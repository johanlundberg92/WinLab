$labName = "JLAB"

New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    #'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:DnsServer1'= '10.0.0.2'
    'Add-LabMachineDefinition:DomainName'= 'ACME.local'
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2019 Standard (Desktop Experience)'
    'Add-LabMachineDefinition:UserLocale'= 'en-SE'
}

# Network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace "10.0.0.0/24"

# Domain definitions
Add-LabDomainDefinition -Name "ACME.local" -AdminUser "jl" -AdminPassword "Tjenna123!"

# Credentials
Set-LabInstallationCredential -Username "jl" -Password "Tjenna123!"

# Machines
# == # First DC
$roles = Get-LabMachineRoleDefinition -Role RootDC
Add-LabMachineDefinition -Name DC01 -OperatingSystem "Windows Server 2019 Standard (Desktop Experience)" -IpAddress 10.0.0.2 -Roles $roles -DomainName "ACME.local"

# == # Root CA
$roles = Get-LabMachineRoleDefinition -Role CaRoot
Add-LabMachineDefinition -Name ROOTCA01 -IpAddress 10.0.0.3 -Roles $roles -IsDomainJoined

# == # SubCA
$roles = Get-LabMachineRoleDefinition -Role CaSubordinate
Add-LabMachineDefinition -Name SUBCA01 -IpAddress 10.0.0.4 -Roles $roles -IsDomainJoined

# == # Misc server
Add-LabMachineDefinition -Name "SRV01" -IpAddress 10.0.0.5 -IsDomainJoined

#Install-Lab

Install-Lab -BaseImages -NetworkSwitches -VMs
Install-Lab -Domains
Install-Lab -CA
Install-Lab -StartRemainingMachines

Show-LabDeploymentSummary -Detailed