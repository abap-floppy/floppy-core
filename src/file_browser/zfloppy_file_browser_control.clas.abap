CLASS zfloppy_file_browser_control DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF display_options,
        show_directory_tree       TYPE abap_bool,
        enable_path_input         TYPE abap_bool,
        show_file_system_info     TYPE abap_bool,
        show_status_bar           TYPE abap_bool,
        show_options_toolbar      TYPE abap_bool,
        directory_listing_options TYPE zfloppy_dir_listing_control=>display_options,
      END OF display_options.

    EVENTS open_file_requested EXPORTING VALUE(path)        TYPE REF TO zfloppy_path
                                         VALUE(file_system) TYPE REF TO zfloppy_file_system.
    EVENTS current_directory_changed EXPORTING VALUE(old_directory) TYPE REF TO zfloppy_path
                                               VALUE(new_directory) TYPE REF TO zfloppy_path.

    CLASS-METHODS get_default_display_options RETURNING VALUE(result) TYPE display_options.

    METHODS constructor IMPORTING !parent         TYPE REF TO cl_gui_container
                                  file_system     TYPE REF TO zfloppy_file_system
                                  !directory      TYPE REF TO zfloppy_path
                                  display_options TYPE display_options.

    METHODS display RAISING zfloppy_file_browser_exception.
    METHODS free.

  PRIVATE SECTION.
    DATA parent                 TYPE REF TO cl_gui_container.
    DATA file_system            TYPE REF TO zfloppy_file_system.
    DATA current_directory      TYPE REF TO zfloppy_path.
    DATA splitter               TYPE REF TO cl_gui_splitter_container.
    DATA inner_splitter_top     TYPE REF TO cl_gui_splitter_container.
    DATA toolbar                TYPE REF TO cl_gui_toolbar.
    DATA path_input             TYPE REF TO cl_gui_input_field.
    DATA directory_listing      TYPE REF TO zfloppy_dir_listing_control.
    DATA directory_tree         TYPE REF TO zfloppy_directory_tree_control.
    DATA status_bar             TYPE REF TO zfloppy_status_bar_control.
    DATA actual_display_options TYPE display_options.

    METHODS refresh_ui           RAISING   cx_salv_error.
    METHODS on_path_input_submit FOR EVENT submit OF cl_gui_input_field IMPORTING !input.

    METHODS on_change_directory_requ_tree FOR EVENT change_directory_requested OF zfloppy_directory_tree_control
      IMPORTING !directory.

    METHODS on_change_directory_requ_list FOR EVENT change_directory_requested OF zfloppy_dir_listing_control
      IMPORTING !directory.

    METHODS on_open_file_requested FOR EVENT open_file_requested OF zfloppy_dir_listing_control
      IMPORTING !path.
ENDCLASS.


CLASS zfloppy_file_browser_control IMPLEMENTATION.
  METHOD get_default_display_options.
    result = VALUE display_options(
                       show_directory_tree       = abap_true
                       enable_path_input         = abap_true
                       show_file_system_info     = abap_true
                       show_status_bar           = abap_true
                       show_options_toolbar      = abap_true
                       directory_listing_options = zfloppy_dir_listing_control=>get_default_display_options( ) ).
  ENDMETHOD.

  METHOD constructor.
    me->parent      = parent.
    me->file_system = file_system.
    current_directory = directory.
    actual_display_options = display_options.
  ENDMETHOD.

  METHOD display.
    TRY.
*        update_listing( ).
        refresh_ui( ).
      CATCH zfloppy_exception cx_salv_error INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_file_browser_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD refresh_ui.
    DATA pixels TYPE i.

    IF splitter IS NOT BOUND.
      splitter = NEW cl_gui_splitter_container(
                         shellstyle              = cl_gui_container=>ws_visible + cl_gui_container=>ws_child
                         parent                  = parent
                         rows                    = 5
                         columns                 = 1
                         no_autodef_progid_dynnr = abap_true ). " required for screen0 to work
      splitter->set_metric( cl_gui_control=>metric_pixel ).
      splitter->set_row_mode( cl_gui_splitter_container=>mode_absolute ).

      inner_splitter_top = NEW cl_gui_splitter_container(
                                   shellstyle              = cl_gui_container=>ws_visible + cl_gui_container=>ws_child
                                   parent                  = splitter->get_container( row    = 1
                                                                                      column = 1 )
                                   rows                    = 1
                                   columns                 = 2
                                   no_autodef_progid_dynnr = abap_true ). " required for screen0 to work
      inner_splitter_top->set_metric( cl_gui_control=>metric_pixel ).
      inner_splitter_top->set_column_mode( cl_gui_splitter_container=>mode_absolute ).

      pixels = cl_gui_cfw=>compute_metric_from_dynp( metric = cl_gui_control=>metric_pixel
                                                     x_or_y = 'X'
                                                     in     = 6 ).
      inner_splitter_top->set_column_width( id    = 2
                                            width = pixels ).
      inner_splitter_top->set_column_sash( id    = 1
                                           type  = cl_gui_splitter_container=>type_sashvisible
                                           value = cl_gui_splitter_container=>false ).
      inner_splitter_top->set_column_sash( id    = 1
                                           type  = cl_gui_splitter_container=>type_movable
                                           value = cl_gui_splitter_container=>false ).

      pixels = cl_gui_cfw=>compute_metric_from_dynp( metric = cl_gui_control=>metric_pixel
                                                     x_or_y = 'Y'
                                                     in     = 1 ).
      splitter->set_row_height( id     = 1
                                height = pixels ).
      splitter->set_row_sash( id    = 1
                              type  = cl_gui_splitter_container=>type_sashvisible
                              value = cl_gui_splitter_container=>false ).
      splitter->set_row_sash( id    = 1
                              type  = cl_gui_splitter_container=>type_movable
                              value = cl_gui_splitter_container=>false ).

      pixels = cl_gui_cfw=>compute_metric_from_dynp( metric = cl_gui_control=>metric_pixel
                                                     x_or_y = 'Y'
                                                     in     = 1 ).
      splitter->set_row_height( id     = 2
                                height = pixels ).
      splitter->set_row_sash( id    = 2
                              type  = cl_gui_splitter_container=>type_sashvisible
                              value = cl_gui_splitter_container=>false ).
      splitter->set_row_sash( id    = 2
                              type  = cl_gui_splitter_container=>type_movable
                              value = cl_gui_splitter_container=>false ).

      pixels = cl_gui_cfw=>compute_metric_from_dynp( metric = cl_gui_control=>metric_pixel
                                                     x_or_y = 'Y'
                                                     in     = 10 ).
      splitter->set_row_height( id     = 3
                                height = pixels ).
      splitter->set_row_sash( id    = 3
                              type  = cl_gui_splitter_container=>type_sashvisible
                              value = cl_gui_splitter_container=>true ).
      splitter->set_row_sash( id    = 3
                              type  = cl_gui_splitter_container=>type_movable
                              value = cl_gui_splitter_container=>true ).

      " For unkown reasons this is very buggy? 4 may not be set to invisible, otherwise 3 will also disappear. 4 is
      " invisible anyways apparently.
*      splitter->set_row_sash(
*          id    = 4
*          type  = cl_gui_splitter_container=>type_sashvisible
*          value = cl_gui_splitter_container=>false ).
      splitter->set_row_sash( id    = 4
                              type  = cl_gui_splitter_container=>type_movable
                              value = cl_gui_splitter_container=>false ).

      pixels = cl_gui_cfw=>compute_metric_from_dynp( metric = cl_gui_control=>metric_pixel
                                                     x_or_y = 'Y'
                                                     in     = 1 ).
      splitter->set_row_height( id     = 5
                                height = pixels ).

      DATA(dd) = NEW cl_dd_document( no_margins = abap_true ).

      DATA(file_system_description) = file_system->get_description( ).
      IF file_system_description IS INITIAL.
        file_system_description = replace( val  = cl_abap_classdescr=>get_class_name( file_system )
                                           sub  = '\CLASS='
                                           with = space
                                           occ  = 1 ).
      ENDIF.

      dd->add_text( text = 'File System:' sap_fontsize = cl_dd_area=>small ).
      dd->add_text( text = CONV #( file_system_description ) sap_fontsize = cl_dd_area=>small ).

      TRY.
          DATA(connection_info) = file_system->get_connection_info( ).

          IF connection_info-user IS NOT INITIAL.
            dd->add_gap( width = 2 ).
            dd->add_text( text = 'User:' sap_fontsize = cl_dd_area=>small ).
            dd->add_text( text = CONV #( connection_info-user ) sap_fontsize = cl_dd_area=>small ).
          ENDIF.

          IF connection_info-host IS NOT INITIAL.
            dd->add_gap( width = 2 ).
            dd->add_text( text = 'Host:' sap_fontsize = cl_dd_area=>small ).
            dd->add_text( text = CONV #( connection_info-host ) sap_fontsize = cl_dd_area=>small ).
          ENDIF.

          IF connection_info-protocol IS NOT INITIAL.
            dd->add_gap( width = 2 ).
            dd->add_text( text = 'Protocol:' sap_fontsize = cl_dd_area=>small ).
            dd->add_text( text = CONV #( connection_info-protocol ) sap_fontsize = cl_dd_area=>small ).
          ENDIF.
        CATCH zfloppy_frontend_fs_exception ##NEEDED.
      ENDTRY.

      dd->merge_document( ).
      dd->display_document( parent = inner_splitter_top->get_container( row = 1 column = 1 ) ).

      toolbar = NEW cl_gui_toolbar( parent      = inner_splitter_top->get_container( row    = 1
                                                                                     column = 2 )
*                                    shellstyle  =
*                                    lifetime    =
*                                    display_mode = m_mode_horizontal
*                                    name        =
                                    align_right = 1 ).
      toolbar->add_button_group( VALUE #( ( function = 'OPT' icon = icon_settings butn_type = cntb_btype_dropdown ) ) ).
    ENDIF.

    IF path_input IS NOT BOUND.
      path_input = NEW cl_gui_input_field( parent               = splitter->get_container( row    = 2
                                                                                           column = 1 )
                                           label_text           = 'Current Path:'
                                           activate_history     = abap_true
                                           activate_find_button = abap_true
                                           button_icon_info     = icon_other_object
                                           button_tooltip_info  = 'Change Path' ).
      path_input->set_text( current_directory->path ).

      SET HANDLER on_path_input_submit FOR path_input.
    ELSE.
      path_input->set_text( current_directory->path ).
    ENDIF.

    IF directory_listing IS NOT BOUND.
      directory_listing = NEW zfloppy_dir_listing_control(
                                  parent          = splitter->get_container( row    = 4
                                                                             column = 1 )
                                  file_system     = file_system
                                  directory       = current_directory
                                  display_options = actual_display_options-directory_listing_options ).
      SET HANDLER on_change_directory_requ_list FOR directory_listing.
      SET HANDLER on_open_file_requested FOR directory_listing.
      directory_listing->display( ).
    ELSE.
      directory_listing->set_current_directory( current_directory ).
      directory_listing->refresh( ).
    ENDIF.

    DATA(file_count) = REDUCE #(
        INIT count = 0
        FOR file IN directory_listing->directory_listing
        WHERE ( is_directory = abap_false )
        NEXT count = count + 1 ).
    DATA(directory_count) = REDUCE #(
        INIT count = 0
        FOR file IN directory_listing->directory_listing
        WHERE ( is_directory = abap_true AND is_virtual_directory = abap_false )
        NEXT count = count + 1 ).

    IF status_bar IS NOT BOUND.
      status_bar = NEW #( splitter->get_container( row    = 5
                                                   column = 1 ) ).
      status_bar->set_directory_count( directory_count ).
      status_bar->set_file_count( file_count ).
      status_bar->display( ).
    ELSE.
      status_bar->set_directory_count( directory_count ).
      status_bar->set_file_count( file_count ).
      status_bar->refresh( ).
    ENDIF.

    IF directory_tree IS NOT BOUND.
      directory_tree = NEW zfloppy_directory_tree_control( parent      = splitter->get_container( row    = 3
                                                                                                  column = 1 )
                                                           file_system = file_system
                                                           directory   = current_directory ).
      SET HANDLER on_change_directory_requ_tree FOR directory_tree.
      directory_tree->display( ).
    ELSE.
      directory_tree->set_current_directory( current_directory ).
      directory_tree->refresh( ).
    ENDIF.
  ENDMETHOD.

  METHOD on_path_input_submit.
    current_directory = zfloppy_path=>from_string(
                            path      = input
                            path_kind = zfloppy_path_kind_enum=>from_separator( file_system->get_separator( ) ) ).
    refresh_ui( ).
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.

  METHOD on_change_directory_requ_list.
    current_directory = directory.
    refresh_ui( ).
  ENDMETHOD.

  METHOD on_change_directory_requ_tree.
    current_directory = directory.
    refresh_ui( ).
  ENDMETHOD.

  METHOD on_open_file_requested.
    RAISE EVENT open_file_requested
          EXPORTING
            path        = path
            file_system = file_system.
  ENDMETHOD.
ENDCLASS.
