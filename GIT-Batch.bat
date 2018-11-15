@echo off


SET backUpDir=%cd%

CALL set currentDate=%date:~10,4%%date:~4,2%%date:~7,2%


SET /p uploadFlag= Want to upload to gitHub(Y/N):

IF /I "%uploadFlag%"=="N" (
	Exit /B
)

CALL IF /I "%uploadFlag%"=="Y" (
	SET /p repoCheck= Do you already have a local repository of GitHub (Y/N):
	CALL IF /I "%repoCheck%"=="N" (
		SET /p gitServer= Please enter the gitHub location which you want to clone:
		SET /p localRepo= Please enter the local directory path where you want to create your local repository:
		cd /d %localRepo%
		git clone %gitServer%
	)
	SET /p repoPath= Please enter your local repository absolute path:
	SET /p gitUserName= Please enter your gitHub username:
	chdir /d %repoPath%
	git config --global user.name "%gitUserName%"
	git fetch --all
	git pull
	IF not exist %repoPath%\ConfigurationBackups ( 
	mkdir ConfigurationBackups 
	)
	DEL %repoPath%\ConfigurationBackups\* /s /q
	xcopy %backUpDir%\20180730\144451\* %repoPath%\ConfigurationBackups\* /e /i
	git config --local core.autocrlf false
	git add *
	git commit -m "Last updated on %currentDate% at 152831 by %gitUserName%"
	git push
	echo "*********************"
	echo "Successfully uploaded to GitHub"
	echo "*********************"
)