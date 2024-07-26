$dlTemplate = "https://raw.githubusercontent.com/mousseng/DalamudPlugins/main/plugins/{0}/latest.zip"
$output = New-Object Collections.Generic.List[object]

Get-ChildItem -Path ./plugins/ -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json
    $content | add-member -Force -Name "IsHide" -value "False" -MemberType NoteProperty
    $content | add-member -Force -Name "IsTestingExclusive" -value "False" -MemberType NoteProperty

    $internalName = $content.InternalName

    $path = "plugins/$internalName/latest.zip"
    if (!($path | Test-Path)) {
        exit 1;
    }

    $updateDate = git log -1 --pretty="format:%ct" $path
    if ($updateDate -eq $null){
        $updateDate = 0;
    }
    $content | add-member -Force -Name "LastUpdate" $updateDate -MemberType NoteProperty

    $installLink = $dlTemplate -f $internalName
    $content | add-member -Force -Name "DownloadLinkInstall" $installLink -MemberType NoteProperty
    $content | add-member -Force -Name "DownloadLinkTesting" $installLink -MemberType NoteProperty
    $content | add-member -Force -Name "DownloadLinkUpdate" $installLink -MemberType NoteProperty

    $output.Add($content)
}

ConvertTo-Json -InputObject $output | Out-File -FilePath .\pluginmaster.json
