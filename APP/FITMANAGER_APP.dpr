program FITMANAGER_APP;

uses
  System.StartUpCopy,
  FMX.Forms,
  dmDatabase in 'dmDatabase.pas' {DB: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDB, DB);
  Application.Run;
end.
