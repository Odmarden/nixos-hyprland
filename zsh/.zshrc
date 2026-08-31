# ==============================================================================
# Tokyo Night Zsh Configuration for Kitty & NixOS
# ==============================================================================

# Enable colors and modern completion
autoload -U colors && colors
autoload -U compinit && compinit

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Standard Emacs-style keybindings
bindkey -e
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Zsh Autosuggestions configuration
if [ -f /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # Tokyo Night storm comment style for autosuggestions
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    # Accept suggestion shortcuts: Right Arrow, Ctrl+Space, Ctrl+F, or End
    bindkey "^ " autosuggest-accept
    bindkey "^F" autosuggest-accept
    bindkey "^[[F" autosuggest-accept
fi

# Zsh Syntax Highlighting
if [ -f /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Ensure standard path
export PATH="$HOME/.local/bin:/run/current-system/sw/bin:$PATH"

# ==============================================================================
# Aliases & Terminal Shortcuts
# ==============================================================================
alias c="clear"
alias r="systemctl reboot"
alias s="systemctl poweroff"
alias q="exit"

# NixOS shortcuts
alias nr="sudo nixos-rebuild switch"
alias nrb="sudo nixos-rebuild dry-build"
alias ntest="sudo nixos-rebuild test"
alias ngc="sudo nix-collect-garbage -d"

# Navigation & utility shortcuts
alias ls="ls --color=auto"
alias ll="ls -lh --color=auto"
alias la="ls -lah --color=auto"
alias grep="grep --color=auto"
alias wp="wallpaper-picker"
alias ..="cd .."
alias ...="cd ../.."

# Tokyo Night prompt
PROMPT="%F{#7aa2f7}%n%f@%F{#bb9af7}%m%f %F{#7dcfff}%~%f %F{#9ece6a}❯%f "
RPROMPT="%F{#565f89}%*%f"
