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

# Install Flutter as non-root user
RUN git clone https://github.com/flutter/flutter.git ./flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy project files
WORKDIR /home/flutteruser/app
COPY --chown=flutteruser:flutteruser . .

# Build the specific app folder
WORKDIR /home/flutteruser/app/quiz_app
RUN flutter pub get
RUN flutter build web --release

# Stage 2 - Serve with Nginx
FROM nginx:alpine
# Copy the build output from the build-env stage
COPY --from=build-env /home/flutteruser/app/quiz_app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
