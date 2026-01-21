"""Tata Neu Customer Care Assistant Agent package.

Uses AgentTool pattern for calling sub-agents:
- Root agent: Live API (gemini-live-2.5-flash-native-audio) for voice/video
- Sub-agents: Text model (gemini-2.5-flash) for cost efficiency

Sub-agents are called as tools via AgentTool wrapper:
- order_agent: Order management and tracking via BigQuery
- customer_neucard_agent: Customer profile, NeuCoins, and NeuCard queries via BigQuery
- rag_retrieval_agent: NeuCard FAQ and policy retrieval from RAG corpus
"""

from .agent import agent

__all__ = ["agent"]
