# get the repo
FROM alpine/git as repo
ARG FOCALBOARD_TAG=v0.9.2
RUN git clone -b ${FOCALBOARD_TAG} --depth 1 https://github.com/mattermost/focalboard.git /focalboard


# build the frontend
FROM node:16.3.0 AS frontend
WORKDIR /webapp
COPY --from=repo /focalboard/webapp .
RUN npm install --no-optional
RUN npm run pack


# build the backend
FROM golang:1.17.2 AS backend
ARG TARGETARCH=arm
WORKDIR /focalboard
COPY --from=repo /focalboard .
RUN sed -i "s/GOARCH=amd64/GOARCH=${TARGETARCH}/g" Makefile
RUN make server-linux


# final image
FROM debian:buster-slim
WORKDIR /opt/focalboard
COPY --from=backend /focalboard/bin/linux/focalboard-server ./bin/
COPY --from=backend /focalboard/build/MIT-COMPILED-LICENSE.md ./
COPY --from=backend /focalboard/NOTICE.txt ./
COPY --from=frontend /webapp/pack ./pack
COPY --from=frontend /webapp/NOTICE.txt ./webapp-NOTICE.txt

CMD ["/opt/focalboard/bin/focalboard-server"]
