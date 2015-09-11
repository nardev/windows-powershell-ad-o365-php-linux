##########################################################################################################
###                           Commands
##########################################################################################################
<#
  Provjera postoji li user                   
        .\stuADapi.ps1 -akcija p -user_id "test.p2" -ad faculty                

  Brisanje korisnika                   
        .\stuADapi.ps1 -akcija d -user_id "test.p2" -ad faculty

  Kreiranje korisnika  
  .\stuADapi.ps1 -akcija c -user_id "test.p2" -sifra userP2014 -ime Test -prezime Prezime3 -ad faculty                

  Update korisnika - ista komanda kao kreiranje, ako korisnik postoji obaviti ce se update passworda
  .\stuADapi.ps1 -akcija c -user_id "test.p2" -sifra userP2014 -ime Test -prezime Prezime3 -ad faculty                


  Komande uzete preko studentskog apija isto je za samu skriptu s tim sto se mijenja ime skripte



  #>
##########################################################################################################






############################ PARAMS ############################ 
Param(
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $sifra,
    [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $akcija,

    ####################   AD PARAMS   ############################
    [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $ime,
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $prezime,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $user_id,
    [Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
    [string] $telefon

)

<###############################Preferences###############################>

$ErrorActionPreference= 'silentlycontinue'
$comments = $true;
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

##########################################################################################################
##########################################################################################################
##########################################################################################################







############################################################################################################
###########                          AD FUNKCIJE
############################################################################################################


function konektujAD ()
{
    # Importuj modul za AD 
    Import-Module ActiveDirectory

    #setujmo lokaciju AD, pa direktno grupa u koju cemo dodavati korisnike
    Set-Location "AD:\"
    #Set-Location "AD:\ou=space_users,dc=ssst,dc=local" -PassThru:$false
}



#check if user exist returns 1 if does retrusn 0 if does not
function getADuser ($user_id)
{
    if(dsquery user -samid $user_id) 
    {
       #Write-Host -ForegroundColor DarkGreen "User found"
        return 1
    }
    #Write-Host -ForegroundColor Red "User not found!"
    return 0
}




# novi AD korisnik
function NoviAduser ($ime, $prezime, $sifra ,$user_id)
{
   
   $upn = $user_id + "@faculty.local"
    #dodaj novog korisnika
    New-ADUser -Name ($ime  + " " +$prezime) -UserPrincipalName $upn -GivenName $ime -Surname $prezime -SamAccountName $user_id -DisplayName ($ime  + " " +$prezime) -AccountPassword (ConvertTo-SecureString -AsPlainText $sifra -Force) -Path "OU=SpaceAccounts,DC=faculty,DC=local"
    
    $user = getADuser $user_id
    #"user find: " + $user
    
    if ($user -eq 0)
    {
        Ispis "### User not added! It si not found in AD" -boja Red 
        Set-Location C: -PassThru:$false
        return 0
     }
    
    Set-ADUser -Identity $user_id -PasswordNeverExpires $true
    Enable-ADAccount -Identity $user_id
    #Move-ADObject $user -TargetPath "OU=SpaceAccounts,DC=students,DC=local"
    #Add-ADGroupMember -Identity Faculty -Members $user_id
    Set-Location C: -PassThru:$false
    return 1
}


#user password reset

function userResetPass ($user_id, $sifra)
{
    #Write-Host -ForegroundColor Green ($sifra+" - "+$user_id)
    $user = Get-ADUser -Filter "SamAccountName -like '*$User_id*'" -Properties *
    #$user
    Set-ADAccountPassword $user_id -NewPassword (ConvertTo-SecureString -AsPlainText $sifra -Force) -Reset -ErrorVariable passwordError
    if ($passwordError)
    {
        return 1
    }

    #check if user is locked out
    if((Get-Aduser $user_id -Properties LockedOut).LockedOut) {
        #unlock
        Unlock-ADAccount $user
    }else{
     #   Write-Host -ForegroundColor Green "User is not locked"
    
    }
    return 0
}


#UserDelete
function deleteKorisnika ($user_id)
{
    Remove-ADUser -Identity $user_id -Confirm:$false
    #return !getADuser $user_id
}

function ad_out ()
{
    # povratak iz AD space-a   
    Set-Location C: -PassThru:$false
}

##***************************************************************************************************#####
##***************************************************************************************************#####
##***************************************************************************************************#####




                #################             AD  Instanca             ################

                ### run konekcija AD
                konektujAD
                ##----------------------------------------------------------------------



                switch ($akcija)
                {
        
                    'c'{
                            ###


                            if (getADuser $user_id) 
                            {
                                

                                Ispis "Green" "User nadjen"

                                #korisnik podtoji promijeni password
                                $passwordError = userResetPass $user_id $sifra
        
                                if($passwordError -ne 1){
                             
                                            Ispis "AD Korisnik - passsword Changed!"
                       
                                            # povratak iz AD space-a 
                                            ad_out  
                                            return 1

                                    }else{
                             
                                            Ispis "AD promijena password error" -boja Red
                             
                                            # povratak iz AD space-a 
                                            ad_out
                                            return 0
                             
                                        }
    




                            }else{
                            
                                #Ispis Green "Dodaj korisnika "
                                NoviAduser $ime $prezime $sifra $user_id 
                                
                                if (getADuser $user_id){
                                    ad_out
                                    Ispis "AD User added"
                                    return 1
                                
                                } else {
                                    ad_out
                                    Ispis "AD User not added" -boja Red
                                    return 0                                    
                                
                                }

                            }

                            # povratak iz AD space-a   
                            ad_out
                    
                            ###                        
                        }

                    'd'{
            
                        
                         deleteKorisnika $user_id
                         $user = getADuser $user_id
                         ad_out
                         if ($user -eq 0)
                         {
                             return 1
                         }else{
                            return 0
                         
                         }


         
                     }
                  
                    'p'{ 
                        
                        $korisnik = getADuser $user_id

                            if ($korisnik -eq 1)
                            {
                                ad_out
                                Ispis "Korisnik nadjen"
                                return 1
                            }
                            else{
                                ad_out
                                Ispis "Korisnik nije nadjen"
                                return 0
                        
                            }
                    
                    
                        }

                    Default {return "No action specified"}
                }




               