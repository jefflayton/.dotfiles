 function jp --description 'fix, precheck, then push'
      set -l jj_args $argv

      if command -q prek
          if test -f .pre-commit-config.yaml; or test -f prek.toml
              # -i passes unknown flags (--dry-run, --remote, ...) through to jj.
              argparse -i 'b/bookmark=+' 'c/change=+' 'r/revisions=+' -- $argv; or return

              set -l targets
              for b in $_flag_bookmark
                  set -a targets "\"$b\""
              end
              for r in $_flag_change $_flag_revisions
                  set -a targets "($r)"
              end
              test (count $targets) -eq 0; and set targets @

              # Every commit the remotes don't already have, up to the push targets.
              set -l range "remote_bookmarks()..("(string join ' | ' $targets)")"

              set -l files
              for f in (jj diff --name-only -r $range)
                  test -e $f; and set -a files $f
              end

              if test (count $files) -gt 0
                  prek run --stage pre-commit --files $files; or return
                  prek run --stage pre-push --files $files; or return
              end
          end
      end

      jj git push $jj_args
  end
