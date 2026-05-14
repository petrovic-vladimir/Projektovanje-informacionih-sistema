unit FITMANAGER_memberPlanDetail;

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.ListBox,
  FMX.Controls.Presentation;

type
  TFrmMemberPlanDetail = class(TForm)
    lblTitle: TLabel;
    lblMemberName: TLabel;
    lblProgram: TLabel;
    cbPrograms: TComboBox;
    btnConfirm: TButton;
    procedure btnConfirmClick(Sender: TObject);
  private
    FMemberId: Integer;
    FTrainerForm: TForm;
    FProgramIds: array of Integer;
    procedure LoadMember;
    procedure LoadPrograms;
    procedure SaveProgramChange;
  public
    constructor CreateForMember(AOwner: TComponent; AMemberId: Integer;
      ATrainerForm: TForm); reintroduce;
  end;

implementation

uses
  dmDatabase;

{$R *.fmx}

constructor TFrmMemberPlanDetail.CreateForMember(AOwner: TComponent;
  AMemberId: Integer; ATrainerForm: TForm);
begin
  inherited Create(AOwner);
  FMemberId := AMemberId;
  FTrainerForm := ATrainerForm;

  try
    DB.InitializeDatabase;
    LoadMember;
    LoadPrograms;
  except
    on E: Exception do
      lblMemberName.Text := 'Greska: ' + E.Message;
  end;
end;

procedure TFrmMemberPlanDetail.btnConfirmClick(Sender: TObject);
begin
  SaveProgramChange;
  if Assigned(FTrainerForm) then
    FTrainerForm.Show;
  Close;
end;

procedure TFrmMemberPlanDetail.LoadMember;
begin
  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT first_name, last_name FROM member WHERE member_id = :member_id';
  DB.FDQuery1.ParamByName('member_id').AsInteger := FMemberId;
  DB.FDQuery1.Open;

  if not DB.FDQuery1.IsEmpty then
    lblMemberName.Text := Format('%s %s',
      [DB.FDQuery1.FieldByName('first_name').AsString,
       DB.FDQuery1.FieldByName('last_name').AsString])
  else
    lblMemberName.Text := 'Clan nije pronadjen';

  DB.FDQuery1.Close;
end;

procedure TFrmMemberPlanDetail.LoadPrograms;
var
  CurrentProgramId: Integer;
  NewIndex: Integer;
begin
  cbPrograms.Clear;
  SetLength(FProgramIds, 0);
  CurrentProgramId := 0;

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT program_id FROM plan_training WHERE member_id = :member_id ' +
    'ORDER BY plan_id LIMIT 1';
  DB.FDQuery1.ParamByName('member_id').AsInteger := FMemberId;
  DB.FDQuery1.Open;
  if (not DB.FDQuery1.IsEmpty) and
     (not DB.FDQuery1.FieldByName('program_id').IsNull) then
    CurrentProgramId := DB.FDQuery1.FieldByName('program_id').AsInteger;
  DB.FDQuery1.Close;

  DB.FDQuery1.SQL.Text :=
    'SELECT program_id, title FROM program_training ' +
    'WHERE status <> :deleted_status ORDER BY program_id';
  DB.FDQuery1.ParamByName('deleted_status').AsString := 'Obrisan';
  DB.FDQuery1.Open;
  while not DB.FDQuery1.Eof do
  begin
    NewIndex := cbPrograms.Items.Add(DB.FDQuery1.FieldByName('title').AsString);
    SetLength(FProgramIds, Length(FProgramIds) + 1);
    FProgramIds[NewIndex] := DB.FDQuery1.FieldByName('program_id').AsInteger;

    if FProgramIds[NewIndex] = CurrentProgramId then
      cbPrograms.ItemIndex := NewIndex;

    DB.FDQuery1.Next;
  end;
  DB.FDQuery1.Close;
end;

procedure TFrmMemberPlanDetail.SaveProgramChange;
var
  ProgramId: Integer;
begin
  if cbPrograms.ItemIndex < 0 then
    Exit;

  ProgramId := FProgramIds[cbPrograms.ItemIndex];

  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'UPDATE plan_training SET program_id = :program_id ' +
    'WHERE plan_id = (' +
    'SELECT plan_id FROM plan_training WHERE member_id = :member_id ' +
    'ORDER BY plan_id LIMIT 1)';
  DB.FDQuery1.ParamByName('program_id').AsInteger := ProgramId;
  DB.FDQuery1.ParamByName('member_id').AsInteger := FMemberId;
  DB.FDQuery1.ExecSQL;
end;

end.
