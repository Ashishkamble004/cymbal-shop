"""FastAPI application for Tata Neu Customer Care Assistant using ADK Bidi-streaming.

This is the main entry point for the Tata Neu Customer Care Representative (Neha) backend.
Follows the ADK bidi-streaming pattern from google/adk-samples.
Uses multi-agent architecture with AgentTool pattern.
"""

import asyncio
import json
import logging
import warnings
import base64
import os
from typing import List, Dict, Any
from datetime import datetime

from dotenv import load_dotenv

# Load environment variables BEFORE importing agent
load_dotenv()

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from google.adk.agents.live_request_queue import LiveRequestQueue
from google.adk.agents.run_config import RunConfig, StreamingMode
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

from tat_neu import agent

# Configure logging
logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Suppress Pydantic serialization warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pydantic")

# Application constants
APP_NAME = "tata-neu-customer-care"
VOICE_NAME = os.getenv("VOICE_NAME", "Leda")
SEND_SAMPLE_RATE = 16000  # Rate of audio sent to Gemini
RECEIVE_SAMPLE_RATE = 24000  # Rate of audio received from Gemini

# ========================================
# Phase 1: Application Initialization (once at startup)
# ========================================

app = FastAPI(title="Tata Neu Customer Care Assistant - ADK Bidi-streaming")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define your session service
session_service = InMemorySessionService()

# Define your runner
runner = Runner(app_name=APP_NAME, agent=agent, session_service=session_service)


# ========================================
# HTTP Endpoints
# ========================================


@app.get("/health")
async def health_check():
    """Health check endpoint for Cloud Run."""
    return {"status": "healthy", "app": APP_NAME}


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Tata Neu Customer Care Assistant - ADK Bidi-streaming",
        "websocket_endpoint": "/ws/{user_id}/{session_id}",
        "legacy_websocket_endpoint": "/ws",
        "health_check": "/health"
    }


# ========================================
# WebSocket Endpoint
# ========================================


@app.websocket("/ws/{user_id}/{session_id}")
async def websocket_endpoint(
    websocket: WebSocket, user_id: str, session_id: str
) -> None:
    """WebSocket endpoint for bidirectional streaming with ADK.
    
    Protocol:
    - Client sends: {"type": "audio", "data": base64_encoded_pcm}
    - Client sends: {"type": "video", "data": base64_encoded_jpeg, "mimeType": "image/jpeg"}
    - Client sends: {"type": "text", "data": "message"}
    - Client sends: {"type": "ping"} - keep-alive
    - Server sends: {"type": "audio", "data": base64_encoded_pcm}
    - Server sends: {"type": "text", "data": "transcription"}
    - Server sends: {"type": "tool_call", "data": {...}}
    - Server sends: {"type": "turn_complete", "session_id": "..."}
    - Server sends: {"type": "interrupted", "data": "..."}
    """
    logger.debug(
        f"WebSocket connection request: user_id={user_id}, session_id={session_id}"
    )
    await websocket.accept()
    logger.debug("WebSocket connection accepted")

    # Session data collectors
    session_start_time = datetime.utcnow()
    conversation_messages: List[Dict[str, Any]] = []

    # ========================================
    # Phase 2: Session Initialization
    # ========================================

    # Native audio models require AUDIO response modality
    # Note: Automatic VAD (Voice Activity Detection) is enabled by default
    run_config = RunConfig(
        streaming_mode=StreamingMode.BIDI,
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(
                    voice_name=VOICE_NAME
                )
            ),
        ),
        response_modalities=["AUDIO"],
        output_audio_transcription=types.AudioTranscriptionConfig(),
        input_audio_transcription=types.AudioTranscriptionConfig(),
    )

    logger.debug(f"RunConfig created with voice: {VOICE_NAME}")

    # Get or create session
    session = await session_service.get_session(
        app_name=APP_NAME, user_id=user_id, session_id=session_id
    )
    if not session:
        session = await session_service.create_session(
            app_name=APP_NAME, user_id=user_id, session_id=session_id
        )
        logger.info(f"📝 Created new session: user_id={user_id}, session_id={session_id}")
    else:
        logger.info(f"♻️ Resuming session: user_id={user_id}, session_id={session_id}")

    # Create live request queue for this session
    live_request_queue = LiveRequestQueue()

    # ========================================
    # Phase 3: Task Functions
    # ========================================

    async def upstream_task() -> None:
        """Receives messages from WebSocket and sends to LiveRequestQueue."""
        try:
            while True:
                message = await websocket.receive_text()
                try:
                    data = json.loads(message)
                    msg_type = data.get("type")

                    if msg_type == "audio":
                        # Decode base64 audio and send to Gemini
                        audio_bytes = base64.b64decode(data.get("data", ""))
                        live_request_queue.send_realtime(
                            types.Blob(
                                data=audio_bytes,
                                mime_type=f"audio/pcm;rate={SEND_SAMPLE_RATE}",
                            )
                        )

                    elif msg_type == "video":
                        # Decode base64 video frame and send to Gemini
                        video_bytes = base64.b64decode(data.get("data", ""))
                        live_request_queue.send_realtime(
                            types.Blob(
                                data=video_bytes,
                                mime_type="image/jpeg",
                            )
                        )
                        logger.debug("Video frame sent to Gemini")

                    elif msg_type == "text":
                        # Handle text input
                        text_data = data.get("data", "")
                        logger.info(f"📝 Received text: {text_data}")

                    elif msg_type == "ping":
                        # Keep-alive ping
                        await websocket.send_json({"type": "pong"})

                    elif msg_type == "end_session":
                        # Client wants to end session
                        logger.info("📴 Client requested session end")
                        break

                except json.JSONDecodeError:
                    logger.error("Invalid JSON message received")
                except Exception as e:
                    logger.error(f"Error processing upstream message: {e}")

        except WebSocketDisconnect:
            logger.info("WebSocket disconnected in upstream task")
        except Exception as e:
            logger.error(f"Upstream task error: {e}")

    async def downstream_task() -> None:
        """Receives Events from run_live() and sends to WebSocket."""
        nonlocal conversation_messages
        
        # Track transcriptions
        input_texts = []
        output_texts = []
        current_session_handle = None
        interrupted = False

        logger.debug("Starting downstream task with run_live()")

        # Send initial status message
        await websocket.send_json({"type": "status", "status": "connected"})

        try:
            async for event in runner.run_live(
                user_id=user_id,
                session_id=session_id,
                live_request_queue=live_request_queue,
                run_config=run_config,
            ):
                try:
                    event_str = str(event)

                    # Handle session resumption update
                    if (
                        hasattr(event, "session_resumption_update")
                        and event.session_resumption_update
                    ):
                        update = event.session_resumption_update
                        if update.resumable and update.new_handle:
                            current_session_handle = update.new_handle
                            logger.info(f"🆔 Session handle: {current_session_handle}")
                            await websocket.send_json({
                                "type": "session_id",
                                "data": current_session_handle
                            })

                    # Handle input transcription
                    if hasattr(event, 'input_transcription') and event.input_transcription:
                        text = event.input_transcription.text
                        is_final = event.input_transcription.finished
                        if text:
                            logger.info(f"🎤 INPUT TRANSCRIPTION: {text[:100]}... (finished={is_final})")
                            input_texts.append(text)
                            await websocket.send_json({
                                "type": "input_transcription",
                                "text": text,
                                "finished": is_final
                            })

                    # Handle output transcription
                    if hasattr(event, 'output_transcription') and event.output_transcription:
                        text = event.output_transcription.text
                        is_final = event.output_transcription.finished
                        if text:
                            logger.info(f"📝 OUTPUT TRANSCRIPTION: {text[:100]}... (finished={is_final})")
                            output_texts.append(text)
                            await websocket.send_json({
                                "type": "output_transcription",
                                "text": text,
                                "finished": is_final
                            })

                    # Handle tool calls (sub-agent invocations)
                    if hasattr(event, "actions") and event.actions:
                        if hasattr(event.actions, "function_calls") and event.actions.function_calls:
                            for fc in event.actions.function_calls:
                                logger.info(f"📞 TOOL CALLED: {fc.name}")
                                await websocket.send_json({
                                    "type": "tool_call",
                                    "data": {
                                        "name": fc.name,
                                        "args": dict(fc.args) if fc.args else {}
                                    }
                                })

                        # Log function responses
                        if hasattr(event.actions, "function_responses") and event.actions.function_responses:
                            for fr in event.actions.function_responses:
                                logger.info(f"📋 TOOL RESPONSE for {fr.name}: {str(fr.response)[:500]}...")

                    # Handle audio content
                    if event.content and event.content.parts:
                        for part in event.content.parts:
                            if part.inline_data and part.inline_data.data:
                                # Base64 encode audio for JSON transmission
                                b64_audio = base64.b64encode(part.inline_data.data).decode("utf-8")
                                await websocket.send_json({
                                    "type": "audio",
                                    "data": b64_audio
                                })

                    # Handle interruption
                    if event.interrupted and not interrupted:
                        logger.info("🤐 INTERRUPTION DETECTED")
                        await websocket.send_json({
                            "type": "interrupted",
                            "data": "Response interrupted by user input"
                        })
                        interrupted = True

                    # Handle turn completion
                    if event.turn_complete:
                        if not interrupted:
                            logger.info("✅ Turn complete")
                            await websocket.send_json({
                                "type": "turn_complete",
                                "session_id": current_session_handle
                            })

                        # Log transcriptions
                        if input_texts:
                            unique_texts = list(dict.fromkeys(input_texts))
                            full_input = " ".join(unique_texts)
                            logger.info(f"🎤 Input: {full_input}")
                            conversation_messages.append({
                                "role": "user",
                                "text": full_input,
                                "timestamp": datetime.utcnow().isoformat()
                            })

                        if output_texts:
                            unique_texts = list(dict.fromkeys(output_texts))
                            full_output = " ".join(unique_texts)
                            logger.info(f"🔊 Output: {full_output}")
                            conversation_messages.append({
                                "role": "assistant",
                                "text": full_output,
                                "timestamp": datetime.utcnow().isoformat()
                            })

                        # Reset for next turn
                        input_texts = []
                        output_texts = []
                        interrupted = False

                except Exception as e:
                    logger.error(f"Error processing event: {e}")

        except Exception as e:
            logger.error(f"Downstream task error: {e}")

    # ========================================
    # Phase 4: Run Tasks Concurrently
    # ========================================

    try:
        upstream = asyncio.create_task(upstream_task())
        downstream = asyncio.create_task(downstream_task())

        # Wait for either task to complete (or fail)
        done, pending = await asyncio.wait(
            [upstream, downstream],
            return_when=asyncio.FIRST_COMPLETED,
        )

        # Cancel remaining tasks
        for task in pending:
            task.cancel()
            try:
                await task
            except asyncio.CancelledError:
                pass

    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected: user_id={user_id}, session_id={session_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
    finally:
        # Log session summary
        session_duration = (datetime.utcnow() - session_start_time).total_seconds()
        logger.info(f"📊 Session ended: duration={session_duration:.1f}s, messages={len(conversation_messages)}")


# Legacy endpoint for backward compatibility
@app.websocket("/ws")
async def websocket_legacy_endpoint(websocket: WebSocket) -> None:
    """Legacy WebSocket endpoint without user/session IDs."""
    import uuid
    user_id = f"user_{uuid.uuid4().hex[:8]}"
    session_id = f"session_{uuid.uuid4().hex[:8]}"
    await websocket_endpoint(websocket, user_id, session_id)


# ========================================
# Startup/Shutdown Events
# ========================================


@app.on_event("startup")
async def startup_event():
    """Startup event handler."""
    logger.info(f"🚀 Starting {APP_NAME}")
    logger.info(f"📢 Root Agent: {agent.name} using model: {agent.model}")
    logger.info(f"🔧 Sub-agents loaded via AgentTool pattern")
    logger.info(f"🎙️ Voice: {VOICE_NAME}")


@app.on_event("shutdown")
async def shutdown_event():
    """Shutdown event handler."""
    logger.info(f"👋 Shutting down {APP_NAME}")


# ========================================
# Main Entry Point
# ========================================

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8080"))
    
    logger.info(f"Starting server on {host}:{port}")
    uvicorn.run(app, host=host, port=port)
