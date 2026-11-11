function gwl --description 'Watch latest in-progress GH run'
    set -l id (gh run list --status in_progress --limit 1 --json databaseId -q '.[0].databaseId')
    if test -z "$id"
        echo "no in-progress runs"
        return 1
    end
    gh run watch $id
end
