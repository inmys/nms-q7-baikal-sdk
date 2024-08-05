# nms-q7-baikal-sdk

## Компоненты
Для работы с SDK требуется архив [thirdparty](https://disk.yandex.ru/d/FYv6qjSekAyT_Q), который необходимо поместить рядом с sdk

```
tar xvf thirdparty.tar.gz
git clone https://github.com/inmys/nms-q7-baikal-sdk
cd baikal-bmc-sdk
```

SDK позволяет собрать: 
* u-boot
```
make ubootconfig
make uboot
```

* kernel
```
make kernelconfig
make kernel
```
* dtb
```
make dtb
```

* rootfs
```
make rootfsconfig
make rootfs
```

* образ sata-диска
```
make usb_flash.img
```

Цель по умолчанию - update.swu файл обновления для механизма SWU.

## Описание загрузчика
Загрузчик использует переменные окружения, описанные в файле **br2external_nms/overlay/etc/u-boot-initial-env**. Их же использует Linux, как переменные по умолчанию для работы утилит fw_printenv/fw_setenv. Для кастомизации переменных окружения необходимо редактировать этот файл.

## Описание rootfs
Конфигурационные скрипты и сервисы расположены в **br2external_nms/overlay/etc/init** и **br2external_nms/overlay/etc/sv/**.

Статический IP-адрес по умолчанию при сборке задается в **br2external_nms/overlay/etc/init/rc.kernel**.
