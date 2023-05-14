"! <p class="shorttext synchronized" lang="en">File System Factory</p>
CLASS zfloppy_file_system_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      get_fs_for_target_server IMPORTING target_server TYPE REF TO zfloppy_target_server_enum
                               RETURNING VALUE(result) TYPE REF TO zfloppy_file_system
                               RAISING   zfloppy_file_system_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF cache_line,
        target_server TYPE REF TO zfloppy_target_server_enum,
        file_system   TYPE REF TO zfloppy_file_system,
      END OF cache_line.
    CLASS-DATA:
      cache TYPE HASHED TABLE OF cache_line WITH UNIQUE KEY target_server.
ENDCLASS.



CLASS zfloppy_file_system_factory IMPLEMENTATION.
  METHOD get_fs_for_target_server.
    READ TABLE cache WITH TABLE KEY target_server = target_server REFERENCE INTO DATA(cache_line).
    IF sy-subrc = 0.
      result = cache_line->file_system.
      RETURN.
    ENDIF.

    CASE target_server.
      WHEN zfloppy_target_server_enum=>backend.
        result = NEW zfloppy_backend_fs_impl( NEW zfloppy_dataset_api_impl( ) ).
      WHEN zfloppy_target_server_enum=>frontend.
        result = NEW zfloppy_frontend_fs_impl( NEW zfloppy_frontend_services_impl( ) ).
    ENDCASE.

    IF result IS NOT BOUND.
      RAISE EXCEPTION NEW zfloppy_file_system_exception( ).
    ENDIF.

    INSERT VALUE #(
        target_server = target_server
        file_system   = result
    ) INTO TABLE cache.
    ASSERT sy-subrc = 0.
  ENDMETHOD.
ENDCLASS.
