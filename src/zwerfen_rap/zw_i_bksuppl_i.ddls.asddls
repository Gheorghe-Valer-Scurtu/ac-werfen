@EndUserText.label: 'Booking Supplements - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity zw_i_bksuppl_i
  as projection on zw_r_bksuppl_i
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,
      CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent zw_i_booking_i,
      _Product,
      _SupplementText,
      _Travel  : redirected to zw_i_travel_i
}
