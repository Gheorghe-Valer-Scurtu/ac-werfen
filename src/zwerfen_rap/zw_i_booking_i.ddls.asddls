@EndUserText.label: 'Booking - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity zw_i_booking_i
  as projection on zw_r_booking_i
{
  key BookingUUID,
      TravelUUID,
      BookingID,
      BookingDate,
      CustomerID,
      AirlineID,
      ConnectionID,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child zw_i_bksuppl_i,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent zw_i_travel_i
}
