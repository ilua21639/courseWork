# Дипломная Работа
Дипломная работа на профессии "Системный администратор линукс" - Денисов Илья

Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud.
Примечание: в курсовой работе используется система мониторинга Prometheus. Вместо Prometheus вы можете использовать Zabbix. Задание для курсовой работы с использованием Zabbix находится по ссылке.
Перед началом работы над дипломным заданием изучите Инструкция по экономии облачных ресурсов.

Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.
Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.
Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.
Создайте Target Group, включите в неё две созданных ВМ.
Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.
Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.
Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.
Протестируйте сайт
curl -v <публичный IP балансера>:80

Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и Nginx Log Exporter. Настройте Prometheus на сбор метрик с этих exporter.
Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые tresholds на соответствующие графики.

Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.
Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.
Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.
Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

Ход выполенения

Данные облака:  

organization-eliah21639

cloud-eliah21639

идентификатор:

b1g521q13m0q1ea7ur3k

Все ресурсы инфраструктуры разворачиваются с помощью файлов *.tf и ansible-playbook- *.yml
Для удобства передачи файлов на Bastion создан move.sh
Для ускорения разворачивания с помощью плейбуков Ansible с Bastion был создан start.sh
Сайт был взят статичекий из свободного доступа в интернете.
Разворачиваем ресурсы:

ilua@Ilua-Default-String@:~/terraform-cloud$terraform apply

Затем передаем все необходимые файлы проекта на Bastion:

ilua@Ilua-Default-String@:~/terraform-cloud$bash move.sh

Конфигурируем ansible и последовательно запускаем плейбуки 

ilua1@bastion:~$ cd ansible/

ilua1@bastion:~/ ansible$ bash start.sh
