#  -*- mode: unix-shell-script; -*-

# Mail file as attachment: <filepath> <subject> <recipient>
mailattach() {
	uuencode ${1} `basename $1` | mail -s "${2}" ${3}
}

