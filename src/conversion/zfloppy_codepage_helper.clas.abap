CLASS zfloppy_codepage_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CONSTANTS:
      "! Some well known external codepage names (TCP00A-CPATTR for CPATTRKIND=H)
      BEGIN OF external_codepage_names,
        utf8     TYPE string VALUE `utf-8`,
        utf16_be TYPE string VALUE `utf-16be`,
        utf16_le TYPE string VALUE `utf-16le`,
      END OF external_codepage_names.

    CLASS-METHODS get_codepage_by_external_name IMPORTING external_name TYPE csequence
                                                RETURNING VALUE(result) TYPE cpcodepage
                                                RAISING   zfloppy_codepage_exception.

    CLASS-METHODS get_system_codepage RETURNING VALUE(result) TYPE cpcodepage.

    CLASS-METHODS get_utf8 RETURNING VALUE(result) TYPE cpcodepage
                           RAISING   zfloppy_codepage_exception.

    CLASS-METHODS analyze_xstring IMPORTING xstring       TYPE xstring
                                            max_kb        TYPE i DEFAULT -1
                                  RETURNING VALUE(result) TYPE cpcodepage
                                  RAISING   zfloppy_codepage_exception.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF codepage_kinds,
        http           TYPE cpattrkind VALUE 'H',
        java           TYPE cpattrkind VALUE 'J',
      END OF codepage_kinds,
      BEGIN OF return_codes,
        success        TYPE syst_subrc VALUE 0,
        old_kernel     TYPE syst_subrc VALUE 1,
        io_error       TYPE syst_subrc VALUE 8,
        argument_error TYPE syst_subrc VALUE 16,
        not_found      TYPE syst_subrc VALUE 128,
      END OF return_codes.
ENDCLASS.


CLASS zfloppy_codepage_helper IMPLEMENTATION.
  METHOD get_codepage_by_external_name.
    DATA(mutable_external_name) = to_lower( external_name ).

    IF mutable_external_name IS INITIAL.
      RAISE EXCEPTION TYPE zfloppy_codepage_exception.
    ENDIF.

    DO 2 TIMES.
      DATA(codepage_kind) = SWITCH #( sy-index
                                      WHEN 1 THEN codepage_kinds-http
                                      WHEN 2 THEN codepage_kinds-java ).
      ASSERT codepage_kind IS NOT INITIAL.

      DATA(return_code) = cl_i18n_utils=>get_cp_from_name( EXPORTING im_name = external_name
                                                                     im_kind = codepage_kind
                                                           IMPORTING ex_cp   = result ).
      CASE return_code.
        WHEN return_codes-success.
          EXIT.
        WHEN return_codes-old_kernel.
          " Fallback to SCP_CODEPAGE_BY_EXTERNAL_N_OLD is not implemented as it is assumed that the minimal kernel
          " version on 7.50 does support the kernel method above.
          ASSERT 1 = 2.

        WHEN return_codes-not_found.
          CONTINUE.

        WHEN OTHERS.
          RAISE EXCEPTION TYPE zfloppy_codepage_exception.
      ENDCASE.
    ENDDO.

    IF result IS INITIAL.
      RAISE EXCEPTION TYPE zfloppy_codepage_exception.
    ENDIF.
  ENDMETHOD.

  METHOD get_system_codepage.
    CALL FUNCTION 'SCP_GET_CODEPAGE_NUMBER'
      EXPORTING database_also = abap_false
      IMPORTING appl_codepage = result.
  ENDMETHOD.

  METHOD get_utf8.
    result = get_codepage_by_external_name( external_codepage_names-utf8 ).
  ENDMETHOD.

  METHOD analyze_xstring.
    " If a file has a byte order mark return the corresponding codepage. If it does not check if all characters (up to
    " the kb limit) are UTF-8 compatible. Then return UTF-8, otherwise raise an exception. Some kind of heuristic could
    " be added or called in the future for different codepages.

    cl_abap_file_utilities=>check_xstring_utf8( EXPORTING xstring  = xstring
                                                          max_kb   = max_kb
                                                IMPORTING bom      = DATA(bom)
                                                          encoding = DATA(encoding) ).
    CASE bom.
      WHEN cl_abap_file_utilities=>bom_utf8.
        result = get_codepage_by_external_name( external_codepage_names-utf8 ).
      WHEN cl_abap_file_utilities=>bom_utf16_be.
        result = get_codepage_by_external_name( external_codepage_names-utf16_be ).
      WHEN cl_abap_file_utilities=>bom_utf16_le.
        result = get_codepage_by_external_name( external_codepage_names-utf16_le ).
      WHEN cl_abap_file_utilities=>no_bom.
        CASE encoding.
          WHEN cl_abap_file_utilities=>encoding_utf8 OR
               cl_abap_file_utilities=>encoding_7bit_ascii.
            result = get_codepage_by_external_name( external_codepage_names-utf8 ).
          WHEN cl_abap_file_utilities=>encoding_other.

          WHEN OTHERS.
            RAISE EXCEPTION TYPE zfloppy_codepage_exception.
        ENDCASE.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zfloppy_codepage_exception.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
