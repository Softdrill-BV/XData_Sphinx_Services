program SphinxManager;

uses
  Vcl.Forms,
  Form.SphinxManager in 'Form.SphinxManager.pas' {frmManager},
  Entities.SphinxUserEx in 'Entities.SphinxUserEx.pas',
  Form.SphinxUserEx in 'Form.SphinxUserEx.pas' {dlgSphinxUserEx};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmManager, frmManager);
  Application.Run;
end.
