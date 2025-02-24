

# Dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://ollama.ai/install.sh | sh

EXPOSE 11434

WORKDIR /root

RUN echo '#!/bin/bash\nollama serve' > /root/start.sh && \
    chmod +x /root/start.sh

ENTRYPOINT ["/root/start.sh"]