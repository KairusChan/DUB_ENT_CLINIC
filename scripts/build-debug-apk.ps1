$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot
$javaDirectory = Get-ChildItem -LiteralPath "$projectRoot/.build-tools/java" -Directory | Select-Object -First 1
if (!$javaDirectory) { throw 'Java 21 must be extracted into .build-tools/java first.' }
$env:JAVA_HOME = $javaDirectory.FullName
$env:PATH = "$env:JAVA_HOME/bin;$env:PATH"
$env:GRADLE_USER_HOME = "$projectRoot/.build-tools/gradle"
$env:ANDROID_USER_HOME = "$projectRoot/.build-tools/android-user"
$env:ANDROID_HOME = "$env:LOCALAPPDATA/Android/Sdk"
$env:GRADLE_OPTS = '-Djavax.net.ssl.trustStoreType=Windows-ROOT -Djavax.net.ssl.trustStore=NONE'
$sdkDirectory = $env:ANDROID_HOME.Replace('\','/')
Set-Content -LiteralPath "$projectRoot/android/local.properties" -Value "sdk.dir=$sdkDirectory" -Encoding ascii
& npm.cmd run build:mobile
if ($LASTEXITCODE -ne 0) { throw 'Mobile web build failed.' }
& npx.cmd cap sync android
if ($LASTEXITCODE -ne 0) { throw 'Android sync failed.' }
Push-Location -LiteralPath "$projectRoot/android"
try {
    & .\gradlew.bat --no-daemon --console=plain assembleDebug
    if ($LASTEXITCODE -ne 0) { throw 'APK compilation failed.' }
} finally { Pop-Location }
New-Item -ItemType Directory -Force -Path "$projectRoot/artifacts" | Out-Null
Copy-Item -LiteralPath "$projectRoot/android/app/build/outputs/apk/debug/app-debug.apk" -Destination "$projectRoot/artifacts/ENT-Clinic-debug.apk" -Force
Get-Item -LiteralPath "$projectRoot/artifacts/ENT-Clinic-debug.apk" | Select-Object FullName,Length
