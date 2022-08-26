#!/usr/bin/env sh
# Prepare environment
find /tmp/pineapple/* ! -name '*.tar.gz' 2>/dev/null | sort -n -r | xargs rm -rf --
mkdir -p /tmp/pineapple && cd /tmp/pineapple
#Define the functions
makealias() {
    ryualias='alias ryuldn="'$arg' GDK_BACKEND=x11 /home/'${USER}'/.local/share/Ryujinx_LDN/Ryujinx"'
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
        sed -i '/alias ryuldn/d' $FILE
        echo $ryualias >> $FILE
    else
        printf "$FILE does not exist, creating new file..."
        echo $ryualias > $FILE
    fi
    printf "Alias created successfully, use the command ryuldn the next time you open your terminal.\n"
}
removealias() {
    if [ -z "${SHELL##*zsh*}" ]; then
        FILE="/home/${USER}/.zshrc"
    elif [ -z "${SHELL##*bash*}" ]; then
        FILE="/home/${USER}/.bashrc"
    else
        return 1
    fi
    sed -i '/alias ryuldn/d' $FILE
}
install () {
	printf "Downloading $version...\n"
	curl -L "https://www.patreon.com/file?h=70757628&i=11545814" > ryujinx-1.0.0-ldn2.5-linux_x64.tar.gz
	tar -xf ryujinx-1.0.0-ldn2.5-linux_x64.tar.gz
	arch_dir=$(tar --exclude='*/*' -tf ryujinx-1.0.0-ldn2.5-linux_x64.tar.gz)
	if [ -d "$arch_dir" ]; then
		printf "Extraction successful!\n"
		mkdir -p /home/${USER}/.local/share/Ryujinx_LDN
		cp -a $arch_dir/. /home/${USER}/.local/share/Ryujinx_LDN
	else
		printf "Extraction failed!\nAborting...\n"
		exit
	fi
	curl -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/LDN/Ryujinx_LDN.desktop" > Ryujinx_LDN.desktop
	curl -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/LDN/Ryujinx_LDN.png" > Ryujinx_LDN.png
	curl -L "https://raw.githubusercontent.com/edisionnano/Pine-jinx/LDN/Ryujinx_LDN.xml" > Ryujinx_LDN.xml
	if ! [ "$(command -v gamemoderun)" ]; then
		printf "Warning:Gamemode not found!\nIf you want to use it you'll have to install it.\n"
		printf "\e[91m$(tput bold)This means that if you choose Y you will have to install it manually yourself (sudo pacman -Syu gamemode on arch)!\e[0m\n"
	fi
	printf "Gamemode is a tool that improves performance on non custom kernels.\n"
	read -p "Do you want to use it? [y/N]: " gamemode
	if [ "$gamemode" = "y" ] || [ "$gamemode" = "Y" ]; then
		arg1="gamemoderun "
	else
		arg1=""
	fi
	read -p "Optimize Ryujinx LDN for 1)Nvidia 2)Intel and AMD 3)None: " gpuopt
	if [ "$gpuopt" = "1" ]; then
		arg2='env __GL_THREADED_OPTIMIZATIONS=1 __GL_SYNC_TO_VBLANK=0 '
	elif [ "$gpuopt" = "2" ]; then
		arg2="env AMD_DEBUG=w32ge,w32ps,w32cs R600_DEBUG=nohyperz glsl_zero_init=true radeonsi_clamp_div_by_zero=true mesa_glthread=true vblank_mode=0 "
		printf "MESA_NO_ERROR can give performance boosts in games like Monster Hunter Rise and Animal Crossing but potentially break others like Splaton 2\n"
		read -p "Do you want to use it? [y/N]: " mesanoerror
		if [ "$mesanoerror" = "y" ] || [ "$mesanoerror" = "Y" ]; then
            arg3="MESA_NO_ERROR=1 "
        else
            arg3=""
        fi
	else
		arg2=''
	fi
	arg="$arg2$arg3$arg1"
	read -p "Do you want to disable the console window? [y/N]: " console
	if [ "$console" = "y" ] || [ "$console" = "Y" ]; then
		sed -i "s/Terminal=true/Terminal=false/g" Ryujinx.desktop
	fi
	#Desktop entries do not accept relative paths so the user's name must be in the file
	sed -i "s/dummy/${USER}/g" Ryujinx_LDN.desktop
	#Append any optimizations
	sed -i "s/^Exec=/Exec=${arg}/" Ryujinx_LDN.desktop
	#Place desktop entry
	mkdir -p /home/${USER}/.local/share/applications && cp Ryujinx_LDN.desktop /home/${USER}/.local/share/applications
	#Place icon
	mkdir -p /home/${USER}/.local/share/icons && cp Ryujinx_LDN.png /home/${USER}/.local/share/icons
	#Place mime entry
	mkdir -p /home/${USER}/.local/share/mime/packages && cp Ryujinx_LDN.xml /home/${USER}/.local/share/mime/packages
	#Set the rights
	chmod +x /home/${USER}/.local/share/Ryujinx_LDN/Ryujinx
	#Update the MIME database
	update-mime-database /home/${USER}/.local/share/mime
	#Update the application database
	update-desktop-database /home/${USER}/.local/share/applications
	read -p "Do you want PineJinx to setup an alias for Ryujinx LDN? [y/N]: " alias
	if [ "$alias" = "y" ] || [ "$alias" = "Y" ]; then
		makealias
	else
		:
	fi
	printf "Installation successful, launch Ryujinx from your app launcher.\n"
	printf "Also don't forget to show your love on Patreon at https://www.patreon.com/ryujinx\n"
}
uninstall () {
	printf "Uninstalling..."
	rm -rf /home/${USER}/.local/share/Ryujinx_LDN
	rm -rf /home/${USER}/.local/share/mime/packages/Ryujinx_LDN.xml
	rm -rf /home/${USER}/.local/share/applications/Ryujinx_LDN.desktop
	rm -rf /home/${USER}/.local/share/icons/Ryujinx_LDN.png
	update-mime-database /home/${USER}/.local/share/mime
	update-desktop-database /home/${USER}/.local/share/applications
	printf "\nUninstallation successful!\n"
	removealias

}
printf "Welcome to PinEApple-Ryujinx LDN\n"
printf "Latest LDN version is: 2.5\n"
printf "[1] Install it\n"
printf "[2] Uninstall\n"
printf "[3] Reinstall\Repair\n"
read -p "Choose an option (or anything else to quit): " option
if [ "$option" = "1" ]; then
	install
elif [ "$option" = "2" ]; then
	uninstall
elif [ "$option" = "3" ]; then
	uninstall
	install
else
	:
fi
exit

