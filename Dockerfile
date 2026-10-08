FROM node:22-slim AS builder

LABEL maintainer="info@redpencil.io"

RUN corepack enable

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm i --frozen-lockfile
COPY . .
RUN npm run build

FROM semtech/static-file-service:0.2.0

ENV EMBER_GN_FEATURE_REGULATORY_STATEMENTS=false

COPY --from=builder /app/dist /data
