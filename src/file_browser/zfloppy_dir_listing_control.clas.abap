CLASS zfloppy_dir_listing_control DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF display_options,
        layout_save_allowed     TYPE abap_bool,
        default_layout_allowed  TYPE abap_bool,
        layout_save_restriction TYPE salv_de_layout_restriction,
        layout_key              TYPE salv_s_layout_key,
      END OF display_options.

    EVENTS change_directory_requested EXPORTING VALUE(directory) TYPE REF TO zfloppy_path.
    EVENTS open_file_requested EXPORTING VALUE(path) TYPE REF TO zfloppy_path.

    DATA directory_listing TYPE STANDARD TABLE OF zfloppy_file_browser_out READ-ONLY.

    CLASS-METHODS get_default_display_options RETURNING VALUE(result) TYPE display_options.

    METHODS constructor IMPORTING !parent         TYPE REF TO cl_gui_container
                                  file_system     TYPE REF TO zfloppy_file_system
                                  !directory      TYPE REF TO zfloppy_path
                                  display_options TYPE display_options.

    METHODS display               RAISING   zfloppy_file_browser_exception.
    METHODS refresh               RAISING   zfloppy_control_exception.
    METHODS get_current_directory RETURNING VALUE(result) TYPE REF TO zfloppy_path.
    METHODS set_current_directory IMPORTING !directory    TYPE REF TO zfloppy_path.
    METHODS free.

  PRIVATE SECTION.
    DATA parent                 TYPE REF TO cl_gui_container.
    DATA file_system            TYPE REF TO zfloppy_file_system.
    DATA current_directory      TYPE REF TO zfloppy_path.
    DATA alv                    TYPE REF TO cl_salv_table.
    DATA actual_display_options TYPE display_options.

    METHODS update_listing  RAISING   zfloppy_exception.
    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table IMPORTING !row.
ENDCLASS.


CLASS zfloppy_dir_listing_control IMPLEMENTATION.
  METHOD get_default_display_options.
    result = VALUE #( layout_save_allowed = abap_false ).
  ENDMETHOD.

  METHOD constructor.
    me->parent      = parent.
    me->file_system = file_system.
    current_directory = directory.
    actual_display_options = display_options.
  ENDMETHOD.

  METHOD display.
    IF alv IS BOUND.
      RETURN.
    ENDIF.

    TRY.
        update_listing( ).

        cl_salv_table=>factory( EXPORTING r_container  = parent
                                IMPORTING r_salv_table = alv
                                CHANGING  t_table      = directory_listing ).
        SET HANDLER on_double_click FOR alv->get_event( ).

        DATA(columns) = alv->get_columns( ).

        CAST cl_salv_column_table( columns->get_column( 'IS_DIRECTORY' )
          )->set_cell_type( if_salv_c_cell_type=>checkbox ).
        columns->set_optimize( ).

        alv->get_functions( )->set_all( ).

        DATA(layout) = alv->get_layout( ).
        layout->set_key( actual_display_options-layout_key ).
        layout->set_save_restriction( actual_display_options-layout_save_restriction ).
        layout->set_default( actual_display_options-default_layout_allowed ).

        alv->get_selections( )->set_current_cell( VALUE #( columnname = 'FILENAME' row = 1 ) ).
        alv->display( ).

      CATCH cx_salv_error zfloppy_exception INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_control_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD refresh.
    TRY.
        update_listing( ).
        alv->refresh( s_stable     = VALUE #( row = abap_true col = abap_true )
                      refresh_mode = if_salv_c_refresh=>full ).
        alv->get_columns( )->set_optimize( ).
        alv->get_selections( )->set_current_cell( VALUE #( columnname = 'FILENAME' row = 1 ) ).
      CATCH cx_salv_error zfloppy_exception INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_control_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD free.
    CLEAR directory_listing.
    FREE alv.
  ENDMETHOD.

  METHOD get_current_directory.
    result = current_directory.
  ENDMETHOD.

  METHOD set_current_directory.
    current_directory = directory.
  ENDMETHOD.

  METHOD update_listing.
    CLEAR directory_listing.

    IF NOT current_directory->is_root_folder( ).
      directory_listing = VALUE #( ( filename             = '..'
                                     is_directory         = abap_true
                                     is_virtual_directory = abap_true ) ).
    ENDIF.

    directory_listing = VALUE #( BASE directory_listing
                                 FOR f IN file_system->get_directory_contents( current_directory->path )
                                 ( filename     = f-filename
                                   is_directory = xsdbool( f-isdir = 1 ) ) ).
  ENDMETHOD.

  METHOD on_double_click.
    IF row IS INITIAL.
      RETURN.
    ENDIF.

    DATA(line) = REF #( directory_listing[ row ] ).

    TRY.
        DATA(path) = current_directory->append_path( line->filename ).

        IF line->is_directory = abap_true.
          RAISE EVENT change_directory_requested
                EXPORTING
                  directory = path.
        ELSE.
          RAISE EVENT open_file_requested
                EXPORTING
                  path = path.
        ENDIF.

      CATCH zfloppy_exception INTO DATA(exception).
        MESSAGE exception TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
