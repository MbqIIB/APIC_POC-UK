@echo off

SET /p userId= UserId:
SET /p password= Password:

CALL apic login --username "%userId%" --password "%password%" --server "mgmt.test1manager.apico2r53.co.uk" --realm provider/default-idp-2

SET /p importFlag= Want to import from gitHub(Y/N):

CALL IF /I "%importFlag%"=="N" (
	SET /p filePath= Please enter Backup folder location:
    chdir /d %filePath%
	FOR %%I IN ( "*.yaml")  DO CALL apic draft-apis:create --api_type rest  --format yaml -o o2apic -s mgmt.test1manager.apico2r53.co.uk %%I

	echo "*********************"
	echo "APIs import completed"
	echo "*********************"

	FOR %%I IN ( "product*.yaml")  DO CALL apic draft-products:create --format yaml -o o2apic -s mgmt.test1manager.apico2r53.co.uk %%I

	echo "*********************"
	echo "Products import completed"
	echo "*********************"

	SET /p uploadFlag= Recheck:
	Exit /B
)

CALL IF /I "%importFlag%"=="Y" (
	SET /p repoPath= Please enter your local repository path:
	SET /p gitUserName= Please enter your gitHub username:
	CALL chdir /d %repoPath%
	SET /p flag= drive : %repoPath%
	CALL git config --global user.name "%gitUserName%"
	CALL git fetch --all
	CALL git pull
	
	FOR %%I IN ( "ConfigurationBackups\o2apic*.yaml")  DO CALL apic draft-apis:create --api_type rest  --format yaml -o o2apic -s mgmt.test1manager.apico2r53.co.uk %%I

	echo "*********************"
	echo "APIs import completed"
	echo "*********************"

	FOR %%I IN ( "ConfigurationBackups\postpay*.yaml")  DO CALL apic draft-products:create --format yaml -o o2apic -s mgmt.test1manager.apico2r53.co.uk %%I

	echo "*********************"
	echo "Products import completed"
	echo "*********************"
	Exit /B
)
