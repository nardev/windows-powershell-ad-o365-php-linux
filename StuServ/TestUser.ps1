Function Test-ADAuthentication { 
    param($userlogin,$userpassword) 
    (new-object directoryservices.directoryentry "",$userlogin,$userpassword).psbase.name -ne $null 
} 
     

cls 
#Prompting the user to enter the variables 
#Reads the User login 
$login = Read-Host 'What is the user login?' 
#Reads the User password 
$password = Read-Host 'What is the user password?' 
if (Test-ADAuthentication $login $password) 
{ 
    Write-Host "Valid credentials" -ForegroundColor Green  
} 
else 
{ 
    Write-Host "Invalid credentials" -ForegroundColor Red  
} 
$wait = Read-Host
