FROM node:20-alpine

WORKDIR /app

COPY Backend/package.json Backend/package-lock.json ./
RUN npm ci --omit=dev

COPY Backend/src ./src
COPY Backend/prototype ./prototype

ENV PORT=4000
EXPOSE 4000

CMD ["node", "src/prototype.js"]
