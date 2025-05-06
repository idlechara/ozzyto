ARG TARGETARCH=arm
ARG TARGETVARIANT=v7

# Use Debian as base image
FROM debian:bookworm

# Set environment variables for configuration
ENV NGINX_RTMP_HOST=localhost \
    STREAM_WIDTH=1280 \
    STREAM_HEIGHT=720 \
    STREAM_FRAMERATE=30 \
    STREAM_PATH=live/stream \
    VIDEO_DEVICE=/dev/video0

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    netcat-openbsd \
    procps \
    v4l-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# For Raspberry Pi, add Pi-specific tools
RUN case "${TARGETARCH}${TARGETVARIANT}" in \
      "armv7") \
        apt-get update && \
        apt-get install -y --no-install-recommends gnupg && \
        echo "deb http://archive.raspberrypi.org/debian/ bookworm main" > /etc/apt/sources.list.d/raspi.list && \
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82B129927FA3303E && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
          libcamera-apps \
          rpicam-apps \
          && apt-get clean \
          && rm -rf /var/lib/apt/lists/* \
        ;; \
      "arm64") \
        apt-get update && \
        apt-get install -y --no-install-recommends gnupg && \
        echo "deb http://archive.raspberrypi.org/debian/ bookworm main" > /etc/apt/sources.list.d/raspi.list && \
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82B129927FA3303E && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
          libcamera-apps \
          rpicam-apps \
          && apt-get clean \
          && rm -rf /var/lib/apt/lists/* \
        ;; \
      *) \
        echo "Standard build for ${TARGETARCH}${TARGETVARIANT}" \
        ;; \
    esac

# Create working directory
WORKDIR /app

# Copy streaming script
COPY stream.sh /app/
RUN chmod +x /app/stream.sh

# Command to run
ENTRYPOINT ["/app/stream.sh"]