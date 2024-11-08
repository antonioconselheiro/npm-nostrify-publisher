FROM denoland/deno

# Including git
RUN apt update
RUN apt install -y git
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /npm-nostrify-publisher

# Keyboard & Timezone
ENV LANG=C.UTF-8
ENV TZ=America/Sao_Paulo

# The run the start script
CMD [ "/bin/bash" ]
