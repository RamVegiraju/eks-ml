# Serving ML Models with Docker
In this repository we'll have a quick introduction to Docker and how we can use it to serve ML models. Traditionally ML models that live standalone in Jupyter Notebooks don't have any functional purpose. Utilizing a containerization tool like Docker we can help port and serve these models very simply. Later on in this series we'll also explore Kubernetes and how we can scale model inference.

In this example specifically we'll take a look at serving a simple Transformers translation model utilizing FastAPI and Uvicorn as the underlying server. We will showcase our Dockerfile, build an image, run the container, and execute sample inference.

## Docker Commands
Commands to follow along in the video:
```
# Build the Docker image
docker build -t fastapi-transformers:latest .

# Run the Docker container
docker run -d -p 8000:80 --name fastapi-transformers-container fastapi-transformers:latest
```

## Additional Resources
- [Docker Installation](https://www.docker.com/)
- [Docker Tutorial](https://www.youtube.com/watch?v=pg19Z8LL06w)