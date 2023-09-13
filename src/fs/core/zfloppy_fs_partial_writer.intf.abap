"! <p class="shorttext synchronized">File System with Partial Write Support</p>
INTERFACE zfloppy_fs_partial_writer PUBLIC.
  METHODS:
    write_buffer_to_file_bin IMPORTING !offset TYPE i DEFAULT 0
                                       !length TYPE i DEFAULT -1
                                       !buffer TYPE xsequence
                             RAISING   zfloppy_fs_unsupp_operation
                                       zfloppy_file_system_exception,

    write_buffer_to_file_text IMPORTING !offset TYPE i DEFAULT 0
                                        !length TYPE i DEFAULT -1
                                        !buffer TYPE csequence
                              RAISING   zfloppy_fs_unsupp_operation
                                        zfloppy_file_system_exception,

    append_text_to_file IMPORTING !path    TYPE csequence
                                  codepage TYPE cpcodepage
                                  !content TYPE csequence
                        RAISING   zfloppy_fs_unsupp_operation
                                  zfloppy_file_system_exception.
ENDINTERFACE.
