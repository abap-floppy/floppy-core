CLASS zfloppy_message_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      set_msg_vars_for_any IMPORTING any TYPE data.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zfloppy_message_helper IMPLEMENTATION.
  METHOD set_msg_vars_for_any.
    " Actually for any here... cl_message_helper=>set_msg_vars_for_any doesn't support exceptions without any message
    " interface (IF_T100_MSG, IF_T100_DYN_MSG, IF_MESSAGE) for some reason. RAISE ... USING MESSAGE is not available
    " on 750.

    DESCRIBE FIELD any TYPE DATA(type).

    CASE type.
      WHEN 'r'. " Object reference
        DATA(object) = CAST object( any ).
        CASE TYPE OF object.
          WHEN TYPE if_t100_message.
            cl_message_helper=>set_msg_vars_for_if_t100_msg( CAST #( object ) ).
          WHEN TYPE if_message.
            cl_message_helper=>set_msg_vars_for_if_msg( CAST #( object ) ).
          WHEN TYPE cx_root INTO DATA(exception).
            cl_message_helper=>set_msg_vars_for_clike( exception->get_text( ) ).
        ENDCASE.
      WHEN OTHERS.
        cl_message_helper=>set_msg_vars_for_clike( any ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
