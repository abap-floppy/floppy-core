"! <p class="shorttext synchronized">Path</p>
"!
"! <p>Immutable representation of an absolute path to a file or a directory on a file system.</p>
"!
"! <h1>Implementation Details</h1>
"! <p>This class basically wraps {@link CL_FS_PATH} and converts the exceptions to checked ones but also provides an
"! immutable API instead of a mutable one by creating a new instance on every call with changes to the path.
"! That approach <em>could</em> be slow but that's fine for now.</p>
CLASS zfloppy_path DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    DATA path      TYPE string                        READ-ONLY.
    DATA path_kind TYPE REF TO zfloppy_path_kind_enum READ-ONLY.

    CLASS-METHODS from_string IMPORTING !path         TYPE csequence
                                        path_kind     TYPE REF TO zfloppy_path_kind_enum OPTIONAL
                              RETURNING VALUE(result) TYPE REF TO zfloppy_path
                              RAISING   zfloppy_path_exception.

    CLASS-METHODS from_logical_filename IMPORTING logical_filename TYPE fileintern
                                        RETURNING VALUE(result)    TYPE REF TO zfloppy_path
                                        RAISING   zfloppy_path_exception.

    METHODS append_path IMPORTING !path         TYPE csequence
                        RETURNING VALUE(result) TYPE REF TO zfloppy_path
                        RAISING   zfloppy_path_exception.

    METHODS is_directory        RETURNING VALUE(result) TYPE abap_bool.
    METHODS get_extension       RETURNING VALUE(result) TYPE string.
    METHODS get_filename        RETURNING VALUE(result) TYPE string.
    METHODS get_base_filename   RETURNING VALUE(result) TYPE string.
    METHODS is_root_folder      RETURNING VALUE(result) TYPE abap_bool.
    METHODS get_path_components RETURNING VALUE(result) TYPE string_table.

  PRIVATE SECTION.
    DATA fs_path TYPE REF TO cl_fs_path.

    "! {@link .data:fs_path} must be provided as mutable (copied) by the caller
    CLASS-METHODS from_fs_path IMPORTING fs_path       TYPE REF TO cl_fs_path
                               RETURNING VALUE(result) TYPE REF TO zfloppy_path
                               RAISING   zfloppy_path_exception.

    CLASS-METHODS parse_path_kind_from_string IMPORTING !path         TYPE csequence
                                              RETURNING VALUE(result) TYPE REF TO zfloppy_path_kind_enum
                                              RAISING   zfloppy_path_exception.
ENDCLASS.


CLASS zfloppy_path IMPLEMENTATION.
  METHOD from_string.
    TRY.
        DATA(mutable_path_kind) = COND #(
            WHEN path_kind IS BOUND
            THEN path_kind
            ELSE parse_path_kind_from_string( path ) ).

        result = NEW #( ).
        result->fs_path   = cl_fs_path=>create( name           = path
                                                force_absolute = abap_true
                                                path_kind      = mutable_path_kind->fs_path_kind ).
        result->path      = result->fs_path->get_path_name( ).
        result->path_kind = mutable_path_kind.
      CATCH cx_fs_path_error INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_path_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD from_logical_filename.
    TRY.
        result = from_fs_path( cl_fs_path=>create_from_logical_name(
                                   name      = logical_filename
                                   path_kind = cl_fs_path=>path_kind_from_opsys( ) ) ).
      CATCH cx_fs_path_error INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_path_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD from_fs_path.
    result = NEW #( ).
    result->fs_path = fs_path.
    result->path    = result->fs_path->get_path_name( ).

    CASE TYPE OF result->fs_path.
      WHEN TYPE cl_fs_unix_path.
        result->path_kind = zfloppy_path_kind_enum=>unix.
      WHEN TYPE cl_fs_windows_path.
        result->path_kind = zfloppy_path_kind_enum=>windows.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zfloppy_path_exception.
    ENDCASE.
  ENDMETHOD.

  METHOD parse_path_kind_from_string.
    DATA separator TYPE zfloppy_path_kind_enum=>path_separator.

    " Very basic determination, ideally find a method to call instead

    DATA(length) = strlen( path ).

    IF length >= 1 AND path(1) = '/'.
      separator = path(1).
    ELSEIF length >= 3 AND to_lower( path(1) ) CA sy-abcde AND path+1(1) = ':' AND path+2(1) = '\'.
      separator = path(3).
    ENDIF.

    IF separator IS INITIAL.
      RAISE EXCEPTION TYPE zfloppy_path_exception.
    ENDIF.

    TRY.
        result = zfloppy_path_kind_enum=>from_separator( separator ).
      CATCH zfloppy_illegal_argument INTO DATA(exception).
        RAISE EXCEPTION TYPE zfloppy_path_exception
          EXPORTING previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD append_path.
    TRY.
        DATA(fs_path) = me->fs_path->copy( ).
        fs_path->append_path_name( path ).
        result = from_fs_path( fs_path ).
      CATCH cx_fs_path_error INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_path_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_extension.
    result = fs_path->get_file_extension( ).
    IF result IS NOT INITIAL AND result(1) = '.'.
      result = result+1.
    ENDIF.
  ENDMETHOD.

  METHOD get_filename.
    result = fs_path->get_file_name( ).
  ENDMETHOD.

  METHOD get_base_filename.
    result = fs_path->get_file_base_name( ).
  ENDMETHOD.

  METHOD is_directory.
    result = xsdbool( fs_path->get_file_name( ) IS INITIAL ).
  ENDMETHOD.

  METHOD is_root_folder.
    result = xsdbool( fs_path->is_empty( ) = abap_true ).
  ENDMETHOD.

  METHOD get_path_components.
    SPLIT path AT path_kind->separator INTO TABLE result.
  ENDMETHOD.
ENDCLASS.
