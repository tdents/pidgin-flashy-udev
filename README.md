#Версия для udev <br />
Для работы необходимо добавить правило udev:<br />
<br >
ACTION=="add", SUBSYSTEM=="usb",<br />
ATTRS{idVendor}=="", \ #insert id here <br />
ATTRS{idProduct}=="", \ #insert id here <br />
MODE:="0664", GROUP:="led",NAME="pidgin-led", SYMLINK+="pidgin-led", RUN+="/etc/flash-set.sh"<br />
