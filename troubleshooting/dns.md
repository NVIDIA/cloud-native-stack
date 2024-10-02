# DNS troubleshooting

## DNS resolution for pods

### Driver Container failed to access archive.ubuntu.com

#### Issue:

Driver Container logs display the following error messages:
![driver container logs](driver-container-logs.png)


#### Troubleshooting:

follow the steps located here: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/ to troubleshoot DNS pod resolution.

To install the dnsutils pod, launch the command:
```
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
```

In a working CNS deployment, you should have an output similar to below:

```
nvidia@ipp1-1394:~$ kubectl exec -i -t dnsutils -- nslookup archive.ubuntu.com
Server:		10.96.0.10
Address:	10.96.0.10#53

Non-authoritative answer:
Name:	archive.ubuntu.com
Address: 91.189.91.82
Name:	archive.ubuntu.com
Address: 185.125.190.82
Name:	archive.ubuntu.com
Address: 185.125.190.83
Name:	archive.ubuntu.com
Address: 185.125.190.81
Name:	archive.ubuntu.com
Address: 91.189.91.81
Name:	archive.ubuntu.com
Address: 91.189.91.83
Name:	archive.ubuntu.com
Address: 2620:2d:4002:1::103
Name:	archive.ubuntu.com
Address: 2620:2d:4000:1::101
Name:	archive.ubuntu.com
Address: 2620:2d:4002:1::102
Name:	archive.ubuntu.com
Address: 2620:2d:4002:1::101
Name:	archive.ubuntu.com
Address: 2620:2d:4000:1::103
Name:	archive.ubuntu.com
Address: 2620:2d:4000:1::102
```

Note that Name must be exactly 'archive.ubuntu.com':

***Name:	archive.ubuntu.com***


If you get a different output, it is recommended to fix the root cause (check with the team in charge of the DNS server. They may have created an entry for the archive.ubuntu.com and if this is the case, they must remove it).

