class lhc_Travel definition inheriting from cl_abap_behavior_handler.
  private section.

    constants:
      begin of travel_status,
        open     type c length 1 value 'O', "Open
        accepted type c length 1 value 'A', "Accepted
        rejected type c length 1 value 'X', "Rejected
      end of travel_status.

    methods get_instance_features for instance features
      importing keys request requested_features for Travel result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Travel result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for Travel result result.

    methods precheck_create for precheck
      importing entities for create Travel.

    methods precheck_update for precheck
      importing entities for update Travel.


    methods deductDiscount for modify
      importing keys for action Travel~deductDiscount result result.

    methods reCalcTotalPrice for modify
      importing keys for action Travel~reCalcTotalPrice.

    methods acceptTravel for modify
      importing keys for action Travel~acceptTravel result result.

    methods rejectTravel for modify
      importing keys for action Travel~rejectTravel result result.

    methods Resume for modify
      importing keys for action Travel~Resume.

    methods calculateTotalPrice for determine on modify
      importing keys for Travel~calculateTotalPrice.

    methods setStatusToOpen for determine on modify
      importing keys for Travel~setStatusToOpen.

    methods setTravelNumber for determine on save
      importing keys for Travel~setTravelNumber.

    methods validateAgency for validate on save
      importing keys for Travel~validateAgency.

    methods validateBookingFee for validate on save
      importing keys for Travel~validateBookingFee.

    methods validateCurrencyCode for validate on save
      importing keys for Travel~validateCurrencyCode.

    methods validateCustomer for validate on save
      importing keys for Travel~validateCustomer.

    methods validateDates for validate on save
      importing keys for Travel~validateDates.
endclass.

class lhc_Travel implementation.

  method get_instance_features.
  endmethod.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method precheck_create.
  endmethod.

  method precheck_update.
  endmethod.

  method deductDiscount.
  endmethod.

  method reCalcTotalPrice.
  endmethod.

  method rejectTravel.
  endmethod.

  method Resume.
  endmethod.

  method calculateTotalPrice.
  endmethod.

  method setStatusToOpen.
  endmethod.

  method setTravelNumber.
  endmethod.

  method validateAgency.
  endmethod.

  method validateBookingFee.
  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validateCustomer.
  endmethod.

  method validateDates.
  endmethod.

  method acceptTravel.

* EML - Entity Manipulation Language
    modify entities of zw_r_travel_i in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky = key-%tky
                                           OverallStatus = travel_status-accepted ) ).

    read entities of zw_r_travel_i in local mode
         entity Travel
         all fields with
         corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
                                              %param = travel ) ).

  endmethod.

endclass.
