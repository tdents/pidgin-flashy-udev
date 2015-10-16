# pidgin-flashy-udev
udev version for flashing
Another one version of this..
Firsh - add rule to udev:
#LED flash
ACTION=="add", \
SUBSYSTEM=="usb", \
ATTRS{idVendor}=="", \  //insert your device id here
ATTRS{idProduct}=="", \  //insert your device id here
MODE:="0664", \
GROUP:="led", \
NAME="pidgin-led", \
SYMLINK+="pidgin-led"
RUN+="/etc/flash-set.sh"
