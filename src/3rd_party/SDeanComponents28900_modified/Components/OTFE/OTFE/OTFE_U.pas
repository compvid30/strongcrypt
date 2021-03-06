unit OTFE_U;
// Description: Abstract base class for OTF Encryption systems
// By Sarah Dean
// Email: sdean12@sdean12.org
// WWW:   http://www.SDean12.org/
//
// -----------------------------------------------------------------------------
//


// -----------------------------------------------------------------------------
interface

// -----------------------------------------------------------------------------
uses
  classes,
  Windows, // Needed for UINT, ULONG
  sysUtils,
  OTFEConsts_U;

// -----------------------------------------------------------------------------
const
  VERSION_ID_FAILURE = $FFFFFFFF;

// -- begin Windows standard bits taken from "dbt.h", not included with Delphi --
const
  DBT_DEVICEARRIVAL        = $8000;  // System detected a new device
  DBT_DEVICEREMOVEPENDING  = $8003;  // About to remove, still available
  DBT_DEVICEREMOVECOMPLETE = $8004;  // Device has been removed
  DBT_DEVNODES_CHANGED     = $0007;  // Some added or removed - update yourself

  DBT_DEVTYP_VOLUME = $00000002;  // logical volume

type
  DEV_BROADCAST_HDR = packed record
    dbch_size: ULONG;
    dbch_devicetype: ULONG;
    dbch_reserved: ULONG;
  end;
  PDEV_BROADCAST_HDR = ^DEV_BROADCAST_HDR;

  DEV_BROADCAST_VOLUME = packed record
    dbch_size: ULONG;
    dbch_devicetype: ULONG;
    dbch_reserved: ULONG;
    dbcv_unitmask: ULONG;
    dbcv_flags: WORD;  // USHORT
    dummy: WORD;  // Padding to word boundry
  end;
  PDEV_BROADCAST_VOLUME = ^DEV_BROADCAST_VOLUME;

// -- end Windows standard bits taken from "dbt.h", not included with Delphi --


// -----------------------------------------------------------------------------
type

  TOTFE = class(TComponent)
  private
    { private declarations here}
  protected
    FActive: boolean;
    FLastErrCode: integer; // See OTFEConsts_U.pas
    procedure DestroyString(var theString: string);
    procedure DestroyTStringList(theTStringList: TStringList);
    function  SortString(theString: string): string;

    // Set the component active/inactive
    // Note: Must raise exception if status is set to TRUE, but the component
    //       cannot be set to this state
    procedure SetActive(status: Boolean); virtual;

    // Raises exception if the component isn't active
    // Returns FActive (TRUE/FALSE)
    function  CheckActive(): boolean;

    // Broadcast a message, notifying everyone that a drive has been
    // added/removed
    // addedNotRemoved - Set to TRUE to broadcast that the specified drive
    //                   letter has just been added, or FALSE to broadcast it's
    //                   removal
    procedure BroadcastDriveChangeMessage(addedNotRemoved: boolean; driveLetter: char); overload;
    // devChangeEvent - Set to DBT_DEVICEREMOVEPENDING/DBT_DEVICEREMOVECOMPLETE/DBT_DEVICEARRIVAL
    procedure BroadcastDriveChangeMessage(devChangeEvent: cardinal; driveLetter: char); overload;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy(); override;

    // === Mounting, dismounting drives ========================================

    // Prompt the user for a password (and drive letter if necessary), then
    // mount the specified volume file
    // Returns the drive letter of the mounted volume on success, #0 on failure
    function  Mount(volumeFilename: string; readonly: boolean = FALSE): char; overload; virtual; abstract;

    // As previous Mount, but more than one volumes is specified. Volumes are
    // mounted using the same password
    // Sets mountedAs to the drive letters of the mounted volumes, in order.
    // Volumes that could not be mounted have #0 as their drive letter
    // Returns TRUE if any of the volumes mounted correctly, otherwise FALSE
    function  Mount(volumeFilenames: TStringList; var mountedAs: string; readonly: boolean = FALSE): boolean; overload; virtual; abstract;
    // Example:
    //   Set:
    //     volumeFilenames[0] = c:\test0.dat
    //     volumeFilenames[1] = c:\test1.dat
    //     volumeFilenames[2] = c:\test2.dat
    //   Call Mount described above in which:
    //     volume test0.dat was sucessfully mounted as W:
    //     volume test1.dat failed to mount
    //     volume test2.dat was sucessfully mounted as X:
    //   Then this function should set:
    //     mountedAs = 'W.X' (where '.' is #0)

    // Given the "mountedAs" parameter set by the above Mount(...) function,
    // this will give a count of the number of volumes mounted successfully, and failed
    procedure CountMountedResults(mountedAs: string; out CntMountedOK: integer; out CntMountFailed: integer); virtual;


    // Prompt the user for a device (if appropriate) and password (and drive
    // letter if necessary), then mount the device selected
    // Returns the drive letter of the mounted devices on success, #0 on failure
    function  MountDevices(): string; virtual; abstract;

    // Determine if OTFE component can mount devices.
    // Returns TRUE if it can, otherwise FALSE
    function  CanMountDevice(): boolean; virtual; abstract;


    // Work out the order in which to dismount drives, taking into account
    // the potential for one drive to be mounted within another
    // Returns "dismountDrives" in the order in which they should be dismounted
    function  DismountOrder(dismountDrives: string): string;

    // Dismount by volume filename
    // Returns TRUE on success, otherwise FALSE
    function  Dismount(volumeFilename: string; emergency: boolean = FALSE): boolean; overload; virtual; abstract;

    // Dismount by drive letter
    // Returns TRUE on success, otherwise FALSE
    function  Dismount(driveLetter: char; emergency: boolean = FALSE): boolean; overload; virtual; abstract;

    // Dismount all mounted drives
    // Returns a string containing the drive letters for all drives that could
    // not be dismounted
    function  DismountAll(emergency: boolean = FALSE): string; virtual;

    // === Miscellaneous =======================================================

    // Returns the human readable name of the OTFE product the component
    // supports (e.g. "CrossCrypt", "ScramDisk")
    // Returns '' on error
    function  Title(): string; overload; virtual; abstract;

    // Returns TRUE if the underlying driver is installed and the component can
    // be used, otherwise FALSE
    function  IsDriverInstalled(): boolean; overload; virtual;

    // Returns version ID of underlying driver (VERSION_ID_FAILURE on error)
    // (Returns cardinal and not string representation in order to facilitate
    // processing of the version number by the calling function)
    function  Version(): cardinal; virtual; abstract;

    // Returns version ID of underlying driver ('' on error)
    function  VersionStr(): string; virtual; abstract;

    // Check version is at least "minVersion"
    function  CheckVersionAtLeast(minVersion: cardinal): boolean; virtual;

    // Returns TRUE if the file specified appears to be an encrypted volume file
    function  IsEncryptedVolFile(volumeFilename: string): boolean; virtual; abstract;

    // Returns a string containing the drive letters (in uppercase) of all
    // mounted drives (e.g. 'DGH') in alphabetical order
    function  DrivesMounted(): string; virtual; abstract;

    // Returns a count of drives mounted (included for completeness)
    function  CountDrivesMounted(): integer; virtual;

    // Returns the volume filename for a given mounted drive
    // (empty string on failure)
    function  GetVolFileForDrive(driveLetter: char): string; virtual; abstract;

    // Returns the drive letter for a mounted volume file
    // (#0 on failure)
    function  GetDriveForVolFile(volumeFilename: string): char; virtual; abstract;

    // Check to see if there are any volume files mounted on the given drive
    // Returns the drive letters of any mounted volumes
    function  VolsMountedOnDrive(driveLetter: char): string; virtual;

    // Test to see if the specified drive is readonly
    // Returns TRUE if the drive is readonly, otherwise FALSE
    function  IsDriveReadonly(driveLetter: char): boolean; virtual;

    // Returns a string describing the last error
    function  GetLastErrorMsg(): string; virtual;

    // Returns a string containing the main executable to the OTF crypto system
    // (the one used mounting, if there's more than one executable)
    // Returns "" on error
    function  GetMainExe(): string; virtual; abstract;

    // Returns a disk-encryption specific record containing information on the
    // specified encrypted drive
    //
    // (Can't represent in the base class, but...)
    // function GetDriveInfo(driveLetter: char): TDiskInfo; virtual; abstract;

  published
    property Active: boolean read FActive write SetActive;
    property LastErrorCode: integer read FLastErrCode write FLastErrCode default OTFE_ERR_SUCCESS;

  end;


// Helper function to take a string containing driveletters, and generates a
// prettyprinted version
// e.g. DFGI -> D:, F:, G:, I:
// Any #0 characters in the string passed in will be ignored
function PrettyPrintDriveLetters(driveLetters: string): string;

// Returns the number of characters in "driveLetters" which aren't #0
function CountValidDrives(driveLetters: string): integer;

// Change CWD to anywhere other than a mounted drive
// This must be done before any dismount, in case the user changed the CWD to a
// dir stored within the drive to be dismounted (e.g. by mounting another
// volume stored within that mounted drive - the mount dialog would change the
// CWD)
procedure ChangeCWDToSafeDir();


// -----------------------------------------------------------------------------
implementation

uses
  ShlObj,  // Needed for SHChangeNotify(...), etc
  Messages,  // Needed for WM_DEVICECHANGE
  SDUGeneral;


// -----------------------------------------------------------------------------
function PrettyPrintDriveLetters(driveLetters: string): string;
var
  i: integer;
  retval: string;
  validLetters: string;
begin
  retval := '';

  validLetters := '';
  for i:=1 to length(driveLetters) do
    begin
    if (driveLetters[i] <> #0) then
      begin
      validLetters := validLetters + driveLetters[i];
      end;
    end;

  for i:=1 to length(validLetters) do
    begin
    if (retval <> '') then
      begin
      retval := retval + ', ';
      end;

    retval := retval + validLetters[i] + ':';
    end;

  Result := retval;
end;

// -----------------------------------------------------------------------------
function CountValidDrives(driveLetters: string): integer;
var
  i: integer;
  retval: integer;
begin
  retval := 0;

  for i:=1 to length(driveLetters) do
    begin
    if (driveLetters[i] <> #0) then
      begin
      inc(retval);
      end;
    end;
    
  Result := retval;
end;

// -----------------------------------------------------------------------------
procedure ChangeCWDToSafeDir();
var
  windowsDir: string;
begin
  windowsDir := SDUGetSpecialFolderPath(SDU_CSIDL_WINDOWS);
  SDUSetCurrentWorkingDirectory(windowsDir);
end;

// -----------------------------------------------------------------------------
constructor TOTFE.Create(AOwner: TComponent);
begin
  inherited;
  FActive := FALSE;
  FLastErrCode:= OTFE_ERR_SUCCESS;

end;

// -----------------------------------------------------------------------------
destructor  TOTFE.Destroy();
begin
  inherited;

end;

// -----------------------------------------------------------------------------
// Destroy the contents of the supplied TStringList
procedure TOTFE.DestroyTStringList(theTStringList: TStringList);
var
  i: integer;
  j: integer;
begin
  randomize();
  for i:=0 to (theTStringList.Count-1) do
    begin
    for j:=0 to length(theTStringList[i]) do
      begin
      theTStringList[i] := format('%'+inttostr(length(theTStringList[i]))+'s', [chr(random(255))]);
      end;
    end;

  theTStringList.Clear();

end;

// -----------------------------------------------------------------------------
// Destroy the contents of the supplied string
procedure TOTFE.DestroyString(var theString: string);
var
  i: integer;
begin
  randomize();
  for i:=0 to length(theString) do
    begin
    theString := format('%'+inttostr(length(theString))+'s', [chr(random(255))]);
    end;

end;

// -----------------------------------------------------------------------------
// Returns a string describing the last error
// If no error, returns an empty string
function TOTFE.GetLastErrorMsg(): string;
begin
  Result := ''; // OTFE_ERR_SUCCESS

  case FLastErrCode of

    // See OTFEConsts_U.pas for descriptions

    OTFE_ERR_NOT_ACTIVE                : Result := 'Component not active';
    OTFE_ERR_DRIVER_FAILURE            : Result := 'Driver failure';
    OTFE_ERR_USER_CANCEL               : Result := 'User cancelled operation';
    OTFE_ERR_WRONG_PASSWORD            : Result := 'Wrong password entered';
    OTFE_ERR_VOLUME_FILE_NOT_FOUND     : Result := 'Volume file not found';
    OTFE_ERR_INVALID_DRIVE             : Result := 'Invalid drive';
    OTFE_ERR_MOUNT_FAILURE             : Result := 'Mount failure';
    OTFE_ERR_DISMOUNT_FAILURE          : Result := 'Dismount failure';
    OTFE_ERR_FILES_OPEN                : Result := 'Files open on volume';
    OTFE_ERR_STREAMING_DATA            : Result := 'Can''t dismount while still streaming data, or was doing so in the last few seconds';
    OTFE_ERR_FILE_NOT_ENCRYPTED_VOLUME : Result := 'File is not an encrypted volume';
    OTFE_ERR_UNABLE_TO_LOCATE_FILE     : Result := 'Unable to locate file';
    OTFE_ERR_DISMOUNT_RECURSIVE        : Result := 'Dismounting recursivly mounted drive';
    OTFE_ERR_INSUFFICENT_RIGHTS        : Result := 'Insufficient rights';
    OTFE_ERR_NOT_W9X                   : Result := 'Operation not available under Windows 95/98/ME';
    OTFE_ERR_NOT_WNT                   : Result := 'Operation not available under Windows NT/2000';
    OTFE_ERR_NO_FREE_DRIVE_LETTERS     : Result := 'There are no free drive letters';

    // BestCrypt
    OTFE_ERR_UNKNOWN_ALGORITHM         : Result := 'Unknown algorithm';
    OTFE_ERR_UNKNOWN_KEYGEN            : Result := 'Unknown key generator';

    // ScramDisk
    OTFE_ERR_UNABLE_MOUNT_COMPRESSED   : Result := 'Can''t mount compressed volume';

    // PANIC!
    OTFE_ERR_UNKNOWN_ERROR             : Result := 'Unknown error';
  end;

end;

// -----------------------------------------------------------------------------
// Returns the number of drives mounted
function TOTFE.CountDrivesMounted(): integer;
begin
  FLastErrCode:= OTFE_ERR_SUCCESS;
  Result := length(DrivesMounted());

end;

// -----------------------------------------------------------------------------
// Dismounts all mounted drives
function TOTFE.DismountAll(emergency: boolean = FALSE): string;
var
  drvsMounted: string;
  badUnmount: string;
  i: integer;
begin
  FLastErrCode:= OTFE_ERR_SUCCESS;
  drvsMounted := DrivesMounted();
  badUnmount := '';

  // Dismount in correct order!
  drvsMounted := DismountOrder(drvsMounted);

  for i:=1 to length(drvsMounted) do
    begin
    if not(Dismount(drvsMounted[i], emergency)) then
      begin
      FLastErrCode:= OTFE_ERR_DISMOUNT_FAILURE;
      badUnmount := badUnmount + drvsMounted[i];
      end;
    end;

  Result := badUnmount;

end;

// -----------------------------------------------------------------------------
// Returns TRUE if the underlying driver is installed and the component can
// be used, otherwise FALSE
function TOTFE.IsDriverInstalled(): boolean;
begin
  Result := TRUE;
  FLastErrCode:= OTFE_ERR_SUCCESS;

  if not(Active) then
    begin
    try
      Active := TRUE;
    except
    end;

    Result := Active;
    Active := FALSE;
    end;

  if not(Result) then
    begin
    FLastErrCode:= OTFE_ERR_DRIVER_FAILURE;
    end;

end;

// -----------------------------------------------------------------------------
// Check version is at least "minVersion"
function TOTFE.CheckVersionAtLeast(minVersion: cardinal): boolean;
begin
  Result := (
             (Version() <> VERSION_ID_FAILURE) and
             (Version() >= minVersion)
            );
end;


// -----------------------------------------------------------------------------
// Set the component active/inactive
// [IN] status - the status of the component
procedure TOTFE.SetActive(status: Boolean);
begin
  FLastErrCode:= OTFE_ERR_SUCCESS;
  FActive := status;

end;

// -----------------------------------------------------------------------------
// Sort the contents of a string into alphabetical order, assuming each char
// only appears once.
function TOTFE.SortString(theString: string): string;
var
  output: string;
  i: integer;
begin
  output := '';
  for i:=ord('A') to ord('Z') do
    begin
    if pos(chr(i), theString)>0 then
      begin
      output := output + chr(i);
      end;
    end;

  Result := output;

end;

// -----------------------------------------------------------------------------
// Raises exception if the component isn't active
// Returns FActive (TRUE/FALSE)
function TOTFE.CheckActive(): boolean;
begin
  FLastErrCode:= OTFE_ERR_SUCCESS;
  if not(FActive) then
    begin
    FLastErrCode := OTFE_ERR_NOT_ACTIVE;
    raise EOTFEException.Create(OTFE_EXCPT_NOT_ACTIVE);
    end;

  Result := FActive;

end;

// -----------------------------------------------------------------------------
// Check to see if there are any volume files mounted on the given drive
// Returns the drive letters of any mounted volumes
function TOTFE.VolsMountedOnDrive(driveLetter: char): string;
var
  mountedDrives: string;
  volFilename: string;
  retval: string;
  i: integer;
begin
  retval := '';

  driveLetter := upcase(driveLetter);

  mountedDrives := DrivesMounted();

  for i:=1 to length(mountedDrives) do
    begin
    volFilename := GetVolFileForDrive(mountedDrives[i]);
    volFilename := uppercase(volFilename);

    if (length(volFilename)>=3) then
      begin
      if (volFilename[2]=':') and
         (volFilename[3]='\') or (volFilename[3]='/') then
        begin
        if (volFilename[1]=driveLetter) then
          begin
          retVal := retVal + mountedDrives[i];
          end;
        end;

      end;
    end;

  Result := retval;

end;

// -----------------------------------------------------------------------------
// Work out the order in which to dismount drives, taking into account
// the potential for one drive to be mounted within another
// Returns "dismountDrives" in the order in which they should be dismounted
function TOTFE.DismountOrder(dismountDrives: string): string;
var
  unorderedDrives: string;
  unorderedDrivesHosts: string;
  sortedDrives: string;
  sortedDrivesHosts: string;
  tmpDrives: string;
  tmpDrivesHosts: string;
  i: integer;
  volFilename: string;
  hostDrive: char;
begin
  unorderedDrives := dismountDrives;
  // Get all host drive letters for recursivly mounted drives
  unorderedDrivesHosts := '';
  for i:=1 to length(dismountDrives) do
    begin
    volFilename := GetVolFileForDrive(dismountDrives[i]);
    volFilename := uppercase(volFilename);

    hostDrive := #0;
    if (length(volFilename)>=3) then
      begin
      if (volFilename[2]=':') and
         (volFilename[3]='\') or (volFilename[3]='/') then
        begin
        hostDrive := volFilename[1];
        end;

      end;

    unorderedDrivesHosts := unorderedDrivesHosts + hostDrive;
    end;


  // NOTE: AT THIS STAGE, unorderedDrives and unorderedDrivesHosts are in the
  //       same order; unorderedDrivesHosts[X] is the host drive for
  //       unorderedDrives[X], with unorderedDrivesHosts[X] set to #0 if it's
  //       not hosted on a mounted drive
  

  // Finally, get the drives into the order in which they should be dismounted
  // in...
  sortedDrives := '';
  sortedDrivesHosts:= '';
  while (length(unorderedDrives)>0) do
    begin
    tmpDrives := '';
    tmpDrivesHosts:= '';

    for i:=1 to length(unorderedDrives) do
      begin
      if ((Pos(unorderedDrivesHosts[i], dismountDrives)=0) or
          (Pos(unorderedDrivesHosts[i], sortedDrives)>0)) then
        begin
        sortedDrives := unorderedDrives[i] + sortedDrives;
        sortedDrivesHosts := unorderedDrivesHosts[i] + sortedDrivesHosts;
        end
      else
        begin
        tmpDrives := unorderedDrives[i] + tmpDrives;
        tmpDrivesHosts := unorderedDrivesHosts[i] + tmpDrivesHosts;
        end;

      end;

    unorderedDrives := tmpDrives;
    unorderedDrivesHosts := tmpDrivesHosts;

    end;

  Result := sortedDrives;

end;


// -----------------------------------------------------------------------------
// devChangeEvent - Set to DBT_DEVICEREMOVEPENDING/DBT_DEVICEREMOVECOMPLETE/DBT_DEVICEARRIVAL
procedure TOTFE.BroadcastDriveChangeMessage(devChangeEvent: cardinal; driveLetter: char);
var
  dbv: DEV_BROADCAST_VOLUME;
  unitMask: ULONG;
  i: char;
  ptrBroadcast: PByte;
  dwRecipients: DWORD;
begin
  ptrBroadcast := nil;
  if (devChangeEvent <> DBT_DEVNODES_CHANGED) then
    begin
    driveLetter := upcase(driveLetter);

    unitMask := 1;
    for i:='B' to driveLetter do
      begin
      unitMask := unitMask shl 1;
      end;

    dbv.dbch_size       := sizeof(dbv);
    dbv.dbch_devicetype := DBT_DEVTYP_VOLUME;
    dbv.dbch_reserved   := 0;
    dbv.dbcv_unitmask   := unitMask;
    dbv.dbcv_flags      := 0;

    ptrBroadcast := SysGetMem(sizeof(dbv));
    Move(dbv, ptrBroadcast^, sizeof(dbv));
    end;

  try
{
    // Don't use PostMessage(...) here!
    // If we use PostMessage(...) on mounting, Windows explorer will show the new
    // drive... And a second later, remove it from its display!
    SendMessage(
                HWND_BROADCAST,
                WM_DEVICECHANGE,
                devChangeEvent,
                lParam
               );
}
    dwRecipients := BSM_APPLICATIONS;
    BroadcastSystemMessage(
                           (
                            BSF_IGNORECURRENTTASK or
                            BSF_POSTMESSAGE or
                            BSF_FORCEIFHUNG
{
                            BSF_NOHANG
                            BSF_NOTIMEOUTIFNOTHUNG
}
                           ),
                           @dwRecipients,
                           //BSM_ALLCOMPONENTS
                           WM_DEVICECHANGE,
                           devChangeEvent,
                           integer(ptrBroadcast)
                          );
  finally
    if (ptrBroadcast <> nil) then
      begin
      SysFreeMem(ptrBroadcast);
      end;
  end;

  // Sleep briefly to allow things to settle down
// Not needed now that using SysGetmem(...)/SysFreemem(...) instead of
// AllocMem(...)/<nothing!>
//  sleep(500);
end;


// -----------------------------------------------------------------------------
procedure TOTFE.BroadcastDriveChangeMessage(addedNotRemoved: boolean; driveLetter: char);
var
  wndWParam: cardinal;
  drivePath: string;
  ptrDrive: Pointer;
//UNICODE TEST -  ptrDrive: PWideChar;
begin
  driveLetter := upcase(driveLetter);

  drivePath := driveLetter + ':\'+#0;
  // +1 to include terminating NULL
  ptrDrive := SysGetMem((length(drivePath) + 1));
//UNICODE TEST -  ptrDrive := SysGetMem(((length(drivePath) + 1)*sizeof(WCHAR)));
  try
    StrMove(ptrDrive, PChar(drivePath), length(drivePath));
//UNICODE TEST -    // Convert to UNICODE
//UNICODE TEST -    StringToWideChar(drivePath, ptrDrive, (length(drivePath)+1));

    if addedNotRemoved then
      begin
      wndWParam := DBT_DEVICEARRIVAL;
      SHChangeNotify(SHCNE_DRIVEADD, SHCNF_PATH, ptrDrive, nil);
//UNICODE TEST -          SHChangeNotify(SHCNE_DRIVEADD, SHCNF_PATHW, ptrDrive, nil);

      // Update dir is required in order to get Explorer's treeview to
      // correctly display the newly mounted volume's label and drive letter.
      // Note: atm, we're setting this to the drive which has been added,
      //       though it looks like Windows actually sends a NULL/empty string
      //       here
      //
      // Amusing side note to the TrueCrypt developers: You've been missing
      // this since TrueCrypt v3.1, and had this fault reported in your forums
      // many times by different users over the years. It might be worth your
      // adding something like this into TrueCrypt to resolve the problem? ;)
      SHChangeNotify(SHCNE_UPDATEDIR, SHCNF_PATH, ptrDrive, nil);
//UNICODE TEST -          SHChangeNotify(SHCNE_UPDATEDIR, SHCNF_PATHW, ptrDrive, nil);
      end
    else
      begin
      wndWParam := DBT_DEVICEREMOVECOMPLETE;
      SHChangeNotify(SHCNE_DRIVEREMOVED, SHCNF_PATH, ptrDrive, nil);
//UNICODE TEST -          SHChangeNotify(SHCNE_DRIVEREMOVED, SHCNF_PATHW, ptrDrive, nil);
      end;

  finally
    SysFreeMem(ptrDrive);
  end;

  BroadcastDriveChangeMessage(DBT_DEVNODES_CHANGED, driveLetter);
  BroadcastDriveChangeMessage(wndWParam, driveLetter);
  if addedNotRemoved then
    begin
    BroadcastDriveChangeMessage(DBT_DEVNODES_CHANGED, driveLetter);
    end;

end;


// -----------------------------------------------------------------------------
// Test to see if the specified drive is readonly
// Returns TRUE if the drive is readonly, otherwise FALSE
function  TOTFE.IsDriveReadonly(driveLetter: char): boolean;
  function GenerateRandomFilename(): string;
    var
      outputFilename: string;
      i: integer;
    begin
      outputFilename := '';
      for i:=1 to 20 do
        begin
        outputFilename := outputFilename + chr(ord('A')+random(26));
        end;

      Result := outputFilename;
    end;

var
  F: TextFile;
  OldMode: UINT;
  I: Integer;
  rndFilename: string;
begin
  Result := FALSE;
  // This function has been tested, and works OK if the disk is full
  // This function has been tested, and works OK if the root directory is full of
  // files, and no more can be added

  randomize();
  rndFilename := driveLetter + ':\'+ GenerateRandomFilename();
  while FileExists(rndFilename) do
    begin
    rndFilename := driveLetter + ':\'+ GenerateRandomFilename();
    end;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
{$I-}
  AssignFile(F, rndFilename);  // File you want to write to here.
  Rewrite(F);
{$I+}
  I := IOResult;
  SetErrorMode(OldMode);
  if I <> 0 then
    begin
    Result := ((I AND $FFFFFFFF)=ERROR_WRITE_PROTECT);
    end
  else
    begin
    CloseFile(F);
    SysUtils.DeleteFile(rndFilename);
    end;

end;


// -----------------------------------------------------------------------------
// Given the "mountedAs" parameter set by the above Mount(...) function,
// this will give a count of the number of volumes mounted successfully, and failed
procedure TOTFE.CountMountedResults(mountedAs: string; out CntMountedOK: integer; out CntMountFailed: integer);
var
  i: integer;
begin
  CntMountedOK := 0;
  CntMountFailed := 0;

  for i:=1 to length(mountedAs) do
    begin
    if (mountedAs[i] = #0) then
      begin
      inc(CntMountFailed);
      end
    else
      begin
      inc(CntMountedOK);
      end;
    end;

end;

// -----------------------------------------------------------------------------

END.


