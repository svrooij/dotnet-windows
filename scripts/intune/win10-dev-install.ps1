Start-Transcript

$updateWingetSettings = $false;
$installApps = @("Microsoft.Teams", "Microsoft.Edge", "AgileBits.1Password", "Discord.Discord", "OBS Studio", "XSplit.VCam", "Elgato.StreamDeck")
$installDevApps = @("Microsoft.PowerShell", "Microsoft.AzureCLI", "Microsoft.AzureStorageExplorer", "Microsoft.AzureCosmosEmulator","Microsoft.dotnet", "Microsoft.dotnetRuntime.3-x86", "Microsoft.dotnetRuntime.5-x86",  "Microsoft.EdgeWebView2Runtime", "Microsoft.WindowsTerminal", "Microsoft.PowerToys", "Microsoft.VisualStudioCode",  "GitHub.cli", "7zip.7zip", "Insomnia.Insomnia",  "Docker.DockerDesktop");
$installStoreApps = @("Microsoft.Whiteboard");
# $uninstallApps = @("Microsoft.People", "*xboxapp*", "*3DPrint*", "Microsoft.SkypeApp", "Microsoft.Advertising*", "Microsoft.BingWeather", "Microsoft.ZuneVideo", "Microsoft.ZuneMusic", "Microsoft.Getstarted", "Microsoft.MicrosoftOfficeHub", "microsoft.windowscommunicationsapps");

if ($updateWingetSettings) {
  # Load existing Winget settings file
  $wingetSettingsFile = $env:LOCALAPPDATA + "\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
  $settings = Get-Content -Raw -Path $wingetSettingsFile -ErrorAction SilentlyContinue | ConvertFrom-Json;

  # Write required settings to remove Store apps
  if ($null -eq $settings) {
    Write-Output "No settings, writing default"
    $json = @"
{
  "$schema": "https://aka.ms/winget-settings.schema.json",
  // For documentation on these settings, see: https://aka.ms/winget-settings
  // "source": {
  //    "autoUpdateIntervalInMinutes": 5
  // },
  "installBehavior": {
      "preferences": {
          "locale": ["en-US","nl-NL"]
      }
  },
  "telemetry": {
      "disable": true
  },
  "experimentalFeatures": {
      "experimentalMSStore": true,
      "uninstall": true
  }
}
"@

    $json | Out-File $wingetSettingsFile -Encoding utf8

  }
  else {
    if ($null -eq $settings.telemetry) {

      $settings | Add-Member -Name "telemetry" -MemberType NoteProperty -Value @{}
      $settings.telemetry.disable = $true
    }

    if ($null -eq $settings.experimentalFeatures) {
      $settings | Add-Member -Name "experimentalFeatures" -MemberType NoteProperty -Value @{}
      $settings.experimentalFeatures.experimentalMSStore = $true;
      $settings.experimentalFeatures.uninstall = $true;
    }

    $settings | ConvertTo-Json -Depth 3 | Out-File $wingetSettingsFile -Encoding utf8;
  }
}

# Import required module to (un)install apps
# Import-Module Appx

$counter = 0;
Foreach ($app in $installApps) {
  $counter++
  Write-Output "Installing app $($app)... ($counter/$($installApps.Length))"

  winget install --exact --silent $app --source winget
}

$counter = 0;
Foreach ($app in $installDevApps) {
  $counter++
  Write-Output "Installing dev app $($app)... ($counter/$($installDevApps.Length))"

  winget install --exact --silent $app --source winget
}


$counter = 0;
Foreach ($app in $installStoreApps) {
  $counter++
  Write-Output "Installing windows app $($app)... ($counter/$($installStoreApps.Length))"

  winget install --exact --silent $app --source msstore
}

# $counter = 0;
# Foreach ($app in $uninstallApps) {
#   $counter++
#   Write-Output "Uninstalling windows app $($app)... ($counter/$($uninstallApps.Length))"

#   Get-AppxPackage $app | Remove-AppxPackage
# }

Stop-Transcript