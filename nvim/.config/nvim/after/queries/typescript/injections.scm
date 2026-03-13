; extends

(call_expression
  function: (identifier) @_tag
  (#eq? @_tag "sql")
  arguments: (template_string) @injection.content
  (#set! injection.language "sql"))
