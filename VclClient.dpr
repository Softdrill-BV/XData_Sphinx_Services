program VclClient;

uses
  Vcl.Forms,
  Form.VclClient in 'Form.VclClient.pas' {frmVclClient},
  Entities.Example in 'Entities.Example.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmVclClient, frmVclClient);
  Application.Run;
end.
