using { ConfigService } from '../../config-service';
using { Rubros as rubro } from '../../../db/schema';

extend service ConfigService with {
    entity Rubros as projection on rubro;
}