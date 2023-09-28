  echo "========================================================================================================================"
  echo "                               Build the Host Kernel for SNP                                                            "
  echo "========================================================================================================================"

  sudo apt update >/dev/null 2>&1
  sudo apt upgrade -y >/dev/null 2>&1
  sudo apt install -y ninja-build iasl nasm  flex bison openssl dkms autoconf zlib1g-dev python3-pip libncurses-dev libssl-dev libelf-dev libudev-dev libpci-dev libiberty-dev libtool libsdl-console libsdl-console-dev libpango1.0-dev libjpeg8-dev libpixman-1-dev libcairo2-dev  libgif-dev libglib2.0-dev >/dev/null 2>&1
  sudo pip3 install numpy flex bison >/dev/null 2>&1
  echo
  echo "========================================================================================================================"
  echo "Download the AMDSEV Pacakge"
  echo "========================================================================================================================"
  if [[ ! -d /shared ]]; then
          sudo mkdir /shared
          sudo chmod -R 777 /shared
  fi
  cd /shared
  git clone https://github.com/AMDESE/AMDSEV.git
  git clone https://github.com/NVIDIA/nvtrust.git
  cd AMDSEV
  git checkout sev-snp-devel
  sed -i '/run_cmd .\/scripts\/config --disable DEBUG_PREEMPT/a\                        run_cmd .\/scripts\/config --enable  CONFIG_CRYPTO_ECC\n                        run_cmd .\/scripts\/config --enable  CONFIG_CRYPTO_ECDH\n                        run_cmd .\/scripts\/config --enable  CONFIG_CRYPTO_ECDSA' common.sh
  sudo ln -sf /usr/bin/python3 /usr/bin/python
  ./build.sh --package
  cp /shared/nvtrust/infrastructure/linux/patches/*.patch /shared/AMDSEV
  echo
  echo "========================================================================================================================"
  echo "Modify the Kernel for SNP"
  echo "========================================================================================================================"
  echo
  pushd /shared/AMDSEV/linux/host
  patch -p1 -l < ../../iommu_pagefault.patch
  patch -p1 -l < ../../iommu_pagesize.patch
  popd
  ./build.sh --package
  echo
  echo "========================================================================================================================"
  echo "Install Host kernel"
  echo "========================================================================================================================"
  echo
  sudo cp kvm.conf /etc/modprobe.d/
  snp_file=$(ls -lrt /shared/AMDSEV/ |grep snp-release | grep -v tar.gz | tail -1f | awk '{print $NF}')
  echo $snp_file
  cd /shared/AMDSEV/$snp_file
  sudo ./install.sh
  echo
  echo "========================================================================================================================"
  echo "Enble IOMMU for Confidential Computing with Kata"
  echo
  cpu_name=$(lscpu | grep -i 'Model name' | awk -F' ' '{print $3}')
  if [[ $cpu_name == 'Intel(R)' ]]; then
          sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on modprobe.blacklist=nouveau"/g' /etc/default/grub
          sudo update-grub
  elif [[ $cpu_name == 'AMD' ]]; then
          sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on modprobe.blacklist=nouveau"/g' /etc/default/grub
          sudo update-grub
  fi
  echo
  echo "========================================================================================================================"
  echo "Reboot to load the SNP and Grub"
# sudo reboot