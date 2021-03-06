unit OTFEFreeOTFE_InstructionRichEdit;
// Description: Password Richedit
// By Sarah Dean
// Email: sdean12@sdean12.org
// WWW:   http://www.SDean12.org/
//
// -----------------------------------------------------------------------------
//
// This control exposes the "PasswordChar" property of TRichEdit


interface

uses
  Windows, Messages, Classes,
  StdCtrls,
  ComCtrls,  // Required for definition of TRichEdit
  Forms, // Required for bsNone
  Graphics,
  Controls;

type
  TOTFEFreeOTFE_InstructionRichEdit = class(TRichEdit)
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy(); override;

    procedure ResetDisplay();

  published
{
    property BorderStyle default bsNone;
    property TabStop default FALSE;
    property PlainText default TRUE;
    property ReadOnly default TRUE;
    property Color default clBtnFace;
    property ParentColor default TRUE;
}
  property Color default clWindow;
  end;


procedure Register;

implementation

uses
  RichEdit;

procedure Register;
begin
  RegisterComponents('FreeOTFE', [TOTFEFreeOTFE_InstructionRichEdit]);
end;

constructor TOTFEFreeOTFE_InstructionRichEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // We don't set these at design-time, as it makes it easier to see where the
  // components are
  if not(csDesigning in ComponentState) then
    begin
    ResetDisplay();
    end;

end;

destructor TOTFEFreeOTFE_InstructionRichEdit.Destroy();
begin
  inherited;
end;

procedure TOTFEFreeOTFE_InstructionRichEdit.ResetDisplay();
begin
  inherited;

  // Restore various properties suitable for instructions display...
  self.BorderStyle := bsNone;
  self.TabStop     := FALSE;
  self.PlainText   := TRUE;
  self.Readonly    := TRUE;
  self.ParentColor := TRUE;
end;

END.


