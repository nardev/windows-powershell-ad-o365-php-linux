    
############################ PARAMS ############################ 
Param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $user_id,
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $sifra,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $akcija,
    [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $ime,
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $prezime,
    [Parameter(Position=5, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $ad

)
    
    #students credentials
    $stupass = cat C:\_01_Ps\stupass | ConvertTo-SecureString
    $stucred = new-object -typename System.Management.Automation.PSCredential -argumentlist "Voyager3.students.local\administrator", $stupass

    #Faculty credentials
    $facultypass = cat C:\_01_Ps\facultypass | ConvertTo-SecureString
    $facultycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "faculty.local\administrator", $facultypass


    if ($ad -eq "faculty")
    {
        #nova sesija
        $sess = New-PSSession -ComputerName 10.1.0.32 -Credential $facultycred
        #$scname = .\facultyad.ps1
        Invoke-Command -Session $sess -ScriptBlock {.\Facultyad.ps1 -akcija $($args[0]) -user_id $($args[1]) -ime $($args[2]) -prezime $($args[3]) -sifra $($args[4]) } -ArgumentList $akcija, $user_id, $ime, $prezime, $sifra

        
    }
    else
    {
            
        #nova sesija
        $sess = New-PSSession -ComputerName 10.2.1.1 -Credential $stucred
        #$scname = .\Stuad.ps1
        Invoke-Command -Session $sess -ScriptBlock {.\Stuad.ps1 -akcija $($args[0]) -user_id $($args[1]) -ime $($args[2]) -prezime $($args[3]) -sifra $($args[4]) } -ArgumentList $akcija, $user_id, $ime, $prezime, $sifra

        
    }


   #Invoke-Command -Session $sess -ScriptBlock {.\Stuad.ps1 -akcija $($args[0]) -user_id $($args[1]) -ime $($args[2]) -prezime $($args[3]) -sifra $($args[4]) } -ArgumentList $akcija, $user_id, $ime, $prezime, $sifra

   #-ArgumentList [0] $akcija, [1] $user_id, [2] $ime, [3] $prezime, [4] $sifra


#   Invoke-Command -Session $students -ScriptBlock {ls; echo "-----" ; .\Stuad.ps1 -user_id $user_id -ime $ime -prezime $prezime -sifra $sifra -akcija $akcija}
   #Write-Host $cmnd

       #Get-PSSession 
       Get-PSSession | Remove-PSSession
      echo "--------------"
       Get-PSSession 

