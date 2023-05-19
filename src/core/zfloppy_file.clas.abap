"! <p class="shorttext synchronized">File</p>
CLASS zfloppy_file DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! Create an instance for a file on the file system of the application server
    "! @parameter path                          | Full path to the file
    "! @parameter result                        | Created instance
    "! @raising   zfloppy_file_system_exception | Error retrieving the file system instance
    CLASS-METHODS for_backend IMPORTING !path         TYPE csequence
                              RETURNING VALUE(result) TYPE REF TO zfloppy_file
                              RAISING   zfloppy_file_system_exception.

    "! Create an instance for a file on the file system of the frontend server
    "! @parameter path                          | Full path to the file
    "! @parameter result                        | Created instance
    "! @raising   zfloppy_file_system_exception | Error retrieving the file system instance
    CLASS-METHODS for_frontend IMPORTING !path         TYPE csequence
                               RETURNING VALUE(result) TYPE REF TO zfloppy_file
                               RAISING   zfloppy_file_system_exception.

    "! Create an instance for a target server (frontend / backend)
    "! @parameter target_server                 | Target server
    "! @parameter path                          | Full path to the file
    "! @parameter result                        | Created instance
    "! @raising   zfloppy_file_system_exception | Error retrieving the file system instance
    CLASS-METHODS for_target_server IMPORTING target_server TYPE REF TO zfloppy_target_server_enum
                                              !path         TYPE csequence
                                    RETURNING VALUE(result) TYPE REF TO zfloppy_file
                                    RAISING   zfloppy_file_system_exception.

    "! Create an instance for any file system
    "! @parameter file_system | File system
    "! @parameter path        | Full path to the file
    "! @parameter result      | Created instance
    CLASS-METHODS for_file_system IMPORTING file_system   TYPE REF TO zfloppy_file_system
                                            !path         TYPE csequence
                                  RETURNING VALUE(result) TYPE REF TO zfloppy_file.

    "! Get the full path to the file
    "! @parameter result | Full path
    METHODS get_path RETURNING VALUE(result) TYPE REF TO zfloppy_path.

    "! Check if file exists
    "! @parameter result                        | File exists
    "! @raising   zfloppy_file_system_exception | Error in file system
    METHODS exists RETURNING VALUE(result) TYPE abap_bool
                   RAISING   zfloppy_file_system_exception.

    "! Create empty file if it doesn not exist
    "! @raising zfloppy_file_system_exception | Error in file system
    METHODS touch RAISING zfloppy_file_system_exception.

    "! Sets the codepage used for text based operations
    "!
    "! <p>This is only used if the codepage parameter of the method providing access to the operation is initial.</p>
    "!
    "! @parameter codepage                   | Codepage
    "! @raising   zfloppy_codepage_exception | Codepage error
    METHODS set_current_codepage IMPORTING codepage TYPE cpcodepage
                                 RAISING   zfloppy_codepage_exception.

    "! Gets the codepage used for text based operations
    "!
    "! <p>{@link .METH:get_current_codepage.DATA:result} may be initial if {@link .METH:set_current_codepage} has not
    "! been called and no call to the file system implementation has yet been made to get the default codepage.</p>
    "!
    "! @parameter result | Current codepage
    METHODS get_current_codepage RETURNING VALUE(result) TYPE cpcodepage.

    METHODS append_text IMPORTING codepage TYPE cpcodepage OPTIONAL
                                  !text    TYPE csequence
                        RAISING   zfloppy_file_system_exception
                                  zfloppy_codepage_exception.

    METHODS get_input_stream.
    METHODS get_output_stream.

    METHODS read_all_content_as_text IMPORTING codepage      TYPE cpcodepage OPTIONAL
                                     RETURNING VALUE(result) TYPE string
                                     RAISING   zfloppy_file_system_exception
                                               zfloppy_codepage_exception.

    METHODS read_all_content_as_binary RETURNING VALUE(result) TYPE xstring
                                       RAISING   zfloppy_file_system_exception.

  PRIVATE SECTION.
    DATA file_system      TYPE REF TO zfloppy_file_system.
    DATA path             TYPE REF TO zfloppy_path.
    DATA current_codepage TYPE cpcodepage.

    METHODS constructor IMPORTING !path       TYPE csequence
                                  file_system TYPE REF TO zfloppy_file_system.

    METHODS determine_codepage_to_use IMPORTING method_parameter_cp TYPE cpcodepage
                                      RETURNING VALUE(result)       TYPE cpcodepage
                                      RAISING   zfloppy_codepage_exception.
ENDCLASS.


CLASS zfloppy_file IMPLEMENTATION.
  METHOD for_backend.
    result = for_target_server( target_server = zfloppy_target_server_enum=>backend
                                path          = path ).
  ENDMETHOD.

  METHOD for_frontend.
    result = for_target_server( target_server = zfloppy_target_server_enum=>frontend
                                path          = path ).
  ENDMETHOD.

  METHOD for_target_server.
    result = for_file_system( file_system = zfloppy_file_system_factory=>get_fs_for_target_server( target_server )
                              path        = path ).
  ENDMETHOD.

  METHOD for_file_system.
    result = NEW #( path        = path
                    file_system = file_system ).
  ENDMETHOD.

  METHOD constructor.
    me->path        = zfloppy_path=>from_string(
                          path      = path
                          path_kind = zfloppy_path_kind_enum=>from_separator( file_system->get_separator( ) ) ).
    me->file_system = file_system.
  ENDMETHOD.

  METHOD determine_codepage_to_use.
    IF method_parameter_cp IS NOT INITIAL.
      result = method_parameter_cp.
      RETURN.
    ENDIF.

    IF current_codepage IS INITIAL.
      current_codepage = file_system->get_default_codepage( ).
    ENDIF.

    result = current_codepage.
  ENDMETHOD.

  METHOD get_path.
    result = path.
  ENDMETHOD.

  METHOD exists.
    result = file_system->file_exists( path->path ).
  ENDMETHOD.

  METHOD touch.
    DATA empty_content TYPE xstring VALUE IS INITIAL.

    IF exists( ).
      RETURN.
    ENDIF.

    file_system->write_file_bin( path    = path->path
                                 content = empty_content ).
  ENDMETHOD.

  METHOD set_current_codepage.
    current_codepage = codepage.
  ENDMETHOD.

  METHOD get_current_codepage.
    result = current_codepage.
  ENDMETHOD.

  METHOD append_text.
    ##TODO. " Ask the file system if it supports append and use that, fallback to this
*    file_system->append_file_text
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(content) = file_system->read_file_text( path     = path->path
                                                 codepage = determine_codepage_to_use( codepage ) ).

    content = content && text && |\n|.

*    file_system->write_file_text(
*
*    ).
*    CATCH zfloppy_fs_unsupp_operation.
*    CATCH zfloppy_file_system_exception.
  ENDMETHOD.

  METHOD get_input_stream.
  ENDMETHOD.

  METHOD get_output_stream.
  ENDMETHOD.

  METHOD read_all_content_as_binary.
    result = file_system->read_file_bin( path->path ).
  ENDMETHOD.

  METHOD read_all_content_as_text.
    result = file_system->read_file_text( path     = path->path
                                          codepage = determine_codepage_to_use( codepage ) ).
  ENDMETHOD.
ENDCLASS.
