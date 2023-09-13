REPORT zfloppy_demo_test.

TRY.
    DATA(file) = zfloppy_file=>for_backend( `/tmp/floppytest3.txt` ).
*    file->set_current_codepage( '4110' ).
    file->touch( ).

    DO 10 TIMES.
      file->append_text( |{ sy-index }: Writing some content to a file in a loop\n| ).
    ENDDO.

    DATA(content) = file->read_all_content_as_text( ).

    SPLIT content AT |\n| INTO TABLE DATA(lines).
    LOOP AT lines ASSIGNING FIELD-SYMBOL(<line>).
      WRITE / <line>.
    ENDLOOP.

  CATCH zfloppy_exception INTO DATA(exception).
    MESSAGE exception TYPE 'E'.
ENDTRY.
