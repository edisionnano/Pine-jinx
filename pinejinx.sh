#!/usr/bin/env sh
# Prepare environment
find /tmp/pineapple/* ! -name '*.tar.gz' 2>/dev/null | sort -n -r | xargs rm -rf --
mkdir -p /tmp/pineapple && cd /tmp/pineapple
#Define the functions
install () {
	jobid=$(curl -s https://ci.appveyor.com/api/projects/gdkchan/ryujinx/branch/master | grep -Po '"jobId":.*?[^\\]",' |sed  's/"jobId":"\(.*\)",/\1/' )
	echo "Downloading $version..."
	curl -LOC - "https://ci.appveyor.com/api/buildjobs/${jobid}/artifacts/ryujinx-${version}-linux_x64.tar.gz"
	tar -xf ryujinx-${version}-linux_x64.tar.gz
	arch_dir=$(tar --exclude='*/*' -tf ryujinx-${version}-linux_x64.tar.gz)
	if [ -d "$arch_dir" ]; then
		printf "Extraction successful!\n"
		mkdir -p ~/.local/share/Ryujinx
		cp -a $arch_dir/. ~/.local/share/Ryujinx
	else
		printf "Extraction failed!\nAborting...\n"
		exit
	fi
	curl -sLOC - "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.desktop"
	curl -sLOC - "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.png"
	curl -sLOC - "https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/Ryujinx.xml"
	if ! [ "$(command -v gamemoderun)" ];then
		printf "Warning:Gamemode not found!\nIf you want to use it you'll have to install it.\n"
	fi
	printf "Gamemode is a tool that improves performance on non custom kernels.\n"
	read -p "Do you want to use it? [y/N]: " gamemode
	if [ "$gamemode" = "y" ] || [ "$gamemode" = "Y" ]; then
		arg1="gamemoderun "
	else
		arg1=""
	fi
	read -p "Optimize Ryujinx for 1)Nvidia 2)Intel and AMD 3)None: " gpuopt
	if [ "$gpuopt" = "1" ]; then
		arg2='env __GL_THREADED_OPTIMIZATIONS=1 __GL_SYNC_TO_VBLANK=0 '
	elif [ "$gpuopt" = "2" ]; then
		arg2='env AMD_DEBUG=w32ge,w32ps,w32cs R600_DEBUG=nohyperz glsl_zero_init=true radeonsi_clamp_div_by_zero=true mesa_glthread=true vblank_mode=0 MESA_EXTENSION_OVERRIDE="-GL_KHR_texture_compression_astc_ldr -GL_KHR_texture_compression_astc_sliced_3d" '
	else
		arg2=''
	fi
	arg="$arg2$arg1"
	#Desktop entries do not accept relative paths so the user's name must be in the file
	sed -i "s/dummy/${USER}/g" Ryujinx.desktop
	#Append any optimizations
	sed -i "s/^Exec=/Exec=${arg}/" Ryujinx.desktop 
	#Place desktop entry
	mkdir -p ~/.local/share/applications && cp Ryujinx.desktop ~/.local/share/applications
	#Place icon
	mkdir -p ~/.local/share/icons && cp Ryujinx.png ~/.local/share/icons
	#Place mime entry
	mkdir -p ~/.local/share/mime/packages && cp Ryujinx.xml ~/.local/share/mime/packages
	#Update the MIME database
	update-mime-database ~/.local/share/mime
	#Update the application database
	update-desktop-database ~/.local/share/applications
	printf "Installation successful, launch Ryujinx from your app launcher.\n"
}
uninstall () {
	printf "Uninstalling..."
	rm -rf ~/.local/share/Ryujinx
	rm -rf ~/.local/share/mime/packages/Ryujinx.xml
	rm -rf ~/.local/share/applications/Ryujinx.desktop
	rm -rf ~/.local/share/icons/Ryujinx.png
	update-mime-database ~/.local/share/mime
	update-desktop-database ~/.local/share/applications
	printf "\nUninstallation successful!\n"
}
printf "Welcome to PinEApple-Ryujinx\n"
printf "Fetching latest version info from the slow AppVeyor api...\n"
version=$(curl -s https://ci.appveyor.com/api/projects/gdkchan/ryujinx/branch/master | grep -Po '"version":.*?[^\\]",' | sed  's/"version":"\(.*\)",/\1/')
printf "Latest version is: $version\n"
printf "[1] Install it\n"
printf "[2] Uninstall\n"
printf "[3] Reinstall\n"
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
