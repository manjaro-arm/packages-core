
err() {
    ALL_OFF="\e[1;0m"
    BOLD="\e[1;1m"
    RED="${BOLD}\e[1;31m"
	local mesg=$1; shift
	printf "${RED}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

msg() {
    ALL_OFF="\e[1;0m"
    BOLD="\e[1;1m"
    GREEN="${BOLD}\e[1;32m"
	local mesg=$1; shift
	printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

check_pkgs()
{
	local remove=""

    for pkg in ${packages} ; do
        for rmpkg in $(pacman -Qq | grep ${pkg}) ; do
            if [ "${pkg}" == "${rmpkg}" ] ; then
               removepkgs="${removepkgs} ${rmpkg}"
            fi
        done
    done

    packages="${removepkgs}"
}


post_upgrade() {

	#Init pacman-key
          pacman-key --init

	# importing dodgejcr's signature
		# running dirmngr helps prevent pacman-key from failing to connect to servers
		dirmngr </dev/null
		msg "Get dodgejcr's signature ..."
		pacman-key -r CC37B7EC
		pacman-key --lsign-key CC37B7EC
		
	# Importing Build servers signature
		#same as above
		dirmngr </dev/null
		msg "Get Manjaro ARM Build Server's signature..."
		pacman-key -r B338D5DF
		pacman-key --lsign-key B338D5DF
}
