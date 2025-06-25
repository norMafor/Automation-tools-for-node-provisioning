# REPORT_DevOps8_boltonth
# Инструменты автоматизации

## Contents

   1. [Удаленное конфигурирование узла через Ansible](#part-1-удаленное-конфигурирование-узла-через-ansible)
   2. [Service Discovery](#part-2-service-discovery)


## Part 1. Удаленное конфигурирование узла через Ansible

Удаленная настройка узла для разворачивания мультисервисного приложения.

**== Задание ==**

1) Создать с помощью Vagrant три машины - manager, node01, node02. Не устанавливать с помощью shell-скриптов docker при создании машин на Vagrant! Прокинуть порты node01 на локальную машину для доступа к пока еще не развернутому микросервисному приложению.

         создан src/ansible01/Vagrantfile

* Запущены три машины: 
![1_01](pictures/1_01.png)

2) Подготовить manager как рабочую станцию для удаленного конфигурирования (помощь по Ansible в материалах).
- Зайти на manager. 
![1_02-1](pictures/1_02-1.png) 
- На manager проверить подключение к node01 через ssh по приватной сети. 
![1_02-2](pictures/1_02-2.png) 

      Подключились к node01 (через vagrant ssh node01).
      Убедились, что SSH-сервер запущен:
         sudo systemctl status ssh
      Открыли для редактирования: 
         sudo nano /etc/ssh/sshd_config
      Убедились, что параметры настроены правильно:
         PasswordAuthentication yes
      Перезапустили SSH-сервер:
         sudo systemctl restart ssh

- Сгенерировать ssh-ключ для подключения к node01 из manager (без passphrase). 
* Генерация ключа командой:  
`ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa` 
![1_02-3](pictures/1_02-3.png) 
* Подтверждение инсталляции ключа  node01: 
![1_02-3-01](pictures/1_02-3-01.png) 
* Демонстрация ключа на node01: 
![1_02-3-02](pictures/1_02-3-02.png) 

- Скопировать на manager docker-compose файл и исходный код микросервисов. (Используй проект из папки src и docker-compose файл из предыдущей главы. Помощь по ssh в материалах.)
* Перенос исходного кода микросервисов: 
![1_02-4-01](pictures/1_02-4-01.png)
* Перенос файла docker-compose.yml: 
![1_02-4-02](pictures/1_02-4-02.png)
* Проверка успешности переноса на машине manager: 
![1_02-4-03](pictures/1_02-4-03.png) 

- Установить Ansible на менеджер и создать папку ansible, в которой создать inventory-файл. 

      sudo apt update
      sudo apt install -y ansible
* Результат установки: 
![1_02-5](pictures/1_02-5.png) 

* Создание inventory файла: 
![1_02-6](pictures/1_02-6.png) 

- Использовать модуль ping для проверки подключения через Ansible. 
- Результат выполнения модуля поместить в отчет.
* Выполнение модуля ping: 
![1_02-7](pictures/1_02-7.png) 

3) Написать первый плейбук для Ansible, который выполняет apt update, устанавливает docker, docker-compose, копирует compose-файл из manager'а и разворачивает микросервисное приложение. 

         Создан src/ansible01/main.yml, размещен на manager /home/vagrant/ansible/main.yml
* Результат запуска написанного плейбука командой ansible-playbook -i inventory main.yml: 
![1_03-1](pictures/1_03-1.png) 
![1_03-2](pictures/1_03-2.png) 

4) Прогнать заготовленные тесты через postman и удостовериться, что все они проходят успешно. В отчете отобразить результаты тестирования. 

* проверка проброса портов с локальной машины на node01 
![1_04-1](pictures/1_04-1.png) 
* проверка выполнения запроса из командной строки  
![1_04-2](pictures/1_04-2.png) 
* результат запуска тестов в Postman 
![1_04-3](pictures/1_04-3.png) 

5) Сформировать три роли: 
 - роль application выполняет развертывание микросервисного приложения при помощи docker-compose,
 - apache устанавливает и запускает стандартный apache сервер
 - postgres устанавливает и запускает postgres, создает базу данных с произвольной таблицей и добавляет в нее три произвольные записи. 


         Выполнена инициализация ролей:
         cd ~/ansible    
         ansible-galaxy init roles/application   
         ansible-galaxy init roles/apache    
         ansible-galaxy init roles/postgres  

* результат инициализации  
![1_05-1](pictures/1_05-1.png) 
![1_05-1-01](pictures/1_05-1-01.png) 


 - Назначить первую роль node01 и вторые две роли node02, проверить postman-тестами работоспособность микросервисного приложения, удостовериться в доступности postgres и apache-сервера. Для Apache веб-страница должна открыться в браузере. Что касается PostgreSQL, необходимо подключиться с локальной машины и отобразить содержимое ранее созданной таблицы с данными. 

         Расписаны задачи для каждой роли:
         src/ansible01/roles/apache/tasks/main.yml
         src/ansible01/roles/application/tasks/main.yml
         src/ansible01/roles/postgres/tasks/main.yml 
         
         Создан плейбук для применения ролей src/ansible01/roles.yml
         размещен на manager /home/vagrant/ansible/roles.yml

* внесены изменения в ansible.cfg 
![1_05-2-01](pictures/1_05-2-01.png) 
* результат запуска playbook.yml 
![1_05-2](pictures/1_05-2.png) 

* результат запуска тестов в Postman 
![1_05-3](pictures/1_05-3.png) 

* страница Apache в браузере 
![1_05-4](pictures/1_05-4.png) 

- Подключимся к базе данных из консоли node02: 
      
      sudo -u postgres psql -d devops8_db 
      SELECT * FROM arbitrary_table 

* результат проверки внесения записей в таблицу postgres 
![1_05-5](pictures/1_05-5.png) 

 - Пробросим порт (модифицируем Vagrantfile и сделаем reload node02) на локальную машину и подключимся к базе данных через pgAdmin c локальной машины  

         добавим разрешение в: 
         /etc/postgresql/12/main/pg_hba.conf  

* результат проверки внесения записей в таблицу postgres при подклчении с локальной машины
![1_05-6](pictures/1_05-6.png) 



6) Созданные в этом разделе файлы размещены в папке `src\ansible01` в личном репозитории.

## Part 2. Service Discovery

Теперь перейдем к обнаружению сервисов. В этой главе тебе предстоит cымитировать два удаленных сервиса - api и БД, и осуществить между ними подключение через Service Discovery с использованием Consul.

**== Задание ==**

1) Написать два конфигурационный файла для consul (информация по consul в материалах):
- consul_server.hcl:
   - настроить агент как сервер;
   - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant  

* содержимое consul_server.hcl  
![2_01-1](pictures/2_01-1.png) 

- consul_client.hcl:
   - настроить агент как клиент;
   - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant  

* содержимое consul_client.hcl  
![2_01-2](pictures/2_01-2.png)  

2) Создать с помощью Vagrant четыре машины - consul_server, api, manager и db. 
- Прокинуть порт 8082 с api на локальную машину для доступа к пока еще не развернутому api
- Прокинуть порт 8500 с manager для доступа к ui consul.  

      Создан src/ansible02/Vagrantfile   


3) Написать плейбук для ansible и четыре роли:   

         Создан src/ansible02/main.yml 
         размещен на manager /home/vagrant/ansible/main.yml  
* Выполнение модуля ping:      
![2_03-0](pictures/2_03-0.png)  
* создание ролей    
![2_03-1](pictures/2_03-1.png)  

- install_consul_server, которая:
   - работает с consul_server;
   - копирует consul_server.hcl;
   - устанавливает consul и необходимые для consul зависимости;
   - запускает сервис consul   

         Создан src/ansible02/install_consul_server/tasks/main.yml   

* результат запуска consul_server    
![2_03-2](pictures/2_03-2.png)  
![2_03-3](pictures/2_03-3.png)  
![2_03-4](pictures/2_03-4.png)  

- install_consul_client, которая:
   - работает с api и db;
   - копирует consul_client.hcl;
   - устанавливает consul, envoy и необходимые для consul зависимости; 
   - запускает сервис consul и consul-envoy;   

         Создан src/ansible02/install_consul_client/tasks/main.yml   

* результат запуска consul и envoy    
![2_03-5-11](pictures/2_03-5-11.png)  
![2_03-5-12](pictures/2_03-5-12.png)  
![2_03-5-13](pictures/2_03-5-13.png)  
![2_03-5-14](pictures/2_03-5-14.png)  
![2_03-5-00](pictures/2_03-5-00.png)  
![2_03-5](pictures/2_03-5.png)  
![2_03-5-01](pictures/2_03-5-01.png)  
![2_03-5-02](pictures/2_03-5-02.png)  
![2_03-5-22](pictures/2_03-5-22.png)  
![2_03-5-03](pictures/2_03-5-03.png)  
![2_03-5-33](pictures/2_03-5-33.png)  
![2_03-5-04](pictures/2_03-5-04.png)  
![2_03-5-44](pictures/2_03-5-44.png)  

- install_db, которая:
   - работает с db;
   - устанавливает postgres и запускает его;
   - создает базу данных `hotels_db`;   

         Создан src/ansible02/install_db/tasks/main.yml   
* результат создания базы данных `hotels_db`    
![2_03-5-45](pictures/2_03-5-45.png)  

- install_hotels_service, которая:
   - работает с api;
   - копирует исходный код сервиса
   - устанавлвиает `openjdk-8-jdk`
   - создает глобальные переменные окружения:
      - POSTGRES_HOST="127.0.0.1"
      - POSTGRES_PORT="5432"
      - POSTGRES_DB="hotels_db"
      - POSTGRES_USER="<имя пользователя>"
      - POSTGRES_PASSWORD="<пароль пользователя>"
   - запускает собранный jar-файл командой `java -jar <путь до hotel-service>/hotel-service/target/<имя jar-файла>.jar`   

         Создан src/ansible02/install_hotels_service/tasks/main.yml   

* установленные переменные   
![2_03-6-01](pictures/2_03-6-01.png)  
* результат запуска hotel-service   
![2_03-6](pictures/2_03-6.png)  
![2_03-6-02](pictures/2_03-6-02.png)  
![2_03-6-03](pictures/2_03-6-03.png)  
![2_03-6-04](pictures/2_03-6-04.png)  


4) Проверить работоспособность CRUD-операций над сервисом отелей. В отчете отобразить результаты тестирования.

* GET-запрос (информация обо всех отелях) к подключенной базе с использованием postman с локальной машины   
![2_04-1](pictures/2_04-1.png)  

* POST-запрос добавление нового отеля   
![2_04-2](pictures/2_04-2.png)  

* GET-запрос проверка выполненного добавления   
![2_04-3](pictures/2_04-3.png)  

* GET-запрос получение опреденного количества объектов (с использованием пагинации)   
![2_04-4](pictures/2_04-4.png)  

* таблица в базе после манипуляций   
![2_04-5](pictures/2_04-5.png)  
* search запрос из браузера   
![2_04-6](pictures/2_04-6.png)   

5) Созданные в этом разделе файлы размещены в папках `src\ansible02` и `src\consul01` в личном репозитории.
