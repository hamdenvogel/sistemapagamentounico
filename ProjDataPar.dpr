program ProjDataPar;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  ChildWin in 'ChildWin.pas' {MDIChild},
  about in 'about.pas' {AboutBox},
  unPagamento in 'unPagamento.pas',
  unUtils in 'unUtils.pas',
  unDataModule in 'unDataModule.pas' {dmModule: TDataModule},
  unCalculoPagamento in 'unCalculoPagamento.pas',
  unt_Excel in 'unt_Excel.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TdmModule, dmModule);
  Application.Run;
end.
