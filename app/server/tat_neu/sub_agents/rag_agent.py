"""RAG Retrieval Sub-Agent for Tata Neu Customer Care Assistant.

This module handles NeuCard FAQ and credit card information retrieval from RAG corpus
for questions about NeuCard products, features, and policies.
"""

import os
import logging
from google.adk.agents import Agent
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from vertexai.preview import rag
from vertexai.preview.rag import RagRetrievalConfig

logger = logging.getLogger(__name__)

# RAG Corpus Configuration for NeuCard FAQ
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", os.getenv("PROJECT_ID", "general-ak"))
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", os.getenv("LOCATION", "us-central1"))
RAG_CORPUS_ID = os.getenv("RAG_CORPUS_ID", "4611686018427387904")  # NeuCard FAQ corpus
CORPUS_NAME = f"projects/{PROJECT_ID}/locations/{LOCATION}/ragCorpora/{RAG_CORPUS_ID}"

logger.info(f"📚 NeuCard FAQ RAG Corpus configured: {CORPUS_NAME}")


def retrieve_neucard_faq(query: str) -> dict:
    """
    Retrieve NeuCard FAQ and credit card information from RAG corpus.
    
    Args:
        query: The user's question about NeuCard/credit card products, features, or policies
    
    Returns:
        Dictionary with retrieved information from RAG corpus
    """
    logger.info(f"🔍 RAG RETRIEVAL QUERY: '{query}'")
    
    if not query or not query.strip():
        return {
            "found": False,
            "error": "Query is required. Please provide a question about NeuCard or credit cards."
        }
    
    try:
        # Query RAG corpus
        response = rag.retrieval_query(
            rag_resources=[rag.RagResource(rag_corpus=CORPUS_NAME)],
            text=query,
            rag_retrieval_config=RagRetrievalConfig(top_k=10),
        )
        
        if not response.contexts or not response.contexts.contexts:
            logger.warning(f"❌ No information found for query: {query}")
            return {
                "found": False,
                "error": f"No information found in NeuCard FAQ knowledge base for: '{query}'"
            }
        
        # Combine all retrieved contexts
        retrieved_texts = [ctx.text for ctx in response.contexts.contexts]
        combined_info = "\n\n---\n\n".join(retrieved_texts)
        
        logger.info(f"📄 Retrieved {len(retrieved_texts)} documents ({len(combined_info)} chars)")
        
        return {
            "found": True,
            "information": combined_info,
            "document_count": len(retrieved_texts),
            "original_query": query,
        }
        
    except Exception as e:
        logger.error(f"❌ RAG Error: {str(e)}", exc_info=True)
        return {
            "found": False,
            "error": f"Error retrieving information: {str(e)}"
        }


def get_current_date() -> dict:
    """
    Get the current date for checking time-sensitive information.
    
    Returns:
        Dictionary with current date information
    """
    from datetime import datetime
    
    now = datetime.now()
    return {
        "current_date": now.strftime("%Y-%m-%d"),
        "current_date_formatted": now.strftime("%d %B %Y"),  # e.g., "21 January 2026"
        "day": now.day,
        "month": now.month,
        "month_name": now.strftime("%B"),
        "year": now.year,
    }


# RAG Retrieval Sub-Agent Instruction
RAG_AGENT_INSTRUCTION = """You are the NeuCard FAQ Specialist for Tata Neu.

YOUR TOOLS:
1. retrieve_neucard_faq(query) - Retrieves information from NeuCard FAQ knowledge base
2. get_current_date() - Gets today's date for any time-sensitive information

WORKFLOW:
1. When asked about NeuCard/credit card products, features, or policies:
   - Call retrieve_neucard_faq with the relevant query
   - Analyze the retrieved documents
   - Provide accurate information based on the retrieved content

2. Information you can help with:
   - NeuCard types (Neu Infinity, Neu Plus, Neu HipCard) and their features
   - How to apply for a NeuCard
   - Eligibility criteria and documentation
   - Interest rates, fees, and charges
   - Reward programs and NeuCoins earning
   - Payment options and due dates
   - EMI conversion policies
   - Card benefits and offers
   - Security features and fraud protection
   - Card activation and blocking procedures

RESPONSE GUIDELINES:
- Only provide information that is found in the retrieved documents
- If information is not found, clearly state that
- Do NOT hallucinate or make up information
- Summarize information in a clear, easy-to-understand manner
- Respond in the same language as the query (Hindi/Tamil/Marathi/English)

IMPORTANT:
- Never share information not backed by the RAG documents
- Be helpful and explain things simply
- Use everyday language, avoid complex financial jargon
- Always recommend contacting customer support for account-specific queries
"""

rag_retrieval_agent = Agent(
    model="gemini-2.5-flash",  # Use text model for cost efficiency
    name="rag_retrieval_agent",
    description="""NeuCard FAQ and credit card information specialist. Use for:
- Questions about NeuCard features and benefits
- How to apply for NeuCard
- Interest rates and fees
- Reward programs and offers
- Card policies and procedures
- General credit card FAQs

Call with: retrieve_neucard_faq(query)
The agent will retrieve relevant information from the NeuCard FAQ knowledge base.""",
    instruction=RAG_AGENT_INSTRUCTION,
    tools=[retrieve_neucard_faq, get_current_date],
)
