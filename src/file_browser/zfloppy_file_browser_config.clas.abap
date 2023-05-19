CLASS zfloppy_file_browser_config DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      file_systems TYPE STANDARD TABLE OF REF TO zfloppy_file_system WITH EMPTY KEY,
      BEGIN OF browser_configuration,
        file_systems TYPE file_systems,
      END OF browser_configuration.

    DATA configuration TYPE browser_configuration READ-ONLY.

    CLASS-METHODS get_default_configuration RETURNING VALUE(result) TYPE REF TO zfloppy_file_browser_config.

    METHODS constructor IMPORTING configuration TYPE browser_configuration.
ENDCLASS.


CLASS zfloppy_file_browser_config IMPLEMENTATION.
  METHOD get_default_configuration.
    result = NEW #( VALUE #(
        file_systems = VALUE #( FOR target IN zfloppy_target_server_enum=>get_instances( )
                                ( zfloppy_file_system_factory=>get_fs_for_target_server( target ) ) ) ) ).
  ENDMETHOD.

  METHOD constructor.
    me->configuration = configuration.
  ENDMETHOD.
ENDCLASS.
