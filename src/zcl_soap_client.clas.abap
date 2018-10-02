*----------------------------------------------------------------------*
*       CLASS ZCL_SOAP_CLIENT DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zcl_soap_client definition
  public
  final
  create public .

*"* public components of class ZCL_SOAP_CLIENT
*"* do not include other source files here!!!
  public section.

    data url type string read-only .
    data action type string read-only .
    data timeout type i read-only value '60' ##NO_TEXT.                                  " .

    methods constructor
      importing
        !i_url    type string optional
        !i_action type string optional
          preferred parameter i_url
      raising
        zcx_generic .
    methods set_url
      importing
        !i_url type simple
      raising
        zcx_generic .
    methods set_action
      importing
        !i_action type simple
      raising
        zcx_generic .
    methods set_timeout
      importing
        !i_timeout type i .
    methods send
      importing
        !i_request        type simple
      returning
        value(e_response) type string
      raising
        zcx_generic .
  protected section.
*"* protected components of class ZCL_SOAP_CLIENT
*"* do not include other source files here!!!
  private section.
*"* private components of class ZCL_SOAP_CLIENT
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_SOAP_CLIENT IMPLEMENTATION.


  method constructor.

    url    = i_url.
    action = i_action.

  endmethod.                    "constructor


  method send.

    data lr_client type ref to zcl_http_client.
    create object lr_client
      exporting
        i_url = url.

    lr_client->set_timeout( timeout ).

    lr_client->set_method( if_http_request=>co_request_method_post ).

    lr_client->set_header_field(
      i_name  = zcl_soap_static=>field_action
      i_value = action ).

    lr_client->set_content_type( zcl_soap_static=>content_type ).

    lr_client->set_body( i_request ).

    lr_client->send( ).

    e_response = lr_client->get_body( ).

    lr_client->close( ).

  endmethod.                    "send


  method set_action.

    action = i_action.

  endmethod.                    "set_action


  method set_timeout.

    timeout = i_timeout.

  endmethod.                    "set_timeout


  method set_url.

    url = i_url.

  endmethod.                    "set_url
ENDCLASS.
