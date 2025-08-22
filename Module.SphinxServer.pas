unit Module.SphinxServer;

interface

uses
  System.SysUtils, System.Classes, Aurelius.Drivers.SQLite, Aurelius.Engine.DatabaseManager, Sparkle.HttpServer.Module,
  Sparkle.HttpServer.Context, Sphinx.Server.Module, Aurelius.Drivers.Interfaces, XData.Comp.ConnectionPool,
  Sphinx.Comp.Config, Sparkle.Comp.Server, XData.Comp.Server, Sphinx.Comp.Server, Aurelius.Comp.DBSchema,
  Aurelius.Comp.Connection, Sparkle.Comp.HttpSysDispatcher,

  // uSphinxMailer, // Removed from demo.  Please implement your own.

  VCL.TMSLogging;

type
  TmodServerContainer = class(TDataModule)
    SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher;
    acSphinx: TAureliusConnection;
    adbsSphinx: TAureliusDBSchema;
    SphinxServer: TSphinxServer;
    SphinxConfig: TSphinxConfig;
    SphinxConnectionPool: TXDataConnectionPool;
    procedure DataModuleCreate(Sender: TObject);
    procedure SphinxConfigGetSigningData(Sender: TObject; Args: TGetSigningDataArgs);
    procedure SphinxConfigConfigureToken(Sender: TObject; Args: TConfigureTokenArgs);
    procedure SphinxConfigGenerateEmailConfirmationToken(Sender: TObject; Args: TGenerateEmailConfirmationTokenArgs);
    procedure SphinxConfigGeneratePasswordResetToken(Sender: TObject; Args: TGeneratePasswordResetTokenArgs);
    procedure DataModuleDestroy(Sender: TObject);
    procedure SparkleHttpSysDispatcherStart(Sender: TObject);
    // strict private
    // FMailer: TSphinxMailer; // Removed from demo.  Please implement your own.
  private
    { Private declarations }
    procedure ConfigureClients;
  public
    { Public declarations }
    procedure ReadConfigFromIni;
  end;

var
  modServerContainer: TmodServerContainer;

implementation

uses System.IOUtils, IniFiles, Entities.SphinxUserEx, Sparkle.HttpSys.Config;

const
  // Arbitrary value to identify the encryption key. Same constant must be used in the XData Server...
  MY_KEYID = 'EE899E1F-305E-4D0C-B2D2-1F9CF13665F1';

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
  { TDataModule1 }

procedure TmodServerContainer.ReadConfigFromIni;
var
  LIniFile: TIniFile;
  LConfig: THttpSysServerConfig;
begin
  LIniFile := TIniFile.Create(TPath.ChangeExtension(ParamStr(0), 'ini'));
  TMSLogger.Info('Reading configuration from: ' + LIniFile.FileName);
  LConfig := THttpSysServerConfig.Create;
  try
    try
      // Set BaseUrl and ensure it's reserved (i.e. no need to use TMSHttpConfig utility
      SphinxServer.BaseUrl := LIniFile.ReadString('Server', 'BaseURL', 'http://+:2001/example/sphinx');
      TMSLogger.Info('Server base URL set to: ' + SphinxServer.BaseUrl);
      if not LConfig.IsUrlReserved(SphinxServer.BaseUrl) then
      begin
        LConfig.ReserveUrl(SphinxServer.BaseUrl, [TSidType.CurrentUser, TSidType.NetworkService]);
        TMSLogger.Info('Server base URL reserved: ' + SphinxServer.BaseUrl);
      end;

      SphinxConfig.UserOptions.RequireUserName := LIniFile.ReadBool('SphinxConfig', 'UserNameRequired', true);
      SphinxConfig.UserOptions.RequireEmail := LIniFile.ReadBool('SphinxConfig', 'EmailRequired', true);
      SphinxConfig.UserOptions.RequireUniqueEmail := LIniFile.ReadBool('SphinxConfig', 'EmailUnique', true);
      SphinxConfig.LoginOptions.RequireConfirmedEmail := LIniFile.ReadBool('SphinxConfig', 'EmailConfirmation', true);
      SphinxConfig.UserOptions.RequirePhoneNumber := LIniFile.ReadBool('SphinxConfig', 'PhoneRequired', true);
      SphinxConfig.UserOptions.RequireUniquePhoneNumber := LIniFile.ReadBool('SphinxConfig', 'PhoneUnique', true);
      SphinxConfig.LoginOptions.RequireConfirmedPhoneNumber :=
        LIniFile.ReadBool('SphinxConfig', 'PhoneConfirmation', true);

      SphinxConfig.LoginOptions.UseEmail := LIniFile.ReadBool('SphinxConfig', 'AllowUserName', true);
      SphinxConfig.LoginOptions.UseUserName := LIniFile.ReadBool('SphinxConfig', 'AllowEmailAddress', true);
      SphinxConfig.LoginOptions.UsePhoneNumber := LIniFile.ReadBool('SphinxConfig', 'AllowPhoneNumber', false);

      SphinxConfig.LoginOptions.RequireTwoFactor := LIniFile.ReadBool('SphinxConfig', 'TwoFactorAll', false);
      TMSLogger.Info('SphinxServer.Require2FA set to ' + BoolToStr(SphinxConfig.LoginOptions.RequireTwoFactor));

      SphinxConfig.PasswordOptions.RequiredLength := LIniFile.ReadInteger('SphinxConfig', 'PasswordLength', 4);
      SphinxConfig.PasswordOptions.RequireUppercase := LIniFile.ReadBool('SphinxConfig', 'PasswordUpper', true);
      SphinxConfig.PasswordOptions.RequireLowercase := LIniFile.ReadBool('SphinxConfig', 'PasswordLower', true);
      SphinxConfig.PasswordOptions.RequireDigit := LIniFile.ReadBool('SphinxConfig', 'PasswordDigit', true);
      SphinxConfig.PasswordOptions.RequireNonAlphanumeric := LIniFile.ReadBool('SphinxConfig', 'PasswordSpecial', true);

      SphinxConfig.UIOptions.LoginAppFolder := LIniFile.ReadString('SphinxConfig', 'LoginAppFolder', '');
      TMSLogger.Info('SphinxServer.LoginAppFolder set to ' + SphinxConfig.UIOptions.LoginAppFolder);

      // SphinxConfig.UIOptions.AccountAppFolder := TPath.GetDirectoryName(ParamStr(0));

      TMSLogger.Info('SphinxConfig settings applied.');
    except
      on E: Exception do
        TMSLogger.Error(E.Message);
    end;
  finally
    LConfig.Free;
    LIniFile.Free;
  end;
end;

procedure TmodServerContainer.ConfigureClients;
var
  LClient: TSphinxClientApp;
begin
  TMSLogger.Info('Configuring clients');

  LClient := SphinxConfig.Clients.Add;
  LClient.ClientId := 'XData-Sphinx';
  LClient.DisplayName := 'XData-Sphinx Example Application';
  LClient.RedirectUris.Add('http://127.0.0.1');
  LClient.RequireClientSecret := false;
  LClient.AllowedGrantTypes := [TGrantType.gtAuthorizationCode];
  LClient.ValidScopes.Add('openid');
  LClient.ValidScopes.Add('email');
  LClient.RequirePkce := true;

  LClient.AccessTokenLifetime := 3600; // Set token lifetime to 1 hour....

  TMSLogger.Info('Configuring client completed. ID = ' + LClient.ClientId);
end;

procedure TmodServerContainer.DataModuleCreate(Sender: TObject);
var
  LDatabase: TFileName;
begin
  TMSLogger.Info('Enter: DataModuleCreate');

  try
    // Place database in application directory for this example
    LDatabase := TPath.ChangeExtension(ParamStr(0), '.db');
    acSphinx.Params.Clear;
    acSphinx.Params.Add(Format('Database=%s', [LDatabase]));
    acSphinx.Params.Add('EnableForeignKeys=True');
    adbsSphinx.UpdateDatabase;
    TMSLogger.Info('Database set to: ' + LDatabase);

    SphinxConfig.UserClass := TSphinxUserEx;

    SphinxServer.Pool := SphinxConnectionPool;
    SparkleHttpSysDispatcher.HttpSys.KeepHostInUrlPrefixes := true; // Running besides IIS
    SphinxServer.Dispatcher := SparkleHttpSysDispatcher;

    ConfigureClients;
  except
    on E: Exception do
      TMSLogger.Error('DataModuleCreate error: ' + E.Message);
  end;
  TMSLogger.Info('Exit: DataModuleCreate');
end;

procedure TmodServerContainer.DataModuleDestroy(Sender: TObject);
begin
  TMSLogger.Info('Enter: DataModuleDestroy');
  // if assigned(FMailer) then
  // FMailer.Free;
  TMSLogger.Info('Exit: DataModuleDestroy');
end;

procedure TmodServerContainer.SparkleHttpSysDispatcherStart(Sender: TObject);
begin
  // *******************************************************************************************************
  // This appears to be the most logical implementation but SphinxServer.BaseUrl = '' (design-time) causes a problem.
  // Apparently, SparkleHttpSysDispatcher is already active at start up of service, causing an exception....
  // Now implemented in TmodSphinxService.ServiceStart (therefore ReadConfigFromIni is public)
  // *******************************************************************************************************
  // Set up configuration from ini file
  // try
  // if not SparkleHttpSysDispatcher.Active then
  // begin
  // ReadConfigFromIni;
  // TMSLogger.Info('Server configured from ini. Starting HttpSysDispatcher.');
  // end;
  // except
  // TMSLogger.Error('Start HttpSysDispatcher - Error reading ini file.');
  // end;
end;

procedure TmodServerContainer.SphinxConfigConfigureToken(Sender: TObject; Args: TConfigureTokenArgs);
begin
  // *******************************************************************************************************
  // Set claims here from custom user type (TSphinxUserEx)
  // For this demo, there are four user levels: reader, editor, poweruser and admin
  // Each level has more (cumulative) rights. PowerUser and Admin have access to "secret" entities.
  // See unit Entities.Example for use of EntityAuthorizeScopes attribute for this purpose
  // *******************************************************************************************************
  Args.Token.Claims.AddOrSet('preferred_username', TSphinxUserEx(Args.User).UserName.Value);
  Args.Token.Claims.AddOrSet('scope', TSphinxUserEx(Args.User).Access_Level);
  TMSLogger.Info('Issued token for: ' + TSphinxUserEx(Args.User).UserName.Value);
  TMSLogger.Info('Added claim''scope'' to JWT token with value: ' + TSphinxUserEx(Args.User).Access_Level);
end;

procedure TmodServerContainer.SphinxConfigGenerateEmailConfirmationToken(Sender: TObject;
  Args: TGenerateEmailConfirmationTokenArgs);
var
  LResponse: string;
begin
  // *******************************************************************************************************
  // User logged in for first time.  Send token to confirm email address (if required by SphinxConfig)
  // *******************************************************************************************************
  TMSLogger.Info('Sending email confirmation token to: ' + Args.User.Email.ValueOrDefault);
  // if not assigned(FMailer) then
  // FMailer := TSphinxMailer.Create;
  // LResponse := FMailer.SendEmailConfirmationToken(Args.User.Email.ValueOrDefault, Args.Token);
  TMSLogger.Info('Result: ' + LResponse);
end;

procedure TmodServerContainer.SphinxConfigGeneratePasswordResetToken(Sender: TObject;
  Args: TGeneratePasswordResetTokenArgs);
var
  LResponse: string;
begin
  // *******************************************************************************************************
  // Send to token for user to reset password (if requested through 'Forgot password' feature on login page
  // *******************************************************************************************************
  TMSLogger.Info('Sending password reset token to: ' + Args.User.Email.ValueOrDefault);
  // if not assigned(FMailer) then
  // FMailer := TSphinxMailer.Create;
  // LResponse := FMailer.SendEmailConfirmationToken(Args.User.Email.ValueOrDefault, Args.Token);
  TMSLogger.Info('Result: ' + LResponse);
end;

procedure TmodServerContainer.SphinxConfigGetSigningData(Sender: TObject; Args: TGetSigningDataArgs);
var
  LPrivateKeyFile: string;
begin
  // *******************************************************************************************************
  // Use PRIVATE key (asymmetric) to sign JWT (JWT token is issued "under the hood" by Sphinx)
  // This identifies the key sent.  Use public key to identify the key is correct (must "match" private key)
  // Use GENERATE_KEYS.bat script to generate the required key files in the application directory
  // Private key may NOT be published (i.e. must remain on server only)!!!!
  // *******************************************************************************************************
  Args.Data.Algorithm := 'RS256'; // Asymmetric
  Args.Data.KeyId := MY_KEYID;

  try
    LPrivateKeyFile := TPath.GetDirectoryName(ParamStr(0)) + '\my-private.key';
    Args.Data.Key := TFile.ReadAllBytes(LPrivateKeyFile);
    TMSLogger.Info('Signed token with private key');
  except
    TMSLogger.Error('Error reading/applying private key file : ' + LPrivateKeyFile);
  end;
end;

end.
