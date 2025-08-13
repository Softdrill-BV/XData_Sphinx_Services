unit Module.XDataServer;

interface

uses
  System.SysUtils, System.Classes, Sparkle.HttpServer.Module, Sparkle.HttpServer.Context, Sparkle.Comp.Server,
  Sparkle.Comp.HttpSysDispatcher, Aurelius.Drivers.Interfaces, Aurelius.Comp.Connection, XData.Comp.ConnectionPool,
  XData.Server.Module, XData.Comp.Server, Aurelius.Drivers.SQLite, Sparkle.Comp.JwtMiddleware,
  Aurelius.Engine.DatabaseManager, Aurelius.Comp.DBSchema;

type
  TmodServerContainer = class(TDataModule)
    SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher;
    XDataServer: TXDataServer;
    XDataConnectionPool: TXDataConnectionPool;
    acXData: TAureliusConnection;
    XDataServerJWT: TSparkleJwtMiddleware;
    adbsXData: TAureliusDBSchema;
    procedure DataModuleCreate(Sender: TObject);
    procedure XDataServerJWTGetSecretEx(Sender: TObject; const JWT: TJWT; Context: THttpServerContext;
      var Secret: TBytes);
  private
    procedure ServerSetup;
  protected
  public
  end;

var
  modServerContainer: TmodServerContainer;

implementation

uses System.IOUtils, IniFiles, Bcl.Jose.Core.Base, Sparkle.HttpSys.Config, XData.Security.Attributes;

const
  // Arbitrary value to identify the encryption key. Same constant used in Sphinx Server...
  MY_KEYID = 'EE899E1F-305E-4D0C-B2D2-1F9CF13665F1'; // Arbitrary value to identify the key

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TmodServerContainer.DataModuleCreate(Sender: TObject);
var
  LDatabase: TFileName;
begin
  // Place database in application directory for this example
  LDatabase := TPath.ChangeExtension(ParamStr(0), '.db');
  // Setup database connection
  acXData.DriverName := 'SQLite';
  acXData.Params.Clear;
  acXData.Params.Add(Format('Database=%s', [LDatabase]));
  acXData.Params.Add('EnableForeignKeys=True');

  ServerSetup; // Show properties normally set at design time for demo purposes...

  adbsXData.UpdateDatabase; // Ensure database is up-to-date
end;

procedure TmodServerContainer.ServerSetup;
var
  LIniFile: TIniFile;
  LConfig: THttpSysServerConfig;
begin
  LIniFile := TIniFile.Create(TPath.ChangeExtension(ParamStr(0), 'ini'));
  LConfig := THttpSysServerConfig.Create;
  try
    // This demo was developed for running with other web apps via IIS.
    // I prefer to use port 443 (https) to minimize firewall issues (443 is open on most firewalls).
    // Of course 443 is also nice because most servers already have a certificate installed on that port... :-)
    SparkleHttpSysDispatcher.HttpSys.KeepHostInUrlPrefixes := true;

    // These properties are typically set at design time. Shown here for documentation purposes.
    XDataServer.Pool := XDataConnectionPool;
    XDataServer.Dispatcher := SparkleHttpSysDispatcher;
    adbsXData.Connection := acXData;

    // Set BaseUrl and ensure it's registered
    XDataServer.BaseUrl := LIniFile.ReadString('Server', 'BaseURL', 'http://+:2001/example/xdata');
    if not LConfig.IsUrlReserved(XDataServer.BaseUrl) then
      LConfig.ReserveUrl(XDataServer.BaseUrl, [TSidType.CurrentUser, TSidType.NetworkService]);

    // XDataServer must not be active in order to set DefaultEntitySetPermissions!
    // This is overruled by EntityAuthorizeScopes attribute in entities (ref. unit Entities.Example)
    XDataServer.DefaultEntitySetPermissions := EntitySetPermissionsAll;

    // Important in production environments!
    XDataServerJWT.ForbidAnonymousAccess := true;

    // Start server
    SparkleHttpSysDispatcher.Active := true;
  finally
    LConfig.Free;
    LIniFile.Free;
  end;
end;

procedure TmodServerContainer.XDataServerJWTGetSecretEx(Sender: TObject; const JWT: TJWT; Context: THttpServerContext;
  var Secret: TBytes);
var
  LPublicKeyFile: string;
begin
  // Identify the key (signed with private key, validate with public key).
  if JWT.Header.Algorithm = 'RS256' then
  begin
    if JWT.Header.KeyID = MY_KEYID then
    begin
      // Validate with PUBLIC key
      LPublicKeyFile := TPath.GetDirectoryName(ParamStr(0)) + '\my-public.key';
      Secret := TFile.ReadAllBytes(LPublicKeyFile)
    end
    else
      raise EJOSEException.CreateFmt('Unknown Key ID in JWT', [JWT.Header.KeyID]);
  end
  else
    raise EJOSEException.CreateFmt('JWS algorithm [%s] is not supported', [JWT.Header.Algorithm]);
end;

end.
