### Install Chef and Bootstrap with ConfigMgr
Disclaimer! I'm making several assumptions here, one of which is I assume you know how to make basic objects in ConfigMgr like packages, collections, variables, and task sequences. If you aren't familiar with ConfigMgr or just need a refresher, Windows Noob has some great [tutorials](https://www.windows-noob.com/forums/topic/13288-step-by-step-guides-system-center-configuration-manager-current-branch-and-technical-preview/).
1. First step is to edit line 45 in the script and add your information. Specify the runlist and any other parameters you might want to statically assign to a node. (Don't assign anything you can query later, this is a good spot to assign things like owner, physical site, business unit or department, etc.)
   ``` 
   write-output "{`"run_list`": [`"recipe[brownfield::default]`"], `"system_info`": {`"business_unit`": `"[$ClientBU]`"}}"}
2. Put the updated script, the validator.pem, and the chef-client-XX.X.XX-arch.msi file in your source files directory on your ConfigMgr server and create a package for it.
3. Create a program for the MSI using the Chef specific options required [Chef MSI options](https://docs.chef.io/install_windows.html#addlocal-options)
   ```
   chef-client-13.1.31-1-x64.msi /qn ADDLOCAL="ChefClientFeature"
4. Now, create a task sequence with 3 steps.
   1. Create a "Run PowerShell Script" step
      ```
      Script Name: Create-BootstrapFiles.ps1
      Parameters: -ClientEnv %ClientEnv% -ClientBU %ClientBU%
      Execution Policy: Bypass
   2. Create an "Install Package" step and select the Chef package and program made earlier.
   3. Create a "Run Command Line" step to bootstrap the node
      ```
      cmd /c "c:\opscode\chef\bin\chef-client.bat -j c:\chef\first-boot.json"
5. Now create the collections needed for deployment. Make a deployment collection (I separate deployment collectiosn out by the timeframe of the deployment). Use collection limiting to reduce scope of target systems. Then, make individual collections for the various parameters (in this case, environment and business unit) and assign collection variables to each one.
   * Here's a sample layout
      * Deployment - Test Systems
         * Parameters - BU eq Accounting
         * Parameters - BU eq Engineering
         * Parameters - BU eq Sales
         * Parameters - ClientENV eq Test
6. Now the fun part, create a deployment for the task sequence and target the "Deployment" collection
7. Sit back and watch your automation do your work for you!
