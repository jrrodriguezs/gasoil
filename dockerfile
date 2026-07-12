FROM node:20-alpine

WORKDIR /srv

RUN npm i -g @sap/cds-dk

COPY . .

EXPOSE 4004

ADD package.json /

RUN npm install

# FIX-024: No copiar .env a la imagen Docker.
# Las credenciales se inyectan via variables de entorno en runtime
# (docker run -e GAS_DB_HOST=... -e GAS_DB_PASSWORD=...).
# En Kubernetes/Cloud Foundry se usan Secrets o VCAP_SERVICES.
# Si se necesita .env en desarrollo local con Docker, montarlo como volumen:
#   docker run -v $(pwd)/.env:/srv/.env ...

CMD ["npm" , "run", "serve-production"]
