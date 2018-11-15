@echo off



SET /p uploadFlag= Want to upload to gitHub(Y/N):

IF /I "%uploadFlag%"=="N" (
	Exit /B
)

CALL IF /I "%uploadFlag%"=="Y" (
	SET /p repoPath= Please enter your local repository path:
	CALL chdir /d %repoPath%
    IF not exist %repoPath%\ConfigurationBackups ( 
	mkdir ConfigurationBackups 
	)
	DEL %repoPath%\ConfigurationBackups\* /s /q
	CALL xcopy D:\APIC\Novum\CLI-2018\20180730\125312\Products\* %repoPath%\ConfigurationBackups\* /e /i
	
	echo "*********************"
	echo "Successfully uploaded to GitHub"
	echo "*********************"
)

SET /p flag= Recheck:
