<# This script will produce the difference between two files/folder permissions #>

$path1 = "C:\\users\karar\documents\projects\PermDiff\test1.txt"
$path2 = "C:\\users\karar\documents\projects\PermDiff\test2.txt"


<# This function will provide output to a permission structure object which will be used for comparison #>
function GetPermissionDataStructure {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $AccessObject
    )

    # $hashtable = {"User": { "TypeOfPerm": "PermVal", "TypeOfPerm": "PermVal" }}
    $hashTable = @{}

    foreach ($accessElement in $AccessObject) {
        $user = $accessElement.IdentityReference.Value
        $typeOfPerm = $accessElement.FileSystemRights
        $permVal = $accessElement.AccessControlType

        $hashTable.Add($user, @{$typeOfPerm = $permVal })
    }

    return $hashTable
}

function DifferPermissionsAndOutput() {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $permissionDataStruct1,

        [Parameter(Mandatory = $true, Position = 1)]
        $permissionDataStruct2
    )
    
    foreach ($user in $permissionDataStruct1.Keys) {
        if (!$permissionDataStruct2.ContainsKey($user)) {
            Write-Host "User:" $user "(not found in 2nd location)" 
            Write-Host "`n"
        }
        else {
            # if the key is found in second, then please check the permissions.
            $permHashTableOfUserOfPath1 = $permissionDataStruct1[$user]
            $permHashTableOfUserOfPath2 = $permissionDataStruct2[$user]
            
            foreach ($perm in $permHashTableOfUserOfPath1.Keys) {
                if (!$permHashTableOfUserOfPath2.ContainsKey($perm)) {
                    Write-Host "User:" $user 
                    Write-Host "Permission:" $perm "(is missing from 2nd location)"
                    Write-Host "`n"
                }
                elseif (! ($permHashTableOfUserOfPath1[$perm] -eq $permHashTableOfUserOfPath2[$perm])) {
                    Write-Host "User:" $user 
                    Write-Host "Permission:" $perm " = " $permHashTableOfUserOfPath1[$perm] "(mismatch with 2nd)"
                    Write-Host "`n"
                }
            }
        }
    }

}

$access1 = (Get-Acl $path1).Access
$access2 = (Get-Acl $path2).Access

$permissionDataStruct1 = GetPermissionDataStructure $access1
$permissionDataStruct2 = GetPermissionDataStructure $access2

Write-Host "------------------------------------------------"
Write-Host "`n1st location:" $path1 "`n2nd location:" $path2 "`n"
DifferPermissionsAndOutput $permissionDataStruct1 $permissionDataStruct2

Write-Host "------------------------------------------------"
Write-Host "`n1st location:" $path2 "`n2nd location:" $path1 "`n"
DifferPermissionsAndOutput $permissionDataStruct2 $permissionDataStruct1

Write-Host "------------------------------------------------"