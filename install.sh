#!/bin/sh
#
# install.sh : Silly attempt at avoiding autoconf to set up bashlib.
#

required_progs="awk bc cat cut date echo env grep printf sed tr"
bashlib_in=bashlib.in
bashlib_out=bashlib

for i in ${required_progs}; do
  if [ -x /bin/${i} ]; then
    eval "export FOUND_${i}=/bin/${i}"
  elif [ -x /usr/bin/${i} ]; then
    eval "export FOUND_${i}=/usr/bin/${i}"
  elif [ -x /usr/local/bin/${i} ]; then
    eval "export FOUND_${i}=/usr/local/bin/${i}"
  else
    echo "Can't seem to find /bin/${i}, /usr/bin/${i}, or /usr/local/bin/${i}."
    echo -n "Where is ${i} located on your system? "
    read FOUND_${i}
  fi
done

if [ -r ${bashlib_in} ]; then
cat <<BASHLIB >${bashlib_out}
#!/bin/bash

# \$Id$
# Author:     darren chamberlain <dlc@users.sourceforge.net>
# Co-Author:  Paul Bournival <paulb-ns@cajun.nu>
#
# bashlib is used by sourcing it at the beginning of scripts that
# needs its functionality (by using the `.' or `source' commands).

# Requires the following standard GNU utilities:
BASHLIB
  for i in ${required_progs}; do
    name=$(env | grep '^FOUND_' | grep $i | awk -F= '{print $1}' | sed -e 's/FOUND_//')
    value=$(env | grep '^FOUND_' | grep $i | awk -F= '{print $2}')
    echo "_${name}=${value}" >> ${bashlib_out}
  done
fi
cat ${bashlib_in} >> ${bashlib_out}
