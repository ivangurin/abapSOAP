*----------------------------------------------------------------------*
*       CLASS ZCL_SOAP_CLIENT DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_SOAP_CLIENT definition
  public
  final
  create public .

*"* public components of class ZCL_SOAP_CLIENT
*"* do not include other source files here!!!
public section.

  data URL type STRING read-only .
  data ACTION type STRING read-only .
  data TIMEOUT type I read-only value '60' ##NO_TEXT.                                  " .

  methods CONSTRUCTOR
    importing
      !I_URL type STRING optional
      !I_ACTION type STRING optional
    preferred parameter I_URL
    raising
      ZCX_GENERIC .
  methods SET_URL
    importing
      !I_URL type STRING
    raising
      ZCX_GENERIC .
  methods SET_ACTION
    importing
      !I_ACTION type STRING
    raising
      ZCX_GENERIC .
  methods SET_TIMEOUT
    importing
      !I_TIMEOUT type I .
  methods SEND
    importing
      !I_REQUEST type SIMPLE
    returning
      value(E_RESPONSE) type STRING
    raising
      ZCX_GENERIC .
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
