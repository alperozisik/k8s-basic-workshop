You can always check content of the [samples folder](../samples) to check the file contents.

In this lab, we will work with two higher-level entities in Kubernetes: ReplicaSets and Deployments.  
We will also see some use cases for labels and selectors.

# 1. Labels and Selectors
1. Connect to the master node with your user credentials. Make sure that there are no pods already running on the system (in your namespace)
2. Display the list of nodes in the cluster, including their labels. Notice that Kubernetes automatically applies some labels to the nodes (one label identifies master nodes, others identify the architecture, OS, hostname, etc)
    > 💡**Hint:** You already know how to display the nodes. You just need to add the `--show-labels` option.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get nodes --show-labels
    NAME STATUS ROLES AGE VERSION LABELS
    master-node Ready master 5h v1.11.2
    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-
    00-01,node-role.kubernetes.io/master=
    worker-01 Ready <none> 4h v1.11.2
    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-
    00-02
    worker-02 Ready <none> 4h v1.11.2
    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-
    00-03
    ```
    </details>
3. Display node information for your **second worker node** (hostname ending in -02). Use a label selector for this.
    > 💡**Hint:** The `-l` argument to kubectl get nodes will help

    > 💡**Hint:** The label for the hostname is `kubernetes.io/hostname`
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get nodes -l kubernetes.io/hostname=worker-01
    NAME STATUS ROLES AGE VERSION
    worker-01 Ready <none> 4h v1.11.2
    ```
    </details>
4. In a previous lab, you have created a simple pod definition file ( 01-pod.yaml ). Copy it to a new file ( 04-pod-nodeselector.yaml ). Edit the new file so that the pod will only run on the 10th node in the cluster (for example, if your nodes are named kube-cluster-xx, this pod should only run on nodes with the `hostname = kube-cluster-10` ).
    > 🗒️**Note:** No, this is not a typo - we are purposefully creating a selector that will never match, in order to see the results!
    > 💡**Hint:** You will need to add a nodeSelector under .spec . Under nodeSelector, you will need to add a key: value pair (where the key is the label name you want to match - in our case, kubernetes.io/hostname ).
    <details>
        <summary>Answer</summary>

    content of `04-pod-nodeselector.yml`:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx01
    spec:
     nodeSelector:
       kubernetes.io/hostname: kubernetes-00-04
     containers:
       - image: nginx
         name: nginx
    ```
    </details>
5. Create a pod based on this file. What happens? Is the pod created correctly?
    > 💡**Hint:** amazingly enough, the pod seems to be created correctly! However...
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 04-pod-nodeselector.yml
    pod/nginx01 created
    ```
    </details>
6. Look at the list of pods. Is the pod running?
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    nginx01 0/1 Pending 0 26s
    ```
    </details>
7. Get the pod details. What do you see? Why isn’t this pod running?
    > 🗒️**Note:** The pod does get created, but the scheduler is unable to place the pod on a worker node (there is no worker node matching the condition). So the pod will remain forever in a `Pending` state.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl describe pod nginx01
    Name: nginx01
    ...
    Events:
    Type Reason Age From Message
    ---- ------ --- ---- -------
    Warning FailedScheduling 5s (x14 over 40s) default-scheduler 0/3 nodes are available: 3 node(s) didn't match node selector.
    ```
    </details>
8. Edit the YAML file to specify a correct node (use -02 , your second worker node).
    <details>
        <summary>Answer</summary>

    content of `04-pod-nodeselector.yml`
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx01
    spec:
      nodeSelector:
        kubernetes.io/hostname: worker-02
      containers:
        - image: nginx
          name: nginx
    ```
    </details>
9. Delete the existing pod. Create a new one using the changed file.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete pod nginx01
    pod "nginx01" deleted
    ubuntu@master-node:~$ kubectl apply -f 04-pod-nodeselector.yml
    pod/nginx01 created
    ```
    </details>
10. Verify that the new pod is correctly scheduled, and is running on your second worker node.
    <details>
        <summary>Answer</summary>
    
    ```
    ubuntu@master-node:~$ kubectl get pod -o wide
    NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE
    nginx01 1/1 Running 0 44s 192.168.38.72 worker-02 <none>
    ```
    </details>
11. Delete the pod.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete pod nginx01
    pod "nginx01" deleted
    ```
    </details>

# 2. ReplicaSets
1. Create a YAML file ( 05-replicaset.yaml ) describing a simple ReplicaSet. The ReplicaSet will be named `web-replicaset-01`. It will run 5 instances of the nginx web server. The pods should be labeled with `app: multi- web`, and the ReplicaSet .spec.selector should match on this label.
    > 💡**Hint:** the YAML files are beginning to get a little bit more complicated. It is always easier to start from an example. You could take one from the official documentation (
https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#example ), use the one on the slides, or start from the one below:
    ```yaml
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
      name: <rs-name>
    spec:
      replicas: <x>
      selector:
        matchLabels:
          key: value
      template:
        metadata:
          name: pod-template
          labels:
            pod-key: pod-value
        spec:
          containers:
          - name: web
            image: nginx 
    ```
    <details>
        <summary>Answer</summary>

    content of `05-replicaset.yaml`:
    ```yaml
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
    name: web-replicaset-01
    spec:
    replicas: 5
    selector:
        matchLabels:
        app: multi-web
    template:
        metadata:
        name: pod-template
        labels:
            app: multi-web
        spec:
        containers:
        - name: web
            image: nginx
    ```
    </details>
2. Start the ReplicaSet on your cluster.
    > 💡**Hint:** If you get an error message that says `selector does not match template labels`, double-check that the .spec.selector actually matches the .spec.template.labels.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 05-replicaset.yaml
    replicaset.extensions/web-replicaset-01 created
    ```
    </details>
3. Check the number of pods on your cluster, and the host they are running on. You should see the 5 pods making up your ReplicaSet, and the fact that Kubernetes has tried to distribute them among the worker nodes.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get pod -o wide
    NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE
    web-replicaset-01-6zcrf 1/1 Running 0 55s 192.168.63.202 worker-01 <none>
    web-replicaset-01-ffp9h 1/1 Running 0 55s 192.168.38.75 worker-02 <none>
    web-replicaset-01-h22jh 1/1 Running 0 55s 192.168.63.203 worker-01 <none>
    web-replicaset-01-l8k4j 1/1 Running 0 55s 192.168.38.74 worker-02 <none>
    web-replicaset-01-zpt7r 1/1 Running 0 55s 192.168.63.204 worker-01 <none>
    ```
    </details>
4. In order to save resources, let’s scale the ReplicaSet down to two replicas. We could do this by using kubectl scale, but let’s stick to the declarative model. Edit the file, changing the number of replicas to 2, and reapply the file. Watch the running pods to see the result. You should see the extra pods being terminated.
    <details>
        <summary>Answer</summary>

    `05-replicaset.yaml` content:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: ReplicaSet
    metadata:
      name: web-replicaset-01
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: multi-web
      template:
        metadata:
          name: pod-template
          labels:
            app: multi-web
        spec:
          containers:
          - name: web
            image: nginx
    ```
    ```
    ubuntu@master-node:~$ kubectl apply -f 05-replicaset.yaml
    replicaset.extensions/web-replicaset-01 configured
    ubuntu@master-node:~$ kubectl get pod -o wide
    NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE
    web-replicaset-01-6zcrf 1/1 Running 0 5m 192.168.63.202 worker-01 <none>
    web-replicaset-01-ffp9h 0/1 Terminating 0 5m <none> worker-02 <none>
    web-replicaset-01-h22jh 0/1 Terminating 0 5m 192.168.63.203 worker-01 <none>
    web-replicaset-01-l8k4j 1/1 Running 0 5m 192.168.38.74 worker-02 <none>
    ubuntu@master-node:~$ kubectl get pod -o wide
    NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE
    web-replicaset-01-6zcrf 1/1 Running 0 5m 192.168.63.202 worker-01 <none>
    web-replicaset-01-l8k4j 1/1 Running 0 5m 192.168.38.74 worker-02 <none>
    ```
    </details>
5. Our application is getting more successful - we need more web server instances! Scale the
ReplicaSet up to 6 instances.
    <details>
        <summary>Answer</summary>

    update `05-replicaset.yaml` content:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: ReplicaSet
    metadata:
      name: web-replicaset-01
    spec:
      replicas: 6
      selector:
        matchLabels:
          app: multi-web
      template:
        metadata:
          name: pod-template
          labels:
            app: multi-web
        spec:
          containers:
          - name: web
            image: nginx
    ```
    ```shell
    ubuntu@master-node:~$ kubectl apply -f 05-replicaset.yaml
    replicaset.extensions/web-replicaset-01 configured
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-replicaset-01-6zcrf 1/1 Running 0 7m
    web-replicaset-01-fwqdv 0/1 ContainerCreating 0 3s
    web-replicaset-01-l8k4j 1/1 Running 0 7m
    web-replicaset-01-p5tzx 0/1 ContainerCreating 0 2s
    web-replicaset-01-w46tc 0/1 ContainerCreating 0 3s
    web-replicaset-01-x6zf6 0/1 ContainerCreating 0 3s
    ```
    </details>
6. Delete one of the pods? What happens?
    > 🗒️**Note:** You are beginning to see the *magic* of the declarative model - we have told Kubernetes to keep a certain desired state (*6 replicas*), and it will do its best to maintain that state. When a pod *disappears* (crashed, deleted, etc), a new one will immediately take its place.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete pod web-replicaset-01-w46tc
    pod "web-replicaset-01-w46tc" deleted

    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-replicaset-01-6gmds 0/1 ContainerCreating 0 2s
    web-replicaset-01-6zcrf 1/1 Running 0 8m
    web-replicaset-01-fwqdv 1/1 Running 0 54s
    web-replicaset-01-l8k4j 1/1 Running 0 8m
    web-replicaset-01-p5tzx 1/1 Running 0 53s
    web-replicaset-01-x6zf6 1/1 Running 0 54s
    ```
    </details>
7. Run the command below to delete the ReplicaSet.
    ```shell
    kubectl delete replicaset web-replicaset-01 --cascade=false
    ```
    > 🗒️**Note:** The default behaviour when deleting items is `cascading deletion` - deleting the ReplicaSet would also delete the corresponding pods. So make sure you specify the `-- cascade=false` option! Take a look at the list of running pods, and make sure that all the web server instances are still running.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete replicaset web-replicaset-01 --cascade=false
    replicaset.extensions "web-replicaset-01" deleted
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-replicaset-01-6gmds 1/1 Running 0 1m
    web-replicaset-01-6zcrf 1/1 Running 0 9m
    web-replicaset-01-fwqdv 1/1 Running 0 2m
    web-replicaset-01-l8k4j 1/1 Running 0 9m
    web-replicaset-01-p5tzx 1/1 Running 0 2m
    web-replicaset-01-x6zf6 1/1 Running 0 2m
    ```
    </details>
    </details>
8. Delete one of the pods (your choice which one). Does it get recreated?
    > 🗒️**Note:** no. The pods are no longer controlled by a higher-level entity (ReplicaSet), so there is nothing to recreate the dead/missing pod.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete pod web-replicaset-01-x6zf6
    pod "web-replicaset-01-x6zf6" deleted
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-replicaset-01-6gmds 1/1 Running 0 1m
    web-replicaset-01-6zcrf 1/1 Running 0 9m
    web-replicaset-01-fwqdv 1/1 Running 0 2m
    web-replicaset-01-l8k4j 1/1 Running 0 9m
    web-replicaset-01-p5tzx 1/1 Running 0 2m
    ```
    </details>
9. Reapply the 05-replicaset.yaml file. Look at the running pods. What happens?
    > 🗒️**Note:**: You should see two different behaviours:
        - The existing pods are *adopted* by the newly-created ReplicaSet (you can verify this by doing a kubectl describe pod - look at the Controlled By: section )
        - The ReplicaSet notices that the number of existing pods is less than the desired number, and creates a new pod to complete the set.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 05-replicaset.yaml
    replicaset.extensions/web-replicaset-01 created
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-replicaset-01-6gmds 1/1 Running 0 2m
    web-replicaset-01-6zcrf 1/1 Running 0 10m
    web-replicaset-01-fwqdv 1/1 Running 0 2m
    web-replicaset-01-l8k4j 1/1 Running 0 10m
    web-replicaset-01-p5tzx 1/1 Running 0 2m
    web-replicaset-01-pr7lg 0/1 ContainerCreating 0 1s
    ```
    </details>
    </details>
10. (Optional) Copy the 01-pod.yaml file to 06-pod-labeled.yaml . Edit the new file, adding
the `app=multi-web` label for the pod. Apply the file, in order to create a new pod. What
happens?
    > 🗒️**Note:** The newly-created pod matches the ReplicaSet selector (although it has a different name, the ReplicaSet only cares about the labels). Since the addition of the new pod means that the number of matching pods (7) exceeds the desired number (6), one of the pods will automatically be terminated. Most likely, it will be the newly-created one.
    <details>
        <summary>Answer</summary>

    content of `06-pod-labeled.yaml`:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx01
      labels:
        app: multi-web
    spec:
      containers:
      - image: nginx
        name: nginx
    ```
    ```shell
    ubuntu@master-node:~$ kubectl apply -f 06-pod-labeled.yaml
    pod/nginx01 created
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    nginx01 0/1 Terminating 0 2s
    web-replicaset-01-6gmds 1/1 Running 0 9m
    web-replicaset-01-6zcrf 1/1 Running 0 17m
    web-replicaset-01-fwqdv 1/1 Running 0 10m
    web-replicaset-01-l8k4j 1/1 Running 0 17m
    web-replicaset-01-p5tzx 1/1 Running 0 10m
    web-replicaset-01-pr7lg 1/1 Running 0 7m
    ```
    </details>
11. Delete the ReplicaSet. The corresponding pods should be automatically deleted.


# 3. Deployments
1. Create a YAML file ( 07-deployment.yaml ), corresponding to the previously-created ReplicaSet. The name of the deployment should be web-deployment-01, and it should run 6
instances of the nginx pod. Use `app: depl-web` for the template labels, and the selector.
    > 💡**Hint:** here is a starting point:
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: <depl-name>
    spec:
      replicas: <x>
      selector:
        matchLabels:
          key: value
    template:
      metadata:
        labels:
          pod-key: pod-value
      spec:
        containers:
        - name: nginx
          image: nginx
    ```
    <details>
        <summary>Answer</summary>

    content of `07-deployment.yaml`:
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-deployment-01
    spec:
      replicas: 6
      selector:
        matchLabels:
          app: depl-web
      template:
        metadata:
          labels:
            app: depl-web
      spec:
        containers:
        - name: nginx
          image: nginx
    ```
    apply using
    ```shell
    ubuntu@master-node:~$ kubectl apply -f 07-deployment.yaml
    deployment.apps/web-deployment-01 created
    ```
    </details>
2. Apply the YAML file.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 07-deployment.yaml
    deployment.apps/web-deployment-01 created
    ```
    </details>
3. Display the list of running pods. You should see the newly-created 6 instances.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-deployment-01-74446f759b-4m45p 1/1 Running 0 2m
    web-deployment-01-74446f759b-gvxfk 1/1 Running 0 2m
    web-deployment-01-74446f759b-ljv8x 1/1 Running 0 2m
    web-deployment-01-74446f759b-mhfkh 1/1 Running 0 2m
    web-deployment-01-74446f759b-tb7jb 1/1 Running 0 2m
    web-deployment-01-74446f759b-vb7vq 1/1 Running 0 2m
    ```
    </details>
4. Display the list of ReplicaSets. Notice that the deployment actually creates a ReplicaSet in the background, and it is the ReplicaSet that manages the pods.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get replicasets.
    NAME DESIRED CURRENT READY AGE
    web-deployment-01-74446f759b 6 6 6 2m
    ```
    </details>

# 4. (Optional) Upgrading a Deployment
A new version of the application (in this case, the webserver) is out - let’s upgrade our pods Preferably with zero downtime!
1. Copy the 07-deployment.yaml file to 08-deployment-upgraded.yaml.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ cp 07-deployment.yaml 08-deployment-upgraded.yaml
    ```
    </details>
2. Change the new file so that the containers are running nginx:1.15.1 as an image.
    <details>
        <summary>Answer</summary>

    content of `08-deployment-upgraded.yaml`:
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-deployment-01
    spec:
      replicas: 6
      selector:
      matchLabels:
        app: depl-web
      template:
        metadata:
          labels:
            app: depl-web
      spec:
        containers:
        - name: nginx
          image: nginx:1.15.1
    ```
    </details>
3. Apply the new file to the system.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 08-deployment-upgraded.yaml
    deployment.apps/web-deployment-01 configured
    ```
    </details>
4. Take a look at the list of pods. What happens?
    > 💡**Hint:** The pods are updated in sequence. Pods will be created with the new version of the application. After the new pods have started, a corresponding number of old pods will be terminated. This process continues until all the pods are using the new image.
    > 💡**Hint:** The pod names are of the form deployment_name-AAAA-BBBB , where AAAA identifies the ReplicaSet, and BBBB identifies the individual pods. If you look at the middle part (AAAA), you will see that it changes.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-deployment-01-74446f759b-4m45p 1/1 Running 0 8m
    web-deployment-01-74446f759b-gvxfk 1/1 Running 0 8m
    web-deployment-01-74446f759b-ljv8x 0/1 Terminating 0 8m
    web-deployment-01-74446f759b-mhfkh 1/1 Running 0 8m
    web-deployment-01-74446f759b-tb7jb 1/1 Running 0 8m
    web-deployment-01-74446f759b-vb7vq 1/1 Running 0 8m
    web-deployment-01-7dbb4874dd-ghblw 0/1 ContainerCreating 0 2s
    web-deployment-01-7dbb4874dd-l4shl 0/1 ContainerCreating 0 2s
    web-deployment-01-7dbb4874dd-xb8fh 0/1 ContainerCreating 0 2s
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    web-deployment-01-74446f759b-gvxfk 0/1 Terminating 0 9m
    web-deployment-01-74446f759b-tb7jb 0/1 Terminating 0 9m
    web-deployment-01-7dbb4874dd-ghblw 1/1 Running 0 36s
    web-deployment-01-7dbb4874dd-l4shl 1/1 Running 0 36s
    web-deployment-01-7dbb4874dd-lj2ms 1/1 Running 0 12s
    web-deployment-01-7dbb4874dd-pv7sv 1/1 Running 0 9s
    web-deployment-01-7dbb4874dd-tztrj 1/1 Running 0 18s
    web-deployment-01-7dbb4874dd-xb8fh 1/1 Running 0 36s
    ```
    </details>
5. Take a look at the list of ReplicaSets. What do you see?
    > 💡**Hint:** Upgrading the deployment creates a new ReplicaSet. The old one is also kept around - if, for any reason, you need to revert to the previous version of the app, you can use the saved ReplicaSet to switch back.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl get rs
    NAME DESIRED CURRENT READY AGE
    web-deployment-01-74446f759b 0 0 0 11m
    web-deployment-01-7dbb4874dd 6 6 6 3m
    ```
    </details>

# 5. Cleaning Up
5.1. Delete the deployment. All corresponding ReplicaSets and pods should automatically be deleted.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete deployments web-deployment-01
    deployment.extensions "web-deployment-01" deleted
    ubuntu@master-node:~$ kubectl get rs
    No resources found.
    ubuntu@master-node:~$ kubectl get pod
    No resources found.
    ```
    </details>