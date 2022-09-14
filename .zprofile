if [[ $(tty) = /dev/tty1 ]]; then
    startx

    # Log out on when Xorg quits
	#exec startx
fi
