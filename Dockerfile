FROM node:18-slim

RUN apt-get update && apt-get install -y git

RUN git clone --recurse-submodules https://github.com/MatWaze/Blob-API.git

WORKDIR /Blob-API/transcendence/api

RUN npm i

RUN npx prisma generate

# Create .env before building
COPY .env .env

EXPOSE 4000

ENTRYPOINT [ "npm", "start" ]