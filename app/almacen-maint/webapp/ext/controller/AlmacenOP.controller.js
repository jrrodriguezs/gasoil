// @ts-nocheck
sap.ui.define(['sap/ui/core/mvc/ControllerExtension', "sap/ui/model/json/JSONModel"],
	function (ControllerExtension, JSONModel) {
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
					/** @type {sap.ui.model.odata.v4.ODataModel} */
					let oView = this.getView();
					// Get the binding context of the view
					let oBindingContext = oView.getBindingContext();
					let ID = oBindingContext.getProperty("ID");
					const {PerAlmacen, PerTanques} = await this._getProviderData(ID);
					const oJSONModel = new JSONModel({PerAlmacen, PerTanques});
					console.log(oJSONModel.getData());
					
					this.getView().setModel(oJSONModel, "providerData");
				}
			},

			async _getProviderData(AlmacenID) {
				try {
					const response = await fetch(`/odata/v4/config/QuantityByAlmacen(AlmacenID=${AlmacenID})`, {
						method: 'GET',
						headers: {
							'Content-Type': 'application/json'
						}
					});
					const data = await response.json();
					return data;
				} catch (error) {
					console.error('Error fetching provider data:', error);
					throw error;
				}
			}
		});
	});
