#Версия для udev <br />

Установка:<br />
1. Необходимо узнать ID устройства, с которым будет оперировать плагин.<br />
Для этого в консоли выполнить: lsusb<br />
Из полученного списка взять idVendor и idProduct. Например:<br />
Bus 008 Device 003: ID 09da:0006 A4 Tech Co., Ltd Optical Mouse WOP-35 / Trust 450L Optical Mouse<br />
<br />
idVendor = 09da<br />
idProduct = 0006<br />
<br />
2. Добавить правило udev:<br />
<br />
#LED flash<br />
ACTION=="add", \<br />
SUBSYSTEM=="usb", \<br />
ATTRS{idVendor}=="09da", \<br />
ATTRS{idProduct}=="0006", \<br />
MODE:="0664", \<br />
GROUP:="led", \<br />
NAME="pidgin-led", \<br />
SYMLINK+="pidgin-led"<br />
RUN+="/etc/flash-set.sh"<br />
<br />
Соответственно изменить в правиле idVendor и idProduct на устройство из системы (lsusb)<br />
<br />
3. Разместить 2 файла flash-set.sh и pidgin-flashy.conf в /etc/<br />
<br />
4. В файле pidgin-flashy.conf изменить idVendor и idProduct на те же значения из lsusb<br />
<br />
5. Установить плагин, разместив файл flash-plugin.pl в директорию ~/.purple/plugin<br />
<br />
После чего перезапустить Pidgin и, если не включен, то включить плагин в Средства > Модули > FlashyLightPlugin.<br />
<br />
После подключения устройства оно должно автоматически перейти в состояние suspend.<br /> 
В случае с мышкой - погаснуть.<br />
