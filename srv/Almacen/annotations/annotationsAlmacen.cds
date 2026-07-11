using { ConfigService } from '../../service';

annotate ConfigService.Almacenes with @(
    odata.draft.enabled,
    Capabilities : {
        InsertRestrictions : { Insertable : true },
        UpdateRestrictions : { Updatable : true },
        DeleteRestrictions : { Deletable : true }
    },
    UI : {
        HeaderInfo : {
            TypeName : 'Almacen',
            TypeNamePlural : 'Almacenes',
            Title : { Value : nombreSede },
            Description : { Value : ubicacion }
        },
        LineItem : [
            { Value : nombreSede, Label : 'Sede', Importance : #High },
            { Value : ubicacion, Label : 'Ubicacion', Importance : #High },
            { Value : responsable, Label : 'Responsable', Importance : #Medium },
            { Value : capacidadTotal, Label : 'Capacidad total', Importance : #Medium },
            { Value : actual, Label : 'Capacidad actual', Importance : #Medium },
            { Value : estado, Label : 'Estado', Importance : #Medium }
        ],
        Identification : [
            { Value : nombreSede, Label : 'Sede' },
            { Value : ubicacion, Label : 'Ubicacion' },
            { Value : responsable, Label : 'Responsable' },
            { Value : capacidadTotal, Label : 'Capacidad total' },
            { Value : actual, Label : 'Capacidad actual' },
            { Value : estado, Label : 'Estado' }
        ],
        Facets  : [
            {
                $Type : 'UI.ReferenceFacet',
                Target : '@UI.Identification',
                Label : 'Datos generales del almacen'
            },
            {
                $Type : 'UI.CollectionFacet',
                ID : 'TanquesSubtable',
                Label : 'Tanques del almacen',
                Facets : [
                    {
                        $Type : 'UI.ReferenceFacet',
                        Label : 'Tanques',
                        Target : 'tanques/@UI.LineItem#SubTablaTanques'
                    }
                ]
            }
        ],
    }
) {
    tanques @Capabilities.InsertRestrictions : { Insertable : true };
    estado @Common.ValueListWithFixedValues : true;
};

annotate ConfigService.Tanques with @UI.LineItem #SubTablaTanques : [
    { Value : codigo, Label : 'Codigo' },
    { Value : descripcion, Label : 'Descripcion' },
    { Value : tipo_combustible, Label : 'Tipo combustible' },
    { Value : capacidadTotal, Label : 'Capacidad total' },
    { Value : nivel_actual, Label : 'Nivel actual' },
    { Value : nivel_minimo, Label : 'Nivel minimo' },
    { Value : estadoTanque.code, Label : 'Estado del tanque' }
];
