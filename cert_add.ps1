# ExportAndImportMavenCert.ps1
# Purpose: Export Maven certificate and import into JRE

param(
    [Parameter(Mandatory=$false)]
    [string]$MavenUrl = "https://repo.maven.apache.org/maven2",
    [string]$MavenUrlNoProtocol = "repo.maven.apache.org",
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = ".\certs",
    
    [Parameter(Mandatory=$false)]
    [string]$KeystorePassword = "changeit",
    
    [Parameter(Mandatory=$false)]
    [string]$Alias = "MavenRepo"
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$certFileName = "maven_cert_$timestamp.cer"
$TempCertPath = Join-Path $OutputDir $certFileName
$Alias =   $Alias + $timestamp

try {
    Write-Host "=== Maven Certificate Export & Import ===" -ForegroundColor Cyan
    
    # Step 1: Validate JAVA_HOME
    if (-not $env:JAVA_HOME) {
        throw "JAVA_HOME environment variable is not set"
    }
    
    $keytool = "$env:JAVA_HOME\bin\keytool.exe"
    $cacerts = "$env:JAVA_HOME\jre\lib\security\cacerts"
    
    if (-not (Test-Path $keytool)) {
        throw "keytool not found: $keytool"
    }
    
    Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
    
    # Step 2: Export certificate
    Write-Host "`n[STEP 1] Exporting certificate from Maven repository..." -ForegroundColor Magenta
    if (-not (Test-Path $OutputDir)) {
        Write-Host "Creating directory: $OutputDir" -ForegroundColor Yellow
        $null = New-Item -ItemType Directory -Path $OutputDir -Force:$Force
    }
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect($MavenUrlNoProtocol, 443)
    
    $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
    $sslStream.AuthenticateAsClient($MavenUrlNoProtocol)
    
    $certificate = $sslStream.RemoteCertificate
    $certBytes = $certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    [System.IO.File]::WriteAllBytes($TempCertPath, $certBytes)
    
    $sslStream.Close()
    $tcpClient.Close()
    
    if (-not (Test-Path $TempCertPath)) {
        throw "Certificate export failed"
    }
    
    Write-Host "Certificate exported: $TempCertPath" -ForegroundColor Green
    
    # Step 3: Import certificate
    Write-Host "`n[STEP 2] Importing certificate into JRE..." -ForegroundColor Magenta
    
    $importArgs = @(
        "-import", "-trustcacerts",
        "-alias", $Alias,
        "-file", $TempCertPath,
        "-keystore", $cacerts,
        "-storepass", $KeystorePassword,
        "-noprompt"
    )
    
    & $keytool $importArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Certificate import failed. Exit code: $LASTEXITCODE"
    }
    
    Write-Host "Certificate imported successfully" -ForegroundColor Green
    
    # Step 4: Verify import
    Write-Host "`n[STEP 3] Verifying certificate..." -ForegroundColor Magenta
    
    & $keytool -list -alias $Alias -keystore $cacerts -storepass $KeystorePassword
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Certificate verification successful" -ForegroundColor Green
    }
    
    Write-Host "`n=== PROCESS COMPLETED ===" -ForegroundColor Cyan
    Write-Host "Maven certificate exported and imported" -ForegroundColor Gray
    Write-Host "Alias: $Alias" -ForegroundColor Gray
    Write-Host "Keystore: $cacerts" -ForegroundColor Gray
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup
    if (Test-Path $TempCertPath) {
        Remove-Item $TempCertPath -ErrorAction SilentlyContinue
    }
}