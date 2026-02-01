unit FITMANAGER_membership;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FITMANAGER_membershipFeedback;

type
  TFrmMembership = class(TForm)
    Image1: TImage;
    BtnMembership1: TButton;
    BtnMembership2: TButton;
    BtnMembership3: TButton;
    Edit1: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    BtnAcceptMembership: TButton;
    BtnCancel: TButton;
    procedure acceptMembership(Sender: TObject);
    procedure cancel(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMembership: TFrmMembership;

implementation

{$R *.fmx}

procedure TFrmMembership.acceptMembership(Sender: TObject);
begin
  FrmMembershipFeedback.Show;
end;

procedure TFrmMembership.cancel(Sender: TObject);
begin
  self.Hide;
end;

end.
