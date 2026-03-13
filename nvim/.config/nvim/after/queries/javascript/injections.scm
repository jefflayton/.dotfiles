; extends

(call_expression
  function: (identifier) @_tag
  (#eq? @_tag "sql")
  arguments: (template_string) @injection.content
  (#set! injection.language "sql")
  (#set! injection.combined true))

; Query Spec (string)
(pair
  key: (property_identifier) @_key
  (#eq? @_key "query")
  value: (string
    (string_fragment) @injection.content)
  (#set! injection.language "sql"))

; Query Spec (template)
(pair
  key: (property_identifier) @_key
  (#eq? @_key "query")
  value: (template_string
    (string_fragment) @injection.content)
  (#set! injection.language "sql")
  (#set! injection.combined true))

; Query Call (string, parenthesis)
(call_expression
  function: (member_expression
    property: (property_identifier) @_prop
    (#eq? @_prop "query"))
  arguments: (arguments
    (string
      (string_fragment) @injection.content))
  (#set! injection.language "sql"))

; Query Call (template, parenthesis)
(call_expression
  function: (member_expression
    property: (property_identifier) @_prop
    (#eq? @_prop "query"))
  arguments: (arguments
    (template_string
      (string_fragment) @injection.content))
  (#set! injection.language "sql")
  (#set! injection.combined true))

; Query Call (template, no parenthesis)
(call_expression
  function: (member_expression
    property: (property_identifier) @_prop
    (#eq? @_prop "query"))
  arguments: (template_string
    (string_fragment) @injection.content)
  (#set! injection.language "sql")
  (#set! injection.combined true))
