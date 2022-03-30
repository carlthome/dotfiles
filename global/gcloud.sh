# Paths to Google Cloud SDK and its config.
gcloud="$HOME/.cache/cloud-code/installer/google-cloud-sdk"
config="$HOME/.config/gcloud"

# The next line updates PATH for the Google Cloud SDK.
source "$gcloud/path.bash.inc"

# The next line enables shell command completion for gcloud.
source "$gcloud/completion.bash.inc"

# Append active gcloud config in Bash terminal prompt.
PS1='[$(cat $config/active_config)] '"${PS1}"
export PS1
