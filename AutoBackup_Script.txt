@echo off

CALL apic logout --server "mgmt.test1manager.apico2r53.co.uk"

SET /p userId= APIM UserId:
SET /p password= Password:

CALL apic login --username "%userId%" --password "Temp12$$" --server "mgmt.test1manager.apico2r53.co.uk" --realm provider/default-idp-2

SET backUpDir=%cd%

CALL set currentDate=%date:~10,4%%date:~4,2%%date:~7,2%
CALL set currentTimeStamp=%time:~0,2%%time:~3,2%%time:~6,2%
CALL md %currentDate%\%currentTimeStamp%

FOR /F "tokens=1 delims= " %%I IN ( 'CALL apic draft-products:list-all -o o2apic -s "mgmt.test1manager.apico2r53.co.uk" ')  DO CALL apic draft-products:get --format yaml -o o2apic -s "mgmt.test1manager.apico2r53.co.uk" --output %currentDate%\%currentTimeStamp% %%I

echo "*********************"
echo "Products backup completed"
echo "*********************"

FOR /F "tokens=1 delims= " %%I IN ( 'CALL apic draft-apis:list-all -o o2apic -s "mgmt.test1manager.apico2r53.co.uk" ')  DO (
     SETLOCAL ENABLEDELAYEDEXPANSION
     SET "apiName=%%I"
     SET "apiNameInProduct=!apiName::=_!"
	 DEL %currentDate%\%currentTimeStamp%\!apiNameInProduct!.yaml
	 CALL apic draft-apis:get --format yaml -o o2apic -s "mgmt.test1manager.apico2r53.co.uk" --output %currentDate%\%currentTimeStamp% %%I
)

echo "*********************"
echo "APIs backup completed"
echo "*********************"
CALL apic logout --server "mgmt.test1manager.apico2r53.co.uk"

SET /p uploadFlag= Want to upload to gitHub(Y/N):

IF /I "%uploadFlag%"=="N" (
	Exit /B
)

CALL IF /I "%uploadFlag%"=="Y" (
	CALL SET /p repoPath= Please enter your local repository path:
	CALL SET /p gitUserName= Please enter your gitHub username:
	call chdir /d %repoPath%
	CALL git config --global user.name "%gitUserName%"
	CALL git fetch --all
	CALL git pull
	DEL %repoPath%\ConfigurationBackups\* /s /q
	CALL xcopy %backUpDir%\%currentDate%\%currentTimeStamp%\* %repoPath%\ConfigurationBackups\* /e /i
	CALL git config --local core.autocrlf false
	CALL git add *
	CALL git commit -m "Last updated on %currentDate% at %currentTimeStamp% by %gitUserName%"
	CALL git push
	echo "*********************"
	echo "Successfully uploaded to GitHub"
	echo "*********************"
)

