<#
requirements:
python
HTMLAgilityPack
Install-Package -Name HTMLAgilityPack -ProviderName NuGet -Source 'https://www.nuget.org/api/v2' -Destination $Destination
nb2wp.py and style.css:
https://github.com/bennylp/nb2wp
#>

function build {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            $NotebookName,
            [Parameter(Mandatory)]
            $UrlPostFix,
            $urlPrefix = 'https://powershellone.files.wordpress.com/'

          
        )
    $imageUrlPrefix = $urlPrefix + $UrlPostFix
    if (! $imageUrlPrefix.EndsWith('/')) {  $imageUrlPrefix =  $imageUrlPrefix+ '/'}
    $path = $PSScriptRoot
    Push-Location $path
    $NotebookName = $NotebookName.Replace('.\','')
    python .\run_nb2wp.py $NotebookName $imageUrlPrefix
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