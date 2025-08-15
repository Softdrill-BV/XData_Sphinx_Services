unit Form.VclClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Aurelius.Bind.BaseDataset, Aurelius.Bind.Dataset,
  System.Generics.Collections, XData.Client, Entities.Example, Sphinx.Login, Sparkle.Http.Engine, cxGraphics,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons, Vcl.DBCtrls, Vcl.Mask,

  Vcl.TMSLogging, Vcl.TMSLoggingMemoOutputHandler, System.ImageList, Vcl.ImgList;

type
  TfrmVclClient = class(TForm)
    adsInvoice: TAureliusDataset;
    adsInvoiceItems: TAureliusDataset;
    dsInvoice: TDataSource;
    dsInvoiceItems: TDataSource;
    adsInvoiceSelf: TAureliusEntityField;
    adsInvoiceID: TGuidField;
    adsInvoiceInvoiceNo: TStringField;
    adsInvoiceCustomer: TStringField;
    adsInvoiceInvoiceDate: TDateTimeField;
    adsInvoiceInvoiceItems: TDataSetField;
    SphinxLogin: TSphinxLogin;
    adsInvoiceItemsSelf: TAureliusEntityField;
    adsInvoiceItemsID: TGuidField;
    adsInvoiceItemsItemDescription: TStringField;
    adsInvoiceItemsAmount: TFloatField;
    adsInvoiceItemsInvoice: TAureliusEntityField;
    adsSecret: TAureliusDataset;
    adsSecretSelf: TAureliusEntityField;
    adsSecretID: TGuidField;
    adsSecretSecret: TStringField;
    dsSecret: TDataSource;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    dbeID: TDBEdit;
    dbInvoiceNo: TDBEdit;
    dbeInvoiceCustomer: TDBEdit;
    DBEdit1: TDBEdit;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    DBNavigator2: TDBNavigator;
    DBGrid2: TDBGrid;
    memLog: TMemo;
    btnSecret: TButton;
    btnLogin: TButton;
    btnLogout: TButton;
    Panel4: TPanel;
    btnClear: TButton;
    ilVclClient: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure SphinxLoginUserLoggedIn(Args: TUserLoggedInArgs);
    procedure btnClearClick(Sender: TObject);
    procedure btnSecretClick(Sender: TObject);
  strict private
    FXDataClient: TXDataClient;
    FInvoices: TList<TInvoice>;
    // FInserted: TObjectList<TObject>;
    FSecrets: TList<TSecret>;
  private
    { Private declarations }
    procedure ClientSendingRequest(Req: THttpRequest);
    procedure PrepareDatasets;
    procedure LogUserInfo(Info: TAuthResult);
  protected
    { Protected declarations }
    procedure ObjectInsert(Dataset: TDataSet; AObject: TObject);
    procedure ObjectRemove(Dataset: TDataSet; AObject: TObject);
    procedure ObjectUpdate(Dataset: TDataSet; AObject: TObject);
    procedure LoadData;
  public
    { Public declarations }
  end;

var
  frmVclClient: TfrmVclClient;

implementation

uses IniFiles, System.IOUtils, TMSLoggingUtils,
  System.UITypes; // Suppress compiler warning

{$R *.dfm}

procedure TfrmVclClient.btnClearClick(Sender: TObject);
begin
  // Clear the log, if requested...
  memLog.Lines.Clear;
end;

procedure TfrmVclClient.btnLoginClick(Sender: TObject);
begin
  // Ensure the user is not already logged in
  if SphinxLogin.IsLoggedIn then
  begin
    TMSLogger.Info('>> Already logged in!');
    exit;
  end;
  // Perform log in
  SphinxLogin.Login;
end;

procedure TfrmVclClient.SphinxLoginUserLoggedIn(Args: TUserLoggedInArgs);
begin
  // Triggered after successful login...
  TMSLogger.Info('User successfully logged in');
  LogUserInfo(Args.LoginResult);
  try
    LoadData;
    TMSLogger.Info('Data successfully loaded.');
  except
    on E: EXDataClientRequestException do
      TMSLogger.Warning(IntToStr(E.StatusCode) + ' >>> ' + E.ErrorMessage);
  end;
end;

procedure TfrmVclClient.btnLogoutClick(Sender: TObject);
begin
  SphinxLogin.Logout;
  adsSecret.Close;
  adsInvoice.Close;
  TMSLogger.Info('Logged out. All tables closed...');
end;

procedure TfrmVclClient.btnSecretClick(Sender: TObject);
begin
  if adsSecret.Active then
    adsSecret.Close;
  if assigned(FSecrets) then
    FreeAndNil(FSecrets);
  try
    FSecrets := FXDataClient.List<TSecret>;
    adsSecret.SetSourceList(FSecrets);
    adsSecret.Open;
  except
    on E: EXDataClientRequestException do
      TMSLogger.Warning(IntToStr(E.StatusCode) + ' >>> ' + E.ErrorMessage);
  end;
end;

procedure TfrmVclClient.ClientSendingRequest(Req: THttpRequest);
begin
  if SphinxLogin.AuthResult <> nil then
    Req.Headers.SetValue('Authorization', 'Bearer ' + SphinxLogin.AuthResult.AccessToken);
end;

procedure TfrmVclClient.FormCreate(Sender: TObject);
var
  LIniFile: TIniFile;
  LBaseURL: string;
begin
  // Set up logging to text file
  TMSLogger.RegisterManagedOutputHandler(TTMSLoggerMemoOutputHandler.Create(memLog));
  TMSLogger.ExceptionHandling := true;
  TMSLogger.Outputs := [loTimeStamp, loLogLevel, loValue];

  { $IFDEF DEBUG }
  ReportMemoryLeaksOnShutdown := true;
  { $ENDIF }

  // It is assumed that XData, Sphinx and this client are run from the same directory!
  LIniFile := TIniFile.Create(TPath.ChangeExtension(ParamStr(0), 'ini'));
  try
    LBaseURL := LIniFile.ReadString('Server', 'Sphinx.BaseURL', 'http://localhost:2001/example/sphinx');
    SphinxLogin.Authority := LBaseURL;
    SphinxLogin.ClientId := 'XData-Sphinx';
    SphinxLogin.Scope := 'openid email';
    TMSLogger.Info('Sphinx authority: ' + SphinxLogin.Authority);

    FXDataClient := TXDataClient.Create;
    LBaseURL := LIniFile.ReadString('Server', 'XData.BaseURL', 'http://localhost:2001/example/xdata');
    FXDataClient.Uri := LBaseURL;
    FXDataClient.HttpClient.OnSendingRequest := ClientSendingRequest;
    TMSLogger.Info('XData Server: ' + FXDataClient.Uri);

    PrepareDatasets;
  finally
    LIniFile.Free;
  end;
end;

procedure TfrmVclClient.FormDestroy(Sender: TObject);
begin
  if assigned(FSecrets) then
    FSecrets.Free;
  // FInserted.Free; // Owns / destroys objects...
  FInvoices.Free;
  FXDataClient.Free;
end;

procedure TfrmVclClient.LoadData;
begin
  FreeAndNil(FInvoices);
  FInvoices := FXDataClient.List<TInvoice>;
  adsInvoice.SetSourceList(FInvoices);
  adsInvoice.Open;
end;

procedure TfrmVclClient.LogUserInfo(Info: TAuthResult);
begin
  if Info.Profile <> nil then
  begin
    TMSLogger.Info('User ID: ' + Info.Profile.Subject);
    TMSLogger.Info('Email: ' + Info.Profile.Email);
    TMSLogger.Info('EmailVerified: ' + Info.Profile.EmailVerified.ToString(TUseBoolStrs.True));
  end
  else
    TMSLogger.Info('No user profile.');
  TMSLogger.Info('Scope: ' + Info.Scope);
  TMSLogger.Info('Token type: ' + Info.TokenType);
  TMSLogger.Info('Expiration: ' + DateTimeToStr(Info.Expiration));
  TMSLogger.Info('Is expired: ' + BoolToStr(Info.IsExpired, true));
  TMSLogger.Info('Token ID: ' + Copy(Info.IdToken, 1, 30) + '...'); // Clipped to keep log readible...
  TMSLogger.Info('Access token: ' + Copy(Info.AccessToken, 1, 30) + '...');
end;

procedure TfrmVclClient.ObjectInsert(Dataset: TDataSet; AObject: TObject);
begin
  FXDataClient.Post(AObject);
  FXDataClient.ReturnedEntities.Add(AObject);
end;

procedure TfrmVclClient.ObjectRemove(Dataset: TDataSet; AObject: TObject);
begin
  FXDataClient.Delete(AObject);
end;

procedure TfrmVclClient.ObjectUpdate(Dataset: TDataSet; AObject: TObject);
var
  LClass: TClass;
begin
  inherited;
  LClass := AObject.ClassType;
  FXDataClient.Put(AObject as LClass);
end;

procedure TfrmVclClient.PrepareDatasets;
var
  ii: Integer;
begin
  // For ID and Version fields Required must be false to allow posting of entities (records)
  for ii := 0 to ComponentCount - 1 do
    if Components[ii] is TAureliusDataset then
    begin
      TAureliusDataset(Components[ii]).FieldByName('ID').Required := false;
      // Version not used in this demo
      // TAureliusDataset(Components[ii]).FieldByName('Version').Required := false;
      TMSLogger.Info('Set field properties for dataset: ' + TAureliusDataset(Components[ii]).Name);

      // Hook dataset event handlers to ensure objects are handled correctly
      TAureliusDataset(Components[ii]).OnObjectInsert := ObjectInsert;
      TAureliusDataset(Components[ii]).OnObjectUpdate := ObjectUpdate;
      TAureliusDataset(Components[ii]).OnObjectRemove := ObjectRemove;

      TMSLogger.Info('Set object handlers for dataset: ' + TAureliusDataset(Components[ii]).Name);
    end;
end;

end.
