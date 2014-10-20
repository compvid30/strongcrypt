unit SC_PRNG;

interface

uses
  Windows,
  SysUtils;

type
  TMemoryStatusEx = packed record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;

function GenerateRNGDataIsaac(bytesRequired: integer; var randomData: AnsiString): boolean;

function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): BOOL; stdcall; external kernel32;
function GetShellWindow: HWND; stdcall; external 'user32.dll' name 'GetShellWindow';

implementation

uses
  tsc,
  dates,
  hash,
  whirl512,
  Isaac;


// Collect some random data for seeding our prng
function CollectRND(var WD: TWhirlDigest): boolean;
var
  sctx: THashContext;
  ctr: TCtrRec;
  ctrInt: LongInt;
  tick: LongWord;
  msc: LongInt;
  pID: LongWord;
  tID: LongWord;
  Status: TMemoryStatusEx;
  pos: TPoint;
  PCreationTime: TFileTime;
  TCreationTime: TFileTime;
  ExitTime: TFileTime;
  PKernelTime: TFileTime;
  TKernelTime: TFileTime;
  UserTime: TFileTime;
  min: LongWord;
  max: LongWord;
  hwnd: LongWord;
  hwnd2: LongWord;
  hwnd3: LongWord;
  hwnd4: LongWord;
  hwnd5: LongWord;
  heaphwnd: LongWord;
  cp: LongWord;
  mt: LongInt;
  dt: TDateTime;
begin

  try
    Result := True;

    // ms since midnight
    _ReadCounter(Ctr);

    // ms since system start
    tick := GetTickCount;

    // current time as ms
    msc := MsCount;

    // Get global memory status
    ZeroMemory(@Status, SizeOf(TMemoryStatusEx));
    Status.dwLength := SizeOf(TMemoryStatusEx);
    GlobalMemoryStatusEx(Status);

    // Get cursor position
    GetCursorPos(Pos);

    // Get process creation time
    GetProcessTimes(GetCurrentProcess, PCreationTime, ExitTime, PKernelTime, UserTime);

    // Get thread creation time
    GetThreadTimes(GetCurrentProcess, TCreationTime, ExitTime, TKernelTime, UserTime);

    // Get the minimum and maximum working set size
    GetProcessWorkingSetSize(GetCurrentProcess, min, max);

    // Get current process and thread ID
    pID := GetCurrentProcessId;
    tID := GetCurrentThreadId;

    // Handle of focused window
    hwnd := GetFocus;

    // Get desktop window handle
    hwnd2 := GetDesktopWindow;

    // Get handle of last popup window
    hwnd3 := GetLastActivePopup(hwnd2);

    // Get handle of clipboard owner
    hwnd4 := GetClipboardOwner;

    // Retrieves a handle to the Shell's desktop window
    hwnd5 := GetShellWindow;

    // Get handle to process heap
    heaphwnd := GetProcessHeap;

    // Get code page
    cp := GetOEMCP;

    // Retrieves the message time for the last message retrieved by the GetMessage function
    mt := GetMessageTime;

    // Just now
    dt := now;

    // Hash all values with whirlpool to get the seed for the prng
    Whirl_Init(sctx);

    Whirl_Update(sctx, @ctr, SizeOf(ctr));
    Whirl_Update(sctx, @tick, SizeOf(tick));
    Whirl_Update(sctx, @msc, SizeOf(msc));
    Whirl_Update(sctx, @status, SizeOf(status));
    Whirl_Update(sctx, @pos, SizeOf(pos));
    Whirl_Update(sctx, @PCreationTime, SizeOf(PCreationTime));
    Whirl_Update(sctx, @TKernelTime, SizeOf(TKernelTime));
    Whirl_Update(sctx, @min, SizeOf(min));
    Whirl_Update(sctx, @max, SizeOf(max));
    Whirl_Update(sctx, @pID, SizeOf(pID));
    Whirl_Update(sctx, @tID, SizeOf(tID));
    Whirl_Update(sctx, @hwnd, SizeOf(hwnd));
    Whirl_Update(sctx, @hwnd2, SizeOf(hwnd2));
    Whirl_Update(sctx, @hwnd3, SizeOf(hwnd3));
    Whirl_Update(sctx, @hwnd4, SizeOf(hwnd4));
    Whirl_Update(sctx, @hwnd5, SizeOf(hwnd5));
    Whirl_Update(sctx, @heaphwnd, SizeOf(heaphwnd));
    Whirl_Update(sctx, @cp, SizeOf(cp));
    Whirl_Update(sctx, @mt, SizeOf(mt));
    Whirl_Update(sctx, @dt, SizeOf(dt));

    Whirl_Final(sctx, WD);

  except
    on E: Exception do
    begin
      Result := False;
    end;
  end;

end;

function GenerateRNGDataIsaac(bytesRequired: integer; var randomData: AnsiString): boolean;
var
  i: integer;
  ctx: isaac_ctx;
  isaacrn: cardinal;
  WD: TWhirlDigest;
  IsaacSeed: array[0..15] of LongInt;
begin
  Result := False;

  if CollectRND(WD) then
  begin

    randomData := '';

    move(WD, IsaacSeed, SizeOf(IsaacSeed));

      // Feed Isaac with our seeds
      isaac_inita(ctx, IsaacSeed, 16);

      for i := 0 to bytesRequired - 1 do
      begin
        isaacrn := isaac_dword(ctx);
        randomData := randomData + Chr(isaacrn mod 255);
      end;
      if Length(randomData) = bytesRequired then
        Result := True;
  end;
end;

end.

