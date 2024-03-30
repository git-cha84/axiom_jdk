#!/bin/bash
clear
deadlock_message="DETECTED_DEADLOCK"

check_and_install_libraries() {
  local libraries=("$@")
  
  for library in "${libraries[@]}"; do
    dpkg -s "$library" &> /dev/null
    if [ $? -eq 0 ]; then
      continue
    else
    
      echo "Install library $library"
      sudo apt update
      if [ ! $? -eq 0 ]; then
       echo "error command: sudo apt update"
       exit 1
      fi
      
      sudo ldconfig
      
      sudo apt install -y "$library"
      if [ ! $? -eq 0 ]; then
       echo "error install library $library"
       exit 2
      fi
      
      sudo ldconfig
    fi
  done
}


check_and_install_libraries g++ gdb

g++ deadlock.cpp -o deadlock -std=c++14 -pthread -O0 -ggdb

if [ ! $? -eq 0 ]; then
  echo "Compile error"
  exit 3
fi


key=""
rand=$((RANDOM % 2))
if [ $rand -eq 0 ]; then
 key="--d" 
fi

echo "RUN PROGRAM WITH KEY: $key"


./deadlock $key &
pid=$!
while true; do

    if ! ps -p $pid > /dev/null; then
      echo "TEST PASSED: program was finished and in runtime not detected DEADLOCK "
      rm deadlock
      exit 0
    fi

    sudo gdb -p $pid  -ex="source -v ./deadlock.py" -ex="found_blocked_threads" -ex="detach" -ex="quit"  2>/dev/null | grep -q $deadlock_message
    if [  $? -eq 0 ]; then
      echo "TEST FAILED: detected deadlock "
      kill  $pid
      rm deadlock
      exit 0
    fi
    
    sleep 1
done
