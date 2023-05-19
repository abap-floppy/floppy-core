CLASS zfloppy_tdc_file_system DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zfloppy_file_system.

  PRIVATE SECTION.
    CONSTANTS tdc_name TYPE etobj_name VALUE 'ZFLOPPY_FILES'.

    DATA container TYPE REF TO cl_apl_ecatt_tdc_api.

    METHODS get_container RETURNING VALUE(result) TYPE REF TO cl_apl_ecatt_tdc_api
                          RAISING   zfloppy_file_system_exception.
ENDCLASS.


CLASS zfloppy_tdc_file_system IMPLEMENTATION.
  METHOD zfloppy_file_system~create_directory.
    RAISE EXCEPTION TYPE zfloppy_fs_unsupp_operation.
  ENDMETHOD.

  METHOD zfloppy_file_system~delete_directory.
    RAISE EXCEPTION TYPE zfloppy_fs_unsupp_operation.
  ENDMETHOD.

  METHOD zfloppy_file_system~file_exists.
    TRY.
        DATA(variants) = get_container( )->get_variant_list( ).
        result = xsdbool( line_exists( variants[ table_line = |/{ path }| ] ) ).
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_file_system_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_connection_info.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_default_codepage.
    result = zfloppy_codepage_helper=>get_system_codepage( ).
  ENDMETHOD.

  METHOD zfloppy_file_system~get_description.
    result = 'eCATT Test Data Container File System (INTERNAL TESTING)'.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_directory_contents.
    IF path <> '/'.
      RETURN.
    ENDIF.

    TRY.
        result = VALUE #( FOR v IN get_container( )->get_variant_list( )
                          ( filename = v ) ).
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_file_system_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_separator.
    result = '/'.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_bin.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_text.
    FIELD-SYMBOLS <csequence> TYPE csequence.

    DATA(mutable_path) = path.

    IF mutable_path IS NOT INITIAL AND mutable_path(1) = '/'.
      SHIFT mutable_path LEFT BY 1 PLACES.
      CONDENSE mutable_path.
    ENDIF.

    DATA(content_tab) = container->get_variant_content( CONV #( mutable_path ) ).
    DATA(ref) = content_tab[ parname = 'FILE_CONTENT' ]-value_ref.
    ASSIGN ref->* TO <csequence>.
    ASSERT sy-subrc = 0.
    result = <csequence>.
  ENDMETHOD.

  METHOD zfloppy_file_system~write_file_bin.
    RAISE EXCEPTION TYPE zfloppy_fs_unsupp_operation.
  ENDMETHOD.

  METHOD get_container.
    IF container IS NOT BOUND.
      TRY.
          container = cl_apl_ecatt_tdc_api=>get_instance( tdc_name ).
        CATCH cx_ecatt_tdc_access INTO DATA(exception).
          cl_message_helper=>set_msg_vars_for_any( exception ).
          RAISE EXCEPTION TYPE zfloppy_file_system_exception
                MESSAGE ID sy-msgid
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                EXPORTING
                  previous = exception.
      ENDTRY.
    ENDIF.

    result = container.
  ENDMETHOD.
ENDCLASS.
