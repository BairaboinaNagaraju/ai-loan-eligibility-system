# --- Stage 1: Build React Frontend ---
FROM node:22-alpine AS frontend-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- Stage 2: Serve Backend & Frontend ---
FROM python:3.11-slim
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir email-validator

# Copy backend codebase
COPY backend/ ./

# Copy compiled frontend assets to backend static folder
COPY --from=frontend-builder /frontend/dist /app/static

# Expose port
EXPOSE 8000

# Set environment variables
ENV PORT=8000
ENV JWT_SECRET_KEY=b3a4a835b62b7cd493a1c8f61596eb4c02cf3c9597ad89ef7dc830c2394747eb

# Command to run uvicorn
CMD ["sh", "-c", "python scripts/train.py && uvicorn app.main:app --host 0.0.0.0 --port $PORT"]
