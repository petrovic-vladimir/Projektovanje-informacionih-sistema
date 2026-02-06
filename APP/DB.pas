unit DB;

interface

uses
  System.SysUtils, System.Classes,
  Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Phys,
  FireDAC.FMXUI.Wait, FireDAC.Phys.ODBC, FireDAC.Phys.ODBCDef;

type
  TUserRole = (urNone, urAdmin, urMember, urInstructor);

  TdmDB = class(TDataModule)
    DbConnect: TFDConnection;
    Query_getAllUsers: TFDQuery;
  private
    FCurrentUserId: Integer;
    FCurrentUsername: string;
    FCurrentEmail: string;
    FCurrentRole: TUserRole;
    procedure ResetCurrentUser;
    procedure EnsureConnected;
  public
    function AuthenticateUser(const ALogin, APassword: string): Boolean;
    function GetRoleByUserId(const AUserId: Integer): TUserRole;

    function RegisterUser(const AName, ALname, AUsername, APassword, AEmail,
      AJMBG, APhone: string): Boolean;

    property CurrentUserId: Integer read FCurrentUserId;
    property CurrentUsername: string read FCurrentUsername;
    property CurrentEmail: string read FCurrentEmail;
    property CurrentRole: TUserRole read FCurrentRole;
  end;

var
  dmDB: TdmDB;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

procedure TdmDB.EnsureConnected;
begin
  if not DbConnect.Connected then
    DbConnect.Connected := True;
end;

procedure TdmDB.ResetCurrentUser;
begin
  FCurrentUserId := 0;
  FCurrentUsername := '';
  FCurrentEmail := '';
  FCurrentRole := urNone;
end;

function TdmDB.GetRoleByUserId(const AUserId: Integer): TUserRole;
var
  Q: TFDQuery;
  RoleCode: Integer;
begin
  EnsureConnected;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DbConnect;

    // FK kolona se zove [User] u sve 3 tabele
    Q.SQL.Text :=
      'SELECT CASE ' +
      'WHEN EXISTS (SELECT 1 FROM [Admin]      WHERE [User] = :id) THEN 1 ' +
      'WHEN EXISTS (SELECT 1 FROM [Member]     WHERE [User] = :id) THEN 2 ' +
      'WHEN EXISTS (SELECT 1 FROM [Instructor] WHERE [User] = :id) THEN 3 ' +
      'ELSE 0 END AS RoleCode';

    Q.ParamByName('id').AsInteger := AUserId;
    Q.Open;

    RoleCode := Q.FieldByName('RoleCode').AsInteger;

    case RoleCode of
      1: Result := urAdmin;
      2: Result := urMember;
      3: Result := urInstructor;
    else
      Result := urNone;
    end;
  finally
    Q.Free;
  end;
end;

function TdmDB.AuthenticateUser(const ALogin, APassword: string): Boolean;
var
  Q: TFDQuery;
  LLogin: string;
begin
  ResetCurrentUser;
  EnsureConnected;

  LLogin := Trim(ALogin);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DbConnect;

    Q.SQL.Text :=
      'SELECT TOP 1 ID_User, Username, Email ' +
      'FROM [User] ' +
      'WHERE (Username = :login OR Email = :login) ' +
      '  AND [Password] = :pass';

    Q.ParamByName('login').AsString := LLogin;
    Q.ParamByName('pass').AsString := APassword;

    Q.Open;
    Result := not Q.IsEmpty;

    if Result then
    begin
      FCurrentUserId := Q.FieldByName('ID_User').AsInteger;

      if Q.FindField('Username') <> nil then
        FCurrentUsername := Q.FieldByName('Username').AsString;

      if Q.FindField('Email') <> nil then
        FCurrentEmail := Q.FieldByName('Email').AsString;

      FCurrentRole := GetRoleByUserId(FCurrentUserId);
    end;
  finally
    Q.Free;
  end;
end;

function TdmDB.RegisterUser(const AName, ALname, AUsername, APassword, AEmail,
  AJMBG, APhone: string): Boolean;
var
  Q: TFDQuery;
  PhoneInt: Integer;
begin
  EnsureConnected;

  // phone mora da bude broj (int u bazi)
  if not TryStrToInt(Trim(APhone), PhoneInt) then
    Exit(False);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DbConnect;

    // Provera duplikata: Username ili Email ili JMBG
    Q.SQL.Text :=
      'SELECT 1 FROM [User] ' +
      'WHERE Username = :u OR Email = :e OR JMBG = :j';
    Q.ParamByName('u').AsString := Trim(AUsername);
    Q.ParamByName('e').AsString := Trim(AEmail);
    Q.ParamByName('j').AsString := Trim(AJMBG);
    Q.Open;

    if not Q.IsEmpty then
      Exit(False);

    Q.Close;

    // Insert u [User]
    Q.SQL.Text :=
      'INSERT INTO [User] (Name, Lname, Username, [Password], Email, Phone, Created_at, JMBG, Status) ' +
      'VALUES (:n, :ln, :u, :p, :e, :ph, GETDATE(), :j, :st)';

    Q.ParamByName('n').AsString  := Trim(AName);
    Q.ParamByName('ln').AsString := Trim(ALname);
    Q.ParamByName('u').AsString  := Trim(AUsername);
    Q.ParamByName('p').AsString  := APassword; // (kasnije hash)
    Q.ParamByName('e').AsString  := Trim(AEmail);
    Q.ParamByName('ph').AsInteger := PhoneInt;
    Q.ParamByName('j').AsString  := Trim(AJMBG);
    Q.ParamByName('st').AsString := 'Aktivan';

    Q.ExecSQL;

    Result := True;
  finally
    Q.Free;
  end;
end;

function TdmDB.GetAllTrainers: TFDQuery;
var
  Q: TFDQuery;
begin
  EnsureConnected;

  Q := TFDQuery.Create(nil);
  Q.Connection := DbConnect;

  Q.SQL.Text :=
    'SELECT ' +
    ' u.Username, u.Email, u.Phone, u.Status, i.Specialization ' +
    'FROM instructor i ' +
    'JOIN `user` u ON i.`User` = u.ID_User ' +
    'WHERE u.Status = ''Aktivan'' ' +
    'ORDER BY u.Username';

  Q.Open;
  Result := Q;
end;

end.

end.

