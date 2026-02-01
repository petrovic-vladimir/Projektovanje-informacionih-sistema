unit FITMANAGER_sheduleTraining;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, DB,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FITMANAGER_sheduleTrainingFeedback,
  FMX.Layouts;

type
  TFrmSheduleTraining = class(TForm)
    Image1: TImage;
    BtnSchedule: TButton;
    BtnCancel: TButton;
    InputNote: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    GroupBox1: TLayout;
    GroupBox2: TLayout;
    GroupBox3: TLayout;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    procedure sheduleTraining(Sender: TObject);
    procedure Cancel(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSheduleTraining: TFrmSheduleTraining;

implementation

{$R *.fmx}

procedure TFrmSheduleTraining.Cancel(Sender: TObject);
begin
  self.Hide;
end;

procedure TFrmSheduleTraining.sheduleTraining(Sender: TObject);
begin
  FrmSheduleTrainingFeedback.Show
end;

end.
