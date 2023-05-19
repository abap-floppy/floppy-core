"! <p class="shorttext synchronized">Dataset API</p>
"!
"! <p>This interface defines methods, types and constants for the ABAP statements regarding the file interface on the
"! backend file system of the current application server.</p>
"!
"! <p>The methods signatures mostly match the specifications for the statements in the ABAP Keyword Documentation. One
"! exception to that is the exception handling and usage of return codes. Both should be implemented using
"! {@link ZFLOPPY_DATASET_API_EXCEPTION} which allows for wrapping {@link CX_SY_FILE_ACCESS_ERROR} and
"! <em>sy-subrc</em>. One exception to that approach: If a statement needs to both return values and a return code then
"! the return code should be added as a parameter.</p>
INTERFACE zfloppy_dataset_api PUBLIC.
  TYPES:
    access_type           TYPE c          LENGTH 1,
    mode                  TYPE c          LENGTH 15,
    encoding              TYPE c          LENGTH 15,
    linefeed              TYPE c          LENGTH 10,
    endian                TYPE c          LENGTH 1,
    BEGIN OF mode_options,
      encoding            TYPE encoding,
      linefeed            TYPE linefeed,
      endian              TYPE endian,
      codepage            TYPE cpcodepage,
    END OF mode_options,
    BEGIN OF os_additions,
      type                TYPE string,
      filter              TYPE string,
    END OF os_additions,
    replacement_character TYPE c          LENGTH 1.
  CONSTANTS:
    BEGIN OF access_types,
      input                         TYPE access_type VALUE 'I',
      output                        TYPE access_type VALUE 'O',
      appending                     TYPE access_type VALUE 'A',
      update                        TYPE access_type VALUE 'U',
    END OF access_types,
    BEGIN OF modes,
      binary                        TYPE mode        VALUE 'BINARY',
      text                          TYPE mode        VALUE 'TEXT',
      legacy_binary                 TYPE mode        VALUE 'LEGACY_BINARY',
      legacy_text                   TYPE mode        VALUE 'LEGACY_TEXT',
    END OF modes,
    BEGIN OF encodings,
      default                       TYPE encoding    VALUE 'DEFAULT',
      utf8                          TYPE encoding    VALUE 'UTF8',
      utf8_skipping_byte_order_mark TYPE encoding    VALUE 'UTF8_SKIP_BOM',
      utf8_with_byte_order_mark     TYPE encoding    VALUE 'UTF8_WITH_BOM',
    END OF encodings,
    BEGIN OF linefeeds,
      native                        TYPE linefeed    VALUE 'NATIVE',
      smart                         TYPE linefeed    VALUE 'SMART',
      unix                          TYPE linefeed    VALUE 'UNIX',
      windows                       TYPE linefeed    VALUE 'WINDOWS',
    END OF linefeeds,
    BEGIN OF endians,
      little_endian                 TYPE endian      VALUE 'L',
      big_endian                    TYPE endian      VALUE 'B',
    END OF endians.

  METHODS:
    "! Open file
    open_dataset IMPORTING !dataset                 TYPE clike
                           access_type              TYPE access_type
                           !mode                    TYPE mode
                           mode_options             TYPE mode_options          OPTIONAL
                           !position                TYPE i                     OPTIONAL
                           os_additions             TYPE os_additions          OPTIONAL
                           ignore_conversion_errors TYPE abap_bool             DEFAULT abap_false
                           replacement_character    TYPE replacement_character OPTIONAL
                 RAISING   zfloppy_dataset_api_exception,

    transfer IMPORTING data_object    TYPE data
                       !dataset       TYPE clike
                       !length        TYPE i         OPTIONAL
                       no_end_of_line TYPE abap_bool DEFAULT abap_false
             RAISING   zfloppy_dataset_api_exception,

    read_dataset IMPORTING !dataset             TYPE clike
                           maximum_length       TYPE i DEFAULT -1
                 EXPORTING VALUE(data_object)   TYPE data
                           VALUE(actual_length) TYPE i
                           VALUE(return_code)   TYPE syst_subrc
                 RAISING   zfloppy_dataset_api_exception,

    "! <p class="shorttext synchronized" lang="en">Get information about open file</p>
    "!
    "! @parameter dataset | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter position | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter attributes | <p class="shorttext synchronized" lang="en"></p>
    "! @raising cx_sy_file_open_mode | <p class="shorttext synchronized" lang="en"></p>
    "! @raising cx_sy_file_position | <p class="shorttext synchronized" lang="en"></p>
    "! @raising cx_sy_conversion_overflow | <p class="shorttext synchronized" lang="en"></p>
    get_dataset IMPORTING !dataset          TYPE clike
                EXPORTING VALUE(position)   TYPE i
                          VALUE(attributes) TYPE dset_attributes
                RAISING   cx_sy_file_open_mode
                          cx_sy_file_position
                          cx_sy_conversion_overflow,

    set_dataset_position IMPORTING !dataset  TYPE clike
                                   !position TYPE i
                         RAISING   zfloppy_dataset_api_exception,

    set_dataset_attributes IMPORTING !dataset    TYPE clike
                                     !attributes TYPE dset_attributes
                           RAISING   zfloppy_dataset_api_exception,

    truncate_dataset_at IMPORTING !dataset  TYPE clike
                                  !position TYPE i
                        RAISING   zfloppy_dataset_api_exception,

    truncate_dataset_at_curr_pos IMPORTING !dataset TYPE clike
                                 RAISING   zfloppy_dataset_api_exception,

    "! Close file
    close_dataset IMPORTING !dataset TYPE clike
                  RAISING   zfloppy_dataset_api_exception,

    delete_dataset IMPORTING !dataset      TYPE clike
                   RETURNING VALUE(result) TYPE syst_subrc
                   RAISING   cx_sy_file_authority
                             cx_sy_file_open.
ENDINTERFACE.
