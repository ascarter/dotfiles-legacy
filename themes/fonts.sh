#!/bin/sh

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local i=1
    local length="${#1}"
    while [ $i -le $length ]
    do
        local c=$(echo "$(expr substr $1 $i 1)")
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf "%%20" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
        i=`expr $i + 1`
    done

    LC_COLLATE=$old_lc_collate
}

install_google_font() {
  # $1 == license
  # $2 == font family
  # $3 == font file
  # $4 == font source file
  echo "Installing ${2} ${3}"
  fontfile=~/.local/share/fonts/${2}/${3}
  mkdir -p $(dirname ${fontfile})
  curl -fsSL -o ${fontfile} https://raw.githubusercontent.com/google/fonts/master/${1}/${2}/$(urlencode ${4:-$3})
}

# Google fonts

install_google_font ofl firacode FiraCode.ttf 'FiraCode[wght].ttf'

install_google_font ofl firamono FiraMono-Bold.ttf
install_google_font ofl firamono FiraMono-Medium.ttf
install_google_font ofl firamono FiraMono-Regular.ttf

install_google_font ofl firasans FiraSans-Black.ttf
install_google_font ofl firasans FiraSans-BlackItalic.ttf
install_google_font ofl firasans FiraSans-Bold.ttf
install_google_font ofl firasans FiraSans-BoldItalic.ttf
install_google_font ofl firasans FiraSans-ExtraBold.ttf
install_google_font ofl firasans FiraSans-ExtraBoldItalic.ttf
install_google_font ofl firasans FiraSans-ExtraLight.ttf
install_google_font ofl firasans FiraSans-ExtraLightItalic.ttf
install_google_font ofl firasans FiraSans-Italic.ttf
install_google_font ofl firasans FiraSans-Light.ttf
install_google_font ofl firasans FiraSans-LightItalic.ttf
install_google_font ofl firasans FiraSans-Medium.ttf
install_google_font ofl firasans FiraSans-MediumItalic.ttf
install_google_font ofl firasans FiraSans-Regular.ttf
install_google_font ofl firasans FiraSans-SemiBold.ttf
install_google_font ofl firasans FiraSans-SemiBoldItalic.ttf
install_google_font ofl firasans FiraSans-Thin.ttf
install_google_font ofl firasans FiraSans-ThinItalic.ttf

install_google_font ofl firasanscondensed FiraSansCondensed-Black.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-BlackItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Bold.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-BoldItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-ExtraBold.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-ExtraBoldItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-ExtraLight.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-ExtraLightItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Italic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Light.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-LightItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Medium.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-MediumItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Regular.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-SemiBold.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-SemiBoldItalic.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-Thin.ttf
install_google_font ofl firasanscondensed FiraSansCondensed-ThinItalic.ttf

install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Black.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-BlackItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Bold.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-BoldItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-ExtraBold.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-ExtraBoldItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-ExtraLight.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-ExtraLightItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Italic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Light.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-LightItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Medium.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-MediumItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Regular.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-SemiBold.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-SemiBoldItalic.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-Thin.ttf
install_google_font ofl firasansextracondensed FiraSansExtraCondensed-ThinItalic.ttf

install_google_font apache roboto Roboto-Italic.ttf 'Roboto-Italic[wdth,wght].ttf'
install_google_font apache roboto Roboto.ttf 'Roboto[wdth,wght].ttf'

install_google_font apache robotomono RobotoMono-Italic.ttf 'RobotoMono-Italic[wght].ttf'
install_google_font apache robotomono RobotoMono.ttf 'RobotoMono[wght].ttf'

install_google_font ofl robotoserif RobotoSerif-Italic.ttf 'RobotoSerif-Italic[GRAD,opsz,wdth,wght].ttf'
install_google_font ofl robotoserif RobotoSerif.ttf 'RobotoSerif[GRAD,opsz,wdth,wght].ttf'

install_google_font apache robotoslab RobotoSlab.ttf 'RobotoSlab[wght].ttf'
