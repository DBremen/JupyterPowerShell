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
            $UrlPrefix = 'https://powershellone.files.wordpress.com/'
        )
    $imageUrlPrefix = $UrlPrefix + $UrlPostFix
    if (! $imageUrlPrefix.EndsWith('/')) {  $imageUrlPrefix =  $imageUrlPrefix+ '/'}
    $path = $PSScriptRoot
    Push-Location $path
    $NotebookName = $NotebookName.Replace('.\','')
    $nbPath = (Resolve-Path $NotebookName)
	copy $nbPath notebooks
    $text = Get-Content $nbPath -Raw
    $text = $text.Replace('$','~~')
    $char = [char]0x9d
    $text = $text -replace $char,''
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($nbPath, $text, $Utf8NoBomEncoding)
    python .\run_nb2wp.py $NotebookName $imageUrlPrefix
    $text = $text.Replace('~~' ,'$')
    $text | Set-Content $nbPath -NoNewline  -Encoding utf8
    Add-Type -Path "C:\scripts\ps1\get-stats\Helper\HtmlAgilityPack.dll" 
    $doc = New-Object HtmlAgilityPack.HtmlDocument
    $htmlName = [System.IO.Path]::ChangeExtension($NotebookName, 'html')
    $htmlFolder = 'html\' + [System.IO.Path]::GetFileNameWithoutExtension($NotebookName)
    $htmlPath = Join-Path (Join-Path $path $htmlFolder) $htmlName
    $text = Get-Content $htmlPath -Raw -Encoding utf8
    $text = $text.Replace('~~' , '$')
    $text | Set-Content $htmlPath -NoNewline  -Encoding utf8
    $result = $doc.Load($htmlPath)
    $result = $doc.DocumentNode.SelectNodes("//div[contains(@class,'prompt')]")
    $result.foreach{$_.remove()}
    $result = $doc.DocumentNode.SelectNodes("//script")
    $result.foreach{$_.remove()}
    $doc.DocumentNode.SelectSingleNode('//body').OuterHtml | Set-Clipboard
    $doc.Save($htmlPath)
    del $nbPath
    Pop-Location
}

build 'graphTheory2.ipynb' 2021/03