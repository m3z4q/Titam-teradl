FROM node:20-alpine

RUN apk add --no-cache unzip findutils

WORKDIR /app

COPY terabox-api.zip /app/

RUN unzip -o terabox-api.zip && \
    rm -f terabox-api.zip && \
    # Agar koi folder bana hai (jaise terabox-api/) toh uske contents ko /app mein lao
    if [ "$(ls -d */ 2>/dev/null)" ]; then \
        for dir in */; do \
            if [ "$dir" != "node_modules/" ]; then \
                cd "$dir" && cp -r . .. && cd .. && rm -rf "$dir"; \
            fi; \
        done; \
    fi

RUN npm install --omit=dev && npm cache clean --force

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

USER nodejs

EXPOSE ${PORT:-3000}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3000}/api/health || exit 1

CMD ["node", "server.js"]
