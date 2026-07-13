// @ts-nocheck
sap.ui.define([
	'sap/ui/core/mvc/ControllerExtension',
	'sap/ui/model/json/JSONModel',
	'sap/ui/core/HTML'
],
	function (ControllerExtension, JSONModel, HTML) {
		'use strict';

		return ControllerExtension.extend('com.tandem.almacenmaint.ext.controller.AlmacenOP', {
			// this section allows to extend lifecycle hooks or hooks provided by Fiori elements
			override: {
				/**
				 * Called when a controller is instantiated and its View controls (if available) are already created.
				 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
				 * @memberOf com.tandem.almacenmaint.ext.controller.AlmacenOP
				 */
				onInit: function () {
					// you can access the Fiori elements extensionAPI via this.base.getExtensionAPI
					var oModel = this.base.getExtensionAPI();

				},
				onPageReady: async function () {
					try {
						/** @type {sap.ui.model.odata.v4.ODataModel} */
						let oView = this.getView();
						// Get the binding context of the view
						let oBindingContext = oView.getBindingContext();
						let ID = oBindingContext.getProperty("ID");
						const [providerData, volumeHistory] = await Promise.all([
							this._getProviderData(ID),
							this._getVolumeHistory(ID)
						]);
						const oJSONModel = new JSONModel(providerData);
						this.getView().setModel(oJSONModel, "providerData");

						const oVolumeModel = new JSONModel(volumeHistory);
						this.getView().setModel(oVolumeModel, "volumeHistory");
						console.log({providerData, volumeHistory});

						// Crear el gráfico de línea como SVG inline
						let oChartContainer = oView.byId("volumeChartContainer");
						console.log("volumeChartContainer byId:", oChartContainer);
						if (!oChartContainer) {
							const fullId = oView.getId() + "--fe::CustomSubSection::Proveedor--volumeChartContainer";
							oChartContainer = sap.ui.getCore().byId(fullId);
							console.log("volumeChartContainer por ID completo:", oChartContainer, "ID:", fullId);
						}
						if (oChartContainer && volumeHistory && volumeHistory.points && volumeHistory.points.length) {
							this._renderChart(oChartContainer, volumeHistory);
						} else if (volumeHistory && volumeHistory.points && volumeHistory.points.length) {
							// El fragmento puede no estar renderizado aún; reintentar
							let retries = 0;
							const interval = setInterval(() => {
								retries++;
								let container = oView.byId("volumeChartContainer");
								if (!container) {
									container = sap.ui.getCore().byId(oView.getId() + "--fe::CustomSubSection::Proveedor--volumeChartContainer");
								}
								console.log("Retry", retries, "container:", container);
								if (container) {
									clearInterval(interval);
									this._renderChart(container, volumeHistory);
								} else if (retries > 30) {
									clearInterval(interval);
									console.error("No se encontró volumeChartContainer después de 30 intentos");
								}
							}, 500);
						}
					} catch (error) {
						console.error("Error en onPageReady:", error);
						this.getView().setModel(new JSONModel({ PerTanques: null }), "providerData");
						this.getView().setModel(new JSONModel({ points: null, leftBottomLabel: "", rightBottomLabel: "" }), "volumeHistory");
					}
				}
			},

			_buildLineChartSVG(volumeHistory) {
				const points = volumeHistory.points;
				const width = 600;
				const height = 120;
				const padding = { top: 20, right: 20, bottom: 30, left: 60 };
				const chartWidth = width - padding.left - padding.right;
				const chartHeight = height - padding.top - padding.bottom;
				const minY = Math.min(...points.map(p => p.y), 0);
				const maxY = Math.max(...points.map(p => p.y), 1);
				const yRange = maxY - minY || 1;
				const xRange = points.length - 1 || 1;

				const mapX = (i) => padding.left + (i / xRange) * chartWidth;
				const mapY = (y) => padding.top + chartHeight - ((y - minY) / yRange) * chartHeight;

				const polylinePoints = points.map((p, i) => `${mapX(i)},${mapY(p.y)}`).join(" ");

				const formatNumber = (n) => n.toLocaleString();

				// Etiquetas del eje Y (min, max)
				const yTicks = [
					{ y: minY, label: formatNumber(Math.round(minY)) },
					{ y: maxY, label: formatNumber(Math.round(maxY)) }
				];

				let svg = `<svg width="100%" height="120px" viewBox="0 0 ${width} ${height}" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">`;
				svg += `<rect width="${width}" height="${height}" fill="transparent"/>`;

				// Eje Y
				svg += `<line x1="${padding.left}" y1="${padding.top}" x2="${padding.left}" y2="${padding.top + chartHeight}" stroke="#ccc" stroke-width="1"/>`;
				// Eje X
				svg += `<line x1="${padding.left}" y1="${padding.top + chartHeight}" x2="${padding.left + chartWidth}" y2="${padding.top + chartHeight}" stroke="#ccc" stroke-width="1"/>`;

				// Línea de datos
				svg += `<polyline fill="none" stroke="#0070f2" stroke-width="2" points="${polylinePoints}"/>`;

				// Puntos
				points.forEach((p, i) => {
					svg += `<circle cx="${mapX(i)}" cy="${mapY(p.y)}" r="2" fill="#0070f2"/>`;
				});

				// Etiquetas eje Y
				yTicks.forEach(t => {
					svg += `<text x="${padding.left - 8}" y="${mapY(t.y) + 4}" text-anchor="end" font-size="10" fill="#666">${t.label}</text>`;
				});

				// Etiquetas eje X (primera y última fecha)
				svg += `<text x="${padding.left}" y="${height - 5}" text-anchor="middle" font-size="10" fill="#666">${volumeHistory.leftBottomLabel}</text>`;
				svg += `<text x="${padding.left + chartWidth}" y="${height - 5}" text-anchor="middle" font-size="10" fill="#666">${volumeHistory.rightBottomLabel}</text>`;

				// Título
				svg += `<text x="${padding.left}" y="${padding.top - 6}" font-size="11" font-weight="bold" fill="#333">${volumeHistory.leftTopLabel}</text>`;

				svg += `</svg>`;
				return svg;
			},

			_renderChart(oChartContainer, volumeHistory) {
				oChartContainer.destroyItems();
				console.log("Creando SVG chart con puntos:", volumeHistory.points);
				const svg = this._buildLineChartSVG(volumeHistory);
				const oHTML = new HTML({
					content: svg
				});
				oChartContainer.addItem(oHTML);
			},

			async _getVolumeHistory(AlmacenID) {
				try {
					var oModel = this.base.getExtensionAPI().getModel();
					var oContextBinding = oModel.bindContext("/AlmacenVolumeHistory(AlmacenID=" + AlmacenID + ")");
					var data = await oContextBinding.requestObject();
					var items = data?.items || [];

					const points = items.map((item, index) => ({
						x: index,
						label: item.fecha,
						y: Math.round(Number(item.capacidad) || 0)
					}));

					const formatDate = (iso) => {
						if (!iso) return "";
						var d = new Date(iso);
						return (d.getDate()).toString().padStart(2, '0') + "/" + (d.getMonth() + 1).toString().padStart(2, '0');
					};

					return {
						points: points,
						leftTopLabel: "Capacidad actual (L)",
						leftBottomLabel: items.length ? formatDate(items[0].fecha) : "",
						rightBottomLabel: items.length ? formatDate(items[items.length - 1].fecha) : ""
					};
				} catch (error) {
					console.error('Error fetching volume history:', error);
					return { points: [], leftTopLabel: "", leftBottomLabel: "", rightBottomLabel: "" };
				}
			},
			async _getProviderData(AlmacenID) {
				try {
					/** @type {sap.ui.model.odata.v4.ODataModel} */
					var oModel = this.base.getExtensionAPI().getModel();
					var oContextBinding = oModel.bindContext("/QuantityByAlmacen(AlmacenID=" + AlmacenID + ")");
					var data = await oContextBinding.requestObject();
					return data;
				} catch (error) {
					console.error('Error fetching provider data:', error);
					return { PerTanques: null };
				}
			}
		});
	});
