FROM node:12-alpine

COPY ./ /app
WORKDIR /app/user-list-front

RUN npm i
RUN npm run build:mac

WORKDIR /app/user-list-back

RUN npm i
RUN npm run build

EXPOSE 3000

CMD npm run start:prod

