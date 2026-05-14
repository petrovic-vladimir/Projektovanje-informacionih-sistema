unit dmDatabase;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands;

type
  TDB = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    function BuildPath(const APath, AFileName: string): string;
    function ColumnExists(const ATableName, AColumnName: string): Boolean;
    function ColumnIsRequired(const ATableName, AColumnName: string): Boolean;
    function GetDatabaseFileName: string;
    function GetDatabaseScriptFileName: string;
    function GetDatabaseTemplateFileName: string;
    function DatabaseIsReady: Boolean;
    procedure ConfigureConnection;
    procedure CreateDatabaseFromScript(const AScriptFileName: string);
    procedure CreateMinimalDatabase;
    procedure EnsureDatabaseSchema;
    procedure ExecuteSqlText(const ASqlText: string);
    procedure RebuildPlanTrainingForProgramDelete;
  public
    procedure InitializeDatabase;
  end;

var
  DB: TDB;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDB.ConfigureConnection;
begin
  FDConnection1.Connected := False;
  FDConnection1.Params.Values['DriverID'] := 'SQLite';
  FDConnection1.Params.Values['Database'] := GetDatabaseFileName;
  FDConnection1.LoginPrompt := False;
end;

function TDB.DatabaseIsReady: Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text :=
      'SELECT COUNT(*) AS table_count FROM sqlite_master ' +
      'WHERE type = ''table'' AND name IN (' +
      '''member'', ''trainer'', ''program_training'', ''plan_training'', ' +
      '''schedule'', ''training'', ''records'', ''reports'')';
    Query.Open;
    Result := Query.FieldByName('table_count').AsInteger = 8;
  finally
    Query.Free;
  end;
end;

function TDB.BuildPath(const APath, AFileName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(APath) + AFileName;
end;

function TDB.ColumnExists(const ATableName, AColumnName: string): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';
    Query.Open;
    while not Query.Eof do
    begin
      if SameText(Query.FieldByName('name').AsString, AColumnName) then
        Exit(True);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TDB.ColumnIsRequired(const ATableName, AColumnName: string): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';
    Query.Open;
    while not Query.Eof do
    begin
      if SameText(Query.FieldByName('name').AsString, AColumnName) then
        Exit(Query.FieldByName('notnull').AsInteger = 1);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TDB.CreateDatabaseFromScript(const AScriptFileName: string);
begin
  ExecuteSqlText(TFile.ReadAllText(AScriptFileName, TEncoding.UTF8));
end;

procedure TDB.CreateMinimalDatabase;
const
  CMinimalDatabaseSql =
    'PRAGMA foreign_keys = OFF;'#13#10 +
    'CREATE TABLE IF NOT EXISTS member (' +
    'member_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, ' +
    'first_name TEXT NOT NULL, last_name TEXT NOT NULL, age INTEGER NOT NULL, ' +
    'sex TEXT NOT NULL, phone TEXT, email TEXT NOT NULL, membership_date TEXT, status TEXT);'#13#10 +
    'CREATE TABLE IF NOT EXISTS trainer (' +
    'trainer_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, ' +
    'first_name TEXT NOT NULL, last_name TEXT NOT NULL, phone TEXT, email TEXT NOT NULL, ' +
    'specialization TEXT, status TEXT);'#13#10 +
    'CREATE TABLE IF NOT EXISTS program_training (' +
    'program_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL UNIQUE, ' +
    'description TEXT NOT NULL, program_type TEXT NOT NULL, goal TEXT, status TEXT NOT NULL DEFAULT ''Aktivan'');'#13#10 +
    'CREATE TABLE IF NOT EXISTS plan_training (' +
    'plan_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, goal TEXT, ' +
    'max_training_count INTEGER NOT NULL, duration_minutes INTEGER NOT NULL, start_date TEXT NOT NULL, ' +
    'end_date TEXT NOT NULL, status TEXT NOT NULL, program_id INTEGER, member_id INTEGER NOT NULL, ' +
    'trainer_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(program_id) REFERENCES program_training(program_id) ON DELETE SET NULL, ' +
    'FOREIGN KEY(member_id) REFERENCES member(member_id), ' +
    'FOREIGN KEY(trainer_id) REFERENCES trainer(trainer_id));'#13#10 +
    'CREATE TABLE IF NOT EXISTS schedule (' +
    'schedule_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, training_date TEXT NOT NULL, ' +
    'start_time TEXT NOT NULL, end_time TEXT NOT NULL, status TEXT, note TEXT, plan_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(plan_id) REFERENCES plan_training(plan_id));'#13#10 +
    'CREATE TABLE IF NOT EXISTS training (' +
    'training_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, reservation_time TEXT NOT NULL, ' +
    'start_time TEXT NOT NULL, end_time TEXT NOT NULL, status TEXT, note TEXT, member_id INTEGER NOT NULL, ' +
    'trainer_id INTEGER NOT NULL, schedule_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(member_id) REFERENCES member(member_id), ' +
    'FOREIGN KEY(trainer_id) REFERENCES trainer(trainer_id), ' +
    'FOREIGN KEY(schedule_id) REFERENCES schedule(schedule_id));'#13#10 +
    'CREATE TABLE IF NOT EXISTS records (' +
    'record_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, presence INTEGER NOT NULL DEFAULT 1, ' +
    'status TEXT, trainer_note TEXT, record_date TEXT NOT NULL, record_time TEXT NOT NULL, training_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(training_id) REFERENCES training(training_id));'#13#10 +
    'CREATE TABLE IF NOT EXISTS reports (' +
    'report_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, title TEXT, report_type TEXT, ' +
    'start_time TEXT NOT NULL, end_time TEXT NOT NULL, date_created TEXT NOT NULL, description TEXT, record_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(record_id) REFERENCES records(record_id));'#13#10 +
    'INSERT OR IGNORE INTO member VALUES ' +
    '(300, ''Aleksandar'', ''Markovic'', 34, ''Muski'', ''+381641112233'', ' +
    '''aleksandar.markovic@example.com'', ''2026-01-08'', ''Aktivan'');'#13#10 +
    'INSERT OR IGNORE INTO trainer VALUES ' +
    '(400, ''Milan'', ''Trifunovic'', ''+381601001001'', ''milan.trifunovic@fitmanager.rs'', ' +
    '''Snaga i hipertrofija'', ''Aktivan'');'#13#10 +
    'INSERT OR IGNORE INTO program_training VALUES ' +
    '(100, ''Pocetni program snage'', ''Program za clanove koji prvi put rade sa opterecenjem.'', ' +
    '''Snaga'', ''Savladavanje tehnike i osnovna snaga'', ''Aktivan'');'#13#10 +
    'INSERT OR IGNORE INTO plan_training VALUES ' +
    '(200, ''Osnovna snaga - Aleksandar'', ''Sigurna tehnika cucnja, potiska i mrtvog dizanja'', ' +
    '16, 60, ''2026-05-01'', ''2026-07-15'', ''Aktivan'', 100, 300, 400);'#13#10 +
    'DELETE FROM sqlite_sequence WHERE name IN (''program_training'', ''plan_training'', ''member'', ''trainer'');'#13#10 +
    'INSERT INTO sqlite_sequence(name, seq) VALUES ' +
    '(''program_training'', 100), (''plan_training'', 200), (''member'', 300), (''trainer'', 400);'#13#10 +
    'PRAGMA foreign_keys = ON;';
begin
  ExecuteSqlText(CMinimalDatabaseSql);
end;

procedure TDB.EnsureDatabaseSchema;
begin
  if not ColumnExists('plan_training', 'trainer_id') then
  begin
    FDConnection1.ExecSQL('ALTER TABLE plan_training ADD COLUMN trainer_id INTEGER');
    FDConnection1.ExecSQL(
      'UPDATE plan_training SET trainer_id = CASE plan_id ' +
      'WHEN 200 THEN 400 WHEN 201 THEN 404 WHEN 202 THEN 400 ' +
      'WHEN 203 THEN 402 WHEN 204 THEN 401 WHEN 205 THEN 405 ' +
      'WHEN 206 THEN 406 WHEN 207 THEN 407 WHEN 208 THEN 408 ' +
      'WHEN 209 THEN 409 ELSE 400 END ' +
      'WHERE trainer_id IS NULL');
  end;

  if ColumnIsRequired('plan_training', 'program_id') then
    RebuildPlanTrainingForProgramDelete;
end;

procedure TDB.RebuildPlanTrainingForProgramDelete;
begin
  ExecuteSqlText(
    'PRAGMA foreign_keys = OFF;'#13#10 +
    'CREATE TABLE plan_training_new (' +
    'plan_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, ' +
    'title TEXT NOT NULL, goal TEXT, max_training_count INTEGER NOT NULL, ' +
    'duration_minutes INTEGER NOT NULL, start_date TEXT NOT NULL, end_date TEXT NOT NULL, ' +
    'status TEXT NOT NULL, program_id INTEGER, member_id INTEGER NOT NULL, trainer_id INTEGER NOT NULL, ' +
    'FOREIGN KEY(program_id) REFERENCES program_training(program_id) ON DELETE SET NULL, ' +
    'FOREIGN KEY(member_id) REFERENCES member(member_id), ' +
    'FOREIGN KEY(trainer_id) REFERENCES trainer(trainer_id));'#13#10 +
    'INSERT INTO plan_training_new ' +
    '(plan_id, title, goal, max_training_count, duration_minutes, start_date, end_date, status, program_id, member_id, trainer_id) ' +
    'SELECT plan_id, title, goal, max_training_count, duration_minutes, start_date, end_date, status, program_id, member_id, trainer_id ' +
    'FROM plan_training;'#13#10 +
    'DROP TABLE plan_training;'#13#10 +
    'ALTER TABLE plan_training_new RENAME TO plan_training;'#13#10 +
    'DELETE FROM sqlite_sequence WHERE name = ''plan_training'';'#13#10 +
    'INSERT INTO sqlite_sequence(name, seq) SELECT ''plan_training'', COALESCE(MAX(plan_id), 199) FROM plan_training;'#13#10 +
    'PRAGMA foreign_keys = ON;');
end;

procedure TDB.ExecuteSqlText(const ASqlText: string);
var
  Script: TFDScript;
begin
  Script := TFDScript.Create(nil);
  try
    Script.Connection := FDConnection1;
    Script.SQLScripts.Clear;
    Script.SQLScripts.Add.SQL.Text := ASqlText;
    Script.ValidateAll;
    Script.ExecuteAll;
  finally
    Script.Free;
  end;
end;

procedure TDB.DataModuleCreate(Sender: TObject);
begin
end;

procedure TDB.InitializeDatabase;
var
  DatabaseFileName: string;
  DatabaseTemplateFileName: string;
  DatabaseScriptFileName: string;
begin
  ConfigureConnection;
  DatabaseFileName := FDConnection1.Params.Values['Database'];

  if not TFile.Exists(DatabaseFileName) then
  begin
    TDirectory.CreateDirectory(ExtractFilePath(DatabaseFileName));

    DatabaseTemplateFileName := GetDatabaseTemplateFileName;
    if (DatabaseTemplateFileName <> '') and
       (not SameText(DatabaseTemplateFileName, DatabaseFileName)) then
      TFile.Copy(DatabaseTemplateFileName, DatabaseFileName, True);

    if not TFile.Exists(DatabaseFileName) then
    begin
      FDConnection1.Connected := True;
      DatabaseScriptFileName := GetDatabaseScriptFileName;
      if DatabaseScriptFileName <> '' then
        CreateDatabaseFromScript(DatabaseScriptFileName)
      else
        CreateMinimalDatabase;
    end
    else
      FDConnection1.Connected := True;
  end
  else
    FDConnection1.Connected := True;

  if not DatabaseIsReady then
  begin
    DatabaseScriptFileName := GetDatabaseScriptFileName;
    if DatabaseScriptFileName <> '' then
      CreateDatabaseFromScript(DatabaseScriptFileName)
    else
    begin
      DatabaseTemplateFileName := GetDatabaseTemplateFileName;
      if (DatabaseTemplateFileName <> '') and
         (not SameText(DatabaseTemplateFileName, DatabaseFileName)) then
      begin
        FDConnection1.Connected := False;
        TFile.Copy(DatabaseTemplateFileName, DatabaseFileName, True);
        FDConnection1.Connected := True;
      end;

      if not DatabaseIsReady then
        CreateMinimalDatabase;
    end;
  end;

  EnsureDatabaseSchema;
end;

function TDB.GetDatabaseFileName: string;
begin
  {$IFDEF MSWINDOWS}
  Result := '..\database\fitmanager.db';
  {$ELSE}
  Result := BuildPath(System.IOUtils.TPath.GetDocumentsPath, 'fitmanager.db');
  {$ENDIF}
end;

function TDB.GetDatabaseScriptFileName: string;
var
  CandidateFileName: string;
begin
  {$IFDEF MSWINDOWS}
  CandidateFileName := '..\database\create_database.sql';
  if TFile.Exists(CandidateFileName) then
    Result := CandidateFileName
  else
    Result := '';
  {$ELSE}
  CandidateFileName := BuildPath(System.IOUtils.TPath.GetDocumentsPath, 'create_database.sql');
  if TFile.Exists(CandidateFileName) then
    Exit(CandidateFileName);

  CandidateFileName := BuildPath(ExtractFilePath(ParamStr(0)), 'create_database.sql');
  if TFile.Exists(CandidateFileName) then
    Exit(CandidateFileName);

  Result := '';
  {$ENDIF}
end;

function TDB.GetDatabaseTemplateFileName: string;
var
  CandidateFileName: string;
begin
  {$IFDEF MSWINDOWS}
  Result := '';
  {$ELSE}
  CandidateFileName := BuildPath(System.IOUtils.TPath.GetDocumentsPath, 'fitmanager.db');
  if TFile.Exists(CandidateFileName) then
    Exit(CandidateFileName);

  CandidateFileName := BuildPath(ExtractFilePath(ParamStr(0)), 'fitmanager.db');
  if TFile.Exists(CandidateFileName) then
    Exit(CandidateFileName);

  Result := '';
  {$ENDIF}
end;

end.
