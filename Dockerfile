FROM node:20-alpine

RUN apk add --no-cache unzip

WORKDIR /app

COPY terabox-api.zip /app/

# ZIP extract karo - files ek folder mein hain, unhe bahar nikaalo
RUN unzip -o terabox-api.zip -d /tmp/ && \
    # Check karo ki ZIP ke andar folder hai ya nahi
    if [ -d "/tmp/terabox-api" ]; then \
        cp -r /tmp/terabox-api/* /app/; \
    else \
        cp -r /tmp/* /app/; \
    fi && \
    rm -rf /tmp/terabox-api.zip /tmp/terabox-api

# Ab package.json mil jayega
RUN npm install --omit=dev && npm cache clean --force

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

USER nodejs

EXPOSE ${PORT:-3000}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3000}/api/health || exit 1

CMD ["node", "server.js"]
