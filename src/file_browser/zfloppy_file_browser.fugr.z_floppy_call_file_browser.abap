FUNCTION z_floppy_call_file_browser.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(CONFIGURATION) TYPE REF TO
*"        ZFLOPPY_FILE_BROWSER_CONFIG OPTIONAL
*"----------------------------------------------------------------------
  main=>initialization( ).
  CALL SELECTION-SCREEN 2000.
  IF sy-subrc = 0.
    main = NEW #( ).
    main->run( ).
  ENDIF.
ENDFUNCTION.
