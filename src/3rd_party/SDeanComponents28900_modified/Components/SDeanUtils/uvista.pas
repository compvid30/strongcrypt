unit uVista;

// *** Need to use XPTheme.
// In your project's .dpr file, add XPTheme to the top of the "uses" list.
// If you have TXPManifest, you can use that instead, since it does the
// same job.
//
// This is a compilation of code-fragments I have found on the net.
// Kevin Solway.
// http://www.theabsolute.net/sware/taskdialog/
// Last modified: 11th Feb, 2008


interface

uses Forms, Windows, Graphics, CommDlg, controls, dialogs;

type
 pboolean = ^boolean;
 TTASKDIALOG_BUTTON =
   packed record
      nButtonId     : Integer;
      pszButtonText : PWideChar;
   end;
 TTASKDIALOG_BUTTONS = array of TTASKDIALOG_BUTTON;



function IsWindowsVista: Boolean;
procedure SetVistaFonts(const AForm: TCustomForm);
procedure SetVistaContentFonts(const AFont: TFont);
procedure SetDesktopIconFonts(const AFont: TFont);
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
function CompositingEnabled: Boolean;
function TaskDialog(const AHandle: THandle; const ATitle, ADescription,
  AContent: string; const Icon, Buttons: integer): Integer;
procedure TaskMessage(const AHandle: THandle; AMessage: string);
procedure SetVistaTreeView(const AHandle: THandle);



function OpenSaveFileDialog(Parent: TWinControl;
                            const DefExt,
                            Filter,
                            InitialDir,
                            Title: string;
                            var FileName: string;
                            MustExist,
                            OverwritePrompt,
                            NoChangeDir,
                            DoOpen: Boolean): Boolean;


const
  VistaFont = 'Segoe UI';
  VistaContentFont = 'Calibri';
  XPContentFont = 'Verdana';
  XPFont = 'Tahoma';

  TD_ICON_BLANK = 0;
  TD_ICON_WARNING = 84;
  TD_ICON_QUESTION = 99;
  TD_ICON_ERROR = 98;
  TD_ICON_INFORMATION = 81;
  TD_ICON_SHIELD_QUESTION = 104;
  TD_ICON_SHIELD_ERROR = 105;
  TD_ICON_SHIELD_OK = 106;
  TD_ICON_SHIELD_WARNING = 107;

  TD_BUTTON_OK = 1;
  TD_BUTTON_YES = 2;
  TD_BUTTON_NO = 4;
  TD_BUTTON_CANCEL = 8;
  TD_BUTTON_RETRY = 16;
  TD_BUTTON_CLOSE = 32;

  TD_RESULT_OK = 1;
  TD_RESULT_CANCEL = 2;
  TD_RESULT_RETRY = 4;
  TD_RESULT_YES = 6;
  TD_RESULT_NO = 7;
  TD_RESULT_CLOSE = 8;

  TD_IDS_WINDOWTITLE       = 10;
  TD_IDS_CONTENT           = 11;
  TD_IDS_MAININSTRUCTION   = 12;
  TD_IDS_VERIFICATIONTEXT  = 13;
  TD_IDS_FOOTER            = 15;
  TD_IDS_RB_GOOD           = 16;
  TD_IDS_RB_OK             = 17;
  TD_IDS_RB_BAD            = 18;
  TD_IDS_CB_SAVE           = 19;


var
  CheckOSVerForFonts: Boolean = True;

implementation

uses SysUtils, UxTheme;

function sametext(x,y : string) : boolean;
// not case sensitive
begin
 //if SameText(x,y) then... with ...if CompareText(x,y)=0 then
 result := comparetext(x,y) = 0;
end;


procedure SetVistaTreeView(const AHandle: THandle);
// handle must be a handle of a treeview component eg, TreeView.Handle
begin
  if IsWindowsVista then
    SetWindowTheme(AHandle, 'explorer', nil);
end;

procedure SetVistaFonts(const AForm: TCustomForm);
begin
  if (IsWindowsVista or not CheckOSVerForFonts)
    and not SameText(AForm.Font.Name, VistaFont)
    and (Screen.Fonts.IndexOf(VistaFont) >= 0) then
  begin
    AForm.Font.Size := AForm.Font.Size;
    AForm.Font.Name := VistaFont;
  end;
end;

procedure SetVistaContentFonts(const AFont: TFont);
// parameter must be something like,  memo.font
// for memos, richedits, etc
begin
  if (IsWindowsVista or not CheckOSVerForFonts)
    and not SameText(AFont.Name, VistaContentFont)
    and (Screen.Fonts.IndexOf(VistaContentFont) >= 0) then
  begin
    AFont.Size := AFont.Size + 2;
    AFont.Name := VistaContentFont;
  end;
end;

procedure SetDefaultFonts(const AFont: TFont);
begin
  AFont.Handle := GetStockObject(DEFAULT_GUI_FONT);
end;

procedure SetDesktopIconFonts(const AFont: TFont);
// set default font to be the same as the desktop icons font
// otherwise, uses default windows font
var
  LogFont: TLogFont;
begin
  if SystemParametersInfo(SPI_GETICONTITLELOGFONT, SizeOf(LogFont),
    @LogFont, 0) then
    AFont.Handle := CreateFontIndirect(LogFont)
  else
    SetDefaultFonts(AFont);
end;

function IsWindowsVista: Boolean;   
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);        
  Result := VerInfo.dwMajorVersion >= 6;
end;  

const
  dwmapi = 'dwmapi.dll';
  DwmIsCompositionEnabledSig = 'DwmIsCompositionEnabled';
  DwmExtendFrameIntoClientAreaSig = 'DwmExtendFrameIntoClientArea';
  TaskDialogSig = 'TaskDialog';

function CompositingEnabled: Boolean;
var
  DLLHandle: THandle;
  DwmIsCompositionEnabledProc: function(pfEnabled: PBoolean): HRESULT; stdcall;
  Enabled: Boolean;
begin
  Result := False;
  if IsWindowsVista then
  begin
    DLLHandle := LoadLibrary(dwmapi);

    if DLLHandle <> 0 then 
    begin
      @DwmIsCompositionEnabledProc := GetProcAddress(DLLHandle,
        DwmIsCompositionEnabledSig);

      if (@DwmIsCompositionEnabledProc <> nil) then
      begin
        DwmIsCompositionEnabledProc(@Enabled);
        Result := Enabled;
      end;

      FreeLibrary(DLLHandle);
    end;
  end;
end;

//from http://www.delphipraxis.net/topic93221,next.html
procedure ExtendGlass(const AHandle: THandle; const AMargins: TRect);
type
  _MARGINS = packed record 
    cxLeftWidth: Integer; 
    cxRightWidth: Integer; 
    cyTopHeight: Integer; 
    cyBottomHeight: Integer;
  end; 
  PMargins = ^_MARGINS;
  TMargins = _MARGINS; 
var 
  DLLHandle: THandle;
  DwmExtendFrameIntoClientAreaProc: function(destWnd: HWND; const pMarInset: 
    PMargins): HRESULT; stdcall;
  Margins: TMargins;
begin
  if IsWindowsVista and CompositingEnabled then
  begin
    DLLHandle := LoadLibrary(dwmapi);

    if DLLHandle <> 0 then
    begin
      @DwmExtendFrameIntoClientAreaProc := GetProcAddress(DLLHandle,
        DwmExtendFrameIntoClientAreaSig);

      if (@DwmExtendFrameIntoClientAreaProc <> nil) then
      begin
        ZeroMemory(@Margins, SizeOf(Margins));
        Margins.cxLeftWidth := AMargins.Left;
        Margins.cxRightWidth := AMargins.Right;
        Margins.cyTopHeight := AMargins.Top;
        Margins.cyBottomHeight := AMargins.Bottom;

        DwmExtendFrameIntoClientAreaProc(AHandle, @Margins);
      end;

      FreeLibrary(DLLHandle);
    end;
  end;
end;


//from http://www.tmssoftware.com/atbdev5.htm
function TaskDialog(const AHandle: THandle; const ATitle, ADescription,
  AContent: string; const Icon, Buttons: Integer): Integer;
label normal;
var
  DLLHandle: THandle;
  res: integer;
  assignprob : boolean;
  S, Dmy: string;
  wTitle, wDescription, wContent: array[0..1024] of widechar;
  Btns: TMsgDlgButtons;
  DlgType: TMsgDlgType;
  TaskDialogProc: function(HWND: THandle; hInstance: THandle; cTitle,
    cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer;
    ResButton: pinteger): integer; cdecl stdcall;
begin
  Result := 0;
  assignprob := false;
  if IsWindowsVista then
  begin
    DLLHandle := LoadLibrary(comctl32);
    if DLLHandle >= 32 then
    begin
      @TaskDialogProc := GetProcAddress(DLLHandle, TaskDialogSig);

      // mbb(assigned(taskdialogproc));

      if Assigned(TaskDialogProc) then
      begin
        StringToWideChar(ATitle, wTitle, SizeOf(wTitle));
        StringToWideChar(ADescription, wDescription, SizeOf(wDescription));

        //Get rid of line breaks, may be here for backwards compat but not
        //needed with Task Dialogs
        S := StringReplace(AContent, #10, '', [rfReplaceAll]);
        S := StringReplace(S, #13, '', [rfReplaceAll]);
        StringToWideChar(S, wContent, SizeOf(wContent));

        TaskDialogProc(AHandle, 0, wTitle, wDescription, wContent, Buttons,
          Icon, @res);

        Result := mrOK;

        case res of
          TD_RESULT_CANCEL : Result := mrCancel;
          TD_RESULT_RETRY : Result := mrRetry;
          TD_RESULT_YES : Result := mrYes;
          TD_RESULT_NO : Result := mrNo;
          TD_RESULT_CLOSE : Result := mrAbort;
        end;
      end
      else assignprob := true;
     FreeLibrary(DLLHandle);
     // mySysError;
     if assignprob then goto normal;
    end;
  end else
  begin
    normal:
    Btns := [];
    if Buttons and TD_BUTTON_OK = TD_BUTTON_OK then
      Btns := Btns + [MBOK];

    if Buttons and TD_BUTTON_YES = TD_BUTTON_YES then
      Btns := Btns + [MBYES];

    if Buttons and TD_BUTTON_NO = TD_BUTTON_NO then
      Btns := Btns + [MBNO];

    if Buttons and TD_BUTTON_CANCEL = TD_BUTTON_CANCEL then
      Btns := Btns + [MBCANCEL];

    if Buttons and TD_BUTTON_RETRY = TD_BUTTON_RETRY then
      Btns := Btns + [MBRETRY];

    if Buttons and TD_BUTTON_CLOSE = TD_BUTTON_CLOSE then
      Btns := Btns + [MBABORT];

    DlgType := mtCustom;

    case Icon of
      TD_ICON_WARNING : DlgType := mtWarning;
      TD_ICON_QUESTION : DlgType := mtConfirmation;
      TD_ICON_ERROR : DlgType := mtError;
      TD_ICON_INFORMATION: DlgType := mtInformation;
    end;

    Dmy := ADescription;
    if AContent <> '' then
     begin
       if Dmy <> '' then Dmy := Dmy + #$D#$A + #$D#$A;
       Dmy := Dmy + AContent;
     end;
    result := MessageDlg(Dmy, DlgType, Btns, 0);
  end;
end;


procedure TaskMessage(const AHandle: THandle; AMessage: string);
begin
  TaskDialog(AHandle, '', '', AMessage, TD_BUTTON_OK, 0);
end;


function ReplaceStr(Str, SearchStr, ReplaceStr: string): string;
begin
  while Pos(SearchStr, Str) <> 0 do
  begin
    Insert(ReplaceStr, Str, Pos(SearchStr, Str));
    system.Delete(Str, Pos(SearchStr, Str), Length(SearchStr));
  end;
  Result := Str;
end;



function OpenSaveFileDialog(Parent: TWinControl;
                            const DefExt,
                            Filter,
                            InitialDir,
                            Title: string;
                            var FileName: string;
                            MustExist,
                            OverwritePrompt,
                            NoChangeDir,
                            DoOpen: Boolean): Boolean;
// uses commdlg
var
  ofn: TOpenFileName;
  szFile: array[0..MAX_PATH] of Char;
begin
  Result := False;
  FillChar(ofn, SizeOf(TOpenFileName), 0);
  with ofn do
  begin
    lStructSize := SizeOf(TOpenFileName);
    hwndOwner := Parent.Handle;
    lpstrFile := szFile;
    nMaxFile := SizeOf(szFile);
    if (Title <> '') then
      lpstrTitle := PChar(Title);
    if (InitialDir <> '') then
      lpstrInitialDir := PChar(InitialDir);
    StrPCopy(lpstrFile, FileName);
    lpstrFilter := PChar(ReplaceStr(Filter, '|', #0)+#0#0);
    if DefExt <> '' then
      lpstrDefExt := PChar(DefExt);
  end;

  if MustExist then ofn.Flags := ofn.Flags or OFN_FILEMUSTEXIST;
  if OverwritePrompt then ofn.Flags := ofn.Flags or OFN_OVERWRITEPROMPT;
  if NoChangeDir then ofn.Flags := ofn.Flags or OFN_NOCHANGEDIR;

  if DoOpen then
  begin
    if GetOpenFileName(ofn) then
    begin
      Result := True;
      FileName := StrPas(szFile);
    end;
  end
  else
  begin
    if GetSaveFileName(ofn) then
    begin
      Result := True;
      FileName := StrPas(szFile);
    end;
  end
end; // function OpenSaveFileDialog



{
MsgDLgTypes:

mtWarning	A message box containing a yellow exclamation point symbol.
mtError	A message box containing a red stop sign.
mtInformation	A message box containing a blue "i".
mtConfirmation	A message box containing a green question mark.
mtCustom	A message box containing no bitmap. The caption of the message box is the name of the application's executable file.

MsgDlgBUttons:

mbYes	A button with 'Yes' on its face.
mbNo	A button the text 'No' on its face.
mbOK	A button the text 'OK' on its face.
mbCancel	A button with the text 'Cancel' on its face.
mbHelp	A button with the text 'Help' on its face
mbAbort	A button with the text 'Abort' on its face
mbRetry	A button with the text 'Retry' on its face
mbIgnore	A button with the text 'Ignore' on its face
mbAll	A button with the text 'All' on its face
}




end.
