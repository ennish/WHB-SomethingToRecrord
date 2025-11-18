# Environment set up in HKHS

## 1. Basic env setup

### * Set jdk path

Just run [jdk_chk script](jdk_chk.bat)

### * Setting in vscode

Setup java.home in vscode
Setup maven executable path in vscode



## 2. PKIV issue

Run the script to download cert and add to jre
```bash
.\cert_add.ps1 -KeystorePassword "changeit" -Alias "MavenCentral"
```