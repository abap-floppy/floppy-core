CLASS zfloppy_status_bar_control DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor         IMPORTING !parent TYPE REF TO cl_gui_container.
    METHODS display             RAISING   zfloppy_control_exception.
    METHODS refresh             RAISING   zfloppy_control_exception.
    METHODS set_file_count      IMPORTING !count  TYPE i.
    METHODS set_directory_count IMPORTING !count  TYPE i.

  PRIVATE SECTION.
    DATA parent          TYPE REF TO cl_gui_container.
    DATA document        TYPE REF TO cl_dd_document.
    DATA directory_count TYPE i.
    DATA file_count      TYPE i.
ENDCLASS.


CLASS zfloppy_status_bar_control IMPLEMENTATION.
  METHOD constructor.
    me->parent = parent.
  ENDMETHOD.

  METHOD display.
    IF document IS BOUND.
      RETURN.
    ENDIF.

    document = NEW cl_dd_document( no_margins = abap_true ).
    refresh( ).
  ENDMETHOD.

  METHOD refresh.
    document->initialize_document( no_margins = abap_true ).
    document->add_text(
        text         = |{ file_count NUMBER = USER } Files, { directory_count NUMBER = USER } Directories|
        sap_fontsize = cl_dd_area=>small ).

    document->merge_document( ).
    document->display_document( EXPORTING  reuse_control      = abap_true
                                           reuse_registration = abap_true
                                           parent             = parent
                                EXCEPTIONS html_display_error = 1
                                           OTHERS             = 2 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zfloppy_control_exception
            MESSAGE ID sy-msgid
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD set_directory_count.
    directory_count = count.
  ENDMETHOD.

  METHOD set_file_count.
    file_count = count.
  ENDMETHOD.
ENDCLASS.
