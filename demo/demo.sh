#!/usr/bin/env bash

# TLDR; Setup steps
<<COMMENT
    make deps
    docker-compose up -d
    ./demo.sh  # this script
COMMENT

# install the demo-magic script
if [ ! -f /tmp/demo-magic.sh ]; then
    curl -fsSL https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh \
	 -o /tmp/demo-magic.sh
fi

# install pv and jq
if ! which pv >/dev/null || ! which jq >/dev/null; then
    if [ `uname` = "Darwin" ]; then
  brew install pv jq
    else
  sudo apt-get -yq install pv jq
    fi
fi

# Configure the options

# speed at which to simulate typing. bigger num = faster
TYPE_SPEED=80

# include the magic
. /tmp/demo-magic.sh

# custom prompt
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W$ "


echo -n "Type 'yes' to cleanup all caches from prior run: "
read cleanup
if [ $cleanup == "yes" ]; then
  docker image rm $(docker image ls -q) 2>&1 >/dev/null || true
  docker kill $(docker ps -q) 2>&1 >/dev/null || true
  rm -rf target
fi

# hide the evidence
clear

# put your demo awesomeness here

echo "# This docker demo will"
echo "#   1) Compile/build the sample-spring-boot-app using maven"
echo "#   2) Build a Docker image that contains the sample-spring-boot-app"
echo "#   3) Push the sample-spring-boot-app to the docker registry"
echo "#   4) Docker pull and run the sample-spring-boot-app from the docker registry"
pe "clear"


echo "###########################################################"
echo "#   0) Ensure we have a clean state for this demo"
echo "###########################################################"
echo "# This is the clean project directory with no build artifacts"
pe "tree"
pe "docker ps"
pe "docker images"
pe "clear"


echo "###########################################################"
echo "#   1) Compile/build the sample-spring-boot-app using maven"
echo "###########################################################"
echo "# Check out this maven build file"
pe "cat pom.xml"
pe "clear"

echo "# Note that this machine does not have maven installed"
pe "mvn -h"
p  ""
echo "# But we can run maven from a docker image"
echo "#   We'll use the docker container maven:3.5.2-jdk-8-alpine'"
pe "docker run -it --rm --name maven maven:3.5.2-jdk-8-alpine mvn -h"
pe "clear"

echo "# So let's use the maven docker image to build our project"
pe 'docker run -it --rm --name maven-builder -v "$PWD":/mnt -w /mnt maven:3.5.2-jdk-8-alpine mvn install'
pe "clear"

echo "# The finished build should be in the ./target folder"
pe "tree target"
pe "clear"

echo "# Notice that this machine does not have java installed"
pe "java -h"
pe "clear"

echo "# List the images in our local docker cache"
pe "docker images"
pe "clear"

echo "# We're going to download the jre so that we can run our new jar file"
pe "docker pull openjdk:8-jre-alpine"
pe "clear"

echo "# The prior step was optional, because docker run will pull an image if its not already there"
echo "# We're going to run the newly built jar file using java in a docker container"
p 'docker run --rm --name sample-spring-boot-app -p 8080:8080 -v "$PWD":/mnt -w /mnt openjdk:8-jre-alpine java -jar ./target/sample-spring-boot-app-0.1.0.jar &'
docker run --rm --name sample-spring-boot-app -p 8080:8080 -v "$PWD":/mnt -w /mnt openjdk:8-jre-alpine java -jar ./target/sample-spring-boot-app-0.1.0.jar &
p "# Now let's make sure the webserver is working"
pe "curl -v http://localhost:8080"
pe "clear"

echo "# Let's kill the webserver"
pe "docker stop $(docker ps -q)"
pe "clear"

echo "###########################################################"
echo "#   2) Build a Docker image that contains the sample-spring-boot-app"
echo "###########################################################"

echo "Lets take a look at the Dockerfile"
pe "cat Dockerfile"
pe "clear"

echo "Lets build the image using the Dockerfile"
pe "docker build -f Dockerfile --tag containers.cisco.com/sopdsre/sample-spring-boot-app:0.1.0 ."
echo "Let's look at our newly built Docker Image"
pe "docker images"
pe "clear"


echo "###########################################################"
echo "#   3) Push the sample-spring-boot-app to the docker registry"
echo "###########################################################"
echo "We would like to push that image to a repository"
echo "Let's authenticate with the docker registry using the robot account"
pe 'docker login -u="sopdsre+user" -p="JEWXAE7GVYKA9IOCAY6MDCFOLDJNV5ZWJLBQQYJ6X8DHBLNKI04SW6IZNG2D09G2" containers.cisco.com'
pe "clear"

echo "Let's push that image that we just created"
pe "docker push containers.cisco.com/sopdsre/sample-spring-boot-app:0.1.0"
pe "clear"


echo "Check out what images we have locally on our machine"
pe "docker images"
pe "clear"

echo "Let's remove all of the images that we have just built"
pe "docker image rm $(docker image ls|grep sample-spring-boot-app | awk -F' ' '{print $3}')"
pe "clear"

echo "Check out what images we have locally on our machine"
pe "docker images"
pe "clear"


echo "###########################################################"
echo "#   4) Docker pull and run the sample-spring-boot-app from the docker registry"
echo "###########################################################"

echo "# Run the docker image directly from the registry"
p 'docker run --rm --name sample-spring-boot-app -p 8080:8080 containers.cisco.com/sopdsre/sample-spring-boot-app:0.1.0 &'
docker run --rm --name sample-spring-boot-app -p 8080:8080 containers.cisco.com/sopdsre/sample-spring-boot-app:0.1.0 &

p "# Now let's make sure the webserver is working"
pe "curl -v http://localhost:8080"
pe "clear"

echo "# Let's kill the webserver"
pe "docker stop $(docker ps -q)"
pe "clear"


echo "# Notice the difference between the two running command lines"
echo "# This command line runs the jar file using the docker JRE image"
echo "#   docker run --rm --name sample-spring-boot-app -p 8080:8080 -v "$PWD":/mnt -w /mnt openjdk:8-jre-alpine java -jar ./target/sample-spring-boot-app-0.1.0.jar"
echo "# While this command line runs docker from the docker app image which uses the JRE image as the base image"
echo "# docker run --rm --name sample-spring-boot-app -p 8080:8080 containers.cisco.com/sopdsre/sample-spring-boot-app:0.1.0"
pe "clear"

# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""

