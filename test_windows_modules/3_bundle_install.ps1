[CmdletBinding()]
  Param(
    [String]$module
  )

  function not-exist { -not (Test-Path $args) }
  Set-Alias !exist not-exist -Option "Constant, AllScope"
  Set-Alias exist Test-Path -Option "Constant, AllScope"

   if (exist "$env:temp\$module") {
    Write-Output "Moving into $env:temp\$module"
    cd "$env:temp\$module"
  } else {
    Write-Output "$module not found"
    exit 1
  }

  Write-Output "Trying to remove inventory.yaml"

  if (exist "$env:temp\$module\inventory.yaml") {
    Write-Output "Removing inventory.yaml"
    rm inventory.yaml
  } else {
    Write-Output "inventory.yaml not present, nothing to remove"
  }

  gem install bundler
  bundle lock --add-platform ruby
  bundle install -j4

  exit $LASTEXITCODE
