*"* use this source file for your ABAP unit test classes

CLASS domain_test DEFINITION INHERITING FROM zfloppy_domain_enum_test FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS:
      constructor.
ENDCLASS.

CLASS domain_test IMPLEMENTATION.
  METHOD constructor.
    DATA: class  TYPE REF TO zfloppy_path_kind_enum,
          domain TYPE zfloppy_path_kind.

    super->constructor(
        class  = class
        domain = domain ).
  ENDMETHOD.
ENDCLASS.
