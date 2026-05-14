unit FITMANAGER_trainerHome;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TFrmTrainerHome = class(TForm)
    imgBackground: TImage;
    lblTrainerName: TLabel;
    lblRequestsTitle: TLabel;
    lblRequests: TLabel;
    btnApprove: TButton;
    btnDecline: TButton;
    lblMembersTitle: TLabel;
    sbMembers: TScrollBox;
    lyMembersContent: TLayout;
    btnBack: TButton;
    procedure btnApproveClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnDeclineClick(Sender: TObject);
  private
    FTrainerId: Integer;
    FFirstRequestId: Integer;
    function BuildPath(const APath, AFileName: string): string;
    function FindAssetFile(const AFileName: string): string;
    procedure AddMemberCard(const ALeft, ATop: Single; const AName, AGoal: string;
      AMemberId: Integer);
    procedure MemberCardClick(Sender: TObject);
    procedure LoadMemberCards;
    procedure LoadTemplateBackground;
    procedure LoadTrainerContext;
    procedure RefreshRequests;
    procedure UpdateFirstRequestStatus(const AStatus: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  dmDatabase, FITMANAGER_memberPlanDetail;

{$R *.fmx}

constructor TFrmTrainerHome.Create(AOwner: TComponent);
begin
  inherited;
  LoadTemplateBackground;
  try
    DB.InitializeDatabase;
    LoadTrainerContext;
    RefreshRequests;
  except
    on E: Exception do
      lblRequests.Text := 'Greska pri ucitavanju baze: ' + E.Message;
  end;
end;

procedure TFrmTrainerHome.AddMemberCard(const ALeft, ATop: Single;
  const AName, AGoal: string; AMemberId: Integer);
var
  Card: TRectangle;
  NameLabel, GoalLabel: TLabel;
begin
  Card := TRectangle.Create(lyMembersContent);
  Card.Parent := lyMembersContent;
  Card.Position.X := ALeft;
  Card.Position.Y := ATop;
  Card.Width := 266;
  Card.Height := 92;
  Card.XRadius := 8;
  Card.YRadius := 8;
  Card.Fill.Color := $FFFFE8CF;
  Card.Stroke.Color := $00FFFFFF;
  Card.Tag := AMemberId;
  Card.HitTest := True;
  Card.OnClick := MemberCardClick;

  NameLabel := TLabel.Create(Card);
  NameLabel.Parent := Card;
  NameLabel.HitTest := False;
  NameLabel.Position.X := 10;
  NameLabel.Position.Y := 8;
  NameLabel.Width := 246;
  NameLabel.Height := 24;
  NameLabel.Text := AName;
  NameLabel.TextSettings.Font.Size := 7;

  GoalLabel := TLabel.Create(Card);
  GoalLabel.Parent := Card;
  GoalLabel.HitTest := False;
  GoalLabel.Position.X := 10;
  GoalLabel.Position.Y := 34;
  GoalLabel.Width := 246;
  GoalLabel.Height := 50;
  GoalLabel.Text := 'Cilj: ' + AGoal;
  GoalLabel.WordWrap := True;
  GoalLabel.TextSettings.Font.Size := 5;
end;

procedure TFrmTrainerHome.MemberCardClick(Sender: TObject);
var
  MemberId: Integer;
begin
  if not (Sender is TRectangle) then
    Exit;

  MemberId := TRectangle(Sender).Tag;
  TFrmMemberPlanDetail.CreateForMember(Application, MemberId, Self).Show;
  Hide;
end;

procedure TFrmTrainerHome.btnApproveClick(Sender: TObject);
begin
  UpdateFirstRequestStatus('Odobren');
end;

procedure TFrmTrainerHome.btnBackClick(Sender: TObject);
begin
  if Assigned(Application.MainForm) then
    Application.MainForm.Show;
  Close;
end;

procedure TFrmTrainerHome.btnDeclineClick(Sender: TObject);
begin
  UpdateFirstRequestStatus('Odbijen');
end;

function TFrmTrainerHome.BuildPath(const APath, AFileName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(APath) + AFileName;
end;

function TFrmTrainerHome.FindAssetFile(const AFileName: string): string;
var
  Candidate: string;
begin
  Candidate := BuildPath(BuildPath(ExtractFilePath(ParamStr(0)), 'assets'), AFileName);
  if TFile.Exists(Candidate) then
    Exit(Candidate);

  Candidate := BuildPath(ExtractFilePath(ParamStr(0)), AFileName);
  if TFile.Exists(Candidate) then
    Exit(Candidate);

  Candidate := BuildPath(System.IOUtils.TPath.GetDocumentsPath, AFileName);
  if TFile.Exists(Candidate) then
    Exit(Candidate);

  Result := '';
end;

procedure TFrmTrainerHome.LoadTemplateBackground;
var
  FileName: string;
begin
  FileName := FindAssetFile('Template2.png');
  if FileName <> '' then
    imgBackground.Bitmap.LoadFromFile(FileName);
end;

procedure TFrmTrainerHome.LoadTrainerContext;
begin
  FTrainerId := 0;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT trainer_id, first_name, last_name FROM trainer ' +
    'WHERE status = :status ORDER BY trainer_id LIMIT 1';
  DB.FDQuery1.ParamByName('status').AsString := 'Aktivan';
  DB.FDQuery1.Open;
  if not DB.FDQuery1.IsEmpty then
  begin
    FTrainerId := DB.FDQuery1.FieldByName('trainer_id').AsInteger;
    lblTrainerName.Text := Format('%s %s',
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString]);
  end;
  DB.FDQuery1.Close;

  LoadMemberCards;
end;

procedure TFrmTrainerHome.LoadMemberCards;
const
  CCardHeight = 92;
  CRowGap = 12;
var
  Index: Integer;
  CardLeft, CardTop: Single;
  FullName, Goal: string;
begin
  while lyMembersContent.ChildrenCount > 0 do
    lyMembersContent.Children[0].Free;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT m.member_id, m.first_name, m.last_name, p.goal ' +
    'FROM member m ' +
    'JOIN plan_training p ON p.member_id = m.member_id ' +
    'WHERE p.trainer_id = :trainer_id ' +
    'ORDER BY m.member_id';
  DB.FDQuery1.ParamByName('trainer_id').AsInteger := FTrainerId;
  DB.FDQuery1.Open;

  Index := 0;
  while not DB.FDQuery1.Eof do
  begin
    CardLeft := 6;
    CardTop := Index * (CCardHeight + CRowGap);

    FullName := Format('%s %s',
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString]);

    Goal := DB.FDQuery1.FieldByName('goal').AsString;
    if Goal = '' then
      Goal := 'Cilj nije unet.';

    AddMemberCard(CardLeft, CardTop, FullName, Goal,
      DB.FDQuery1.FieldByName('member_id').AsInteger);

    Inc(Index);
    DB.FDQuery1.Next;
  end;

  lyMembersContent.Height := Index * (CCardHeight + CRowGap);
  DB.FDQuery1.Close;
end;

procedure TFrmTrainerHome.RefreshRequests;
var
  Lines: string;
begin
  FFirstRequestId := 0;
  Lines := '';

  if FTrainerId = 0 then
  begin
    lblRequests.Text := 'Trener nije pronadjen u bazi.';
    Exit;
  end;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT tr.training_id, tr.start_time, tr.end_time, m.first_name, m.last_name, tr.status ' +
    'FROM training tr ' +
    'JOIN member m ON m.member_id = tr.member_id ' +
    'WHERE tr.trainer_id = :trainer_id AND tr.status = :status ' +
    'ORDER BY tr.training_id DESC LIMIT 5';
  DB.FDQuery1.ParamByName('trainer_id').AsInteger := FTrainerId;
  DB.FDQuery1.ParamByName('status').AsString := 'Na cekanju';
  DB.FDQuery1.Open;

  while not DB.FDQuery1.Eof do
  begin
    if FFirstRequestId = 0 then
      FFirstRequestId := DB.FDQuery1.FieldByName('training_id').AsInteger;

    Lines := Lines + Format('%s %s | %s-%s'#13#10'%s'#13#10,
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString,
       DB.FDQuery1.FieldByName('start_time').AsString,
       DB.FDQuery1.FieldByName('end_time').AsString,
       DB.FDQuery1.FieldByName('status').AsString]);
    DB.FDQuery1.Next;
  end;

  DB.FDQuery1.Close;
  if Lines = '' then
    Lines := 'Trenutno nema novih zahteva.';
  lblRequests.Text := Lines;
end;

procedure TFrmTrainerHome.UpdateFirstRequestStatus(const AStatus: string);
begin
  if FFirstRequestId = 0 then
  begin
    lblRequests.Text := 'Nema zahteva za obradu.';
    Exit;
  end;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'UPDATE training SET status = :status WHERE training_id = :training_id';
  DB.FDQuery1.ParamByName('status').AsString := AStatus;
  DB.FDQuery1.ParamByName('training_id').AsInteger := FFirstRequestId;
  DB.FDQuery1.ExecSQL;

  RefreshRequests;
end;

end.
