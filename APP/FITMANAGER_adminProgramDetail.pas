unit FITMANAGER_adminProgramDetail;

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Edit, FMX.Memo,
  FMX.ListBox, FMX.Controls.Presentation, FMX.Memo.Types, FMX.ScrollBox;

type
  TFrmAdminProgramDetail = class(TForm)
    lblTitle: TLabel;
    lblName: TLabel;
    edtName: TEdit;
    lblDescription: TLabel;
    memoDescription: TMemo;
    lblType: TLabel;
    edtType: TEdit;
    lblGoal: TLabel;
    edtGoal: TEdit;
    lblStatus: TLabel;
    cbStatus: TComboBox;
    lblMessage: TLabel;
    btnCancel: TButton;
    btnSave: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FProgramId: Integer;
    FAdminForm: TForm;
    function SelectedStatus: string;
    procedure SetupStatusOptions;
    procedure LoadProgram;
    function SaveProgram: Boolean;
  public
    constructor CreateForProgram(AOwner: TComponent; AProgramId: Integer;
      AAdminForm: TForm); reintroduce;
  end;

implementation

uses
  dmDatabase;

{$R *.fmx}

constructor TFrmAdminProgramDetail.CreateForProgram(AOwner: TComponent;
  AProgramId: Integer; AAdminForm: TForm);
begin
  inherited Create(AOwner);
  FProgramId := AProgramId;
  FAdminForm := AAdminForm;
  SetupStatusOptions;

  if FProgramId = 0 then
  begin
    lblTitle.Text := 'Dodaj program';
    cbStatus.ItemIndex := 0;
  end
  else
  begin
    lblTitle.Text := 'Izmeni program';
    LoadProgram;
  end;
end;

procedure TFrmAdminProgramDetail.btnCancelClick(Sender: TObject);
begin
  if Assigned(FAdminForm) then
    FAdminForm.Show;
  Close;
end;

procedure TFrmAdminProgramDetail.btnSaveClick(Sender: TObject);
begin
  if SaveProgram then
  begin
    if Assigned(FAdminForm) then
      FAdminForm.Show;
    Close;
  end;
end;

procedure TFrmAdminProgramDetail.LoadProgram;
begin
  DB.FDQuery1.Close;
  DB.FDQuery1.SQL.Text :=
    'SELECT title, description, program_type, goal, status ' +
    'FROM program_training WHERE program_id = :program_id';
  DB.FDQuery1.ParamByName('program_id').AsInteger := FProgramId;
  DB.FDQuery1.Open;

  if not DB.FDQuery1.IsEmpty then
  begin
    edtName.Text := DB.FDQuery1.FieldByName('title').AsString;
    memoDescription.Text := DB.FDQuery1.FieldByName('description').AsString;
    edtType.Text := DB.FDQuery1.FieldByName('program_type').AsString;
    edtGoal.Text := DB.FDQuery1.FieldByName('goal').AsString;
    if SameText(DB.FDQuery1.FieldByName('status').AsString, 'Neaktivan') then
      cbStatus.ItemIndex := 1
    else
      cbStatus.ItemIndex := 0;
  end;

  DB.FDQuery1.Close;
end;

function TFrmAdminProgramDetail.SaveProgram: Boolean;
begin
  Result := False;

  if Trim(edtName.Text) = '' then
  begin
    lblMessage.Text := 'Naziv programa je obavezan.';
    Exit;
  end;

  if Trim(memoDescription.Text) = '' then
  begin
    lblMessage.Text := 'Opis programa je obavezan.';
    Exit;
  end;

  if Trim(edtType.Text) = '' then
  begin
    lblMessage.Text := 'Tip programa je obavezan.';
    Exit;
  end;

  if cbStatus.ItemIndex < 0 then
    cbStatus.ItemIndex := 0;

  DB.FDQuery1.Close;
  if FProgramId = 0 then
  begin
    DB.FDQuery1.SQL.Text :=
      'INSERT INTO program_training (title, description, program_type, goal, status) ' +
      'VALUES (:title, :description, :program_type, :goal, :status)';
  end
  else
  begin
    DB.FDQuery1.SQL.Text :=
      'UPDATE program_training SET title = :title, description = :description, ' +
      'program_type = :program_type, goal = :goal, status = :status ' +
      'WHERE program_id = :program_id';
    DB.FDQuery1.ParamByName('program_id').AsInteger := FProgramId;
  end;

  DB.FDQuery1.ParamByName('title').AsString := Trim(edtName.Text);
  DB.FDQuery1.ParamByName('description').AsString := Trim(memoDescription.Text);
  DB.FDQuery1.ParamByName('program_type').AsString := Trim(edtType.Text);
  DB.FDQuery1.ParamByName('goal').AsString := Trim(edtGoal.Text);
  DB.FDQuery1.ParamByName('status').AsString := SelectedStatus;
  DB.FDQuery1.ExecSQL;

  Result := True;
end;

function TFrmAdminProgramDetail.SelectedStatus: string;
begin
  if cbStatus.ItemIndex = 1 then
    Result := 'Neaktivan'
  else
    Result := 'Aktivan';
end;

procedure TFrmAdminProgramDetail.SetupStatusOptions;
begin
  cbStatus.Items.Clear;
  cbStatus.Items.Add('Aktivan');
  cbStatus.Items.Add('Neaktivan');
  cbStatus.ItemIndex := 0;
end;

end.
