CLASS zfloppy_frontend_services_exc DEFINITION
  PUBLIC
  INHERITING FROM zfloppy_exception
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF classic_exception_method_call,
        msgid TYPE symsgid VALUE 'ZFLOPPY_FS_FRONTEND',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'EXCEPTION',
        attr2 TYPE scx_attrname VALUE 'METHOD',
        attr3 TYPE scx_attrname VALUE 'CLASS',
        attr4 TYPE scx_attrname VALUE '',
      END OF classic_exception_method_call.
    DATA:
      exception TYPE string READ-ONLY,
      method    TYPE abap_methname READ-ONLY,
      class     TYPE abap_classname READ-ONLY.
    METHODS:
      constructor IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                            previous  LIKE previous OPTIONAL
                            exception TYPE csequence OPTIONAL
                            method    TYPE abap_methname OPTIONAL
                            class     TYPE abap_classname DEFAULT 'CL_GUI_FRONTEND_SERVICES'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zfloppy_frontend_services_exc IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->exception = exception.
    me->method = method.
    me->class = class.
  ENDMETHOD.
ENDCLASS.
