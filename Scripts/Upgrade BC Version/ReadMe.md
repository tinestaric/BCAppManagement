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
 - Check all AAD settings, and reset them. 

## 8. Set IIS Instance Settings
 - Stop the IIS instance
 - Override files in wwwroot folder with files in WebPublish folder. WebPublish is in the install directory. This is only necessary for non-default instances, as default instance is updated during the installation of new BC version
 - Set correct ports and authentication method in navsettings.json which is in the instance folder in wwwroot
 - for AAD set AadApplicationId and AadAuthorityUri, this is mandatory for default instance as well 
## 8. Enjoy!
