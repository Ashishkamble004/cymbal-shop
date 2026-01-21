FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .
COPY tat_neu/ ./tat_neu/

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["python", "main.py"]
