REPORT zfloppy_dataset_api_generator.

CLASS parameter_names DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CONSTANTS mode TYPE abap_parmname VALUE 'MODE'.
ENDCLASS.


CLASS parameter DEFINITION.
  PUBLIC SECTION.
    DATA name TYPE abap_parmname READ-ONLY.

    METHODS constructor IMPORTING !name TYPE abap_parmname.

    METHODS only_when IMPORTING parameter_name  TYPE abap_parmname
                                parameter_value TYPE csequence.

    METHODS not_when IMPORTING parameter_name  TYPE abap_parmname
                               parameter_value TYPE csequence.

*
*    METHODS specific_for_param_values IMPORTING parameter_name   TYPE abap_parmname
*                                                parameter_values TYPE string_table.
ENDCLASS.


CLASS parameter IMPLEMENTATION.
  METHOD constructor.
    me->name = name.
  ENDMETHOD.

  METHOD only_when.
  ENDMETHOD.

  METHOD not_when.
  ENDMETHOD.
ENDCLASS.


CLASS free_value_parameter DEFINITION INHERITING FROM parameter.
ENDCLASS.


CLASS value_range_parameter DEFINITION INHERITING FROM parameter.
  PUBLIC SECTION.
    DATA value_constant TYPE REF TO data READ-ONLY.

    METHODS constructor IMPORTING !name          TYPE abap_parmname
                                  value_constant TYPE REF TO data.
ENDCLASS.


CLASS value_range_parameter IMPLEMENTATION.
  METHOD constructor.
    super->constructor( name = name ).
    me->value_constant = value_constant.
  ENDMETHOD.
ENDCLASS.


CLASS parameter_list_builder DEFINITION.
  PUBLIC SECTION.
    DATA parameters TYPE STANDARD TABLE OF REF TO parameter READ-ONLY.

    METHODS new_free_value_parameter IMPORTING !name         TYPE abap_parmname
                                     RETURNING VALUE(result) TYPE REF TO parameter.

    METHODS new_value_range_parameter IMPORTING !name          TYPE abap_parmname
                                                value_constant TYPE REF TO data
                                      RETURNING VALUE(result)  TYPE REF TO parameter.
ENDCLASS.


CLASS parameter_list_builder IMPLEMENTATION.
  METHOD new_free_value_parameter.
    result = NEW free_value_parameter( name ).
    APPEND result TO parameters.
  ENDMETHOD.

  METHOD new_value_range_parameter.
    result = NEW value_range_parameter( name = name value_constant = value_constant ).
    APPEND result TO parameters.
  ENDMETHOD.
ENDCLASS.


CLASS generator DEFINITION.
  PUBLIC SECTION.
    METHODS run.

  PRIVATE SECTION.
    DATA parameters TYPE STANDARD TABLE OF REF TO parameter.

    METHODS define_parameters.
    METHODS execute_generation.

ENDCLASS.


CLASS generator IMPLEMENTATION.
  METHOD run.
  ENDMETHOD.

  METHOD define_parameters.
    DATA(builder) = NEW parameter_list_builder( ).

    builder->new_value_range_parameter( name           = parameter_names=>mode
                                        value_constant = REF #( zfloppy_dataset_api=>modes ) ).
  ENDMETHOD.

  METHOD execute_generation.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  NEW generator( )->run( ).
