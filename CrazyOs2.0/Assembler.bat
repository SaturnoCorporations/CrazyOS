echo off
cls
set a=1
set back=1
set cor=0
set NUM1=1398113
set NUM2=13
set result=
mode con cols=15 lines=10
:LOL
	color 0%cor%
	set /a result=%NUM1%/%NUM2%
	set /a NUM1=%result%/%NUM2%
	cecho %result%
	start /wait /min timeout 0.1 /nobreak
	cls
	if %back% equ 9 goto Change
	set /a back=%back%+%a%
	set /a cor=%cor%+%a%
	goto LOL
	
:Change 
	set back=1
	set cor=0
	goto LOL