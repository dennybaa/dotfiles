. ~/.shell/functions

# We are not using global zprofile, so we need to populate env
. ~/.shell/env

# Load shell tools (cleanup functions in the end)
. ~/.shell/load && shell-cleanup
