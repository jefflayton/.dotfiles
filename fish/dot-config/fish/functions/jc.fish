  function jc --description 'fix, precheck, then commit'
      if command -q prek
          if test -f .pre-commit-config.yaml; or test -f prek.toml
              # jj never stages anything, so give prek jj's changed files directly.
              # Leave out deleted paths so hooks never get a file that doesn't exist.
              set -l files
              for f in (jj diff --name-only)
                  test -e $f; and set -a files $f
              end

              if test (count $files) -gt 0
                  prek run --stage pre-commit --files $files; or return
              end
          end
      end

      jj commit $argv
  end
