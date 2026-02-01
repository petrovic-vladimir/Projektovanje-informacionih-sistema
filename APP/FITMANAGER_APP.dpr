program FITMANAGER_APP;

uses
  System.StartUpCopy,
  FMX.Forms,
  FITMANAGER_login in 'FITMANAGER_login.pas' {FrmLogin},
  FITMANAGER_register in 'FITMANAGER_register.pas' {FrmRegister},
  FITMANAGER_dashboard in 'FITMANAGER_dashboard.pas' {FrmDashboard},
  FITMANAGER_adminPage in 'FITMANAGER_adminPage.pas' {FrmAdmin},
  FITMANAGER_trainerPage in 'FITMANAGER_trainerPage.pas' {FrmTrainer},
  dmMain in 'dmMain.pas' {DataModule1: TDataModule},
  Test in 'Test.pas' {TestDataForm},
  DB in 'DB.pas' {dmDB: TDataModule},
  FITMANAGER_adminUserManagement in 'FITMANAGER_adminUserManagement.pas' {FrmAdminUserManagement},
  FITMANAGER_trainerTrainingPlan in 'FITMANAGER_trainerTrainingPlan.pas' {FrmTrainerTrainingPlan},
  FITMANAGER_sheduleTraining in 'FITMANAGER_sheduleTraining.pas' {FrmSheduleTraining},
  FITMANAGER_sheduleTrainingFeedback in 'FITMANAGER_sheduleTrainingFeedback.pas' {FrmSheduleTrainingFeedback},
  FITMANAGER_membership in 'FITMANAGER_membership.pas' {FrmMembership},
  FITMANAGER_membershipFeedback in 'FITMANAGER_membershipFeedback.pas' {FrmMembershipFeedback},
  FITMANAGER_trainerSelection in 'FITMANAGER_trainerSelection.pas' {FrmTrainerSelection};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmRegister, FrmRegister);
  Application.CreateForm(TFrmDashboard, FrmDashboard);
  Application.CreateForm(TFrmAdmin, FrmAdmin);
  Application.CreateForm(TFrmTrainer, FrmTrainer);
  Application.CreateForm(TdmDB, dmDB);
  Application.CreateForm(TFrmAdminUserManagement, FrmAdminUserManagement);
  Application.CreateForm(TFrmTrainerTrainingPlan, FrmTrainerTrainingPlan);
  Application.CreateForm(TFrmSheduleTraining, FrmSheduleTraining);
  Application.CreateForm(TFrmSheduleTrainingFeedback, FrmSheduleTrainingFeedback);
  Application.CreateForm(TFrmMembership, FrmMembership);
  Application.CreateForm(TFrmMembershipFeedback, FrmMembershipFeedback);
  Application.CreateForm(TFrmTrainerSelection, FrmTrainerSelection);
  //Application.CreateForm(TDataModule1, DataModule1);
  //Application.CreateForm(TTestDataForm, TestDataForm);
  Application.Run;
end.
