INTERFACE zfloppy_test_data_iterator PUBLIC.
  METHODS:
    has_next RETURNING VALUE(result) TYPE abap_bool,
    get_next RETURNING VALUE(result) TYPE REF TO data
             RAISING   zfloppy_illegal_state
                       zfloppy_test_data_exception,
    reset,
    set_position IMPORTING position TYPE i
                 RAISING   zfloppy_illegal_argument,
    get_position RETURNING VALUE(result) TYPE i,
    get_type RETURNING VALUE(result) TYPE REF TO if_abap_data_type_handle.
ENDINTERFACE.
