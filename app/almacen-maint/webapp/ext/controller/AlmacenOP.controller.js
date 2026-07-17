// @ts-nocheck
sap.ui.define([
	'sap/ui/core/mvc/ControllerExtension',
	'sap/ui/model/json/JSONModel',
	'sap/ui/core/HTML'
],
	function (ControllerExtension, JSONModel, HTML) {
		'use strict';

		return ControllerExtension.extend('com.tandem.almacenmaint.ext.controller.AlmacenOP', {
			override: {
				onInit: function () {
					var oModel = this.base.getExtensionAPI();
				},

				onPageReady: async function () {
					try {
						let oView = this.getView();
						let oBindingContext = oView.getBindingContext();
						let ID = oBindingContext.getProperty("ID");
						const [providerData, volumeHistory] = await Promise.all([
							this._getProviderData(ID),
							this._getVolumeHistory(ID)
						]);
						this.getView().setModel(new JSONModel(providerData), "providerData");
						this.getView().setModel(new JSONModel(volumeHistory), "volumeHistory");
						console.log({providerData, volumeHistory});

						this._findAndRenderChart(oView, volumeHistory);
					} catch (error) {
						console.error("Error en onPageReady:", error);
						this.getView().setModel(new JSONModel({ PerTanques: null }), "providerData");
						this.getView().setModel(new JSONModel({ points: null, leftBottomLabel: "", rightBottomLabel: "" }), "volumeHistory");
					}
				}
			},

			_findAndRenderChart(oView, volumeHistory) {
				const tryRender = () => {
					let oChartContainer = oView.byId("volumeChartContainer");
					if (!oChartContainer) {
						const fullId = oView.getId() + "--fe::CustomSubSection::Proveedor--volumeChartContainer";
						oChartContainer = sap.ui.getCore().byId(fullId);
					}
					if (!oChartContainer && sap.ui.getCore().mElements) {
						const foundId = Object.keys(sap.ui.getCore().mElements).find(id => id.endsWith("--volumeChartContainer"));
						if (foundId) {
							oChartContainer = sap.ui.getCore().byId(foundId);
						}
					}
					if (oChartContainer && volumeHistory && volumeHistory.points && volumeHistory.points.length) {
						this._renderChart(oChartContainer, volumeHistory);
						return true;
					}
					return false;
				};

				if (tryRender()) return;

				let retries = 0;
				const interval = setInterval(() => {
					retries++;
					console.log("Buscando volumeChartContainer, intento", retries);
					if (tryRender()) {
						clearInterval(interval);
					} else if (retries > 40) {
						clearInterval(interval);
						console.error("No se encontró volumeChartContainer después de 40 intentos");
					}
				}, 500);
			},

			_buildLineChartSVG(volumeHistory) {
				const points = volumeHistory.points;
				const width = 600;
				const height = 150;
				const padding = { top: 26, right: 24, bottom: 32, left: 68 };
				const chartWidth = width - padding.left - padding.right;
				const chartHeight = height - padding.top - padding.bottom;

				// Calcular rango del eje Y de 0 a la capacidad total del almacén
				const minY = 0;
				const maxY = Math.max(volumeHistory.capacidadTotalAlmacen || 0, ...points.map(p => p.y), 1);
				const yRange = maxY - minY || 1;
				const xRange = points.length - 1 || 1;

				const mapX = (i) => padding.left + (i / xRange) * chartWidth;
				const mapY = (y) => padding.top + chartHeight - ((y - minY) / yRange) * chartHeight;

				const polylinePoints = points.map((p, i) => `${mapX(i)},${mapY(p.y)}`).join(" ");
				const formatNumber = (n) => n.toLocaleString();

				const yTicks = [
					{ y: minY, label: formatNumber(Math.round(minY)) },
					{ y: maxY, label: formatNumber(Math.round(maxY)) }
				];

				let svg = `<svg width="100%" height="150px" viewBox="0 0 ${width} ${height}" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">`;
				svg += `<rect width="${width}" height="${height}" fill="transparent"/>`;

				// Líneas de guía horizontales
				for (let i = 0; i <= 4; i++) {
					const y = padding.top + (chartHeight * i) / 4;
					svg += `<line x1="${padding.left}" y1="${y}" x2="${padding.left + chartWidth}" y2="${y}" stroke="#e6e6e6" stroke-width="1" stroke-dasharray="2,2"/>`;
				}

				// Ejes
				svg += `<line x1="${padding.left}" y1="${padding.top}" x2="${padding.left}" y2="${padding.top + chartHeight}" stroke="#999" stroke-width="1"/>`;
				svg += `<line x1="${padding.left}" y1="${padding.top + chartHeight}" x2="${padding.left + chartWidth}" y2="${padding.top + chartHeight}" stroke="#999" stroke-width="1"/>`;

				// Área bajo la línea
				const areaPoints = polylinePoints + ` ${mapX(points.length - 1)},${padding.top + chartHeight} ${mapX(0)},${padding.top + chartHeight}`;
				svg += `<defs><linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#0070f2" stop-opacity="0.25"/><stop offset="100%" stop-color="#0070f2" stop-opacity="0.05"/></linearGradient></defs>`;
				svg += `<polygon points="${areaPoints}" fill="url(#areaGradient)"/>`;

				// Línea de datos
				svg += `<polyline fill="none" stroke="#0070f2" stroke-width="2.5" points="${polylinePoints}" stroke-linejoin="round" stroke-linecap="round"/>`;

				// Puntos con tooltip
				points.forEach((p, i) => {
					const cx = mapX(i);
					const cy = mapY(p.y);
					const fechaLabel = p.label || "";
					svg += `<circle cx="${cx}" cy="${cy}" r="3.5" fill="#0070f2" stroke="#fff" stroke-width="1.5" style="cursor:pointer">`;
					svg += `<title>Fecha: ${fechaLabel}\nVolumen total: ${formatNumber(p.y)} L</title>`;
					svg += `</circle>`;
				});

				// Etiquetas eje Y
				yTicks.forEach(t => {
					svg += `<text x="${padding.left - 8}" y="${mapY(t.y) + 4}" text-anchor="end" font-size="10" fill="#555">${t.label}</text>`;
				});

				// Etiquetas eje X
				svg += `<text x="${padding.left}" y="${height - 5}" text-anchor="middle" font-size="10" fill="#555">${volumeHistory.leftBottomLabel}</text>`;
				svg += `<text x="${padding.left + chartWidth}" y="${height - 5}" text-anchor="middle" font-size="10" fill="#555">${volumeHistory.rightBottomLabel}</text>`;

				// Título
				svg += `<text x="${padding.left}" y="${padding.top - 8}" font-size="12" font-weight="bold" fill="#333">${volumeHistory.leftTopLabel}</text>`;

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
						capacidadTotalAlmacen: Math.round(Number(data?.capacidadTotalAlmacen) || 0),
						leftTopLabel: "Volumen total en tanques (L)",
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
