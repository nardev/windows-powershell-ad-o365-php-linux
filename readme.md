Connect O365 Active Directory with PHP application.

##### Sync all your passwords in one place.


##### This scripts need HUGE cleanup and variables to be translated.



This is actually just copy from running server.


Idea is that you don't need expensive Forefront Identity Manager MIcrosoft aka FIM in order to sync all your passwords from one machine.


I managed to make it much more simpler. Install SSH server on your ActiveDirectory machine. Limit the resources for SSH server so that you are safe, make tunneling or some other way to protect your Linux PHP Server --> ActiveDirectory server communication and save n*1000$ and controll everything from your ORM/CRM etc... :D


If you are using Laravel, it's quite elegant to make ssh connection, execute command, get the response and make queue for propagating/changing passwords in another systems.


In my particular case this was something like 5-6 different systems.

Also we had two different ADs in two different machines so it was bit unusual how to connect those two.. but who looks for a way finds it :P who looks for an excuse finds it too.


p.s. script files were designed by me but mostly coded by my friend.
And we know it's is not ready to be PNP

:D
