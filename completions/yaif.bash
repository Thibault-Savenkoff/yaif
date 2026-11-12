# bash completion for yaif. Install: copy into a bash-completion completions
# directory (e.g. ~/.local/share/bash-completion/completions/yaif, no
# extension) -- sourced automatically by the bash-completion package, no
# ~/.bashrc edit needed. File names go through its _filedir, which quotes spaces.
_yaif() {
  local cur prev
  _init_completion || return
  local cmds="encode decode convert preview info bench version"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "$cmds --version" -- "$cur"))
    return
  fi

  case ${COMP_WORDS[1]} in
    encode)
      case $prev in
        -m) COMPREPLY=($(compgen -W "adaptive lossless lossy" -- "$cur")); return ;;
        -l) COMPREPLY=($(compgen -W "0 1 2 3 4 5" -- "$cur")); return ;;
        -live) _filedir mov; return ;;
      esac
      _filedir ;;
    decode|convert)
      case $prev in
        -m) COMPREPLY=($(compgen -W "lossy lossless" -- "$cur")); return ;;
        -look) COMPREPLY=($(compgen -W "canon darktable" -- "$cur")); return ;;
      esac
      _filedir ;;
    preview|info)
      _filedir yaif ;;
    bench)
      _filedir '@(png|jpg|jpeg)' ;;
    *)
      _filedir ;;
  esac
}
complete -F _yaif yaif
