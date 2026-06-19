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
}

# Global Aliases

alias ff = fastfetch --logo-type kitty --logo /persist/etc/nixos/assets/logo.png
alias lg = lazygit
