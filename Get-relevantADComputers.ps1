foreach($a in $domains)

{

filter Relevant_ComputerAccounts

{

    if($_.Enabled -eq $true -and $_.LastLogonDate -gt $(get-date).AddDays(-180) -and ($_.OperatingSystem -like "*Windows Server*" -or $_.OperatingSystem -like "Windows Server*" )-and ($_.ServicePrincipalName -join "|") -notlike "*MSClusterVirtualServer*")

    {

    $_

    }

}

$adcomputers = get-adcomputer -filter * -Properties Enabled,Name,CanonicalName,Description,Created,DistinguishedName,LastLogonDate,MemberOf,OperatingSystem,ServicePrincipalName,SID,whenChanged,IPv4Address,IPv6Address -Server $a | select Enabled, CanonicalName,Description,Created,DistinguishedName,LastLogonDate,MemberOf,Name,OperatingSystem,ServicePrincipalName,SID,whenChanged,IPv4Address,IPv6Address | Relevant_ComputerAccounts

    foreach($adcomputer in $adcomputers)

    {

    $properties = [ordered]@{

                level = ($adcomputer.DistinguishedName.Split([string[]]@('OU='),[StringSplitOptions]"None")).Count - 1

                Name=$adcomputer.Name

                CanonicalName =$adcomputer.CanonicalName

                Description=$adcomputer.Description

                Created=$adcomputer.Created

                DistinguishedName=$adcomputer.DistinguishedName

                LastLogonDate=$adcomputer.LastLogonDate

                MemberOf=($adcomputer.MemberOf | % {get-adgroup $_ -Server $a | select -ExpandProperty Name} ) -join ", "

                OperatingSystem=$adcomputer.OperatingSystem

                ServicePrincipalNames=($adcomputer.ServicePrincipalNames | % {$_} ) -join ", "

                SID=$adcomputer.SID

                whenChanged=$adcomputer.whenChanged

                IPv4Address=$adcomputer.IPv4Address

                IPv6Address=$adcomputer.IPv6Address

                scandate = $scandate

                }

    $object =New-Object -Property $properties -TypeName PSObject

    $adcomputersreport += $object

    }

}