; extends

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#lua-match? @injection.language "^[\"'][\"'][\"']%s*#!%S*/env%s+%S") ; multiline shebang using env
  (#gsub! @injection.language "^%W*#!%S*/env%s+(%S+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#lua-match? @injection.language "^[\"'][\"'][\"']%s*#!/[^%s]+[ \t]*\n") ; multiline shebang
  (#not-lua-match? @injection.language "^[\"'][\"'][\"']%s*#!%S*/env%s")
  (#gsub! @injection.language "^%W*#!%S*/(%S+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#lua-match? @injection.content "^[\"'][\"'][\"']") ; multiline
  (#not-lua-match? @injection.content "^[\"'][\"'][\"']%s*#!") ; no shebang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#not-lua-match? @injection.content "^[\"'][\"'][\"']") ; not multiline
  (#offset! @injection.content 0 1 0 -1) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)
