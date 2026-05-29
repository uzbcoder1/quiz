# Stage 1 - Build
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -ms /bin/bash flutteruser
USER flutteruser
WORKDIR /home/flutteruser

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git ./flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy project files
WORKDIR /home/flutteruser/app
COPY --chown=flutteruser:flutteruser . .

# Build the web version
WORKDIR /home/flutteruser/app/quiz_app
RUN flutter pub get
RUN flutter build web --release

# Stage 2 - Serve with Nginx
FROM nginx:alpine

# Custom nginx config to use dynamic port from Railway
RUN printf "server {\n  listen 8080;\n  location / {\n    root /usr/share/nginx/html;\n    index index.html;\n    try_files \$uri \$uri/ /index.html;\n  }\n}\n" > /etc/nginx/conf.d/default.conf

COPY --from=build-env /home/flutteruser/app/quiz_app/build/web /usr/share/nginx/html

# Railway often uses 8080 by default
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
