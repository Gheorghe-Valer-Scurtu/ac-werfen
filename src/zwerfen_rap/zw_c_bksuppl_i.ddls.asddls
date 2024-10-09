@EndUserText.label: 'Booking Supplements - Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity zw_c_bksuppl_i
  as projection on zw_r_bksuppl_i
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: [ 'SupplementDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name : '/DMO/I_Supplement_StdVH',
                                                     element: 'SupplementID' },
                                           additionalBinding: [{ localElement: 'BookSupplPrice',
                                                                 element: 'Price',
                                                                 usage: #RESULT },
                                                               { localElement: 'CurrencyCode',
                                                                 element: 'CurrencyCode',
                                                                 usage: #RESULT }],
                                           useForValidation: true }]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                           useForValidation: true}]
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent zw_c_booking_i,
      _Product,
      _SupplementText,
      _Travel  : redirected to zw_c_travel_i
}
