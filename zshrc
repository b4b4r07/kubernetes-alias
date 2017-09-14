# List and select pod name with fzf (https://github.com/junegunn/fzf)
# e.g.
#   kubectl exec -it P sh
#   kubectl delete pod P
alias -g P='$(kubectl get pods | fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'

# Like P, global aliases about kubernetes resources
alias -g POD='$(   kubectl get pods  | fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'
alias -g DEPLOY='$(kubectl get deploy| fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'
alias -g RS='$(    kubectl get rs    | fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'
alias -g SVC='$(   kubectl get svc   | fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'
alias -g ING='$(   kubectl get ing   | fzf-tmux --header-lines=1 --reverse --multi --cycle | awk "{print \$1}")'

# Context switcher
# c.f. https://github.com/ahmetb/kubectx
alias kubectl-change='kubectx $(kubectx | fzy) >/dev/null'

# Alias of kubectl command
# also execute user-defined kubectl commands (and third party command; e.g. kubectx) if you have
# - `kube get pods` means `kubectl get pods`
# - `kube ctx` means `kubectx`
# - `kube change` means `kubectl-change`
function kube() {
    # This list was generated by `kubectl help`
    local -A subcommands=(
    # Basic Commands (Beginner):
    "create"         "Create a resource by filename or stdin"
    "expose"         "Take a replication controller, service, deployment or pod and expose it as a new Kubernetes Service"
    "run"            "Run a particular image on the cluster"
    "run-container"  "Run a particular image on the cluster"
    "set"            "Set specific features on objects"
    # Basic Commands (Intermediate):
    "get"            "Display one or many resources"
    "explain"        "Documentation of resources"
    "edit"           "Edit a resource on the server"
    "delete"         "Delete resources by filenames, stdin, resources and names, or by resources and label selector"
    # Deploy Commands:
    "rollout"        "Manage the rollout of a resource"
    "rolling-update" "Perform a rolling update of the given ReplicationController"
    "rollingupdate"  "Perform a rolling update of the given ReplicationController"
    "scale"          "Set a new size for a Deployment, ReplicaSet, Replication Controller, or Job"
    "resize"         "Set a new size for a Deployment, ReplicaSet, Replication Controller, or Job"
    "autoscale"      "Auto-scale a Deployment, ReplicaSet, or ReplicationController"
    # Cluster Management Commands:
    "certificate"    "Modify certificate resources."
    "cluster-info"   "Display cluster info"
    "clusterinfo"    "Display cluster info"
    "top"            "Display Resource (CPU/Memory/Storage) usage."
    "cordon"         "Mark node as unschedulable"
    "uncordon"       "Mark node as schedulable"
    "drain"          "Drain node in preparation for maintenance"
    "taint"          "Update the taints on one or more nodes"
    # Troubleshooting and Debugging Commands:
    "describe"       "Show details of a specific resource or group of resources"
    "logs"           "Print the logs for a container in a pod"
    "attach"         "Attach to a running container"
    "exec"           "Execute a command in a container"
    "port-forward"   "Forward one or more local ports to a pod"
    "proxy"          "Run a proxy to the Kubernetes API server"
    "cp"             "Copy files and directories to and from containers."
    "auth"           "Inspect authorization"
    # Advanced Commands:
    "apply"          "Apply a configuration to a resource by filename or stdin"
    "patch"          "Update field(s) of a resource using strategic merge patch"
    "replace"        "Replace a resource by filename or stdin"
    "update"         "Replace a resource by filename or stdin"
    "convert"        "Convert config files between different API versions"
    # Settings Commands:
    "label"          "Update the labels on a resource"
    "annotate"       "Update the annotations on a resource"
    "completion"     "Output shell completion code for the specified shell (bash or zsh)"
    # Other Commands:
    "api-versions"   "Print the supported API versions on the server, in the form of "group/version""
    "config"         "Modify kubeconfig files"
    "help"           "Help about any command"
    "plugin"         "Runs a command-line plugin"
    "version"        "Print the client and server version information"
    )
    local arg="${1:?too few arguments}"

    # Search from original kubectl commands
    if (( $+subcommands[$arg] )); then
        kubectl "$@"
        return $?
    fi

    # Search from user-defined kube* commands
    local -a expand_subs=( ${^path}/{kube-,kube,kubectl-}$arg(N-.) )
    if (( $#expand_subs > 0 )); then
        $expand_subs[1]
        return $?
    fi

    # Search from kubectl-* aliases
    if (( ${(k)+aliases[kubectl-${arg}]} )); then
        echo ${(v)aliases[kubectl-${arg}]} | zsh
        return $?
    fi

    # Nothing to find
    echo "$arg: no such kubernetes command" >&2
    return 1
}

# References
# - https://github.com/c-bata/kube-prompt
# - https://github.com/cloudnativelabs/kube-shell
