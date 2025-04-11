#!/bin/bash
set -a
if [ -z $1 ]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n                               install gke   : Install NVIDIA Cloud Native Stack with Confidential Computing\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
	echo
	exit 1
elif [[ $1 == "help" || $1 == "-h" || $1 == "--help" || $1 == "usage" ]]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n                               install cc   : Install NVIDIA Cloud Native Stack with Confidential Computing\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
    echo
    exit 1	 
fi

sudo ls > /dev/null

version=$(cat cns_version.yaml | awk -F':' '{print $2}' | head -n1 | tr -d ' ' | tr -d '\n\r')
cp cns_values_$version.yaml cns_values.yaml
#sed -i "1s/^/cns_version: $version\n/" cns_values.yaml

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
            sudo yum install python39 python3-pip sshpass -y 2>&1 >/dev/null
            sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
            sudo ln -sf /usr/bin/python3.9 /usr/bin/python
        fi
    fi
  fi

if [[ $os == "ubuntu" ]]; then
    sudo apt update 2>&1 >/dev/null && sudo apt install python3-pip sshpass -y 2>&1 >/dev/null
elif [ $os == '"rhel"' ]; then
    sudo yum install python39-pip sshpass -y 2>&1 >/dev/null
fi

  uname=$(uname -r | awk -F'-' '{print $NF}')
  if [[ $uname == 'tegra' ]]; then
          pip3 install ansible 2>&1 >/dev/null
   else
         pversion=$(python3 --version | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
         p2version=$(python --version 2>&1 | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
         if [[ $pversion < 3.10 || $pversion == 3.10 || $p2version == 3.10 || $p2version < 3.10  ]]; then
                 python3 -m pip install ansible==8.7.0 2>&1 >/dev/null
         elif [[ $pversion > 3.10 ]]; then
                 python3 -m pip install ansible==11.4.0 --break-system-packages 2>&1 >/dev/null
        fi
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
        sudo subscription-manager release --set 8.10
    	sudo yum install curl -y 2>&1 >/dev/null
      fi
elif [[ $os == 'Darwin' ]]; then
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
	brew install curl
fi
url=$(cat cns_values.yaml | grep k8s_apt_key | awk -F '//' '{print $2}' | awk -F'/' '{print $1}')
code=$(curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" https://$url)
echo "Checking this system has valid prerequisites"
echo
if [[ $code == 200 ]] || [[ $code == 302 ]]; then
	echo "This system has an internet access"
	echo
else
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

tf_install() {
ostype=$(uname -o)
if [[ $ostype == 'GNU/Linux' ]]; then
        arch=$(uname -m)
        if [[ $arch == 'x86_64' ]]; then
                curl -s -O https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip
                unzip terraform_1.5.3_linux_amd64.zip
        elif [[ $arch == 'aarch64' ]]; then
                curl -s -O https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_arm64.zip
                unzip terraform_1.5.3_linux_arm64.zip
        fi
        sudo mv terraform /usr/local/bin/
elif [[ $ostype == 'Darwin' ]]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
fi
}

gke_install() {
ostype=$(uname -o)
if [[ $ostype == 'GNU/Linux' ]]; then
arch=$(uname -m)
        if [[ $arch == 'x86_64' ]]; then
                curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-linux-x86_64.tar.gz
                tar -xf google-cloud-cli-425.0.0-linux-x86_64.tar.gz
        elif [[ $arch == 'aarch64' ]]; then
                curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-linux-arm.tar.gz
                tar -xf google-cloud-cli-425.0.0-linux-arm.tar.gz
        fi
        source google-cloud-sdk/path.bash.inc
        curl -s -O https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
        sudo mv jq-linux64 /usr/local/bin/jq
        chmod +x /usr/local/bin/jq
elif [[ $ostype == 'Darwin' ]]; then
        curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-425.0.0-darwin-x86_64.tar.gz
        tar -xf google-cloud-cli-425.0.0-darwin-x86_64.tar.gz
        source google-cloud-sdk/path.zsh.inc
        brew install helm jq kubectl --force
fi
export PATH=$PATH:./google-cloud-sdk/bin
google-cloud-sdk/install.sh --quiet >/dev/null 2>&1
echo
echo "Installing Google Cloud Components please wait"
echo
gcloud components install beta --quiet >/dev/null 2>&1
gcloud components install kubectl --quiet >/dev/null 2>&1
gcloud components install gke-gcloud-auth-plugin --quiet >/dev/null 2>&1
gcloud components update --quiet >/dev/null 2>&1
echo
echo "Google Cloud login"
echo
gcloud auth login --update-adc --no-launch-browser
#gcloud auth application-default login --no-launch-browser
}

az_install() {
ostype=$(uname -o)
if [[ $ostype == 'GNU/Linux' ]]; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
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
        arch=$(uname -m)
        if [[ $arch == 'x86_64' ]]; then
                wget -q https://github.com/Azure/kubelogin/releases/download/v0.0.31/kubelogin-linux-amd64.zip
                unzip kubelogin-linux-amd64.zip
                sudo mv bin/linux_amd64/kubelogin /usr/local/bin/
                curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl 
        elif [[ $arch == 'aarch64' ]]; then
                wget -q https://github.com/Azure/kubelogin/releases/download/v0.0.31/kubelogin-linux-arm64.zip
                unzip kubelogin-linux-arm64.zip
                sudo mv bin/linux_arm64/kubelogin /usr/local/bin/
                curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/arm64/kubectl
        fi
        curl -s -O https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
        sudo mv jq-linux64 /usr/local/bin/jq
        sudo cp kubectl /usr/local/bin/kubectl
        sudo chmod +x /usr/local/bin/jq /usr/local/bin/kubelogin /usr/local/bin/kubectl
elif [[ $ostype == 'Darwin' ]]; then
        brew update && brew install azure-cli
        brew install Azure/kubelogin/kubelogin
        brew install helm jq kubectl --force
        fi
az config set core.no_color=true
echo
az login --use-device-code
az aks install-cli
}

aws_install () {
ostype=$(uname -o)
if [[ $ostype == 'GNU/Linux' ]]; then
arch=$(uname -m)
        if [[ $arch == 'x86_64' ]]; then
                curl -s -O https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
                curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
                unzip -q awscli-exe-linux-x86_64.zip
        elif [[ $arch == 'aarch64' ]]; then
                curl -s -O https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip
                curl -LO https://dl.k8s.io/release/v1.26.0/bin/linux/arm64/kubectl
                unzip awscli-exe-linux-aarch64.zip
        fi
        curl -s -O https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
        sudo cp jq-linux64 /usr/local/bin/jq
        sudo cp kubectl /usr/local/bin/kubectl
        sudo chmod +x /usr/local/bin/kubectl /usr/local/bin/jq 
        sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
elif [[ $ostype == 'Darwin' ]]; then
        pip3 install awscli
        brew install helm jq kubectl --force
fi
mkdir -p $HOME/.aws/ && cp -r $PWD/files/aws_credentials $HOME/.aws/credentials
}

if [ $1 == "install" ]; then
        echo
	if [[ $2 == 'aks' ]]; then
		az_install
                tf_install
                azure_account_name=$(cat cns_values_$version.yaml | grep azure_account_name | awk -F': ' '{print $2}')
                cluster_name=$(cat cns_values_$version.yaml | grep aks_cluster_name | awk -F': ' '{print $2}')
                location=$(cat cns_values_$version.yaml | grep aks_cluster_location | awk -F': ' '{print $2}')
                azure_object_id=$(cat cns_values_$version.yaml | grep azure_object_id | awk -F': ' '{print $2}')
		rm -rf nvidia-terraform-modules
                git clone https://github.com/NVIDIA/nvidia-terraform-modules.git
                cd nvidia-terraform-modules/aks
		git reset --hard 223e39fcf55f39ad714895e0a86481275fdd6623
		echo "cluster_name           = \"$cluster_name\"" >> terraform.tfvars
		echo "location  = $location" >> terraform.tfvars
		echo "admin_group_object_ids = $azure_object_id" >> terraform.tfvars
                terraform init
                terraform apply --auto-approve
                #az aks get-credentials --resource-group $cluster_name-rg --name $cluster_name
	elif [[ $2 == 'gke' ]]; then
		gke_install
                tf_install
                region=$(cat cns_values_$version.yaml | grep gke_region | awk -F': ' '{print $2}')
                node_zone=$(cat cns_values_$version.yaml | grep gke_node_zones | awk -F': ' '{print $2}')
                cluster_name=$(cat cns_values_$version.yaml | grep gke_cluster_name | awk -F': ' '{print $2}')
                gke_project_id=$(cat cns_values_$version.yaml | grep gke_project_id | awk -F': ' '{print $2}')
		rm -rf nvidia-terraform-modules
                git clone https://github.com/NVIDIA/nvidia-terraform-modules.git
                cd nvidia-terraform-modules/gke
		git reset --hard 223e39fcf55f39ad714895e0a86481275fdd6623
		echo "cluster_name = \"$cluster_name\"" >> terraform.tfvars
		echo "project_id = \"$gke_project_id\"" >> terraform.tfvars
		echo "region     = \"$region\"" >> terraform.tfvars
		echo "node_zones =  $node_zone" >> terraform.tfvars
                sed -i '$a num_gpu_nodes = "1"' terraform.tfvars
		sed -i '$a gpu_min_node_count = "1"' terraform.tfvars
                gcloud config set project $gke_project_id
                terraform init
                terraform apply --auto-approve
                node_zone1=$(echo $node_zone | sed 's/\[//g;s/\]//g;s/\"//g')
                gcloud container clusters get-credentials $cluster_name --zone $node_zone1
        elif [[ $2 == 'eks' ]]; then
                tf_install
                aws_install
                region=$(cat cns_values_$version.yaml | grep aws_region | awk -F': ' '{print $2}')
                cluster_name=$(cat cns_values_$version.yaml | grep aws_cluster_name | awk -F': ' '{print $2}')
                instance_type=$(cat cns_values_$version.yaml | grep aws_gpu | awk -F': ' '{print $2}')
		rm -rf nvidia-terraform-modules
                git clone https://github.com/NVIDIA/nvidia-terraform-modules.git
                cd nvidia-terraform-modules/eks
		git reset --hard 223e39fcf55f39ad714895e0a86481275fdd6623
                aws configure set default.region $region
		echo "cluster_name = \"$cluster_name\"" >> terraform.tfvars
		echo "region  = \"$region\"" >> terraform.tfvars
                echo "gpu_instance_type = \"$instance_type\"" >> terraform.tfvars
                sed -i '$a min_gpu_nodes = "1"' terraform.tfvars
                sed -i '$a desired_count_gpu_nodes = "1"' terraform.tfvars
                terraform init
                terraform apply --auto-approve
                aws eks update-kubeconfig --name tf-$cluster_name --region $region
        elif [[ $2 == 'cc' ]]; then
                ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cns_values.yaml regexp='confidential_computing: no' line='confidential_computing: yes'"
                ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cns_values_"$version".yaml regexp='confidential_computing: no' line='confidential_computing: yes'"
                ansible-playbook -c local -i localhost, cns_cc_bios.yaml
                ansible-playbook -i hosts cns-installation.yaml
      	elif [ -z $2 ]; then
		echo "Installing NVIDIA Cloud Native Stack Version $version"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
			sed -ie 's/- hosts: master/- hosts: all/g' *.yaml
			nvidia_driver=$(ls /usr/src/ | grep nvidia | awk -F'-' '{print $1}')
			if [[ $nvidia_driver == 'nvidia' ]]; then
				ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cns_values.yaml regexp='cns_docker: no' line='cns_docker: yes'"
			fi
			ansible-playbook -c local -i localhost, cns-installation.yaml
			else
				ansible-playbook -i hosts cns-installation.yaml
			fi
		fi
elif [ $1 == "upgrade" ]; then
	echo
	echo "Upgarding NVIDIA Cloud Native Stack"
	id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
	manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
	if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		sed -i 's/- hosts: master/- hosts: all/g' *.yaml
		ansible-playbook -c local -i localhost, cns-upgrade.yaml
	else
     		ansible-playbook -i hosts cns-upgrade.yaml
	fi
elif [ $1 == "uninstall" ]; then
	if [[ $2 == 'eks'  ]]; then
		cd nvidia-terraform-modules/eks
                terraform destroy --auto-approve
                cd ../../
                rm -rf terraform_1.5.3_linux_* jq-linux64 kubectl aws awscli-exe-linux-*                
        elif [[ $2 == 'aks' ]]; then
                cd nvidia-terraform-modules/aks
                terraform destroy --auto-approve
                cd ../../
                rm -rf terraform_1.5.3_linux_amd64.zip jq-linux64 kubectl kubelogin-linux-*
        elif [[ $2 == 'gke' ]]; then
                cd nvidia-terraform-modules/gke
                terraform destroy --auto-approve
                cd ../../
                rm -rf terraform_1.5.3_linux_* jq-linux64 kubectl
	elif [ -z $2 ]; then
		echo
		echo "Unstalling NVIDIA Cloud Native Stack"
		id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
		if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
			sed -i 's/- hosts: master/- hosts: all/g' *.yaml
			ansible-playbook -c local -i localhost, cns-uninstall.yaml
		else
			ansible-playbook -i hosts cns-uninstall.yaml
		fi
	fi
elif [ $1 == "validate" ]; then
	echo
	echo "Validating NVIDIA Cloud Native Stack"
	id=$(sudo dmidecode --string system-uuid | awk -F'-' '{print $1}' | cut -c -3)
	manufacturer=$(sudo dmidecode -s system-manufacturer | egrep -i "microsoft corporation|Google")
	if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		sed -i 's/- hosts: master/- hosts: all/g' *.yaml
		ansible-playbook -c local -i localhost, cns-validation.yaml
	else
        	ansible-playbook -i hosts cns-validation.yaml
	fi	
else
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install gke   : Install NVIDIA Cloud Native Stack on Google GKE\n                               install eks   : Install NVIDIA Cloud Native Stack on Amazon EKS\n                               install aks   : Install NVIDIA Cloud Native Stack on Azure AKS\n                               install cc   : Install NVIDIA Cloud Native Stack with Confidential Computing\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n                             Sub Options:\n                               uninstall gke   : Uninstall NVIDIA Cloud Native Stack on Google GKE\n                               uninstall eks   : Uninstall NVIDIA Cloud Native Stack on Amazon EKS\n                               uninstall aks   : Uninstall NVIDIA Cloud Native Stack on Azure AKS\n"
        echo
        exit 1
fi