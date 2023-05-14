*"* use this source file for your ABAP unit test classes

CLASS constant_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS:
      standard FOR TESTING.
  PRIVATE SECTION.
    DATA:
      constant TYPE REF TO data,
      value    TYPE REF TO data,
      result   TYPE abap_bool.
    METHODS:
      given_the_constant IMPORTING constant TYPE data,
      given_the_value IMPORTING value TYPE data,
      when_is_val_in_const_is_called,
      then_result_should_be IMPORTING result TYPE abap_bool.
ENDCLASS.

CLASS constant_test IMPLEMENTATION.
  METHOD standard.
    CONSTANTS: BEGIN OF message_types,
                 success   TYPE syst_msgty VALUE 'S',
                 info      TYPE syst_msgty VALUE 'I',
                 warning   TYPE syst_msgty VALUE 'W',
                 error     TYPE syst_msgty VALUE 'E',
                 abort     TYPE syst_msgty VALUE 'A',
                 shortdump TYPE syst_msgty VALUE 'X',
               END OF message_types.

    given_the_constant( message_types ).

    given_the_value( message_types-success ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( message_types-info ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( message_types-warning ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( message_types-error ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( message_types-abort ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( message_types-shortdump ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_true ).

    given_the_value( ' ' ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_false ).

    given_the_value( 'Z' ).
    when_is_val_in_const_is_called( ).
    then_result_should_be( abap_false ).
  ENDMETHOD.

  METHOD given_the_constant.
    me->constant = REF #( constant ).
  ENDMETHOD.

  METHOD given_the_value.
    me->value = REF #( value ).
  ENDMETHOD.

  METHOD when_is_val_in_const_is_called.
    ASSIGN value->* TO FIELD-SYMBOL(<value>).
    ASSERT sy-subrc = 0.
    ASSIGN constant->* TO FIELD-SYMBOL(<constant>).
    ASSERT sy-subrc = 0.

    result = zfloppy_enum_validator=>is_value_in_constant(
        value    = <value>
        constant = <constant> ).
  ENDMETHOD.

  METHOD then_result_should_be.
    cl_abap_unit_assert=>assert_equals(
        act = me->result
        exp = result ).
  ENDMETHOD.
ENDCLASS.
