class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for BookingSupplement result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for BookingSupplement result result.

    methods calculateTotalPrice for determine on modify
      importing keys for BookingSupplement~calculateTotalPrice.

    methods setBookSupplNumber for determine on save
      importing keys for BookingSupplement~setBookSupplNumber.

    methods validateCurrencyCode for validate on save
      importing keys for BookingSupplement~validateCurrencyCode.

    methods validatePrice for validate on save
      importing keys for BookingSupplement~validatePrice.

    methods validateSupplement for validate on save
      importing keys for BookingSupplement~validateSupplement.

endclass.

class lhc_BookingSupplement implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method calculateTotalPrice.

    read entities of zw_r_travel_i in local mode
         entity BookingSupplement by \_Travel
         fields ( TravelUUID  )
         with corresponding #(  keys  )
         result data(travels).

    modify entities of zw_r_travel_i in local mode
           entity Travel
           execute reCalcTotalPrice
           from corresponding  #( travels ).

  endmethod.

  method setBookSupplNumber.

    data max_bookingsupplementid type /dmo/booking_supplement_id.
    data bookingsupplements_update type table for update zw_r_travel_i\\BookingSupplement.

    read entities of zw_r_travel_i in local mode
      entity BookingSupplement by \_Booking
        fields (  BookingUUID  )
        with corresponding #( keys )
      result data(bookings).

    loop at bookings into data(ls_booking).
      read entities of zw_r_travel_i in local mode
        entity Booking by \_BookingSupplement
          fields ( BookingSupplementID )
          with value #( ( %tky = ls_booking-%tky ) )
        result data(bookingsupplements).

      max_bookingsupplementid = '00'.
      loop at bookingsupplements into data(bookingsupplement).
        if bookingsupplement-BookingSupplementID > max_bookingsupplementid.
          max_bookingsupplementid = bookingsupplement-BookingSupplementID.
        endif.
      endloop.

      loop at bookingsupplements into bookingsupplement where BookingSupplementID is initial.
        max_bookingsupplementid += 1.
        append value #( %tky                = bookingsupplement-%tky
                        bookingsupplementid = max_bookingsupplementid
                      ) to bookingsupplements_update.

      endloop.
    endloop.

    modify entities of zw_r_travel_i in local mode
      entity BookingSupplement
        update fields ( BookingSupplementID ) with bookingsupplements_update.

  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validatePrice.
  endmethod.

  method validateSupplement.
  endmethod.

endclass.
