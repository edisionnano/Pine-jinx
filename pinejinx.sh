#!/usr/bin/env sh
# Prepare environment
rm -rf /tmp/pineapple
mkdir -p /tmp/pineapple && cd /tmp/pineapple
#Define the functions
getoptions() {
	if ! [ "$(command -v gamemoderun)" ]; then
		printf "Warning:Gamemode not found!\nIf you want to use it you'll have to install it.\n"
		printf "\e[91m$(tput bold)This means that if you choose Y you will have to install it manually yourself (sudo pacman -Syu gamemode on arch)!\e[0m\n"
	fi
	printf "Gamemode is a tool that improves performance on non custom kernels.\n"
	read -p "Do you want to use it? [y/N]: " gamemode
	read -p "Optimize Ryujinx for 1)Nvidia 2)Intel and AMD 3)None: " gpuopt
	if [ "$gpuopt" = "2" ]; then
		printf "MESA_NO_ERROR can give performance boosts in games but potentially crash others (very rare).\n"
		read -p "Do you want to use it? [y/N]: " mesanoerror
	fi
	read -p "Do you want to disable the console window? [y/N]: " console
	read -p "Do you want PineJinx to setup an alias for ryujinx? [y/N]: " alias
}
makealias() {
    ryualias='alias ryujinx="'$arg' COMPlus_EnableAlternateStackCheck=1 GDK_BACKEND=x11 /home/'${USER}'/.local/share/Ryujinx/Ryujinx"'
    if [ -z "${SHELL##*zsh*}" ]; then
        printf "Detected shell: ZSH\n"
        FILE="/home/${USER}/.zshrc"
    elif [ -z "${SHELL##*bash*}" ]; then
        printf "Detected shell: BASH\n"
        FILE="/home/${USER}/.bashrc"
    else
        printf "Unsupported shell, no alias will be created!\n"
        return 1
    fi
    if [ -f $FILE ]; then
        sed -i '/alias ryujinx/d' $FILE
        echo $ryualias >> $FILE
    else
        printf "$FILE does not exist, creating new file..."
        echo $ryualias > $FILE
    fi
    printf "Alias created successfully, use the command ryujinx the next time you open your terminal.\n"
}
removealias() {
    if [ -z "${SHELL##*zsh*}" ]; then
        FILE="/home/${USER}/.zshrc"
    elif [ -z "${SHELL##*bash*}" ]; then
        FILE="/home/${USER}/.bashrc"
    else
        return 1
    fi
    sed -i '/alias ryujinx/d' $FILE
}
install() {
	printf "Downloading $version...\n"
	curl -L "https://github.com/Ryujinx/release-channel-master/releases/download/${version}/ryujinx-${version}-linux_x64.tar.gz" > ryujinx-${version}-linux_x64.tar.gz
	tar -xf ryujinx-${version}-linux_x64.tar.gz
	arch_dir=$(tar --exclude='*/*' -tf ryujinx-${version}-linux_x64.tar.gz)
	if [ -d "$arch_dir" ]; then
		printf "Extraction successful!\n"
		mkdir -p /home/${USER}/.local/share/Ryujinx
		cp -a $arch_dir/. /home/${USER}/.local/share/Ryujinx
	else
		printf "Extraction failed!\nAborting...\n"
		exit
	fi
	curl -s -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.desktop" > Ryujinx.desktop
	curl -s -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.png" > Ryujinx.png
	curl -s -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.xml" > Ryujinx.xml
	if [ "$noconfirm" = "1" ]; then
		:
	else
		getoptions
	fi
	if [ "$gamemode" = "y" ] || [ "$gamemode" = "Y" ]; then
		arg1="gamemoderun "
		curl -s -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/gamemode.ini" > /home/${USER}/.config/gamemode.ini
	else
		arg1=""
	fi
	if [ "$gpuopt" = "1" ]; then
		arg2="__GL_THREADED_OPTIMIZATIONS=0 __GL_SYNC_TO_VBLANK=0 "
	elif [ "$gpuopt" = "2" ]; then
		arg2="AMD_DEBUG=w32ge,w32cs,nohyperz,nofmask glsl_zero_init=true radeonsi_clamp_div_by_zero=true force_integer_tex_nearest=true mesa_glthread=false vblank_mode=0 RADV_PERFTEST=bolist "
		if [ "$mesanoerror" = "y" ] || [ "$mesanoerror" = "Y" ]; then
            arg3="MESA_NO_ERROR=1 "
        else
            arg3=""
        fi
	else
		arg2=''
	fi
	arg=$(echo "$arg2$arg3$arg1"|sed 's/ *$//')
	if [ "$console" = "y" ] || [ "$console" = "Y" ]; then
		sed -i "s/Terminal=true/Terminal=false/g" Ryujinx.desktop
	fi
	if [ "$alias" = "y" ] || [ "$alias" = "Y" ]; then
		makealias
	else
		:
	fi
    #Desktop entries do not accept relative paths so the user's name must be in the file
	sed -i "s/dummy/${USER}/g" Ryujinx.desktop
	#Append any optimizations
	sed -i "s/x11/x11 ${arg}/" Ryujinx.desktop
	#Place desktop entry
	mkdir -p /home/${USER}/.local/share/applications && cp Ryujinx.desktop /home/${USER}/.local/share/applications
	#Place icon
	mkdir -p /home/${USER}/.local/share/icons && cp Ryujinx.png /home/${USER}/.local/share/icons
	#Place mime entry
	mkdir -p /home/${USER}/.local/share/mime/packages && cp Ryujinx.xml /home/${USER}/.local/share/mime/packages
	#Set the rights
	chmod +x /home/${USER}/.local/share/Ryujinx/Ryujinx
	#Update the MIME database
	update-mime-database /home/${USER}/.local/share/mime
	#Update the application database
	update-desktop-database /home/${USER}/.local/share/applications
	printf "Installation successful, launch Ryujinx from your app launcher.\n"
	printf "Also don't forget to show your love on Patreon at https://www.patreon.com/ryujinx\n"
}
uninstall() {
	printf "Uninstalling..."
	rm -rf /home/${USER}/.local/share/Ryujinx
	rm -rf /home/${USER}/.local/share/mime/packages/Ryujinx.xml
	rm -rf /home/${USER}/.local/share/applications/Ryujinx.desktop
	rm -rf /home/${USER}/.local/share/icons/Ryujinx.png
	rm -rf /home/${USER}/.config/gamemode.ini
	update-mime-database /home/${USER}/.local/share/mime
	update-desktop-database /home/${USER}/.local/share/applications
	printf "\nUninstallation successful!\n"
	removealias
}
clear
if [ "$option" != "2" ]; then
	printf "Welcome to PinEApple-Ryujinx\n"
	printf "Fetching latest version info from the Github release page...\n"
	version=$(curl -s https://api.github.com/repos/Ryujinx/release-channel-master/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	printf "Latest version is: $version\n"
fi
if [ -n "$option" ]; then
	:
else
	printf "[1] Install it\n"
	printf "[2] Uninstall\n"
	printf "[3] Reinstall\Repair\n"
	printf "[4] LDN version\n"
	read -p "Choose an option (or anything else to quit): " option
fi
if [ "$option" = "1" ]; then
	install
elif [ "$option" = "2" ]; then
	uninstall
elif [ "$option" = "3" ]; then
	uninstall
	install
elif [ "$option" = "4" ]; then
	bash -c "$(curl -s https://raw.githubusercontent.com/edisionnano/Pine-jinx/LDN/pinejinx.sh)"
else
	:
fi
exit
