#!/bin/bash
set -a
if [ -z $1 ]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      install           Install NVIDIA Cloud Native Stack\n      validate          Validate NVIDIA Cloud Native Stack x86 only\n      upgrade         Upgrade NVIDIA Cloud Native Stack\n      uninstall         Uninstall NVIDIA Cloud Native Stack"
	echo
	exit 1
fi

sudo ls > /dev/null

version=$(cat cnc_version.yaml | awk -F':' '{print $2}' | head -n1 | tr -d ' ' | tr -d '\n\r')
cp cnc_values_$version.yaml cnc_values.yaml
#sed -i "1s/^/cnc_version: $version\n/" cnc_values.yaml

# Ansible Install

ansible_install() {
  os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
  if ! hash sudo python 2>/dev/null
  then
    if ! hash sudo python3 2>/dev/null
    then
      if [[ $os == "ubuntu" ]]; then
        sudo apt update 2>&1 >/dev/null && sudo apt install python3 python3-pip sshpass -y 2>&1 >/dev/null
      elif [ $os == "rhel*" ]; then
        sudo yum install python3 python3-pip -y 2>&1 >/dev/null
      fi
	else
		if [[ $os == "ubuntu" ]]; then
			sudo apt update 2>&1 >/dev/null && sudo apt install python3-pip sshpass -y 2>&1 >/dev/null
		elif [ $os == "rhel*" ]; then
			sudo yum update 2>&1 >/dev/null && sudo yum install python3-pip sshpass -y 2>&1 >/dev/null
		fi
    fi
  fi
  pip3 install ansible 2>&1 >/dev/null
  export PATH=$PATH:$HOME/.local/bin
}
# Prechecks
prerequisites() {
url=$(cat cnc_values.yaml | grep k8s_apt_key | awk -F '//' '{print $2}' | awk -F'/' '{print $1}')
code=$(curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" http://$url)
echo "Checking this system has valid prerequisites"
echo
if [ $code == 200 ]; then
	echo "This system has an internet access"
	echo
elif [ $code != 200 ]; then
    echo "This system does not have a internet access"
	echo
    exit 1
fi
}

if ! hash sudo ansible 2>/dev/null
then
    prerequisites
	ansible_install
else
	os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
        if [[ $os == "ubuntu" ]]; then
		ansible_version=$(sudo pip3 list | grep ansible | awk '{print $2}' | head -n1 | awk -F'.' '{print $1}')
                if [[ $ansible_version -le 2 ]]; then
                	sudo apt purge ansible -y 2>&1 >/dev/null && sudo apt autoremove -y 2>&1 >/dev/null
	         		ansible_install
  		fi
	fi
	echo "Ansible Already Installed"
	echo
fi

if [ $1 == "install" ]; then
	echo
        echo "Installing NVIDIA Cloud Native Stack Version $version"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
			sed -ie 's/- hosts: master/- hosts: all/g' *.yaml
			nvidia_driver=$(ls /usr/src/ | grep nvidia | awk -F'-' '{print $1}')
			if [[ $nvidia_driver == 'nvidia' ]]; then
				ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cnc_values.yaml regexp='cnc_docker: no' line='cnc_docker: yes'"
			fi
				ansible-playbook -c local -i localhost, cnc-installation.yaml
		else
			ansible-playbook -i hosts cnc-installation.yaml
		fi
elif [ $1 == "upgrade" ]; then
		echo
		echo "Upgarding NVIDIA Cloud Native Stack"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		    sed -i 's/- hosts: master/- hosts: all/g' *.yaml
			ansible-playbook -c local -i localhost, cnc-upgrade.yaml
		else
     		ansible-playbook -i hosts cnc-upgrade.yaml
		fi
elif [ $1 == "uninstall" ]; then
		echo
		echo "Unstalling NVIDIA Cloud Native Stack"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		    sed -i 's/- hosts: master/- hosts: all/g' *.yaml
			ansible-playbook -c local -i localhost, cnc-uninstall.yaml
		else
     		ansible-playbook -i hosts cnc-uninstall.yaml
		fi
elif [ $1 == "validate" ]; then
		echo
		echo "Validating NVIDIA Cloud Native Stack"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		    sed -i 's/- hosts: master/- hosts: all/g' *.yaml
			ansible-playbook -c local -i localhost, cnc-validation.yaml
		else
        	ansible-playbook -i hosts cnc-validation.yaml
		fi
else
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      install     Install NVIDIA Cloud Native Stack\n      validate    Validate NVIDIA Cloud Native Stack\n      upgrade         Upgrade NVIDIA Cloud Native Stack\n      uninstall   Uninstall NVIDIA Cloud Native Stack"
        echo
        exit 1
	fi