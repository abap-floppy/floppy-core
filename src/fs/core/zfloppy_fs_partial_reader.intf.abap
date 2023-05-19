INTERFACE zfloppy_fs_partial_reader PUBLIC.
  METHODS:
    read_file_to_buffer_bin IMPORTING !path         TYPE csequence
                                      !offset       TYPE i DEFAULT 0
                                      !length       TYPE i DEFAULT -1
                            EXPORTING VALUE(buffer) TYPE xsequence
                            RAISING   zfloppy_fs_unsupp_operation
                                      zfloppy_file_system_exception,

    read_file_to_buffer_text IMPORTING !path         TYPE csequence
                                       !offset       TYPE i DEFAULT 0
                                       !length       TYPE i DEFAULT -1
                             EXPORTING VALUE(buffer) TYPE data
                             RAISING   zfloppy_fs_unsupp_operation
                                       zfloppy_file_system_exception.
ENDINTERFACE.
