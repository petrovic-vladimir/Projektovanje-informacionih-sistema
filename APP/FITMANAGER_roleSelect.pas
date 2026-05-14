unit FITMANAGER_roleSelect;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TFrmRoleSelect = class(TForm)
  private
    FMemberLabel: TLabel;
    FTrainerLabel: TLabel;
    FAdminLabel: TLabel;
    FDatabaseReady: Boolean;
    FLoadTimer: TTimer;
    procedure BuildLayout;
    function EnsureDatabaseReady: Boolean;
    procedure LoadDemoUsers;
    procedure LoadTimerTimer(Sender: TObject);
    procedure OpenAdminArea(Sender: TObject);
    procedure OpenMemberArea(Sender: TObject);
    procedure OpenTrainerArea(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  FrmRoleSelect: TFrmRoleSelect;

implementation

uses
  dmDatabase, FITMANAGER_memberHome, FITMANAGER_trainerHome,
  FITMANAGER_adminHome;

{$R *.fmx}

constructor TFrmRoleSelect.Create(AOwner: TComponent);
begin
  inherited;
  Caption := 'FITMANAGER - izbor uloge';
  Width := 420;
  Height := 780;
  BuildLayout;

  FLoadTimer := TTimer.Create(Self);
  FLoadTimer.Interval := 250;
  FLoadTimer.OnTimer := LoadTimerTimer;
  FLoadTimer.Enabled := True;
end;

procedure TFrmRoleSelect.BuildLayout;
var
  Root: TVertScrollBox;
  Header, Subtitle: TLabel;
  MemberButton, TrainerButton, AdminButton: TButton;
begin
  Root := TVertScrollBox.Create(Self);
  Root.Parent := Self;
  Root.Align := TAlignLayout.Client;
  Root.Padding.Rect := TRectF.Create(24, 40, 24, 24);

  Header := TLabel.Create(Self);
  Header.Parent := Root;
  Header.Align := TAlignLayout.Top;
  Header.Height := 48;
  Header.Text := 'FITMANAGER';
  Header.TextSettings.HorzAlign := TTextAlign.Center;
  Header.TextSettings.Font.Size := 28;

  Subtitle := TLabel.Create(Self);
  Subtitle.Parent := Root;
  Subtitle.Align := TAlignLayout.Top;
  Subtitle.Height := 70;
  Subtitle.TextSettings.HorzAlign := TTextAlign.Center;
  Subtitle.TextSettings.VertAlign := TTextAlign.Center;
  Subtitle.TextSettings.Font.Size := 16;

  FMemberLabel := TLabel.Create(Self);
  FMemberLabel.Parent := Root;
  FMemberLabel.Align := TAlignLayout.Top;
  FMemberLabel.Height := 54;
  FMemberLabel.Text := 'Clan: ucitavanje iz baze...';
  FMemberLabel.TextSettings.Font.Size := 14;

  MemberButton := TButton.Create(Self);
  MemberButton.Parent := Root;
  MemberButton.Align := TAlignLayout.Top;
  MemberButton.Height := 54;
  MemberButton.Margins.Bottom := 28;
  MemberButton.Text := 'Nastavi kao clan';
  MemberButton.OnClick := OpenMemberArea;

  FTrainerLabel := TLabel.Create(Self);
  FTrainerLabel.Parent := Root;
  FTrainerLabel.Align := TAlignLayout.Top;
  FTrainerLabel.Height := 54;
  FTrainerLabel.Text := 'Trener: ucitavanje iz baze...';
  FTrainerLabel.TextSettings.Font.Size := 14;

  TrainerButton := TButton.Create(Self);
  TrainerButton.Parent := Root;
  TrainerButton.Align := TAlignLayout.Top;
  TrainerButton.Height := 54;
  TrainerButton.Margins.Bottom := 28;
  TrainerButton.Text := 'Nastavi kao trener';
  TrainerButton.OnClick := OpenTrainerArea;

  FAdminLabel := TLabel.Create(Self);
  FAdminLabel.Parent := Root;
  FAdminLabel.Align := TAlignLayout.Top;
  FAdminLabel.Height := 54;
  FAdminLabel.Text := 'Admin:';
  FAdminLabel.TextSettings.Font.Size := 14;

  AdminButton := TButton.Create(Self);
  AdminButton.Parent := Root;
  AdminButton.Align := TAlignLayout.Top;
  AdminButton.Height := 54;
  AdminButton.Text := 'Nastavi kao admin';
  AdminButton.OnClick := OpenAdminArea;
end;

function TFrmRoleSelect.EnsureDatabaseReady: Boolean;
begin
  Result := FDatabaseReady;
  if Result then
    Exit;

  try
    DB.InitializeDatabase;
    FDatabaseReady := True;
    Result := True;
  except
    on E: Exception do
    begin
      FMemberLabel.Text := 'Baza nije spremna: ' + E.Message;
      FTrainerLabel.Text := 'Aplikacija se startovala, ali baza nije otvorena.';
      if Assigned(FAdminLabel) then
        FAdminLabel.Text := 'Admin ekran ceka bazu.';
      Result := False;
    end;
  end;
end;

procedure TFrmRoleSelect.LoadDemoUsers;
begin
  if not EnsureDatabaseReady then
    Exit;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT member_id, first_name, last_name FROM member ' +
    'WHERE status = :status ORDER BY member_id LIMIT 1';
  DB.FDQuery1.ParamByName('status').AsString := 'Aktivan';
  DB.FDQuery1.Open;
  if not DB.FDQuery1.IsEmpty then
    FMemberLabel.Text := Format('Clan iz baze: %s %s',
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString]);

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT trainer_id, first_name, last_name FROM trainer ' +
    'WHERE status = :status ORDER BY trainer_id LIMIT 1';
  DB.FDQuery1.ParamByName('status').AsString := 'Aktivan';
  DB.FDQuery1.Open;
  if not DB.FDQuery1.IsEmpty then
    FTrainerLabel.Text := Format('Trener iz baze: %s %s',
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString]);
  DB.FDQuery1.Close;
end;

procedure TFrmRoleSelect.LoadTimerTimer(Sender: TObject);
begin
  FLoadTimer.Enabled := False;
  LoadDemoUsers;
end;

procedure TFrmRoleSelect.OpenAdminArea(Sender: TObject);
begin
  if not EnsureDatabaseReady then
    Exit;

  TFrmAdminHome.Create(Application).Show;
  Hide;
end;

procedure TFrmRoleSelect.OpenMemberArea(Sender: TObject);
begin
  if not EnsureDatabaseReady then
    Exit;

  TFrmMemberHome.Create(Application).Show;
  Hide;
end;

procedure TFrmRoleSelect.OpenTrainerArea(Sender: TObject);
begin
  if not EnsureDatabaseReady then
    Exit;

  TFrmTrainerHome.Create(Application).Show;
  Hide;
end;

end.
