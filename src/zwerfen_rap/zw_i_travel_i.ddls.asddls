@EndUserText.label: 'Travel - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity zw_i_travel_i
  provider contract transactional_interface
  as projection on zw_r_travel_i
{
  key TravelUUID,
      TravelID,
      AgencyID,
      CustomerID,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
 
      /* Associations */
      _Agency,
      _Booking : redirected to composition child zw_i_booking_i,
      _Currency,
      _Customer,
      _OverallStatus
}
