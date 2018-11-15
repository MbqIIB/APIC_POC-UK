@echo off

ECHO Please enter your APIConnect Credentials:

SET /p userId= UserId:
SET /p password= Password:
SET /p server= Server:
SET /p realm= Realm:
SET /p organization= Organization:

echo terminating the earlier session with above Credentials if there is any

CALL apic logout --server "%server%"

CALL apic login --username "%userId%" --password "%password%" --server "%server%" --realm %realm%

SET backUpDir=%cd%

CALL set currentDate=%date:~10,4%%date:~4,2%%date:~7,2%
CALL set currentTimeStamp=%time:~0,2%%time:~3,2%%time:~6,2%
CALL md %currentDate%\%currentTimeStamp%\Products

FOR /F "tokens=1 delims= " %%I IN ( 'CALL apic draft-products:list-all -o %organization% -s "%server%" ')  DO CALL apic draft-products:get --format yaml -o %organization% -s "%server%" --output %currentDate%\%currentTimeStamp%\Products %%I

echo "*********************"
echo "Products backup completed"
echo "*********************"
CALL md %currentDate%\%currentTimeStamp%\APIs

FOR /F "tokens=1 delims= " %%I IN ( 'CALL apic draft-apis:list-all -o %organization% -s "%server%" ')  DO (
     SETLOCAL ENABLEDELAYEDEXPANSION
     SET "apiName=%%I"
     SET "apiNameInProduct=!apiName::=_!"
	 DEL %currentDate%\%currentTimeStamp%\Products\!apiNameInProduct!.yaml
	 CALL apic draft-apis:get --format yaml -o %organization% -s "%server%" --output %currentDate%\%currentTimeStamp%\APIs %%I
)

echo "*********************"
echo "APIs backup completed"
echo "*********************"
CALL apic logout --server "%server%"

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
	IF not exist %repoPath%\ConfigurationBackups ( 
	mkdir ConfigurationBackups 
	)
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

