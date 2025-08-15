unit Module.SphinxService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  Vcl.TMSLogging;

type
  TmodSphinxService = class(TService)
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  modSphinxService: TmodSphinxService;

implementation

uses Module.SphinxServer, TMSLoggingTextOutputHandler, System.IOUtils, TMSLoggingUtils;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  modSphinxService.Controller(CtrlCode);
end;

function TmodSphinxService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TmodSphinxService.ServiceCreate(Sender: TObject);
begin
  // Set up logging to text file
  TMSLogger.RegisterManagedOutputHandler(TTMSLoggerTextOutputHandler.Create(TPath.GetDirectoryName(ParamStr(0)) +
    '\Sphinx_Log.txt'));
  TMSLogger.ExceptionHandling := true;
  TMSLogger.Outputs := [loTimeStamp, loLogLevel, loValue];
end;

procedure TmodSphinxService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
  TMSLogger.Info('Dispatcher paused');
end;

procedure TmodSphinxService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TMSLogger.Info('Starting dispatcher');
  try
    modServerContainer.ReadConfigFromIni;
    modServerContainer.SparkleHttpSysDispatcher.Start;
  except
    on E: System.SysUtils.Exception do
      TMSLogger.Error('Dispatcher start error: ' + E.Message);
  end;
end;

procedure TmodSphinxService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
  TMSLogger.Info('Dispatcher stopped');
end;

end.
