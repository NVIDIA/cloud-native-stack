#!/bin/bash
set -a
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

if [[ -z "${CNS_SUDO_PASSWORD:-}" && -r hosts ]]; then
	CNS_SUDO_PASSWORD=$(awk '
		/^[[:space:]]*localhost[[:space:]]/ {
			for (i = 1; i <= NF; i++) {
				if ($i ~ /^ansible_sudo_pass=/) {
					sub(/^ansible_sudo_pass=/, "", $i)
					gsub(/^'\''|'\''$/, "", $i)
					gsub(/^"|"$/, "", $i)
					print $i
					exit
				}
			}
		}
	' hosts)
fi
export -n CNS_SUDO_PASSWORD 2>/dev/null || true

cns_sudo() {
	if sudo -n true 2>/dev/null; then
		sudo "$@"
	elif [[ -n "${CNS_SUDO_PASSWORD:-}" ]]; then
		printf '%s\n' "$CNS_SUDO_PASSWORD" | sudo -S -p '' "$@"
	elif [[ -t 0 ]]; then
		sudo "$@"
	else
		return 1
	fi
}

detect_cloud_env() {
	id=""
	manufacturer=""
	if command -v dmidecode >/dev/null 2>&1; then
		id=$(cns_sudo dmidecode --string system-uuid 2>/dev/null | awk -F'-' '{print $1}' | cut -c -3)
		manufacturer=$(cns_sudo dmidecode -s system-manufacturer 2>/dev/null | grep -E -i "microsoft corporation|Google" || true)
	fi
}

if [ -z $1 ]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install cc        : Install NVIDIA Cloud Native Stack with Confidential Computing\n                               install launchpad : Install NVIDIA Cloud Native Stack on NVIDIA LaunchPad\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n"
	echo
	exit 1
elif [[ $1 == "help" || $1 == "-h" || $1 == "--help" || $1 == "usage" ]]; then
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install cc        : Install NVIDIA Cloud Native Stack with Confidential Computing\n                               install launchpad : Install NVIDIA Cloud Native Stack on NVIDIA LaunchPad\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n"
    echo
    exit 1
fi

cns_sudo true > /dev/null

# Bootstrap passwordless sudo for the invoking user on Ubuntu 26.04.
# Reason: ansible runs over `connection: local` with no controlling TTY, so any
# `become: true` task times out (12s) waiting for a sudo password prompt that
# can't be answered. The `cns_sudo true` above warmed the credential cache for THIS
# shell, but the cached cred doesn't propagate to the ansible-spawned process
# tree. Install /etc/sudoers.d/<user> NOPASSWD entry once so subsequent ansible
# become tasks work without prompting. Gated on Ubuntu 26.04.
#
# Scope: this only touches the box running setup.sh (i.e. the LOCAL host when
# `connection: local` is used). For REMOTE inventory targets, the equivalent
# bootstrap runs as an ansible task at the top of cns-installation.yaml using
# `become: true` + ansible_sudo_pass from the inventory line. So both modes
# are covered without any inventory parsing here.
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "26.04" ]]; then
    if ! cns_sudo grep -qE "^${USER}\s+.*NOPASSWD" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
      SUDOERS_FILE="/etc/sudoers.d/${USER}"
      SUDOERS_TMP=$(mktemp)
      echo "Ubuntu 26.04: bootstrapping passwordless sudo for ${USER} -> ${SUDOERS_FILE}"
      echo "${USER} ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_TMP"
      cns_sudo install -m 0440 "$SUDOERS_TMP" "$SUDOERS_FILE"
      rm -f "$SUDOERS_TMP"
      if ! cns_sudo visudo -cf "$SUDOERS_FILE" > /dev/null; then
        echo "ERROR: sudoers entry $SUDOERS_FILE failed syntax check. Removing."
        cns_sudo rm -f "$SUDOERS_FILE"
        exit 1
      fi
    fi
  fi
fi

existing_confidential_computing=""
if [[ -r cns_values.yaml ]]; then
	existing_confidential_computing=$(awk -F': *' '/^confidential_computing:/ {print $2; exit}' cns_values.yaml | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
fi

version=$(cat cns_version.yaml | awk -F':' '{print $2}' | head -n1 | tr -d ' ' | tr -d '\n\r')
cp cns_values_$version.yaml cns_values.yaml
selected_confidential_computing=$(awk -F': *' '/^confidential_computing:/ {print $2; exit}' cns_values.yaml | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
if [[ "$1" == "uninstall" && ( "$existing_confidential_computing" == "yes" || "$existing_confidential_computing" == "true" ) ]]; then
	sed -i 's/^confidential_computing:.*/confidential_computing: yes/' cns_values.yaml
	echo "Preserving confidential_computing: yes for uninstall cleanup."
fi
#sed -i "1s/^/cns_version: $version\n/" cns_values.yaml

if [[ "$1" == "install" && "${2:-}" != "cc" && "$selected_confidential_computing" != "yes" && "$selected_confidential_computing" != "true" && -r /etc/os-release ]]; then
	. /etc/os-release
	if [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "26.04" ]]; then
		echo "ERROR: Standard CNS installation is not supported on Ubuntu 26.04." >&2
		echo "CNS supports Ubuntu 26.04 only for Confidential Computing." >&2
		echo "Run: bash setup.sh install cc" >&2
		echo "Use Ubuntu 24.04 for the standard GPU Operator installation path." >&2
		exit 2
	fi
fi

# Ansible Install

ansible_install() {
  os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
  if ! command -v python >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1
  then
    if [[ $os == "ubuntu" ]]; then
	  cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 >/dev/null && cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get install python3 python3-pip python3-venv sshpass -y 2>&1 >/dev/null
    elif [ $os == '"rhel"' ]; then
	      cns_sudo yum install python39 python39-pip -y 2>&1 >/dev/null
    fi
  else
    pversion=$(python3 --version | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
	p2version=$(python --version 2>&1 | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
    if [[ $pversion < 3.8 || $pversion == 3.8 || $p2version == 3.8 || $p2version < 3.8 ]]; then
        if [[ $os == "ubuntu" ]]; then
		os_version=$(cat /etc/os-release  | grep -iw 'VERSION_ID' | awk -F'=' '{print $2}')
            if [[ $os_version == '"20.04"' ]]; then
	                cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 >/dev/null && cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get install python3.9 python3.9-venv python3-pip sshpass -y 2>&1 >/dev/null
	                cns_sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
	                cns_sudo ln -sf /usr/bin/python3.9 /usr/bin/python
					cns_sudo ln -sf /usr/lib/python3/dist-packages/apt_pkg.cpython-* /usr/lib/python3/dist-packages/apt_pkg.so
					cns_sudo ln -sf /usr/lib/python3/dist-packages/apt_inst.cpython-* /usr/lib/python3/dist-packages/apt_inst.so
			fi
        elif [ $os == '"rhel"' ]; then
	            cns_sudo yum install python39 python3-pip sshpass -y 2>&1 >/dev/null
	            cns_sudo ln -sf /usr/bin/python3.9 /usr/bin/python3
	            cns_sudo ln -sf /usr/bin/python3.9 /usr/bin/python
        fi
    fi
  fi

if [[ $os == "ubuntu" ]]; then
	    cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 >/dev/null && cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get install python3-pip python3-venv sshpass -y 2>&1 >/dev/null
elif [ $os == '"rhel"' ]; then
	    cns_sudo yum install python39-pip sshpass -y 2>&1 >/dev/null
fi

  version_le() {
          [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]
  }

  ansible_venv="$HOME/.cns-ansible-venv"
  uname=$(uname -r | awk -F'-' '{print $NF}')
  if [[ $uname == 'tegra' ]]; then
          ansible_package="ansible"
   else
         pversion=$(python3 --version | awk '{print $2}' | awk -F'.' '{print $1"."$2}')
         if version_le "$pversion" "3.10"; then
                 ansible_package="ansible==8.7.0"
         else
                 ansible_package="ansible==12.3.0"
        fi
  fi
  python3 -m venv "$ansible_venv"
  "$ansible_venv/bin/python" -m pip install --upgrade pip 2>&1 >/dev/null
  "$ansible_venv/bin/python" -m pip install "$ansible_package" 2>&1 >/dev/null

  export PATH=$ansible_venv/bin:$PATH:$HOME/.local/bin
  if [[ $os == "ubuntu" || $os == '"rhel"' ]]; then
          if ! grep -qxF 'export PATH=$HOME/.cns-ansible-venv/bin:$PATH:$HOME/.local/bin' ~/.bashrc; then
                  echo 'export PATH=$HOME/.cns-ansible-venv/bin:$PATH:$HOME/.local/bin' >> ~/.bashrc
          fi
  fi
  ansible-galaxy collection install community.general ansible.posix --force 2>&1 >/dev/null

}

# Prechecks
prerequisites() {
os=$(uname -o)
if [[ $os == 'GNU/Linux' ]]; then
os=$(cat /etc/os-release | grep -iw ID | awk -F'=' '{print $2}')
      if [[ $os == "ubuntu" ]]; then
	    cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get update 2>&1 >/dev/null && cns_sudo env DEBIAN_FRONTEND=noninteractive apt-get install curl -y 2>&1 >/dev/null
      elif [ $os == '"rhel"' ]; then
	        cns_sudo subscription-manager release --set 8.10
	    cns_sudo yum install curl -y 2>&1 >/dev/null
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

prerequisites
ansible_install

if [ $1 == "install" ]; then
        echo
        if [[ $2 == 'cc' ]]; then
                ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cns_values.yaml regexp='confidential_computing: no' line='confidential_computing: yes'"
                ansible -c local -i localhost, all -m lineinfile -a "path={{lookup('pipe', 'pwd')}}/cns_values_"$version".yaml regexp='confidential_computing: no' line='confidential_computing: yes'"
                # Vendor-aware + BMC-aware BIOS step:
                #   - Intel TDX  -> cns_cc_bios.yaml has no Intel attributes; BIOS must be set manually. Skip.
                #   - AMD SNP w/ BMC creds -> run cns_cc_bios.yaml to configure BIOS via Redfish.
                #   - AMD SNP w/o BMC creds (bmc_ip empty in cns_values.yaml) -> skip; BIOS must be set manually.
                cpu_vendor=$(grep -m1 vendor_id /proc/cpuinfo 2>/dev/null | awk '{print $3}')
                bmc_ip=$(awk -F': *' '/^bmc_ip:/ {gsub(/"|'\''| /,"",$2); print $2}' cns_values.yaml)
                if [[ "$cpu_vendor" == "GenuineIntel" ]]; then
                        echo "Intel CPU detected ($cpu_vendor) -> skipping cns_cc_bios.yaml (TDX BIOS must be set manually)."
                elif [[ -z "$bmc_ip" ]]; then
                        echo "AMD CPU detected but bmc_ip is not set in cns_values.yaml -> skipping cns_cc_bios.yaml. BIOS must be configured manually."
                else
                        ansible-playbook -c local -i localhost, cns_cc_bios.yaml
                fi
                ansible-playbook -i hosts cns-installation.yaml
        elif [[ $2 == 'launchpad' ]]; then
                ansible-playbook -i hosts cns-installation.yaml
	      elif [ -z $2 ]; then
			echo "Installing NVIDIA Cloud Native Stack Version $version"
			detect_cloud_env
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
	detect_cloud_env
	if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		sed -i 's/- hosts: master/- hosts: all/g' *.yaml
		ansible-playbook -c local -i localhost, cns-upgrade.yaml
	else
     		ansible-playbook -i hosts cns-upgrade.yaml
	fi
elif [ $1 == "uninstall" ]; then
	echo
	echo "Unstalling NVIDIA Cloud Native Stack"
	detect_cloud_env
	if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		sed -i 's/- hosts: master/- hosts: all/g' *.yaml
		ansible-playbook -c local -i localhost, cns-uninstall.yaml
	else
		ansible-playbook -i hosts cns-uninstall.yaml
	fi
elif [ $1 == "validate" ]; then
	echo
	echo "Validating NVIDIA Cloud Native Stack"
	detect_cloud_env
	if [[ $id == 'ec2' || $manufacturer == 'Microsoft Corporation' || $manufacturer == 'Google' ]]; then
		sed -i 's/- hosts: master/- hosts: all/g' *.yaml
		ansible-playbook -c local -i localhost, cns-validation.yaml
	else
        	ansible-playbook -i hosts cns-validation.yaml
	fi
else
	echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      -h, --help, usage    : Show this help message and exit\n      install              : Install NVIDIA Cloud Native Stack\n                             Sub Options:\n                               install cc        : Install NVIDIA Cloud Native Stack with Confidential Computing\n                               install launchpad : Install NVIDIA Cloud Native Stack on NVIDIA LaunchPad\n \n      validate             : Validate NVIDIA Cloud Native Stack\n      upgrade              : Upgrade NVIDIA Cloud Native Stack\n      uninstall            : Uninstall NVIDIA Cloud Native Stack\n"
        echo
        exit 1
fi
