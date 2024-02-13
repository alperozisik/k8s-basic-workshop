You can always check content of the [samples folder](../samples) to check the file contents.

In this lab, we will see how we can keep our data, even though our containers are (and should be!) ephemeral.

# 1. EmptyDir
We will start with a very simple example - the *emptyDir* volume type. This simply uses a directory on the node the pod is running on.
1. Connect to the master node with your user credentials. Make sure that there are no pods already running on the system (in your namespace)
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl get pod
    No resources found.
    ```
    </details>
2. Copy the `02-alpine.yaml` file to a new file: `09-emptydir.yaml`
    <details>
        <summary>Answer</summary>

    ```shell
    cp 02-alpine.yaml 09-emptydir.yaml
    ```
    </details>
3. Edit the new file to add an emptyDir volume. Name the volume *empty-volume*, and mount it in /scratch
    > 💡**Hint:** as usual, here is a snippet to get you started:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
        name: <pod-name>
    spec:
        containers:
        - image:
        …
        volumeMounts:
        - mountPath: <directory>
            name: <vol-name>
        volumes:
        - name: <vol-name>
        emptyDir: {}
    ```
    <details>
        <summary>Answer</summary>

    content of 09-emptydir.yaml
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: alpine01
    spec:
      containers:
      - image: alpine
        name: alpine
        stdin: true
        tty: true
        volumeMounts:
        - mountPath: /scratch
          name: empty-volume
      volumes:
      - name: empty-volume
        emptyDir: {}
    ```
    </details>
4. Create a pod based on this specification.
    <details>
        <summary>Answer</summary>

    ```shell
student@kubernetes-00-01:~$ kubectl apply -f 09-emptydir.yaml
pod/alpine01 created
    ```
    </details>
5. Get a shell inside the pod. Create a file inside the /scratch directory, with a text contents of your choosing.
    > 💡**Hint:** you can connect to the existing shell ( `kubectl attach` ), or you can open a new one (`kubectl exec` ). Which one you choose is very relevant when you exit the pod! :)
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl exec -it alpine01 sh
    / # cd /scratch/
    /scratch # ls
    /scratch # echo "test file" > testfile
    /scratch # ls
    testfile
    ```
    </details>
6. Exit the pod. Delete the pod.
    <details>
        <summary>Answer</summary>

    ```shell
    /scratch # [^D]
    student@kubernetes-00-01:~$ kubectl delete pod alpine01
    pod "alpine01" deleted
    ```
    </details>
7. Create a new pod based on the same yaml file.
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl apply -f 09-emptydir.yaml
    pod/alpine01 created
    ```
    </details>
8. Get a shell inside the new pod. Is your file still inside?
    > 💡**Hint:** While *emptyDir* volumes wil survive a pod crash/restart, they will be removed when the pod itself is removed.
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl exec -it alpine01 sh
    / # cd /scratch/
    /scratch # ls
    /scratch #
    ```
    </details>
9. Exit the pod. Delete the pod.
    <details>
        <summary>Answer</summary>

    ```shell
    /scratch # [^D]
    student@kubernetes-00-01:~$ kubectl delete pod alpine01
    pod "alpine01" deleted
    ```
    </details>

# 2. HostPath
A more relevant (more... persistent) example is the hostPath volume type. This will actually persist across pod deletions, but has another disadvantage - it makes the pod dependent on a specific host (a specific host directory structure). So in order to make sure that the pods will find that directory structure, we will force them to always run on a specific host.

Needless to say, this is not something you would generally want to do in production. However, it
is a useful exercise for dealing with labels and selectors. 😀

1. In order to make testing easier, we want to force our pod to run on one specific node (it is
easier this way than chasing the pods across multiple nodes).
In order to do this, we will use a label. Label your first worker node ( worker-01 ) with `pathConfigured=true`.
    > 💡**Hint:** kubectl label node...
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl label node kubernetes-00-02 pathConfigured=true
    node/kubernetes-00-02 labeled
    ```
    </details>
2. Make sure that the label has been correctly applied.
    > 💡**Hint:** kubectl get ... --show-labels
    <details>
        <summary>Answer</summary>

    ```
    student@kubernetes-00-01:~$ kubectl get nodes --show-labels
    NAME STATUS ROLES AGE VERSION LABELS
    kubernetes-00-01 Ready master 19h v1.11.2 beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-00-01,node-role.kubernetes.io/master=
    kubernetes-00-02 Ready <none> 18h v1.11.2 beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-00-02,pathConfigured=true
    kubernetes-00-03 Ready <none> 18h v1.11.2 beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kubernetes-00-03
    ```
    </details>
3. Copy the 09-emptydir.yaml file to 10-hostpath.yaml .
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ cp 09-emptydir.yaml 10-hostpath.yaml
    ```
    </details>
4. Edit the 10-hostpath.yaml file to add the following:
    - A node selector that forces the pod to run only on nodes labeled with pathConfigured=true. (Hint: this will be under .spec.nodeSelector )
    - A volume named host-volume mapped to the host directory /tmp/hostpath
    - A volumeMount for the container that tells it to mount the volume under /hostvol
    > 💡**Hint:**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: <pod-name>
    spec:
      nodeSelector:
        <key: value>
      containers:
        - image: <>
          name: <>
        volumeMounts:
        - mountPath: <pod-mount-path>
          name: <vol-name>
      volumes:
      - name: <vol-name>
      hostPath:
        # directory location on host
        path: <host-path>
        type: DirectoryOrCreate
    ```
    <details>
        <summary>Answer</summary>

    Content of `10-hostpath.yaml`
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: alpine02
    spec:
      nodeSelector:
        pathConfigured<your_user_id>: "true"
      containers:
      - image: alpine
        name: alpine
        stdin: true
        tty: true
        volumeMounts:
        - mountPath: /hostvol
          name: host-volume
      volumes:
      - name: host-volume
        hostPath:
          path: /tmp/hostpath
        type: DirectoryOrCreate
    ```
    </details>
5. Create a pod based on this new specification file.
    > 🗒️**Note:** If you get a very cryptic error that looks like the one below, make sure that the value for the nodeSelector key:value pair is a string (place it in quotes):
    ```
    Error from server (BadRequest): error when creating "10-hostpath.yaml": Pod in version "v1" cannot be handled as a Pod:v1.Pod.Spec: v1.PodSpec.NodeSelector: ReadString: expects " or n, but found t, error found in #10 byte of ...|figured":true}
    ```
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl apply -f 10-hostpath.yaml
    pod/alpine02 created
    ```
    </details>
6. Get a shell into the pod, and create a test file in /hostvol . Use a content of your choosing.
    <details>
        <summary>Answer</summary>

    ```
    student@kubernetes-00-01:~$ kubectl exec -it alpine02 sh
    / # cd /ho
    home/ hostvol/
    / # cd /hostvol/
    /hostvol # echo "hello Alper" > testfile
    /hostvol # [^D]
    ```
    </details>
7. Exit the pod. Ask your instructor to connect to the host that the pod is running on, and check the /tmp/hostpath-ID directory. You should see your newly-created file.
    <details>
        <summary>Answer</summary>

    ```shell
    root@kubernetes-00-02:~# cd /tmp/hostpath/
    root@kubernetes-00-02:/tmp/hostpath# ls
    testfile
    root@kubernetes-00-02:/tmp/hostpath# cat testfile
    hello Alper
    ```
    </details>
8. Delete the pod, and create a new one based on the same YAML file. Get a shell into the pod. The file should still be in `/hostvol`.
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl delete pod alpine02
    pod "alpine02" deleted
    student@kubernetes-00-01:~$ kubectl apply -f 10-hostpath.yaml
    pod/alpine02 created
    student@kubernetes-00-01:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine02 0/1 ContainerCreating 0 4s
    nginx-01 1/1 Running 0 9m
    student@kubernetes-00-01:~$ kubectl exec -it alpine02 sh
    / # cd /hostvol/
    /hostvol # cat testfile
    hello Alper
    /hostvol # [^D]
    student@kubernetes-00-01:~$
    ```
    </details>
9. Delete the pod.
    <details>
        <summary>Answer</summary>

    ```shell
    student@kubernetes-00-01:~$ kubectl delete pod alpine02
    pod "alpine02" deleted
    ```
    </details>

# 3. (Optional) NFS Volume
To be skipped for today

# 4. (Bonus) PVs
To be skipped for today

# 5. Cleaning Up
1. Delete all PVs, PVCs, and pods.
    > 💡**Hint:** There are always shortcuts 😉
    > 🗒️**Note:** Do not use `kubectl delete pv --all` - since PVs are not namespaced, this will also delete PVs belonging to other usages!
    ```shell
    student@kubernetes-00-01:~$ kubectl delete pvc,pod --all
    student@kubernetes-00-01:~$ kubectl delete pv <pv_name>
    ```