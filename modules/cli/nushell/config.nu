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
    hooks: {
        pre_execution: [
            {||
                if "TMUX" in $env {
                    let cmd = (commandline)
                    let fullscreen_cmds = ["lazygit", "lg", "hx", "helix", "nvim", "vim", "vi", "yazi", "btop", "top", "htop", "less", "man"]
                    let words = ($cmd | str trim | split row " ")
                    let first_word = ($words | first)
                    let second_word = ($words | get -o 1)
                    if ($first_word in $fullscreen_cmds) or ($first_word == "sudo" and $second_word in $fullscreen_cmds) {
                        let esc = (char -i 27)
                        print -n $"($esc)Ptmux;($esc)($esc)_Ga=d,d=A($esc)($esc)\\"
                    }
                }
            }
        ]
    }
}

# Global Aliases

def --wrapped ff [...args] {
    clear
    if "TMUX" in $env {
        let cmd = (["fastfetch"] | append $args | str join " ")
        let out = (script -q -c $cmd /dev/null)
        let esc = (char -i 27)
        let rep = $"($esc)Ptmux;($esc)($esc)_G$1($esc)($esc)\\"
        print -n ($out | str replace -r "\u{1b}_G(.*?)\u{1b}\\\\" $rep)
    } else {
        ^fastfetch ...$args
    }
}
alias lg = lazygit

# Starship Transient Prompt
$env.TRANSIENT_PROMPT_COMMAND = {|| ^starship module character }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
