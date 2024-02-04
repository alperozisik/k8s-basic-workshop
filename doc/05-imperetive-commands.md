# 1. Taking a Look Around
1. List all the namespaces in your cluster.  
    > **Hint:** namespaces are a resource just like everything else in k8s.  
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get namespaces
    ```
    </details>
2. List all the pods in each namespace.  
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pods -n kube-public
    kubectl get pods -n default
    kubectl get pods -n kube-system
    ```
    </details>
3. Right now, the only running pods are inside the kube-system namespace. List the pods, including the node on which every pod is currently running.  
    > **Hint:** the -o wide option for kubectl get pods will help here!
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pods -n kube-system -o wide
    ```
    </details>
4. Do you notice a pattern in the pod-to-node distribution?
    <details>
        <summary>Answer</summary>

    There are actually several patterns:
    - some pods (like the kube-proxy ones) run a copy of the pod on each node in the cluster. These are part of so-called DaemonSets
    - other pods (like the controller-manager) only run on the master
    - yet other pods (like the user workloads, which we will soon see) are not normally scheduled on the master - only on the worker nodes.
    </details>

# 2. Running a Simple Pod
1. Run a simple pod based on the alpine image (a very small, very lightweight, Linux image). Use the following options, without specifying anything else:
    - "pod" name: `alpine1` (actually, this will create a deployment, not just a pod!)
    - image name: `alpine`
    - interactive mode, keep tty open (-it)
    - command to run: sh
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl run -it alpine1 --image=alpine sh
    ```
    </details>
2. You should end up at a command-line prompt inside the pod. Verify this by checking the hostname of the machine you are now on.  
    > **Note:** Keep in mind that connecting and running commands directly inside a container is **NOT** a best practice! We are just using it in the lab to illustrate various behaviours (also, it can be very useful for troubleshooting container issues).
    <details>
        <summary>Answer</summary>

    ```shell
    hostname
    ```
    </details>
3. What is the IP address of this pod?
    <details>
        <summary>Answer</summary>

    ```shell
    ifconfig
    ```
    </details>
4. Exit the interactive session, leaving the pod running
    <details>
        <summary>Answer</summary>

    If you are inside the pod's terminal, you can typically detach without stopping the process by pressing `Ctrl` + `p`, followed by `Ctrl` + `q`.
    </details>
5. Display a list of pods. What is the status of the pod? On which host is the pod running?
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod
    ```
    OR
    ```shell
    kubectl get pod -o wide
    ```
    </details>
6. Get the IP address of the pod, as it is known by Kubernetes.
    <details>
        <summary>Answer</summary>

    You need to replace the pod name from the previous query
    ```shell
    kubectl describe pod alpine1-5d997c9767-jk9cx
    ```
    IP will be listed within the answer
    </details>
7. Ping the pod’s IP address. Can you reach it? (Optional: also try to ping it from another node)
    > **Note:** we will get back to this in a future lesson, but this is the „magic” of Kubernetes networking - all pods are reachable from all nodes, on the same (private) IP address!
    <details>
        <summary>Answer</summary>

    You need to replace the ip from the previous query
    ```shell
    ping 192.168.63.194
    ```
    Press `Ctrl` + `c`, otherwise ping go on indefinelty
    </details>

# 3. Running nginx
1. Run a new pod, with the following settings:
    - name: nginx1
    - image name: nginx
    > **Hint:** This is a "normal" pod - there is no need to run it in interactive mode. Also, since the nginx image will automatically start the nginx daemon, there is no need to specify a command to run.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl run nginx1 --image=nginx
    ```
    </details>

2. Check that the pod is running. On what host has it been scheduled?
    > **Note:** chances are it has been scheduled on the other node (not the one on which the *alpine* pod is running). Kubernetes does its best to balance the workload among worker nodes.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl get pod
    ```
    OR
    ```shell
    kubectl get pod -o wide
    ```
    </details>




