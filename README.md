#Версия для udev <br />
Для работы необходимо добавить правило udev:<br />
<br >
ACTION=="add", SUBSYSTEM=="usb",<br />
ATTRS{idVendor}=="", \ #впишите ID устойства <br />
ATTRS{idProduct}=="", \ #впишите ID устройста <br />
MODE:="0664", GROUP:="led",NAME="pidgin-led", SYMLINK+="pidgin-led", RUN+="/etc/flash-set.sh"<br />

После чего файл flash-set.sh разместить в директории /etc. Там же создать конфиг pidgin-flashy.conf. <br />
В нем указать:<br />
dVendor=ID<br />
dProduct=ID<br />
<br />
ID можно найти в lsusb.<br />
