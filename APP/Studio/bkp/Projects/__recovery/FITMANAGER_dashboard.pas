unit FITMANAGER_dashboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TFrmDashboard = class(TForm)
    Image1: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDashboard: TFrmDashboard;

implementation

{$R *.fmx}

procedure TFrmDashboard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if MessageDlg(
       'Da li ste sigurni da zelite da napustite aplikaciju?',
       TMsgDlgType.mtConfirmation,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) = mrYes then
  begin
    CanClose := True;
    Application.Terminate;   // gasi aplikaciju
  end
  else
    CanClose := False;       // ostaje u aplikaciji
end;


end.
