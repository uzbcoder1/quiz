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

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor and enable web
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy files and build
WORKDIR /app
COPY . .
WORKDIR /app/quiz_app
RUN flutter pub get
RUN flutter build web --release

# Stage 2 - Serve
FROM nginx:alpine
COPY --from=build-env /app/quiz_app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
