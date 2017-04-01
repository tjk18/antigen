######################################################################
# This file was autogenerated by `make`. Do not edit it directly!
######################################################################
# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"

for config in $_ANTIGEN_CHECK_FILES; do
  if [[ "$config" -nt "$config.zwc" ]]; then
    zcompile "$config"
    [[ -f "$_ANTIGEN_CACHE" ]] && \rm -f "$_ANTIGEN_CACHE"
  fi
done

[[ -f $_ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$_ANTIGEN_CACHE" && return;
[[ -z "$_ANTIGEN_INSTALL_DIR" ]] && _ANTIGEN_INSTALL_DIR=${0:A:h}

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
[[ $_ANTIGEN_CACHE_LOADED != true ]] && typeset -aU _ANTIGEN_BUNDLE_RECORD

# Do not load anything if git is not available.
if (( ! $+commands[git] )); then
    echo 'Antigen: Please install git to use Antigen.' >&2
    return 1
fi

# Used to defer compinit/compdef
typeset -a __deferred_compdefs
compdef () { __deferred_compdefs=($__deferred_compdefs "$*") }

# A syntax sugar to avoid the `-` when calling antigen commands. With this
# function, you can write `antigen-bundle` as `antigen bundle` and so on.
antigen () {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo 'Antigen: Please give a command to run.' >&2
    return 1
  fi
  shift

  if (( $+functions[antigen-$cmd] )); then
      "antigen-$cmd" "$@"
  else
      echo "Antigen: Unknown command: $cmd" >&2
  fi
}
# Returns the bundle's git revision
#
# Usage
#   -antigen-bundle-rev bundle-name
#
# Returns
#   Bundle rev-parse output (branch name or short ref name)
-antigen-bundle-rev () {
  local bundle=$1
  local bundle_path=$(-antigen-get-clone-dir $bundle)
  local ref
  ref=$(git --git-dir="$bundle_path/.git" rev-parse --abbrev-ref '@')

  # Avoid 'HEAD' when in detached mode
  if [[ $ref == "HEAD" ]]; then
    ref=$(git --git-dir="$bundle_path/.git" describe --tags --exact-match 2>/dev/null || git --git-dir="$bundle_path/.git" rev-parse --short '@')
  fi
  echo $ref
}
-antigen-bundle-short-name () {
  local bundle_name=$(echo "$1" | sed -E "s|.*/(.*/.*).*|\1|"|sed -E "s|\.git.*$||g")
  local bundle_branch=$2
    
  if [[ "$bundle_branch" == "" ]]; then
    echo $bundle_name
    return
  fi

  echo "$bundle_name@$bundle_branch"
}

# Echo the bundle specs as in the record. The first line is not echoed since it
# is a blank line.
-antigen-echo-record () {
  echo ${(j:\n:)_ANTIGEN_BUNDLE_RECORD}
}
# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-bundle example/bundle
#
# Returns
#   String if bundle is found
-antigen-find-bundle () {
  echo $(-antigen-find-record $1 | cut -d' ' -f1)
}

# Filters _ANTIGEN_BUNDLE_RECORD for $1
#
# Usage
#   -antigen-find-record example/bundle
#
# Returns
#   String if record is found
-antigen-find-record () {
  local bundle=$1
  
  if [[ $# -eq 0 ]]; then
    return 1
  fi

  local record=${bundle/\|/\\\|}
  echo "${_ANTIGEN_BUNDLE_RECORD[(r)*$record*]}"
}
# Returns bundle names from _ANTIGEN_BUNDLE_RECORD
#
# Usage
#   -antigen-get-bundles [--short|--simple|--long]
#
# Returns
#   List of bundles installed
-antigen-get-bundles () {
  local mode
  local revision
  local url
  local bundle_name
  local bundle_entry
  mode=${1:-"--short"}

  for record in $_ANTIGEN_BUNDLE_RECORD; do
    url="$(echo "$record" | cut -d' ' -f1)"
    bundle_name=$(-antigen-bundle-short-name $url)

    case "$mode" in
        --short)
          revision=$(-antigen-bundle-rev $url)
          loc="$(echo "$record" | cut -d' ' -f2)"
          if [[ $loc != '/' ]]; then
            bundle_name="$bundle_name ~ $loc"
          fi
          echo "$bundle_name @ $revision"
        ;;
        --simple)
          echo "$bundle_name"
        ;;
        --long)
          echo "$record"
        ;;
     esac
  done
}
-antigen-get-clone-dir () {
  # Takes a repo url and mangles it, giving the path that this url will be
  # cloned to. Doesn't actually clone anything.
  echo -n $ADOTDIR/repos/

  if [[ "$1" == "$ANTIGEN_PREZTO_REPO_URL" ]]; then
    # Prezto's directory *has* to be `.zprezto`.
    echo .zprezto
  else
    local url="${1}"
    url=${url//\//-SLASH-}
    url=${url//\:/-COLON-}
    url=${url//\*/-STAR-}
    echo "${url//\|/-PIPE-}"
  fi
}

-antigen-get-clone-url () {
  # Takes a repo's clone dir and unmangles it, to give the repo's original url
  # that was used to create the given directory path.

  if [[ "$1" == ".zprezto" ]]; then
    echo "$(cd "$ADOTDIR/repos/.zprezto" && git config --get remote.origin.url)"
  else
    local _path="${1}"
    _path=${_path//^\$ADOTDIR\/repos\/}
    _path=${_path//-SLASH-/\/}
    _path=${_path//-COLON-/\:}
    _path=${_path//-STAR-/\*}
    echo "${_path//-PIPE-/\|}"
  fi
}

# Returns bundles flagged as make_local_clone
#
# Usage
#    -antigen-cloned-bundles
#
# Returns
#    Bundle metadata
-antigen-get-cloned-bundles() {
  -antigen-echo-record |
      awk '$4 == "true" {print $1}' |
      sort -u
}
# Returns a list of themes from a default library (omz)
#
# Usage
#   -antigen-get-themes
#
# Returns
#   List of themes by name
-antigen-get-themes () {
  local library='robbyrussell/oh-my-zsh'
  local bundle=$(-antigen-find-bundle $library)

  if [[ -n "$bundle" ]]; then
    local dir=$(-antigen-get-clone-dir $ANTIGEN_DEFAULT_REPO_URL)
    echo $(ls $dir/themes | sed 's/.zsh-theme//')
  fi
  
  return 0
}

# Updates _ANTIGEN_INTERACTIVE environment variable to reflect
# if antigen is running in an interactive shell or from sourcing.
#
# This function check ZSH_EVAL_CONTEXT if available or functrace otherwise.
# If _ANTIGEN_INTERACTIVE is set to true it won't re-check again.
#
# Usage
#   -antigen-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-antigen-interactive-mode () {
  # Check if we are in any way running in interactive mode
  if [[ $_ANTIGEN_INTERACTIVE == false ]]; then
    if [[ "$ZSH_EVAL_CONTEXT" =~ "toplevel:*" ]]; then
      _ANTIGEN_INTERACTIVE=true
    elif [[ -z "$ZSH_EVAL_CONTEXT" ]]; then
      zmodload zsh/parameter
      if [[ "${functrace[$#functrace]%:*}" == "zsh" ]]; then
        _ANTIGEN_INTERACTIVE=true
      fi
    fi
  fi

  return _ANTIGEN_INTERACTIVE
}

# Parses and retrieves a remote branch given a branch name.
#
# If the branch name contains '*' it will retrieve remote branches
# and try to match against tags and heads, returning the latest matching.
#
# Usage
#     -antigen-parse-branch https://github.com/user/repo.git x.y.z
#
# Returns
#     Branch name
-antigen-parse-branch () {
  local url=$1
  local branch=$2
  local branches

  if [[ "$branch" =~ '\*' ]]; then
    branches=$(git ls-remote --tags -q "$url" "$branch"|cut -d'/' -f3|sort -n|tail -1)
    # There is no --refs flag in git 1.8 and below, this way we
    # emulate this flag -- also git 1.8 ref order is undefined.
    branch=${${branches#*/*/}%^*} # Why you are like this?
  fi

  echo $branch
}
# Parses a bundle url in bundle-metadata format: url[|branch]
-antigen-parse-bundle-url() {
  local url=$1
  local branch=$2

  # Resolve the url.
  url="$(-antigen-resolve-bundle-url "$url")"

  # Add the branch information to the url.
  if [[ ! -z $branch ]]; then
    url="$url|$branch"
  fi

  echo $url
}
# Given an acceptable short/full form of a bundle's repo url, this function
# echoes the full form of the repo's clone url.
-antigen-resolve-bundle-url () {
  local url="$1"

  # Expand short github url syntax: `username/reponame`.
  if [[ $url != git://* &&
          $url != https://* &&
          $url != http://* &&
          $url != ssh://* &&
          $url != /* &&
          $url != git@github.com:*/*
          ]]; then
    url="https://github.com/${url%.git}.git"
  fi

  echo "$url"
}

# Ensure that a clone exists for the given repo url and branch. If the first
# argument is `update` and if a clone already exists for the given repo
# and branch, it is pull-ed, i.e., updated.
#
# This function expects three arguments in order:
# - 'url=<url>'
# - 'update=true|false'
# - 'verbose=true|false'
#
# Returns true|false Whether cloning/pulling was succesful
-antigen-ensure-repo () {
  # Argument defaults. Previously using ${1:?"missing url argument"} format
  # but it seems to mess up with cram
  if (( $# < 1 )); then
    echo "Antigen: Missing url argument."
    return 1
  fi
  
  # The url. No sane default for this, so just empty.
  local url=$1
  # Check if we have to update.
  local update=${2:-false}
  # Verbose output.
  local verbose=${3:-false}

  shift $#

  # Get the clone's directory as per the given repo url and branch.
  local clone_dir="$(-antigen-get-clone-dir $url)"
  if [[ -d "$clone_dir" && $update == false ]]; then
    return true
  fi
    
  # A temporary function wrapping the `git` command with repeated arguments.
  --plugin-git () {
    (cd "$clone_dir" &>>! $_ANTIGEN_LOG && git --git-dir="$clone_dir/.git" --no-pager "$@" &>>! $_ANTIGEN_LOG)
  }

  # Clone if it doesn't already exist.
  local start=$(date +'%s')
  local install_or_update=false
  local success=false
  
  # If its a specific branch that we want, checkout that branch.
  local branch="master" # TODO FIX THIS
  if [[ $url == *\|* ]]; then
    branch="$(-antigen-parse-branch ${url%|*} ${url#*|})"
  fi
  
  if [[ ! -d $clone_dir ]]; then
    install_or_update=true
    echo -n "Installing $(-antigen-bundle-short-name "$url" "$branch")... "
    git clone ${=_ANTIGEN_CLONE_OPTS} --branch "$branch" -- "${url%|*}" "$clone_dir" &>> $_ANTIGEN_LOG
    success=$?
  elif $update; then
    install_or_update=true
    echo -n "Updating $(-antigen-bundle-short-name "$url" "$branch")... "
    # Save current revision.
    local old_rev="$(--plugin-git rev-parse HEAD)"
    # Pull changes if update requested.
    --plugin-git checkout "$branch"
    --plugin-git pull origin "$branch"
    success=$?

    # Update submodules.
    --plugin-git submodule update ${=_ANTIGEN_SUBMODULE_OPTS}
    # Get the new revision.
    local new_rev="$(--plugin-git rev-parse HEAD)"
  fi

  if $install_or_update; then
    local took=$(( $(date +'%s') - $start ))
    if [[ $success -eq 0 ]]; then
      printf "Done. Took %ds.\n" $took
    else
      printf "Error! Activate logging and try again.\n";
    fi
  fi

  if [[ -n $old_rev && $old_rev != $new_rev ]]; then
    echo Updated from $old_rev[0,7] to $new_rev[0,7].
    if $verbose; then
      --plugin-git log --oneline --reverse --no-merges --stat '@{1}..'
    fi
  fi

  # Remove the temporary git wrapper function.
  unfunction -- --plugin-git

  return $success
}
-antigen-env-setup () {
  # Helper function: Same as `$1=$2`, but will only happen if the name
  # specified by `$1` is not already set.
  -set-default () {
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && $arg_name='$arg_value'"
  }

  # Pre-startup initializations.
  -set-default ANTIGEN_DEFAULT_REPO_URL \
      https://github.com/robbyrussell/oh-my-zsh.git
  -set-default ANTIGEN_PREZTO_REPO_URL \
      https://github.com/zsh-users/prezto.git
  -set-default ADOTDIR $HOME/.antigen
  if [[ ! -d $ADOTDIR ]]; then
    mkdir -p $ADOTDIR
  fi

  -set-default _ANTIGEN_COMPDUMP "${ZDOTDIR:-$HOME}/.zcompdump"

  -set-default _ANTIGEN_LOG "/dev/null"
  
  # CLONE_OPTS uses ${=CLONE_OPTS} expansion so don't use spaces
  # for arguments that can be passed as `--key=value`.
  -set-default _ANTIGEN_CLONE_OPTS "--single-branch --recursive --depth=1"
  -set-default _ANTIGEN_SUBMODULE_OPTS "--recursive --depth=1"

  # Setup antigen's own completion.
  autoload -Uz compinit
  compinit -C -d "$_ANTIGEN_COMPDUMP"
  compdef _antigen antigen

  # Remove private functions.
  unfunction -- -set-default
}

-antigen-load-list () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local btype="$4"

  # The full location where the plugin is located.
  local location="$url/"
  if $make_local_clone; then
    location="$(-antigen-get-clone-dir "$url")/"
  fi

  if [[ $loc != "/" ]]; then
    location="$location$loc"
  fi

  if [[ ! -f "$location" && ! -d "$location" ]]; then
    return 1
  fi

  if [[ -f "$location" ]]; then
    echo "$location"
    return
  fi

  # Load `*.zsh-theme` for themes
  if [[ "$btype" == "theme" ]]; then
    local theme_plugin
    theme_plugin=($location/*.zsh-theme(N[1]))
    if [[ -f "$theme_plugin" ]]; then
      echo "$theme_plugin"
      return
    fi
  fi

  # If we have a `*.plugin.zsh`, source it.
  local script_plugin
  script_plugin=($location/*.plugin.zsh(N[1]))
  if [[ -f "$script_plugin" ]]; then
    echo "$script_plugin"
    return
  fi

  # Otherwise source init.
  if [[ -f $location/init.zsh ]]; then
    echo "$location/init.zsh"
    return
  fi

  # If there is no `*.plugin.zsh` file, source *all* the `*.zsh` files.
  local bundle_files
  bundle_files=($location/*.zsh(N) $location/*.sh(N))
  if [[ $#bundle_files -gt 0 ]]; then
    echo "${(j:\n:)bundle_files}"
    return
  fi
  
  # Add to PATH (binary bundle)
  echo "$location"
  return
}

# Load a given bundle by sourcing it.
#
# The function also modifies fpath to add the bundle path.
#
# Usage
#   -antigen-load "bundle-url" ["location"] ["make_local_clone"] ["btype"]
#
# Returns
#   Integer. 0 if success 1 if an error ocurred.
-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local btype="$4"
  local src

  if [[ -d "$loc/functions" ]]; then
    fpath=($loc/functions $fpath)
  fi

  for src in $(-antigen-load-list "$url" "$loc" "$make_local_clone" "$btype"); do
    # TODO Refactor this out
    if [[ -d "$src" ]]; then
      if (( ! ${fpath[(I)$src]} )); then
          fpath=($src $fpath)
      fi
      PATH="$PATH:$src"
    else
      # Hack away local variables. See https://github.com/zsh-users/antigen/issues/122
      # This is needed to seek-and-destroy local variable definitions *outside*
      # function-contexts. This is done in this particular way *only* for
      # interactive bundle/theme loading, for static loading -99.9% of the time-
      # eval and subshells are not needed.
      if [[ "$btype" == "theme" ]]; then
        eval "__PREVDIR=$PWD; cd ${src:A:h};
              $(cat $src | sed -Ee '/\{$/,/^\}/!{
               s/^local //
           }'); cd $__PREVDIR"
      else
        source "$src"
      fi
    fi
  done

  local location="$url/"
  if $make_local_clone; then
    location="$(-antigen-get-clone-dir "$url")/$loc"
  fi

  # If there is no location either as a file or a directory
  # we assume there is an error in the given location
  local success=0
  if [[ -f "$location" || -d "$location" ]]; then
    # Add to $fpath, for completion(s), if not in there already
    if (( ! ${fpath[(I)$location]} )); then
      fpath=($location $fpath)
    fi
  else
    success=1
  fi

  return $success
}

-antigen-parse-args () {
  local key
  local value
  local index=0

  while [[ $# -gt 0 ]]; do
    argkey="${1%\=*}"
    key="${argkey//--/}"
    value="${1#*=}"

    case "$argkey" in
      --url|--loc|--branch|--btype)
        if [[ "$value" == "$argkey" ]]; then
          echo "Required argument for '$key' not provided."
        else
          echo "local $key='$value'"
        fi
      ;;
      --no-local-clone)
        echo "local no_local_clone='true'"
      ;;
      --*)
        echo "Unknown argument '$key'."
      ;;
      *)
        value=$key
        case $index in
          0)
            key=url
            if [[ "$value" =~ '@' ]]; then
              echo "local branch='${value#*@}'"
              value="${value%@*}"
            fi
          ;;
          1) key=loc ;;
        esac
        let index+=1
        echo "local $key='$value'"
      ;;
    esac

    shift
  done
}


-antigen-parse-bundle () {
  # Bundle spec arguments' default values.
  local url="$ANTIGEN_DEFAULT_REPO_URL"
  local loc=/
  local branch=
  local no_local_clone=false
  local btype=plugin

  # Parse the given arguments. (Will overwrite the above values).
  eval "$(-antigen-parse-args "$@")"
  # Check if url is just the plugin name. Super short syntax.
  if [[ "$url" != */* ]]; then
    loc="plugins/$url"
    url="$ANTIGEN_DEFAULT_REPO_URL"
  fi

  # Format url in bundle-metadata format: url[|branch]
  url=$(-antigen-parse-bundle-url "$url" "$branch")

  # The `make_local_clone` variable better represents whether there should be
  # a local clone made. For cloning to be avoided, firstly, the `$url` should
  # be an absolute local path and `$branch` should be empty. In addition to
  # these two conditions, either the `--no-local-clone` option should be
  # given, or `$url` should not a git repo.
  local make_local_clone=true
  if [[ $url == /* && -z $branch &&
          ( $no_local_clone == true || ! -d $url/.git ) ]]; then
    make_local_clone=false
  fi

  # Add the theme extension to `loc`, if this is a theme, but only
  # if it's especified, ie, --loc=theme-name, in case when it's not
  # specified antige-load-list will look for *.zsh-theme files
  if [[ $btype == theme &&
    $loc != "/" && $loc != *.zsh-theme ]]; then
      loc="$loc.zsh-theme"
  fi

  # Bundle spec arguments' default values.
  echo "local url=\""$url\""
        local loc=\""$loc\""
        local branch=\""$branch\""
        local make_local_clone="$make_local_clone"
        local btype=\""$btype\""
        "
}

# Updates revert-info data with git hash.
#
# This does process only cloned bundles.
#
# Usage
#    -antigen-revert-info
#
# Returns
#    Nothing. Generates/updates $ADOTDIR/revert-info.
-antigen-revert-info() {
  # Update your bundles, i.e., `git pull` in all the plugin repos.
  date >! $ADOTDIR/revert-info

  -antigen-get-cloned-bundles | while read url; do
    local clone_dir="$(-antigen-get-clone-dir "$url")"
    if [[ -d "$clone_dir" ]]; then
      (echo -n "$clone_dir:"
        cd "$clone_dir"
        git rev-parse HEAD) >> $ADOTDIR/revert-info
    fi
  done
}

-antigen-use-oh-my-zsh () {
  if [[ -z "$ZSH" ]]; then
    ZSH="$(-antigen-get-clone-dir "$ANTIGEN_DEFAULT_REPO_URL")"
  fi
  if [[ -z "$ZSH_CACHE_DIR" ]]; then
    ZSH_CACHE_DIR="$ZSH/cache/"
  fi
  antigen-bundle --loc=lib
}

-antigen-use-prezto () {
  _zdotdir_set=${+parameters[ZDOTDIR]}
  if (( _zdotdir_set )); then
    _old_zdotdir=$ZDOTDIR
  fi
  ZDOTDIR=$ADOTDIR/repos/

  antigen-bundle $ANTIGEN_PREZTO_REPO_URL
}

_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-$ADOTDIR/init.zsh}"
# Whether to use bundle or reference cache (since v1.4.0)
_ZCACHE_BUNDLE=${_ZCACHE_BUNDLE:-false}

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ANTIGEN_CACHE
#
# This does avoid function-context $0 references.
#
# This does handles the following patterns:
#   $0
#   ${0}
#   ${funcsourcetrace[1]%:*}
#   ${(%):-%N}
#   ${(%):-%x}
#
# Usage
#   -zcache-process-source "/path/to/source" ["theme"|"plugin"]
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
  local src="$1"
  local btype="$2"

  # Removes $0 references globally (exclusively)
  local globals_only='/\{$/,/^\}/!{
    /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
    s/\$(.?)0(.?)/\$\1__ZCACHE_FILE_PATH\2/
  }'

  # Removes funcsourcetrace, and ${%} references globally
  local globals='/.*/{
    /\$.?(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
    s/\$(.?)(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))(.?)/\$\1__ZCACHE_FILE_PATH\4/
  }'

  # Removes `local` from temes globally
  local sed_regexp_themes=''
  if [[ "$btype" == "theme" ]]; then
    themes='/\{$/,/^\}/!{
      s/^local //
    }'
    sed_regexp_themes="-e "$themes
  fi

  cat "$src" | sed -E -e $globals -e $globals_only $sed_regexp_themes
}

# Generates cache from listed bundles.
#
# Iterates over _ANTIGEN_BUNDLE_RECORD and join all needed sources into one,
# if this is done through -antigen-load-list.
# Result is stored in _ANTIGEN_CACHE. Loaded bundles and metadata is stored
# in _ZCACHE_META_PATH.
#
# _ANTIGEN_BUNDLE_RECORD and fpath is stored in cache.
#
# Usage
#   -zcache-generate-cache
#
# Returns
#   Nothing. Generates _ANTIGEN_CACHE
-zcache-generate-cache () {
  local -aU _fpath _PATH
  local _payload="" _sources="" location=""

  for bundle in $_ANTIGEN_BUNDLE_RECORD; do
    # -antigen-load-list "$url" "$loc" "$make_local_clone"
    eval "$(-antigen-parse-bundle ${=bundle})"

    if $make_local_clone; then
      -antigen-ensure-repo "$url"
    fi

    -antigen-load-list "$url" "$loc" "$make_local_clone" | while read line; do
      if [[ -f "$line" ]]; then
        # Whether to use bundle or reference cache
        # Force bundle cache for btype = theme, until PR
        # https://github.com/robbyrussell/oh-my-zsh/pull/3743 is merged.
        if [[ $_ZCACHE_BUNDLE == true || $btype == "theme" ]]; then
          _sources+="#-- SOURCE: $line\NL"
          _sources+=$(-zcache-process-source "$line" "$btype")
          _sources+="\NL;#-- END SOURCE\NL"
        else
          _sources+="source \"$line\";\NL"
        fi
      elif [[ -d "$line" ]]; then
        _PATH+=($line)
      fi
    done

    if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/$loc"
    else
      location="$url/"
    fi

    if [[ -d "$location" ]]; then
      _fpath+=($location)
    fi

    if [[ -d "$location/functions" ]]; then
      _fpath+=($location/functions)
    fi
  done

  _payload="#-- START ZCACHE GENERATED FILE
#-- GENERATED: $(date)
#-- ANTIGEN v1.4.1
$(functions -- _antigen)
antigen () {
  [[ \"\$ZSH_EVAL_CONTEXT\" =~ \"toplevel:*\" || \"\$ZSH_EVAL_CONTEXT\" =~ \"cmdarg:*\" ]] && \
    source \""$_ANTIGEN_INSTALL_DIR/antigen.zsh"\" && \
      eval antigen \$@
}
fpath+=(${_fpath[@]}); PATH=\"\$PATH:${_PATH[@]}\"
_antigen_compinit () {
  autoload -Uz compinit; compinit -C -d \"$_ANTIGEN_COMPDUMP\"; compdef _antigen antigen
  add-zsh-hook -D precmd _antigen_compinit
}
autoload -Uz add-zsh-hook; add-zsh-hook precmd _antigen_compinit
compdef () {}\NL"

  _payload+=$_sources
  _payload+="typeset -aU _ANTIGEN_BUNDLE_RECORD;\
      _ANTIGEN_BUNDLE_RECORD=("$(print ${(qq)_ANTIGEN_BUNDLE_RECORD})")\NL"
  _payload+="_ANTIGEN_CACHE_LOADED=true _ANTIGEN_CACHE_VERSION=v1.4.1\NL"

  # Cache omz/prezto env variables. See https://github.com/zsh-users/antigen/pull/387
  if [[ -n "$ZSH" ]]; then
    _payload+="ZSH=\"$ZSH\" ZSH_CACHE_DIR=\"$ZSH_CACHE_DIR\"\NL";
  fi
  if [[ -n "$ZDOTDIR" ]]; then
    _payload+="ZDOTDIR=\"$ADOTDIR/repos/\"\NL";
  fi
  _payload+="#-- END ZCACHE GENERATED FILE\NL"

  echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$_ANTIGEN_CACHE"
  zcompile "$_ANTIGEN_CACHE"
  
  # Compile config files, if any
  [[ -n $_ANTIGEN_CHECK_FILES ]] && zcompile "$_ANTIGEN_CHECK_FILES"

  return true
}
# Initialize completion
antigen-apply () {
  \rm -f $_ANTIGEN_COMPDUMP

  # Load the compinit module. This will readefine the `compdef` function to
  # the one that actually initializes completions.
  autoload -Uz compinit
  compinit -C -d "$_ANTIGEN_COMPDUMP"
  if [[ ! -f "$_ANTIGEN_COMPDUMP.zwc" ]]; then
    # Apply all `compinit`s that have been deferred.
    for cdef in "${__deferred_compdefs[@]}"; do
      compdef "$cdef"
    done

    zcompile "$_ANTIGEN_COMPDUMP"
  fi

  unset __deferred_compdefs

  if (( _zdotdir_set )); then
    ZDOTDIR=$_old_zdotdir
  else
    unset ZDOTDIR
    unset _old_zdotdir
  fi
  unset _zdotdir_set
  
  -zcache-generate-cache
}
# Syntaxes
#   antigen-bundle <url> [<loc>=/]
# Keyword only arguments:
#   branch - The branch of the repo to use for this bundle.
antigen-bundle () {
  # Bundle spec arguments' default values.
  local url="$ANTIGEN_DEFAULT_REPO_URL"
  local loc=/
  local branch=
  local no_local_clone=false
  local btype=plugin

  if [[ -z "$1" ]]; then
    echo "Antigen: Must provide a bundle url or name."
    return 1
  fi

  eval "$(-antigen-parse-bundle "$@")"

  # Ensure a clone exists for this repo, if needed.
  if $make_local_clone; then
    if ! -antigen-ensure-repo "$url"; then
      # Return immediately if there is an error cloning
      # Error message is displayed from -antigen-ensure-repo
      return 1
    fi
  fi

  # Load the plugin.
  if ! -antigen-load "$url" "$loc" "$make_local_clone" "$btype"; then
    echo "Antigen: Failed to load $btype."
    return 1
  fi

  # Add it to the record.
  _ANTIGEN_BUNDLE_RECORD+=("$url $loc $btype $make_local_clone")
}

antigen-bundles () {
  # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
  # are ignored. Everything else is given to `antigen-bundle` as is, no
  # quoting rules applied.
  local line
  setopt localoptions no_extended_glob # See https://github.com/zsh-users/antigen/issues/456
  grep '^[[:space:]]*[^[:space:]#]' | while read line; do
    antigen-bundle ${=line%#*}
  done
}
# Generate static-cache file at $_ANTIGEN_CACHE using currently loaded
# bundles from $_ANTIGEN_BUNDLE_RECORD
#
# Usage
#   antigen-cache-gen
#
# Returns
#   Nothing
antigen-cache-gen () {
  -zcache-generate-cache
}
# Cleanup unused repositories.
antigen-cleanup () {
  local force=false
  if [[ $1 == --force ]]; then
    force=true
  fi

  if [[ ! -d "$ADOTDIR/repos" || -z "$(\ls "$ADOTDIR/repos/")" ]]; then
    echo "You don't have any bundles."
    return 0
  fi

  # Find directores in ADOTDIR/repos, that are not in the bundles record.
  local unused_clones="$(comm -13 \
    <(-antigen-echo-record |
      awk '$4 == "true" {print $1}' |
      while read line; do
        -antigen-get-clone-dir "$line"
      done |
      sort -u) \
    <(\ls -d "$ADOTDIR/repos/"* | sort -u))"

  if [[ -z $unused_clones ]]; then
    echo "You don't have any unidentified bundles."
    return 0
  fi

  echo 'You have clones for the following repos, but are not used.'
  echo "$unused_clones" |
    while read line; do
      -antigen-get-clone-url "$line"
    done |
    sed -e 's/^/  /' -e 's/|/, branch /'

  if $force || (echo -n '\nDelete them all? [y/N] '; read -q); then
    echo
    echo
    echo "$unused_clones" | while read line; do
      echo -n "Deleting clone for $(-antigen-get-clone-url "$line")..."
      rm -rf "$line"
      echo ' done.'
    done
  else
    echo
    echo Nothing deleted.
  fi
}

antigen-help () {
  cat <<EOF
Antigen is a plugin management system for zsh. It makes it easy to grab awesome
shell scripts and utilities, put up on github. For further details and complete
documentation, visit the project's page at 'http://antigen.sharats.me'.

EOF
  antigen-version
}
# Antigen command to load antigen configuration
#
# This method is slighlty more performing than using various antigen-* methods.
#
# Usage
#   Referencing an antigen configuration file:
#
#       antigen-init "/path/to/antigenrc"
#
#   or using HEREDOCS:
#
#       antigen-init <<EOBUNDLES
#           antigen use oh-my-zsh
#
#           antigen bundle zsh/bundle
#           antigen bundle zsh/example
#
#           antigen theme zsh/theme
#
#           antigen apply
#       EOBUNDLES
#
# Returns
#   Nothing
antigen-init () {
  local src="$1"

  # If we're given an argument it should be a path to a file
  if [[ -n "$src" ]]; then
    if [[ -f "$src" ]]; then
      source "$src"
      return
    else
      echo "Antigen: invalid argument provided.";
      return 1
    fi
  fi

  # Otherwise we expect it to be a heredoc
  grep '^[[:space:]]*[^[:space:]#]' | while read -r line; do
    eval $line
  done
}

# List instaled bundles either in long (record), short or simple format.
#
# Usage
#    antigen-list [--short|--long|--simple]
#
# Returns
#    List of bundles
antigen-list () {
  local format=$1

  # List all currently installed bundles.
  if [[ -z $_ANTIGEN_BUNDLE_RECORD ]]; then
    echo "You don't have any bundles." >&2
    return 1
  fi

  -antigen-get-bundles $format
}
# Remove a bundle from filesystem
#
# Usage
#   antigen-purge example/bundle [--force]
#
# Returns
#   Nothing. Removes bundle from filesystem.
antigen-purge () {
  local bundle=$1
  local force=$2

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  if -antigen-purge-bundle $bundle $force; then
    antigen-reset
  else
    return $?
  fi

  return 0
}

# Remove a bundle from filesystem
#
# Usage
#   antigen-purge example/bundle [--force]
#
# Returns
#   Nothing. Removes bundle from filesystem.
-antigen-purge-bundle () {
  local bundle=$1
  local force=$2
  local clone_dir=""

  local record=""
  local url=""
  local make_local_clone=""

  if [[ $# -eq 0  ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi

  # local keyword doesn't work on zsh <= 5.0.0
  record=$(-antigen-find-record $bundle)
  
  if [[ ! -n "$record" ]]; then
    echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
    return 1
  fi

  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be removed."
    return 1
  fi

  clone_dir=$(-antigen-get-clone-dir "$url")
  if [[ $force == "--force" ]] || read -q "?Remove '$clone_dir'? (y/n) "; then
    # Need empty line after read -q
    [[ ! -n $force ]] && echo "" || echo "Removing '$clone_dir'.";
    rm -rf "$clone_dir"
    return $?
  fi

  return 1
}
# Removes cache payload and metadata if available
#
# Usage
#   antigen-reset
#
# Returns
#   Nothing
antigen-reset () {
  [[ -f "$_ANTIGEN_CACHE" ]] && rm -f "$_ANTIGEN_CACHE"
  echo 'Done. Please open a new shell to see the changes.'
}
antigen-restore () {
  if [[ $# == 0 ]]; then
    echo 'Please provide a snapshot file to restore from.' >&2
    return 1
  fi

  local snapshot_file="$1"

  # TODO: Before doing anything with the snapshot file, verify its checksum.
  # If it fails, notify this to the user and confirm if restore should
  # proceed.

  echo -n "Restoring from $snapshot_file..."

  sed -n '1!p' "$snapshot_file" |
    while read line; do
      local version_hash="${line%% *}"
      local url="${line##* }"
      local clone_dir="$(-antigen-get-clone-dir "$url")"

      if [[ ! -d $clone_dir ]]; then
          git clone "$url" "$clone_dir" &> /dev/null
      fi

      (cd "$clone_dir" && git checkout $version_hash) &> /dev/null
    done

  echo ' done.'
  echo 'Please open a new shell to get the restored changes.'
}

# Reads $ADORDIR/revert-info and restores bundles' revision
antigen-revert () {
  if [[ -f $ADOTDIR/revert-info ]]; then
    cat $ADOTDIR/revert-info | sed -n '1!p' | while read line; do
      local dir="$(echo "$line" | cut -d: -f1)"
      git --git-dir="$dir/.git" --work-tree="$dir" \
        checkout "$(echo "$line" | cut -d: -f2)" 2> /dev/null
    done

    echo "Reverted to state before running -update on $(
            cat $ADOTDIR/revert-info | sed -n '1p')."

  else
    echo 'No revert information available. Cannot revert.' >&2
    return 1
  fi
}

# Update (with `git pull`) antigen itself.
# TODO: Once update is finished, show a summary of the new commits, as a kind of
# "what's new" message.
antigen-selfupdate () {
  ( cd $_ANTIGEN_INSTALL_DIR
   if [[ ! ( -d .git || -f .git ) ]]; then
     echo "Your copy of antigen doesn't appear to be a git clone. " \
       "The 'selfupdate' command cannot work in this case."
     return 1
   fi
   local head="$(git rev-parse --abbrev-ref HEAD)"
   if [[ $head == "HEAD" ]]; then
     # If current head is detached HEAD, checkout to master branch.
     git checkout master
   fi
   git pull

   # TODO Should be transparently hooked by zcache
   antigen-reset &>> /dev/null
  )
}
antigen-snapshot () {
  local snapshot_file="${1:-antigen-shapshot}"

  # The snapshot content lines are pairs of repo-url and git version hash, in
  # the form:
  #   <version-hash> <repo-url>
  local snapshot_content="$(
    -antigen-echo-record |
    awk '$4 == "true" {print $1}' |
    sort -u |
    while read url; do
      local dir="$(-antigen-get-clone-dir "$url")"
      local version_hash="$(cd "$dir" && git rev-parse HEAD)"
      echo "$version_hash $url"
    done)"

  {
    # The first line in the snapshot file is for metadata, in the form:
    #   key='value'; key='value'; key='value';
    # Where `key`s are valid shell variable names.

    # Snapshot version. Has no relation to antigen version. If the snapshot
    # file format changes, this number can be incremented.
    echo -n "version='1';"

    # Snapshot creation date+time.
    echo -n " created_on='$(date)';"

    # Add a checksum with the md5 checksum of all the snapshot lines.
    chksum() { (md5sum; test $? = 127 && md5) 2>/dev/null | cut -d' ' -f1 }
    local checksum="$(echo "$snapshot_content" | chksum)"
    unset -f chksum;
    echo -n " checksum='${checksum%% *}';"

    # A newline after the metadata and then the snapshot lines.
    echo "\n$snapshot_content"

  } > "$snapshot_file"
}

# Loads a given theme.
#
# Shares the same syntax as antigen-bundle command.
#
# Usage
#   antigen-theme zsh/theme[.zsh-theme]
#
# Returns
#   0 if everything was succesfully
antigen-theme () {
  local record
  local result=0

  -antigen-theme-reset-hooks

  record=$(-antigen-find-record "theme")

  if [[ "$1" != */* && "$1" != --* ]]; then
    # The first argument is just a name of the plugin, to be picked up from
    # the default repo.
    local name="${1:-robbyrussell}"
    antigen-bundle --loc=themes/$name --btype=theme

  else
    antigen-bundle "$@" --btype=theme

  fi
  result=$?

  # Remove a theme from the record if the following conditions apply:
  #   - there was no error in bundling the given theme
  #   - there is a theme registered
  #   - registered theme is not the same as the current one
  if [[ $result == 0 && -n $record ]]; then
    # http://zsh-workers.zsh.narkive.com/QwfCWpW8/what-s-wrong-with-this-expression
    if [[ "$record" =~ "$@" ]]; then
      return $result
    else
      _ANTIGEN_BUNDLE_RECORD[$_ANTIGEN_BUNDLE_RECORD[(I)$record]]=()
    fi
  fi

  return $result
}

-antigen-theme-reset-hooks () {
  # This is only needed on interactive mode
  autoload -U add-zsh-hook is-at-least
  local hook

  # Clear out prompts
  PROMPT=""
  RPROMPT=""

  for hook in chpwd precmd preexec periodic; do
    add-zsh-hook -D "${hook}" "prompt_*"
    # common in omz themes
    add-zsh-hook -D "${hook}" "*_${hook}" 
    add-zsh-hook -d "${hook}" "vcs_info"
  done
}

# Updates the bundles or a single bundle.
#
# Usage
#    antigen-update [example/bundle]
#
# Returns
#    Nothing. Performs a `git pull`.
antigen-update () {
  local bundle=$1

  # Clear log
  :> $_ANTIGEN_LOG

  # Update revert-info data
  -antigen-revert-info

  # If no argument is given we update all bundles
  if [[ $# -eq 0  ]]; then
    # Here we're ignoring all non cloned bundles (ie, --no-local-clone)
    -antigen-get-cloned-bundles | while read url; do
      -antigen-update-bundle $url
    done
    # TODO next minor version
    # antigen-reset
  else
    if -antigen-update-bundle $bundle; then
      # TODO next minor version
      # antigen-reset
    else
      return $?
    fi
  fi
}

# Updates a bundle performing a `git pull`.
#
# Usage
#    -antigen-update-bundle example/bundle
#
# Returns
#    Nothing. Performs a `git pull`.
-antigen-update-bundle () {
  local bundle="$1"
  local record=""
  local url=""
  local make_local_clone=""
  
  if [[ $# -eq 0 ]]; then
    echo "Antigen: Missing argument."
    return 1
  fi
  
  record=$(-antigen-find-record $bundle)
  if [[ ! -n "$record" ]]; then
    echo "Bundle not found in record. Try 'antigen bundle $bundle' first."
    return 1
  fi
  
  url="$(echo "$record" | cut -d' ' -f1)"
  make_local_clone=$(echo "$record" | cut -d' ' -f4)

  if [[ $make_local_clone == "false" ]]; then
    echo "Bundle has no local clone. Will not be updated."
    return 1
  fi

  # update=true verbose=false
  if ! -antigen-ensure-repo "$url" true false; then
    return 1
  fi
}
antigen-use () {
  if [[ $1 == oh-my-zsh ]]; then
    -antigen-use-oh-my-zsh
  elif [[ $1 == prezto ]]; then
    -antigen-use-prezto
  elif [[ $1 != "" ]]; then
    ANTIGEN_DEFAULT_REPO_URL=$1
    antigen-bundle $@
  else
    echo 'Usage: antigen-use <library-name|url>' >&2
    echo 'Where <library-name> is any one of the following:' >&2
    echo ' * oh-my-zsh' >&2
    echo ' * prezto' >&2
    echo '<url> is the full url.' >&2
    return 1
  fi
}

antigen-version () {
  echo "Antigen v1.4.1"
}

#compdef _antigen
# Setup antigen's autocompletion
_antigen () {
  local -a _1st_arguments
  _1st_arguments=(
    'apply:Load all bundle completions'
    'bundle:Install and load the given plugin'
    'bundles:Bulk define bundles'
    'cleanup:Clean up the clones of repos which are not used by any bundles currently loaded'
    'cache-gen:Generate cache'
    'init:Load Antigen configuration from file'
    'list:List out the currently loaded bundles'
    'purge:Remove a cloned bundle from filesystem'
    'reset:Clears cache'
    'restore:Restore the bundles state as specified in the snapshot'
    'revert:Revert the state of all bundles to how they were before the last antigen update'
    'selfupdate:Update antigen itself'
    'snapshot:Create a snapshot of all the active clones'
    'theme:Switch the prompt theme'
    'update:Update all bundles'
    'use:Load any (supported) zsh pre-packaged framework'
  );

  _1st_arguments+=(
    'help:Show this message'
    'version:Display Antigen version'
  )

  __bundle() {
    _arguments \
      '--loc[Path to the location <path-to/location>]' \
      '--url[Path to the repository <github-account/repository>]' \
      '--branch[Git branch name]' \
      '--no-local-clone[Do not create a clone]'
  }
  __list() {
    _arguments \
      '--simple[Show only bundle name]' \
      '--short[Show only bundle name and branch]' \
      '--long[Show bundle records]'
  }


  __cleanup() {
    _arguments \
      '--force[Do not ask for confirmation]'
  }

  _arguments '*:: :->command'

  if (( CURRENT == 1 )); then
    _describe -t commands "antigen command" _1st_arguments
    return
  fi

  local -a _command_args
  case "$words[1]" in
    bundle)
      __bundle
      ;;
    use)
      compadd "$@" "oh-my-zsh" "prezto"
      ;;
    cleanup)
      __cleanup
      ;;
    (update|purge)
      compadd $(type -f \-antigen-get-bundles &> /dev/null || antigen &> /dev/null; -antigen-get-bundles --simple 2> /dev/null)
      ;;
    theme)
      compadd $(type -f \-antigen-get-themes &> /dev/null || antigen &> /dev/null; -antigen-get-themes 2> /dev/null)
      ;;
    list)
      __list
    ;;
  esac
}

-antigen-env-setup
