[CmdletBinding()]
  Param(
    [String]$module
  )

  Set-Alias exist Test-Path -Option "Constant, AllScope"

  if (exist "$env:temp\$module") {
    Write-Output "$module already cloned"
  } else {
    Write-Output "Clonning $module"
    git clone "https://github.com/puppetlabs/$module.git" "$env:temp\$module"
  }

  exit $LASTEXITCODE
