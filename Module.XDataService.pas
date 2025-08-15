unit Module.XDataService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  Vcl.TMSLogging;

type
  TmodXDataService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
  end;

var
  modXDataService: TmodXDataService;

implementation

uses Module.XDataServer, System.IOUtils, TMSLoggingTextOutputHandler, TMSLoggingUtils;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  modXDataService.Controller(CtrlCode);
end;

function TmodXDataService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TmodXDataService.ServiceCreate(Sender: TObject);
begin
  // Set up logging to text file
  TMSLogger.RegisterManagedOutputHandler(TTMSLoggerTextOutputHandler.Create(TPath.GetDirectoryName(ParamStr(0)) +
    '\XData_Log.txt'));
  TMSLogger.ExceptionHandling := true;
  TMSLogger.Outputs := [loTimeStamp, loLogLevel, loValue];
end;

procedure TmodXDataService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
  TMSLogger.Info('Dispatcher paused');
end;

procedure TmodXDataService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TMSLogger.Info('Starting dispatcher');
  try
    modServerContainer.SparkleHttpSysDispatcher.Start;
  except
    on E: System.SysUtils.Exception do
      TMSLogger.Error('Dispatcher start error: ' + E.Message);
  end;
end;

procedure TmodXDataService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  modServerContainer.SparkleHttpSysDispatcher.Stop;
  TMSLogger.Info('Dispatcher stopped');
end;

end.
