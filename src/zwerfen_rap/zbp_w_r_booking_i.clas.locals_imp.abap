class lhc_Booking definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Booking result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for Booking result result.

    methods calculateTotalPrice for determine on modify
      importing keys for Booking~calculateTotalPrice.

    methods setBookingDate for determine on save
      importing keys for Booking~setBookingDate.

    methods setBookingNumber for determine on save
      importing keys for Booking~setBookingNumber.

    methods validateConnection for validate on save
      importing keys for Booking~validateConnection.

    methods validateCurrencyCode for validate on save
      importing keys for Booking~validateCurrencyCode.

    methods validateCustomer for validate on save
      importing keys for Booking~validateCustomer.

    methods validateFlightPrice for validate on save
      importing keys for Booking~validateFlightPrice.

    methods validateStatus for validate on save
      importing keys for Booking~validateStatus.

endclass.

class lhc_Booking implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method calculateTotalPrice.

    read entities of zw_r_travel_i in local mode
         entity Booking by \_Travel
         fields ( TravelUUID  )
         with corresponding #(  keys  )
         result data(travels).

    modify entities of zw_r_travel_i in local mode
           entity Travel
           execute reCalcTotalPrice
           from corresponding  #( travels ).

  endmethod.

  method setBookingDate.
  endmethod.

  method setBookingNumber.

    data max_booking_id type /dmo/booking_id.

    data bookings_update type table for update zw_r_travel_i\\Booking.

    read entities of zw_r_travel_i in local mode
          entity Booking by \_Travel
          fields ( TravelUUID )
          with corresponding #( keys )
          result data(travels).

    loop at travels into data(travel).

      read entities of zw_r_travel_i in local mode
           entity Travel by \_Booking
           fields ( BookingID )
           with value #( ( %tky = travel-%tky ) )
           result data(bookings).

      max_booking_id = '0000'.

      loop at bookings into data(booking).
        if booking-BookingID > max_booking_id.
          max_booking_id = booking-BookingID.
        endif.
      endloop.

      loop at bookings into booking where BookingID is initial.

        max_booking_id += 1.
        append value #( %tky       = booking-%tky
                        BookingID = max_booking_id ) to bookings_update.
      endloop.
    endloop.

    modify entities of zw_r_travel_i in local mode
           entity Booking
           update fields ( BookingID )
           with bookings_update.

  endmethod.

  method validateConnection.
  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validateCustomer.
  endmethod.

  method validateFlightPrice.
  endmethod.

  method validateStatus.
  endmethod.

endclass.
