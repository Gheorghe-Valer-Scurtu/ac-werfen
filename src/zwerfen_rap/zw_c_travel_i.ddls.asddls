@EndUserText.label: 'Travel - Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity zw_c_travel_i
  provider contract transactional_query
  as projection on zw_r_travel_i
{
  key TravelUUID,

      @Search.defaultSearchElement: true
      TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                     element: 'AgencyID' },
                                            useForValidation: true }]
      AgencyID,
      _Agency.Name              as AgencyName,


      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]

      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID' },
                                            useForValidation: true }]
      CustomerID,
      _Customer.LastName        as CustomerName,

      BeginDate,
      EndDate,

      BookingFee,
      TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                           useForValidation: true}]
      CurrencyCode,

      Description,

      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,

      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,


      /* Associations */
      _Agency,
      _Booking : redirected to composition child zw_c_booking_i,
      _Currency,
      _Customer,
      _OverallStatus
}
