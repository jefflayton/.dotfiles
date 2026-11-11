function jc --description 'fix, precheck, then commit'
    if command -q prek;
        if test -f .pre-commit-config.yaml; or test -f prek.toml
            prek run --stage pre-commit; or return
        end
    end

    jj commit $argv
end
