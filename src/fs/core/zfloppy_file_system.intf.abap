"! <p class="shorttext synchronized">File System</p>
"!
"! <p>Implementations of this interface provide direct access to a concrete file system. The methods with the exception
"! {@link zfloppy_fs_unsupp_operation} are optional. If no implementation can be provided the mentioned exception should
"! be thrown. Any implementation should provide the corresponding information which features it supports in the method
"! {@link zfloppy_file_system.METH:get_supported_methods} in order for generic use cases to work.
"! Any error in the implementation should throw {@link zfloppy_file_system_exception} or a corresponding
"! subclass for that file system.</p>
"!
"! <p>Do note that additional interfaces exist like {@link zfloppy_fs_partial_reader} and
"! {@link zfloppy_fs_partial_writer} for additional features.</p>
INTERFACE zfloppy_file_system PUBLIC.
  TYPES:
    file_info_tab TYPE STANDARD TABLE OF file_info WITH KEY filename,
    separator     TYPE c LENGTH 1,
    BEGIN OF connection_info,
      user     TYPE string,
      host     TYPE string,
      protocol TYPE string,
    END OF connection_info.
  METHODS: get_supported_methods RETURNING VALUE(result) TYPE zfloppy_fs_method_enum=>instances,
           get_description       RETURNING VALUE(result) TYPE string,

    file_exists IMPORTING !path         TYPE csequence
                RETURNING VALUE(result) TYPE abap_bool
                RAISING   zfloppy_fs_unsupp_operation
                          zfloppy_file_system_exception,

    read_file_bin IMPORTING !path         TYPE csequence
                  RETURNING VALUE(result) TYPE xstring
                  RAISING   zfloppy_fs_unsupp_operation
                            zfloppy_file_system_exception,

    read_file_text IMPORTING !path         TYPE csequence
                             codepage      TYPE cpcodepage
                   RETURNING VALUE(result) TYPE string
                   RAISING   zfloppy_fs_unsupp_operation
                             zfloppy_file_system_exception,

    write_file_bin IMPORTING !path   TYPE csequence
                             content TYPE xsequence
                   RAISING   zfloppy_fs_unsupp_operation
                             zfloppy_file_system_exception,

    get_directory_contents IMPORTING !path         TYPE csequence
                           RETURNING VALUE(result) TYPE file_info_tab
                           RAISING   zfloppy_fs_unsupp_operation
                                     zfloppy_file_system_exception,

    create_directory IMPORTING !path TYPE csequence
                     RAISING   zfloppy_fs_unsupp_operation
                               zfloppy_file_system_exception,

    delete_directory IMPORTING !path TYPE csequence
                     RAISING   zfloppy_fs_unsupp_operation
                               zfloppy_file_system_exception,

    get_default_codepage RETURNING VALUE(result) TYPE cpcodepage
                         RAISING   zfloppy_fs_unsupp_operation
                                   zfloppy_file_system_exception,

    get_separator RETURNING VALUE(result) TYPE separator
                  RAISING   zfloppy_fs_unsupp_operation
                            zfloppy_file_system_exception,

    get_connection_info RETURNING VALUE(result) TYPE connection_info
                        RAISING   zfloppy_fs_unsupp_operation
                                  zfloppy_file_system_exception.
ENDINTERFACE.
