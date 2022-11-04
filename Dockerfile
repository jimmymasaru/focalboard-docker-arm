# global args. they still need to be called after each FROM (without '=value'). 
# if it's needed by a FROM, there's no need to call it again.
ARG FOCALBOARD_TAG=v7.1.0
ARG FOCALBOARD_DOCKER_TAG=7.1.0

# get the repo
FROM alpine/git as repo
ARG FOCALBOARD_TAG
RUN git clone -b ${FOCALBOARD_TAG} --depth 1 https://github.com/mattermost/focalboard.git /focalboard

# build the frontend (fails on arm/v7 due to cypress)
# FROM node:16.3.0 AS frontend
# WORKDIR /webapp
# COPY --from=repo /focalboard/webapp .
# RUN npm install --no-optional
# RUN npm run pack

# grab the official frontend

FROM mattermost/focalboard:${FOCALBOARD_DOCKER_TAG} AS frontend_official

# build the backend
FROM golang:1.18.3 AS backend
ARG TARGETARCH=arm
WORKDIR /focalboard
COPY --from=repo /focalboard .
RUN sed -i "s/GOARCH=amd64/GOARCH=${TARGETARCH}/g" Makefile
RUN EXCLUDE_PLUGIN=true EXCLUDE_SERVER=true EXCLUDE_ENTERPRISE=true make server-linux

# final image
FROM debian:buster-slim
WORKDIR /opt/focalboard
COPY --from=backend --chown=nobody:nobody /focalboard/bin/linux/focalboard-server ./bin/
COPY --from=backend --chown=nobody:nobody /focalboard/LICENSE.txt ./LICENSE.txt
# COPY --from=frontend /webapp/pack ./pack
COPY --from=frontend_official --chown=nobody:nobody /opt/focalboard/pack ./pack

CMD ["/opt/focalboard/bin/focalboard-server"]
