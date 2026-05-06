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
    function GetDatabaseFileName: string;
    function GetDatabaseScriptFileName: string;
    procedure ConfigureConnection;
    procedure CreateDatabaseFromScript(const AScriptFileName: string);
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

procedure TDB.CreateDatabaseFromScript(const AScriptFileName: string);
var
  Script: TFDScript;
begin
  if not TFile.Exists(AScriptFileName) then
    raise Exception.CreateFmt('SQL skripta za kreiranje baze nije pronadjena: %s',
      [AScriptFileName]);

  Script := TFDScript.Create(nil);
  try
    Script.Connection := FDConnection1;
    Script.SQLScripts.Clear;
    Script.SQLScripts.Add.SQL.LoadFromFile(AScriptFileName, TEncoding.UTF8);
    Script.ValidateAll;
    Script.ExecuteAll;
  finally
    Script.Free;
  end;
end;

procedure TDB.DataModuleCreate(Sender: TObject);
var
  DatabaseFileName: string;
begin
  if csDesigning in ComponentState then
    Exit;

  ConfigureConnection;
  DatabaseFileName := FDConnection1.Params.Values['Database'];

  if not TFile.Exists(DatabaseFileName) then
  begin
    TDirectory.CreateDirectory(ExtractFilePath(DatabaseFileName));
    FDConnection1.Connected := True;
    CreateDatabaseFromScript(GetDatabaseScriptFileName);
  end
  else
    FDConnection1.Connected := True;
end;

function TDB.GetDatabaseFileName: string;
begin
  {$IFDEF MSWINDOWS}
  Result := '..\database\fitmanager.db';
  {$ELSE}
  Result := TPath.Combine(TPath.GetDocumentsPath, 'fitmanager.db');
  {$ENDIF}
end;

function TDB.GetDatabaseScriptFileName: string;
begin
  {$IFDEF MSWINDOWS}
  Result := '..\database\create_database.sql';
  {$ELSE}
  Result := TPath.Combine(TPath.GetDocumentsPath, 'create_database.sql');
  {$ENDIF}
end;

end.
