CLASS zfloppy_frontend_fs_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zfloppy_frontend_file_system.

    METHODS constructor IMPORTING frontend_services TYPE REF TO zfloppy_frontend_services.

  PRIVATE SECTION.
    TYPES x1024 TYPE x LENGTH 1024.

    DATA frontend_services TYPE REF TO zfloppy_frontend_services.
ENDCLASS.


CLASS zfloppy_frontend_fs_impl IMPLEMENTATION.
  METHOD constructor.
    me->frontend_services = frontend_services.
  ENDMETHOD.

  METHOD zfloppy_file_system~create_directory.
    TRY.
        DATA(return_code) = frontend_services->directory_create( path ).

        IF return_code IS NOT INITIAL.
          RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception.
        ENDIF.

      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~delete_directory.
    TRY.
        DATA(return_code) = frontend_services->directory_delete( path ).

        IF return_code IS NOT INITIAL.
          RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception.
        ENDIF.

      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~file_exists.
    TRY.
        result = frontend_services->file_exists( path ).
      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_default_codepage.
    CALL FUNCTION 'SCP_GET_CODEPAGE_NUMBER'
      EXPORTING database_also = abap_false
      IMPORTING gui_codepage  = result.

    " There also is cl_gui_frontend_services=>get_saplogon_encoding and there used to be a GUI setting just for file
    " transfer encodings. cl_gui_frontend_services=>file_open_dialog optionally can return a codepage but that forces
    " an older file open dialog.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_directory_contents.
    TRY.
        frontend_services->directory_list_files( EXPORTING directory  = path
                                                 IMPORTING file_table = result ).
      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_bin.
    DATA data_tab TYPE STANDARD TABLE OF x1024.

    TRY.
        frontend_services->gui_upload( EXPORTING filename   = path
                                                 filetype   = zfloppy_frontend_services=>file_types-binary
                                       IMPORTING filelength = DATA(length)
                                                 data_tab   = data_tab ).

        result = zfloppy_conversion_utils=>binary_tab_to_xstring( binary_tab = data_tab
                                                                  length     = length ).

      CATCH zfloppy_frontend_services_exc
            zfloppy_conversion_exception INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_text.
    DATA data_tab TYPE STANDARD TABLE OF x1024.

    TRY.
        " Also do binary mode when reading text as otherwise conversions take place and data might get lost when the
        " target table line length is too small.

        frontend_services->gui_upload( EXPORTING filename   = path
                                                 filetype   = zfloppy_frontend_services=>file_types-binary
                                       IMPORTING filelength = DATA(length)
                                                 data_tab   = data_tab ).

        DATA(xstring) = zfloppy_conversion_utils=>binary_tab_to_xstring( binary_tab = data_tab
                                                                         length     = length ).
        result = zfloppy_conversion_utils=>xstring_to_string( xstring  = xstring
                                                              codepage = codepage ).

      CATCH zfloppy_frontend_services_exc
            zfloppy_conversion_exception INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~write_file_bin.
    DATA data_tab TYPE STANDARD TABLE OF x1024.

    TRY.
        zfloppy_conversion_utils=>xstring_to_binary_tab( EXPORTING xstring    = content
                                                         IMPORTING binary_tab = data_tab ).

        frontend_services->gui_download( bin_filesize = xstrlen( content )
                                         filename     = path
                                         filetype     = zfloppy_frontend_services=>file_types-binary
                                         data_tab     = data_tab ).

      CATCH zfloppy_frontend_services_exc
            zfloppy_conversion_exception INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_separator.
    TRY.
        result = frontend_services->get_separator( ).
      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_description.
    result = 'SAP GUI Frontend'.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_connection_info.
    TRY.
        frontend_services->get_computer_name( CHANGING computer_name = result-host ).
        frontend_services->get_user_name( CHANGING user_name = result-user ).
        result-protocol = 'DIAG/RFC'.

        frontend_services->flush( ).
      CATCH zfloppy_frontend_services_exc INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_frontend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_supported_methods.
    result = VALUE #( ( zfloppy_fs_method_enum=>create_directory )
                      ( zfloppy_fs_method_enum=>delete_directory )
                      ( zfloppy_fs_method_enum=>file_exists )
                      ( zfloppy_fs_method_enum=>get_default_codepage )
                      ( zfloppy_fs_method_enum=>get_directory_contents )
                      ( zfloppy_fs_method_enum=>read_file_bin )
                      ( zfloppy_fs_method_enum=>read_file_text )
                      ( zfloppy_fs_method_enum=>write_file_bin )
                      ( zfloppy_fs_method_enum=>get_separator )
                      ( zfloppy_fs_method_enum=>get_connection_info ) ).
  ENDMETHOD.
ENDCLASS.
