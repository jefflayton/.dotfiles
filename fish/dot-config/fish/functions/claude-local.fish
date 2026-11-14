function claude-local --description 'Claude Code on a local Ollama model, bare mode'
    # claude-local [model] [claude args...]   default model: qwen3.5:4b
    set -l model qwen3.5:4b
    if set -q argv[1]; and not string match -q -- '-*' $argv[1]
        set model $argv[1]
        set -e argv[1]
    end
    # Env only, so ~/.claude/settings.json (shared with normal sessions) is untouched.
    # --bare: no hooks/plugins/MCP/CLAUDE.md, a much smaller prompt; auth must be ANTHROPIC_API_KEY.
    ANTHROPIC_BASE_URL=http://localhost:11434 \
        ANTHROPIC_API_KEY=ollama \
        ANTHROPIC_DEFAULT_HAIKU_MODEL=$model \
        ANTHROPIC_DEFAULT_SONNET_MODEL=$model \
        ANTHROPIC_DEFAULT_OPUS_MODEL=$model \
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
        CLAUDE_CODE_MAX_CONTEXT_TOKENS=32768 \
        claude --bare --model $model $argv
end
