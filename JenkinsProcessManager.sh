#! /bin/bash -p
# www.donaldsimpson.co.uk
# Script to start|stop|restart|check an instance of Jenkins
# For each new instance, the PROJECT and HTTP_PORT need to be updated:
export PROJECT=jenkins
export HTTP_PORT=9000

EXIT_STRING=””
JENKINS_ROOT=/opt/apps/jenkins
export JENKINS_HOME=${JENKINS_ROOT}/${PROJECT}

JENKINS_WAR=${JENKINS_HOME}/jenkins.war
WAIT_TIME=5
START_WAIT_TIME=15
JAVA_HOME=/usr
PATH=$JAVA_HOME/bin:$PATH
JAVA=${JAVA_HOME}/bin/java
NOHUP=/usr/bin/nohup
LOG_FILE=${JENKINS_HOME}/debug_${PROJECT}.log
MARKER=”JenkinsProcFor_${PROJECT}”
NC=/bin/nc
WGET=/usr/bin/wget
LSOF=/usr/bin/lsof
AWK=/usr/bin/awk
GREP=/bin/grep
FUSER=/bin/fuser
#################################################################################
### Functions Start #############################################################
#################################################################################

cleanup(){
  # Perform any clean-up activities here…
  [ “${EXIT_STRING}” != “0” ] && echo `date “+%d/%m/%y %H:%M:%S”` ${EXIT_STRING}
  exit 0
}

trap ” QUIT

_error() {
  EXIT_STRING=”${1}”
  [ “${1}” != “0” ] && EXIT_STRING=”ERROR: ${1}, please investigate, terminating.”
  cleanup  # Never returns from this call…
}

say(){
  echo `date “+%d/%m/%y %H:%M:%S”` “${1}”
}

saybold(){
  tput bold 2>/dev/null
  echo `date “+%d/%m/%y %H:%M:%S”` “${1}”
  tput sgr0 2>/dev/null
}

check_folders(){
  say “”
  saybold “Checking all required folders exist…”
  for REQUIRED_DIR in ${JENKINS_ROOT} ${JENKINS_HOME} ${JAVA_HOME}
  do
    [ ! -d “${REQUIRED_DIR}” ] && _error “Necessary directory: ${REQUIRED_DIR} does not exist”
    say “Found required directory: ${REQUIRED_DIR}”
  done
  saybold “Done.”
  say “”
}

check_files(){
  say “”
  saybold “Checking all required files exist…”
  for REQUIRED_FILE in ${JENKINS_WAR} ${NC} ${WGET} ${JAVA} ${LSOF} ${FUSER} ${GREP} ${AWK}
  do
    [ ! -f “${REQUIRED_FILE}” ] && _error “Necessary file: ${REQUIRED_file} does not exist”
    say “Found required file ${REQUIRED_FILE}”
  done
  saybold “Done.”
  say “”
}

check_port_closed(){
  say “Checking that port ${HTTP_PORT} is closed…”
  ${NC} -w 1 localhost ${HTTP_PORT}
  if [ $? -eq 0 ]; then
    _error “Required Jenkins port ${HTTP_PORT} is already in use”
  else
    say “Ok, required port ${HTTP_PORT} is available, continuing…”
  fi
}

check_port_open(){
  say “Checking that port ${HTTP_PORT} is open…”
  ${NC} -w 1 localhost ${HTTP_PORT}
  if [ $? -eq 0 ]; then
    say “Ok, a process is listening on port ${HTTP_PORT}, continuing…”
  else
    _error “Required Jenkins port ${HTTP_PORT} has not been opened.”
  fi
}

start_process(){
  cd ${JENKINS_HOME}
  saybold “Starting Process now…”
  ${NOHUP} ${JAVA} -jar ${JENKINS_WAR} -D${MARKER} –httpListenAddress=0.0.0.0 –httpPort=${HTTP_PORT} > ${LOG_FILE} &
  say “Process initiated.”
}

check_log(){
  say “Checking the log file ${LOG_FILE} for an HTTP listener…”
  STARTED=`${GREP} -c “HTTP Listener started” ${LOG_FILE}`
  if [ ${STARTED} -eq “0” ]; then
    _error “An HTTP Listener has not reported as started in the log file ${LOG_FILE}”
  else
    saybold “An HTTP Listener is reported as started in the log file ${LOG_FILE}”
  fi
}

check_html(){
  # These checks need error handling, but you get the general idea.
  say “Checking that localhost:${HTTP_PORT} is serving Jenkins pages…”
  TEMP_WGETDIR=tempwgetdir$$
  mkdir ${TEMP_WGETDIR}
  cd ${TEMP_WGETDIR}
  ${WGET} -q http://localhost:${HTTP_PORT}
  GOT_HTML=`${GREP} -c Dashboard index.html`
  cd ${JENKINS_HOME}
  rm -rf ${TEMP_WGETDIR}
  if [ ${GOT_HTML} -eq “0” ]; then
    _error “Unable to get an HTML page from the Server.”
  fi
  saybold “Recieved valid HTML from the server, all looks ok.”
}

check_process(){
  check_port_open
  check_log
  check_html
  say “A Jenkins instance is listening on port ${HTTP_PORT} for project ${PROJECT}.”
  say “The process is logging debug info to the log file: ${LOG_FILE}”
}

stop_proc(){
  check_port_open
  saybold “Looking for the Process ID attached to port ${HTTP_PORT}”
  PID=`${LSOF} -w -n -i tcp:${HTTP_PORT} | ${GREP} -v COMMAND | ${AWK} {‘print $2’}`
  if [ “${PID}” == “” ]; then
    saybold “Unable to detect the Process ID that is listening on port ${HTTP_PORT}!”
    PID=`${FUSER} ${LOG_FILE}`
    if [ “${PID}” == “” ]; then
      _error “Unable to find the PID that has the log file open too!”
    else
      say “Ok, found PID ${PID}”
    fi
  else
    saybold “Found a PID of $PID, killing it now…”
  fi
  kill -9 ${PID}
  say “Waiting ${WAIT_TIME} seconds for the process to die…”
  sleep ${WAIT_TIME}
  saybold “Done, checking port is closed…”
  check_port_closed
  saybold “All done.”
}

start(){
  check_folders
  check_files
  check_port_closed
  start_process
  start_process
  sleep ${START_WAIT_TIME}
  check_process
}

restart(){
  stop_proc
  start
}

#################################################################################
### Script Start ################################################################
#################################################################################

case “$1” in
start)
start
;;
stop)
stop_proc
;;
restart)
restart
;;
check)
check_process
;;
*)
echo “Usage: $0 {start|stop|restart|check}”
esac
# Exit cleanly
_error “0”