; extends

(invocation
  parameter: (term
    value: (literal) @injection.content)
  (#set! injection.language "sql")
  (#set! injection.include-children true))
