# syntax=docker/dockerfile:1.9.0

FROM ghcr.io/prefix-dev/pixi:0.27.1-bookworm

#WORKDIR /app/mylib
WORKDIR /app
COPY pixi.toml .
COPY pixi.lock .

# this is a bit bad -> has to do with the editable packages
# but will trigger a re-run for the full env build of the container
# but if copy 
#COPY mylib mylib

#RUN pixi install -e myenv-static --locked
RUN pixi install -e myenv-static --frozen -vvv
RUN pixi shell-hook -e myenv-static -s bash > /shell-hook
RUN echo "#!/bin/bash" > /app/entrypoint_myenv_static.sh
RUN cat /shell-hook >> /app/entrypoint_myenv_static.sh
RUN echo 'exec "$@"' >> /app/entrypoint_myenv_static.sh


COPY mylib mylib
# the source code is only needed here
#--locked
RUN pixi install -e myenv-dynamic  --frozen -vv
RUN pixi shell-hook -e myenv-dynamic -s bash > /shell-hook
RUN echo "#!/bin/bash" > /app/entrypoint_myenv_editable.sh
RUN cat /shell-hook >> /app/entrypoint_myenv_editable.sh
RUN echo 'exec "$@"' >> /app/entrypoint_myenv_editable.sh

# docker buildx build --progress=plain --platform=linux/amd64 -t foo:xx .
# docker buildx build --platform=linux/amd64 -t foo:xx .