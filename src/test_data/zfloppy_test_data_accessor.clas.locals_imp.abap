*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS tdc_iterator_base DEFINITION FOR TESTING ABSTRACT.
  PUBLIC SECTION.
    INTERFACES zfloppy_test_data_iterator.

    METHODS constructor IMPORTING container TYPE REF TO cl_apl_ecatt_tdc_api
                                  line_type TYPE REF TO if_abap_data_type_handle
                        RAISING   cx_ecatt_tdc_access.

  PROTECTED SECTION.
    METHODS map_variant_content_to_result IMPORTING variant         TYPE etvar_id
                                                    variant_content TYPE etpar_ref_tabtype
                                          CHANGING  !result         TYPE REF TO data.

  PRIVATE SECTION.
    DATA container    TYPE REF TO cl_apl_ecatt_tdc_api.
    DATA line_type    TYPE REF TO if_abap_data_type_handle.
    DATA variant_list TYPE etvar_name_tabtype.
    DATA current      TYPE i.
ENDCLASS.


CLASS tdc_iterator_base IMPLEMENTATION.
  METHOD constructor.
    me->container = container.
    me->line_type = line_type.
    variant_list = container->get_variant_list( ).
    DELETE variant_list WHERE table_line = 'ECATTDEFAULT'.
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~get_next.
    IF NOT zfloppy_test_data_iterator~has_next( ).
      RAISE EXCEPTION TYPE zfloppy_illegal_state.
    ENDIF.

    TRY.
        current = current + 1.
        DATA(variant) = variant_list[ current ].
        DATA(variant_content) = container->get_variant_content( variant ).

        DATA(type) = zfloppy_test_data_iterator~get_type( ).
        CREATE DATA result TYPE HANDLE type.

        map_variant_content_to_result( EXPORTING variant         = variant
                                                 variant_content = variant_content
                                       CHANGING  result          = result ).

      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~has_next.
    result = xsdbool( line_exists( variant_list[ current + 1 ] ) ).
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~reset.
    current = 0.
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~get_position.
    result = current.
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~set_position.
    IF line_exists( variant_list[ position ] ).
      current = position.
    ELSE.
      RAISE EXCEPTION TYPE zfloppy_illegal_argument.
    ENDIF.
  ENDMETHOD.

  METHOD map_variant_content_to_result.
    FIELD-SYMBOLS <variant> TYPE etvar_id.

    ASSIGN result->* TO FIELD-SYMBOL(<result>).
    ASSERT sy-subrc = 0.

    LOOP AT variant_content REFERENCE INTO DATA(parameter).
      ASSIGN COMPONENT parameter->parname OF STRUCTURE <result> TO FIELD-SYMBOL(<component>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <component> ?= parameter->value_ref.
    ENDLOOP.

    ASSIGN COMPONENT 'VARIANT' OF STRUCTURE <result> TO <variant>.
    IF sy-subrc = 0.
      <variant> = variant.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_test_data_iterator~get_type.
    result = line_type.
  ENDMETHOD.
ENDCLASS.


CLASS test_file_iterator DEFINITION INHERITING FROM tdc_iterator_base FOR TESTING.
  PUBLIC SECTION.
    METHODS constructor IMPORTING container TYPE REF TO cl_apl_ecatt_tdc_api
                        RAISING   cx_ecatt_tdc_access.
ENDCLASS.


CLASS test_file_iterator IMPLEMENTATION.
  METHOD constructor.
    DATA dummy TYPE zfloppy_test_data_accessor=>test_file.

    super->constructor( container = container
                        line_type = CAST #( cl_abap_typedescr=>describe_by_data( dummy ) ) ).
  ENDMETHOD.
ENDCLASS.


CLASS test_path_iterator DEFINITION INHERITING FROM tdc_iterator_base FOR TESTING.
  PUBLIC SECTION.
    METHODS constructor IMPORTING container TYPE REF TO cl_apl_ecatt_tdc_api
                        RAISING   cx_ecatt_tdc_access.
ENDCLASS.


CLASS test_path_iterator IMPLEMENTATION.
  METHOD constructor.
    DATA dummy TYPE zfloppy_test_data_accessor=>test_path.

    super->constructor( container = container
                        line_type = CAST #( cl_abap_typedescr=>describe_by_data( dummy ) ) ).
  ENDMETHOD.
ENDCLASS.
