$filename = ".env"

if (-not (Test-Path $filename)) {
    Write-Error "Error: File .env not found."
    exit 1
}

Get-Content $filename | ForEach-Object {
    $line = $_.Trim()

    if ([string]::IsNullOrEmpty($line)) {
        continue
    }

    if ($line.StartsWith("#")) {
        continue
    }

    if ($line -like "*=*") {
        $parts = $line.Split('=', 2)
        $var_name = $parts[0].Trim()
        $var_value = $parts[1].Trim()

        if (-not ([string]::IsNullOrEmpty($var_name)) -and -not ([string]::IsNullOrEmpty($var_value))) {
            $env:$var_name = $var_value
            Write-Host "Exported: $var_name=$env:$var_name"
        } else {
            Write-Host "Ignored (wrong format or empty value): $line"
        }
    } else {
        Write-Host "Ignored (wrong format or empty value): $line"
    }
}

Write-Host ""
Write-Host "IDEMPIERE_REPOSITORY: $($env:IDEMPIERE_REPOSITORY)"

Write-Host ""
java -version
mvn -v

set DEBUG_MODE=

set PLUGINS_PATH=%*

if "%1" == "debug" (
  set DEBUG_MODE=-X
  call set PLUGINS_PATH=%%PLUGINS_PATH:*%1=%%
)

javac TargetPlatformPomGenerator.java
java TargetPlatformPomGenerator %PLUGINS_PATH%
call mvn validate -Didempiere.target=com.ingeint.template.p2.targetplatform %DEBUG_MODE%
call mvn verify -Didempiere.target=com.ingeint.template.p2.targetplatform %DEBUG_MODE%
javac TargetPlatformPluginTagger.java
java TargetPlatformPluginTagger %PLUGINS_PATH%
