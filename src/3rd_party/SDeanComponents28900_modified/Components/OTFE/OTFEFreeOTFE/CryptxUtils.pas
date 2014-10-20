(* ========================================================================== *)
(*                                UltimateZip 7.0                             *)
(*                          (c) 2001-2013 Oliver von Schleusen                *)
(*                            Compiler: Delphi 2007                           *)
(*                              Windows-32-Target                             *)
(*                              License: Public Domain                        *)
(* ========================================================================== *)
unit CryptxUtils;



interface

uses
  Classes,
  SysUtils,
  Math,
  Forms,
  Controls;

procedure EstimatePasswordBits(var vPasswordChars: string; var b: cardinal);

implementation


procedure EstimatePasswordBits(var vPasswordChars: string; var b: cardinal);
var
  bChLower, bChUpper, bChNumber, bChSimpleSpecial, bChExtSpecial, bChHigh, bChEscape: boolean;
  vCharCounts: TStringList;
  vDifferences: TStringList;
  i, iDiff: integer;
  dblEffectiveLength, dblDiffFactor, dblBitsPerChar: double;
  charSpace: cardinal;
  key: char;
  j: integer;
begin
  bChLower := False;
  bChUpper := False;
  bChNumber := False;
  bChSimpleSpecial := False;
  bChExtSpecial := False;
  bChHigh := False;
  bChEscape := False;

  dblEffectiveLength := 0.0;

  vCharCounts := TStringList.Create;
  vDifferences := TStringList.Create;
  try
  for i := 1 to Length(vPasswordChars) do
  begin
    key := vPasswordChars[i];
    if (key < ' ') then
      bChEscape := True;
    if ((key >= 'A') and (key <= 'Z')) then
      bChUpper := True;
    if ((key >= 'a') and (key <= 'z')) then
      bChLower := True;
    if ((key >= '0') and (key <= '9')) then
      bChNumber := True;
    if ((key >= ' ') and (key <= '/')) then
      bChSimpleSpecial := True;
    if ((key >= ':') and (key <= '@')) then
      bChExtSpecial := True;
    if ((key >= '[') and (key <= '`')) then
      bChExtSpecial := True;
    if ((key >= '{') and (key <= '~')) then
      bChExtSpecial := True;
    if (key > '~') then
      bChHigh := True;
    dblDiffFactor := 1.0;
    if (i >= 1) then
    begin
      iDiff := (Ord(key) - Ord(vPasswordChars[i - 1]));
      if vDifferences.IndexOf(IntToStr(iDiff)) = -1 then
        vDifferences.AddObject(IntToStr(iDiff), TObject(1))
      else
      begin
        j := vDifferences.IndexOf(IntToStr(iDiff));
        vDifferences.Objects[j] := TObject(Integer(vDifferences.Objects[j]) + 1);
        dblDiffFactor := dblDiffFactor / (Integer(vDifferences.Objects[j]));
      end;
    end;

    if vCharCounts.IndexOf(key) = -1 then
    begin
      vCharCounts.AddObject(key, TObject(1));
      dblEffectiveLength := dblEffectiveLength + dblDiffFactor;
    end
    else
    begin
      j := vCharCounts.IndexOf(key);
      vCharCounts.Objects[j] := TObject(Integer(vCharCounts.Objects[j]) + 1);
      dblEffectiveLength := dblEffectiveLength + (dblDiffFactor * (1.0 / (Integer(vCharCounts.Objects[j]))));
    end;
  end;
  charSpace := 0;
  if (bChEscape) then
    Inc(charSpace, 60);
  if (bChUpper) then
    Inc(charSpace, 26);
  if (bChLower) then
    Inc(charSpace, 26);
  if (bChNumber) then
    Inc(charSpace, 10);
  if (bChSimpleSpecial) then
    Inc(charSpace, 16);
  if (bChExtSpecial) then
    Inc(charSpace, 17);
  if (bChHigh) then
    Inc(charSpace, 112);
  if (charSpace = 0) then
  begin
    b := 0;
    Exit;
  end;

  dblBitsPerChar := LN(charSpace) / LN(2.0);
  begin
    b := Math.Ceil(dblBitsPerChar * dblEffectiveLength);
    if vPasswordChars = '' then
      b := 0;
    Exit;
  end;

  finally
    vCharCounts.Free;
  vDifferences.Free;
  end;
end;

end.
