FROM node:20-alpine

WORKDIR /srv

RUN npm i -g @sap/cds-dk

COPY . .

EXPOSE 4004

ADD package.json /

RUN npm install

CMD ["npm" , "run", "serve-production"]