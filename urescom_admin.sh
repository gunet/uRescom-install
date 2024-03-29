#!/bin/bash

COMPOSE="docker-compose"
TEST_CONFIG=""

BOLD='\033[1m'
NC='\033[0m'
IMAGE='ghcr.io/gunet/urescom-base'


help () {
	echo "Usage: $0 <command>"
	echo ""
	echo "If env var URESCOM_TESTING is set to 1 we use the complete testing stack"
	echo "ie URESCOM_TESTING=1 $0 recreate"
	echo ""
	echo "Available commands:"
	echo "backup [dst]		Backup MariaDB to <dst> or if <dst> is not provided to /var/tmp/urescom.sql"
	echo "bash						Give a bash prompt on the uRescom server"
	echo "config					Show docker compose complete config"
	echo "destroy					Remove EVERYTHING: containers, images and volumes (used by MariaDB). Totally destructive!"
	echo "df							Show disk space consumed by images/containers/volumes"
	echo "down						Down Docker compose stack"
	echo "images					Show Docker images"
	echo "logs						Show uRescom logs (last 40 lines). You can add an optional argument to set a different # of lines to show"
	echo "logs-all				Show all uRescom logs (since container started)"
	echo "logs-f					Show uRescom logs with -f flag (last 20 lines)"
	echo "prune						Prune Docker images not needed"
	echo "ps							Show running services"
	echo "recreate				Pull images and run 'docker compose up -d'"
	echo "remove					Remove containers AND images to be able to start over (calls down with the --rmi all option)"
	echo "restart					Restart uRescom service (Important: env variables in the container are NOT changed)"
	echo "start						Start uRescom service"
	echo "status					Show status"
	echo "stop						Stop uRescom service (docker compose stop)"
	echo "test						Check that the admin has actually setup a production level environment"
	echo "up				 			Docker compose up (usually if we have changed the env file)"
	echo "version					Show pusdate label for institution image (acts as version)"
	echo "volume					Show volume stats (to gauge space used by MariaDB)"
	exit 1
}

if [[ -v ${URESCOM_TESTING} ]]; then
	TEST_CONFIG="-f docker-compose.yaml -f docker-compose.test.yaml"
fi

if [[ $# -eq 0 ]]; then
	help
fi

case $1 in
backup)
	BACKUP=/var/tmp/urescom.sql
	if [[ $# -eq 2 ]]; then
		BACKUP=$2
	fi
	echo -e "${BOLD}Backing up MariaDB to ${BACKUP}..${NC}"
	docker run --rm --network urescom-install_default ghcr.io/gunet/urescom-mariadb mysqldump --host=db --user=urescom --password=secret urescom >${BACKUP}
	echo "Finished!"
	;;
bash)
	echo "Opening bash prompt.."
	docker exec -it urescom-install_urescom_1 bash
	;;
config)
	echo -e "${BOLD}Docker Compose Config..${NC}"
	${COMPOSE} ${TEST_CONFIG} config
	;;
destroy)
	echo -e "${BOLD}Docker Compose Remove everything (containers, images and volumes)..${NC}"
	${COMPOSE} ${TEST_CONFIG} down --rmi all --volumes
	;;
df)
	docker system df
	;;
down)
	echo -e "${BOLD}Docker Compose Down..${NC}"
	${COMPOSE} ${TEST_CONFIG} down
	;;
images)
	echo "uRescom images.."
	${COMPOSE} ${TEST_CONFIG} images
	;;
logs)
	if [[ $# -eq 2 ]]; then
		LINES=$2
	else
		LINES=40
	fi
	echo "Showing ${LINES} lines of logs.."
	${COMPOSE} logs --tail=${LINES} urescom
	;;
logs-all)
	${COMPOSE} logs urescom
	;;
logs-f)
	${COMPOSE} logs -f --tail=20 urescom
	;;
prune)
	echo -e "${BOLD}Docker image prune..${NC}"
	docker image prune -f
	;;
ps)
	echo -e "${BOLD}Active services..${NC}"
	${COMPOSE} ${TEST_CONFIG} ps
	;;
recreate)
	echo -e "${BOLD}Docker Compose pull images..${NC}"
	${COMPOSE} ${TEST_CONFIG} pull
	echo -e "${BOLD}Docker Compose up..${NC}"
	${COMPOSE} ${TEST_CONFIG} up -d
	;;
remove)
	echo -e "${BOLD}Docker Compose Down and RMI (remove images)..${NC}"
	${COMPOSE} ${TEST_CONFIG} down --rmi all
	;;
restart)
	echo -e "${BOLD}Docker Compose restart uRescom..${NC}"
	${COMPOSE} restart urescom
	;;
start)
	echo -e "${BOLD}Docker Compose start..${NC}"
	${COMPOSE} ${TEST_CONFIG} start
	;;
status)
	echo -e "${BOLD}Docker Compose ps..${NC}"
	${COMPOSE} ${TEST_CONFIG} ps
	echo -e "${BOLD}Docker Compose top..${NC}"
	${COMPOSE} ${TEST_CONFIG} top
	echo -e "${BOLD}Showing last 10 log lines..${NC}"
	${COMPOSE} logs --tail=10 urescom
	;;
stop)
	echo -e "${BOLD}Docker Compose stop..${NC}"
	${COMPOSE} ${TEST_CONFIG} stop
	;;
test)
	echo -e "${BOLD}Checking environemnt variables..${NC}"
	source variables.env
	if [[ ${URESCOM_SITE} == "https://localhost" ]]; then
		echo "Variable URESCOM_SITE has not been set"
		exit 1
	elif [[ ${URESCOM_SQL_HOST} == "mssql" ]]; then
		echo "MSSQL (Rescom) DB variables have not been set"
		exit 1
	elif [[ ${URESCOM_CAS_HOSTNAM} == "localhost" ]]; then
		echo "CAS server has not been set"
		exit 1
	elif [[ ${VDUSER_PASSWORD} == "secret" ]]; then
		echo "vduser password has not been set"
		exit 1
	fi
	echo -e "${BOLD}Checking certificate..${NC}"
	openssl x509 -subject -noout -in institution/certs/server.crt |grep ^subject|grep -q urescom.gunet.gr
	if [[ $? -eq 0 ]]; then
		echo "Certificate is issued to urescom.gunet.gr, not a production server"
		exit 1
	fi
	echo -e "${BOLD}Tests finished..${NC}"
	;;
up)
	echo -e "${BOLD}Docker Compose up..${NC}"
	${COMPOSE} ${TEST_CONFIG} up -d
	;;
version)
	echo -n "Version number: "
	VERSION=$(docker image inspect ${IMAGE}:latest|grep pushdate| awk '{print $2}'|tr -d '",')
	echo -e "${BOLD}$VERSION ${NC}"
	;;
volume)
	echo -e "${BOLD}Volume stats..${NC}"
	docker system df|egrep '^(TYPE|Images|Local Volumes)'
	;;
*)
	echo "Unknown option"
	exit 1
	;;
esac
