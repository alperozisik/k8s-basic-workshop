You can always check content of the [samples folder](../samples) to check the file contents.

# 1. Running a pod
1. Connect to the master node with your user credentials. Make sure that there are no pods already running on the system (in your namespace)
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod
    ```
    resulting:
    ```
    No resources found.
    ```
    </details>




2. Create a simple pod YAML file in your home directory - let’s call it **01-pod.yaml**.
    > 🗒️ Note: You can use any text editor you wish for this task. If you do not have a favorite, I would recommend VScode:
    ```shell
    code ~/01-pod.yaml
    ```
3. Populate the file with the necessary information in order to create an nginx pod. The name of the pod should be nginx01, and the image used should be nginx.  
Remember that you will need:
    - apiVersion (pods exist since v1)
    - kind (Pod) (the kind is CamelCase)
    - metadata, with a field called name (mandatory)
    - spec, listing at least one container, with a name and an image
    
    Here is a starting point for the file:
    ```yaml
    apiVersion: v1
    kind: <>
    metadata:
        name: <>
    spec:
        containers:
        - name: <>
          image: <>
    ```

    <details>
        <summary>Answer</summary>

    ```yaml
   apiVersion: v1
    kind: Pod
    metadata:
        name: nginx01
    spec:
        containers:
        - name: nginx
          image: nginx
            
    ```
    </details>
4. Run the pod on the cluster.
    > 💡 **Hint:** You can use kubectl apply or kubectl create, with the -f argument specifying the file to use.    

    <details>
        <summary>Answer</summary>

    ```shell
    kubectl apply -f 01-pod.yaml
    ```
    resulting:
    ```
    pod/nginx01 created
    ```
    </details>
5. Verify that the pod has been created and is running. On which host has the pod been scheduled?
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod
    ```
    resulting:
    ```
    NAME    READY   STATUS  RESTARTS    AGE
    nginx01 1/1     Running 0           12s
    ```
    </details>
6. Get the IP address of the pod. Connect to the IP address using curl to verify that the web server is serving content.
    > 💡 **Hint:** you could use kubectl describe to get the IP address, but it is also included in the output of `kubectl get pod -o wide`
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod -o wide
    ```
    resulting:
    ```
    NAME    READY   STATUS  RESTARTS    AGE IP              NODE                NOMINATED NODE
    nginx01 1/1     Running 0           14s 192.168.63.198  kubernetes-00-02    <none>
    ```
    Get the IP address from the pod, query that via curl. Your IP could be different
    ```shell
    curl 192.168.63.198
    ````
    response:
    ```
    <!DOCTYPE html>
    <html>
    <head>
    ...
    ```
    </details>

# 2. Getting Possible Options
1. There are many possible options that could be used in the YAML file. The easiest way to take a look at them is to see the actual configuration of your pod (the way Kubernetes sees it). Display the pod configuration in YAML format
    > 💡**Hint:** kubectl get pod -o yaml

    > 🗒️**Note:** The status section is dynamically populated by Kubernetes at runtime (so it cannot be part of the original YAML file, used to create the pod). Focus on the spec section.

    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod nginx01 -o yaml
    ```
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
        annotations:
            kubectl.kubernetes.io/last-applied-configuration: |
            [...]
        nodeName: kubernetes-00-02
        priority: 0
        restartPolicy: Always #<---------
    ```
    
    </details>

2. What is the restart policy of the pod?
    > 💡**Hint:** Look for `restartPolicy`

    > 🗒️**Note:** Since we did not specify this field as part of the original YAML file, it has been populated with the default value.
3. For a full list of configuration options, try the `kubectl explain pod --recursive` command.
    > 💡**Hint:** It is strongly recommended to pipe it to the less command - there are many pages of possible options...
4. Print out the pod configuration in JSON format.
    > 🗒️**Note:** Not as easy to read by a human, is it? (although the fact that k8s pretty-prints it by default does help) However, it is much easier to parse by machines - including command-line tools such as `jq`
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod nginx01 -o json
    ```
    ```json
    {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
        "annotations": {
        "kubectl.kubernetes.io/last-applied-configuration":
        "{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"name\":\"nginx01\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"image\":\"nginx\",\"name\":\"nginx\"}]}}\n"
        },
    ```
    </details>
5. (Challenge) Speaking of jq - can you write a single command that prints out only the IP address of a specific pod?
    > 💡**Hint:** This is not easy in the beginning (it requires you to look up and understand the syntax used by jq to extract specific fields). However, it is a very useful thing to master if you ever need to deal with JSON-formatted data.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod nginx01 -o json | jq -r .status.podIP
    ```
    ```
    192.168.63.198
    ```
    </details>
6. Create another file (`02-alpine.yaml`) that starts an `alpine` pod. The name of the pod should be `alpine01`, and the image used should be `alpine`. Create the pod based on this file.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl apply -f 02-alpine.yaml
    ```
    ```
    pod/alpine01 created
    ```
    </details>
7. Verify that the pod is running. What do you see?
    <details>
        <summary>Answer</summary>
    
    You will see that the pod continuously crashes and is automatically restarted:
    ```shell
    kubectl get pod
    ```
    ```
    NAME        READY   STATUS      RESTARTS    AGE
    alpine01    0/1     Completed   0           7s
    nginx01     1/1     Running     0           20m
    ```
    and
    ```shell
    kubectl get pod
    ```
    ```
    NAME        READY   STATUS              RESTARTS    AGE
    alpine01    0/1     CrashLoopBackOff    1           10s
    nginx01     1/1     Running             0           20m
    ```
    </details>
8. Check the details of the pod. What is the reason for this behavior?
    > 💡**Hint:** kubectl describe pod

    > 💡**Hint:** By default, the alpine image will try to run sh. Which is a shell, and expects to receive input...
    <details>
        <summary>Answer</summary>
    
    Actually, the describe command is not that helpful - you will see that the container keeps crashing, but you will not see the actual reason...
    ```shell
    kubectl describe pod alpine01
    ```
    ```
    Name: alpine01
    Namespace: default
    Events:
    Type    Reason  Age   From    Message
    ----    ------  ----  ----    -------
    Normal Scheduled 47s default-scheduler Successfully assigned default/alpine01 to
    kubernetes-00-02
    Normal Pulling 23s (x3 over 46s) kubelet, kubernetes-00-02 pulling image "alpine"
    Normal Pulled 21s (x3 over 44s) kubelet, kubernetes-00-02 Successfully pulled image "alpine"
    Normal Created 21s (x3 over 44s) kubelet, kubernetes-00-02 Created container
    Normal Started 21s (x3 over 43s) kubelet, kubernetes-00-02 Started container
    Warning BackOff 4s (x4 over 38s) kubelet, kubernetes-00-02 Back-off restarting failed container
    ```

    </details>
9. Delete the pod. Edit the 02-alpine.yaml to fix the problem.
    > 💡**Hint:** When running a shell (or any other type of program that expects input on stdin) inside a container, you need to use `-it` on the command line. The equivalent in YAML is to set stdin: true (`-i`) and tty: true (`-t`) for the container (*.spec.containers*)
    <details>
        <summary>Answer</summary>

    ```shell
    cat 02-alpine.yaml
    ```
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
    ```
    </details>
10. Create a pod based on the new file, and verify that the pod starts correctly.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl apply -f 02-alpine.yaml
    ```
    ```
    pod/alpine01 created
    ```
    ```shell
    kubectl get pod
    ```
    ```
    NAME READY STATUS RESTARTS AGE
    alpine01 1/1 Running 0 6s
    nginx01 1/1 Running 0 30m
    ```
    </details>
11. Attach to the running shell on the alpine container
    > 💡**Hint:** In a previous lab, we have used `kubectl exec` to **run** a new process inside an **existing** container. This time, we want to attach to the existing, main process inside the container. For this, we will use `kubectl attach`.

    > 💡**Hint:** you need to specify `-it` on the command line!

    <details>
        <summary>Answer</summary>

    ```shell
    kubectl attach -it alpine01
    ```
    ```
    Defaulting container name to alpine.
    Use 'kubectl describe pod/alpine01 -n default' to see all of the
    containers in this pod.
    If you don't see a command prompt, try pressing enter.
    / #
    ```
    </details>
12. Exit the shell (type exit or press `Ctrl+D`).
    <details>
        <summary>Answer</summary>

    ```/ # [^D] Session ended, resume using 'kubectl attach alpine01 -c alpine -i -t' command when the pod is running
    ubuntu@master-00-01:~$
    ```
    </details>
13. What happens?
    > 💡**Hint:** If you have attached to the **main** process inside the container, and then stopped that process, the container is stopped. However, Kubernetes automatically restarts it - you will see the number of restarts incrementing.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod
    ```
    ```
    NAME READY STATUS RESTARTS AGE
    alpine01 1/1 Running 1 5m
    nginx01 1/1 Running 0 35m
    ```
    </details>

# 3. (Optional) RestartPolicy
1. Let’s explore the possible restart policies... The status of the container is dictated by its exit code - `0` means **success**, a *non-zero* code means **error**. To simulate this, we will attach to the container and use the commands `exit 0` (for success), or 
`exit 1` (for failure).
2. Attach to the running alpine container. Type `exit 0`. What happens?
    > 💡**Hint:** this is a `success`. The container status will briefly change to `Completed`, and then the pod will be restarted.
    <details>
        <summary>Answer</summary>

    ```
    kubectl attach -it alpine01
    Defaulting container name to alpine.
    Use 'kubectl describe pod/alpine01 -n default' to see all of the
    containers in this pod.
    If you don't see a command prompt, try pressing enter.
    / # exit 0
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Completed 1 9m
    nginx01 1/1 Running 0 39m
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 1/1 Running 2 10m
    nginx01 1/1 Running 0 40m
    ```
    </details>
3. Once the pod is running again, reattach to it. This time, type `exit 1`. What happens?
Hint: this is **exit with an error**. The container status will change to `Error`, and then the pod will be restarted.
    <details>
        <summary>Answer</summary>

    ```
    kubectl attach -it alpine01
    Defaulting container name to alpine.
    Use 'kubectl describe pod/alpine01 -n default' to see all of the
    containers in this pod.
    If you don't see a command prompt, try pressing enter.
    / # exit 1
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Error 2 11m
    nginx01 1/1 Running 0 41m
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 1/1 Running 3 14m
    nginx01 1/1 Running 0 43m
    ```
    </details>
4. Delete the pod. Change the YAML file so that `restartPolicy` (under spec) is set to `OnFailure`.
    <details>
        <summary>Answer</summary>

    ```
    ubuntu@master-node:~$ kubectl delete pod alpine01
    pod "alpine01" deleted
    ubuntu@master-node:~$ cat 02-alpine.yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: alpine01
    spec:
    restartPolicy: OnFailure
    containers:
    - image: alpine
        name: alpine
        stdin: true
        tty: true
    ```
    </details>
5. Create a new pod based on the changed file.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl apply -f 02-alpine.yaml
    pod/alpine01 created
    ```
    </details>
6. Repeat steps 2 and 3 above. What happens?
    > 💡**Hint:** Start with step 3, and then move to step 2 😉 This time, only a pod that exits due to an error is restarted. Once the pod completes execution successfully, it remains stopped.
    <details>
        <summary>Answer</summary>

    ```
    ubuntu@master-node:~$ kubectl attach -it alpine01
    Defaulting container name to alpine.
    Use 'kubectl describe pod/alpine01 -n default' to see all of the
    containers in this pod.
    If you don't see a command prompt, try pressing enter.
    / # exit 1
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Error 0 36s
    nginx01 1/1 Running 0 46m
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 1/1 Running 1 41s
    nginx01 1/1 Running 0 46m
    ubuntu@master-node:~$ kubectl attach -it alpine01
    Defaulting container name to alpine.
    Use 'kubectl describe pod/alpine01 -n default' to see all of the
    containers in this pod.
    If you don't see a command prompt, try pressing enter.
    / # exit 0
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Completed 1 59s
    nginx01 1/1 Running 0 46m
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Completed 1 2m
    nginx01 1/1 Running 0 47m
    ```

# 4. (Optional) Running Multiple Pods
1. Create a single file ( 03-pods.yaml ) that starts both an alpine and an nginx pod.
    > 💡**Hint:** The easiest way to do this is to simply use two yaml documents (separated by `---` ) inside a single file.
    <details>
        <summary>Answer</summary>

    content of `03-pods.yaml` file
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx02
    spec:
      containers:
        - image: nginx
          name: nginx
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: alpine02
    spec:
      containers:
      - image: alpine
        name: alpine
        stdin: true
        tty: true
    ```
    </details>
2. Apply the file and verify that the two pods get created correctly.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl apply -f 03-pods.yaml
    pod/nginx02 created
    pod/alpine02 created
    ubuntu@master-node:~$ kubectl get pod
    NAME READY STATUS RESTARTS AGE
    alpine01 0/1 Completed 1 5m
    alpine02 1/1 Running 0 36s
    nginx01 1/1 Running 0 50m
    nginx02 1/1 Running 0 36s
    ```
    </details>

# 5. Cleaning Up
1. Delete all pods.
    <details>
        <summary>Answer</summary>

    ```shell
    ubuntu@master-node:~$ kubectl delete pods --all
    pod "alpine02" deleted
    pod "nginx01" deleted
    pod "nginx02" deleted
    ```
    </details>