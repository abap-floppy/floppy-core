FUNCTION-POOL zfloppy_file_browser.

SELECTION-SCREEN BEGIN OF SCREEN 2000.
  PARAMETERS: p_fs  TYPE zfloppy_target_server AS LISTBOX VISIBLE LENGTH 40 OBLIGATORY,
              p_dir TYPE string LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 2000.

INCLUDE lzfloppy_file_browserd01.          " Local class definition

DATA main TYPE REF TO main.
