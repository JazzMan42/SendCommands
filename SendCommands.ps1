#requires -version 2
<#
.SYNOPSIS
  <Overview of script>
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None>
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
  <Example explanation goes here>
#>

#-----------------------------------------------------------[Bindings]------------------------------------------------------------
<# NON FUCTION EXAMPLE TEMPLATE, COPY FUNCTION BELOW AND MOVE OUT OF COMMENT BLOCK < # # >

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$CsvFilePath
    )

#>

    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [String]$ComputerNames,
        [String]$Path,
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath
    )

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'Continue'

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here
#ex $global:globalvar1
#ex $global:globalvar2
#ex $global:globalvar3

#starting variables

#set the computers to hit
[System.Collections.ArrayList]$computers = New-Object System.Collections.ArrayList($null)



#-----------------------------------------------------------[Functions]------------------------------------------------------------

<# EXAMPLE FUNCTION TEMPLATE, COPY FUNCTION BELOW AND MOVE OUT OF COMMENT BLOCK < # # >
Function <FunctionName> {
   Param(
        [int]$GroupName,
        [double]$two,
        [string]$three,
        [int]$four
        )
  Try {
    <code goes here>
  }
  Catch {
    Break
  }
}
#>

function main([string[]]$computers, $Script){

[System.Collections.ArrayList]$completeHostNames = New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$uncompleteableHosts = New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$reattemptableHosts= New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$adIssueTotal= New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$accessIssueTotal= New-Object System.Collections.ArrayList($null)

$runCount = 0;

    do{

if(!$reattemptableHosts){
    $reattemptableHosts.AddRange($computers);
}

[System.Collections.ArrayList]$accessDenied= New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$adIssueDNE= New-Object System.Collections.ArrayList($null)
[System.Collections.ArrayList]$computerOffline= New-Object System.Collections.ArrayList($null)
#[System.Collections.ArrayList]$failedToCopyFile= New-Object System.Collections.ArrayList($null)

[int]$offlineCount = 0;
[int]$onlineCount = 0;
[int]$current = 0;

$runCount++;

$reattemptableHosts | %{
    $current++;
    $NSResult = [string](NSlookup $_) 2>$nul
   
            If (!$NSResult.contains("Name:    "+[string]$_) ) 
            {
                $offlineCount++; 
                $adIssueDNE.add($_) > $Nul;
                echo "[$current of $($reattemptableHosts.count)] Host does not exist in domain: $_";
                return;
            }
                
            $PingResult =[String](ping -w 100 -n 1 -a $_)   

            #machine is offline
            If($PingResult.Contains("100% loss") )   {
 
                $offlineCount++; 
                $computerOffline.add($_) > $Nul;
                echo "[$current of $($reattemptableHosts.count)] Computer is Offline: $_"
                return;
            }
            
            #run the commands
            If ($PingResult.Contains("0% loss")){
                    
                psexec \\$_ -s -d -f -c $scriptpath
                $onlineCount++; 
                $completeHostNames.add($_) > $Nul;
                echo "[$current of $($reattemptableHosts.count)] Success: Script executed on $_!"
                return;
            }   
    }
	
    $folderName = $PSScriptRoot + "\" +$($($($scriptpath.Split('\'))[-1]) -split '.')[0] + ""+ $(Get-Date -format M.d.yyyy)

    #make the folder if it does not exist
	if(!$(test-path $folderName)){
		mkdir $folderName
	}

    $reattemptableHosts = $reattemptableHosts | select -Unique

    $canNotBeCompleted = 0
    $couldBeCompleted = 0
    $actualCompleted = 0

    $canNotBeCompleted = ($($adIssueDNE.Count)+$($accessDenied.count))
    $couldBeCompleted = $($reattemptableHosts.count)-$canNotBeCompleted
    $actualCompleted = $($completeHostNames.count)-$canNotBeCompleted

    $uncompleteableHosts.AddRange($adIssueDNE)
    $uncompleteableHosts.AddRange($accessDenied)
    $adIssueTotal.AddRange($adIssueDNE)
    $accessIssueTotal.AddRange($accessDenied)

    $adIssueDNE | %{$reattemptableHosts.Remove($_)}
    $accessDenied | %{$reattemptableHosts.Remove($_)}

    $completeHostNames | %{$reattemptableHosts.Remove($_)}

    echo "------------------------------------------"
    Echo "Run #$($runCount) : $(get-date)"
    echo "----------- Overall Variables ------------"
    echo "Total computers $($computers.count)"
    echo "Total reattemetable: $($reattemptableHosts.Count)"
    echo "Total unreattemtable: $($uncompleteableHosts.Count)"
    echo "Total access denied: $($accessIssueTotal.Count)"
    echo "Total computer not in ad: $($adIssueTotal.Count)"
    echo "--------- Current Run Variables ---------- "
    echo "Total completed: $($completeHostNames.count)"
    echo "Total access denied: $($accessDenied.count)"
    echo "Total does not exist in AD: $($adIssueDNE.Count)"
    echo "Total offline : $($computerOffline.count)"
    echo "Total copy file failure: $($failedToCopyFile.Count)"
    echo "Total uncompleteable: $($canNotBeCompleted.count)"
    echo "------------------------------------------"

    $reattemptableHosts > "$folderName\reattemptableHosts.log"
    $uncompleteableHosts >> "$folderName\uncompleteableHosts.log"
    $accessIssueTotal >> "$folderName\accessIssueTotal.log"
    $adIssueTotal >> "$folderName\adIssueTotal.log"
    $completeHostNames >> "$folderName\completeHostNames.log"
    $accessDenied >> "$folderName\accessDenied.log"
    $adIssueDNE >> "$folderName\adIssueDNE.log"
    $computerOffline > "$folderName\computerOffline.log"
    #$failedToCopyFile >> "$PSScriptRoot\failedToCopyFile.log"
    $canNotBeCompleted >> "$folderName\canNotBeCompleted.log"

    $rnd = Get-Random -Minimum 60 -Maximum 300
    echo "Sleep for $($rnd/60) minutes"
    start-sleep -Seconds $rnd

}
while($couldBeCompleted -ne $actualCompleted);


}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here
# Ex Function([int]var1, [double]var2, [string]var3, [int]var4)

if(!$ComputerNames -and !$path){
    write-host "Please use -computernames or -path to specify a list of computers or path to a file with a list of computers"
    return   
}

if($Path){    
    if(!(test-path $path)){
        write-host "path does not exit please try again"
    }
    $computers.AddRange([string[]]$(gc $path))
}

if($ComputerNames){
    $computers.AddRange([string[]]$($ComputerNames -split ','))
}

#make sure you dont hit any duplicates
if($computers.count -gt 1){

    $computers = $($computers | select -Unique)

}

main $computers $ScriptPath