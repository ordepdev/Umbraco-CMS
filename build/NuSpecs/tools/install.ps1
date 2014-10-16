param($rootPath, $toolsPath, $package, $project)

if ($project) {
	$dateTime = Get-Date -Format yyyyMMdd-HHmmss
	$backupPath = Join-Path (Split-Path $project.FullName -Parent) "\App_Data\NuGetBackup\$dateTime"
	$copyLogsPath = Join-Path $backupPath "CopyLogs"
	$projectDestinationPath = Split-Path $project.FullName -Parent

	# Create backup folder and logs folder if it doesn't exist yet
	New-Item -ItemType Directory -Force -Path $backupPath
	New-Item -ItemType Directory -Force -Path $copyLogsPath
	
	# Copy umbraco and umbraco_files from package to project folder
	# This is only done when these folders already exist because we 
	# only want to do this for upgrades
	$umbracoFolder = Join-Path $projectDestinationPath "Umbraco"
	if(Test-Path $umbracoFolder) {
		$umbracoFolderSource = Join-Path $rootPath "UmbracoFiles\Umbraco"
		
		$umbracoBackupPath = Join-Path $backupPath "Umbraco"
		New-Item -ItemType Directory -Force -Path $umbracoBackupPath
		
		robocopy $umbracoFolder $umbracoBackupPath /e /LOG:$copyLogsPath\UmbracoBackup.log
		robocopy $umbracoFolderSource $umbracoFolder /is /it /e /xf UI.xml /LOG:$copyLogsPath\UmbracoCopy.log
	}

	$umbracoClientFolder = Join-Path $projectDestinationPath "Umbraco_Client"	
	if(Test-Path $umbracoClientFolder) {
		$umbracoClientFolderSource = Join-Path $rootPath "UmbracoFiles\Umbraco_Client"
		
		$umbracoClientBackupPath = Join-Path $backupPath "Umbraco_Client"
		New-Item -ItemType Directory -Force -Path $umbracoClientBackupPath
		
		robocopy $umbracoClientFolder $umbracoClientBackupPath /e /LOG:$copyLogsPath\UmbracoClientBackup.log
		robocopy $umbracoClientFolderSource $umbracoClientFolder /is /it /e /LOG:$copyLogsPath\UmbracoClientCopy.log		
	}

	$installFolder = Join-Path $projectDestinationPath "Install"
	if(Test-Path $umbracoFolder) {
		Remove-Item $installFolder -Force -Recurse -Confirm:$false
	}

	# Open readme.txt file
	$DTE.ItemOperations.OpenFile($toolsPath + '\Readme.txt')
}