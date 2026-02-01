unit FITMANAGER_trainerPage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,FMX.DialogService;

type
  TFrmTrainer = class(TForm)
    Image1: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmTrainer: TFrmTrainer;

implementation

{$R *.fmx}

procedure TFrmTrainer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := False;

  TDialogService.MessageDialog(
    'Da li ste sigurni da zelite da napustite aplikaciju',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        Application.Terminate;
    end
  );
end;

end.
