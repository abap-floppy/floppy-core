*"* use this source file for your ABAP unit test classes

CLASS parser_test DEFINITION DEFERRED.
CLASS zfloppy_path DEFINITION LOCAL FRIENDS parser_test.

CLASS parser_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS windows_normal      FOR TESTING RAISING cx_static_check.
    METHODS unix_normal         FOR TESTING RAISING cx_static_check.
    METHODS empty               FOR TESTING RAISING cx_static_check.
    METHODS mixed               FOR TESTING RAISING cx_static_check.
    METHODS test_data_container FOR TESTING RAISING cx_static_check.

  PRIVATE SECTION.
    DATA given_path       TYPE string.
    DATA result_separator TYPE zfloppy_path_kind_enum=>path_separator.
    DATA result_exception TYPE REF TO zfloppy_path_exception.

    METHODS given_the_path           IMPORTING !path     TYPE csequence.

    METHODS when_parsed.

    METHODS then_separator_should_be IMPORTING separator TYPE zfloppy_path_kind_enum=>path_separator.
    METHODS then_exc_should_be_thrown.

    METHODS teardown.
ENDCLASS.


CLASS parser_test IMPLEMENTATION.
  METHOD windows_normal.
    given_the_path( `C:\Users\Demo\Desktop\File.txt` ).
    when_parsed( ).
    then_separator_should_be( `\` ).
  ENDMETHOD.

  METHOD unix_normal.
    given_the_path( `/tmp/File.txt` ).
    when_parsed( ).
    then_separator_should_be( `/` ).
  ENDMETHOD.

  METHOD empty.
    given_the_path( `` ).
    when_parsed( ).
    then_exc_should_be_thrown( ).
  ENDMETHOD.

  METHOD mixed.
    given_the_path( `C:/tmp/File.txt` ).
    when_parsed( ).
    then_exc_should_be_thrown( ).
  ENDMETHOD.

  METHOD test_data_container.
    DATA(test_path_iterator) = zfloppy_test_data_accessor=>get_instance( )->get_test_path_iterator( ).

    WHILE test_path_iterator->has_next( ).
      DATA(test_path) = CAST zfloppy_test_data_accessor=>test_path( test_path_iterator->get_next( ) ).
      given_the_path( test_path->path->* ).
      when_parsed( ).
      then_separator_should_be( COND #( WHEN test_path->syntax_group->* = 'WINDOWS NT' THEN '\' ELSE '/' ) ).
      CLEAR result_separator.
    ENDWHILE.
  ENDMETHOD.

  METHOD given_the_path.
    given_path = path.
  ENDMETHOD.

  METHOD when_parsed.
    TRY.
        result_separator = zfloppy_path=>parse_separator_from_path( given_path ).
      CATCH zfloppy_path_exception INTO result_exception ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD then_separator_should_be.
    cl_abap_unit_assert=>assert_equals( exp = separator
                                        act = result_separator ).
  ENDMETHOD.

  METHOD then_exc_should_be_thrown.
    cl_abap_unit_assert=>assert_bound( result_exception ).
  ENDMETHOD.

  METHOD teardown.
    CLEAR: given_path,
           result_separator.
    FREE result_exception.
  ENDMETHOD.
ENDCLASS.
