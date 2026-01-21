# Tata Neu Customer Care Assistant

A real-time, voice-enabled AI customer care assistant for the Tata Neu platform. Built using Google's Agent Development Kit (ADK) with bidirectional streaming capabilities, this application provides an intelligent virtual customer care representative named **Neha** who can assist customers with orders, NeuCard queries, and platform-related support.

## 🌟 Features

- **Real-time Voice & Video Interaction**: Bidirectional streaming support for natural conversations
- **Multi-language Support**: Primary support for Hindi with capabilities in English, Marathi, and Tamil
- **Intelligent Agent Architecture**: Multi-agent system using Google ADK with specialized sub-agents:
  - **Order Management Agent**: Track orders, handle returns, cancellations, and delivery queries
  - **Customer NeuCard Agent**: Manage NeuCard credit cards, NeuCoins balance, and account information
  - **RAG Retrieval Agent**: Access FAQ and policy information using retrieval-augmented generation
- **BigQuery Integration**: Real-time access to customer data, orders, and transaction history
- **Cloud-Native Design**: Containerized with Docker, deployable to Google Cloud Run

## 🏗️ Architecture

```
┌─────────────────┐     WebSocket      ┌──────────────────────┐
│   Web Client    │◄──────────────────►│   FastAPI Server     │
│  (HTML/JS)      │   Audio/Video/Text │   (main.py)          │
└─────────────────┘                    └──────────┬───────────┘
                                                  │
                                    ┌─────────────▼─────────────┐
                                    │    Root Agent (Neha)      │
                                    │  gemini-live-2.5-flash    │
                                    └─────────────┬─────────────┘
                                                  │
                   ┌──────────────────────────────┼──────────────────────────────┐
                   │                              │                              │
         ┌─────────▼─────────┐         ┌─────────▼─────────┐         ┌─────────▼─────────┐
         │   Order Agent     │         │ Customer NeuCard  │         │   RAG Retrieval   │
         │                   │         │      Agent        │         │      Agent        │
         │  gemini-2.5-flash │         │  gemini-2.5-flash │         │  gemini-2.5-flash │
         └─────────┬─────────┘         └─────────┬─────────┘         └───────────────────┘
                   │                              │
         ┌─────────▼─────────┐         ┌─────────▼─────────┐
         │     BigQuery      │         │     BigQuery      │
         │   orders, items   │         │  customers, cards │
         │    tickets        │         │   transactions    │
         └───────────────────┘         └───────────────────┘
```

## 📋 Prerequisites

- **Python 3.11+**
- **Google Cloud Project** with:
  - BigQuery API enabled
  - Vertex AI API enabled
  - Application Default Credentials configured
- **Docker** (for containerized deployment)
- **Node.js/npm** (optional, for local client development)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Ashishkamble004/cymbal-shop.git
cd cymbal-shop
```

### 2. Set Up Google Cloud Credentials

```bash
# Authenticate with Google Cloud
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 3. Set Up BigQuery

Run the SQL setup script to create the required tables and sample data:

```bash
# Navigate to the server directory
cd app/server

# Execute the BigQuery setup script in your GCP console or using bq CLI
bq query --use_legacy_sql=false < bigquery_tata_neu_setup.sql
```

### 4. Configure Environment Variables

Create a `.env` file in the `app/server` directory:

```bash
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT=your-project-id
BQ_CRM_DATASET=tata_neu_orders

# Agent Configuration
DEMO_AGENT_MODEL=gemini-live-2.5-flash-native-audio
VOICE_NAME=Leda

# Server Configuration
HOST=0.0.0.0
PORT=8080
```

### 5. Install Dependencies

```bash
cd app/server
pip install -r requirements.txt
```

### 6. Run the Server

```bash
# Using the start script
./start_servers.sh

# Or directly with Python
python main.py
```

### 7. Access the Application

Open your browser and navigate to:
- **Server API**: `http://localhost:8080`
- **Client Interface**: Serve the `app/client/multimodal.html` file using a local web server

## 📁 Project Structure

```
cymbal-shop/
└── app/
    ├── client/                     # Frontend web client
    │   ├── Dockerfile             # Client container configuration
    │   ├── multimodal.html        # Main web interface
    │   ├── multimodal-client.js   # WebSocket client for multimodal
    │   ├── audio-client.js        # Audio handling utilities
    │   ├── nginx.conf             # Nginx configuration
    │   └── *.png                  # UI assets
    │
    ├── server/                     # Backend server
    │   ├── Dockerfile             # Server container configuration
    │   ├── main.py                # FastAPI application entry point
    │   ├── requirements.txt       # Python dependencies
    │   ├── start_servers.sh       # Server startup script
    │   ├── bigquery_tata_neu_setup.sql  # Database setup script
    │   ├── cloudbuild.yaml        # Cloud Build configuration
    │   └── tat_neu/               # Agent modules
    │       ├── __init__.py
    │       ├── agent.py           # Root agent (Neha)
    │       └── sub_agents/        # Specialized sub-agents
    │           ├── __init__.py
    │           ├── order_agent.py        # Order management
    │           ├── customer_neucard_agent.py  # NeuCard & customer profile
    │           └── rag_agent.py          # FAQ retrieval
    │
    └── test_prompts.md            # Test scenarios and sample prompts
```

## 🐳 Docker Deployment

### Build and Run Server

```bash
cd app/server
docker build -t tata-neu-server .
docker run -p 8080:8080 \
  -e GOOGLE_CLOUD_PROJECT=your-project-id \
  -e BQ_CRM_DATASET=tata_neu_orders \
  tata-neu-server
```

### Build and Run Client

```bash
cd app/client
docker build -t tata-neu-client .
docker run -p 80:80 tata-neu-client
```

## ☁️ Google Cloud Run Deployment

Use Cloud Build to deploy both services:

```bash
# Deploy server
cd app/server
gcloud builds submit --config cloudbuild.yaml

# Deploy client
cd app/client
gcloud builds submit --config cloudbuild.yaml
```

## 🔌 WebSocket API

### Connection

```javascript
const ws = new WebSocket('wss://your-server/ws/{user_id}/{session_id}');
```

**Parameters:**
- `user_id`: Unique identifier for the user (any string, e.g., `user_abc123`)
- `session_id`: Unique identifier for the session (any string, e.g., `session_xyz789`)

A legacy endpoint `/ws` is also available which auto-generates random user and session IDs.

### Message Types

**Client → Server:**
| Type | Description |
|------|-------------|
| `audio` | Base64-encoded PCM audio data |
| `video` | Base64-encoded JPEG video frame |
| `text` | Text message |
| `ping` | Keep-alive ping |
| `end_session` | End the session |

**Server → Client:**
| Type | Description |
|------|-------------|
| `audio` | Base64-encoded PCM audio response |
| `input_transcription` | User speech transcription |
| `output_transcription` | Agent response transcription |
| `tool_call` | Sub-agent invocation notification |
| `turn_complete` | Agent finished responding |
| `interrupted` | User interrupted the agent |

## 📊 Database Schema

The application uses BigQuery with the following main tables:

- **customers**: Customer profiles, tier, NeuCoins balance
- **orders**: Order details, status, delivery information
- **order_items**: Individual items in each order
- **neu_cards**: NeuCard credit card information
- **card_transactions**: Credit card transaction history
- **card_statements**: Monthly billing statements
- **support_tickets**: Customer support tickets
- **neucoins_transactions**: NeuCoins earning and redemption history

See `app/server/bigquery_tata_neu_setup.sql` for complete schema and sample data.

## 🧪 Testing

Refer to `app/test_prompts.md` for comprehensive test scenarios including:

- Order status queries
- Return and refund scenarios
- NeuCard balance and transaction queries
- NeuCoins balance checks
- Multi-intent queries
- Edge cases and error handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Google Agent Development Kit (ADK)](https://github.com/google/adk-python) - Agent framework
- [FastAPI](https://fastapi.tiangolo.com/) - Web framework
- [Google Cloud BigQuery](https://cloud.google.com/bigquery) - Data warehouse
- [Gemini](https://ai.google.dev/) - AI models
