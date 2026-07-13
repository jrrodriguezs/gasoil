
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
			Title : { Value : destino },
			Description : { Value : nombresParadas }
		},
		LineItem : [
			{ Value : destino, Label : 'Paradas' },
			{ Value : distanciaKm, Label : 'Distancia Total (Km)' },
			{ Value : latitud, Label : 'Latitud' },
			{ Value : longitud, Label : 'Longitud' },
			{ Value : destinosCount, Label : 'Destinos' },
			{ Value : nombresParadas, Label : 'Nombres de paradas' }
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
			{ Value : destino, Label : 'Paradas' },
			{ Value : distanciaKm, Label : 'Distancia Total (Km)' },
			{ Value : latitud, Label : 'Latitud' },
			{ Value : longitud, Label : 'Longitud' },
			{ Value : destinosCount, Label : 'Destinos' },
			{ Value : nombresParadas, Label : 'Nombres de paradas' }
		]
	}
) {
	destinosDescripcion @Common.FieldControl : #ReadOnly;
	nombresParadas @Common.FieldControl : #ReadOnly;
	nombresParadas @Core.Computed;
};

annotate ConfigService.Rutas with @UI.LineItem #RutaVH : [
  { Value : destino, Label : 'Paradas' },
  { Value : distanciaKm, Label : 'Distancia Total (Km)' }
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
				{ Property : orden, Descending : false }
			]
		}
	}
);
