# Windows PowerShell script to create the HTML file.
# saxonJar is the location of the Saxon jar file
param([Parameter(Mandatory=$true)] $docVersion)

# change to unicode
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Check whether SAXON_CP user environment variable is set. SAXON_CP has to point to the main jar file in the Saxon distribution, see https://www.saxonica.com.
if ([System.Environment]::GetEnvironmentVariable("SAXON_CP", [System.EnvironmentVariableTarget]::User) -eq $null) {
    Write-Host "The user environment variable SAXON_CP is not set. Script will exit."
    exit
}

$folder = "target"
if (Test-Path $folder) {
	Remove-Item -Recurse $folder
    Write-Host "Deleted folder "$folder
}
New-Item $folder -ItemType Directory
Write-Host "Folder" $folder "created successfully"

$assetsFolder = $folder + "\assets"
Copy-Item -Path "docs\assets" -Destination $assetsFolder -Recurse

# retrieve today's date, for setting the revision date
$today = Get-Date -Format "yyyy-MM-dd"

Write-Host "Running asciidoctorj"
$tmp_output = "index_tmp.html"
asciidoctorj -b xhtml5 -a revdate=$today -a revnumber=$docVersion -a stylesheet! -o $tmp_output -D $folder docs\index.adoc
Write-Host "Running Saxon"
java -cp $env:SAXON_CP net.sf.saxon.Transform -s:$folder\$tmp_output -xsl:build\prepare_html_for_styling.xsl -o:$folder\index.html
Write-Host "Finished"