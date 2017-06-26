# Get parameters from pipeline
Param
(
    # This is the environment variable for the client RB file
    [Parameter(Mandatory=$true)]
    [String]
    $ClientEnv,

    # This is the business unit variable for the firstboot json file
    [Parameter(Mandatory=$true)]
    [String]
    $ClientBU,

    # This is the chef_server_url variable for the client RB file
    [Parameter(Mandatory=$true)]
    [String]
    $ChefServerURL,

    # This is the validation client name variable for the client RB file
    [Parameter(Mandatory=$true)]
    [String]
    $ValidatorName
)

$ChefRootDir = "c:\chef"
$ChefClientRBFile = "client.rb"
$ChefFirstBootFile = "first-boot.json"
#$ClientEnv = "non-prod"
#$ClientBU = "Test"

# This funtion writes the required output to the client.rb file. The file needs to be generated instead of copied since the individual computer name needs to be injected into it.
function Create-ClientRBFile {
    write-output "log_level        :info" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii
    write-output "log_location     STDOUT" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "chef_server_url  '$ChefServerURL'" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "validation_client_name '$ValidatorName'" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "validation_key '$ChefRootDir\$ValidatorName.pem'" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "node_name '$($env:computername)'" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "ssl_verify_mode :verify_none" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
    write-output "environment '$ClientEnv'" | Out-File -FilePath $ChefRootDir\$ChefClientRBFile -Encoding ascii -Append
}

# Create the first-boot.json file. This runlist may need to be edited to specify the appropriate runlist and additional info (i.e. system_info)
function Create-FirstBootFile {
    write-output "{`"run_list`": [`"recipe[brownfield::default]`"], `"system_info`": {`"business_unit`": `"[$ClientBU]`"}}" | Out-File -FilePath $ChefRootDir\$ChefFirstBootFile -Encoding ascii
}

### Let's make the client.rb
if (Test-Path -Path "$ChefRootDir\$ChefClientRBFile") {
    #File already exists so let's overwrite it with the new params
    Create-ClientRBFile
}
else{
    # something doesn't exist so we need to make the things
    if (Test-Path -Path "$ChefRootDir"){
        #Folder is there so all we need to do is make the file
        Out-File -FilePath "$ChefRootDir\$ChefClientRBFile" -Encoding ascii
    }
    else {
        #nothing exists so make all the things
        New-Item -Path "$ChefRootDir" -ItemType Directory
        Out-File -FilePath "$ChefRootDir\$ChefClientRBFile" -Encoding ascii
    }

    # now that the file exists, populate it!
    Create-ClientRBFile
}

### No make the firstboot.json
if (Test-Path -Path "$ChefRootDir\$ChefFirstBootFile") {
    #File already exists so let's overwrite it with the new params
    Create-ClientRBFile
}
else{
    # something doesn't exist so we need to make the things
    if (Test-Path -Path "$ChefRootDir"){
        #Folder is there so all we need to do is make the file
        Out-File -FilePath "$ChefRootDir\$ChefFirstBootFile" -Encoding ascii
    }
    else {
        #nothing exists so make all the things
        New-Item -Path "$ChefRootDir" -ItemType Directory
        Out-File -FilePath "$ChefRootDir\$ChefFirstBootFile" -Encoding ascii
    }

    # now that the file exists, populate it!
    Create-FirstBootFile
}
# Last but not least, copy the validator file from the SCCM cache directory into the $ChefRootDir with the other files
Copy-Item -Path "$PSScriptRoot\$ValidatorName.pem" -Destination $ChefRootDir