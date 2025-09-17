# Use a small, multi-arch image (arm64 on M-series Macs)
FROM python:3.11-slim

# System deps (optional but nice for SSL/certs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app
COPY requirements.txt .

# Install deps
# For CPU-only PyTorch on Linux (arm64/x86) use the PyTorch index URL:
RUN pip install --no-cache-dir -r requirements.txt \
    --extra-index-url https://download.pytorch.org/whl/cpu

# Copy app
COPY app.py .

# Expose the HTTP port (inside the container)
EXPOSE 80

# Start the server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80"]