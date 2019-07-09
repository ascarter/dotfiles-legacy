#  -*- mode: unix-shell-script; -*-

resetaudio() {
	sudo killall coreaudiod
}

resetvideo() {
	sudo killall VDCAssistant
	sudo killall AppleCameraAssistant
}

resetav() {
	resetaudio
	resetvideo
}
