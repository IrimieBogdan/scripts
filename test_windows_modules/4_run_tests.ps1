[CmdletBinding()]
  Param(
    [String]$module
  )

  Set-Alias exist Test-Path -Option "Constant, AllScope"

  if (exist "$env:temp\$module") {
    Write-Output "Moving into $env:temp\$module"
    cd "$env:temp\$module"
  } else {
    Write-Output "$module not found"
    exit 1
  }

  Write-Output "Start running tests"
  bundle exec rake spec_prep
  bundle exec rake litmus:acceptance:localhost

  exit $LASTEXITCODE
