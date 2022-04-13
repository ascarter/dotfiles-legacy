# Mail file as attachment: <filepath> <subject> <recipient>

emulate -L zsh

uuencode ${1} `basename $1` | mail -s "${2}" ${3}

