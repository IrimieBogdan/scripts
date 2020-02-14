[CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string] $version
  )
  Set-Alias exist Test-Path -Option "Constant, AllScope"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  $url = ("https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$version-1/rubyinstaller-devkit-$version-1-x64.exe");
  $args = "/silent /tasks='assocfiles,modpath'"


  if (exist $env:temp\ruby_installer.exe) {
     Write-Output "Ruby already downloaded"
  } else {
    Write-Output "Downloading Ruby"
    Invoke-WebRequest -Uri $url -OutFile $env:temp\ruby_installer.exe
    Write-Output "Installing Ruby"
    $ruby_inst_process = Start-Process -FilePath $env:temp\ruby_installer.exe -ArgumentList $args -PassThru -Wait

    if ($ruby_inst_process.ExitCode -ne 0) {
      "Ruby $version installation failed"
      exit 0
    }
  }



