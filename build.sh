#!/bin/bash

#Define variables
WORKSPACE="/home/strit/build-dir/"
#Display messages
 msg() {
    ALL_OFF="\e[1;0m"
    BOLD="\e[1;1m"
    GREEN="${BOLD}\e[1;32m"
      local mesg=$1; shift
      printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
 }

if [ $3 == "any" ]; then
	_ARCH="armv7"
else
	_ARCH="$3"
fi

_DATE=$(date +"%Y-%m-%d_%H%M%S")
_LOGDIR=$WORKSPACE/logs/$1/$2-$3-$_DATE.log

#enable qemu binaries
msg "Enabling qemu binaries"
#printf "\n\n===== Enabling qemu binaries =====\n" >> "$_LOGDIR"
sudo update-binfmts --enable qemu-arm
sudo update-binfmts --enable qemu-aarch64 

#pulling git repos
msg "Updating the github repo"
#printf "\n\n===== Updating the github repo =====\n" >> "$_LOGDIR"
#for dir in $WORKSPACE/repo/*; do (cd "$dir" && git pull); done #2>&1 >> "$_LOGDIR"

#updating rootfs 
msg "Updating the rootfs"
#printf "\n\n===== Updating the rootfs =====\n" >> "$_LOGDIR"
sudo systemd-nspawn -D $WORKSPACE/$_ARCH/ -u manjaro sudo pacman -Syyu --noconfirm #&>> "$_LOGDIR"

#cp package to rootfs
msg "Copying build directory {$1/$2} to rootfs"
#printf "\n\n===== Copying the build directory {$1/$2} to rootfs =====\n" >> "$_LOGDIR"
sudo cp -rp /var/lib/jenkins/workspace/filesystem-test/$2/ $WORKSPACE/$_ARCH/home/manjaro/build/ #>> "$_LOGDIR"

#build package
msg "Building {$2}"
#printf "\n\n===== Building {$2} =====\n" >> "$_LOGDIR"
#sudo systemd-nspawn -D $_ARCH/ -u manjaro --chdir=/home/manjaro/ sudo chown -R manjaro build/
sudo systemd-nspawn -D $_ARCH/ -u manjaro --chdir=/home/manjaro/ sudo chmod -R 777 build/
sudo systemd-nspawn -D $WORKSPACE/$_ARCH/ -u manjaro --chdir=/home/manjaro/build/ makepkg -scr --noconfirm #&>> "$_LOGDIR"
#read -p "Press [Enter] to continue"
if ls $WORKSPACE/$_ARCH/home/manjaro/build/*.pkg.tar.xz* 1> /dev/null 2>&1; then
    #pull package our of rootfs
    msg "Extracting finished package out of rootfs"
    #printf "\n\n===== Extracting finished package out of rootfs =====\n" >> "$_LOGDIR"
    cp $WORKSPACE/$_ARCH/home/manjaro/build/*.pkg.tar.xz $WORKSPACE/packages/$3/$1/ #&>> "$_LOGDIR"
else
    msg "Package failed to build"
    #cat "$_LOGDIR" | grep -E 'error|ERROR|WARNING' 
fi

#clean up rootfs
msg "Cleaning rootfs"
#printf "\n\n===== Cleaning rootfs =====\n" >> "$_LOGDIR"
#msg "Entire build log can be found at $_LOGDIR"
sudo rm -r $WORKSPACE/$_ARCH/home/manjaro/build/ > /dev/null

#TODO

#	Find a way to do sanity checks for existing files and error out if they are not accurate. For example, search for the arm7 (rootfs) and mark it good, search in the package folder for a PKGBUILD and mark it good, Search for log folders and mark it good, search for package directory for completed packages, and mark it good.

#
