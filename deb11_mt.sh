#!/bin/bash
# v 1.03
# Для Moon Trader.
# По всем вопросам работы скрипта обращаться в телеграм @Mister3am
# Требования:
# Debian 11
# выделенный сервер или vds на полноценной виртуализации в Токио
# для работы с сервером под Windows советую использовать программу Bitvise SSH Client

clear
PS3='Настройка сервера для MoonTrader на Debian 11. Что делаем: '
options=("Полная настройка для Debian11" "Скачать и распаковать МТ с оф сайта в нужную папку" "Залить свой архив MT tar.xz и распаковать в нужную папку" "Залить свой архив МТ 7z и распаковать в нужную папку" "Залить свой архив data 7z и распаковать в нужную папку" "Выход")
select opt in "${options[@]}"
do
 case $opt in
 	"Полная настройка для Debian11")
	     # устанавливаем весь нужный софт:
	     apt update -y
	     apt upgrade -y						
	     apt install htop screen libncurses5 libtommath1  aptitude fail2ban p7zip-full iptables-persistent systemd-timesyncd -y
					
						
	    # чистим ненужное:           
	    aptitude purge ~iexim4 -y
	    apt -y autoremove
			
	    # создаем дополнительные символические ссылки на библиотеки нужных версий
            ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0
			
			
	    # генерируем пароль default юзеру:
            PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 25 | head -n 1)
    
            # создаем default юзера:
            adduser --disabled-password --home $HOMEDIR/default --shell /bin/bash --gecos "default" default
            echo "default:$PASS" | chpasswd
			
	    # создаем директорию для MT default юзера:
            mkdir $HOMEDIR/default/mt    
			
	    # создадим директорию для файлов конфигурации
	    mkdir $HOMEDIR/default/.config
	    mkdir $HOMEDIR/default/.config/moontrader-data
	    mkdir $HOMEDIR/default/.config/moontrader-data/data
	    chown -R default:default $HOMEDIR/default

            # активируем NTP:
            timedatectl set-ntp true
            systemctl enable systemd-timesyncd
            systemctl restart systemd-timesyncd
			
	    # создаем файл подкачки
	    dd if=/dev/zero of=/swapfile bs=1M count=1024
            mkswap /swapfile
            swapon /swapfile
	    echo "/swapfile none swap sw 0 0" >> /etc/fstab			
			
	    # откроем и сохраним нужные порты
            systemctl enable netfilter-persistent.service			
	    iptables -A INPUT -p udp --dport 4242 -j ACCEPT
            iptables -A INPUT -p tcp --dport 1321 -j ACCEPT			
	    /etc/init.d/netfilter-persistent save
			
	    # новый ssh конфиг со сменой порта:
            echo "Port 1321
            PermitRootLogin yes
            ChallengeResponseAuthentication no
            UsePAM yes
            X11Forwarding yes
            PrintMotd no
            AcceptEnv LANG LC_*
            Subsystem       sftp    /usr/lib/openssh/sftp-server
            " > /etc/ssh/sshd_config
	    
            
            # подчищаем:
            echo "" > /root/.bash_history


           echo "
           #######################################

           Логин и пароль дефолтного юзера:
           "
           echo "default" $PASS
           echo "default" $PASS > /root/user.txt
           echo ""           
           echo -e "необходимое ПО установлено бро ;) \n пароль пользователя на всякий случай в файле user.txt"
			break
  ;;
  "Скачать и распаковать МТ с оф сайта в нужную папку")
            # скачаем МТ
            wget https://cdn3.moontrader.com/beta/linux-x86_64/MoonTrader-linux-x86_64.tar.xz
	    
	    # перенесем архив в нужную папку
            mv /root/MoonTrader-linux-x86_64.tar.xz $HOMEDIR/default/mt/MoonTrader-linux-x86_64.tar.xz
	    cd $HOMEDIR/default/mt
	    
	    #распакуем МТ
            tar -xf MoonTrader-linux-x86_64.tar.xz
	    
	    # удалим архив МТ
	    rm $HOMEDIR/default/mt/MoonTrader-linux-x86_64.tar.xz
	    
	    # сделаем файл исполняемым
            cd $HOMEDIR/default/mt
	    chmod +x ./MTCore
	    
	    # дадим права на файлы нашему пользователю
	    chown -R default:default $HOMEDIR/default
			
	    # подчищаем:
            echo "" > /root/.bash_history

			
            echo "Все готово бро, файлы в папке /default/mt"


			break	
  ;;
  "Залить свой архив MT tar.xz и распаковать в нужную папку")
            # перенесем архив в нужную папку
            mv /root/MoonTrader-linux-x86_64.tar.xz $HOMEDIR/default/mt/MoonTrader-linux-x86_64.tar.xz
	    cd $HOMEDIR/default/mt
	    
	    # распакуем МТ
            tar -xf MoonTrader-linux-x86_64.tar.xz
	    
	    # удалим архив МТ
	    rm $HOMEDIR/default/mt/MoonTrader-linux-x86_64.tar.xz
	    
	    # сделаем файл исполняемым
            cd $HOMEDIR/default/mt
	    chmod +x ./MTCore
	    
	    # дадим права на файлы нашему пользователю
	    chown -R default:default $HOMEDIR/default
			
	    # подчищаем:
            echo "" > /root/.bash_history

            echo "Все готово бро, файлы в папке /default/mt"


			break			
  ;;
  "Залить свой архив МТ 7z и распаковать в нужную папку")
            echo "Введите название архива включая расширение файла: "
	    read arhiv
	    
	    # перенесем архив в нужную папку
	    mv /root/$arhiv $HOMEDIR/default/mt/$arhiv
            cd $HOMEDIR/default/mt
	    
	    # распакуем МТ
            7z x $arhiv
	    
	    # удалим архив МТ
	    rm $HOMEDIR/default/mt/$arhiv
	    
	    # сделаем файл исполняемым
            cd $HOMEDIR/default/mt
	    chmod +x ./MTCore
	    
	    # дадим права на файлы нашему пользователю
	    chown -R default:default $HOMEDIR/default
			
	    # подчищаем:
            echo "" > /root/.bash_history

  
            echo "Все готово бро, файлы в папке /default/mt"

			break		
  ;;
    "Залить свой архив data 7z и распаковать в нужную папку")
            echo "Введите название архива включая расширение файла: "
	    read arhiv
	    
	   # перенесем архив в нужную папку
	   mv /root/$arhiv $HOMEDIR/default/.config/moontrader-data/$arhiv		
           cd $HOMEDIR/default/.config/moontrader-data
	   
	    # распакуем МТ
            7z x $arhiv
	    
            # удалим архив МТ
	    rm $HOMEDIR/default/.config/moontrader-data/$arhiv			
			
	    # дадим права на файлы нашему пользователю
	    chown -R default:default $HOMEDIR/default
			
	    # подчищаем:
            echo "" > /root/.bash_history

  
            echo "Все готово бро, файлы в папке /default/.config/moontrader-data"

			break		
  ;;
 "Выход")
  break
  ;;
 *) echo invalid option;;
 esac
done
