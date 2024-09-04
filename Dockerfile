
FROM node:18-alpine

WORKDIR /simple-reactjs-app


COPY . .

RUN npm cache clean --force

RUN npm install && npm run build && npm install -g create-react-app

EXPOSE 3000

CMD ["npm","start"]

