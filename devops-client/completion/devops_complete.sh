_devops()
{

	local cur prev cmds cmd
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"


	PROVIDERS="ec2 openstack"

	grant=""
	project="create delete list servers set show update add_user remove_user"
	server="bootstrap create delete list pause show unpause add"

	declare -A commands=( [flavor]=1 [group]=1 [image]=1 [project]=0 [server]=0 [deploy]=1 [key]=1 [user]=1 [grant]=0 [tag]=1 [provider]=1 [network]=1 [script]=1 )

	case "${COMP_CWORD}" in
		1)
			#cmds="${!commands[@]}"
			#cmds="--help --version --completion"
			cmds=""
			if [[ "$cur" =~ ^-.* ]]; then
				_devops_options
			else
				for i in "${!commands[@]}"
				do
					if [ ${commands[$i]} -eq 1 ]; then
						cmds="$cmds $i"
					fi
				done
				_set_devops_params
			fi
			;;
		*)
			if [ ${commands[${COMP_WORDS[1]}]} -ne 1 ]; then
				# invalid command
				return
			fi
			eval _devops_${COMP_WORDS[1]} ${COMP_WORDS[@]:2}
			;;
	esac

#	case "$cmds" in
#		PROVIDERS)
#			cmds=$PROVIDERS
#			;;
#		FILE)
#			COMPREPLY=($(compgen -f  "${COMP_WORDS[${COMP_CWORD}]}" ))
#			return 0
#			;;
#	esac

#	COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
	return 0
}

_devops_flavor()
{
	case "$1" in
		list)
			case "$2" in
				ec2|openstack)
					_devops_options ""
					;;
				*)
					_set_devops_params_providers
					;;
			esac
			;;
		*)
			cmds="list"
			_set_devops_params
			;;
	esac
}
alias _devops_group=_devops_flavor
alias _devops_network=_devops_flavor

_devops_provider()
{
	case "$1" in
		list)
			case "$2" in
				*)
					_devops_options ""
					;;
			esac
			;;
		*)
			cmds="list"
			_set_devops_params
			;;
	esac
}

_devops_deploy()
{
	cmds="NODE_NAME"
	_set_devops_params
}

_devops_user()
{
	case "$1" in
		list)
			;;
		create)
			;;
		delete)
			;;
		grant)
			;;
		password)
			;;
		*)
			cmds="create delete grant list password"
			_set_devops_params
			;;
	esac
}

_devops_tag()
{
	case "$1" in
		list)
            ;;
		create)
            ;;
		delete)
            ;;
		*)
	        cmds="create delete list"
			_set_devops_params
			;;
	esac
}

_devops_key()
{
	case "$1" in
		list)
            ;;
		add)
            ;;
		delete)
            ;;
		*)
	        cmds="add delete list"
			_set_devops_params
			;;
	esac
}

_devops_image()
{
	case "$1" in
		list)
			case "$2" in
				provider)
					case "$3" in
						ec2|openstack)
							_devops_options ""
							;;
						*)
							_set_devops_params_providers
							;;
					esac
					;;
				*)
					cmds="provider"
					_set_devops_params
					;;
			esac
			;;
		create)
			_devops_options
			;;
		update)
			if [[ "$2" == "" ]]; then
				cmds="IMAGE"
				_set_devops_params
			else
				if [[ $COMP_CWORD -eq 4 ]]; then
					_set_devops_params_file
				else
					_devops_options ""
				fi
			fi
			;;
		delete|show)
			if [[ "$2" == "" ]]; then
				cmds="IMAGE"
				_set_devops_params
			else
				_devops_options ""
			fi
			;;
		*)
			cmds="create delete list show update"
			_set_devops_params
			;;
	esac
}

_devops_script()
{
	case "$1" in
		list)
            ;;
		add)
            ;;
		run)
            ;;
		delete)
            ;;
		command)
            ;;
		*)
        	cmds="list add delete run command"
			_set_devops_params
			;;
	esac
}

_devops_options()
{
	declare -A common_options=([--help]="" [--version]="" [--host]="HOST" [--api]="API" [--user]="USER" [--format]="table json" [--completion]="")
	val="${common_options[${COMP_WORDS[COMP_CWORD - 1]}]}"
	if [ -z "$val" ]; then
		cmds="${!common_options[@]}"
	else
		cmds="$val"
	fi
	_set_devops_params
}

# set copmletion providers
_set_devops_params_providers()
{
	cmds="ec2 openstack"
	_set_devops_params
}

# set copmletion from $cmds
_set_devops_params()
{
	COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
}

# set copmletion if type is FILE
_set_devops_params_file()
{
	COMPREPLY=($(compgen -f  "${COMP_WORDS[${COMP_CWORD}]}" ))
}
complete -o filenames -o bashdefault -F _devops devops
