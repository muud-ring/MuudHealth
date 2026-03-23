FROM node:20-alpine

WORKDIR /app

COPY backend/package.json backend/package-lock.json ./
RUN npm ci --omit=dev

COPY backend/src ./src
COPY backend/prototype ./prototype

ENV PORT=4000
EXPOSE 4000

CMD ["node", "src/prototype.js"]
