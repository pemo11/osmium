<#
 .Synopsis
 Pushes the whole module to GitHub as well
#>

# Default Module directory
$ModulePath = "C:\Program Files\WindowsPowerShell\Modules\Osmium"
# Important: Get the variable through an enviroment variable
if (Test-Path -Path Env:\OsmiumModulePath)
{
    $ModulePath = $env:OsmiumModulePath
}

$CommitMessage = "Commited from VSTS at {0:d}" -f (Get-Date)

# Setup details
git config --global user.email "pm@activetraining.de"
git config --global user.name "Peter Monadjemi"

# Create new Git directory

$GitDirectoryPath =  Join-Path -Path $env:temp -ChildPath "OsmiumGit"

mkdir $GitDirectoryPath -Force -ErrorAction Ignore | Out-Null

# Copy all the module files into the new directory

Copy-item -path $ModulePath -Destination $GitDirectoryPath -Recurse

$GitUrl = "https://pemo11:!nopw2016@github.com/pemo11/osmium"
cd $GitDirectoryPath

git init

git add .

git commit -m $CommitMessage

git remote add origin $GitUrl

git pull origin master 
git push origin master -f