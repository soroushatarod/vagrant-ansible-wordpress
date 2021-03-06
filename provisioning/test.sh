#!/bin/bash
#
# Ansible role test shim.
#
# Usage: [OPTIONS] ./tests/test.sh
#   - distro: a supported Docker distro version (default = "centos7")
#   - playbook: a playbook in the tests directory (default = "test.yml")
#   - role_dir: the directory where the role exists (default = $PWD)
#   - cleanup: whether to remove the Docker container (default = true)
#   - container_id: the --name to set for the container (default = timestamp)
#   - test_idempotence: whether to test playbook's idempotence (default = true)
#
# If you place a requirements.yml file in tests/requirements.yml, the
# requirements listed inside that file will be installed via Ansible Galaxy
# prior to running tests.
#
# License: MIT

# Exit on any individual command failure.
set -e

# Pretty colors.
red='\033[0;31m'
green='\033[0;32m'
neutral='\033[0m'

timestamp=$(date +%s)

# Allow environment variables to override defaults.
distro=${distro:-"centos7"}
playbook=${playbook:-"test.yml"}
role_dir=${role_dir:-"$PWD/provisioning/"}
cleanup=${cleanup:-"true"}
container_id=${container_id:-$timestamp}
test_idempotence=${test_idempotence:-"true"}

## Set up vars for Docker setup.
# CentOS 7
if [ $distro = 'centos7' ]; then
  init="/usr/lib/systemd/systemd"
  opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# CentOS 6
elif [ $distro = 'centos6' ]; then
  init="/sbin/init"
  opts="--privileged"
# Ubuntu 18.04
elif [ $distro = 'ubuntu1804' ]; then
  init="/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# Ubuntu 16.04
elif [ $distro = 'ubuntu1604' ]; then
  init="/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# Ubuntu 14.04
elif [ $distro = 'ubuntu1404' ]; then
  init="/sbin/init"
  opts="--privileged --volume=/var/lib/docker"
# Ubuntu 12.04
elif [ $distro = 'ubuntu1204' ]; then
  init="/sbin/init"
  opts="--privileged --volume=/var/lib/docker"
# Debian 9
elif [ $distro = 'debian9' ]; then
  init="/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# Debian 8
elif [ $distro = 'debian8' ]; then
  init="/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# Fedora 24
elif [ $distro = 'fedora24' ]; then
  init="/usr/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# Fedora 27
elif [ $distro = 'fedora27' ]; then
  init="/usr/lib/systemd/systemd"
  opts="--privileged --volume=/var/lib/docker --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
fi

# Run the container using the supplied OS.
#printf ${green}"Starting Docker container: geerlingguy/docker-$distro-ansible."${neutral}"\n"

printf ${green}"$role_dir"${neutral}"\n"
printf $role_dir
docker pull geerlingguy/docker-$distro-ansible:latest
docker run --detach --volume="$role_dir":/etc/ansible/roles/:rw --name $container_id $opts geerlingguy/docker-$distro-ansible:latest $init

printf "\n"



printf "\n"

# Test Ansible syntax.
printf ${green}"Checking Ansible playbook syntax."${neutral}
docker exec --tty $container_id env TERM=xterm ansible-playbook /etc/ansible/roles/$playbook --syntax-check

printf "\n"



# Remove the Docker container (if configured).
if [ "$cleanup" = true ]; then
  printf "Removing Docker container...\n"
  docker rm -f $container_id
fi