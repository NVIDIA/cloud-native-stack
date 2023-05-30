#!/bin/bash
set -a
if [ -z $1 ]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
	echo
	exit 1
elif [[ $1 == "help" || $1 == "-h" || $1 == "--help" || $1 == "usage" ]]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
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
  if [ ! command -v python 2>/dev/null || ! command -v python3 2>/dev/null ]
  then
    if [[ $os == "ubuntu" ]]; then
  	  sudo apt update 2>&1 >/dev/null && sudo apt install python3 python3-pip sshpass -y 2>&1 >/dev/null
    elif [ $os == '"rhel"' ]; then
      sudo yum install python39 python39-pip -y 2>&1 >/dev/null
    fi
  else
    pversion=$(python3 --version | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
	p2version=$(python --version 2>&1 | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
    if [[ $pversion < 3.8 || $pversion == 3.8 || $p2version == 3.8 || $p2version < 3.8 ]]; then
        if [[ $os == "ubuntu" ]]; then
		os_version=$(cat /etc/os-release  | grep -iw 'VERSION_ID' | awk -F'=' '{print $2}')
            if [[ $os_version == '"20.04"' ]]; then
                sudo apt update 2>&1 >/dev/null && sudo apt install python3.9 python3-pip sshpass -y 2>&1 >/dev/null
                sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
                sudo ln -sf /usr/bin/python3.9 /usr/bin/python
				sudo ln -sf /usr/lib/python3/dist-packages/apt_pkg.cpython-* /usr/lib/python3/dist-packages/apt_pkg.so
				sudo ln -sf /usr/lib/python3/dist-packages/apt_inst.cpython-* /usr/lib/python3/dist-packages/apt_inst.so
			fi
        elif [ $os == '"rhel"' ]; then
            sudo yum update 2>&1 >/dev/null && sudo yum install python39 python3-pip sshpass -y 2>&1 >/dev/null
            sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
            sudo ln -sf /usr/bin/python3.9 /usr/bin/python
        fi
    fi
  fi

if [[ $os == "ubuntu" ]]; then
    sudo apt update 2>&1 >/dev/null && sudo apt install python3-pip sshpass -y 2>&1 >/dev/null
elif [ $os == '"rhel"' ]; then
    sudo yum update 2>&1 >/dev/null && sudo yum install python39-pip sshpass -y 2>&1 >/dev/null
fi

  uname=$(uname -r | awk -F'-' '{print $NF}')
  if [[ $uname == 'tegra' ]]; then
          pip3 install ansible 2>&1 >/dev/null
  else
         python3 -m pip install ansible==7.0.0 2>&1 >/dev/null
  fi
  if [[ $os == "ubuntu" || $os == '"rhel"' ]]; then
          echo PATH=$PATH:$HOME/.local/bin >> ~/.bashrc
          source ~/.bashrc
		  export PATH=$PATH:$HOME/.local/bin
  else
          export PATH=$PATH:$HOME/.local/bin
  fi
  ansible-galaxy collection install community.general ansible.posix --force 2>&1 >/dev/null

}

# Prechecks
prerequisites() {
os=$(uname -o)
if [[ $os == 'GNU/Linux' ]]; then
os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
      if [[ $os == "ubuntu" ]]; then
    	sudo apt update 2>&1 >/dev/null && sudo apt install curl -y 2>&1 >/dev/null
      elif [ $os == '"rhel"' ]; then
    	sudo yum update -y 2>&1 >/dev/null && sudo yum install curl -y 2>&1 >/dev/null
      fi
elif [[ $os == 'Darwin' ]]; then
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
	brew install curl
fi
url=$(cat cnc_values.yaml | grep k8s_apt_key | awk -F '//' '{print $2}' | awk -F'/' '{print $1}')
code=$(curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" http://$url)
echo "Checking this system has valid prerequisites"
echo
if [[ $code == 200 ]]; then
	echo "This system has an internet access"
	echo
elif [[ $code != 200 ]]; then
    echo "This system does not have a internet access"
	echo
    exit 1
fi
}

if ! command -v ansible 2>/dev/null
then
    prerequisites
    ansible_install
else
ostype=$(uname -o)
	if [[ $ostype == 'GNU/Linux' ]]; then
	os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
        if [[ $os == "ubuntu" ]]; then
		ansible_version=$(sudo pip3 list | grep ansible | awk '{print $2}' | head -n1 | awk -F'.' '{print $1}')
                if [[ $ansible_version -le 2 ]]; then
                	sudo apt purge ansible -y 2>&1 >/dev/null && sudo apt autoremove -y 2>&1 >/dev/null
	         		ansible_install
  				fi
		fi
	fi
	echo "Ansible Already Installed"
	echo
fi

gke_install() {
ostype=$(uname -o)
        if [[ $ostype == 'GNU/Linux' ]]; then
        arch=$(uname -m)
                if [[ $arch == 'x86_64' ]]; then
                        curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-linux-x86_64.tar.gz
                        tar -xf google-cloud-cli-425.0.0-linux-x86_64.tar.gz
                        source google-cloud-sdk/path.bash.inc
                elif [[ $arch == 'aarch64' ]]; then
                        curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-linux-arm.tar.gz
                        tar -xf google-cloud-cli-425.0.0-linux-arm.tar.gz
                        source google-cloud-sdk/path.bash.inc
                fi
        elif [[ $ostype == 'Darwin' ]]; then
                curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-darwin-x86_64.tar.gz
                tar -xf google-cloud-cli-425.0.0-darwin-x86_64.tar.gz
                source google-cloud-sdk/path.zsh.inc
        fi
export PATH=$PATH:./google-cloud-sdk/bin

google-cloud-sdk/install.sh --quiet >/dev/null 2>&1
echo
echo "Installing Google Cloud Components please wait"
echo
gcloud components install beta --quiet >/dev/null 2>&1
gcloud components install kubectl --quiet >/dev/null 2>&1
gcloud components update --quiet >/dev/null 2>&1
echo
echo "Google Cloud login"
echo
gcloud auth login --no-launch-browser
}

az_install() {
ostype=$(uname -o)
        if [[ $ostype == 'GNU/Linux' ]]; then
        os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
           if [[ $os == "ubuntu" ]]; then
                echo "Installing Azure CLI"
                echo
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg >/dev/null 2>&1
                sudo mkdir -p /etc/apt/keyrings
                curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
                sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
                AZ_REPO=$(lsb_release -cs)
                echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install azure-cli -y >/dev/null 2>&1
           elif [ $os == '"rhel"' ]; then
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm >/dev/null 2>&1
                sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm >/dev/null 2>&1
                echo -e "[azure-cli]
                name=Azure CLI
                baseurl=https://packages.microsoft.com/yumrepos/azure-cli
                enabled=1
                gpgcheck=1
                gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
                sudo dnf install azure-cli -y >/dev/null 2>&1
           fi
        elif [[ $ostype == 'Darwin' ]]; then
                brew update && brew install azure-cli
        fi
az config set core.no_color=true
echo
az login --use-device-code
}

if [ $1 == "install" ]; then
	echo
		if [[ $2 == 'aks' ]]; then
			az_install
		fi
		if [[ $2 == 'gke' ]]; then
			gke_install
		fi
		if [[ $2 == 'eks' || $2 == 'gke' || $2 == 'aks' ]]; then
			ansible-playbook -c local -i localhost, csp_install.yaml 
		elif [ -z $2 ]; then
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
		if [[ $2 == 'eks' || $2 == 'gke' || $2 == 'aks' ]]; then
			ansible-playbook -c local -i localhost, csp_uninstall.yaml
		elif [ -z $2 ]; then
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
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
        echo
        exit 1
	fi