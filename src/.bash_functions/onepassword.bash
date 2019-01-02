#  -*- mode: unix-shell-script; -*-

# Signin to 1Password
opsignin() {
	eval "$(op signin $*)"
}
