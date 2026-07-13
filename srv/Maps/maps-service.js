module.exports = async (srv) => {
  srv.on('MapsApiKey', () => process.env.GOOGLE_MAPS_API_KEY || '');
  srv.on('MapsMapId',  () => process.env.GOOGLE_MAPS_MAP_ID  || '');
};
