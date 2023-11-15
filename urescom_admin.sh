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
	echo "bash		Give a bash prompt on the uRescom server"
	echo "config		Show docker compose complete config"
	echo "df		Show disk space consumed by images/containers/volumes"
	echo "down	Down Docker compose stack"
	echo "images		Show Docker images"
	echo "logs		Show uRescom logs (last 40 lines). You can add an optional argument to set a different # of lines to show"
	echo "logs-all	Show all uRescom logs (since container started)"
	echo "logs-f		Show uRescom logs with -f flag (last 20 lines)"
	echo "prune		Prune Docker images not needed"
	echo "recreate	Pull base images, build uRescom and run 'docker compose up -d'"
	echo "restart		Restart uRescom service (Important: env variables in the container are NOT changed)"
	echo "start		Start uRescom service"
	echo "status		Show status"
	echo "stop		Stop uRescom service (docker compose stop)"
	echo "up		Docker compose up (usually if we have changed the env file)"
	echo "version		Show pusdate label for institution image (acts as version)"
	echo "volume		Show volume stats (to gauge space used by MariaDB)"
	exit 1
}

if [[ -v ${URESCOM_TESTING} ]]; then
	TEST_CONFIG="-f docker-compose.yaml -f docker-compose.test.yaml"
fi

if [[ $# -eq 0 ]]; then
	help
fi

case $1 in
bash)
	echo "Opening bash prompt.."
	docker exec -it urescom-install_urescom_1 bash
	;;
config)
	echo -e "${BOLD}Docker Compose Config..${NC}"
	${COMPOSE} ${TEST_CONFIG} config
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
recreate)
	echo -e "${BOLD}Docker Compose pull uResocm base..${NC}"
	${COMPOSE} -f docker-compose.build.yaml pull urescom-base
	echo -e "${BOLD}Docker Compose build..${NC}"
	${COMPOSE} -f docker-compose.build.yaml build
	echo -e "${BOLD}Docker Compose pull images..${NC}"
	${COMPOSE} ${TEST_CONFIG} pull --ignore-pull-failures
	echo -e "${BOLD}Docker Compose up..${NC}"
	${COMPOSE} ${TEST_CONFIG} up -d
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
up)
	echo -e "${BOLD}Docker Compose up..${NC}"
	${COMPOSE} ${TEST_CONFIG} up -d
	;;
version)
	echo -n "Version number: "
	set -x
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
