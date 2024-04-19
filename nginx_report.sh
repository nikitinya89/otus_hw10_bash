#!/bin/bash

#Email адрес получателя
mailbox="lillia.alainah@milkgitter.com"
user=$(echo $mailbox | cut -d @ -f 1 | tr '[:lower:]' '[:upper:]')
log_path="/var/log/nginx/access.log"

#Функция формирования тела письма
function nginxMail () {
    echo "From: Nginx Report <nginx@mail.com>" > mail
    echo "To: $user <$mailbox> " >> mail
    echo "Subject: Nginx Report" >> mail
    echo -e "Список IP-адресов с максимальным числом запросов:\n" >> mail
    awk '{print $1}' $1 | sort | uniq -c | sort -gr | head | awk '{print "IP-адрес: \""$2"\"     Количество: "$1}' >> mail
    echo -e "\n\nСписок наиболее запрашиваемых URL:\n" >> mail
    grep HTTP $1 | awk '{print $7}' | sort | uniq -c | sort -gr | head | awk '{print "URL: \""$2"\"     Количество: "$1}' >> mail
    echo -e "\n\nОшибки веб-сервера/клиента:\n" >> mail
    grep -E "HTTP.{6}40.|HTTP.{6}50." $1 | awk '{print "IP-адрес: \"" $1"\"     URL: \"" $7"\"     HTTP код ошибки: \""$9"\""}' >> mail
    echo -e "\n\nСписок всех кодов HTTP ответа:\n" >> mail
    grep HTTP $1 | awk '{print $9}' | sort | uniq -c | sort -gr | awk '{print "HTTP код: \""$2"\"     Количество: "$1}'  >> mail
    cat mail | sendmail $mailbox
    rm mail
}

#Проверка, запущен ли скрипт
if [ ! -f is_script_running ]
    then
        touch is_script_running
        #Проверка, запускался ли ранее. Если да, то смотрим построчно по даты в логе, сравнивая с датой последнего запуска
        if [ -f lastrun ]
            then
                for i in $(cat $log_path | awk '{print $4}' | sed 's/\[//g')
                    do j=$(($j+1))
                        if [ $(date -d "$(echo $(echo $i | sed 's/\//-/g' | sed 's/:/ /'))" +%s;) -gt $(cat lastrun) ]
                            then sed -e "1,$(($j-1)) d" $log_path > access.log.tmp
                                nginxMail access.log.tmp
                                rm access.log.tmp
                                date +%s > lastrun
                            break
                        fi
                    done
        #Первичный запуск скрипта
        else
            nginxMail $log_path
            date +%s > lastrun
        fi
        rm is_script_running
    #Если скрипт сейчас выполняется
    else
        echo "Script is running. Try again later.."
fi  
