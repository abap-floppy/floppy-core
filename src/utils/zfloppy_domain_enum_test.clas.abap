CLASS zfloppy_domain_enum_test DEFINITION
  PUBLIC
  ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! @parameter class                | Variable with TYPE REF TO enum_class
    "! @parameter domain               | Variable with TYPE dtel with domain
    "! @parameter value_attribute_name | Attribute name for domain value
    METHODS constructor IMPORTING !class               TYPE data
                                  domain               TYPE data
                                  value_attribute_name TYPE abap_attrname DEFAULT 'VALUE'.

    METHODS all_attributes_are_in_domain FOR TESTING.
    METHODS all_domain_values_are_attrs  FOR TESTING.
    METHODS values_should_be_unique      FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA class_descriptor     TYPE REF TO cl_abap_classdescr.
    DATA element_descriptor   TYPE REF TO cl_abap_elemdescr.
    DATA domain_fixed_values  TYPE ddfixvalues.
    DATA attributes           TYPE abap_attrdescr_tab.
    DATA value_attribute_name TYPE abap_attrname.

    METHODS setup.
    METHODS teardown.
ENDCLASS.


CLASS zfloppy_domain_enum_test IMPLEMENTATION.
  METHOD all_attributes_are_in_domain.
    FIELD-SYMBOLS <value> TYPE csequence.

    LOOP AT attributes REFERENCE INTO DATA(attribute).
      DATA(target) = |{ class_descriptor->get_relative_name( ) }=>{ attribute->name }|.
      ASSIGN (target) TO FIELD-SYMBOL(<target>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(object) = CAST object( <target> ).

      ASSIGN object->(value_attribute_name) TO <value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      cl_abap_unit_assert=>assert_true(
          act = xsdbool( line_exists( domain_fixed_values[ low = EXACT domvalue_l( <value> ) ] ) )
          msg = |Could not find domain value for attribute { attribute->name } with value { <value> }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD all_domain_values_are_attrs.
    FIELD-SYMBOLS <value> TYPE csequence.

    LOOP AT domain_fixed_values REFERENCE INTO DATA(fixed_value).
      DATA(found) = abap_false.

      LOOP AT attributes REFERENCE INTO DATA(attribute).
        DATA(target) = |{ class_descriptor->get_relative_name( ) }=>{ attribute->name }|.
        ASSIGN (target) TO FIELD-SYMBOL(<target>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DATA(object) = CAST object( <target> ).

        ASSIGN object->(value_attribute_name) TO <value>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF EXACT domvalue_l( <value> ) = fixed_value->low.
          found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      cl_abap_unit_assert=>assert_true( act = found
                                        msg = |Could not find attribute for domain value { fixed_value->low }'| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD values_should_be_unique.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA values TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <value> TYPE csequence.

    LOOP AT attributes REFERENCE INTO DATA(attribute).
      DATA(target) = |{ class_descriptor->get_relative_name( ) }=>{ attribute->name }|.
      ASSIGN (target) TO FIELD-SYMBOL(<target>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(object) = CAST object( <target> ).

      ASSIGN object->(value_attribute_name) TO <value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      INSERT CONV #( <value> ) INTO TABLE values.
      cl_abap_unit_assert=>assert_subrc( exp = 0
                                         msg = |Attribute with enum value { <value> } already exists| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    class_descriptor = CAST #( CAST cl_abap_refdescr( cl_abap_typedescr=>describe_by_data( class )
      )->get_referenced_type( ) ).
    element_descriptor = CAST #( cl_abap_typedescr=>describe_by_data( domain ) ).
    me->value_attribute_name = value_attribute_name.
  ENDMETHOD.

  METHOD setup.
    element_descriptor->get_ddic_fixed_values( RECEIVING  p_fixed_values = domain_fixed_values
                                               EXCEPTIONS not_found      = 1
                                                          no_ddic_type   = 2
                                                          OTHERS         = 3 ).
    cl_abap_unit_assert=>assert_subrc( exp   = 0
                                       msg   = 'Variable does not point to domain'
                                       symsg = CORRESPONDING #( sy ) ).

    attributes = class_descriptor->attributes.

    DELETE attributes WHERE NOT (
                                  is_class = abap_true
                            AND type_kind    = cl_abap_typedescr=>typekind_oref
                            AND visibility   = cl_abap_objectdescr=>public
                            AND is_read_only = abap_true ).

    LOOP AT attributes REFERENCE INTO DATA(attribute).
      DATA(attribute_descriptor) = CAST cl_abap_refdescr( class_descriptor->get_attribute_type( attribute->name ) ).

      IF NOT class_descriptor->applies_to_class( attribute_descriptor->get_referenced_type( )->absolute_name ).
        DELETE attributes USING KEY loop_key.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD teardown.
    CLEAR domain_fixed_values.
  ENDMETHOD.
ENDCLASS.
