using from '../config-service';

extend service ConfigService with {
  function MapsApiKey() returns String;
  function MapsMapId()  returns String;
}
