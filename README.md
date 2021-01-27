# Pine-jinx
<img align="left" alt="Frogjinx" width="22px" src="https://cdn.discordapp.com/attachments/780529926520438854/802958006282092624/FrogRyujinx.svg" />A local Ryujinx installer for linux

This installer does not create an alias since the way to do this is different for every shell (eg. sh, bash, zsh, fish, ksh)

The purpose of the installer is to place Ryujinx inside ~/.local/share/Ryujinx, setup a desktop entry with optional optimizations (per GPU vendor and/or gamemode) as well as setup mimetypes for Switch binaries (eg. NSP, XCI).

Usage:
`bash -c "$(curl -s https://raw.githubusercontent.com/edisionnano/Pine-jinx/main/pinejinx.sh)"`
