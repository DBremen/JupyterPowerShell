<#
requirements:
python
HTMLAgilityPack: 
Install-Package -Name $package -ProviderName NuGet -Source 'https://www.nuget.org/api/v2' -Destination $Destination
nb2wp.py and style.css:
https://github.com/bennylp/nb2wp
#>

function build {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            $NotebookName,
            [Parameter(Mandatory)]
            $urlPostFix

          
        )
    $urlPrefix = 'https://powershellone.files.wordpress.com/' + $urlPostFix
    if (!$urlPrefix.EndsWith('/')) { $urlPrefix = $urlPrefix + '/'}
    $path = $PSScriptRoot
    Push-Location $path
    $NotebookName = $NotebookName.Replace('.\','')
    python .\run_nb2wp.py $NotebookName $urlPrefix
    Add-Type -Path "C:\scripts\ps1\get-stats\Helper\HtmlAgilityPack.dll" 
    $doc = New-Object HtmlAgilityPack.HtmlDocument
    $htmlName = [System.IO.Path]::ChangeExtension($NotebookName, 'html')
    $htmlFolder = 'html\' + [System.IO.Path]::GetFileNameWithoutExtension($NotebookName)
    $htmlPath = Join-Path (Join-Path $path $htmlFolder) $htmlName
    $result = $doc.Load($htmlPath)
    $result = $doc.DocumentNode.SelectNodes("//div[contains(@class,'prompt')]")
    $result.foreach{$_.remove()}
    $doc.Save($htmlPath)
    move (Resolve-Path $NotebookName) notebooks
    Pop-Location
}

#build blog_test.ipynb 2021/02