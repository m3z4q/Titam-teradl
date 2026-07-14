FROM node:20-alpine

# Install unzip for ZIP file extraction
RUN apk add --no-cache unzip

WORKDIR /app

# Agar ZIP file hai toh extract karo
COPY terabox-api.zip /app/
RUN unzip -o terabox-api.zip -d /app/ && rm -f terabox-api.zip

# COPY package*.json ./    ← ISE HATAA DO
# RUN npm ci --only=production && npm cache clean --force    ← ISE BADLO

# ✅ Direct npm install use karo (package-lock.json ki zaroorat nahi)
RUN npm install --omit=dev && npm cache clean --force

# COPY . .    ← ISE BHI HATAA DO (ZIP ne sab extract kar diya)

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

USER nodejs

EXPOSE ${PORT:-3000}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3000}/api/health || exit 1

CMD ["node", "server.js"]
