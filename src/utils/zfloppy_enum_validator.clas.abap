CLASS zfloppy_enum_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS is_value_in_constant IMPORTING !value        TYPE data
                                                 constant      TYPE data
                                       RETURNING VALUE(result) TYPE abap_bool
                                       RAISING   zfloppy_illegal_argument.
ENDCLASS.


CLASS zfloppy_enum_validator IMPLEMENTATION.
  METHOD is_value_in_constant.
    CONSTANTS type_flat_structure TYPE c LENGTH 1 VALUE 'u'.

    ##TODO. " Remove

    result = abap_false.

    DESCRIBE FIELD constant TYPE DATA(constant_type).
    IF constant_type <> type_flat_structure.
      RAISE EXCEPTION TYPE zfloppy_illegal_argument.
    ENDIF.

    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE constant TO FIELD-SYMBOL(<constant_value>).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      IF value = <constant_value>.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
