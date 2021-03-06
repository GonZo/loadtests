#!/bin/sh -e

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

makefile root:root 0644 "$tmp"/etc/hosts <<EOF
127.0.0.1	localhost localhost.localdomain
# XXX add machine names here
192.168.0.2	    server
192.168.0.3	    load00
192.168.0.4	    load01
EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
erlang
erlang-asn1
erlang-common-test
erlang-compiler
erlang-crypto
erlang-erl-interface
erlang-eunit
erlang-inets
erlang-os-mon
erlang-sasl
erlang-snmp
erlang-ssh
erlang-ssl
erlang-syntax-tools
erlang-tools
erlang-xmerl
openssh
perl
tsung
EOF

makefile root:root 0644 "$tmp"/etc/motd <<EOF

  Example:
    tsung -f configuration.xml start
    cd <results-directory>
    /usr/lib/tsung/bin/tsung_stats.pl

EOF

makefile root:root 0644 "$tmp"/etc/group <<EOF
root:x:0:root
bin:x:1:root,bin,daemon
daemon:x:2:root,bin,daemon
sys:x:3:root,bin,adm
adm:x:4:root,adm,daemon
tty:x:5:
disk:x:6:root,adm
lp:x:7:lp
mem:x:8:
kmem:x:9:
wheel:x:10:root
floppy:x:11:root
mail:x:12:mail
news:x:13:news
uucp:x:14:uucp
man:x:15:man
cron:x:16:cron
console:x:17:
audio:x:18:
cdrom:x:19:
dialout:x:20:root
ftp:x:21:
sshd:x:22:
input:x:23:
at:x:25:at
tape:x:26:root
video:x:27:root
netdev:x:28:
readproc:x:30:
squid:x:31:squid
xfs:x:33:xfs
kvm:x:34:kvm
games:x:35:
shadow:x:42:
postgres:x:70:
cdrw:x:80:
usb:x:85:
vpopmail:x:89:
users:x:100:games
ntp:x:123:
nofiles:x:200:
smmsp:x:209:smmsp
locate:x:245:
abuild:x:300:
utmp:x:406:
ping:x:999:
nogroup:x:65533:
nobody:x:65534:
load:x:301:load
EOF

makefile root:root 0644 "$tmp"/etc/passwd <<EOF
root:x:0:0:root:/root:/bin/ash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
news:x:9:13:news:/usr/lib/news:/sbin/nologin
uucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin
operator:x:11:0:operator:/root:/bin/sh
man:x:13:15:man:/usr/man:/sbin/nologin
postmaster:x:14:12:postmaster:/var/spool/mail:/sbin/nologin
cron:x:16:16:cron:/var/spool/cron:/sbin/nologin
ftp:x:21:21::/var/lib/ftp:/sbin/nologin
sshd:x:22:22:sshd:/dev/null:/sbin/nologin
at:x:25:25:at:/var/spool/cron/atjobs:/sbin/nologin
squid:x:31:31:Squid:/var/cache/squid:/sbin/nologin
xfs:x:33:33:X Font Server:/etc/X11/fs:/sbin/nologin
games:x:35:35:games:/usr/games:/sbin/nologin
postgres:x:70:70::/var/lib/postgresql:/bin/sh
cyrus:x:85:12::/usr/cyrus:/sbin/nologin
vpopmail:x:89:89::/var/vpopmail:/sbin/nologin
ntp:x:123:123:NTP:/var/empty:/sbin/nologin
smmsp:x:209:209:smmsp:/var/spool/mqueue:/sbin/nologin
guest:x:405:100:guest:/dev/null:/sbin/nologin
nobody:x:65534:65534:nobody:/:/sbin/nologin
load:x:301:301:load:/home/load:/bin/ash
EOF

makefile root:shadow 0640 "$tmp"/etc/shadow <<EOF
root:::0:::::
bin:!::0:::::
daemon:!::0:::::
adm:!::0:::::
lp:!::0:::::
sync:!::0:::::
shutdown:!::0:::::
halt:!::0:::::
mail:!::0:::::
news:!::0:::::
uucp:!::0:::::
operator:!::0:::::
man:!::0:::::
postmaster:!::0:::::
cron:!::0:::::
ftp:!::0:::::
sshd:!::0:::::
at:!::0:::::
squid:!::0:::::
xfs:!::0:::::
games:!::0:::::
postgres:!::0:::::
cyrus:!::0:::::
vpopmail:!::0:::::
ntp:!::0:::::
smmsp:!::0:::::
guest:!::0:::::
nobody:!::0:::::
load::17331:0:99999:7:::
EOF

mkdir -p "$tmp"/etc/conf.d/
makefile root:root 0644 "$tmp"/etc/conf.d/ntpd <<EOF
NTPD_OPTS="-N -p pool.ntp.org"
EOF
makefile root:root 0644 "$tmp"/etc/rc.conf <<EOF
# Global OpenRC configuration settings

# Set to "YES" if you want the rc system to try and start services
# in parallel for a slight speed improvement. When running in parallel we
# prefix the service output with its name as the output will get
# jumbled up.
# WARNING: whilst we have improved parallel, it can still potentially lock
# the boot process. Don't file bugs about this unless you can supply
# patches that fix it without breaking other things!
#rc_parallel="NO"

# Set rc_interactive to "YES" and you'll be able to press the I key during
# boot so you can choose to start specific services. Set to "NO" to disable
# this feature. This feature is automatically disabled if rc_parallel is
# set to YES.
#rc_interactive="YES"

# If we need to drop to a shell, you can specify it here.
# If not specified we use $SHELL, otherwise the one specified in /etc/passwd,
# otherwise /bin/sh
# Linux users could specify /sbin/sulogin
#rc_shell=/bin/sh

# Do we allow any started service in the runlevel to satisfy the dependency
# or do we want all of them regardless of state? For example, if net.eth0
# and net.eth1 are in the default runlevel then with rc_depend_strict="NO"
# both will be started, but services that depend on 'net' will work if either
# one comes up. With rc_depend_strict="YES" we would require them both to
# come up.
#rc_depend_strict="YES"

# rc_hotplug controls which services we allow to be hotplugged.
# A hotplugged service is one started by a dynamic dev manager when a matching
# hardware device is found.
# Hotplugged services appear in the "hotplugged" runlevel.
# If rc_hotplug is set to any value, we compare the name of this service
# to every pattern in the value, from left to right, and we allow the
# service to be hotplugged if it matches a pattern, or if it matches no
# patterns. Patterns can include shell wildcards.
# To disable services from being hotplugged, prefix patterns with "!".
#If rc_hotplug is not set or is empty, all hotplugging is disabled.
# Example - rc_hotplug="net.wlan !net.*"
# This allows net.wlan and any service not matching net.* to be hotplugged.
# Example - rc_hotplug="!net.*"
# This allows services that do not match "net.*" to be hotplugged.

# rc_logger launches a logging daemon to log the entire rc process to
# /var/log/rc.log
# NOTE: Linux systems require the devfs service to be started before
# logging can take place and as such cannot log the sysinit runlevel.
#rc_logger="NO"

# Through rc_log_path you can specify a custom log file.
# The default value is: /var/log/rc.log
#rc_log_path="/var/log/rc.log"

# If you want verbose output for OpenRC, set this to yes. If you want
# verbose output for service foo only, set it to yes in /etc/conf.d/foo.
#rc_verbose=no

# By default we filter the environment for our running scripts. To allow other
# variables through, add them here. Use a * to allow all variables through.
#rc_env_allow="VAR1 VAR2"

# By default we assume that all daemons will start correctly.
# However, some do not - a classic example is that they fork and return 0 AND
# then child barfs on a configuration error. Or the daemon has a bug and the
# child crashes. You can set the number of milliseconds start-stop-daemon
# waits to check that the daemon is still running after starting here.
# The default is 0 - no checking.
#rc_start_wait=100

# rc_nostop is a list of services which will not stop when changing runlevels.
# This still allows the service itself to be stopped when called directly.
#rc_nostop=""

# rc will attempt to start crashed services by default.
# However, it will not stop them by default as that could bring down other
# critical services.
#rc_crashed_stop=NO
#rc_crashed_start=YES

# Set rc_nocolor to yes if you do not want colors displayed in OpenRC
# output.
#rc_nocolor=NO

##############################################################################
# MISC CONFIGURATION VARIABLES
# There variables are shared between many init scripts

# Set unicode to YES to turn on unicode support for keyboards and screens.
#unicode="NO"

# This is how long fuser should wait for a remote server to respond. The
# default is 60 seconds, but  it can be adjusted here.
#rc_fuser_timeout=60

# Below is the default list of network fstypes.
#
# afs ceph cifs coda davfs fuse fuse.sshfs gfs glusterfs lustre ncpfs
# nfs nfs4 ocfs2 shfs smbfs
#
# If you would like to add to this list, you can do so by adding your
# own fstypes to the following variable.
#extra_net_fs_list=""

##############################################################################
# SERVICE CONFIGURATION VARIABLES
# These variables are documented here, but should be configured in
# /etc/conf.d/foo for service foo and NOT enabled here unless you
# really want them to work on a global basis.
# If your service has characters in its name which are not legal in
# shell variable names and you configure the variables for it in this
# file, those characters should be replaced with underscores in the
# variable names as shown below.

# Some daemons are started and stopped via start-stop-daemon.
# We can set some things on a per service basis, like the nicelevel.
#SSD_NICELEVEL="-19"
# Or the ionice level. The format is class[:data] , just like the
# --ionice start-stop-daemon parameter.
#SSD_IONICELEVEL="2:2"

# Pass ulimit parameters
# If you are using bash in POSIX mode for your shell, note that the
# ulimit command uses a block size of 512 bytes for the -c and -f
# options
rc_ulimit="-n 65535 -c unlimited"

# It's possible to define extra dependencies for services like so
#rc_config="/etc/foo"
#rc_need="openvpn"
#rc_use="net.eth0"
#rc_after="clock"
#rc_before="local"
#rc_provide="!net"

# You can also enable the above commands here for each service. Below is an
# example for service foo.
#rc_foo_config="/etc/foo"
#rc_foo_need="openvpn"
#rc_foo_after="clock"

# Below is an example for service foo-bar. Note that the '-' is illegal
# in a shell variable name, so we convert it to an underscore.
# example for service foo-bar.
#rc_foo_bar_config="/etc/foo-bar"
#rc_foo_bar_need="openvpn"
#rc_foo_bar_after="clock"

# You can also remove dependencies.
# This is mainly used for saying which services do NOT provide net.
#rc_net_tap0_provide="!net"

# This is the subsystem type.
# It is used to match against keywords set by the keyword call in the
# depend function of service scripts.
#
# It should be set to the value representing the environment this file is
# PRESENTLY in, not the virtualization the environment is capable of.
# If it is commented out, automatic detection will be used.
#
# The list below shows all possible settings as well as the host
# operating systems where they can be used and autodetected.
#
# ""               - nothing special
# "docker"         - Docker container manager (Linux)
# "jail"           - Jail (DragonflyBSD or FreeBSD)
# "lxc"            - Linux Containers
# "openvz"         - Linux OpenVZ
# "prefix"         - Prefix
# "rkt"            - CoreOS container management system (Linux)
# "subhurd"        - Hurd subhurds (to be checked)
# "systemd-nspawn" - Container created by systemd-nspawn (Linux)
# "uml"            - Usermode Linux
# "vserver"        - Linux vserver
# "xen0"           - Xen0 Domain (Linux and NetBSD)
# "xenU"           - XenU Domain (Linux and NetBSD)
#rc_sys=""

# on Linux and Hurd, this is the number of ttys allocated for logins
# It is used in the consolefont, keymaps, numlock and termencoding
# service scripts.
rc_tty_number=12

##############################################################################
# LINUX CGROUPS RESOURCE MANAGEMENT

# If you have cgroups turned on in your kernel, this switch controls
# whether or not a group for each controller is mounted under
# /sys/fs/cgroup.
# None of the other options in this section work if this is set to "NO".
#rc_controller_cgroups="YES"

# The following settings allow you to set up values for the cgroup
# controllers for your services.
# They can be set in this file;, however, if you do this, the settings
# will apply to all of your services.
# If you want different settings for each service, place the settings in
# /etc/conf.d/foo for service foo.
# The format is to specify the names of the settings followed by their
# values. Each variable can hold multiple settings.
# For example, you would use this to set the cpu.shares setting in the
# cpu controller to 512 for your service.
# rc_cgroup_cpu="
# cpu.shares 512
# "
#
#For more information about the adjustments that can be made with
#cgroups, see Documentation/cgroups/* in the linux kernel source tree.

# Set the blkio controller settings for this service.
#rc_cgroup_blkio=""

# Set the cpu controller settings for this service.
#rc_cgroup_cpu=""

# Add this service to the cpuacct controller (any value means yes).
#rc_cgroup_cpuacct=""

# Set the cpuset controller settings for this service.
#rc_cgroup_cpuset=""

# Set the devices controller settings for this service.
#rc_cgroup_devices=""

# Set the hugetlb controller settings for this service.
#rc_cgroup_hugetlb=""

# Set the memory controller settings for this service.
#rc_cgroup_memory=""

# Set the net_cls controller settings for this service.
#rc_cgroup_net_cls=""

# Set the net_prio controller settings for this service.
#rc_cgroup_net_prio=""

# Set the pids controller settings for this service.
#rc_cgroup_pids=""

# Set this to YES if you want all of the processes in a service's cgroup
# killed when the service is stopped or restarted.
# This should not be set globally because it kills all of the service's
# child processes, and most of the time this is undesirable. Please set
# it in /etc/conf.d/<service>.
# To perform this cleanup manually for a stopped service, you can
# execute cgroup_cleanup with /etc/init.d/<service> cgroup_cleanup or
# rc-service <service> cgroup_cleanup.
# rc_cgroup_cleanup="NO"
EOF
makefile root:root 0644 "$tmp"/etc/sysctl.conf <<EOF
# Maximum TCP Receive Window
net.core.rmem_max = 33554432
# Maximum TCP Send Window
net.core.wmem_max = 33554432
# others
net.ipv4.tcp_rmem = 4096 16384 33554432
net.ipv4.tcp_wmem = 4096 16384 33554432
net.ipv4.tcp_syncookies = 1
# this gives the kernel more memory for tcp which you need with many (100k+) open socket connections
net.ipv4.tcp_mem = 786432 1048576 26777216
net.ipv4.tcp_max_tw_buckets = 360000
net.core.netdev_max_backlog = 2500
vm.min_free_kbytes = 65536
vm.swappiness = 0
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
EOF

mkdir -p "$tmp"/etc/ssh/
makefile root:root 0600 "$tmp"/etc/ssh/ssh_host_ed25519_key <<EOF
XXX add file contents here
EOF
makefile root:root 0644 "$tmp"/etc/ssh/ssh_host_ed25519_key.pub <<EOF
XXX add file contents here
EOF
makefile root:root 0600 "$tmp"/etc/ssh/ssh_host_rsa_key <<EOF
XXX add file contents here
EOF
makefile root:root 0644 "$tmp"/etc/ssh/ssh_host_rsa_key.pub <<EOF
XXX add file contents here
EOF
makefile root:root 0600 "$tmp"/etc/ssh/ssh_host_dsa_key <<EOF
XXX add file contents here
EOF
makefile root:root 0644 "$tmp"/etc/ssh/ssh_host_dsa_key.pub <<EOF
XXX add file contents here
EOF
makefile root:root 0600 "$tmp"/etc/ssh/ssh_host_ecdsa_key <<EOF
XXX add file contents here
EOF
makefile root:root 0644 "$tmp"/etc/ssh/ssh_host_ecdsa_key.pub <<EOF
XXX add file contents here
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot

rc_add sshd default
rc_add ntpd default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

mkdir -p "$tmp"/home/load
chown 301:301 "$tmp"/home/load
chmod 0755 "$tmp"/home/load

mkdir "$tmp"/home/load/.ssh
chown 301:301 "$tmp"/home/load/.ssh
chmod 0700 "$tmp"/home/load/.ssh
makefile 301:301 0600 "$tmp"/home/load/.ssh/id_rsa.load <<EOF
XXX add file contents here
EOF
makefile 301:301 0600 "$tmp"/home/load/.ssh/id_rsa.load.pub <<EOF
XXX add file contents here
EOF
makefile 301:301 0600 "$tmp"/home/load/.ssh/authorized_keys <<EOF
XXX add file contents here after testing
EOF
makefile 301:301 0600 "$tmp"/home/load/.ssh/known_hosts <<EOF
XXX add file contents here after testing
EOF
makefile 301:301 0600 "$tmp"/home/load/.ssh/config <<EOF
XXX update file based on hosts used
Host load00
  TCPKeepAlive yes
  IdentityFile ~/.ssh/id_rsa.load
Host load01
  TCPKeepAlive yes
  IdentityFile ~/.ssh/id_rsa.load
Host server
  TCPKeepAlive yes
  IdentityFile ~/.ssh/id_rsa.load
EOF
# workaround for bug https://bugs.erlang.org/browse/ERL-446
# if your erlang installation is in prefix "/home/load/installed"
mkdir "$tmp"/home/load/installed
chown 301:301 "$tmp"/home/load/installed
mkdir "$tmp"/home/load/installed/lib
chown 301:301 "$tmp"/home/load/installed/lib
mkdir "$tmp"/home/load/installed/lib/erlang
chown 301:301 "$tmp"/home/load/installed/lib/erlang
mkdir "$tmp"/home/load/installed/lib/erlang/lib
chown 301:301 "$tmp"/home/load/installed/lib/erlang/lib
mkdir "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2
chown 301:301 "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2
mkdir "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv
chown 301:301 "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv
mkdir "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv/bin
chown 301:301 "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv/bin
makefile 301:301 0644 "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv/bin/cpu_sup <<EOF
placeholder file because of https://bugs.erlang.org/browse/ERL-446
EOF
makefile 301:301 0644 "$tmp"/home/load/installed/lib/erlang/lib/os_mon-2.4.2/priv/bin/memsup <<EOF
placeholder file because of https://bugs.erlang.org/browse/ERL-446
EOF

tar -c -C "$tmp" etc home | gzip -9n > $HOSTNAME.apkovl.tar.gz

