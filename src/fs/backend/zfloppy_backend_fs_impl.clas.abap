CLASS zfloppy_backend_fs_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zfloppy_backend_file_system.
    METHODS:
      constructor IMPORTING dataset_api TYPE REF TO zfloppy_dataset_api.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      dataset_api TYPE REF TO zfloppy_dataset_api.
ENDCLASS.



CLASS zfloppy_backend_fs_impl IMPLEMENTATION.
  METHOD constructor.
    me->dataset_api = dataset_api.
  ENDMETHOD.

  METHOD zfloppy_file_system~file_exists.
    TRY.
        dataset_api->open_dataset(
            dataset     = path
            access_type = zfloppy_dataset_api=>access_types-input
            mode        = zfloppy_dataset_api=>modes-binary ).

        result = abap_true.
        dataset_api->close_dataset( path ).

      CATCH zfloppy_dataset_api_exception INTO DATA(exception).
        DATA(check_failed) = abap_false.

        IF exception->return_code <> 0.
          " Assume 'No such file or directory'. The message returned is surely operating system and language
          " specific so it cannot be reasonably parsed. Other errors may also be reported using the exceptions below
          " so this should be fine.
          result = abap_false.
        ELSEIF exception->previous IS BOUND.
          CASE TYPE OF exception->previous.
            WHEN TYPE cx_sy_file_open.
              " Already open -> exists
              result = abap_true.
            WHEN TYPE cx_sy_codepage_converter_init.
              check_failed = abap_true.
            WHEN TYPE cx_sy_conversion_codepage.
              check_failed = abap_true.
            WHEN TYPE cx_sy_file_authority.
              check_failed = abap_true.
            WHEN TYPE cx_sy_pipes_not_supported.
              check_failed = abap_true.
            WHEN TYPE cx_sy_too_many_files.
              check_failed = abap_true.
            WHEN TYPE cx_sy_file_close.
              " The check worked but closing the file didn't? Better report the dangling file handle?
              cl_message_helper=>set_msg_vars_for_any( exception ).
              RAISE EXCEPTION TYPE zfloppy_backend_fs_exception
                MESSAGE ID sy-msgid
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                EXPORTING
                  previous = exception.
            WHEN OTHERS.
              check_failed = abap_true.
          ENDCASE.
        ELSE.
          check_failed = abap_true.
        ENDIF.

        IF check_failed = abap_true.
          " Couldn't check
          cl_message_helper=>set_msg_vars_for_any( exception ).
          RAISE EXCEPTION TYPE zfloppy_backend_fs_exception
            MESSAGE ID sy-msgid
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            EXPORTING
              previous = exception.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_bin.
    DATA(open) = abap_false.

    TRY.
        TRY.
            dataset_api->open_dataset(
                dataset     = path
                access_type = zfloppy_dataset_api=>access_types-input
                mode        = zfloppy_dataset_api=>modes-binary ).
            open = abap_true.

            dataset_api->read_dataset(
              EXPORTING
                dataset     = path
              IMPORTING
                data_object = result
                return_code = DATA(return_code) ).
            IF return_code <> 0.
              RAISE EXCEPTION TYPE zfloppy_backend_fs_exception.
            ENDIF.

            open = abap_false.
            dataset_api->close_dataset( path ).

          CATCH zfloppy_dataset_api_exception INTO DATA(exception).
            cl_message_helper=>set_msg_vars_for_any( exception ).
            RAISE EXCEPTION TYPE zfloppy_backend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
        ENDTRY.
      CLEANUP.
        IF open = abap_true.
          TRY.
              dataset_api->close_dataset( path ).
            CATCH zfloppy_dataset_api_exception ##NO_HANDLER.
          ENDTRY.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~read_file_text.
    DATA(open) = abap_false.

    TRY.
        TRY.
            dataset_api->open_dataset(
                dataset      = path
                access_type  = zfloppy_dataset_api=>access_types-input
                mode         = zfloppy_dataset_api=>modes-legacy_text
                mode_options = VALUE #(
                    codepage = codepage
                    linefeed = zfloppy_dataset_api=>linefeeds-native ) ).
            open = abap_true.

            dataset_api->read_dataset(
              EXPORTING
                dataset     = path
              IMPORTING
                data_object = result
                return_code = DATA(return_code) ).
            IF return_code <> 0.
              RAISE EXCEPTION TYPE zfloppy_backend_fs_exception.
            ENDIF.

            open = abap_false.
            dataset_api->close_dataset( path ).

          CATCH zfloppy_dataset_api_exception INTO DATA(exception).
            cl_message_helper=>set_msg_vars_for_any( exception ).
            RAISE EXCEPTION TYPE zfloppy_backend_fs_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
        ENDTRY.
      CLEANUP.
        IF open = abap_true.
          TRY.
              dataset_api->close_dataset( path ).
            CATCH zfloppy_dataset_api_exception ##NO_HANDLER.
          ENDTRY.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_fs_partial_reader~read_file_to_buffer_bin.
*    DATA: return_code TYPE syst_subrc.
*
*    TRY.
*        dataset_api->open_dataset(
*          EXPORTING
*            dataset                  = path
*            access_type              = zfloppy_dataset_api=>access_types-input
*            mode                     = zfloppy_dataset_api=>modes-binary
*            position                 = offset
*          IMPORTING
*            return_code              = return_code
*            message                  = DATA(message) ).
*        IF return_code <> 0.
*          cl_message_helper=>set_msg_vars_for_clike( message ).
*          RAISE EXCEPTION TYPE zfloppy_backend_fs_exception USING MESSAGE.
*        ENDIF.
*
*        dataset_api->read_dataset(
*          EXPORTING
*            dataset        = path
*            maximum_length = length
*          IMPORTING
*            data_object    = buffer
*            return_code    = return_code ).
*        IF return_code <> 0.
*          RAISE EXCEPTION TYPE zfloppy_file_system_exception.
*        ENDIF.
*
*        dataset_api->close_dataset( path ).
*
*      CATCH cx_sy_file_open
*            cx_sy_codepage_converter_init
*            cx_sy_conversion_codepage
*            cx_sy_file_authority
*            cx_sy_file_io
*            cx_sy_file_open_mode
*            cx_sy_file_close INTO DATA(exception).
*        cl_message_helper=>set_msg_vars_for_any( exception ).
*        RAISE EXCEPTION TYPE zfloppy_backend_fs_exception USING MESSAGE
*          EXPORTING
*            previous = exception.
*    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_fs_partial_reader~read_file_to_buffer_text.

  ENDMETHOD.

  METHOD zfloppy_fs_partial_writer~write_buffer_to_file_bin.

  ENDMETHOD.

  METHOD zfloppy_fs_partial_writer~write_buffer_to_file_text.

  ENDMETHOD.

  METHOD zfloppy_file_system~write_file_bin.

  ENDMETHOD.
  METHOD zfloppy_file_system~create_directory.

  ENDMETHOD.

  METHOD zfloppy_file_system~delete_directory.

  ENDMETHOD.

  METHOD zfloppy_file_system~get_default_codepage.
    result = zfloppy_codepage_helper=>get_system_codepage( ).
  ENDMETHOD.

  METHOD zfloppy_file_system~get_directory_contents.
    " RSWATCH0 TS_FILE
    TYPES: BEGIN OF al11_file,
             dirname  TYPE dirname_al11,
             name     TYPE filename_al11,
             type     TYPE c LENGTH 10,
             len      TYPE p LENGTH 8 DECIMALS 0,
             owner    TYPE fileowner_al11,
             mtime    TYPE p LENGTH 6 DECIMALS 0,
             mode     TYPE c LENGTH 9,
             useable  TYPE c LENGTH 1,
             subrc    TYPE c LENGTH 4,
             errno    TYPE c LENGTH 3,
             errmsg   TYPE c LENGTH 40,
             mod_date TYPE d,
             mod_time TYPE c LENGTH 8,
             seen     TYPE c LENGTH 1,
             changed  TYPE c LENGTH 1,
             status   TYPE c LENGTH 1,
           END OF al11_file,
           al11_file_tab TYPE STANDARD TABLE OF al11_file.
    FIELD-SYMBOLS: <file_list> TYPE al11_file_tab.

    TRY.
        DATA(short_path) = EXACT dirname_al11( path ).

        PERFORM fill_file_list IN PROGRAM rswatch0
          USING short_path " a_dir_name
                '*' " a_generic_name
                ' ' " a_must_cs = NO_CS
                'I'. " a_operation = c_file_list_create
        ASSIGN ('(RSWATCH0)FILE_LIST[]') TO <file_list>.
        ASSERT sy-subrc = 0.

        result = VALUE #( FOR f IN <file_list> (
          filename   = f-name
          filelength = f-len
          isdir      = COND #( WHEN f-type(1) NA 'fF' THEN 1 ELSE 0 )
          writedate  = f-mod_date
          writetime  = f-mod_time ) ).

        CLEAR <file_list>.

      CATCH cx_sy_conversion_data_loss INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_file_system_exception
          MESSAGE ID sy-msgid
          NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_description.
    result = 'Application Server'.
  ENDMETHOD.

  METHOD zfloppy_file_system~get_separator.
    result = cl_fs_path=>separator ##TODO. " Maybe find a better way to access the separator?
  ENDMETHOD.

  METHOD zfloppy_file_system~get_connection_info.

  ENDMETHOD.

  METHOD zfloppy_file_system~get_supported_methods.

  ENDMETHOD.
ENDCLASS.
