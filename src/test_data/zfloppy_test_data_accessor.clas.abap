CLASS zfloppy_test_data_accessor DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  FOR TESTING.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF test_file,
        file_content TYPE REF TO string,
        file_name    TYPE REF TO string,
        variant      TYPE etvar_id,
      END OF test_file,
      BEGIN OF test_path,
        path         TYPE REF TO string,
        is_folder    TYPE REF TO abap_bool,
        syntax_group TYPE REF TO filesys_d,
        variant      TYPE etvar_id,
      END OF test_path.

    CLASS-METHODS get_instance RETURNING VALUE(result) TYPE REF TO zfloppy_test_data_accessor
                               RAISING   zfloppy_test_data_exception.

    METHODS get_test_file_iterator RETURNING VALUE(result) TYPE REF TO zfloppy_test_data_iterator
                                   RAISING   zfloppy_test_data_exception.

    METHODS get_test_file IMPORTING variant       TYPE etvar_id
                          RETURNING VALUE(result) TYPE REF TO test_file
                          RAISING   zfloppy_test_data_exception.

    METHODS get_test_path_iterator RETURNING VALUE(result) TYPE REF TO zfloppy_test_data_iterator
                                   RAISING   zfloppy_test_data_exception.

    METHODS get_test_path IMPORTING variant       TYPE etvar_id
                          RETURNING VALUE(result) TYPE REF TO test_path
                          RAISING   zfloppy_test_data_exception.

  PRIVATE SECTION.
    CONSTANTS tdc_files_name TYPE etobj_name VALUE 'ZFLOPPY_FILES'.
    CONSTANTS tdc_paths_name TYPE etobj_name VALUE 'ZFLOPPY_PATHS'.

    CLASS-DATA instance TYPE REF TO zfloppy_test_data_accessor.

    DATA test_file_container TYPE REF TO cl_apl_ecatt_tdc_api.
    DATA test_path_container TYPE REF TO cl_apl_ecatt_tdc_api.

    METHODS constructor RAISING zfloppy_test_data_exception.
ENDCLASS.


CLASS zfloppy_test_data_accessor IMPLEMENTATION.
  METHOD get_instance.
    IF instance IS NOT BOUND.
      instance = NEW #( ).
    ENDIF.

    result = instance.
  ENDMETHOD.

  METHOD constructor.
    TRY.
        test_file_container = cl_apl_ecatt_tdc_api=>get_instance( tdc_files_name ).
        test_path_container = cl_apl_ecatt_tdc_api=>get_instance( tdc_paths_name ).
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_test_file_iterator.
    TRY.
        result = NEW test_file_iterator( test_file_container ).
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_test_file.
    TRY.
        DATA(variant_content) = test_file_container->get_variant_content( variant ).
        CREATE DATA result.
        result->file_content ?= variant_content[ parname = 'FILE_CONTENT' ]-value_ref.
        result->file_name    ?= variant_content[ parname = 'FILE_NAME' ]-value_ref.
        result->variant       = variant.
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_test_path_iterator.
    TRY.
        result = NEW test_path_iterator( test_path_container ).
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_test_path.
    TRY.
        DATA(variant_content) = test_path_container->get_variant_content( variant ).
        CREATE DATA result.
        result->path         ?= variant_content[ parname = 'PATH' ]-value_ref.
        result->is_folder    ?= variant_content[ parname = 'IS_FOLDER' ]-value_ref.
        result->syntax_group ?= variant_content[ parname = 'SYNTAX_GROUP' ]-value_ref.
        result->variant       = variant.
      CATCH cx_ecatt_tdc_access INTO DATA(exception).
        cl_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_test_data_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
