CLASS zfloppy_target_server_enum DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      instances TYPE SORTED TABLE OF REF TO zfloppy_target_server_enum WITH UNIQUE KEY table_line.
    CLASS-DATA:
      frontend TYPE REF TO zfloppy_target_server_enum READ-ONLY,
      backend  TYPE REF TO zfloppy_target_server_enum READ-ONLY.
    DATA:
      value TYPE zfloppy_target_server READ-ONLY.
    CLASS-METHODS:
      class_constructor,
      from_value IMPORTING value         TYPE zfloppy_target_server
                 RETURNING VALUE(result) TYPE REF TO zfloppy_target_server_enum
                 RAISING   zfloppy_illegal_argument,
      get_instances RETURNING VALUE(result) TYPE instances.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      enum_instances TYPE instances.
    METHODS:
      constructor IMPORTING path_kind TYPE zfloppy_path_kind.
ENDCLASS.



CLASS zfloppy_target_server_enum IMPLEMENTATION.
  METHOD class_constructor.
    frontend = NEW #( 'F' ).
    backend = NEW #( 'B' ).
  ENDMETHOD.

  METHOD from_value.
    TRY.
        result = enum_instances[ table_line->value = value ].
      CATCH cx_sy_itab_line_not_found INTO DATA(exception).
        RAISE EXCEPTION TYPE zfloppy_illegal_argument
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_instances.
    result = enum_instances.
  ENDMETHOD.

  METHOD constructor.
    value = path_kind.
    INSERT me INTO TABLE enum_instances.
  ENDMETHOD.
ENDCLASS.
