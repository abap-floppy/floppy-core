CLASS screen_base IMPLEMENTATION.
  METHOD call.
    DATA(dynpro) = get_dynpro_number( ).
    RAISE EVENT screen_called.
    CALL SCREEN dynpro.
  ENDMETHOD.

  METHOD pai.
  ENDMETHOD.

  METHOD pbo.
  ENDMETHOD.

  METHOD leave.
    RAISE EVENT leaving_screen.
    free( ).
    LEAVE TO SCREEN 0.
  ENDMETHOD.

  METHOD free.
  ENDMETHOD.
ENDCLASS.

CLASS file_browser_screen IMPLEMENTATION.
  METHOD get_dynpro_number.
    result = dynnr.
  ENDMETHOD.

  METHOD pai.
    CASE user_command.
      WHEN user_commands-back OR
           user_commands-cancel OR
           user_commands-exit.
        leave( ).
      WHEN user_commands-refresh.
*        file_browser->
    ENDCASE.
  ENDMETHOD.

  METHOD pbo.
    SET TITLEBAR title.
    SET PF-STATUS status.

    IF container IS NOT BOUND.
      container = NEW cl_gui_custom_container( container_name ).
      DATA(file_system) = zfloppy_file_system_factory=>get_fs_for_target_server(
          zfloppy_target_server_enum=>from_value( p_fs ) ).
*
      DATA(directory) = zfloppy_path=>from_string(
          path      = p_dir
          path_kind = zfloppy_path_kind_enum=>from_separator( file_system->get_separator( ) ) ).

*      DATA(file_system) = NEW zfloppy_tdc_file_system( ).
*      DATA(directory) = zfloppy_path=>from_string( path = '/' path_kind = zfloppy_path_kind_enum=>unix ).
      file_browser = NEW zfloppy_file_browser_control(
          parent          = container
          file_system     = file_system
          directory       = directory
          display_options = VALUE #(
                               BASE zfloppy_file_browser_control=>get_default_display_options( )
                               directory_listing_options = VALUE #(
                                   layout_save_allowed     = abap_true
                                   default_layout_allowed  = abap_true
                                   layout_save_restriction = if_salv_c_layout=>restrict_none
                                   layout_key              = VALUE #(
                                       report        = sy-repid
                                       logical_group = '0001' ) ) ) ).
      SET HANDLER on_open_file_requested FOR file_browser.
      file_browser->display( ).
    ELSE.
*      file_browser->
    ENDIF.
  ENDMETHOD.

  METHOD on_open_file_requested.
    DATA(file) = zfloppy_file=>for_file_system(
       file_system = file_system
       path        = path->path ) ##TODO.
    NEW file_display_screen( file )->call( ).
  ENDMETHOD.
ENDCLASS.

CLASS file_display_screen IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->file = file.
  ENDMETHOD.

  METHOD get_dynpro_number.
    result = dynnr.
  ENDMETHOD.

  METHOD pai.
    CASE user_command.
      WHEN user_commands-back OR
           user_commands-cancel OR
           user_commands-exit.
        leave( ).
    ENDCASE.
  ENDMETHOD.

  METHOD pbo.
    SET PF-STATUS status.
    DATA(filename) = file->get_path( )->get_filename( ).
    SET TITLEBAR title WITH filename.

    IF container IS NOT BOUND.
      container = NEW cl_gui_custom_container( container_name ).


      TRY.
          ##TODO. " Add option for line endings and codepage

          DATA(content) = escape( val    = file->read_all_content_as_text( )
                                  format = cl_abap_format=>e_html_text ).

          editor = NEW cl_gui_textedit(
            style                      = cl_gui_textedit=>ws_visible + cl_gui_textedit=>ws_child
            wordwrap_mode              = cl_gui_textedit=>wordwrap_off
            parent                     = container
            lifetime                   = cl_gui_textedit=>lifetime_dynpro ).
          editor->set_textstream( content ).
          editor->set_readonly_mode( cl_gui_textedit=>true ).
          editor->set_font_fixed( cl_gui_textedit=>true ).

*          editor->
*          DATA(html) = |<pre>{ content }</pre>|.
*
*          ##TODO. " Refactor to use monospace font, cl_gui_resources does not seem to offer a fitting method
*          document = NEW cl_dd_document( ).
*          document->add_static_html( string_with_html = html ).
*          document->display_document(
*            EXPORTING
*              reuse_control      = abap_true
*              reuse_registration = abap_true
*              parent             = container
*            EXCEPTIONS
*              html_display_error = 1
*              OTHERS             = 2 ).
*          IF sy-subrc <> 0.
*            RAISE EXCEPTION TYPE zfloppy_control_exception
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.


        CATCH zfloppy_exception INTO DATA(exception).
          MESSAGE exception TYPE 'I' DISPLAY LIKE 'E'.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD free.
    IF editor IS BOUND.
      editor->free( ).
      FREE editor.
    ENDIF.
    IF container IS BOUND.
      container->free( ).
      FREE container.
    ENDIF.
    FREE file.
  ENDMETHOD.

ENDCLASS.

CLASS screen_stack IMPLEMENTATION.
  METHOD push.
    INSERT screen INTO stack INDEX 1.
    result = peek( ).
  ENDMETHOD.

  METHOD pop.
    DELETE stack INDEX 1.
    result = peek( ).
  ENDMETHOD.

  METHOD peek.
    IF stack IS INITIAL.
      RETURN.
    ENDIF.

    result = stack[ 1 ].
  ENDMETHOD.
ENDCLASS.

CLASS main IMPLEMENTATION.
  METHOD initialization.
    cl_gui_frontend_services=>get_sapgui_workdir(
      CHANGING
        sapworkdir            = p_dir
      EXCEPTIONS
        get_sapworkdir_failed = 1
        cntl_error            = 2
        error_no_gui          = 3
        not_supported_by_gui  = 4
        OTHERS                = 5 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    cl_gui_cfw=>flush( ).
    p_fs = zfloppy_target_server_enum=>frontend->value.
  ENDMETHOD.

  METHOD at_selection_screen_output.
    SET TITLEBAR '0100'.
  ENDMETHOD.

  METHOD constructor.
    screen_stack = NEW #( ).
    SET HANDLER on_leaving_screen FOR ALL INSTANCES.
    SET HANDLER on_screen_called FOR ALL INSTANCES.
  ENDMETHOD.

  METHOD run.
    NEW file_browser_screen( )->call( ).
  ENDMETHOD.

  METHOD pai.
    DATA(user_command) = me->user_command.
    CLEAR me->user_command.

    screen_stack->peek( )->pai( user_command ).
  ENDMETHOD.

  METHOD pbo.
    screen_stack->peek( )->pbo( ).
  ENDMETHOD.

  METHOD on_leaving_screen.
    ASSERT screen_stack->peek( ) = sender.
    screen_stack->pop( ).
  ENDMETHOD.

  METHOD on_screen_called.
    screen_stack->push( sender ).
  ENDMETHOD.
ENDCLASS.

CLASS transaction_code_helper IMPLEMENTATION.
  METHOD zfloppy_browser.
    main=>initialization( ).
    CALL SELECTION-SCREEN 2000.
    IF sy-subrc = 0.
      main = NEW #( ).
      main->run( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
