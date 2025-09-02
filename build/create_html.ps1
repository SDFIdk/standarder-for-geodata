# Windows PowerShell script to create the HTML file.
# asciidoctorj and Saxon (both Java applications) are used
param(
    [Parameter(Mandatory=$false)] [string]$DocVersion = "udkast",
    [Parameter(Mandatory=$false)] [switch]$SkipOpenHtml
)

# change to UTF-8
chcp 65001

# Check whether SAXON_CP environment variable is set. SAXON_CP has to point to the main jar file in the Saxon distribution, see https://www.saxonica.com.
if (-not $env:SAXON_CP) {
    Write-Error "The environment variable SAXON_CP is not set. Script will exit."
    exit 1
} else {
	Write-Host "SAXON_CP=$env:SAXON_CP"
}

$Folder = "target"
if (Test-Path $Folder) {
	Remove-Item -Recurse $Folder
    Write-Host "Deleted folder $Folder"
}
New-Item $Folder -ItemType Directory
Write-Host "Folder $Folder created successfully"

# retrieve today's date, for setting the revision date
$Today = Get-Date -Format "yyyy-MM-dd"

Write-Host "Create HTML page with asciidoctorj"
$TmpOutputFileName = "index_tmp.html"
$TmpOutput = Join-Path $Folder $TmpOutputFileName
asciidoctorj -b xhtml5 -a revdate=$Today -a revnumber=$DocVersion -a stylesheet! -o $TmpOutputFileName -D $Folder docs/index.adoc

Write-Host "Update HTML page with Saxon"
$FinalOutput = Join-Path $Folder "index.html"
$Java = Join-Path $env:JAVA_HOME "bin/java.exe"
& $Java `
    -cp "$env:SAXON_CP" `
    net.sf.saxon.Transform `
    -s:"$TmpOutput" `
    -xsl:"build/prepare_html_for_styling.xsl" `
    -o:"$FinalOutput"
if (Test-Path $FinalOutput) {
	Write-Host "HTML page $FinalOutput created successfully"
    if (-not $SkipOpenHtml) {
		Invoke-Item $FinalOutput
    }
} else {
	Write-Error "HTML page not created"
}
