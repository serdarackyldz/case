# Stage 1: Build stage
FROM python:3.9-alpine as builder

# Install dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies to a directory within the builder stage
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app.py .

# Stage 2: Final stage
FROM python:3.9-alpine

# Set the working directory
WORKDIR /app

# Copy the dependencies from the build stage
COPY --from=builder /install /usr/local

# Copy the application code
COPY app.py .

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["flask", "run"]
