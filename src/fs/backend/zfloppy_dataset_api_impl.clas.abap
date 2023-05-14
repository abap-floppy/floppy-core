CLASS zfloppy_dataset_api_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      zfloppy_dataset_api.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zfloppy_dataset_api_impl IMPLEMENTATION.
  METHOD zfloppy_dataset_api~close_dataset.
    TRY.
        CLOSE DATASET dataset.
        DATA(return_code) = sy-subrc.

        IF return_code <> 0.
          RAISE EXCEPTION TYPE zfloppy_dataset_api_exception
            EXPORTING
              return_code = return_code.
        ENDIF.

      CATCH cx_sy_file_close INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_dataset_api_exception
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_dataset_api~delete_dataset.

  ENDMETHOD.

  METHOD zfloppy_dataset_api~get_dataset.
    GET DATASET dataset
        POSITION position
        ATTRIBUTES attributes.
  ENDMETHOD.

  METHOD zfloppy_dataset_api~open_dataset.
    DATA: message TYPE string.

    TRY.
        CASE access_type.
          WHEN zfloppy_dataset_api=>access_types-input.
            CASE mode.
              WHEN zfloppy_dataset_api=>modes-binary.
                IF ignore_conversion_errors <> abap_false.
*              RAISE ...
                ELSEIF replacement_character IS NOT INITIAL.
*              RAISE...
                ELSEIF mode_options IS NOT INITIAL.
*                RAISE...
                ENDIF.

                IF position IS NOT INITIAL AND os_additions-filter IS NOT INITIAL.
*              RAISE...
                ELSEIF position IS NOT INITIAL.
                  OPEN DATASET dataset
                      FOR INPUT
                      IN BINARY MODE
                      AT POSITION position
                      TYPE os_additions-type
                      MESSAGE message.
                ELSE.
                  OPEN DATASET dataset
                      FOR INPUT
                      IN BINARY MODE
                      TYPE os_additions-type
                      FILTER os_additions-filter
                      MESSAGE message.
                ENDIF.

              WHEN zfloppy_dataset_api=>modes-legacy_binary.
              WHEN zfloppy_dataset_api=>modes-text.
              WHEN zfloppy_dataset_api=>modes-legacy_text.
                OPEN DATASET dataset
                    FOR INPUT
                    IN LEGACY TEXT MODE
                    AT POSITION position
                    TYPE os_additions-type
                    CODE PAGE mode_options-codepage
                    REPLACEMENT CHARACTER '#'
                    IGNORING CONVERSION ERRORS.
            ENDCASE.
          WHEN zfloppy_dataset_api=>access_types-output.
          WHEN zfloppy_dataset_api=>access_types-update.
          WHEN zfloppy_dataset_api=>access_types-appending.
        ENDCASE.

        DATA(return_code) = sy-subrc.

        IF return_code <> 0.
          zfloppy_message_helper=>set_msg_vars_for_any( message ).
          RAISE EXCEPTION TYPE zfloppy_dataset_api_exception
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            EXPORTING
              return_code = return_code.
        ENDIF.

      CATCH cx_sy_file_open
            cx_sy_codepage_converter_init
            cx_sy_conversion_codepage
            cx_sy_file_authority
            cx_sy_pipes_not_supported
            cx_sy_too_many_files INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_dataset_api_exception
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_dataset_api~read_dataset.
    TRY.
        READ DATASET dataset
            INTO data_object
            MAXIMUM LENGTH maximum_length
            ACTUAL LENGTH actual_length.
        return_code = sy-subrc.

      CATCH cx_sy_codepage_converter_init
            cx_sy_conversion_codepage
            cx_sy_file_authority
            cx_sy_file_io
            cx_sy_file_open
            cx_sy_file_open_mode
            cx_sy_pipe_reopen INTO DATA(exception).
        zfloppy_message_helper=>set_msg_vars_for_any( exception ).
        RAISE EXCEPTION TYPE zfloppy_dataset_api_exception
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING
            previous = exception.
    ENDTRY.
  ENDMETHOD.

  METHOD zfloppy_dataset_api~set_dataset_attributes.

  ENDMETHOD.

  METHOD zfloppy_dataset_api~set_dataset_position.

  ENDMETHOD.

  METHOD zfloppy_dataset_api~transfer.

  ENDMETHOD.

  METHOD zfloppy_dataset_api~truncate_dataset_at.

  ENDMETHOD.

  METHOD zfloppy_dataset_api~truncate_dataset_at_curr_pos.

  ENDMETHOD.

ENDCLASS.
