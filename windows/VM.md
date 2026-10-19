```
virsh -c qemu:///system start win11
```

win11 - username: rpadmin, find pwd in 1password


# Get the cert files into the container
1. VM host: Create an iso file, that is then mounted as the D: drive in windows.
   The iso also contains this VM.md file (D:\VM.md). It's a copy, so rerun these commands after editing VM.md to update it in Windows.
```
cd ~/containers
genisoimage -o ~/iso/windows-certs.iso -J -r windows/certs/windows.lab.pfx ~/.ssl/rootCA.pem windows/VM.md
virsh -c qemu:///system change-media win11 sdb ~/iso/windows-certs.iso --update
```

2. Windows Powershell as admin: Set up the certificate 
```
# Import the certificate and private key into the computer's certificate store
$pw   = ConvertTo-SecureString 'pass' -AsPlainText -Force
$cert = Import-PfxCertificate -FilePath D:\windows.lab.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $pw

# Tell RDP to use it
$ts = Get-CimInstance -Namespace root\cimv2\TerminalServices -ClassName Win32_TSGeneralSetting -Filter "TerminalName='RDP-tcp'"
Set-CimInstance -InputObject $ts -Property @{SSLCertificateSHA1Hash = $cert.Thumbprint}
```

3. Windows: Give the RDP service read access to the private key (otherwise RDP silently keeps its self-signed cert)
   - Run `certlm.msc` and go to Personal → Certificates
   - Right-click **windows.lab** → All Tasks → Manage Private Keys
   - Add **NETWORK SERVICE** with **Read** permission

4. Windows Powershell as admin: Restart RDP and verify (do this from the VNC console, it drops RDP sessions)
```
Restart-Service TermService -Force

# These two should print the same thumbprint
(Get-CimInstance -Namespace root\cimv2\TerminalServices -ClassName Win32_TSGeneralSetting -Filter "TerminalName='RDP-tcp'").SSLCertificateSHA1Hash
$cert.Thumbprint
```

5. VM host: Unmount the drive
```
virsh -c qemu:///system change-media win11 sdb --eject
```
