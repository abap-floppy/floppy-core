"! <p class="shorttext synchronized">Frontend Services</p>
"!
"! <p>This is just a thin wrapper around {@link cl_gui_frontend_services}. Classic exception are converted to
"! {@link zfloppy_frontend_services_exc}. Since these are not raised with messages the technical error context
"! (exception name and called method) is mentioned in the exception error message instead.
CLASS zfloppy_frontend_services_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zfloppy_frontend_services.
ENDCLASS.


CLASS zfloppy_frontend_services_impl IMPLEMENTATION.
  METHOD zfloppy_frontend_services~directory_create.
    cl_gui_frontend_services=>directory_create( EXPORTING  directory                = directory
                                                CHANGING   rc                       = result
                                                EXCEPTIONS directory_create_failed  = 1
                                                           cntl_error               = 2
                                                           error_no_gui             = 3
                                                           directory_access_denied  = 4
                                                           directory_already_exists = 5
                                                           path_not_found           = 6
                                                           unknown_error            = 7
                                                           not_supported_by_gui     = 8
                                                           wrong_parameter          = 9
                                                           OTHERS                   = 10 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `DIRECTORY_CREATE_FAILED`
                                  WHEN 2 THEN `CNTL_ERROR`
                                  WHEN 3 THEN `ERROR_NO_GUI`
                                  WHEN 4 THEN `DIRECTORY_ACCESS_DENIED`
                                  WHEN 5 THEN `DIRECTORY_ALREADY_EXISTS`
                                  WHEN 6 THEN `PATH_NOT_FOUND`
                                  WHEN 7 THEN `UNKNOWN_ERROR`
                                  WHEN 8 THEN `NOT_SUPPORTED_BY_GUI`
                                  WHEN 9 THEN `WRONG_PARAMETER`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'DIRECTORY_CREATE'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~directory_delete.
    cl_gui_frontend_services=>directory_delete( EXPORTING  directory               = directory
                                                CHANGING   rc                      = result
                                                EXCEPTIONS directory_delete_failed = 1
                                                           cntl_error              = 2
                                                           error_no_gui            = 3
                                                           path_not_found          = 4
                                                           directory_access_denied = 5
                                                           unknown_error           = 6
                                                           not_supported_by_gui    = 7
                                                           wrong_parameter         = 8
                                                           OTHERS                  = 9 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `DIRECTORY_DELETE_FAILED`
                                  WHEN 2 THEN `CNTL_ERROR`
                                  WHEN 3 THEN `ERROR_NO_GUI`
                                  WHEN 4 THEN `PATH_NOT_FOUND`
                                  WHEN 5 THEN `DIRECTORY_ACCESS_DENIED`
                                  WHEN 6 THEN `UNKNOWN_ERROR`
                                  WHEN 7 THEN `NOT_SUPPORTED_BY_GUI`
                                  WHEN 8 THEN `WRONG_PARAMETER`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'DIRECTORY_DELETE'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~directory_list_files.
    cl_gui_frontend_services=>directory_list_files( EXPORTING  directory                   = directory
                                                    CHANGING   file_table                  = file_table
                                                               count                       = count
                                                    EXCEPTIONS cntl_error                  = 1
                                                               directory_list_files_failed = 2
                                                               wrong_parameter             = 3
                                                               error_no_gui                = 4
                                                               not_supported_by_gui        = 5
                                                               OTHERS                      = 6 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `CNTL_ERROR`
                                  WHEN 2 THEN `DIRECTORY_LIST_FILES_FAILED`
                                  WHEN 3 THEN `WRONG_PARAMETER`
                                  WHEN 4 THEN `ERROR_NO_GUI`
                                  WHEN 5 THEN `NOT_SUPPORTED_BY_GUI`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'DIRECTORY_LIST_FILES'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~file_exists.
    cl_gui_frontend_services=>file_exist( EXPORTING  file                 = file
                                          RECEIVING  result               = result
                                          EXCEPTIONS cntl_error           = 1
                                                     error_no_gui         = 2
                                                     wrong_parameter      = 3
                                                     not_supported_by_gui = 4
                                                     OTHERS               = 5 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `CNTL_ERROR`
                                  WHEN 2 THEN `ERROR_NO_GUI`
                                  WHEN 3 THEN `WRONG_PARAMETER`
                                  WHEN 4 THEN `NOT_SUPPORTED_BY_GUI`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'FILE_EXISTS'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~gui_upload.
    cl_gui_frontend_services=>gui_upload( EXPORTING  filename                = filename
                                                     filetype                = filetype
                                                     codepage                = codepage
                                          IMPORTING  filelength              = filelength
                                          CHANGING   data_tab                = data_tab
                                          EXCEPTIONS file_open_error         = 1
                                                     file_read_error         = 2
                                                     no_batch                = 3
                                                     gui_refuse_filetransfer = 4
                                                     invalid_type            = 5
                                                     no_authority            = 6
                                                     unknown_error           = 7
                                                     bad_data_format         = 8
                                                     header_not_allowed      = 9
                                                     separator_not_allowed   = 10
                                                     header_too_long         = 11
                                                     unknown_dp_error        = 12
                                                     access_denied           = 13
                                                     dp_out_of_memory        = 14
                                                     disk_full               = 15
                                                     dp_timeout              = 16
                                                     not_supported_by_gui    = 17
                                                     error_no_gui            = 18
                                                     OTHERS                  = 19 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1  THEN `FILE_OPEN_ERROR`
                                  WHEN 2  THEN `FILE_READ_ERROR`
                                  WHEN 3  THEN `NO_BATCH`
                                  WHEN 4  THEN `GUI_REFUSE_FILETRANSFER`
                                  WHEN 5  THEN `INVALID_TYPE`
                                  WHEN 6  THEN `NO_AUTHORITY`
                                  WHEN 7  THEN `UNKNOWN_ERROR`
                                  WHEN 8  THEN `BAD_DATA_FORMAT`
                                  WHEN 9  THEN `HEADER_NOT_ALLOWED`
                                  WHEN 10 THEN `SEPARATOR_NOT_ALLOWED`
                                  WHEN 11 THEN `HEADER_TOO_LONG`
                                  WHEN 12 THEN `UNKNOWN_DP_ERROR`
                                  WHEN 13 THEN `ACCESS_DENIED`
                                  WHEN 14 THEN `DP_OUT_OF_MEMORY`
                                  WHEN 15 THEN `DISK_FULL`
                                  WHEN 16 THEN `DP_TIMEOUT`
                                  WHEN 17 THEN `NOT_SUPPORTED_BY_GUI`
                                  WHEN 18 THEN `ERROR_NO_GUI`
                                  ELSE         `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'GUI_UPLOAD'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~gui_download.
    cl_gui_frontend_services=>gui_download( EXPORTING  bin_filesize              = bin_filesize
                                                       filename                  = filename
                                                       filetype                  = filetype
                                                       append                    = append
                                                       write_field_separator     = abap_false
                                                       trunc_trailing_blanks     = abap_false
                                                       write_lf                  = abap_false " ?
                                                       codepage                  = codepage
                                                       ignore_cerr               = abap_false
                                                       write_bom                 = abap_false " ?
                                                       trunc_trailing_blanks_eol = abap_false
                                                       show_transfer_status      = abap_true
                                                       write_lf_after_last_line  = abap_false
                                            CHANGING   data_tab                  = data_tab
                                            EXCEPTIONS file_write_error          = 1
                                                       no_batch                  = 2
                                                       gui_refuse_filetransfer   = 3
                                                       invalid_type              = 4
                                                       no_authority              = 5
                                                       unknown_error             = 6
                                                       header_not_allowed        = 7
                                                       separator_not_allowed     = 8
                                                       filesize_not_allowed      = 9
                                                       header_too_long           = 10
                                                       dp_error_create           = 11
                                                       dp_error_send             = 12
                                                       dp_error_write            = 13
                                                       unknown_dp_error          = 14
                                                       access_denied             = 15
                                                       dp_out_of_memory          = 16
                                                       disk_full                 = 17
                                                       dp_timeout                = 18
                                                       file_not_found            = 19
                                                       dataprovider_exception    = 20
                                                       control_flush_error       = 21
                                                       not_supported_by_gui      = 22
                                                       error_no_gui              = 23
                                                       OTHERS                    = 24 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1  THEN `FILE_WRITE_ERROR`
                                  WHEN 2  THEN `NO_BATCH`
                                  WHEN 3  THEN `GUI_REFUSE_FILETRANSFER`
                                  WHEN 4  THEN `INVALID_TYPE`
                                  WHEN 5  THEN `NO_AUTHORITY`
                                  WHEN 6  THEN `UNKNOWN_ERROR`
                                  WHEN 7  THEN `HEADER_NOT_ALLOWED`
                                  WHEN 8  THEN `SEPARATOR_NOT_ALLOWED`
                                  WHEN 9  THEN `FILESIZE_NOT_ALLOWED`
                                  WHEN 10 THEN `HEADER_TOO_LONG`
                                  WHEN 11 THEN `DP_ERROR_CREATE`
                                  WHEN 12 THEN `DP_ERROR_SEND`
                                  WHEN 13 THEN `DP_ERROR_WRITE`
                                  WHEN 14 THEN `UNKNOWN_DP_ERROR`
                                  WHEN 15 THEN `ACCESS_DENIED`
                                  WHEN 16 THEN `DP_OUT_OF_MEMORY`
                                  WHEN 17 THEN `DISK_FULL`
                                  WHEN 18 THEN `DP_TIMEOUT`
                                  WHEN 19 THEN `FILE_NOT_FOUND`
                                  WHEN 20 THEN `DATAPROVIDER_EXCEPTION`
                                  WHEN 21 THEN `CONTROL_FLUSH_ERROR`
                                  WHEN 22 THEN `NOT_SUPPORTED_BY_GUI`
                                  WHEN 23 THEN `ERROR_NO_GUI`
                                  ELSE         `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'GUI_DOWNLOAD'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~get_separator.
    cl_gui_frontend_services=>get_file_separator( CHANGING   file_separator       = result
                                                  EXCEPTIONS not_supported_by_gui = 1
                                                             error_no_gui         = 2
                                                             cntl_error           = 3
                                                             OTHERS               = 4 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `NOT_SUPPORTED_BY_GUI`
                                  WHEN 2 THEN `ERROR_NO_GUI`
                                  WHEN 3 THEN `CNTL_ERROR`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'GET_FILE_SEPARATOR'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~flush.
    cl_gui_cfw=>flush( EXCEPTIONS cntl_system_error = 1
                                  cntl_error        = 2
                                  OTHERS            = 3 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `CNTL_SYSTEM_ERROR`
                                  WHEN 2 THEN `CNTL_ERROR`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'FLUSH'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~get_computer_name.
    cl_gui_frontend_services=>get_computer_name( CHANGING   computer_name        = computer_name
                                                 EXCEPTIONS cntl_error           = 1
                                                            error_no_gui         = 2
                                                            not_supported_by_gui = 3
                                                            OTHERS               = 4 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `CNTL_ERROR`
                                  WHEN 2 THEN `ERROR_NO_GUI`
                                  WHEN 3 THEN `NOT_SUPPORTED_BY_GUI`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'GET_COMPUTER_NAME'.
    ENDIF.
  ENDMETHOD.

  METHOD zfloppy_frontend_services~get_user_name.
    cl_gui_frontend_services=>get_user_name( CHANGING   user_name            = user_name
                                             EXCEPTIONS cntl_error           = 1
                                                        error_no_gui         = 2
                                                        not_supported_by_gui = 3
                                                        OTHERS               = 4 ).
    IF sy-subrc <> 0.
      DATA(exception) = SWITCH #( sy-subrc
                                  WHEN 1 THEN `CNTL_ERROR`
                                  WHEN 2 THEN `ERROR_NO_GUI`
                                  WHEN 3 THEN `NOT_SUPPORTED_BY_GUI`
                                  ELSE        `OTHERS` ).
      RAISE EXCEPTION TYPE zfloppy_frontend_services_exc
        EXPORTING textid    = zfloppy_frontend_services_exc=>classic_exception_method_call
                  exception = exception
                  method    = 'GET_USER_NAME'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
