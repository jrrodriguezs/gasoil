using { ConfigService } from '../../srv/config-service';
using from '../../srv/SurtidoUnidad/annotations/annotationsSurtidoUnidad';

annotate ConfigService.SurtidosUnidad with {
    ID @UI.Hidden;
};
