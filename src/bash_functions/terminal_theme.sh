#  -*- mode: unix-shell-script; -*-

# Specify terminal themes for directory colors
# man ls -> find LSCOLORS
#     LSCOLORS        The value of this variable describes what color to use
#                      for which attribute when colors are enabled with
#                      CLICOLOR.  This string is a concatenation of pairs of the
#                      format fb, where f is the foreground color and b is the
#                      background color.
# 
#                      The color designators are as follows:
# 
#                            a     black
#                            b     red
#                            c     green
#                            d     brown
#                            e     blue
#                            f     magenta
#                            g     cyan
#                            h     light grey
#                            A     bold black, usually shows up as dark grey
#                            B     bold red
#                            C     bold green
#                            D     bold brown, usually shows up as yellow
#                            E     bold blue
#                            F     bold magenta
#                            G     bold cyan
#                            H     bold light grey; looks like bright white
#                            x     default foreground or background
# 
#                      Note that the above are standard ANSI colors.  The actual
#                      display may differ depending on the color capabilities of
#                      the terminal in use.
# 
#                      The order of the attributes are as follows:
# 
#                            1.   directory
#                            2.   symbolic link
#                            3.   socket
#                            4.   pipe
#                            5.   executable
#                            6.   block special
#                            7.   character special
#                            8.   executable with setuid bit set
#                            9.   executable with setgid bit set
#                            10.  directory writable to others, with sticky bit
#                            11.  directory writable to others, without sticky
#                                 bit
# 
#                      The default is "exfxcxdxbxegedabagacad", i.e. blue fore-
#                      ground and default background for regular directories,
#                      black foreground and red background for setuid executa-
#                      bles, etc.

termtheme() {
	case $(uname) in	
	Darwin)
		_macos_termtheme $1
		;;
 	esac
}

_macos_termtheme() {
	export CLICOLOR=1
	case "${1}" in
	appledark)
		#               d l s p e b c e e d d
		#                 n     x s s u g s w
		export LSCOLORS=dxfxcxdxDxegedabagacad
		;;
	light)
		export LSCOLORS=exfxcxdxbxegedabagacad
		;;
	lightbold)
		export LSCOLORS=ExFxCxDxBxegedabagacad
		;;
	dark)
		export LSCOLORS=gxfxcxdxbxegedabagacad
		;;
	darkbold)
		export LSCOLORS=GxFxCxDxBxegedabagaced
		;;
	df)
		export LSCOLORS=CxGxcxdxBxegedabagacad
		;;
	panic)
		# Panic palette
		export LSCOLORS=GxFxCxDxBxegedabagaced
		;;
	oceandark)
		# Base16 ocean dark
		#               d l s p e b c e e d d
		#                 n     x s s u g s w
		export LSCOLORS=HxCxFxdxbxegedabagacad
		;;
	solarized)
		# Solarized
		export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
		;;
	*)
		printf "terminal_theme [light | lightbold | dark | darkbold | df | panic | oceandark | solarized]\n"
		return
		;;
	esac
}