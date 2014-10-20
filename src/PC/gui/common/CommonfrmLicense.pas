unit CommonfrmLicense;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmLicense = class(TForm)
    Bevel1: TBevel;
    pbOK: TButton;
    Memo1: TMemo;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmLicense: TfrmLicense;

implementation

{$R *.dfm}

end.
