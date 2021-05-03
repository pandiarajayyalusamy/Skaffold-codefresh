#!/usr/bin/env sh
#

set -x
DIR=`pwd`

command=$1

export OPENAM_HOME=${OPENAM_HOME:-/home/forgerock/openam}


run() {
    cd "${CATALINA_HOME}"
    exec "${CATALINA_HOME}/bin/catalina.sh" run
}