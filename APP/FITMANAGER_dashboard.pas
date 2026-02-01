unit FITMANAGER_dashboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,FMX.DialogService,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Calendar, FMX.Colors,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, DB, FITMANAGER_sheduleTraining, FITMANAGER_membership, FITMANAGER_trainerSelection;

type
  TFrmDashboard = class(TForm)
    Image1: TImage;
    BtnScheduleTraining: TButton;
    BtnMembership: TButton;
    BtnTrainerSelection: TButton;
    BtnScheduleConsultation: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sheduleTraining(Sender: TObject);
    procedure membership(Sender: TObject);
    procedure trainerSelection(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDashboard: TFrmDashboard;

implementation

{$R *.fmx}

procedure TFrmDashboard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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

procedure TFrmDashboard.membership(Sender: TObject);
begin
  frmMembership.Show;
end;

procedure TFrmDashboard.sheduleTraining(Sender: TObject);
begin
  frmSheduleTraining.Show;
end;

procedure TFrmDashboard.trainerSelection(Sender: TObject);
begin
  frmTrainerSelection.Show;
end;

end.
