[CmdletBinding()]
  Param(
    [String]$module
  )

  # [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  # If an error is encountered, the script will stop instead of the default of "Continue"
  # $ErrorActionPreference = "Stop"

  function not-exist { -not (Test-Path $args) }
  Set-Alias !exist not-exist -Option "Constant, AllScope"
  Set-Alias exist Test-Path -Option "Constant, AllScope"

  if (not-exist "$env:temp\modules") {
    New-Item -ItemType directory -Path "$env:temp\modules"
  }

  if (not-exist "$env:temp\modules\$module") {
    git clone "https://github.com/puppetlabs/$module.git" "$env:temp\modules\$module"
  }

  cd "$env:temp\modules\$module"

  if (exist "$env:temp\modules\$module\inventory.yaml") {
    rm inventory.yaml
  }

  gem install bundler
  bundle lock --add-platform ruby
  bundle install -j4
  bundle exec rake litmus:acceptance:localhost
