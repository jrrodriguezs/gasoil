using {ConfigService} from '../service/service';

annotate ConfigService.Rubros with {
    ID @UI.Hidden;
    name @title : 'Nombre';
    description @title : 'Descripción' @UI.MultiLineText: true;
}

annotate ConfigService.Rubros with @odata.draft.enabled @(
    UI.HeaderInfo: {
        $Type : 'UI.HeaderInfoType',
        Title : {
            $Type : 'UI.DataField',
            Value : name,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : description,
        },
        TypeName : 'Rubro',
        TypeNamePlural : 'Rubros',
    },
    UI.LineItem: [
        {
            $Type : 'UI.DataField',
            Value : name,
        },
        {
            $Type : 'UI.DataField',
            Value : description,
        },
    ],
    UI.FieldGroup: {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : name,
            },
            {
                $Type : 'UI.DataField',
                Value : description,
            },
        ],
    },
    UI.Facets: [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup',
            Label : 'Datos Generales',
            ID : 'RubroFacet1',
        },
    ]
)