#!/bin/bash

# The goal of this script is to help our students to set up a Debian system which
# resembles the student systems of our department. 

# If there is something you do not want to have installed,
# just put a hashdeck in front of the relevant lines.

# a fresh install of Debian is assumed
# User must already exist on the system and be in the sudo group


###############################################################################
# some function definitions
###############################################################################

configure_locale() {
    # I like my system menus etc. to be in English, while all other locale settings,
    # e.g. date format, must be in Dutch
    # install Dutch locale
    sudo sed -i 's/# \(nl_NL.*UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen
    sudo dpkg-reconfigure locales

    # make sure all locale settings are Dutch, except menus etc
    CUSTOM=$(cat <<-EOM
export LANGUAGE=en
export LANG=en_US.UTF-8
export LC_ADDRESS=nl_NL.UTF-8
export LC_NAME=nl_NL.UTF-8
export LC_MONETARY=nl_NL.UTF-8
export LC_PAPER=nl_NL.UTF-8
export LC_IDENTIFICATION=nl_NL.UTF-8
export LC_TELEPHONE=nl_NL.UTF-8
export LC_MEASUREMENT=nl_NL.UTF-8
export LC_TIME=nl_NL.UTF-8
export LC_NUMERIC=nl_NL.UTF-8
EOM
)
    echo "$CUSTOM" >> "$HOME/.profile"
}


configure_remote_access() {
    # if you have an account on our student network, it is possible to acces your files 
    # as if they were stored locally

    # create a mountpoint
    sudo mkdir -p /mnt/werk
    sudo chown "$USER:$USER" /mnt/werk

    # create a link in your Documents directory to the mount point
    ln -s /mnt/werk "$USER/Documents/werk"
    
    # Please contact a teacher or an administrator to complete set up.
}


install_chrome() {
    # hanze mail etc. supposedly works best with google chrome, which
    # is not in the binary packages of Debian. It can be installed however ...

    # Download Google's signing key and add it to the list of keys you trust
    wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg

    # Run the following command to add Googles repository to those used by apt
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list 

    sudo apt update
    sudo apt install -y google-chrome-stable
}



install_gnome_stuff() {
    # install some software that is only relevant for the gnome desktop environment
    # dconf is the Gnome configuration database. dconf-editor enables some tweaks that
    # are impossible with the standard installed tools
    sudo apt install -y dconf-editor
    sudo apt install -y gnome-software-plugin-flatpak
}


install_graphics_software() {
    # install software for graphics

    # the gimp is a replacement for Photoshop
    sudo apt install -y gimp
    sudo apt install -y gimp-help-nl
    sudo apt install -y gimp-help-en

    # general pic editing, also through the command line
    sudo apt install -y imagemagick

    # idem, but for videos
    sudo apt install -y ffmpeg

    # a vector image editor
    sudo apt install -y inkscape

    # text based diagramming program
    sudo apt install -y graphviz
}


install_jupyter() {
    # Jupyter is an interactive progrommaing environment.
    sudo apt install -y jupyter jupyter-qtconsole
}


install_ms_teams() {
    # often used for online meetings and sharing of documents
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
    sudo apt update -y
    sudo apt install teams -y
}


install_octave() {
    # install octave
    sudo apt install -y octave liboctave-dev

    # install some additional octave packages
    sudo apt install -y octave-control octave-image octave-io octave-optim octave-signal octave-statistics

    # install jupyter to be able to run notebooks containing the course materials
    install_jupyter

    # install the jupyter octave kernel
    pip3 install octave_kernel
}    


install_r() {
    # a programming environment for statistical analysis
    sudo apt install -y libcurl4-openssl-dev
    sudo apt install -y libssl-dev
    sudo apt install -y libxml2-dev
    sudo apt install -y r-base
}


install_vb_client_utils() {
    # to enable copy/paste and directories shared between host and client,
    # virtualbox client utilities must be installed
    # To mount the guest additions ISO file using VirtualBox manager, open the virtual 
    # machine and click Devices > Insert Guest Additions CD image on the Menu bar. 
    sudo mkdir /mnt/cdrom
    sudo mount /dev/cdrom /mnt/cdrom
    # commonly used packages, so probably installed already.
    sudo apt install -y dkms "linux-headers-$(uname -r)" build-essential
    sudo sh /mnt/cdrom/VBoxLinuxAdditions.run

    # shared folders will be owned by root:vboxsf. add $USER to vboxsf group
    sudo adduser "$USER" vboxsf
    # you'll have to reboot your virtual system to load the modules
}


###############################################################################
# some preliminary steps
###############################################################################

# check if installation is on virtualbox as this will influence some (configuration) steps
VIRTUAL_BOX=$([[ $(systemd-detect-virt | grep oracle) ]] && echo true || echo false)

# enable extra repositories
# backup sources list just to be safe and uncomment the relevant lines
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo sed -i "s/# \(deb.* http\)/\1/" /etc/apt/sources.list


###############################################################################
# install 'core' software
###############################################################################
# flatpack are a format and its tools to install Linux software. Its advantage over
# the apt/.deb combo is that it is distribution independent. This flexibilty, however,
# comes with the cost of extra storage space needed and a performnce hit. Therefore 
# native apps are preferred in this script. Proprietary apps, however, that
# cannot be distributed as debian packages but are available as flatpack are installed
# using flatpack. 
# Flathub is supposedly the best place to get Flatpak apps.
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Git is a version management tool. It can be used to retrieve the source code of
# software that is not available as a precompiled package in the Debian repositories
sudo apt install -y git

# dpkg-sig is used to verify digital signatures
sudo apt install -y dpkg-sig

# packages commonly used for development. Also often required to compile 
# source code retrieved from github.
sudo apt install -y dkms
sudo apt install -y "linux-headers-$(uname -r)"
sudo apt install -y build-essential

# some useful software written in Python can be installed using pip
sudo apt install -y python3
sudo apt install -y python3-pip

# nfs and samba can be used to access remote directories
sudo apt install -y nfs-common
sudo apt install -y smbclient

# a windowed text editor/lightweight ide (also available for other OSses)
sudo apt install -y geany
sudo apt install -y geany-plugins

# a utility to open internet resources
sudo apt install -y curl

# a spell checker. Used by, among others, libre office and rstudio.
sudo apt install -y hunspell
sudo apt install -y dictionaries-common
sudo apt install -y hunspell-en-us
sudo apt install -y hunspell-nl


if [[ "$XDG_CURRENT_DESKTOP" =~ .*Gnome ]]; then
    install_gnome_stuff
fi


###############################################################################
# Installation of office software
###############################################################################

# pandoc is a very powerful converter for almost every document format
sudo apt install -y pandoc
sudo apt install -y pandoc-siteproc
sudo apt install -y texlive-latex-recommended
sudo apt install -y texlive-latex-extra
sudo apt install -y librsvg2-bin
sudo apt install -y wkhtmltopdf

###############################################################################
# Installation of software used in some of our courses
###############################################################################

install_chrome

install_ms_teams

install_jupyter

install_r

install_octave
    
install_graphics_software

configure_locale

configure_remote_access

# enable compose key
sudo setxkbmap -option compose:ralt

###############################################################################


if [ "$VIRTUAL_BOX" = true ]; then
    install_vb_client_utils
fi
