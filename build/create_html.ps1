# Windows PowerShell script to create the HTML file.
# asciidoctorj and Saxon (both Java applications) are used
param([Parameter(Mandatory=$true)] $docVersion)

# change to unicode
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Check whether SAXON_CP user environment variable is set. SAXON_CP has to point to the main jar file in the Saxon distribution, see https://www.saxonica.com.
if ([System.Environment]::GetEnvironmentVariable("SAXON_CP", [System.EnvironmentVariableTarget]::User) -eq $null) {
    Write-Error "The user environment variable SAXON_CP is not set. Script will exit."
    exit
} else {
	Write-Host "SAXON_CP=$env:SAXON_CP"
}

$folder = "target"
if (Test-Path $folder) {
	Remove-Item -Recurse $folder
    Write-Host "Deleted folder $folder"
}
New-Item $folder -ItemType Directory
Write-Host "Folder $folder created successfully"

# retrieve today's date, for setting the revision date
$today = Get-Date -Format "yyyy-MM-dd"

Write-Host "Create HTML page with asciidoctorj"
$tmpOutput = "index_tmp.html"
$finalOutput = "index.html"
asciidoctorj -b xhtml5 -a revdate=$today -a revnumber=$docVersion -a stylesheet! -o $tmpOutput -D $folder docs/index.adoc
Write-Host "Update HTML page with Saxon"
$command = "$env:JAVA_HOME/bin/java.exe -cp $env:SAXON_CP net.sf.saxon.Transform -s:$folder/$tmpOutput -xsl:build/prepare_html_for_styling.xsl -o:$folder/$finalOutput"
Invoke-Expression $command
if (Test-Path "$folder/$finalOutput") {
	Invoke-Item "$folder/$finalOutput"
	Write-Host "HTML page $folder/$finalOutput created successfully"
} else {
	Write-Error "HTML page not created"
}
