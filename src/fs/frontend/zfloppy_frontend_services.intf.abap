INTERFACE zfloppy_frontend_services PUBLIC.
  TYPES:
    file_type TYPE char10,
    separator TYPE c LENGTH 1.
  CONSTANTS:
    BEGIN OF file_types,
      ascii  TYPE filetype VALUE 'ASC',
      binary TYPE filetype VALUE 'BIN',
    END OF file_types.
  METHODS:
    directory_create IMPORTING directory     TYPE string
                     RETURNING VALUE(result) TYPE i
                     RAISING   zfloppy_frontend_services_exc,
    directory_delete IMPORTING directory     TYPE string
                     RETURNING VALUE(result) TYPE i
                     RAISING   zfloppy_frontend_services_exc,
    file_exists IMPORTING file          TYPE string
                RETURNING VALUE(result) TYPE abap_bool
                RAISING   zfloppy_frontend_services_exc,
    directory_list_files IMPORTING directory  TYPE string
                         EXPORTING file_table TYPE STANDARD TABLE
                                   count      TYPE i
                         RAISING   zfloppy_frontend_services_exc,
    "! Upload a file from the frontend server
    gui_upload IMPORTING filename   TYPE string
                         filetype   TYPE file_type
                         codepage   TYPE abap_encoding DEFAULT space
               EXPORTING filelength TYPE i
                         data_tab   TYPE STANDARD TABLE
               RAISING   zfloppy_frontend_services_exc,
    "! Download a file to the frontend server
    gui_download IMPORTING bin_filesize    TYPE i OPTIONAL
                           filename        TYPE string
                           filetype        TYPE file_type
                           append          TYPE abap_bool DEFAULT abap_false
                           codepage        TYPE abap_encoding DEFAULT space
                           VALUE(data_tab) TYPE STANDARD TABLE
                 RAISING   zfloppy_frontend_services_exc,
    get_separator RETURNING VALUE(result) TYPE separator
                  RAISING   zfloppy_frontend_services_exc,
    flush RAISING zfloppy_frontend_services_exc,
    "! Requires {@link zfloppy_frontend_services.METH:flush}
    get_computer_name CHANGING computer_name TYPE string
                      RAISING  zfloppy_frontend_services_exc,
    "! Requires {@link zfloppy_frontend_services.METH:flush}
    get_user_name CHANGING user_name TYPE string
                  RAISING  zfloppy_frontend_services_exc.
ENDINTERFACE.
