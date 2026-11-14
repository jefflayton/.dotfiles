# Run nvim, then cd to its last working directory (written on exit by nvim plugin/41_files.lua).
function nvim --wraps nvim
    set -l f (mktemp -t nvim-cwd)
    NVIM_CWD_FILE=$f command nvim $argv
    set -l dir (cat $f)
    rm -f $f
    if test -n "$dir" -a "$dir" != "$PWD"
        cd -- $dir
    end
end
