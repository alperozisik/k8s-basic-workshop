# 1. Taking a Look Around
1. List all the namespaces in your cluster.  
    > ➡️ namespaces are a resource just like everything else in k8s.  
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
    > ➡️ the -o wide option for kubectl get pods will help here!
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
    > 🗒️ Keep in mind that connecting and running commands directly inside a container is **NOT** a best practice! We are just using it in the lab to illustrate various behaviours (also, it can be very useful for troubleshooting container issues).
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
    > 🗒️ we will get back to this in a future lesson, but this is the „magic” of Kubernetes networking - all pods are reachable from all nodes, on the same (private) IP address!
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
    > ➡️ This is a "normal" pod - there is no need to run it in interactive mode. Also, since the nginx image will automatically start the nginx daemon, there is no need to specify a command to run.
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl run nginx1 --image=nginx
    ```
    </details>

2. Check that the pod is running. On what host has it been scheduled?
    > 🗒️ chances are it has been scheduled on the other node (not the one on which the *alpine* pod is running). Kubernetes does its best to balance the workload among worker nodes.
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

3. What is the IP address of the pod?
    <details>
        <summary>Answer</summary>

    You need to replace the pod name from the previous query
    ```shell
    kubectl describe pod nginx1-846d65cc74-p5h4l
    ```
    </details>

4. Connect to the IP address by using the `curl` command-line utility. You should see the default nginx welcome page

    <details>
        <summary>Answer</summary>

    You need to replace the ip from the previous query
    > ⚠️ Need to be executed within worker, who runs the pod
    ```shell
    curl 192.168.38.67
    ```
    </details>

# 5. Getting Inside a Running Pod
1.  Run a bash shell inside the nginx pod.
    > ➡️ `kubectl exec -it <pod_name>`. The shell needs to be interactive, and it needs stdin (`-it`).
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl exec -it nginx1-846d65cc74-p5h4l bash
    ```
    </details>
2. Change the contents of the default nginx index.html file: /usr/share/nginx/html/index.html
    > ➡️ you could use a text editor. The alternative is to simply `echo "some text" > /path/to/desired/file.html`
    <details>
        <summary>Answer</summary>

    ```shell
    echo "hello from alper-k8s!" > /usr/share/nginx/html/index.html
    ```
    </details>
3. Exit the shell (type exit or press Ctrl-D). Is the pod still running? Why or why not?
    > 🗒️ When the main process inside a container is stopped, the entire container stops. However, the shell was not the main process inside the container - the main process was (and still is) nginx!
    <details>
        <summary>Answer</summary>

    ```shell
    exit
    ```
    </details>

4. Using curl, connect to the web server once again. You should receive the new contents of the index.html file.
    <details>
        <summary>Answer</summary>

    > ⚠️ Need to be executed within worker, who runs the pod
    ```shell
    curl 192.168.38.67
    ```
    </details>

# 5. Deleting a Pod
1. Time to do some cleanup... delete the `alpine1` pod. What happens?
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl delete pod alpine1
    ```
    This may take while, be patient  
    Verify deletion via
    ```shell
    kubectl get pod
    ```

    </details>
2. Repeat the same for `nginx1`
    <details>
        <summary>Answer</summary>

    ```shell
    kubectl delete pod nginx1
    ```  
    Verify deletion via
    ```shell
    kubectl get pod
    ```


