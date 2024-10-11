class lhc_Travel definition inheriting from cl_abap_behavior_handler.
  private section.

    constants mc_customer_reported_area type string value 'VALIDATE_CUSTOMER'.

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

    types:
      ty_create_travel   type table for create zw_r_travel_i\\Travel,
      ty_update_travel   type table for update zw_r_travel_i\\Travel,

      ty_failed_travel   type table for failed early zw_r_travel_i\\Travel,
      ty_reported_travel type table for reported early zw_r_travel_i\\Travel.

    methods new_method importing entities_create_travel type ty_create_travel
                                 entities_update_travel type ty_update_travel
                       changing  failed                 type ty_failed_travel
                                 reported               type ty_reported_travel.

endclass.

class lhc_Travel implementation.

  method get_instance_features.

    read entities of zw_r_travel_i in local mode
         entity Travel
         fields ( OverallStatus )
         with corresponding #( keys )
         result data(travels)
         failed failed.

    result = value #( for travel in travels
                        ( %tky = travel-%tky
                          %field-BookingFee = cond #( when travel-OverallStatus = travel_status-accepted
                                                      then if_abap_behv=>fc-f-read_only
                                                      else if_abap_behv=>fc-f-unrestricted )
                          %action-acceptTravel = cond #( when travel-OverallStatus = travel_status-accepted
                                                      then if_abap_behv=>fc-o-disabled
                                                      else if_abap_behv=>fc-o-enabled )
                          %action-rejectTravel = cond #( when travel-OverallStatus = travel_status-rejected
                                                      then if_abap_behv=>fc-o-disabled
                                                      else if_abap_behv=>fc-o-enabled )
                          %action-deductDiscount = cond #( when travel-OverallStatus = travel_status-accepted
                                                      then if_abap_behv=>fc-o-disabled
                                                      else if_abap_behv=>fc-o-enabled )
                           %assoc-_Booking = cond #( when travel-OverallStatus = travel_status-rejected
                                                      then if_abap_behv=>fc-o-disabled
                                                      else if_abap_behv=>fc-o-enabled ) ) ).

  endmethod.

  method get_instance_authorizations.

    check 1 = 2.

    data: update_requested type abap_bool,
          delete_requested type abap_bool,
          update_granted   type abap_bool,
          delete_granted   type abap_bool.

    read entities of zw_r_travel_i in local mode
         entity Travel
         fields ( AgencyID )
         with corresponding #( keys )
         result data(travels)
         failed failed.

    check travels is not initial.

    "Decide business check
    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).

    update_requested = cond #( when requested_authorizations-%update      = if_abap_behv=>mk-on
                                 or requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                               then abap_true else abap_false ).

    delete_requested = cond #( when requested_authorizations-%delete      = if_abap_behv=>mk-on
                               then abap_true else abap_false ).

    loop at travels into data(travel).

      if travel-AgencyID is not initial.

        "Business check
        if lv_technical_user eq 'CB9980002255' and travel-AgencyID ne '70025'. "WHAT EVER.
          update_granted = abap_true.
          delete_granted = abap_true.
        else.
          update_granted = delete_granted = abap_false.
        endif.


        "check for update
        if update_requested = abap_true.

          if update_granted = abap_false.
            append value #( %tky = travel-%tky
                            %msg = new /dmo/cm_flight_messages(
                                                     textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                     agency_id = travel-AgencyID
                                                     severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) to reported-travel.
          endif.
        endif.

        "check for delete
        if delete_requested = abap_true.

          if delete_granted = abap_false.
            append value #( %tky = travel-%tky
                            %msg = new /dmo/cm_flight_messages(
                                     textid   = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                     agency_id = travel-AgencyID
                                     severity = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) to reported-travel.
          endif.
        endif.

        " operations on draft instances and on active instances
        " new created instances
      else.
        update_granted = delete_granted = abap_true. "REPLACE ME WITH BUSINESS CHECK
        if update_granted = abap_false.
          append value #( %tky = travel-%tky
                          %msg = new /dmo/cm_flight_messages(
                                   textid   = /dmo/cm_flight_messages=>not_authorized
                                   severity = if_abap_behv_message=>severity-error )
                          %element-AgencyID = if_abap_behv=>mk-on
                        ) to reported-travel.
        endif.
      endif.

      append value #( let upd_auth = cond #( when update_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                          del_auth = cond #( when delete_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                      in
                       %tky = travel-%tky
                       %update                = upd_auth
                       %action-Edit           = upd_auth

                       %delete                = del_auth
                    ) to result.
    endloop.

  endmethod.

  method get_global_authorizations.


    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).

    "Simulate NOT Authorized
    lv_technical_user = 'DIFFERENT_USER'.

    if requested_authorizations-%create eq if_abap_behv=>mk-on.

      if lv_technical_user eq 'CB9980002255'.
        result-%create = if_abap_behv=>auth-allowed.
      else.
        result-%create = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_authorized
                                      severity = if_abap_behv_message=>severity-error )
                         %global = if_abap_behv=>mk-on ) to reported-travel.
      endif.

    endif.

    if requested_authorizations-%update      eq if_abap_behv=>mk-on or
       requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.

      if lv_technical_user eq 'CB9980002255'.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      else.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_authorized
                                      severity = if_abap_behv_message=>severity-error )
                         %global = if_abap_behv=>mk-on ) to reported-travel.
      endif.


    endif.

    if requested_authorizations-%delete eq if_abap_behv=>mk-on.

      if lv_technical_user eq 'CB9980002255'.
        result-%delete = if_abap_behv=>auth-allowed.
      else.
        result-%delete = if_abap_behv=>auth-unauthorized.

        append value #( %msg = new /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_authorized
                                      severity = if_abap_behv_message=>severity-error )
                         %global = if_abap_behv=>mk-on ) to reported-travel.
      endif.

    endif.

  endmethod.

  method precheck_create.
  endmethod.

  method precheck_update.
  endmethod.

  method deductDiscount.

    data travels_for_update type table for update zw_r_travel_i.

    data(keys_with_valid_discount) = keys.

    loop at keys_with_valid_discount assigning field-symbol(<key_discount>)
         where %param-discount_percent is initial
            or %param-discount_percent > 100
            or %param-discount_percent <= 0.

      append value #( %tky = <key_discount>-%tky ) to failed-travel.

      append value #(  %tky = <key_discount>-%tky
                       %msg = new /dmo/cm_flight_messages(
                                    textid    = /dmo/cm_flight_messages=>discount_invalid
                                    severity  = if_abap_behv_message=>severity-error )
                       %element-totalprice    = if_abap_behv=>mk-on
                       %action-deductDiscount = if_abap_behv=>mk-on ) to reported-travel.
      delete keys_with_valid_discount.
    endloop.

    check keys_with_valid_discount is not initial.

    read entities of zw_r_travel_i in local mode
         entity Travel
         fields ( BookingFee )
         with corresponding #( keys_with_valid_discount )
         result data(travels).

    data percentage type decfloat16.


    loop at travels assigning field-symbol(<travel>).

      data(discount_percent) = keys_with_valid_discount[ key id %tky = <travel>-%tky ]-%param-discount_percent.
      percentage = discount_percent / 100.
      data(reduced_fee) = <travel>-BookingFee * ( 1 - percentage ).

      append value #( %tky       = <travel>-%tky
                      BookingFee = reduced_fee ) to travels_for_update.

    endloop.

    modify entities of zw_r_travel_i in local mode
           entity Travel
           update fields ( BookingFee )
           with travels_for_update.

    read entities of zw_r_travel_i in local mode
         entity Travel
         all fields
         with corresponding #( travels )
         result data(travels_with_discount).

    result  = value #( for travel in travels_with_discount ( %tky   = travel-%tky
                                                             %param = travel ) ).

  endmethod.

  method reCalcTotalPrice.

    types: begin of ty_amount_per_currencycode,
             amount        type /dmo/total_price,
             currency_code type /dmo/currency_code,
           end of ty_amount_per_currencycode.

    data: amount_per_currencycode type standard table of ty_amount_per_currencycode.

    read entities of zw_r_travel_i in local mode
         entity Travel
            fields ( BookingFee CurrencyCode )
            with corresponding #( keys )
         result data(travels).

    delete travels where CurrencyCode is initial.

    loop at travels assigning field-symbol(<travel>).
      " adding the booking fee.
      amount_per_currencycode = value #( ( amount        = <travel>-BookingFee
                                           currency_code = <travel>-CurrencyCode ) ).

      " Read all associated bookings
      read entities of zw_r_travel_i in local mode
           entity Travel by \_Booking
           fields ( FlightPrice CurrencyCode )
           with value #( ( %tky = <travel>-%tky ) )
          result data(bookings).

      loop at bookings into data(booking) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) into amount_per_currencycode.
      endloop.

      " all associated booking supplements
      read entities of zw_r_travel_i in local mode
           entity Booking by \_BookingSupplement
           fields ( BookSupplPrice CurrencyCode )
           with value #( for rba_booking in bookings ( %tky = rba_booking-%tky ) )
           result data(bookingsupplements).

      loop at bookingsupplements into data(bookingsupplement) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = bookingsupplement-BookSupplPrice
                                                  currency_code = bookingsupplement-CurrencyCode ) into amount_per_currencycode.
      endloop.

      clear <travel>-TotalPrice.
      loop at amount_per_currencycode into data(single_amount_per_currencycode).
        "Currency Conversion
        if single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += single_amount_per_currencycode-amount.
        else.
          /dmo/cl_flight_amdp=>convert_currency(
             exporting
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             importing
               ev_amount                   = data(total_booking_price_per_curr)
            ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        endif.
      endloop.
    endloop.

    modify entities of zw_r_travel_i in local mode
      entity travel
        update fields ( TotalPrice )
        with corresponding #( travels ).

  endmethod.

  method rejectTravel.

* EML - Entity Manipulation Language
    modify entities of zw_r_travel_i in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky = key-%tky
                                           OverallStatus = travel_status-rejected ) ).

    read entities of zw_r_travel_i in local mode
         entity Travel
         all fields with
         corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
                                              %param = travel ) ).

  endmethod.

  method Resume.
  endmethod.

  method calculateTotalPrice.

    modify entities of zw_r_travel_i in local mode
         entity Travel
         execute reCalcTotalPrice
         from corresponding #( keys ).

  endmethod.

  method setStatusToOpen.

    read entities of zw_r_travel_i in local mode
       entity Travel
       fields ( OverallStatus )
       with corresponding #( keys )
       result data(travels).

    delete travels where OverallStatus is not initial.

    check travels is not initial.

    modify entities of zw_r_travel_i in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for travel in travels ( %tky          = travel-%tky
                                                 OverallStatus = travel_status-open ) ).

  endmethod.

  method setTravelNumber.

    read entities of zw_r_travel_i in local mode
         entity Travel
         fields ( TravelID )
         with corresponding #( keys )
         result data(travels).

    delete travels where TravelID is not initial.

    check travels is not initial.

    select single from zwtravel_i
           fields max( travel_id )
           into @data(lv_max_travel_id).

    modify entities of zw_r_travel_i in local mode
           entity Travel
           update fields ( TravelID )
           with value #( for travel in travels index into i
                              ( %tky     = travel-%tky
                                TravelID = lv_max_travel_id + i ) ).

  endmethod.

  method validateAgency.
  endmethod.

  method validateBookingFee.
  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validateCustomer.

    read entities of zw_r_travel_i in local mode
         entity Travel
         fields ( CustomerID )
         with corresponding #( keys )
         result data(travels).

    data customers type sorted table of /dmo/customer with unique key client customer_id.

    customers = corresponding #( travels discarding duplicates mapping customer_id = CustomerID except * ).

    delete customers where customer_id is initial.

    if customers is not initial.

      select from /dmo/customer as ddbb
             inner join @customers as http_req on ddbb~customer_id = http_req~customer_id
             fields ddbb~customer_id
             into table @data(valid_customers).

    endif.

    loop at travels into data(travel).

      append value #( %tky        = travel-%tky
                      %state_area = mc_customer_reported_area ) to reported-travel.

      if travel-CustomerID is initial.
        append value #( %tky = travel-%tky ) to failed-travel.

        append value #(  %tky = travel-%tky
                         %state_area = mc_customer_reported_area
                         %msg = new /dmo/cm_flight_messages(
                                            textid    = /dmo/cm_flight_messages=>enter_customer_id
                                            severity  = if_abap_behv_message=>severity-error )
                         %element-CustomerID    = if_abap_behv=>mk-on ) to reported-travel.

      elseif travel-CustomerID is not initial and not line_exists( valid_customers[ customer_id = travel-CustomerID ] ).
        append value #( %tky = travel-%tky ) to failed-travel.

        append value #(  %tky = travel-%tky
                         %state_area = mc_customer_reported_area
                         %msg = new /dmo/cm_flight_messages(
                                            customer_id = travel-CustomerID
                                            textid    = /dmo/cm_flight_messages=>customer_unkown
                                            severity  = if_abap_behv_message=>severity-error )
                         %element-CustomerID    = if_abap_behv=>mk-on ) to reported-travel.


      endif.

    endloop.

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

  method new_method.

  endmethod.

endclass.
