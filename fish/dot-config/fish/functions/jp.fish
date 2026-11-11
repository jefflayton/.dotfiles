function jp --description 'fix, precheck, then push'
    if command -q prek;
        if test -f .pre-commit-config.yaml; or test -f prek.toml
            prek run --stage pre-push; or return
        end
    end

    jj git push $argv
end
