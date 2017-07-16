# Dynamic Provisioning of Kubernetes HostPath Volumes
## TL;DR
```bash
# install dynamic hostpath provisioner
kubectl create -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/rbac.yaml
kubectl create -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/deployment.yaml
kubectl create -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/storageclass.yaml

# create a test-pvc and a pod writign to it
kubectl create -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/test-claim.yaml
kubectl create -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/test-pod.yaml

# expect a file to exist on your host
$ ls -la /var/kubernetes/default-hostpath-test-claim-pvc-*/

kubectl delete pod hostpath-test-pod
kubectl delete pvc hostpath-test-claim

# expect the file and folder to be removed from your host
$ ls -la /var/kubernetes/default/hostpath-test-claim/
```

# The Do-it-your-self single-node Cluster
Kubernetes is a Cloud-Cluster Orchestration system and as such is 100% geard towards running a cluster on multiple computational nodes.

In order to allow Storage to be shared between those nodes (be it VMs or physical computers), kubernetes highly recommends using a storage subsystem that mount volumes on any of the available nodes. For do-it-your-self clusters this usually means setting up an NFS-Server backing all containers' volumes.

I wanted to have Kubernetes on my single VM up on netcup to orchestrate my hand full of services. I do not plan nor do I need multiple nodes, for me Kubernetes is just a nice way to manage the services that would otherwise run with simple systemd units.

In this simple scenario I do not need NFS or another clever Storage-Provider. All I want is hostPath backed volumes – easy to manage, easy to inspect, easy to backup and no protocol or network overhead on my small VM.

# Dynamic Provisioning
In order for dynamic provision, the process of allocating and binding a suitable Volume to a PersistentVolumeClaim, to happen, a Workload (usually a single Pod) needs to watch the Kubernetes API for new Claims, create Volumes for them and Bind the Volume to the Claim. Similar the same Workload is responsible to remove unneeded Volmes when the Claim goes away and the RetainPolicy does not tell otherwise.

For GoogleComputeEngine, Amazon AWS and even for Minikube there are such Provisioners that know how to handle the creation of GCE-Disks, AWS-Disks or HostPaths for Minikube.

# The Dynamic HostPath Provisioner
This is a small Modifikation to the Example given in the [kubernetes-incubator](https://github.com/kubernetes-incubator/external-storage/tree/master/docs/demo/hostpath-provisioner)-Project on how one could implement such a VolumeProvider. It adds the ability to choose a Target-Directory outside of `/tmp` on the host-system and an option to reain the Directories when the Claim goes away (by setting `PV_RECLAIM_POLICY` in the `deployment.yaml`).

It also improves upon the manifest-files by adding RBAC (RoleBasedAccessControl)-Configuration and a Deployment-Object.

Finally it documents why and how Kubernetes will not autoprovision hostPath VolumeClaums without a Provisioner like this – something that was not clear to me when reading the Docs (they sound like dynamic Provisioning should magically happen when you define a StorageClass. Well, it doesn't.)

So now that you read all this, you can scroll up to the [TL;DR](#tl-dr) section and install the Provisioner. Good Luck!
