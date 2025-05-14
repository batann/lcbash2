# Setup fzf
# ---------
if [[ ! "$PATH" == */home/batan/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/batan/.fzf/bin"
fi

eval "$(fzf --bash)"

export FZF_DEFAULT_OPTS="  --color=fg:#9FB1BC,fg+:#9FB1BC,bg:#2E5266,bg+:#2E5266\
  --color=hl:#1a7ada,hl+:#9ae6ff,info:#9fb1bc,marker:#3ee421 \
  --color=prompt:#1700af,spinner:#F4FFFD,pointer:#F4FFFD,header:#F4FFFD \
  --color=border:#F7B32B,preview-fg:#9fb1bc,preview-bg:#2e5266 \
  --color=preview-label:#00857a,label:#f7b32b,query:#d9d9d9 \
  --border='sharp' --preview-window=right,50%,'wrap' \
  --padding='2' --margin='4' --prompt='' --marker='->' \
  --pointer='>>' --separator='─' --scrollbar='│' --info='inline'"

