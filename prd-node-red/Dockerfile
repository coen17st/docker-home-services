FROM nodered/node-red

# add extra nodes in the package.json file.
COPY data/package.json .

RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production

COPY data/settings.js /data/settings.js

COPY data/flows.json /data/flows.json