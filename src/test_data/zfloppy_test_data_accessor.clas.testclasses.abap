*"* use this source file for your ABAP unit test classes

*CLASS test DEFINITION DEFERRED.
*CLASS zfloppy_test_data_accessor DEFINITION LOCAL FRIENDS test.
*
*CLASS test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
*  PUBLIC SECTION.
*    METHODS:
*      get_iterator FOR TESTING RAISING cx_static_check.
*  PRIVATE SECTION.
*    DATA:
*      cut TYPE REF TO zfloppy_test_data_accessor.
*    METHODS:
*      setup RAISING cx_static_check,
*      teardown.
*ENDCLASS.
*
*CLASS test IMPLEMENTATION.
*  METHOD setup.
*    cut = NEW #( ).
*  ENDMETHOD.
*
*  METHOD teardown.
*    FREE cut.
*  ENDMETHOD.
*
*  METHOD get_iterator.
*    DATA(iterator) = cut->get_test_file_iterator( ).
*
*    WHILE iterator->has_next( ).
*      DATA(test_file) = CAST zfloppy_test_data_accessor=>test_file( iterator->get_next( ) ).
*    ENDWHILE.
*  ENDMETHOD.
*ENDCLASS.
