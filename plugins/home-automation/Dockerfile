FROM homeassistant/raspberrypi4-homeassistant:stable

COPY start.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh
RUN mkdir /camera_recordings/

CMD ["bash","/tmp/start.sh"]
