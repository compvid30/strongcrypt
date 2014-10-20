#define MyAppName "StrongCrypt"
#define MyAppVersion "5.3"
#define MyAppPublisher "StrongCrypt.org"
#define MyAppURL "http://www.strongcrypt.org/"
#define MyAppExeName "StrongCrypt.exe"

[Setup]
AppId={{46F01DBD-CDC2-46D9-865B-B4197D5FE988}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename=setup
Compression=lzma/ultra
SolidCompression=yes
WizardImageFile=wizimages\wizbig.bmp
WizardSmallImageFile=wizimages\wizsmall.bmp

[Messages]
BeveledLabel={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\bin\PC\StrongCrypt.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\\bin\PC\amd64\SCCypherAES_gm.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCCypherSerpent_gm.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCCypherTWOFISH_gm.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCHashRIPEMD.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCHashSHA.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCHashWhirlpool.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\amd64\SCMain.sys"; DestDir: "{app}\amd64"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCCypherAES_gm.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCCypherSerpent_gm.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCCypherTWOFISH_gm.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCHashRIPEMD.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCHashSHA.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCHashWhirlpool.sys"; DestDir: "{app}\x86"; Flags: ignoreversion
Source: "..\..\bin\PC\x86\SCMain.sys"; DestDir: "{app}\x86"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Parameters: "/drivercontrol install /filename all"

[UninstallRun]
Filename: "{app}\{#MyAppExeName}"; Parameters: "/drivercontrol uninstall /filename all"
