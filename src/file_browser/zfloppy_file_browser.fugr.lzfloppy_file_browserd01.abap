CLASS screen_base DEFINITION ABSTRACT.
  PUBLIC SECTION.
    EVENTS screen_called.
    EVENTS leaving_screen.

    METHODS call FINAL.
    METHODS pbo.
    METHODS pai IMPORTING user_command TYPE syst_ucomm.

  PROTECTED SECTION.
    METHODS get_dynpro_number ABSTRACT RETURNING VALUE(result) TYPE syst_dynnr.
    METHODS leave FINAL.
    METHODS free.
ENDCLASS.


CLASS file_browser_screen DEFINITION INHERITING FROM screen_base.
  PUBLIC SECTION.
    METHODS pai REDEFINITION.
    METHODS pbo REDEFINITION.

  PROTECTED SECTION.
    METHODS get_dynpro_number REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      dynnr          TYPE syst_dynnr VALUE '0100',
      status         TYPE sypfkey    VALUE '0100',
      title          TYPE gui_title  VALUE '0100',
      container_name TYPE scrfname   VALUE 'CONTAINER_0100',
      BEGIN OF user_commands,
        back         TYPE syst_ucomm VALUE 'BACK',
        cancel       TYPE syst_ucomm VALUE 'CANCEL',
        exit         TYPE syst_ucomm VALUE 'EXIT',
        refresh      TYPE syst_ucomm VALUE 'REFRESH',
      END OF user_commands.

    DATA container    TYPE REF TO cl_gui_container.
    DATA splitter     TYPE REF TO cl_gui_splitter_container.
    DATA file_browser TYPE REF TO zfloppy_file_browser_control.

    METHODS on_open_file_requested FOR EVENT open_file_requested OF zfloppy_file_browser_control IMPORTING !path file_system.
ENDCLASS.


CLASS file_display_screen DEFINITION INHERITING FROM screen_base.
  PUBLIC SECTION.
    METHODS constructor IMPORTING !file TYPE REF TO zfloppy_file.
    METHODS pai REDEFINITION.
    METHODS pbo REDEFINITION.

  PROTECTED SECTION.
    METHODS get_dynpro_number REDEFINITION.
    METHODS free              REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      dynnr          TYPE syst_dynnr VALUE '0200',
      status         TYPE sypfkey    VALUE '0200',
      title          TYPE gui_title  VALUE '0200',
      container_name TYPE scrfname   VALUE 'CONTAINER_0200',
      BEGIN OF user_commands,
        back         TYPE syst_ucomm VALUE 'BACK',
        cancel       TYPE syst_ucomm VALUE 'CANCEL',
        exit         TYPE syst_ucomm VALUE 'EXIT',
      END OF user_commands.

    DATA file      TYPE REF TO zfloppy_file.
    DATA container TYPE REF TO cl_gui_container.
    DATA editor    TYPE REF TO cl_gui_textedit.
ENDCLASS.


CLASS screen_stack DEFINITION.
  PUBLIC SECTION.
    METHODS push IMPORTING !screen       TYPE REF TO screen_base
                 RETURNING VALUE(result) TYPE REF TO screen_base.

    METHODS pop  RETURNING VALUE(result) TYPE REF TO screen_base.
    METHODS peek RETURNING VALUE(result) TYPE REF TO screen_base.

  PRIVATE SECTION.
    DATA stack TYPE STANDARD TABLE OF REF TO screen_base.
ENDCLASS.


CLASS main DEFINITION.
  PUBLIC SECTION.
    DATA user_command TYPE syst_ucomm.

    CLASS-METHODS initialization.
    CLASS-METHODS at_selection_screen_output.

    METHODS constructor.
    METHODS run.
    METHODS pai.
    METHODS pbo.

  PRIVATE SECTION.
    DATA screen_stack TYPE REF TO screen_stack.

    METHODS on_screen_called FOR EVENT screen_called OF screen_base  IMPORTING sender.
    METHODS on_leaving_screen FOR EVENT leaving_screen OF screen_base IMPORTING sender.
ENDCLASS.


CLASS transaction_code_helper DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS zfloppy_browser.
ENDCLASS.
