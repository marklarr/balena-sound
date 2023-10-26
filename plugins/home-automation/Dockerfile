FROM ghcr.io/home-assistant/home-assistant:stable

COPY start.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh
RUN mkdir -p /camera_recordings/cat_feeding

CMD ["bash","/tmp/start.sh"]
