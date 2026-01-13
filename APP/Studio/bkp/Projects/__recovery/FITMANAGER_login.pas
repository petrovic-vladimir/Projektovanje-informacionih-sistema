unit FITMANAGER_login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ExtCtrls, FMX.Objects, FMX.Colors, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Edit,
  FITMANAGER_register, FITMANAGER_dashboard, DB;

type
  TFrmLogin = class(TForm)
    LoginTemplate: TImage;
    loginBtn: TButton;
    FloatAnimation1: TFloatAnimation;
    Email_input: TEdit;
    Pass_input: TEdit;
    Create_account: TButton;
    procedure loginBtnClick(Sender: TObject);
    procedure Create_accountClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure OpenDashboard;
  public
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

procedure TFrmLogin.OpenDashboard;
begin
  if FrmDashboard = nil then
    FrmDashboard := TFrmDashboard.Create(Application);

  FrmDashboard.Show;
  Self.Hide;
end;

procedure TFrmLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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

procedure TFrmLogin.loginBtnClick(Sender: TObject);
var
  Login, Pass: string;
begin
  Login := Trim(Email_input.Text);
  Pass := Pass_input.Text;

  if (Login = '') or (Pass = '') then
  begin
    ShowMessage('Unesi email/username i lozinku.');
    Exit;
  end;

  if (dmDB <> nil) and dmDB.AuthenticateUser(Login, Pass) then
    OpenDashboard
  else
    ShowMessage('Pogrešan login ili lozinka.');
end;

procedure TFrmLogin.Create_accountClick(Sender: TObject);
begin
  if frmRegister = nil then
    frmRegister := TfrmRegister.Create(Application);

  frmRegister.Show;
  Self.Hide;
end;

end.

