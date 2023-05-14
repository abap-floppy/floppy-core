*"* use this source file for your ABAP unit test classes

CLASS test_base DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT ABSTRACT.
  PROTECTED SECTION.
    CONSTANTS:
      dummy_folder_path TYPE string VALUE `C:\Users\Dummy\Desktop\Test`,
      dummy_file_path   TYPE string VALUE `C:\Users\Dummy\Desktop\Test File.txt`.
    DATA:
      cut                      TYPE REF TO zfloppy_frontend_fs_impl,
      frontend_services_double TYPE REF TO zfloppy_frontend_services,
      test_data                TYPE REF TO zfloppy_test_data_accessor.
  PRIVATE SECTION.
    METHODS:
      setup RAISING cx_static_check,
      teardown.
ENDCLASS.

CLASS test_base IMPLEMENTATION.
  METHOD setup.
    frontend_services_double ?= cl_abap_testdouble=>create(
        EXACT #( zfloppy_rtts_utils=>get_class_name_for_obj_ref( frontend_services_double ) ) ).
    cut = NEW #( frontend_services_double ).
    test_data = zfloppy_test_data_accessor=>get_instance( ).
  ENDMETHOD.

  METHOD teardown.
    FREE cut.
    FREE frontend_services_double.
    FREE test_data.
  ENDMETHOD.
ENDCLASS.

CLASS test_directory DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT INHERITING FROM test_base.
  PUBLIC SECTION.
    METHODS:
      create_directory FOR TESTING RAISING cx_static_check,
      create_directory_exception FOR TESTING RAISING cx_static_check,
      create_directory_rc FOR TESTING RAISING cx_static_check,
      delete_directory FOR TESTING RAISING cx_static_check,
      delete_directory_exception FOR TESTING RAISING cx_static_check,
      delete_directory_rc FOR TESTING RAISING cx_static_check,
      get_directory_contents FOR TESTING RAISING cx_static_check,
      get_directory_contents_exc FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS test_directory IMPLEMENTATION.
  METHOD create_directory.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( 0
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_create( directory = space ).

    cut->zfloppy_file_system~create_directory( dummy_folder_path ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD create_directory_exception.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_create( directory = space ).

    TRY.
        cut->zfloppy_file_system~create_directory( dummy_folder_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD create_directory_rc.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( 1
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_create( directory = space ).

    TRY.
        cut->zfloppy_file_system~create_directory( dummy_folder_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_not_bound( exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD delete_directory.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( 0
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_delete( directory = space ).

    cut->zfloppy_file_system~delete_directory( dummy_folder_path ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD delete_directory_exception.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_delete( directory = space ).

    TRY.
        cut->zfloppy_file_system~delete_directory( dummy_folder_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD delete_directory_rc.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( 1
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_delete( directory = space ).

    TRY.
        cut->zfloppy_file_system~delete_directory( dummy_folder_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_not_bound( exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD get_directory_contents.
    DATA(expected_files) = VALUE zfloppy_file_system=>file_info_tab(
        ( filename = dummy_file_path )
        ( filename = dummy_folder_path
          isdir    = 1 ) ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->set_parameter(
          name  = 'FILE_TABLE'
          value = expected_files
      )->set_parameter(
          name  = 'COUNT'
          value = lines( expected_files )
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_list_files( space ).

    cl_abap_unit_assert=>assert_equals(
      exp = expected_files
      act = cut->zfloppy_file_system~get_directory_contents( dummy_folder_path ) ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD get_directory_contents_exc.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->directory_list_files( space ).

    TRY.
        cut->zfloppy_file_system~get_directory_contents( dummy_folder_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.
ENDCLASS.

CLASS test_read DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT INHERITING FROM test_base.
  PUBLIC SECTION.
    METHODS:
      file_exists_true FOR TESTING RAISING cx_static_check,
      file_exists_false FOR TESTING RAISING cx_static_check,
      file_exists_exception FOR TESTING RAISING cx_static_check,
      read_file_bin FOR TESTING RAISING cx_static_check,
      read_file_bin_exception FOR TESTING RAISING cx_static_check,
      read_file_bin_tdc FOR TESTING RAISING cx_static_check,
      read_file_text FOR TESTING RAISING cx_static_check,
      read_file_text_exception FOR TESTING RAISING cx_static_check,
      read_file_text_tdc FOR TESTING RAISING cx_static_check.
  PRIVATE SECTION.
    CLASS-DATA:
      dummy_file_content TYPE string.
    CLASS-METHODS:
      class_setup,
      class_teardown.
ENDCLASS.

CLASS test_read IMPLEMENTATION.
  METHOD class_setup.
    dummy_file_content = |Hello, this is the file content\nNext line + EOL\n|.
  ENDMETHOD.

  METHOD class_teardown.
    CLEAR dummy_file_content.
  ENDMETHOD.

  METHOD file_exists_true.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( abap_true
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->file_exists( file = space ).

    cl_abap_unit_assert=>assert_true( cut->zfloppy_file_system~file_exists( dummy_file_path ) ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD file_exists_false.
    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( abap_false
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->file_exists( file = space ).

    cl_abap_unit_assert=>assert_false( cut->zfloppy_file_system~file_exists( dummy_file_path ) ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD file_exists_exception.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->file_exists( file = space ).

    TRY.
        cut->zfloppy_file_system~file_exists( dummy_file_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD read_file_bin.
    DATA: data_tab TYPE STANDARD TABLE OF x255.

    DATA(codepage) = zfloppy_codepage_helper=>get_codepage_by_external_name(
        zfloppy_codepage_helper=>external_codepage_names-utf8 ).

    DATA(expected_content) = zfloppy_conversion_utils=>string_to_xstring(
      codepage = codepage
      string   = dummy_file_content ).

    zfloppy_conversion_utils=>xstring_to_binary_tab(
      EXPORTING
        xstring    = expected_content
      IMPORTING
        binary_tab = data_tab ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->set_parameter( name = 'DATA_TAB' value = data_tab
      )->set_parameter( name = 'FILELENGTH' value = xstrlen( expected_content )
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->gui_upload(
      filename = space
      filetype = space ).

    cl_abap_unit_assert=>assert_equals(
      exp = expected_content
      act = cut->zfloppy_file_system~read_file_bin( dummy_file_path ) ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD read_file_bin_exception.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->gui_upload(
      filename = space
      filetype = space ).

    TRY.
        cut->zfloppy_file_system~read_file_bin( dummy_file_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.
  ENDMETHOD.

  METHOD read_file_bin_tdc.
    DATA: data_tab TYPE STANDARD TABLE OF x255.

    DATA(iterator) = test_data->get_test_file_iterator( ).

    WHILE iterator->has_next( ).
      CLEAR data_tab.

      DATA(test_file) = CAST zfloppy_test_data_accessor=>test_file( iterator->get_next( ) ).
      DATA(path) = |/{ test_file->variant }/{ test_file->file_name->* }|.

      DATA(file_content_binary) = zfloppy_conversion_utils=>string_to_xstring(
          string   = test_file->file_content->*
          codepage = zfloppy_codepage_helper=>get_system_codepage( ) ).

      zfloppy_conversion_utils=>xstring_to_binary_tab(
        EXPORTING
          xstring    = file_content_binary
        IMPORTING
          binary_tab = data_tab ).

      cl_abap_testdouble=>configure_call( frontend_services_double
        )->times( 1
        )->set_parameter(
             name  = 'DATA_TAB'
             value = data_tab
        )->set_parameter(
             name  = 'FILELENGTH'
             value = xstrlen( file_content_binary )
        )->and_expect(
        )->is_called_once( ).

      frontend_services_double->gui_upload(
        filename = path
        filetype = zfloppy_frontend_services=>file_types-binary ).

      cl_abap_unit_assert=>assert_equals(
        exp  = file_content_binary
        act  = cut->zfloppy_file_system~read_file_bin( path )
        quit = if_aunit_constants=>quit-no ).
    ENDWHILE.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD read_file_text.
    DATA: data_tab TYPE STANDARD TABLE OF x255.

    DATA(codepage) = zfloppy_codepage_helper=>get_codepage_by_external_name(
        zfloppy_codepage_helper=>external_codepage_names-utf8 ).

    DATA(expected_content) = dummy_file_content.

    DATA(xstring) = zfloppy_conversion_utils=>string_to_xstring(
      string   = expected_content
      codepage = codepage ).
    zfloppy_conversion_utils=>xstring_to_binary_tab(
      EXPORTING
        xstring    = xstring
      IMPORTING
        binary_tab = data_tab ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->set_parameter(
           name  = 'DATA_TAB'
           value = data_tab
      )->set_parameter(
           name  = 'FILELENGTH'
           value = strlen( expected_content )
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->gui_upload(
      filename = space
      filetype = space ).

    cl_abap_unit_assert=>assert_equals(
      exp = expected_content
      act = cut->zfloppy_file_system~read_file_text(
              codepage = codepage
              path     = dummy_file_path ) ).

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.

  METHOD read_file_text_exception.
    DATA(expected_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( expected_exception
      )->ignore_all_parameters(
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->gui_upload(
      filename = space
      filetype = space ).

    TRY.
        cut->zfloppy_file_system~read_file_text(
          codepage = zfloppy_codepage_helper=>get_codepage_by_external_name(
                         zfloppy_codepage_helper=>external_codepage_names-utf8 )
          path     = dummy_file_path ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_frontend_fs_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
          exp = expected_exception
          act = exception->previous ).
    ENDTRY.
  ENDMETHOD.

  METHOD read_file_text_tdc.
    DATA: data_tab TYPE STANDARD TABLE OF x255.

    DATA(codepage) = zfloppy_codepage_helper=>get_codepage_by_external_name(
        zfloppy_codepage_helper=>external_codepage_names-utf8 ).
    DATA(iterator) = test_data->get_test_file_iterator( ).

    WHILE iterator->has_next( ).
      CLEAR data_tab.

      DATA(test_file) = CAST zfloppy_test_data_accessor=>test_file( iterator->get_next( ) ).
      DATA(path) = |/{ test_file->variant }/{ test_file->file_name->* }|.

      DATA(xstring) = zfloppy_conversion_utils=>string_to_xstring(
        string = test_file->file_content->*
        codepage = codepage ).

      zfloppy_conversion_utils=>xstring_to_binary_tab(
        EXPORTING
          xstring    = xstring
        IMPORTING
          binary_tab = data_tab ).

      cl_abap_testdouble=>configure_call( frontend_services_double
        )->times( 1
        )->set_parameter(
             name  = 'DATA_TAB'
             value = data_tab
        )->set_parameter(
             name  = 'FILELENGTH'
             value = strlen( test_file->file_content->* )
        )->and_expect(
        )->is_called_once( ).

      frontend_services_double->gui_upload(
        filename = path
        filetype = zfloppy_frontend_services=>file_types-binary ).

      cl_abap_unit_assert=>assert_equals(
        exp  = test_file->file_content->*
        act  = cut->zfloppy_file_system~read_file_text(
                 codepage = codepage
                 path     = path )
        quit = if_aunit_constants=>quit-no ).
    ENDWHILE.

    cl_abap_testdouble=>verify_expectations( frontend_services_double ).
  ENDMETHOD.
ENDCLASS.

CLASS test_other DEFINITION INHERITING FROM test_base FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS:
      get_separator FOR TESTING RAISING cx_static_check,
      get_separator_exception FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS test_other IMPLEMENTATION.
  METHOD get_separator.
    DATA(expected) = '/'.

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->returning( expected
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->get_separator( ).

    cl_abap_unit_assert=>assert_equals(
        exp = expected
        act = cut->zfloppy_file_system~get_separator( ) ).
  ENDMETHOD.

  METHOD get_separator_exception.
    DATA(inner_exception) = NEW zfloppy_frontend_services_exc( ).

    cl_abap_testdouble=>configure_call( frontend_services_double
      )->times( 1
      )->raise_exception( inner_exception
      )->and_expect(
      )->is_called_once( ).

    frontend_services_double->get_separator( ).

    TRY.
        cut->zfloppy_file_system~get_separator( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_file_system_exception INTO DATA(exception).
        cl_abap_unit_assert=>assert_equals(
            exp = inner_exception
            act = exception->previous ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
