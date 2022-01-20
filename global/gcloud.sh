# Paths to Google Cloud SDK and the user's config.
gcloud="$HOME/.cache/cloud-code/installer/google-cloud-sdk"
config="$HOME/.config/gcloud"

# The next line updates PATH for the Google Cloud SDK.
source "$gcloud/path.bash.inc"

# The next line enables shell command completion for gcloud.
source "$gcloud/completion.bash.inc"

# Append active gcloud config in Bash terminal prompt. For configuration names
# containing "prod", the prompt is colored red for extra visibility.
function gcloud_prompt() {

  # Store original prompt.
  if [[ "${ORIG_PS1}" == "" ]]; then
    export ORIG_PS1=$PS1
  fi

  # Lookup active gcloud config. We look at the internal state directly to avoid starting gcloud on every terminal prompt.
  active=$(cat $config/active_config)

  # Color prompt based on gcloud config name.
  if [[ "${active}" == *'prod'* ]]; then
    active="\e[0;31m[${active}]\e[m "
  else
    active="[${active}] "
  fi

  # Set prompt.
  export PS1="${ORIG_PS1}${active}"
}

export PROMPT_COMMAND=gcloud_prompt
