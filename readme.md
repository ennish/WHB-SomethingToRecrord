# This is a note to record something need for work in WHB

## 1. Quick jdk and maven set
Refer to [jdk_chk.bat](maven/jdk_chk.bat), it will check if java is configured and help to setup jdk environment.


## 2. Maven Cert issue(PKIX issue)
Refer to [cert_add.ps1](maven/cert_add.ps1)，it will download cert from maven repo and add to jdk certs.
usage:
```powershell
.\cert_add.ps1 -KeystorePassword [Optional, default 'changeit'] -Alias [Optional, default 'MavenCentral']
```

## 3. Something to set up in vscode for vscode extension to work well.
Setup *java.home*  and  *maven executable path* in vscode.