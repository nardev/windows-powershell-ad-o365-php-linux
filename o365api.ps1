<#

commands: 
provjera korisnika (akcija p, vraca 1 ili 0)
    
    .\o365api.ps1 -akcija p -korisnik [email]


kreiraj/update korisnika (akcija c, vraca 1 ili 0, ako korisnik postoji vrsi se update ako ne kreira se

    .\o365api.ps1 -akcija c -korisnik [email] -name [displayname] -sifra [password]


Obrisi korisnika
        .\o365api.ps1 -akcija d -korisnik [email] -name [displayname] -sifra [password]

#>

############################ PARAMS ############################ 
Param(
	[Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $korisnik,
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $sifra,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $akcija,
    [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $name
)



<###############################Preferences###############################>

$ErrorActionPreference= 'silentlycontinue'
$comments = $false;
$Error.Clear()


<#############################  End Preferences  ##########################>


##########################################################################################################
###                           Helper functions
##########################################################################################################
function Ispis 
{
    param($poruka, $boja = "Green")
    
    if ($comments)
    {
        Write-Host -ForegroundColor $boja $poruka
               
    }
}



<#############################  End Helper functions  ##########################>

function ProvjeraKorisnika ($k){
    
  
  $user = Get-MsolUser -UserPrincipalName $k
  if ($user.UserPrincipalName -eq $k)
    {
        Ispis "`tInfo: User postoji"
        return 1 
                                   
    }
    
    Ispis "`tInfo: User NE postoji" -boja Red
    return 0


  }

function 0365_kreiraj ($korisnik, $name, $sifra){
    
    #password needs to be of minimum 9 chars 
    
    $user = New-MsolUser -UserPrincipalName $korisnik -DisplayName "$name" -StrongPasswordRequired $false -Password $sifra -LicenseAssignment ssstedu:EXCHANGESTANDARD_STUDENT -UsageLocation BA


    if($user){
        Ispis "Korisnik $korisnik, ime: $name, password: $sifra"
        Set-MsolUser -UserPrincipalName $korisnik -StrongPasswordRequired $false
        Set-MsolUserPassword -UserPrincipalName $korisnik -NewPassword $sifra -ForceChangePassword $false
        return 1

    }else{
    
        Write-Host "Korisnik nije kreiran"
        return 0
    }

}


function 0365_update ($korisnik, $name, $sifra)
{
    
    Set-MsolUser -UserPrincipalName $korisnik -DisplayName $name -StrongPasswordRequired $false 
    $password  = Set-MsolUserPassword -UserPrincipalName $korisnik  -NewPassword  $sifra -ForceChangePassword $false
    Ispis "$password - $name" -boja Magenta
    Set-MsolUser -UserPrincipalName $korisnik -StrongPasswordRequired $false

    if ($password -eq $sifra)
    {
        return 1
    }else{
        return 0
    }

}


function O365_delete ($korisnik)
{
     if(ProvjeraKorisnika $korisnik){
       
        #Delete korisnika - soft delete
        Remove-MsolUser -UserPrincipalName $korisnik -Force
                
      }

      #check again for success ???
      if(ProvjeraKorisnika $korisnik){
            Ispis "Korisnik nije obrisan!!!" -boja yellow
            return 0
        }
        else
        {
            Ispis "Korisnik uspjesno obrisan!!!"
            return 1
            
        }
}



######################################### O365 settings ############################################################

$ConError = $null

$o365sifra = cat o365pass | ConvertTo-SecureString
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "<EMAIL>",$o365sifra
$connection = Connect-MsolService -Credential $mycred -ErrorVariable ConError


#provjeri konekciju ako nema konekcije vrati kod 0
 
if ($Error.count -eq 0)
    {
        Ispis "Konekcija O365 ok!"
        $connection = 1
    }
    else
    {
            
        Ispis "Konekcija O365 ERROR!" -boja Red
        $connection = 0
        return
                
    }



    switch ($akcija)
    {
        
        'c'{
        
                $p = ProvjeraKorisnika $korisnik
                if ($p -eq 1){
                    Ispis "Korisnik postoji" -boja Red
                    $user = 0365_update $korisnik $name $sifra     
                    #dodavanje korisnika faila pa vracamo 0         
                    
                    if ($user -eq 1)
                    {
                        Ispis "Korisnik update"
                        return 1
                    }                     
                        return 0
                }

                #ako provjera faila 
                if ($p -eq 0)
                {
                    
                    $user = 0365_kreiraj $korisnik $name $sifra
                    if ($user -eq 1)
                    {
                        Ispis "korisnik Kreiran"
                        return 1
                    }

                    return 0
                }
        
            }

         'd'
         {
            
            return O365_delete $korisnik
         
         }
         
         
         'p'{ return ProvjeraKorisnika $korisnik }

        Default {return "No action specified"}
    }



