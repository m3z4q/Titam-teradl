FROM node:20-alpine

# Install unzip for ZIP file extraction
RUN apk add --no-cache unzip

WORKDIR /app

# Agar ZIP file hai toh pehle extract karo
COPY terabox-api.zip /app/
RUN unzip -o terabox-api.zip -d /app/ && rm terabox-api.zip

# Copy package.json (agar ZIP ke andar nahi hai toh fallback)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy remaining code (agar ZIP ne nahi kiya toh)
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

USER nodejs

EXPOSE ${PORT:-3000}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3000}/api/health || exit 1

CMD ["node", "server.js"]