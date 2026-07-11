
using { ConfigService } from '../../service';


annotate ConfigService.Rutas with {
	distanciaKm @Measures.Unit : 'km'
};


annotate ConfigService.Rutas with @(
	odata.draft.enabled,
	Capabilities : {
		InsertRestrictions : { Insertable : true },
		UpdateRestrictions : { Updatable : true },
		DeleteRestrictions : { Deletable : true }
	},
	UI : {
		HeaderInfo : {
			TypeName : 'Ruta',
			TypeNamePlural : 'Rutas',
			Title : { Value : descripcion },
			Description : { Value : ID }
		},
		LineItem : [
			{ Value : ID, Label : 'Codigo' },
			{ Value : descripcion, Label : 'Descripcion' },
			{ Value : distanciaKm, Label : 'Distancia (km)' },
			{ Value : latitud, Label : 'Latitud' },
			{ Value : longitud, Label : 'Longitud' },
			{ Value : destinosCount, Label : 'Destinos' },
			{ Value : destinosDescripcion, Label : 'Descripcion destinos' }
		],
		Facets : [
			{
				$Type : 'UI.ReferenceFacet',
				ID : 'DatosRuta',
				Label : 'Datos de la ruta',
				Target : '@UI.Identification'
			},
			{
				$Type : 'UI.ReferenceFacet',
				ID : 'PuntosRuta',
				Label : 'Puntos de la ruta',
				Target : 'puntos/@UI.LineItem'
			}
		],
		Identification : [
			{ Value : ID, Label : 'Codigo' },
			{ Value : descripcion, Label : 'Descripcion' },
			{ Value : distanciaKm, Label : 'Distancia (km)' },
			{ Value : latitud, Label : 'Latitud' },
			{ Value : longitud, Label : 'Longitud' },
			{ Value : destinosCount, Label : 'Destinos' },
			{ Value : destinosDescripcion, Label : 'Descripcion destinos' }
		]
	}
) {
	destinosDescripcion @Common.FieldControl : #ReadOnly;
};

annotate ConfigService.Rutas with @UI.LineItem #RutaVH : [
  { Value : descripcion, Label : 'Descripcion' },
  { Value : distanciaKm, Label : 'Distancia (km)' }
];

annotate ConfigService.Rutas with @UI.PresentationVariant #RutaVH : {
  Visualizations : ['@UI.LineItem#RutaVH']
};

annotate ConfigService.PuntoCoordenadas with @(
	UI : {
		LineItem : [
			{ Value : descripcion, Label : 'Descripcion' },
			{ Value : latitud, Label : 'Latitud' },
			{ Value : longitud, Label : 'Longitud' },
			{ Value : createdAt, Label : 'Registrado' }
		],
		PresentationVariant : {
			SortOrder : [
				{ Property : createdAt, Descending : false }
			]
		}
	}
);
