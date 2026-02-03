FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy dbt project
COPY . .

# Set default profile
ENV DBT_PROFILES_DIR=/app/profiles

# Create profiles directory and copy example
RUN mkdir -p /app/profiles && \
    cp profiles.yml.example /app/profiles/profiles.yml

# Default command
CMD ["dbt", "run"]
