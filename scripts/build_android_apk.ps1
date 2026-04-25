param(
    [string]$AndroidSdkPath,
    [string]$FlutterSdkPath,
    [int]$BuildNumber,
    [string]$BuildName,
    [switch]$SplitPerAbi = $true
)

$ErrorActionPreference = "Stop"

function Resolve-ExistingPath {
    param(
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    return $null
}

function ConvertTo-PropertiesValue {
    param(
        [string]$Value
    )

    return $Value.Replace("\", "\\").Replace(":", "\:")
}

function Ensure-DebugKeystore {
    param(
        [string]$KeystorePath
    )

    if (Test-Path $KeystorePath) {
        return
    }

    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if (-not $keytool) {
        throw "keytool is required to create the debug keystore. Install a JDK and ensure keytool is on PATH."
    }

    $keystoreDir = Split-Path -Parent $KeystorePath
    if (-not (Test-Path $keystoreDir)) {
        New-Item -ItemType Directory -Path $keystoreDir | Out-Null
    }

    & $keytool.Source `
        -genkeypair `
        -v `
        -storetype PKCS12 `
        -keystore $KeystorePath `
        -storepass android `
        -keypass android `
        -alias androiddebugkey `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -dname "CN=Android Debug,O=Android,C=US"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "android"
$localPropertiesPath = Join-Path $androidDir "local.properties"
$keyPropertiesPath = Join-Path $androidDir "key.properties"
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
$flutterSdkFromCommand = $null

if ($flutterCommand) {
    $flutterSdkFromCommand = Split-Path -Parent (Split-Path -Parent $flutterCommand.Source)
}

$resolvedFlutterSdk = Resolve-ExistingPath @(
    $FlutterSdkPath,
    $env:FLUTTER_ROOT,
    $flutterSdkFromCommand
)

if (-not $resolvedFlutterSdk) {
    throw "Flutter SDK not found. Pass -FlutterSdkPath or make sure flutter is on PATH."
}

$resolvedAndroidSdk = Resolve-ExistingPath @(
    $AndroidSdkPath,
    $env:ANDROID_HOME,
    $env:ANDROID_SDK_ROOT,
    (Join-Path $env:LOCALAPPDATA "Android\\Sdk"),
    (Join-Path $env:USERPROFILE "AppData\\Local\\Android\\Sdk"),
    "C:\\Android\\Sdk"
)

if (-not $resolvedAndroidSdk) {
    throw "Android SDK not found. Install Android SDK and pass -AndroidSdkPath, or set ANDROID_HOME / ANDROID_SDK_ROOT."
}

$env:ANDROID_HOME = $resolvedAndroidSdk
$env:ANDROID_SDK_ROOT = $resolvedAndroidSdk

$properties = @{}
if (Test-Path $localPropertiesPath) {
    foreach ($line in Get-Content $localPropertiesPath) {
        if ($line -match '^\s*#' -or $line -notmatch '=') {
            continue
        }

        $parts = $line -split '=', 2
        $properties[$parts[0]] = $parts[1]
    }
}

$properties["flutter.sdk"] = ConvertTo-PropertiesValue $resolvedFlutterSdk
$properties["sdk.dir"] = ConvertTo-PropertiesValue $resolvedAndroidSdk

$content = @(
    "flutter.sdk=$($properties["flutter.sdk"])"
    "sdk.dir=$($properties["sdk.dir"])"
)

foreach ($entry in $properties.GetEnumerator() | Sort-Object Name) {
    if ($entry.Key -in @("flutter.sdk", "sdk.dir")) {
        continue
    }

    $content += "$($entry.Key)=$($entry.Value)"
}

Set-Content -Path $localPropertiesPath -Value $content

$hasReleaseSigning = (Test-Path $keyPropertiesPath) -or (
    $env:ANDROID_KEYSTORE_PATH -and
    $env:ANDROID_KEYSTORE_PASSWORD -and
    $env:ANDROID_KEY_ALIAS -and
    $env:ANDROID_KEY_PASSWORD
)

if (-not $hasReleaseSigning) {
    $debugKeystorePath = Join-Path $env:USERPROFILE ".android\\debug.keystore"
    Ensure-DebugKeystore -KeystorePath $debugKeystorePath

    $env:ANDROID_DEBUG_KEYSTORE = $debugKeystorePath
    $env:ANDROID_DEBUG_KEYSTORE_PASSWORD = "android"
    $env:ANDROID_DEBUG_KEY_ALIAS = "androiddebugkey"
    $env:ANDROID_DEBUG_KEY_PASSWORD = "android"
    $env:USE_DEBUG_SIGNING_FOR_RELEASE = "true"
}

$buildArgs = @("build", "apk")

if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
}

if ($BuildNumber) {
    $buildArgs += "--build-number=$BuildNumber"
}

if ($BuildName) {
    $buildArgs += "--build-name=$BuildName"
}

Write-Host "Using Flutter SDK: $resolvedFlutterSdk"
Write-Host "Using Android SDK: $resolvedAndroidSdk"
& flutter @buildArgs
