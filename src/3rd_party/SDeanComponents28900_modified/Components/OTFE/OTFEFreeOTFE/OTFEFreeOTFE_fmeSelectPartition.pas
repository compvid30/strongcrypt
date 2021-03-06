unit OTFEFreeOTFE_fmeSelectPartition;

interface

// NOTE: The "Tabs" property of the TTabControl has the tab captions as it's
//       strings (as per normal), but each of the TStringList's Object's is a
//       DWORD.
//       If the DWORD's highest WORD is HIWORD_CDROM, the lowest WORD is an
//       index into FRemovableDevices
//       If the DWORD's highest WORD is HIWORD_DISK, the lowest WORD is a disk
//       number

// NOTE: This frame can act "oddly" if it's put on a TTabSheet; controls set
//       as "Visible := FALSE" were being set to non-visible, but were still
//       visible on the display. To fix this, the code segment marked
//       "[TAB_FIX]" in this source was put in, which seems to cure things
//       PROVIDED THAT Initialize(...) is called after the tab is selected for
//       the first time.
//       THIS *SHOULDN'T* BE NEEDED - but is!!!

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, SDUBlocksPanel, SDUDiskPartitionsPanel, ComCtrls,
  OTFEFreeOTFEBase_U,
  SDUGeneral, ImgList, Menus, OTFEFreeOTFE_DiskPartitionsPanel, ActnList;

type
  TfmeSelectPartition = class(TFrame)
    TabControl1: TTabControl;
    SDUDiskPartitionsPanel1: TOTFEFreeOTFEDiskPartitionsPanel;
    pnlNoPartitionDisplay: TPanel;
    ckShowCDROM: TCheckBox;
    ckEntireDisk: TCheckBox;
    lblErrorWarning: TLabel;
    ilErrorWarning: TImageList;
    imgErrorWarning: TImage;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    actProperties: TAction;
    Properties1: TMenuItem;
    procedure TabControl1Change(Sender: TObject);
    procedure ckShowCDROMClick(Sender: TObject);
    procedure ckEntireDiskClick(Sender: TObject);
    procedure SDUDiskPartitionsPanel1Changed(Sender: TObject);
    procedure actPropertiesExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    FAllowCDROM: boolean;
    FOnChange: TNotifyEvent;

    FRemovableDevices: TStringList;

    function GetSelectedDevice(): string;

    procedure SetPartitionDisplayDisk(diskNo: integer);
    procedure SetAllowCDROM(allow: boolean);
    procedure ShowPartitionControl();

    function GetSyntheticDriveLayout(): boolean;

    procedure PopulateTabs();

    procedure NotifyChanged(Sender: TObject);
    procedure UpdateErrorWarning();
    procedure CenterErrorWarning();

    procedure EnableDisableControls();

    function IsCDROMTabSelected(): boolean;
    procedure SelectionErrorWarning(var msg: string; var isWarning: boolean; var isError: boolean);
  public
    FreeOTFEObj: TOTFEFreeOTFEBase;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure Initialize();
    function SelectedSize(): ULONGLONG;
  published
    property SelectedDevice: string read GetSelectedDevice;
    property AllowCDROM: boolean read FAllowCDROM write SetAllowCDROM default TRUE;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property SyntheticDriveLayout: boolean read GetSyntheticDriveLayout;

  end;

implementation

{$R *.dfm}

uses
  GraphUtil,  // Required for GetHighLightColor(...)
  OTFEFreeOTFE_frmSelectPartition,
  SDUi18n,
  SDUDiskPropertiesDlg,
  SDUPartitionPropertiesDlg;

const
  COLOR_USABLE   = TColor($00C000); // clLime too bright, clGreen too dark
  COLOR_UNUSABLE = TColor($0000E0); // clRed too bright

  // Bitmask - these go up 1, 2, 4, 8, 16, 32, etc in the hi-word
  HIWORD_DISK  = $00010000;
  HIWORD_CDROM = $00020000;
  HIWORD_OTHER = $00040000;
  HIWORD_etc   = $00080000;

  // Images indexes within ilErrorWarning
  ICON_NONE    = 0;
  ICON_WARNING = 1;
  ICON_ERROR   = 2;

resourcestring
  RS_NO_PARTITIONS_FOUND = '<No partitions found>';

  RS_CANT_GET_DISK_LAYOUT = '<Unable to get disk layout information for disk #%1>';
  RS_ENTIRE_DISK_X = '<Entire disk #%1>';
  RS_CDROM_IN_X    = '<CDROM/DVD in %1>';

  RS_DBLCLK_PROMPT_PARTITION = 'Doubleclick partition to display properties';
  RS_DBLCLK_PROMPT_DISK      = 'Doubleclick to display disk properties';

  RS_PARTITION = 'Partition #%1';
  
  RS_PART_ERROR_NO_PARTITION_NO      = 'Windows has not allocated this partition a partition number';
  RS_PART_ERROR_SYSTEM_PARTITION     = 'This is where Windows is installed';
  RS_PART_ERROR_PROG_FILES_PARTITION = 'This is where program files are installed';
  RS_PART_WARN_BOOTABLE              = 'Partition is marked as bootable';


procedure TfmeSelectPartition.ckEntireDiskClick(Sender: TObject);
begin
  ShowPartitionControl();
  NotifyChanged(self);
end;

procedure TfmeSelectPartition.ckShowCDROMClick(Sender: TObject);
begin
  PopulateTabs();
  TabControl1Change(nil);
  NotifyChanged(self);
end;

constructor TfmeSelectPartition.Create(AOwner: TComponent);
begin
  inherited;
  FRemovableDevices := TStringList.Create();
end;

destructor TfmeSelectPartition.Destroy();
begin
  FRemovableDevices.Free();
  inherited;
end;

procedure TfmeSelectPartition.Initialize();
  procedure ToggleControl(ctrl: TControl);
  var
    prevValue: boolean;
  begin
    prevValue := ctrl.Visible;
    ctrl.Visible := FALSE;
    ctrl.Visible := TRUE;
    ctrl.Visible := prevValue;
  end;
begin
  actProperties.Enabled := FALSE;

  SDUDiskPartitionsPanel1.FreeOTFEObj := FreeOTFEObj;

  // -- begin [TAB_FIX] --
  ToggleControl(SDUDiskPartitionsPanel1);
  ToggleControl(pnlNoPartitionDisplay);
  ToggleControl(ckShowCDROM);
  // -- end [TAB_FIX] --

  // Fallback...
  SDUDiskPartitionsPanel1.Caption := RS_NO_PARTITIONS_FOUND;

  SDUDiskPartitionsPanel1.Align := alClient;
  pnlNoPartitionDisplay.Align := alClient;

  PopulateTabs();
  TabControl1Change(nil);

  pnlNoPartitionDisplay.Color := GetHighLightColor(COLOR_USABLE);
  pnlNoPartitionDisplay.Font.Style := pnlNoPartitionDisplay.Font.Style + [fsBold];

  // Yes, this is stupid, but required if frame is on a tab?!!
  AllowCDROM := AllowCDROM;

  // Sanity...
  imgErrorWarning.width := ilErrorWarning.width;
  imgErrorWarning.height := ilErrorWarning.height;

  // Set the background color for the error/warning images
  ilErrorWarning.BkColor := self.color;
  imgErrorWarning.Transparent := TRUE;

  // Nudge frame so it sizes itself correctly
  self.Resize();

end;

procedure TfmeSelectPartition.PopulateTabs();
var
  diskNo: TSDUArrayInteger;
  cdromDevices: TStringList;
  title: TStringList;
  deviceIndicator: DWORD;
  i: integer;
begin
  TabControl1.Tabs.Clear();
  FRemovableDevices.Clear();

  if FreeOTFEObj.HDDNumbersList(diskNo) then
    begin
    for i:=low(diskNo) to high(diskNo) do
      begin
      deviceIndicator := HIWORD_DISK + DWORD(diskNo[i]);
      TabControl1.Tabs.AddObject(SDUParamSubstitute(_('Disk #%1'), [diskNo[i]]), TObject(deviceIndicator));
      end;
    end;

  if (
      AllowCDROM and
      ckShowCDROM.checked
     ) then
    begin
    cdromDevices := TStringList.Create();
    title := TStringList.Create();
    try
      if FreeOTFEObj.CDROMDeviceList(cdromDevices, title) then
        begin
        FRemovableDevices.Assign(cdromDevices);
        for i:=0 to (title.count - 1) do
          begin
          deviceIndicator := HIWORD_CDROM + DWORD(i);
          TabControl1.Tabs.AddObject(title[i], TObject(deviceIndicator));
          end;
        end;
    finally
      title.Free();
      cdromDevices.Free();
    end;
    end;

  if (TabControl1.Tabs.Count > 0) then
    begin
    TabControl1.TabIndex := 0;
    end
  else
    begin
    TabControl1.TabIndex := -1;
    end;

end;

procedure TfmeSelectPartition.SDUDiskPartitionsPanel1Changed(Sender: TObject);
begin
  NotifyChanged(self);
end;

procedure TfmeSelectPartition.TabControl1Change(Sender: TObject);
var
  deviceIndicator: DWORD;
  useDevice: integer;
begin
  useDevice:= NO_DISK;

  if (TabControl1.TabIndex >= 0) then
    begin
    deviceIndicator := DWORD(TabControl1.Tabs.Objects[TabControl1.TabIndex]);

    if ((deviceIndicator and HIWORD_DISK) = HIWORD_DISK) then
      begin
      useDevice := (deviceIndicator and $FFFF);
      end;
    end;

  SetPartitionDisplayDisk(useDevice);
  ShowPartitionControl();

  // We reset this control as if switching from to new disk, we don't want the
  // whole disk used, unless the user explicitly selects it
  // If CDROM/DVDROM selected, must use whole CD/DVD
  ckEntireDisk.checked := IsCDROMTabSelected();

  EnableDisableControls();
  NotifyChanged(self);
end;

// Set to NO_PARTITION to indicate control should display no partition
procedure TfmeSelectPartition.SetPartitionDisplayDisk(diskNo: integer);
var
  i: integer;
  blk: TBlock;
begin
  // We know what we're doing...
  // We trap partitions with partition number zero, and we also paint them
  // COLOR_UNUSABLE; see below
  SDUDiskPartitionsPanel1.ShowPartitionsWithPNZero := TRUE;

  try
    SDUDiskPartitionsPanel1.DiskNumber := diskNo;
  except
    on E:Exception do
      begin
      // Swallow any exception
      end;
  end;

  // Setup the partition colours we want to be used
  for i:=0 to (SDUDiskPartitionsPanel1.Count - 1) do
    begin
    blk := SDUDiskPartitionsPanel1.Item[i];

    blk.BkColor := COLOR_UNUSABLE;
    // Only partitions numbered 1 and above are usable
    if (SDUDiskPartitionsPanel1.PartitionInfo[i].PartitionNumber > 0) then
      begin
      blk.BkColor := COLOR_USABLE;
      end;

    // If synthetic layout, clear block captions
    if SDUDiskPartitionsPanel1.SyntheticDriveLayout then
      begin
      blk.Caption := SDUParamSubstitute(
                            RS_PARTITION,
                            [SDUDiskPartitionsPanel1.PartitionInfo[i].PartitionNumber]
                           );
      blk.SubCaption := '';
      end;

    SDUDiskPartitionsPanel1.Item[i] := blk;
    end;

  UpdateErrorWarning();

end;

procedure TfmeSelectPartition.ShowPartitionControl();
var
  showPartCtrl: boolean;
begin
  showPartCtrl := (
                   // We have a disk number...
                   (SDUDiskPartitionsPanel1.DiskNumber > NO_DISK) and
                   // The partition display is valid...
                   SDUDiskPartitionsPanel1.DriveLayoutInformationValid and
                   // We're not using the entire drive
                   not(ckEntireDisk.checked)
                  );

  SDUDiskPartitionsPanel1.Visible := showPartCtrl;
  pnlNoPartitionDisplay.Visible := not(showPartCtrl);

  actProperties.Visible := TRUE;
  if (SDUDiskPartitionsPanel1.DiskNumber > NO_DISK) then
    begin
    if (
        ckEntireDisk.checked or
        not(SDUDiskPartitionsPanel1.DriveLayoutInformationValid) // Display msg for full disk if no partitions displayed
       ) then
      begin
      // actProperties.Visible already set to TRUE
      end
    else
      begin
      // Further information on partitions not available if synthetic drive layout
      actProperties.Visible := not(SDUDiskPartitionsPanel1.SyntheticDriveLayout);
      end;
    end;

  pnlNoPartitionDisplay.Caption := '';
  if (SDUDiskPartitionsPanel1.DiskNumber < 0) then
    begin
    // Sanity check in case there's no tabs
    if (TabControl1.TabIndex >= 0) then
      begin
      // CD/DVD drive selected
      pnlNoPartitionDisplay.Caption := SDUParamSubstitute(RS_CDROM_IN_X, [TabControl1.Tabs[TabControl1.TabIndex]]);
      end;
    end
  else
    begin
    if not(SDUDiskPartitionsPanel1.DriveLayoutInformationValid) then
      begin
      pnlNoPartitionDisplay.Caption := SDUParamSubstitute(RS_CANT_GET_DISK_LAYOUT, [SDUDiskPartitionsPanel1.DiskNumber]);
      end
    else
      begin
      pnlNoPartitionDisplay.Caption := SDUParamSubstitute(RS_ENTIRE_DISK_X, [SDUDiskPartitionsPanel1.DiskNumber]);
      end;
    end;

end;

function TfmeSelectPartition.GetSelectedDevice(): string;
var
  deviceIndicator: DWORD;
  useDevice: integer;
  retval: string;
  partInfo: TSDUPartitionInfo;
  partitionNo: integer;
begin
  retval := '';

  if (TabControl1.TabIndex >=0) then
    begin
    deviceIndicator := DWORD(TabControl1.Tabs.Objects[TabControl1.TabIndex]);
    useDevice := (deviceIndicator and $FFFF);

    if ((deviceIndicator and HIWORD_CDROM) = HIWORD_CDROM) then
      begin
      // Device name can be found in FRemovableDevices
      retval := FRemovableDevices[useDevice];
      end
    else if ((deviceIndicator and HIWORD_DISK) = HIWORD_DISK) then
      begin
      partitionNo := NO_PARTITION;
      if SDUDiskPartitionsPanel1.DriveLayoutInformationValid then
        begin
        if ckEntireDisk.checked then
          begin
          partitionNo := 0;
          end
        else if (SDUDiskPartitionsPanel1.Selected > NO_PARTITION) then
          begin
          partInfo := SDUDiskPartitionsPanel1.PartitionInfo[SDUDiskPartitionsPanel1.Selected];
          // Sanity...
          if (partInfo.PartitionNumber <> 0) then
            begin
            partitionNo:= partInfo.PartitionNumber;
            end;
          end;
        end;

      if (partitionNo > NO_PARTITION) then
        begin
        retval := SDUDeviceNameForPartition(useDevice, partitionNo);
        end;
      end;
    end;

  Result := retval;
end;

procedure TfmeSelectPartition.UpdateErrorWarning();
var
  msg: string;
  showIconWarning: boolean;
  showIconError: boolean;
  useIconidx: integer;
  tmpImg: TIcon;
  imgLabelDiff: integer;
begin
  imgLabelDiff := lblErrorWarning.left - (imgErrorWarning.left + imgErrorWarning.width);
  imgErrorWarning.left := 0;
  lblErrorWarning.left := 0;

  SelectionErrorWarning(msg, showIconWarning, showIconError);

  lblErrorWarning.caption := msg;
  useIconidx := ICON_NONE;
  if showIconError then
    begin
    useIconidx := ICON_ERROR;
    end
  else if showIconWarning then
    begin
    useIconidx := ICON_WARNING;
    end;

  tmpImg := TIcon.Create();
  try
    ilErrorWarning.GetIcon(useIconidx, tmpImg);
    imgErrorWarning.Picture.Assign(tmpImg);
    imgErrorWarning.Refresh();
  finally
    tmpImg.Free();
  end;

  lblErrorWarning.left := imgErrorWarning.left + imgErrorWarning.width + imgLabelDiff;
  CenterErrorWarning();

end;

procedure TfmeSelectPartition.CenterErrorWarning();
var
  ctrlArr: TControlArray;
begin
  // Center the icon and message
  SetLength(ctrlArr, 2);
  ctrlArr[0] := imgErrorWarning;
  ctrlArr[1] := lblErrorWarning;
  SDUCenterControl(ctrlArr, ccHorizontal)
end;

procedure TfmeSelectPartition.NotifyChanged(Sender: TObject);
begin
  UpdateErrorWarning();
  actProperties.Enabled := (
                            ckEntireDisk.checked and
                            (SDUDiskPartitionsPanel1.DiskNumber >= 0)
                           ) or
                           (
                            not(ckEntireDisk.checked) and
                            // 0 is the entire disk, partitions start at 1
                            (SDUDiskPartitionsPanel1.Selected >= 0)
                           );

  if Assigned(FOnChange) then
    begin
    FOnChange(self);
    end;
end;

procedure TfmeSelectPartition.SelectionErrorWarning(var msg: string; var isWarning: boolean; var isError: boolean);

  // Returns TRUE if the special folder path identified by "clsid" is stored on
  // one of the drives listed in "checkDriveLetters". Otherwise returns FALSE
  function SystemUsesDrive(clsid: integer; checkDriveLetters: string): boolean;
  var
    path: string;
    retval: boolean;
    pathDrive: char;
  begin
    retval := FALSE;

    path := SDUGetSpecialFolderPath(clsid);
    if (length(path) > 1) then
      begin
      pathDrive := path[1];
      retval := (Pos(pathDrive, checkDriveLetters) > 0);
      end;

    Result := retval;
  end;

var
  i: integer;
  selectedDriveLetters: string;
  partInfo: TSDUPartitionInfo;
  bootableFlag: boolean;
  badPartitionNumber: boolean;
begin
  msg := '';
  isWarning:= FALSE;
  isError:= FALSE;

  if (SDUDiskPartitionsPanel1.DiskNumber >= 0) then
    begin
    if not(SDUDiskPartitionsPanel1.DriveLayoutInformationValid) then
      begin
      msg := SDUParamSubstitute(UNABLE_TO_GET_DISK_LAYOUT, [SDUDiskPartitionsPanel1.DiskNumber]);
      isError := TRUE;
      end
    else
      begin
      selectedDriveLetters := '';
      bootableFlag := FALSE;
      badPartitionNumber := FALSE;
      if ckEntireDisk.checked then
        begin
        for i:=0 to (SDUDiskPartitionsPanel1.count - 1) do
          begin
          selectedDriveLetters := selectedDriveLetters +
                                  SDUDiskPartitionsPanel1.DriveLetter[i];
          partInfo := SDUDiskPartitionsPanel1.PartitionInfo[i];
          bootableFlag := (bootableFlag or partInfo.BootIndicator);
          // badPartitionNumber never set to TRUE here; entire drive being used
          end;
        end
      else if (SDUDiskPartitionsPanel1.Selected >= 0) then
        begin
        selectedDriveLetters := SDUDiskPartitionsPanel1.DriveLetter[SDUDiskPartitionsPanel1.Selected];
        partInfo := SDUDiskPartitionsPanel1.PartitionInfo[SDUDiskPartitionsPanel1.Selected];
        bootableFlag := partInfo.BootIndicator;
        badPartitionNumber := (partInfo.PartitionNumber = 0);
        end;

      
      if badPartitionNumber then
        begin
        // This is *really* fatal - a partition with no partition number?!
        // Allowing the user to continue from here could result in the user
        // inadvertently overwriting their entire drive, not just a single
        // partition!
        msg := RS_PART_ERROR_NO_PARTITION_NO;
        isError:= TRUE;
        end
      else if (
               SystemUsesDrive(SDU_CSIDL_WINDOWS, selectedDriveLetters) or
               SystemUsesDrive(SDU_CSIDL_SYSTEM, selectedDriveLetters)
              ) then
        begin
        msg := RS_PART_ERROR_SYSTEM_PARTITION;
        // Note: This is a WARNING and *NOT* an error, as user can have a hidden
        //       volume stored on this partition
        isWarning:= TRUE;
        end
      else if SystemUsesDrive(SDU_CSIDL_PROGRAM_FILES, selectedDriveLetters) then
        begin
        msg := RS_PART_ERROR_PROG_FILES_PARTITION;
        // Note: This is a WARNING and *NOT* an error, as user can have a hidden
        //       volume stored on this partition
        isWarning:= TRUE;
        end
      else if bootableFlag then
        begin
        // Warn user; this could be something like a bootable Linux partition
        msg := RS_PART_WARN_BOOTABLE;
        isWarning:= TRUE;
        end

      end;
    end;

end;

procedure TfmeSelectPartition.EnableDisableControls();
begin
  SDUEnableControl(
                   ckEntireDisk,
                   (
                    not(IsCDROMTabSelected()) and
                    SDUDiskPartitionsPanel1.DriveLayoutInformationValid
                   )
                  );

end;

procedure TfmeSelectPartition.FrameResize(Sender: TObject);
begin
  CenterErrorWarning();
end;

function TfmeSelectPartition.IsCDROMTabSelected(): boolean;
var
  deviceIndicator: DWORD;
  retval: boolean;
begin
  retval := FALSE;

  if (TabControl1.TabIndex >=0) then
    begin
    deviceIndicator := DWORD(TabControl1.Tabs.Objects[TabControl1.TabIndex]);
    retval := ((deviceIndicator and HIWORD_CDROM) = HIWORD_CDROM);
    end;

  Result := retval;
end;

procedure TfmeSelectPartition.SetAllowCDROM(allow: boolean);
begin
  FAllowCDROM := allow;

  ckShowCDROM.Visible := allow;
  if not(allow) then
    begin
    ckShowCDROM.checked := FALSE;
    end;

end;

function TfmeSelectPartition.SelectedSize(): ULONGLONG;
var
  retval: ULONGLONG;
  partInfo: TSDUPartitionInfo;
  diskGeometry: TSDUDiskGeometry;
begin
  retval := 0;

  if (SDUDiskPartitionsPanel1.DiskNumber > NO_DISK) then
    begin
    if ckEntireDisk.checked then
      begin
      // Return entire disk size
      if SDUGetDiskGeometry(SDUDiskPartitionsPanel1.DiskNumber, diskGeometry) then
        begin
        retval := diskGeometry.Cylinders.QuadPart *
                  diskGeometry.TracksPerCylinder *
                  diskGeometry.SectorsPerTrack *
                  diskGeometry.BytesPerSector;
        end; 

      end
    else
      begin
      // Return partition size
      if (SDUDiskPartitionsPanel1.Selected >= 0) then
        begin
        partInfo := SDUDiskPartitionsPanel1.PartitionInfo[SDUDiskPartitionsPanel1.Selected];
        retval := partInfo.PartitionLength;
        end;
      end;
    end;

  Result := retval;
end;

function TfmeSelectPartition.GetSyntheticDriveLayout(): boolean;
begin
  Result := SDUDiskPartitionsPanel1.SyntheticDriveLayout;
end;

procedure TfmeSelectPartition.actPropertiesExecute(Sender: TObject);
var
  dlgPartition: TSDUPartitionPropertiesDialog;
  dlgDisk: TSDUDiskPropertiesDialog;
begin
  if ckEntireDisk.checked then
    begin
    if (SDUDiskPartitionsPanel1.DiskNumber >= 0) then
      begin
      dlgDisk := TSDUDiskPropertiesDialog.Create(nil);
      try
        dlgDisk.DiskNumber := SDUDiskPartitionsPanel1.DiskNumber;

        dlgDisk.ShowModal();
      finally
        dlgDisk.Free();
      end;
      end;

    end
  else
    begin
    // 0 is the entire disk, partitions start at 1
    if (SDUDiskPartitionsPanel1.Selected >= 0) then
      begin
      dlgPartition := TSDUPartitionPropertiesDialog.Create(nil);
      try
        dlgPartition.PartitionInfo := SDUDiskPartitionsPanel1.PartitionInfo[SDUDiskPartitionsPanel1.Selected];
        dlgPartition.MountedAsDrive := SDUDiskPartitionsPanel1.DriveLetter[SDUDiskPartitionsPanel1.Selected];

        dlgPartition.ShowModal();
      finally
        dlgPartition.Free();
      end;
      end;
      
    end;

end;

END.

