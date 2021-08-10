# Append active gcloud config in Bash terminal prompt.
#
# For configuration names containing prod, the prompt is colored red for extra visibility.

function gcloud_prompt() {

  # Store original prompt.
  if [[ "${ORIG_PS1}" == "" ]]; then
    export ORIG_PS1=$PS1
  fi

  # Lookup active gcloud config.
  active=$(gcloud config configurations list --format='value(name)' --filter='IS_ACTIVE=true')

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
