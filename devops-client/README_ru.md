
<head>
	<meta charset="utf-8"/>
	<meta name="author" content="Anton Martynov">
	<meta name="author" content="Mike Miroliubov">
	<title>Devops клиент</title>
</head>

<style>
	h1 {
		text-align: center;
	}
	h2 {
		border-bottom: 1px solid black;
	}
	h3 {
		border-bottom: 1px solid #c6c6c6;
	}
	table {
		border-collapse:collapse;
	}
	table, th, td {
		border: 1px solid #cccccc;
	}
	th, td {
		padding: 2px 10px;
	}
</style>

Devops клиент
=============

Клиент реализован в виде гема.

## Оглавление

*	[Установка](#install)
*	[Первый запуск](#first_run)
*	[Команды](#commands)
    *   [Templates](#templates)
    *   [Deploy](#deploy)
    *   [Filters](#filters)
    *   [Flavor](#flavor)
    *   [Group](#group)
    *   [Image](#image)
    *   [Key](#key)
    *   [Network](#network)
    *   [Project](#project)
    *   [Provider](#provider)
    *   [Script](#script)
    *   [Server](#server)
    *   [Tag](#tag)
    *   [User](#user)
*	[HOWTO](#howto)
    *   [Создание пользователя](#howto_user)
    *   [Создание образа](#howto_image)
    *   [Создание проекта](#howto_project)
    *   [Запуск сервера](#howto_server)

<h2 id="install">Установка</h2>

Для правильной работы devops необхлдимо наличие:

* ruby v1.9.3

Установить devops можно командой

	$ sudo gem install devops-client.gem --no-ri --no-rdoc

После установки гема devops-client, будет доступна команда

	$ devops

Если команда не доступна, тогда нужно запустить

	$ gem environment

и добавить путь "EXECUTABLE DIRECTORY" в $PATH

При запуске команды будет выдана короткая справка по ее использованию.

	$ devops

	Usage: /usr/bin/devops command [options]

	Commands:
		Bootsrap templates:
			templates list

		Deploy:
			deploy NODE_NAME [NODE_NAME ...]

		Filters:
			filter image add ec2|openstack IMAGE [IMAGE ...]
			filter image delete ec2|openstack IMAGE [IMAGE ...]
			filter image list ec2|openstack

		Flavor:
			flavor list PROVIDER

		Group:
			group list PROVIDER

		Image:
			image create
			image delete IMAGE
			image list [provider] [ec2|openstack]
			image show IMAGE
			image update IMAGE FILE

		Key:
			key add KEY_NAME FILE
			key delete KEY_NAME
			key list

		Network:
			network list PROVIDER

		Project:
			project create PROJECT_ID
			project delete PROJECT_ID [DEPLOY_ENV]
			project deploy PROJECT_ID [DEPLOY_ENV]
			project list
			project multi create PROJECT_ID
			project servers PROJECT_ID [DEPLOY_ENV]
			project set run_list PROJECT_ID DEPLOY_ENV [(recipe[mycookbook::myrecipe])|(role[myrole]) ...]
			project show PROJECT_ID
			project update PROJECT_ID FILE
			project user add PROJECT_ID USER_NAME [USER_NAME ...]
			project user delete PROJECT_ID USER_NAME [USER_NAME ...]

		Provider:
			provider list

		Script:
			script list
			script add SCRIPT_NAME FILE
			script delete SCRIPT_NAME
			script run SCRIPT_NAME NODE_NAME [NODE_NAME  ... ]
			script command NODE_NAME 'sh command'

		Server:
			server add PROJECT_ID DEPLOY_ENV IP SSH_USER KEY_ID
			server bootstrap INSTANCE_ID
			server create PROJECT_ID DEPLOY_ENV
			server delete NODE_NAME [NODE_NAME ...]
			server list [chef|ec2|openstack]
			server pause NODE_NAME
			server show NODE_NAME
			server unpause NODE_NAME

		Tag:
			tag create NODE_NAME TAG_NAME [TAG_NAME ...]
			tag delete NODE_NAME TAG_NAME [TAG_NAME ...]
			tag list NODE_NAME

		User:
			user create USER_NAME
			user delete USER_NAME
			user grant USER_NAME [COMMAND] [PRIVILEGES]
			user list
			user password USER_NAME

Для каждой команды можно посмотреть более подробную справку с помощью параметра --help

<h2 id="first_run">Первый запуск</h2>

При первом запуске (либо запуске, когда программа не сможет найти конфигурационный файл ~/.devops/devops-client.conf) необходимо будет ввести данные для настройки клиента.
На первый вопрос следует указать адрес и порт devops-сервиса:

		WARN: File '~/.devops/devops-client.conf' does not exist
		Language: ru
		Devops service host: <host>:7070
		Default API version (v2.0):
		Username: my_user
		Password: my_password
		Configuration file '~/.devops/devops-client.conf' is created

В результате будет создан конфигурационный файл.

<h2 id="commands">Команды</h2>

В конце выполнения некоторых команд будет выводиться информация о проделанной работе в формате JSON. И выдаваться вопрос с подтверждением. Если все параметры верны, необходимо подтвердить результат команды, нажав на клавишу "y", либо отменить операцию, нажав на клавишу "n". Данная особенность в тексте упомянаться больше не будет.

Для всех команд доступны опции (в скобках указаны текущие значения):

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>-h, --help</td>
    <td>Show help</td>
    <td>показать справку</td>
  </tr>
  <tr>
    <td>-c, --config FILE</td>
    <td>Specify devops client config file (/home/my_user/.devops/devops-client.conf)</td>
    <td>указать полный путь к конфигурационному файлу</td>
  </tr>
  <tr>
    <td>-v, --version</td>
    <td>devops client version</td>
    <td>вывести версию клиента</td>
  </tr>
  <tr>
    <td>--host HOST</td>
    <td>devops service host address (devops-server-host:devops-server-port)</td>
    <td>указать к какому devops серверу стоит обращаться (в формате host:port)</td>
  </tr>
  <tr>
    <td>--api VER</td>
    <td>devops service API version (v2.0)</td>
    <td>указать версию API</td>
  </tr>
  <tr>
    <td>--user USERNAME</td>
    <td>devops username (my_user)</td>
    <td>сделать запрос к devops от пользователя USERNAME</td>
  </tr>
  <tr>
    <td>--format FORMAT</td>
    <td>Output format: 'table', 'json' (table)</td>
    <td>формат вывода ответа от сервера: table - в таблице, json - текст в формате JSON</td>
  </tr>
  <tr>
    <td>--completion</td>
    <td>Initialize bash completion script</td>
    <td>инициализировать скрипт автодополнения команд (только linux, интерпретатор bash)</td>
  </tr>
</table>

<h3 id="templates">Templates</h3>

	$ devops templates

	Usage: /usr/bin/devops command [options]

	Commands:
		Bootsrap templates:
			templates list

**devops templates list** - посмотреть список доступных шаблонов для бутстрапа

<h3 id="deploy">Deploy</h3>

Команда предназначена для деплоя приложений на сервера.

	$ devops deploy

	Usage: /usr/bin/devops command [options]

	Commands:
		Deploy:
			deploy NODE_NAME [NODE_NAME ...]

**devops deploy** - деплой приложений на указанные сервера

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--tag TAG1,TAG2...</td>
    <td>Tag names, comma separated lista</td>
    <td>Указвается список тегов, которые немходимо применить к серверу при деплое</td>
  </tr>
</table>

<h3 id="filters">Filters</h3>

Команда предназначена для управления списком доступных образов.

	$ devops filter

	Usage: /usr/bin/devops command [options]

	Commands:
		Filters:
			filter image add ec2|openstack IMAGE [IMAGE ...]
			filter image delete ec2|openstack IMAGE [IMAGE ...]
			filter image list ec2|openstack

**devops filter image add** - добавить образ(ы) в список фильтров для провайдера
**devops filter image delete** - удалить образ(ы) из списока фильтров для провайдера
**devops filter image list** - посмотреть список доступных образов для провайдера

<h3 id="flavor">Flavor</h3>

	$ devops flavor

	Usage: /usr/bin/devops command [options]

	Commands:
		Flavor:
			flavor list PROVIDER

**devops flavor list** - посмотреть список доступных конфигураций виртуальных машин провайдера

<h3 id="group">Group</h3>

	$ devops group

	Usage: /usr/bin/devops command [options]

	Commands:
		Group:
			group list PROVIDER

**devops group list** - посмотреть список доступных групп безопасности провайдера

<h3 id="image">Image</h3>

Команда предназначена для управления образами

	$ devops image

	Usage: /usr/bin/devops command [options]

	Commands:
		Image:
			image create
			image delete IMAGE
			image list [provider] [ec2|openstack]
			image show IMAGE
			image update IMAGE FILE

**devops image create** - создать образ, для выполнения команды необходимо ответить на несколько вопросов:

	Provider:                      # выбрать одного из доступных провыйдеров в списке
	Choose image:                  # ввести номер образа из списка, который необходимо использовать
	The ssh username:              # имя пользователя для доступа по ssh
	Bootstrap template (optional): # название скрипта для бутстрапа

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--provider PROVIDER</td>
    <td>Image provider</td>
    <td>указать провайдера в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--image IMAGE_ID</td>
    <td>Image identifier</td>
    <td>указать идентификатор образа в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--ssh_user USER</td>
    <td>SSH user name</td>
    <td>указать имя пользователя для доступа по ssh в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--bootstrap_template TEMPLATE</td>
    <td>Bootstrap template</td>
    <td>указать шаблон в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--no_bootstrap_template</td>
    <td>Do not specify bootstrap template</td>
    <td>Использовать шаблон по умолчанию</td>
  </tr>
</table>

**devops delete** - удалить образ по ID

**devops image list** - посмотреть созданные образы

**devops image list provider ec2|openstack** - посмотреть доступные образы провайдера (с учетом фильтров)

**devops image list ec2|openstack** - посмотреть созданные образы для провайдера

**devops image show** - посмотреть информацию об одном образе

*Команда предусмотрена, однако, может быть лишней, т.к. команда image list ее перекрывает. Команда image show выдает информацию по одному образу. Можно сделать так, что эта команда будет выдавать информацию по нескольким образам (чтобы легче и наглядней было сравнивать, чем с командой image list).*

**devops image update** - обновить образ из файла, файл должен содержать все необходимые параметры в формате JSON

<h3 id="key">Key</h3>

Управление ключами для доступа к серверам

	Key:
			key add KEY_NAME FILE
			key delete KEY_NAME
			key list

**devops key add** - добавить ключ с именем KEY_NAME из файла FILE

**devops key delete** - удалить ключ с именем KEY_NAME

**devops key list** - показать список доступных ключей

Все ключи можно разделить на два типа: системные и пользовательские. Системные - те, которые были созданы при настройке сервера (их нельзя удалять). Пользовательские - добавленные пользователем.

<h3 id="network">Network</h3>

	$ devops network

	Usage: /usr/bin/devops command [options]

	Commands:
		Network:
			network list PROVIDER

**devops network list PROVIDER** - посмотреть список доступных сетей провайдера

<h3 id="project">Project</h3>

Управление проектами

	$ devops project

	Usage: /usr/bin/devops command [options]

	Commands:
		Project:
			project create PROJECT_ID
			project delete PROJECT_ID [DEPLOY_ENV]
			project deploy PROJECT_ID [DEPLOY_ENV]
			project list
			project servers PROJECT_ID [DEPLOY_ENV]
			project set run_list PROJECT_ID DEPLOY_ENV [(recipe[mycookbook::myrecipe])|(role[myrole]) ...]
			project show PROJECT_ID
			project update PROJECT_ID FILE
			project user add PROJECT_ID USER_NAME [USER_NAME  ...]
			project user delete PROJECT_ID USER_NAME [USER_NAME  ...]

**devops project create** - создать проект

После запуска команды клиент будет собирать необходимую информацию (будут возникать небольшие паузы между вопросами). Для создания проекта необходимо ответить на предлагаемые вопросы:

	Deploy environment identifier:                                                               # идентификатор среды окружения (dev, test, my_env...)
	Provider:                                                                                    # провайдер, где будет развернут проект
	Security groups (comma separated), like 1,2,3, or empty for 'default':                       # список групп безопасности
	Users, you will be added automatically (comma separated), like 1,2,3, or empty:              # список пользователей, которые могут работать с проектом
	Flavor:                                                                                      # параметры сервера, на котором будет развернут проект
	Image:                                                                                       # образ ОС для проекта
	Subnets (comma separated), like 1,2,3, or empty:                                             # список подсетей, которые должны быть доступны проекту (для openstack не может быть пустым)
	Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]: role[test_dev], # список ролей и кукбук для развертывания проекта
	Enter expires time if necessary (5m, 3h, 2d, 1w, etc):                                       # время через которое сервер для проекта будет удален (пусто если обция не нужна)

*Если проект с указанным именем существует, то будет добавлена новое окружение к проекту*

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--groups GROUP_1,GROUP_2...</td>
    <td>Security groups (comma separated list)</td>
    <td>Указать список групп в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--deploy_env DEPLOY_ID</td>
    <td>Deploy enviroment identifier</td>
    <td>Указать окружение в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--subnets SUBNET,SUBNET...</td>
    <td>Subnets identifier for deploy enviroment (ec2 - only one sybnet, openstack - comma separated list)</td>
    <td>Указать подсети в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--flavor FLAVOR</td>
    <td>Specify flavor for the project</td>
    <td>Указать конфигурацию в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--image IMAGE_ID</td>
    <td>Specify image identifier for the project</td>
    <td>Указать идентификатор образа в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--run_list RUN_LIST</td>
    <td>Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]:</td>
    <td>Указать список кукбук и ролей в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--users USER,USER...</td>
    <td>Users for deploy environment control</td>
    <td>Указать список пользователей в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--provider PROVIDER</td>
    <td>Provider identifier 'ec2' or 'openstack'</td>
    <td>Указать провайдера в опции, а не в интерактивном режиме</td>
  </tr>
  <tr>
    <td>--no_expires</td>
    <td>Without expires time</td>
    <td>Если не нужно указывать время жизни запускаемых серверов</td>
  </tr>
  <tr>
    <td>--expires EXPIRES</td>
    <td>Expires time (5m, 3h, 2d, 1w, etc)</td>
    <td>Указать время жизни сервера в опции, а не в интерактивном режиме</td>
  </tr>
</table>

**devops project delete** - удалить проект или окружение

**devops project deploy** - деплоить все сервера проекта или окружения проекта

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--servers SERVERS</td>
    <td>Servers list (comma separated)</td>
    <td>Список имен серверов, разделенный запятыми</td>
  </tr>
</table>

**devops project list** - вывести список созданных проектов

**devops project servers** - вывести список запущенных машин для проекта или окружения

**devops project set run_list** - изменить run-list для окружения проекта

**devops project show** - показать информацию о проекте

**devops project update** - обновить конфигурацию проекта из файла (файл должен содержать все необходимые параметры в формате JSON)

**devops project user delete** - добавить пользователя (пользователей) в список доступных пользователей для проекта

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--deploy_env ENV</td>
    <td>Add user to deploy enviroment</td>
    <td>Если опция не используется, то пользователь будет добавлен ко всем окружениям проекта</td>
  </tr>
</table>

**devops project user delete** - удалить пользователя (пользователей) из списока доступных пользователей для проекта

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--deploy_env ENV</td>
    <td>Add user to deploy enviroment</td>
    <td>Если опция не используется, то пользователь будет удален из всех окружений проекта</td>
  </tr>
</table>

<h3 id="provider">Provider</h3>

	$ devops provider

	Usage: /usr/bin/devops command [options]

	Commands:
		Provider:
			provider list

**devops provider list** - посмотреть список доступных провайдеров, доступны провайдеры ec2 и openstack (в зависимости от настроек сервера)

<h3 id="script">Script</h3>

Управление скриптами, которые могут быть запущены на сервере (сервер должен быть под управлением devops)

	$ devops script

	Usage: /usr/bin/devops command [options]

	Commands:
		Script:
			script list
			script add SCRIPT_NAME FILE
			script delete SCRIPT_NAME
			script run SCRIPT_NAME NODE_NAME [NODE_NAME  ...]
			script command NODE_NAME 'sh command'

**devops script list** - посмотреть список доступных скриптов (файлов)

**devops script add** - добавить скрипт с именем SCRIPT_NAME из файла FILE на devops-сервер

**devops script delete** - удалить скрипт с именем SCRIPT_NAME с devops-сервера

**devops script run** - запустить скрипт с именем SCRIPT_NAME на серверах NODE_NAME

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--params PARAMS</td>
    <td>Параметры скрипта (список разделенный запятой)</td>
    <td></td>
  </tr>
</table>

**devops script command** - запустить команду на сервере

*Скрипт запускается интерпретатором bash*

<h3 id="server">Server</h3>

	$ devops server

	Usage: /usr/bin/devops command [options]

	Commands:
		Server:
			server add PROJECT_ID DEPLOY_ENV IP SSH_USER KEY_ID
			server bootstrap INSTANCE_ID
			server create PROJECT_ID DEPLOY_ENV
			server delete NODE_NAME [NODE_NAME ...]
			server list [chef|ec2|openstack]
			server pause NODE_NAME
			server show NODE_NAME
			server unpause NODE_NAME

**devops server add** - добавить сервер под управление devops и зарегистрировать его в проекте PROJECT_ID

**devops server bootstrap** - развернуть на сервере инфраструктуру chef и развернуть проект, в котором сервер зарегистрирован

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>-N, --name NAME</td>
    <td>Set chef name</td>
    <td>Задает серверу имя, если не указано, то имя будет сгенерировано автоматически</td>
  </tr>
  <tr>
    <td>--bootstrap_template [TEMPLATE]</td>
    <td>Bootstrap template (optional)</td>
    <td>Если опция не указана, используется шаблон по умолчанию</td>
  </tr>
</table>

**devops server create** - создать сервер для проекта PROJECT_ID и окружения DEPLOY_ENV

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>-N, --name NAME</td>
    <td>Set chef name</td>
    <td>Задает серверу имя, если не указано, то имя будет сгенерировано автоматически</td>
  </tr>
</table>

**devops server delete** - удалить сервер

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--instance</td>
    <td>Delete node by instance id</td>
    <td>Удалить сервер по идентификатору, а не по имени</td>
  </tr>
</table>

**devops server list** - получить список доступных серверов

**devops server pause** - приостановить работу сервера (если сервер запущен в облаке)

**devops server show** - показать детальную информацию о сервере

**server unpause** - возобновить работу сервера

<h3 id="tag">Tag</h3>

Управление тегами на chef-server для указанной сервера. Сервер должен быть создан командами 'server create' или 'server bootstrap'

	$ devops tag

	Usage: /usr/bin/devops command [options]

	Commands:
		Tag:
			tag create NODE_NAME TAG_NAME [TAG_NAME ...]
			tag delete NODE_NAME TAG_NAME [TAG_NAME ...]
			tag list NODE_NAME

**devops tag create** - создать теги на сервере NODE_NAME

**devops tag delete** - удалить теги с сервера NODE_NAME

**devops tag list** - вывести список созданных тегов на сервере NODE_NAME

<h3 id="user">User</h3>

Управление пользователями

	$ devops user

	Usage: /usr/bin/devops command [options]

	Commands:
		User:
			user create USER_NAME
			user delete USER_NAME
			user grant USER_NAME [COMMAND] [PRIVILEGES]
			user list
			user password USER_NAME

**devops user create** - создать пользователя с именем USER_NAME

Опции:

<table>
  <tr>
    <th>Опция</th>
    <th>Описание</th>
    <th>Комментарий</th>
  </tr>
  <tr>
    <td>--password PASSWORD</td>
    <td>New user password</td>
    <td>Указать пароль в опции</td>
  </tr>
</table>

**devops user delete** - удалить пользователя с именем USER_NAME

**devops user grant** - назначить права доступа пользователю

Доступны команды:

*	all
*	flavor
*	group
*	image
*	project
*	server
*	key
*	user
*	filter
*	network
*	provider
*	script

Привилегии:

*	r
*	w
*	rw

Если привилегии не указаны, то пользователю запрещается выполнять команду

Если не указана и команда и привилегии, то права пользователя сбрасываются к правам по умолчанию

**devops user list** - вывести список всех пользователей

**devops user password** - изменить пароль пользователю  USER_NAME

<h1 id="howto">Mini HOWTO</h1>

Опишем основные действия, необходимые для создания проекта и сервера.

<h2 id="howto_user">Создание пользователя</h2>

По умолчанию, у пользователя root нет пароля, давайте зададим его.

	$ devops user password root -u root
	Enter password for 'root':
	Updated

Создадим пользователя 'test' и назначим ему права, необходимые для создания фильтров, образов, проектов и серверов.

Если в системе еще нет ни одного пользователя, то будем действовать от пользователя root.

	$ devops user create test -u root
	Password for root:
	Enter password for 'test':
	Created

Допустим, пользователю 'test' мы задали пароль 'test', эти параметры надо прописать в конфигурационный файл.

При создании нового пользователя, ему назначаются почти все права только на чтение, добавим права на запись для filter, image, project, server:

	$ devops user grant test filter rw -u root
	Password for root:
	Updated

	$ devops user grant test image rw -u root
	Password for root:
	Updated

	$ devops user grant test project rw -u root
	Password for root:
	Updated

	$ devops user grant test server rw -u root
	Password for root:
	Updated

	$ devops user grant test user r -u root
	Password for root:
	Updated

После выполненных действий *в конфигурационном файле должен быть прописан пользователь 'test'*

<h2 id="howto_image">Создание образа</h2>

Прежде всего необходимо узнать идентификаторы нужных образов и добавить их в фильтр.

	devops filter image add openstack 78665e7b-5123-4fa8-b39b-d7643ecd8ed7

Теперь можно создать образ

	$ devops image create
	+--------+-----------+
	| API version: v2.0  |
	|      Provider      |
	+--------+-----------+
	| Number | Provider  |
	+--------+-----------+
	| 1      | ec2       |
	| 2      | openstack |
	+--------+-----------+
	Provider: 2
	+--------+---------------------------+--------------------------------------+--------+
	|                                 API version: v2.0                                  |
	|                                       Images                                       |
	+--------+---------------------------+--------------------------------------+--------+
	| Number | Name                      | ID                                   | Status |
	+--------+---------------------------+--------------------------------------+--------+
	| 1      | centos-6.4-amd64-20130707 | 78665e7b-5123-4fa8-b39b-d7643ecd8ed7 | ACTIVE |
	+--------+---------------------------+--------------------------------------+--------+
	Image: 1
	The ssh username: root
	Bootstrap template (optional):
	{
	  "provider": "openstack",
	  "name": "centos-6.4-amd64-20130707",
	  "id": "78665e7b-5123-4fa8-b39b-d7643ecd8ed7",
	  "remote_user": "root"
	}
	Create image? (y/n):

Если все параметры верны, то можно нажать на 'y' и проект будет создан.

<h2 id="howto_project">Создание проекта</h2>

Создадим проект 'my_project' с окружением 'test'

	$ devops project create my_project
	Deploy environment identifier: test
	+--------+-----------+
	| API version: v2.0  |
	|      Provider      |
	+--------+-----------+
	| Number | Provider  |
	+--------+-----------+
	| 1      | ec2       |
	| 2      | openstack |
	+--------+-----------+
	Provider: 2

Выбираем группы безопасности или нажимаем Enter, чтобы использовать группу по умолчанию

	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	|                                                API version: v2.0                                                 |
	|                                                      Groups                                                      |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| Number | Name                                | Protocol | From | To    | CIDR      | Description                 |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| 1      | default                             | udp      | 1    | 65535 | 0.0.0.0/0 | default                     |
	|        |                                     | tcp      | 1    | 65535 | 0.0.0.0/0 |                             |
	|        |                                     | icmp     | -1   | -1    | 0.0.0.0/0 |                             |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| 2      | webports                            | tcp      | 8080 | 8080  | 0.0.0.0/0 | web ports                   |
	|        |                                     | tcp      | 80   | 80    | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 8089 | 8089  | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 8443 | 8443  | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 443  | 443   | 0.0.0.0/0 |                             |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	Security groups (comma separated), like 1,2,3, or empty for 'default':

Указываем пользователей, которые могут работать с окружением проекта, пользователь, который создает окружение будет автоматически добавлен, можно нажать Enter.

	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	|                                                     API version: v2.0                                                     |
	|                                                           Users                                                           |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	|        |                  |                                          Privileges                                           |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| Number | User ID          | Image | Key | Project | Server | User | Script | Filter | Flavor | Group | Network | Provider |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| 1      | test             | rw    | r   | rw      | rw     | r    | r      | rw     | r      | r     | r       | r        |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| 2      | root             | rw    | rw  | rw      | rw     | rw   | rw     | rw     | rw     | rw    | rw      | rw       |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	Users, you will be added automatically (comma separated), like 1,2,3, or empty:

Выбмраем параметры сервера. Например, нам надо чтобы проект был развернут на сервере с характеристиками: одно ядро, 20Гб диск и 2Гб RAM, выбирает flavor с номером 7

	+--------+-----------+--------------+------+-------+
	|                API version: v2.0                 |
	|                     Flavors                      |
	+--------+-----------+--------------+------+-------+
	| Number | ID        | Virtual CPUs | Disk | RAM   |
	+--------+-----------+--------------+------+-------+
	| 1      | c1.large  | 8            | 50   | 8192  |
	| 2      | c1.medium | 2            | 50   | 2048  |
	| 3      | c1.small  | 2            | 20   | 1024  |
	| 4      | c2.long   | 2            | 120  | 4096  |
	| 5      | m1.large  | 4            | 80   | 8192  |
	| 6      | m1.medium | 2            | 40   | 4096  |
	| 7      | m1.small  | 1            | 20   | 2048  |
	| 8      | m1.tiny   | 1            | 3    | 512   |
	| 9      | m1.xlarge | 8            | 160  | 16384 |
	| 10     | m2.long   | 2            | 60   | 2048  |
	| 11     | snapshot  | 2            | 42   | 2048  |
	+--------+-----------+--------------+------+-------+
	Flavor: 7

Выбираем ранее созданый образ

	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	|                                                    API version: v2.0                                                     |
	|                                                          Images                                                          |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	| Number | ID                                   | Name                      | Bootstrap template | Remote user | Provider  |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	| 1      | 78665e7b-5123-4fa8-b39b-d7643ecd8ed7 | centos-6.4-amd64-20130707 |                    | root        | openstack |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	Image: 1

Если нам надо, чтобы проект был развернут в подсети 10.0.0.0/24, тогда выбираем подсеть с номером 5

	+--------+--------------+-----------------+
	|            API version: v2.0            |
	|                 Subnets                 |
	+--------+--------------+-----------------+
	| Number | Name         | CIDR            |
	+--------+--------------+-----------------+
	| 1      | 172.16.223.0 | 172.16.223.0/24 |
	| 2      | 172.16.227.0 | 172.16.227.0/24 |
	| 3      | LocalNetwork | 172.16.37.0/24  |
	| 4      | LocalNetwork | 10.1.98.0/24    |
	| 5      | private      | 10.0.0.0/24     |
	+--------+--------------+-----------------+
	Subnets (comma separated), like 1,2,3, or empty: 5

Укажем роли и рецепты необходимые для развертывания проекта. При создании окружения, на chef-сервере будет создана роль с именем 'my_project_test', эта же роль по умолчанию включается в список. Роль нужно настроить на chef-сервере.

	Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]: role[my_project_test],

Нам не нужно уничтожать сервер через заданный промежуток времени, поэтому просто жмем Enter.

	Enter expires time if necessary (5m, 3h, 2d, 1w, etc):

Второго окружения мы создавать не будем, поэтому жмем 'n'

	Add deploy environment? (y/n): n
	{
	  "deploy_envs": [
	    {
	      "identifier": "test",
	      "provider": "openstack",
	      "groups": [
	        "default"
	      ],
	      "users": [
	        "test"
	      ],
	      "flavor": "m1.small",
	      "image": "78665e7b-5123-4fa8-b39b-d7643ecd8ed7",
	      "subnets": [
	        "private"
	      ],
	      "run_list": [
	        "role[my_project_test]"
	      ],
	      "expires": null
	    }
	  ],
	  "name": "my_project"
	}
	Create project? (y/n):

Если все правильно, жмем 'y' и проект будет создан.

<h2 id="howto_server">Запуск сервера</h2>

Теперь запустить новый сервер очень просто, нужно выполнить команду

	devops server create my_project test -N my_server_1

Параметр '-N' говорит о том, что серверу нужно задать имя. Если параметр не указывать, то имя будет сгенерировано автоматически.
