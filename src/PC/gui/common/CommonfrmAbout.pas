unit CommonfrmAbout;
// Description: About Dialog
// By Sarah Dean
// Email: sdean12@sdean12.org
// WWW:   http://www.FreeOTFE.org/
//
// -----------------------------------------------------------------------------
//


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OTFEFreeOTFEBase_U, SDUStdCtrls, SDUForms, uVista;

type
  TfrmAbout = class(TSDUForm)
    pbOK: TButton;
    imgIcon: TImage;
    lblAppID: TLabel;
    lblTitle: TLabel;
    SDUURLLabel1: TSDUURLLabel;
    Bevel1: TBevel;
    lblFreeOTFE: TLabel;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    FreeOTFEObj: TOTFEFreeOTFEBase;
    BetaNumber: integer;
    Description: string;
  end;

implementation

{$R *.DFM}

uses
  ShellApi,  // Needed for ShellExecute
  SDUi18n,
  SDUGeneral;
procedure GetBuildInfo(var V1, V2, V3, V4: Word);
var
   VerInfoSize, VerValueSize, Dummy : DWORD;
   VerInfo : Pointer;
   VerValue : PVSFixedFileInfo;
begin
VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
GetMem(VerInfo, VerInfoSize);
GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
With VerValue^ do
begin
  V1 := dwFileVersionMS shr 16;
  V2 := dwFileVersionMS and $FFFF;
  V3 := dwFileVersionLS shr 16;
  V4 := dwFileVersionLS and $FFFF;
end;
FreeMem(VerInfo, VerInfoSize);
end;

function kfVersionInfo: String;
var
  V1,       // Major Version
  V2,       // Minor Version
  V3,       // Release
  V4: Word; // Build Number
begin
  GetBuildInfo(V1, V2, V3, V4);
  Result := IntToStr(V1) + '.' 
            + IntToStr(V2) + '.' 
            + IntToStr(V3) + '.' 
            + IntToStr(V4);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  SetVistaFonts(self);
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  lblAppID.caption := 'v'+kfVersionInfo;
end;

END.

