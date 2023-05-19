CLASS zfloppy_dataset_api_exception DEFINITION
  PUBLIC
  INHERITING FROM zfloppy_exception
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor IMPORTING textid      LIKE if_t100_message=>t100key OPTIONAL
                                  !previous   LIKE previous                 OPTIONAL
                                  return_code TYPE syst_subrc               OPTIONAL.

    DATA return_code TYPE syst_subrc READ-ONLY.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zfloppy_dataset_api_exception IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->return_code = return_code.
  ENDMETHOD.
ENDCLASS.
