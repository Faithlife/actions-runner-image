# find the latest CodeQL release
$codeql_release = (Invoke-RestMethod -Uri "https://api.github.com/repos/github/codeql-action/releases/latest" -Headers @{
  "Accept" = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
});

# download the Windows x64 bundle
Invoke-WebRequest -Uri $($codeql_release.assets | Where-Object { $_.name -eq "codeql-bundle-win64.tar.gz" }).browser_download_url -OutFile "c:\codeql.tar.gz"

# extract it to the correct location in the runner tool cache
$codeql_version = $codeql_release.html_url.replace('https://github.com/github/codeql-action/releases/tag/codeql-bundle-v', '')
$codeql_path = "C:\actions-runner\_work\_tool\CodeQL\$codeql_version\x64"
New-Item -ItemType Directory -Force -Path $codeql_path > $null
tar -xzf C:\codeql.tar.gz -C $codeql_path

Remove-Item "c:\codeql.tar.gz"

# write a .complete file so that the tool cache knows that the tool is installed; https://github.com/actions/toolkit/blob/3d652d3133965f63309e4b2e1c8852cdbdcb3833/packages/tool-cache/src/tool-cache.ts#L528
New-Item -ItemType File -Path "$codeql_path.complete" -Force > $null
