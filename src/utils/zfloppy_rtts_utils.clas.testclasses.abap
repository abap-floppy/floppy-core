*"* use this source file for your ABAP unit test classes

CLASS dummy DEFINITION.
ENDCLASS.

CLASS test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS:
      get_class_name FOR TESTING RAISING cx_static_check,
      get_class_name_wrong_param FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS test IMPLEMENTATION.
  METHOD get_class_name.
    DATA: dummy TYPE REF TO dummy.

    cl_abap_unit_assert=>assert_equals(
      exp = 'DUMMY'
      act = zfloppy_rtts_utils=>get_class_name_for_obj_ref( dummy ) ).
  ENDMETHOD.

  METHOD get_class_name_wrong_param.
    DATA: dummy TYPE REF TO syst_subrc.

    TRY.
        zfloppy_rtts_utils=>get_class_name_for_obj_ref( dummy ).
        cl_abap_unit_assert=>fail( ).
      CATCH zfloppy_illegal_argument ##NEEDED.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
