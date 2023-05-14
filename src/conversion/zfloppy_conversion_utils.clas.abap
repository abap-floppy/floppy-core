CLASS zfloppy_conversion_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      bom_id TYPE cl_abap_file_utilities=>bom_id,
      encoding_category TYPE c LENGTH 1,
      BEGIN OF utf8_analysis_result,
        bom_id TYPE bom_id,
        encoding_category TYPE encoding_category,
      END OF utf8_analysis_result.
    CLASS-METHODS:
      binary_tab_to_xstring IMPORTING binary_tab    TYPE ANY TABLE
                                      length        TYPE i
                            RETURNING VALUE(result) TYPE xstring
                            RAISING   zfloppy_conversion_exception,
      xstring_to_binary_tab IMPORTING xstring           TYPE xsequence
                            EXPORTING VALUE(binary_tab) TYPE INDEX TABLE
                            RAISING   zfloppy_conversion_exception,
      text_tab_to_string IMPORTING text_tab      TYPE ANY TABLE
                                   length        TYPE i
                         RETURNING VALUE(result) TYPE string
                         RAISING   zfloppy_conversion_exception,
      string_to_text_tab IMPORTING string          TYPE csequence
                         EXPORTING VALUE(text_tab) TYPE INDEX TABLE
                         RAISING   zfloppy_conversion_exception,
      string_to_xstring IMPORTING string        TYPE csequence
                                  codepage      TYPE cpcodepage
                        RETURNING VALUE(result) TYPE xstring
                        RAISING   zfloppy_conversion_exception,
      xstring_to_string IMPORTING xstring       TYPE xsequence
                                  codepage      TYPE cpcodepage
                        RETURNING VALUE(result) TYPE string
                        RAISING   zfloppy_conversion_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF converter_cache_line,
        codepage      TYPE cpcodepage,
        converter_in  TYPE REF TO cl_abap_conv_in_ce,
        converter_out TYPE REF TO cl_abap_conv_out_ce,
      END OF converter_cache_line.
    CLASS-DATA:
      converter_cache TYPE SORTED TABLE OF converter_cache_line WITH UNIQUE KEY codepage.
ENDCLASS.



CLASS zfloppy_conversion_utils IMPLEMENTATION.
  METHOD binary_tab_to_xstring.
    DATA: line_length TYPE i.
    FIELD-SYMBOLS: <line> TYPE x.

    DATA(remaining) = length.

    LOOP AT binary_tab ASSIGNING <line>.
      IF sy-tabix = 1.
        DESCRIBE FIELD <line> LENGTH line_length IN BYTE MODE.
      ENDIF.

      IF remaining < line_length.
        result = result && <line>(remaining).
      ELSE.
        result = result && <line>.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD xstring_to_binary_tab.
    DATA: line_length TYPE i.
    FIELD-SYMBOLS: <line> TYPE x.

    DATA(offset) = 0.
    DATA(remaining) = xstrlen( xstring ).

    WHILE remaining > 0.
      DATA(index) = sy-index.

      APPEND INITIAL LINE TO binary_tab ASSIGNING <line>.

      IF index = 1.
        DESCRIBE FIELD <line> LENGTH line_length IN BYTE MODE.
      ENDIF.

      IF remaining < line_length.
        <line> = xstring+offset(remaining).
        remaining = 0.
      ELSE.
        <line> = xstring+offset(line_length).
        remaining = remaining - line_length.
        offset = offset + line_length.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD text_tab_to_string.
    DATA: line_length TYPE i.
    FIELD-SYMBOLS: <line> TYPE c.

    DATA(remaining) = length.

    LOOP AT text_tab ASSIGNING <line>.
      IF sy-tabix = 1.
        DESCRIBE FIELD <line> LENGTH line_length IN CHARACTER MODE.
      ENDIF.

      IF remaining < line_length.
        result = result && <line>(remaining).
      ELSE.
        result = result && <line>.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD string_to_text_tab.
    DATA: line_length TYPE i.
    FIELD-SYMBOLS: <line> TYPE c.

    DATA(offset) = 0.
    DATA(remaining) = strlen( string ).

    WHILE remaining > 0.
      DATA(index) = sy-index.

      APPEND INITIAL LINE TO text_tab ASSIGNING <line>.

      IF index = 1.
        DESCRIBE FIELD <line> LENGTH line_length IN CHARACTER MODE.
      ENDIF.

      IF remaining < line_length.
        <line> = string+offset(remaining).
        remaining = 0.
      ELSE.
        <line> = string+offset(line_length).
        remaining = remaining - line_length.
        offset = offset + line_length.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD string_to_xstring.
    TRY.
        READ TABLE converter_cache WITH TABLE KEY codepage = codepage REFERENCE INTO DATA(cache).
        IF sy-subrc <> 0.
          INSERT VALUE #(
              codepage = codepage
          ) INTO TABLE converter_cache REFERENCE INTO cache.
        ENDIF.

        ASSERT cache IS BOUND.

        IF cache->converter_out IS NOT BOUND.
          cache->converter_out = cl_abap_conv_out_ce=>create( encoding = CONV #( codepage ) ).
        ENDIF.

        ASSERT cache->converter_out IS BOUND.

        cache->converter_out->convert(
          EXPORTING
            data   = string
          IMPORTING
            buffer = result ).

      CATCH cx_parameter_invalid_range
            cx_sy_codepage_converter_init
            cx_sy_conversion_codepage
            cx_parameter_invalid_type INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_conversion_exception
          MESSAGE ID sy-msgid
          NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD xstring_to_string.
    TRY.
        READ TABLE converter_cache WITH TABLE KEY codepage = codepage REFERENCE INTO DATA(cache).
        IF sy-subrc <> 0.
          INSERT VALUE #(
              codepage = codepage
          ) INTO TABLE converter_cache REFERENCE INTO cache.
        ENDIF.

        ASSERT cache IS BOUND.

        IF cache->converter_in IS NOT BOUND.
          cache->converter_in = cl_abap_conv_in_ce=>create( encoding = CONV #( codepage ) ).
        ENDIF.

        ASSERT cache->converter_in IS BOUND.

        cache->converter_in->convert(
          EXPORTING
            input = xstring
          IMPORTING
            data  = result ).

      CATCH cx_parameter_invalid_range
            cx_sy_codepage_converter_init
            cx_sy_conversion_codepage
            cx_parameter_invalid_type INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_conversion_exception
          MESSAGE ID sy-msgid
          NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
