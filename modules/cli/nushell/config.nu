# Nushell config

$env.config = {
    show_banner: false
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
            enable: true
            max_results: 100
        }
    }
    keybindings: []
}

# Global Aliases

alias ff = fastfetch
# Show dotfiles (.git etc.) by default
alias ls = ls --all
# Re-apply pi-shazam patches (pre-commit hook disable) after npm reinstalls
^bash ~/.pi/agent/lib/shazam-compat.sh
alias lg = lazygit

# Starship Transient Prompt
$env.TRANSIENT_PROMPT_COMMAND = {|| ^starship module character }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
