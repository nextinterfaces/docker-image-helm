FROM node:18-alpine
WORKDIR /usr/src/app
COPY app/ .
RUN npm install
CMD ["npm", "start"]
EXPOSE 3000
