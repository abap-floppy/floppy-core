REPORT zfloppy_demo_test.

TRY.
    DATA(file) = zfloppy_file=>for_backend( `/tmp/floppytest.txt` ).

    file->touch( ).

    DO 10 TIMES.
      file->append_text( |{ sy-index }: Writing some content to a file in a loop\n| ).
    ENDDO.

  CATCH zfloppy_exception INTO DATA(exception).
    MESSAGE exception TYPE 'E'.
ENDTRY.
