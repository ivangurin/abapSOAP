*----------------------------------------------------------------------*
*       CLASS ZCL_SOAP_STATIC DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_SOAP_STATIC definition
  public
  final
  create public .

*"* public components of class ZCL_SOAP_STATIC
*"* do not include other source files here!!!
public section.

  types:
    begin of ts_envelope,
          header type string,
          body   type string,
        end of ts_envelope .
  types:
    begin of ts_fault,
          faultcode   type string,
          faultstring type string,
          detail      type string,
        end of ts_fault .

  constants FIELD_ACTION type STRING value 'SOAPAction' ##NO_TEXT.
  constants CONTENT_TYPE type STRING value 'text/xml;charset=UTF-8' ##NO_TEXT.

  class-methods ENVELOPE_DATA2XML
    importing
      !IS_ENVELOPE type TS_ENVELOPE
    returning
      value(E_XML) type STRING
    raising
      ZCX_GENERIC .
  class-methods ENVELOPE_XML2DATA
    importing
      !I_XML type STRING
    returning
      value(ES_DATA) type TS_ENVELOPE
    raising
      ZCX_GENERIC .
  class-methods FAULT_XML2DATA
    importing
      !I_XML type STRING
    returning
      value(ES_DATA) type TS_FAULT
    raising
      ZCX_GENERIC .
  protected section.
*"* protected components of class ZCL_SOAP_STATIC
*"* do not include other source files here!!!
  private section.
*"* private components of class ZCL_SOAP_STATIC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_SOAP_STATIC IMPLEMENTATION.


  method envelope_data2xml.

    try.

        call transformation zsoap_envelope_data2xml
          source data = is_envelope
          result xml e_xml.

        data lx_root type ref to cx_root.
      catch cx_root into lx_root.
        zcx_generic=>raise( ix_root = lx_root ).
    endtry.

  endmethod.                    "envelope2xml


  method envelope_xml2data.

    try.

        data lr_ixml type ref to if_ixml.
        lr_ixml = cl_ixml=>create( ).

        data lr_stream_factory type ref to if_ixml_stream_factory.
        lr_stream_factory = lr_ixml->create_stream_factory( ).

        data lr_stream type ref to if_ixml_istream.
        lr_stream = lr_stream_factory->create_istream_string( i_xml ).

        data lr_document type ref to if_ixml_document.
        lr_document = lr_ixml->create_document( ).

        data lr_parser type ref to if_ixml_parser.
        lr_parser =
          lr_ixml->create_parser(
            stream_factory = lr_stream_factory
            istream        = lr_stream
            document       = lr_document ).

        lr_parser->parse( ).

        data lr_root type ref to if_ixml_node.
        lr_root = lr_document->get_root( ).

        data lt_children type ref to if_ixml_node_list.
        lt_children = lr_root->get_children( ).

        data lr_iterator type ref to if_ixml_node_iterator.
        lr_iterator = lt_children->create_iterator( ).

        data lr_node type ref to if_ixml_node.
        lr_node = lr_iterator->get_next( ). " Envelope

        data l_namespace type string.
        l_namespace = lr_node->get_namespace( ).

        data lr_header type ref to if_ixml_element.
        lr_header =
          lr_document->find_from_name(
            name = 'Header'                                 "#EC NOTEXT
            namespace = l_namespace ).

        if lr_header is bound.

          lt_children = lr_header->get_children( ).
          lr_iterator = lt_children->create_iterator( ).
          lr_node     = lr_iterator->get_next( ).

          data lr_xml type ref to cl_xml_document.
          create object lr_xml.

          lr_xml->create_with_node( lr_node ).

          lr_xml->render_2_string(
            importing
              stream = es_data-header ).

        endif.

        data lr_body type ref to if_ixml_element.
        lr_body =
          lr_document->find_from_name(
            name = 'Body'                                   "#EC NOTEXT
            namespace = l_namespace ).

        if lr_body is bound.

          lt_children = lr_body->get_children( ).
          lr_iterator = lt_children->create_iterator( ).
          lr_node     = lr_iterator->get_next( ).

          create object lr_xml.
          lr_xml->create_with_node( lr_node ).
          lr_xml->render_2_string( importing stream = es_data-body ).

        endif.

***      call transformation Z_SOAP_ENVELOPE_XML2DATA
***        source xml i_xml
***        result envelope = es_envelope.

        data lx_root type ref to cx_root.
      catch cx_root into lx_root.
        zcx_generic=>raise( ix_root = lx_root ).
    endtry.

  endmethod.                    "xml2envelope


  method fault_xml2data.

    try.

        data lr_ixml type ref to if_ixml.
        lr_ixml = cl_ixml=>create( ).

        data lr_stream_factory type ref to if_ixml_stream_factory.
        lr_stream_factory = lr_ixml->create_stream_factory( ).

        data lr_stream type ref to if_ixml_istream.
        lr_stream = lr_stream_factory->create_istream_string( i_xml ).

        data lr_document type ref to if_ixml_document.
        lr_document = lr_ixml->create_document( ).

        data lr_parser type ref to if_ixml_parser.
        lr_parser =
          lr_ixml->create_parser(
            stream_factory = lr_stream_factory
            istream        = lr_stream
            document       = lr_document ).

        lr_parser->parse( ).

        data lr_root type ref to if_ixml_node.
        lr_root = lr_document->get_root( ).

        data lt_children type ref to if_ixml_node_list.
        lt_children = lr_root->get_children( ).

        data lr_iterator type ref to if_ixml_node_iterator.
        lr_iterator = lt_children->create_iterator( ).

        data lr_node type ref to if_ixml_node.
        lr_node = lr_iterator->get_next( ). " Fault node

        data l_namespace type string.
        l_namespace = lr_node->get_namespace( ).

        data lr_element type ref to if_ixml_element.
        lr_element =
          lr_document->find_from_name(
            name      = 'faultcode'
            namespace = l_namespace ).
        if lr_element is not bound.
          lr_element = lr_document->find_from_name( 'faultcode' ).
        endif.

        if lr_element is bound.
          es_data-faultcode = lr_element->get_value( ).
        endif.

        free lr_element.
        lr_element =
          lr_document->find_from_name(
            name      = 'faultstring'
            namespace = l_namespace ).
        if lr_element is not bound.
          lr_element = lr_document->find_from_name( 'faultstring' ).
        endif.

        if lr_element is bound.
          es_data-faultstring = lr_element->get_value( ).
        endif.

        free lr_element.
        lr_element =
          lr_document->find_from_name(
            name      = 'detail'
            namespace = l_namespace ).
        if lr_element is not bound.
          lr_element = lr_document->find_from_name( 'detail' ).
        endif.

        if lr_element is bound.

          data l_value type string.
          l_value = lr_element->get_value( ).

          if l_value is not initial.

            data lr_xml type ref to cl_xml_document.
            create object lr_xml.

            lr_xml->create_with_node( lr_element ).

            lr_xml->render_2_string(
              importing
                stream = es_data-detail ).

          endif.

        endif.

        data lx_root type ref to cx_root.
      catch cx_root into lx_root.
        zcx_generic=>raise( ix_root = lx_root ).
    endtry.

  endmethod.                    "xml2fault
ENDCLASS.
