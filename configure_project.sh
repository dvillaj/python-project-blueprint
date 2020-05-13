#!/bin/bash

usage () { echo "./configure_project.sh -m <module> [ -r <docker registry> ] "; }

while getopts hm:r: option
do
	case "${option}"
	in
		m) MODULE=${OPTARG};;
		r) REGISTRY=${OPTARG};;
    h) usage; exit;;
	esac
done

if [ -z "$MODULE" ]
then
    echo "Module is missing" >&2
    usage
    exit 1
fi

if [ -z "REGISTRY" ]
then
    REGISTRY = DUMMY_REGISTRY
fi

DUMMY_MODULE='blueprint'
DUMMY_REGISTRY='docker.pkg.github.com/martinheinz/python-project-blueprint'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}Renaming variables and files...${NC}\n"

sed -i s/$DUMMY_MODULE/$MODULE/g dev.Dockerfile
sed -i s/$DUMMY_MODULE/$MODULE/g prod.Dockerfile
sed -i s/$DUMMY_MODULE/$MODULE/g tests/context.py
sed -i s/$DUMMY_MODULE/$MODULE/g tests/test_app.py
mv $DUMMY_MODULE $MODULE

sed -i s/$DUMMY_MODULE/$MODULE/g pytest.ini
sed -i s/$DUMMY_MODULE/$MODULE/g setup.cfg
sed -i s/$DUMMY_MODULE/$MODULE/g sonar-project.properties
sed -i s~$DUMMY_REGISTRY~$REGISTRY~g Makefile
sed -i s/example/$MODULE/g Makefile
sed -i s/$DUMMY_MODULE/$MODULE/g Makefile

echo -e "\n${BLUE}Testing if everything works...${NC}\n"

echo -e "\n${BLUE}Test: make run${NC}\n"
make run
echo -e "\n${BLUE}Test: make test${NC}\n"
make test
echo -e "\n${BLUE}Test: make build-dev${NC}\n"
make build-dev

