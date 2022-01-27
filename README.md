# Pine-jinx
<img align="left" alt="Frogjinx" width="22px" src="https://cdn.discordapp.com/attachments/780529926520438854/802958006282092624/FrogRyujinx.svg" />A local Ryujinx installer for linux

The purpose of the installer is to place Ryujinx inside ~/.local/share/Ryujinx, setup a desktop entry and an optional ZSH or BASH alias with optional optimizations (per GPU vendor and/or gamemode) as well as setup mimetypes for Switch binaries (eg. NSP, XCI).

Ryujinx Master and Ryujinx LDN options are provided on this installer, both versions can be installed simultaneously if desired.

Usage:
Open a terminal, paste <br>
`bash -c "$(curl -s https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/pinejinx.sh)"` <br>
and hit enter

## Notes and Warnings
⚠️ **If you are on Ubuntu or a based distro (like Mint,Elementary,Zorin,Pop_OS) you'll have to install libx11-dev using `sudo apt install libx11-dev` otherwise Ryujinx will fail to run<br>**
⚠️ If you choose to use gamemode you'll have to install it otherwise Ryujinx won't open. Pinejinx prints a warning in bright red bold letters when gamemode is not found. It's preinstalled on Ubuntu. To install it on Arch and based distros (like Manjaro,EndeavourOS and Garuda) do `sudo pacman -Syu gamemode` and for distros on the Debian/Ubuntu family (this includes MX,Mint,Elementary,Zorin,Pop_OS) use `sudo apt install gamemode`<br>
⚠️ If you are on Garuda you'll have to do `exec zsh` before using the script and the alias<br>
⚠️ Pinejinx overwrites ~/.config/gamemode.ini if it exists when you use gamemode. This will be fixed in the future. If you don't know what this is, ignore this warning<br>
⚠️ The gamemode config used by Pinejinx supports the re-nice feature for some additional performance, to use it you must create a gamemode group using `sudo groupadd gamemode` and throw your user in using `sudo usermod -a -G gamemode $USER`<br>
⚠️ Regarding laptop users with NVIDIA GPUs, Ryujinx will have to merge the EGL pull request before Pinejinx can support you<br>

Please come at Ryujinx's Discord server if you face any issues. We'll gladly support you at the #linux-master-race channel
