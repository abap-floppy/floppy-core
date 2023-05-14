CLASS zfloppy_path_kind_enum DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      path_separator TYPE c LENGTH 1,
      instances      TYPE SORTED TABLE OF REF TO zfloppy_path_kind_enum WITH UNIQUE KEY table_line.
    CLASS-DATA:
      windows TYPE REF TO zfloppy_path_kind_enum READ-ONLY,
      unix    TYPE REF TO zfloppy_path_kind_enum READ-ONLY.
    DATA:
      value        TYPE zfloppy_path_kind READ-ONLY,
      separator    TYPE path_separator READ-ONLY,
      fs_path_kind TYPE cl_fs_path=>path_kind_t READ-ONLY.
    CLASS-METHODS:
      class_constructor,
      from_value IMPORTING value         TYPE zfloppy_path_kind
                 RETURNING VALUE(result) TYPE REF TO zfloppy_path_kind_enum
                 RAISING   zfloppy_illegal_argument,
      from_separator IMPORTING separator     TYPE path_separator
                     RETURNING VALUE(result) TYPE REF TO zfloppy_path_kind_enum
                     RAISING   zfloppy_illegal_argument,
      get_instances RETURNING VALUE(result) TYPE instances.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      enum_instances TYPE instances.
    METHODS:
      constructor IMPORTING path_kind    TYPE zfloppy_path_kind
                            separator    TYPE path_separator
                            fs_path_kind TYPE cl_fs_path=>path_kind_t.

ENDCLASS.



CLASS zfloppy_path_kind_enum IMPLEMENTATION.
  METHOD class_constructor.
    windows = NEW #(
        path_kind = 'W'
        separator = '\'
        fs_path_kind = cl_fs_path=>path_kind_windows ).
    unix = NEW #(
        path_kind = 'U'
        separator = '/'
        fs_path_kind = cl_fs_path=>path_kind_unix ).
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

  METHOD from_separator.
    DATA(instances) = enum_instances.
    DELETE enum_instances WHERE table_line <> windows AND table_line <> unix.

    TRY.
        result = enum_instances[ table_line->separator = separator ].
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
    me->separator = separator.
    me->fs_path_kind = fs_path_kind.
    INSERT me INTO TABLE enum_instances.
  ENDMETHOD.
ENDCLASS.
