```bash
docker run -it --rm --privileged --pid=host justincormack/nsenter1
```

```bash
pkill -9 docker
```

```bash
# https://github.com/justincormack/nsenter1
# https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389
# https://formulae.brew.sh/formula/socat
brew install socat
socat $HOME/Library/Containers/com.docker.docker/Data/vms/0/console.sock -,rawer
socat $HOME/Library/Containers/com.docker.docker/Data/debug-shell.sock -,rawer
# Press ENTER
# Output:
# docker-desktop:~#
```

```bash
ctr ns list
# output:
# services.linuxkit
```

```bash
ctr -n services.linuxkit container list
```

```text
CONTAINER            IMAGE    RUNTIME
acpid                -        io.containerd.runc.v2
allowlist            -        io.containerd.runc.v2
binfmt               -        io.containerd.runc.v2
devenv-service       -        io.containerd.runc.v2
dhcpcd               -        io.containerd.runc.v2
diagnose             -        io.containerd.runc.v2
dns-forwarder        -        io.containerd.runc.v2
docker               -        io.containerd.runc.v2
http-proxy           -        io.containerd.runc.v2
kmsg                 -        io.containerd.runc.v2
sntpc                -        io.containerd.runc.v2
socks                -        io.containerd.runc.v2
trim-after-delete    -        io.containerd.runc.v2
volume-contents      -        io.containerd.runc.v2
vpnkit-forwarder     -        io.containerd.runc.v2
```

```bash
ctr -n services.linuxkit task list

```

```bash
ctr -n services.linuxkit task exec -t --exec-id test docker bash
# output:
# root@docker-desktop:/#
```

```bash
docker info
```
```bash
exit
# output:
# docker-desktop:~#
```

```bash
ctr -n services.linuxkit container info vpnkit-forwarder
```

```json
{
    "ID": "vpnkit-forwarder",
    "Labels": null,
    "Image": "",
    "Runtime": {
        "Name": "io.containerd.runc.v2",
        "Options": null
    },
    "SnapshotKey": "",
    "Snapshotter": "",
    "CreatedAt": "2022-08-20T15:19:21.245882666Z",
    "UpdatedAt": "2022-08-20T15:19:21.245882666Z",
    "Extensions": null,
    "Spec": {
        "ociVersion": "1.0.2",
        "process": {
            "user": {
                "uid": 0,
                "gid": 0
            },
            "args": [
                "/usr/bin/vpnkit-forwarder",
                "-data-connect",
                "/run/host-services/vpnkit-data.sock",
                "-data-listen",
                "/run/guest-services/wsl2-expose-ports.sock"
            ],
            "env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "cwd": "/",
            "capabilities": {}
        },
        "root": {
            "path": "/containers/services/vpnkit-forwarder/rootfs"
        },
        "mounts": [
            {
                "destination": "/dev",
                "type": "tmpfs",
                "source": "tmpfs",
                "options": [
                    "nosuid",
                    "strictatime",
                    "mode=755",
                    "size=65536k"
                ]
            },
            {
                "destination": "/dev/pts",
                "type": "devpts",
                "source": "devpts",
                "options": [
                    "nosuid",
                    "noexec",
                    "newinstance",
                    "ptmxmode=0666",
                    "mode=0620"
                ]
            },
            {
                "destination": "/proc",
                "type": "proc",
                "source": "proc",
                "options": [
                    "nosuid",
                    "nodev",
                    "noexec",
                    "relatime"
                ]
            },
            {
                "destination": "/run/guest-services",
                "type": "bind",
                "source": "/run/guest-services",
                "options": [
                    "rw",
                    "rbind",
                    "rshared"
                ]
            },
            {
                "destination": "/run/host-services",
                "type": "bind",
                "source": "/run/host-services",
                "options": [
                    "rw",
                    "rbind",
                    "rshared"
                ]
            },
            {
                "destination": "/sys",
                "type": "sysfs",
                "source": "sysfs",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev"
                ]
            },
            {
                "destination": "/sys/fs/cgroup",
                "type": "cgroup",
                "source": "cgroup",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev",
                    "relatime",
                    "ro"
                ]
            }
        ],
        "linux": {
            "resources": {},
            "cgroupsPath": "systemreserved/vpnkit-forwarder",
            "namespaces": [
                {
                    "type": "pid"
                },
                {
                    "type": "mount"
                }
            ]
        }
    }
}
```


