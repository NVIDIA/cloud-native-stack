#! /usr/bin/python3

import sys,os,json,requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

# Input file with read line by line
file =  sys.argv[1]
f = open(file,'r')
lines = f.readlines()
# Itterate the each host to get the RedFish Details
for item in lines:
    if item == '[master]\n' or item == '[nodes]\n':
    # Split based on ":" from file
        print(' ')
    else:
        bmc = item.strip().split(' ')
        if len(bmc) > 6:
            host = bmc[6]
            user = bmc[7]
            pas = bmc[8]
            host1 = host.strip().split('=')
            user1 = user.strip().split('=')
            pas1 = pas.strip().split('=')
            print('\n' + '*' * 70)
          # method to validate whether the server is valid for RedFish API
            try:
              url = "https://{}/redfish/v1/".format(host1[1])
              requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
              response = requests.get(url, verify=False,timeout=3)
              # method to get valid RedFish Server details with help of res function
              try:
                  oe = response.json()['Oem']
                  #Itterate the OEM Patners to get the server details
                  for item in oe:
                      if item == 'Supermicro':
                          cc =  "https://{}/redfish/v1/Systems/1/Bios".format(host1[1])
                          requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
                          output = requests.get(cc,verify=False,auth=(user1[1], pas1[1]))
                          sev_snp = output.json()['Attributes']['SEV-SNPSupport#01A7']
                          smee = output.json()['Attributes']['SMEE#003E']
                          iommu = output.json()['Attributes']['IOMMU#0196']
                          sev_asid = output.json()['Attributes']['SEV-ESASIDSpaceLimit#700C']
                          snp_memory = output.json()['Attributes']['SNPMemory(RMPTable)Coverage#003C']
                          print("SEV SNP Support: {}".format(sev_snp))
                          print("SMEE Status: {}".format(smee))
                          print("IOMMU Status: {}".format(iommu))
                          print("SEV-ES ASID Space Limit: {}".format(sev_asid))
                          print("SNP Memory Coverage: {}".format(snp_memory))
                          print('*' * 70)
                          if sev_snp == 'Enabled' and smee == 'Enabled' and iommu == 'Enabled' and snp_memory == 'Enabled' and sev_asid == 100:
                              print("BIOS configured for Cloud Computing")
                          else:
                              print("BIOS not configured for Cloud Computing")
                      elif item == 'Ami':
                          cc =  "https://{}/redfish/v1/Systems/Self/Bios".format(host1[1])
                          requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
                          output = requests.get(cc,verify=False,auth=(user1[1], pas1[1]))
                          sev_asid_count = output.json()['Attributes']['CbsCmnCpuSevAsidCount']
                          sev_asid_limit = output.json()['Attributes']['CbsCmnCpuSevAsidSpaceCtrl']
                          sev_asid_space = output.json()['Attributes']['CbsCmnCpuSevAsidSpaceLimit']
                          snp_memory = output.json()['Attributes']['CbsDbgCpuSnpMemCover']
                          smee = output.json()['Attributes']['CbsCmnCpuSmee']
                          snp_support = output.json()['Attributes']['CbsSevSnpSupport']
                          print("SEV SNP Support: {}".format(snp_support))
                          print("SEV ASID Count: {}".format(sev_asid_count))
                          print("SEV ASID Space Limit Control: {}".format(sev_asid_limit))
                          print("SEV-ES ASID Space Limit: {}".format(sev_asid_space))
                          print("SNP Memory Coverage: {}".format(snp_memory))
                          print("SMEE Status: {}".format(smee))
                          print(" ")
                          print('*' * 70)
                          if snp_support == 'CbsSevSnpSupportEnable' and smee == 'CbsCmnCpuSmeeEnabled' and snp_memory == 'CbsDbgCpuSnpMemCoverEnabled' and sev_asid_limit == 'CbsCmnCpuSevAsidSpaceCtrlManual' and sev_asid_count == 'CbsCmnCpuSevAsidCount509ASIDs' and sev_asid_space == 100:
                              print("BIOS configured for Cloud Computing")
                          else:
                              print("BIOS not configured for Cloud Computing")
                      else:
                          print('Not a valid system, it should be either ASRockRack system or SuperMicro System')
              except Exception as e:
                  if 'Oem' in str(e):
                      atosurl = "https://{}/redfish/v1".format(host)
                      atos = requests.get(atosurl,verify=False)
                      print('Atos Server {} UUI is: '.format(host) + atos.json()['UUID'])
            except:
              print('{} Server is not for RedFish API'.format(host))
        else:
             print("Please update BMC IP, Username and Password details in hosts file like \n'localhost ansible_ssh_user=nvidia ansible_ssh_pass=nvidia ansible_sudo_pass=nvidia ansible_ssh_common_args='-o StrictHostKeyChecking=no' bmc_ip=<bmc-IP> bmc_username=root bmc_password=nvidia123'")