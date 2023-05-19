"! <p class="shorttext synchronized">Directory Tree Control</p>
"!
"! <p>This is a control to display a path to a directory in a Tree ALV. The initial node tree is created based on
"! the starting directory. Subdirectories are added by accessing the file system. On navigation in the tree other nodes
"! will also get subfolders added when they either become the current directory or the node expand event is triggered.
"! When changing the current directory to a node that already has subnodes these are checked for being up to date.</p>
"!
"! <p>Note the current directory is not changed automatically on selection but rather
"! {@link zfloppy_directory_tree_control.EVNT:change_directory_requested} is raised and the caller may choose to change
"! it then using {@link zfloppy_directory_tree_control.METH:set_current_directory}.</p>
CLASS zfloppy_directory_tree_control DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    EVENTS change_directory_requested EXPORTING VALUE(directory) TYPE REF TO zfloppy_path.

    METHODS constructor IMPORTING !parent     TYPE REF TO cl_gui_container
                                  file_system TYPE REF TO zfloppy_file_system
                                  !directory  TYPE REF TO zfloppy_path.

    METHODS display RAISING zfloppy_control_exception.

    METHODS refresh IMPORTING full_rebuild TYPE abap_bool DEFAULT abap_false
                    RAISING   zfloppy_control_exception.

    METHODS get_current_directory RETURNING VALUE(result) TYPE REF TO zfloppy_path.
    METHODS set_current_directory IMPORTING !directory    TYPE REF TO zfloppy_path.
    METHODS free.

  PRIVATE SECTION.
    DATA parent              TYPE REF TO cl_gui_container.
    DATA file_system         TYPE REF TO zfloppy_file_system.
    DATA current_directory   TYPE REF TO zfloppy_path.
    DATA directory_hierarchy TYPE STANDARD TABLE OF zfloppy_directory_tree_out.
    DATA tree                TYPE REF TO cl_salv_tree.
    DATA root_node           TYPE REF TO cl_salv_node.

    METHODS refresh_tree_nodes IMPORTING full_rebuild TYPE abap_bool DEFAULT abap_false
                               RAISING   cx_salv_error.

    METHODS get_children_of_node IMPORTING !node                TYPE REF TO cl_salv_node
                                           only_direct_children TYPE abap_bool DEFAULT abap_true
                                 RETURNING VALUE(result)        TYPE salv_t_nodes.

    METHODS on_expand_empty_folder FOR EVENT expand_empty_folder OF if_salv_events_tree IMPORTING node_key.
    METHODS on_double_click FOR EVENT double_click OF if_salv_events_tree        IMPORTING node_key.
ENDCLASS.


CLASS zfloppy_directory_tree_control IMPLEMENTATION.
  METHOD constructor.
    me->parent      = parent.
    me->file_system = file_system.
    current_directory = directory.
  ENDMETHOD.

  METHOD display.
    IF tree IS BOUND.
      RETURN.
    ENDIF.

    TRY.
        cl_salv_tree=>factory( EXPORTING r_container = parent
                                         hide_header = abap_true
                               IMPORTING r_salv_tree = tree
                               CHANGING  t_table     = directory_hierarchy ).

        DATA(tree_settings) = tree->get_tree_settings( ).
        tree_settings->set_hierarchy_icon( CONV #( icon_folder ) ).
        tree_settings->set_hierarchy_header( 'Directory Hierarchy' ).

        SET HANDLER on_expand_empty_folder FOR tree->get_event( ).
        SET HANDLER on_double_click FOR tree->get_event( ).

        LOOP AT tree->get_columns( )->get( ) REFERENCE INTO DATA(column).
          column->r_column->set_visible( abap_false ).
        ENDLOOP.
        refresh_tree_nodes( abap_false ).
        tree->display( ).

      CATCH cx_salv_error INTO DATA(exception).
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
        refresh_tree_nodes( full_rebuild ).
        tree->display( ).
      CATCH cx_salv_error INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_control_exception
              MESSAGE ID sy-msgid
              NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              EXPORTING
                previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_current_directory.
    result = current_directory.
  ENDMETHOD.

  METHOD set_current_directory.
    current_directory = directory.
  ENDMETHOD.

  METHOD free.
    CLEAR directory_hierarchy.
    FREE tree. " Cannot actually call free on the underlying control :/
    FREE root_node.
  ENDMETHOD.

  METHOD refresh_tree_nodes.
    DATA current_node TYPE REF TO cl_salv_node.
    DATA child        TYPE REF TO salv_s_nodes.

    " Traverse the current node tree for the current path to see if it (still) matches. If nodes are missing, add them.
    " Also check the current level for new or missing directories.

    DATA(nodes) = tree->get_nodes( ).
    DATA(selections) = tree->get_selections( ).
    DATA(components) = current_directory->get_path_components( ).

    " Special handling for root directory
    IF current_directory->path_kind = zfloppy_path_kind_enum=>windows.
      components[ 1 ] = components[ 1 ] && current_directory->path_kind->separator.
    ELSE.
      INSERT current_directory->path_kind->separator INTO components INDEX 1.
    ENDIF.

    TRY.
*        current_node = nodes->get_top_node( ).
        " This is buggy for some reason and after several navigation steps return a random node?!
        " Keep memory of root node ourselves for now
        current_node = root_node.
      CATCH cx_salv_error.
    ENDTRY.

    DATA(current_component_index) = 1.
    DATA(found) = abap_false.

    WHILE current_component_index <= lines( components ).
      found = abap_false.

      DATA(component) = REF #( components[ current_component_index ] ).

      IF current_node IS NOT BOUND.
        current_node = nodes->add_node( related_node = space
                                        relationship = if_salv_c_node_relation=>last_child
                                        data_row     = VALUE zfloppy_directory_tree_out( directory = component->* )
                                        text         = CONV #( component->* )
                                        expander     = abap_true
                                        folder       = abap_true ).
        root_node = current_node.
      ENDIF.

      IF current_component_index = 1.
        found = abap_true.

        IF    CAST zfloppy_directory_tree_out( current_node->get_data_row( ) )->directory <> component->*
           OR full_rebuild = abap_true.
          " root is invalid, update and delete children

          LOOP AT get_children_of_node( current_node ) REFERENCE INTO child.
            child->node->delete( ).
          ENDLOOP.

          current_node->set_text( CONV #( component->* ) ).
          current_node->set_data_row( VALUE zfloppy_directory_tree_out( directory = component->* ) ).
        ENDIF.
      ELSE.
        LOOP AT get_children_of_node( current_node ) REFERENCE INTO child.
          IF CAST zfloppy_directory_tree_out( child->node->get_data_row( ) )->directory = component->*.
            current_node = child->node.
            found = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF found = abap_false.
        current_node = nodes->add_node( related_node = current_node->get_key( )
                                        relationship = if_salv_c_node_relation=>last_child
                                        data_row     = VALUE zfloppy_directory_tree_out( directory = component->* )
                                        text         = CONV #( component->* )
                                        expander     = abap_true
                                        folder       = abap_true ).
      ENDIF.

      current_component_index += 1.
    ENDWHILE.

    selections->set_selected_nodes( VALUE #( ( key = current_node->get_key( ) node = current_node ) ) ).

*    DATA(current_directory_listing) = directory_listing.
*    DELETE current_directory_listing WHERE filename = '..' OR is_directory = abap_false ##TODO. " Refactor
*
*    LOOP AT get_children_of_node( current_node ) REFERENCE INTO child.
*      DATA(current_listing_index) = line_index( current_directory_listing[
*           is_directory = abap_true
*           filename     = child->node->get_text( ) ] ).
*      IF current_listing_index IS NOT INITIAL.
*        " Directory still exists
*        DELETE current_directory_listing INDEX current_listing_index.
*      ELSE.
*        " Directory does not exist anymore, remove
*        child->node->delete( ).
*      ENDIF.
*    ENDLOOP.
*
*    " This should only contain new directories
*    LOOP AT current_directory_listing REFERENCE INTO DATA(new_directory).
*      nodes->add_node(
*        EXPORTING
*          related_node   = current_node->get_key( )
*          relationship   = if_salv_c_node_relation=>last_child
**              data_row       =
**              collapsed_icon =
**              expanded_icon  =
**              row_style      =
*          text           = CONV #( new_directory->filename )
**              visible        = abap_true
**              expander       =
**              enabled        = abap_true
**              folder         =
**            RECEIVING
**              node           =
*      ).
**          CATCH cx_salv_msg.
*    ENDLOOP.

    IF get_children_of_node( current_node ) IS NOT INITIAL.
      current_node->expand( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_children_of_node.
    TRY.
        IF only_direct_children = abap_true.
          result = node->get_children( ).
        ELSE.
          result = node->get_subtree( ).
        ENDIF.
      CATCH cx_salv_error ##NEEDED.
        " Methods raise an exception if there are no children for some reason
    ENDTRY.
  ENDMETHOD.

  METHOD on_expand_empty_folder.
  ENDMETHOD.

  METHOD on_double_click.
    DATA parent TYPE REF TO cl_salv_node.

    TRY.
        DATA(node) = tree->get_nodes( )->get_node( node_key ).

        DATA(path) = ``.
        DATA(separator) = file_system->get_separator( ).

        WHILE node IS BOUND.
          TRY.
              parent = node->get_parent( ).
            CATCH cx_salv_error.
              FREE parent.
          ENDTRY.

          path = CAST zfloppy_directory_tree_out( node->get_data_row( ) )->directory &&
                 COND string( WHEN parent IS BOUND THEN separator ELSE '' )
                 && path.

          node = parent.
        ENDWHILE.

        DATA(directory) = zfloppy_path=>from_string(
                              path      = path
                              path_kind = zfloppy_path_kind_enum=>from_separator( file_system->get_separator( ) ) ).
        RAISE EVENT change_directory_requested
              EXPORTING
                directory = directory.
      CATCH cx_salv_error
            zfloppy_exception INTO DATA(exception). " TODO: variable is assigned but never used (ABAP cleaner)

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
