#!/bin/bash

#future function add password in build phase
password_dialog() {
	while [[ "$passphrase" != "$passphrase_repeat" || ${#passphrase} -lt 8 ]]; do

		passphrase=$(whiptail --passwordbox "${passphrase_invalid_message}Please enter the passphrase (8 chars min.):" 20 78 3>&1 1>&2 2>&3)
		passphrase_repeat=$(whiptail --passwordbox "Please repeat the passphrase:" 20 78 3>&1 1>&2 2>&3)
		passphrase_invalid_message="Passphrase too short, or not matching! "
	done
	echo $passphrase
}
#test=$( password_dialog )

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

#function copies the template yml file to the local service folder and appends to the docker-compose.yml file
function yml_builder() {
	service="services/$1/service.yml"

	[ -d ./services/ ] || mkdir ./services/

	if [ -d ./services/$1 ]; then
		#directory already exists prompt user to overwrite
		sevice_overwrite=$(whiptail --radiolist --title "Overwrite Option" --notags \
			"$1 service directory has been detected, use [SPACEBAR] to select you overwrite option" 20 78 12 \
			"none" "Do not overwrite" "ON" \
			"env" "Preserve Environment and Config file" "OFF" \
			"full" "Pull full service from template" "OFF" \
			3>&1 1>&2 2>&3)

		case $sevice_overwrite in

		"full")
			echo "...pulled full $1 from template"
			rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh'
			;;
		"env")
			echo "...pulled $1 excluding env file"
			rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh' --exclude '$1.env' --exclude $(*.conf)
			;;
		"none")
			echo "...$1 service not overwritten"
			;;

		esac

	else
		mkdir ./services/$1
		echo "...pulled full $1 from template"
		rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh'
	fi

	cat $service >>docker-compose.yml

	#test for post build
	if [ -f ./.templates/$1/build.sh ]; then
		chmod +x ./.templates/$1/build.sh
		bash ./.templates/$1/build.sh
	fi

}

#---------------------------------------------------------------------------------------------------
# Menu system starts here
# Display main menu
mainmenu_selection=$(whiptail --title "Main Menu" --menu --notags \
	"" 20 78 12 -- \
	"install" "Install Docker" \
	"build" "Build Stack" \
	"commands" "Docker commands" \
	3>&1 1>&2 2>&3)

case $mainmenu_selection in
#MAINMENU Install docker  ------------------------------------------------------------
"install")
	#sudo apt update && sudo apt upgrade -y ;;

	if command_exists docker; then
		echo "docker already installed"
	else
		echo "Install Docker"
		curl -fsSL https://get.docker.com | sh
		sudo usermod -aG docker $USER
	fi

	if command_exists docker-compose; then
		echo "docker-compose already installed"
	else
		echo "Install docker-compose"
		sudo apt install -y docker-compose
	fi

	if (whiptail --title "Restart Required" --yesno "It is recommended that you restart you device now. Select yes to do so now" 20 78); then
		sudo reboot
	fi
	;;
	#MAINMENU Build stack ------------------------------------------------------------
"build")
	container_selection=$(whiptail --title "Container Selection" --notags --separate-output --checklist \
		"Use the [SPACEBAR] to select which containers you would like to install" 20 78 12 \
		"portainer" "Portainer" "ON" \
		"nodered" "Node-RED" "ON" \
		"influxdb" "InfluxDB" "ON" \
		"telegraf" "Telegraf (Requires InfluxDB and Mosquitto)" "OFF" \
		"grafana" "Grafana" "ON" \
		"mosquitto" "Eclipse-Mosquitto" "ON" \
		"postgres" "Postgres" "OFF" \
		3>&1 1>&2 2>&3)

	mapfile -t containers <<<"$container_selection"

	#if no container is selected then dont overwrite the docker-compose.yml file
	if [ -n "$container_selection" ]; then
		touch docker-compose.yml
		echo "version: '2'" >docker-compose.yml
		echo "services:" >>docker-compose.yml

		#Run yml_builder of all selected containers
		for container in "${containers[@]}"; do
			echo "Adding $container container"
			yml_builder "$container"
		done

		echo "docker-compose successfully created"
		echo "run 'docker-compose up -d' to start the stack"
	else
		echo "Build cancelled"

	fi
	;;
	#MAINMENU Docker commands -----------------------------------------------------------
"commands")

	docker_selection=$(whiptail --title "Docker commands" --menu --notags \
		"Shortcut to common docker commands" 20 78 12 -- \
		"start" "Start stack" \
		"restart" "Restart stack" \
		"stop" "Stop stack" \
		"stop_all" "Stop any running container regardless of stack" \
		"pull" "Update all containers" \
		"prune_volumes" "Delete all stopped containers and docker volumes" \
		"prune_images" "Delete all images not associated with container" \
		3>&1 1>&2 2>&3)

	case $docker_selection in
	"start") ./scripts/start.sh ;;
	"stop") ./scripts/stop.sh ;;
	"stop_all") ./scripts/stop-all.sh ;;
	"restart") ./scripts/restart.sh ;;
	"pull") ./scripts/update.sh ;;
	"prune_volumes") ./scripts/prune-volumes.sh ;;
	"prune_images") ./scripts/prune-images.sh ;;
	esac
	;;

*) ;;

esac
