unit Module.XDataService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TmodXDataService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
  end;

var
  modXDataService: TmodXDataService;

implementation

uses Module.XDataServer;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  modXDataService.Controller(CtrlCode);
end;

function TmodXDataService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TmodXDataService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
end;

procedure TmodXDataService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Start;
end;

procedure TmodXDataService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
end;

end.
