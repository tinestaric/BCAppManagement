# Steps for Upgrading BC
## 1. Run the "Prepare Datebase.ps1":
 - Backs up the database
 - Uninstalls and unpublished all current Apps
 - Stops the Service

## 2. Manually using Setup.exe from installation media uninstal and reinstall BC 
 - Mark all Install options but outlook and help server. For configuration, import the "Server Config.xml"

## 3. Restart the Server
## 4. Run the "Platform Update.ps1":
 - Updates the databse platform, do not worry if this step raises an error, as a CU may not bring platform changes
 - Assignes the database to the BC Server Instance
 - Restarts the Service

## 5. Run the "Application Update.ps1":
 - Imports a Dev Licence
 - Publishes and Syncs all Microsoft apps, BeTerna apps and Custom Apps
 - Imports the Client Licence

## 6. Run the "Upgrade Control Add-Ins.ps1"

## 7. Check if NTLM Authentication and API Services are enabled in the BC Administration Tool
## 8. Enjoy!
