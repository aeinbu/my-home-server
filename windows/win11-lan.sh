#!/bin/bash
set -euo pipefail

# Move the win11 VM from libvirt's NAT network onto the LAN using macvtap.
# The VM shares enp3s0f1 with my-macvlan-network, so like the containers it is
# reachable from other machines on the LAN, but not from this host itself.
#
# Safe to run over ssh: no prompts or sudo (needs the libvirt group), and the
# host's own network is not touched, so the connection does not drop.
#   ssh arjan@192.168.1.222 containers/win11-lan.sh
# or, without copying the script to the host:
#   ssh arjan@192.168.1.222 bash -s < win11-lan.sh

VM=win11
PARENT=enp3s0f1
VM_IP=192.168.1.137
GATEWAY=192.168.1.1
VIRSH="virsh -c qemu:///system"

state=$($VIRSH domstate "$VM")
if [ "$state" != "shut off" ]; then
  echo "$VM is '$state'. Shut it down first: $VIRSH shutdown $VM"
  exit 1
fi

if $VIRSH dumpxml --inactive "$VM" | grep -q "<interface type='direct'>"; then
  echo "$VM is already on macvtap, nothing to do"
  exit 0
fi

backup=~/$VM-$(date +%Y%m%d-%H%M%S).xml
$VIRSH dumpxml --inactive "$VM" > "$backup"
echo "Backed up VM definition to $backup (restore with: $VIRSH define $backup)"

virt-xml -c qemu:///system "$VM" --edit \
  --network type=direct,source=$PARENT,source.mode=bridge

mac=$($VIRSH domiflist "$VM" | awk '/direct/ {print $5}')

cat <<EOF

$VM now uses macvtap on $PARENT (MAC $mac).

Next steps:
1. Start the VM:  $VIRSH start $VM
   (console: virt-manager, or virt-manager -c qemu+ssh://arjan@192.168.1.222/system from another machine)

2. In Windows, open an admin PowerShell and set the static IP:
     netsh interface ipv4 set address name="Ethernet" static $VM_IP 255.255.255.0 $GATEWAY
     netsh interface ipv4 set dnsservers name="Ethernet" static $GATEWAY primary
   (check the adapter name with: Get-NetAdapter)

3. Enable Remote Desktop: Settings > System > Remote Desktop (Windows 11 Pro only).

4. From another machine, connect with RDP to $VM_IP (or windows.lab once DNS is updated).
EOF
