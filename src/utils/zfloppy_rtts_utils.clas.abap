CLASS zfloppy_rtts_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get_class_name_for_obj_ref IMPORTING object_reference TYPE data
                                             RETURNING VALUE(result)    TYPE string
                                             RAISING   zfloppy_illegal_argument.
ENDCLASS.


CLASS zfloppy_rtts_utils IMPLEMENTATION.
  METHOD get_class_name_for_obj_ref.
    TRY.
        result = CAST cl_abap_objectdescr( CAST cl_abap_refdescr(
          cl_abap_typedescr=>describe_by_data( object_reference )
        )->get_referenced_type( ) )->get_relative_name( ).
      CATCH cx_sy_move_cast_error INTO DATA(exception).
        RAISE EXCEPTION TYPE zfloppy_illegal_argument
          EXPORTING previous = exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
