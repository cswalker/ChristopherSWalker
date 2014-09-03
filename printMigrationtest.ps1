##########################################
###Name:    printMigrationtest.ps1     ###
###Purpose: Printer Migration - TESTING###
###Author:  Christopher S. Walker      ###
###Date:    08-28-2014                 ###
##########################################
###########
#Variables#
###########
#1. Set the original print server name
$origPrtSrvr = Read-Host "Existing Print Server name?"
#2. Set the new print server name
$newPrtSrvr = Read-Host "New Print Server Name?"
#3.Get printers from original print server and set them to the Printers list
$newPrinter = Get-WmiObject Win32_Printer -ComputerName $origPrtSrvr
#4.Used for retrieving INF Files from the original print server
$oldSrvrPath = "\\" + $origPrtSrvr + "\C$\"
#5 Used for dumping the original INF file into the new print server
$newSrvrPath = "\\" + $newPrtSrvr + "\C$\INFDUMP\"
#7 Identify all drivers from printers of original print server
$drivers = $newPrinter.DriverName
#8 Path to utilize INFDUMP for creating Driver Store
$driverStore = $newSrvrPath + "*.inf"
########
#Script#
########
#1 read back input to user
    Write-Host "_________________________________" -ForegroundColor Yellow
    Write-Host "Original Print Server: " $origPrtSrvr -ForegroundColor Yellow
    Write-Host "New Print Server: " $newPrtSrvr -ForegroundColor Yellow
    Write-Host "Old Server Path: " $oldSrvrPath -ForegroundColor Yellow
    Write-Host "New Server Path: " $newSrvrPath -ForegroundColor Yellow
    Write-Host "_________________________________" -ForegroundColor Yellow
#2. Make INFDUMP Directory
IF(!(Test-Path -Path $newSrvrPath))
    {
        New-Item -ItemType directory -Path $newSrvrPath
        Write-host "Directory: " $newSrvrPath " Created" -ForegroundColor Yellow
    }
Else
    {
        Write-Host "Directory: " $newSrvrPath " Exists" -ForegroundColor Yellow
    }
#3. Create INF dump on new server from INFs located on the old server
    #Write-Host "_______________________________________" -ForegroundColor Yellow
    #Write-Host "Creating INFDUMP, this may take a while" -ForegroundColor Yellow
    #Write-Host "_______________________________________" -ForegroundColor Yellow
#Get-ChildItem -Path $oldSrvrPath -Filter *.inf -Recurse | Copy-Item -Destination $newSrvrPath
#4. Add the Print drivers copied to the machine
    Write-Host "_________________________________" -ForegroundColor Yellow
    Write-Host "Creating Driver Store" -ForegroundColor Yellow
    Write-Host "_________________________________" -ForegroundColor Yellow
pnputil.exe -i -a $driverStore
    Write-Host "_________________________________" -ForegroundColor Yellow
    Write-Host "Adding Drivers" -ForegroundColor Yellow
    Write-Host "_________________________________" -ForegroundColor Yellow
foreach($driver in $drivers)
{
    Add-PrinterDriver -ComputerName $newPrtSrvr -Name [string]$driver -InfPath $newSrvrPath
}
#5. Add each printer to the new server and output their information to the screen
foreach($Printer in $newPrinter)
{
        Write-Host "_________________________________" -ForegroundColor Yellow
        Write-Host "New Printer: " -ForegroundColor Yellow
        Write-Host "Name: " $Printer.Name  -ForegroundColor Yellow
        Write-Host "Location: " $Printer.Location -ForegroundColor Yellow
        Write-Host "Comment: " $Printer.Comment -ForegroundColor Yellow
        Write-Host "Driver Name: " $Printer.DriverName -ForegroundColor Yellow
        Write-Host "Port Name: " $Printer.PortName -ForegroundColor Yellow
        Write-Host "Shared: " $Printer.Shared -ForegroundColor Yellow
        Write-Host "ShareName: " $Printer.Sharename -ForegroundColor Yellow
        Write-Host "_________________________________" -ForegroundColor Yellow
    Add-Printer -Comment $Printer.Comment -ComputerName $newPrtSrvr -DriverName $Printer.DriverName -Location $Printer.Location -Name $Printer.Name -PortName $Printer.PortName
   
}