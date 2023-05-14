CLASS zfloppy_fs_method_enum DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      instances TYPE SORTED TABLE OF REF TO zfloppy_fs_method_enum WITH UNIQUE KEY table_line.
    CLASS-DATA:
      file_exists            TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      read_file_bin          TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      read_file_text         TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      write_file_bin         TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      get_directory_contents TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      create_directory       TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      delete_directory       TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      get_default_codepage   TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      get_separator          TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      get_connection_info    TYPE REF TO zfloppy_fs_method_enum READ-ONLY,
      BEGIN OF partial_reader READ-ONLY,
        read_file_to_buffer_bin  TYPE REF TO zfloppy_fs_method_enum,
        read_file_to_buffer_text TYPE REF TO zfloppy_fs_method_enum,
      END OF partial_reader,
      BEGIN OF partial_writer READ-ONLY,
        write_buffer_to_file_bin  TYPE REF TO zfloppy_fs_method_enum,
        write_buffer_to_file_text TYPE REF TO zfloppy_fs_method_enum,
      END OF partial_writer.
    DATA:
      value TYPE abap_methname READ-ONLY.
    CLASS-METHODS:
      class_constructor,
      get_instances RETURNING VALUE(result) TYPE instances.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      enum_instances TYPE instances.
    METHODS:
      constructor IMPORTING method_name TYPE abap_methname.
ENDCLASS.



CLASS zfloppy_fs_method_enum IMPLEMENTATION.
  METHOD class_constructor.
    file_exists = NEW #( 'FILE_EXISTS' ).
    read_file_bin = NEW #( 'READ_FILE_BIN' ).
    read_file_text = NEW #( 'READ_FILE_TEXT' ).
    write_file_bin = NEW #( 'WRITE_FILE_BIN' ).
    get_directory_contents = NEW #( 'GET_DIRECTORY_CONTENTS' ).
    create_directory = NEW #( 'CREATE_DIRECTORY' ).
    delete_directory = NEW #( 'DELETE_DIRECTORY' ).
    get_default_codepage = NEW #( 'GET_DEFAULT_CODEPAGE' ).
    get_separator = NEW #( 'GET_SEPARATOR' ).
    get_connection_info = NEW #( 'GET_CONNECTION_INFO' ).

    partial_reader = VALUE #(
        LET prefix = 'ZFLOPPY_FS_PARTIAL_READER' IN
        read_file_to_buffer_bin = NEW #( |{ prefix }~{ 'READ_FILE_TO_BUFFER_BIN' }| )
        read_file_to_buffer_text = NEW #( |{ prefix }~{ 'READ_FILE_TO_BUFFER_TEXT' }| ) ).

    partial_writer = VALUE #(
        LET prefix = 'ZFLOPPY_FS_PARTIAL_WRITER' IN
        write_buffer_to_file_bin = NEW #( |{ prefix }~{ 'WRITE_BUFFER_TO_FILE_BIN' }| )
        write_buffer_to_file_text = NEW #( |{ prefix }~{ 'WRITE_BUFFER_TO_FILE_TEXT' }| ) ).
  ENDMETHOD.

  METHOD get_instances.
    result = enum_instances.
  ENDMETHOD.

  METHOD constructor.
    value = method_name.
    INSERT me INTO TABLE enum_instances.
  ENDMETHOD.
ENDCLASS.
