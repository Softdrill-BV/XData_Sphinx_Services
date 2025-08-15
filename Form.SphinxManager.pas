unit Form.SphinxManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Sphinx.Comp.Config, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,

  Aurelius.Engine.ObjectManager, Aurelius.Drivers.SQLite, Aurelius.Comp.Connection,

  // uSphinxMailer, // Removed from demo.  Please implement your own.

  Entities.SphinxUserEx;

type
  TfrmManager = class(TForm)
    SphinxConfig: TSphinxConfig;
    acSphinx: TAureliusConnection;
    pcManager: TPageControl;
    tsUser: TTabSheet;
    tsSettings: TTabSheet;
    rbUserName: TRadioButton;
    rbEmail: TRadioButton;
    lblFindType: TLabel;
    lblFindBy: TLabel;
    edtFind: TEdit;
    btnCreateUser: TButton;
    btnEditUser: TButton;
    lblDatabase: TLabel;
    Bevel1: TBevel;
    cbUsernameRequired: TCheckBox;
    cbEmailRequired: TCheckBox;
    cbPhoneRequired: TCheckBox;
    cbEmailUnique: TCheckBox;
    cbPhoneUnique: TCheckBox;
    cbPhoneConfirmation: TCheckBox;
    cbEmailConfirmation: TCheckBox;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblPassword: TLabel;
    sePasswordLength: TSpinEdit;
    cbPasswordUpper: TCheckBox;
    cbPasswordLower: TCheckBox;
    cbPasswordDigit: TCheckBox;
    cbPasswordSpecial: TCheckBox;
    Label2: TLabel;
    edtBaseUrl: TEdit;
    cb2FA_All: TCheckBox;
    Label3: TLabel;
    edtLoginAppFolder: TEdit;
    btnDelete: TButton;
    btnSave: TButton;
    Label4: TLabel;
    cbAllowUserName: TCheckBox;
    cbAllowEmail: TCheckBox;
    cbAllowPhone: TCheckBox;
    procedure btnCreateUserClick(Sender: TObject);
    procedure btnEditUserClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PickFindBy(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    // *******************************************************************************************************
    // strict private
    // FMailer: TSphinxMailer; // Removed from demo.  Please implement your own.
    // *******************************************************************************************************
  private
    { Private declarations }
    FObjMgr: TObjectManager;
    function GeneratePassword(const PasswordLength: Integer; const IncludeUppercase, IncludeLowercase, IncludeNumeric,
      IncludeSymbol: boolean): string;
    function FindByValueIsValid: boolean;
  public
    { Public declarations }
    procedure ReadIniFile;
    procedure WriteIniFile;
  end;

var
  frmManager: TfrmManager;

implementation

uses System.IOUtils, System.UITypes, System.IniFiles, Aurelius.Mapping.Explorer, Sphinx.CoreOptions,
  Sphinx.ConfigCoreOptions, Sphinx.UserManager, Sphinx.UserManager.Impl, Form.SphinxUserEx,

  WinSvc;

{$R *.dfm}

procedure TfrmManager.btnCreateUserClick(Sender: TObject);
var
  CoreOptions: ICoreOptions;
  UsrMgr: IUserManager;
  Usr: TSphinxUserEx;
  dlgUser: TdlgSphinxUserEx;
  // LResponse: string;
begin
  if not FindByValueIsValid then
    exit;

  // Ref. https://support.tmssoftware.com/t/create-user-with-aurelius-and-set-initial-password/25703/8)
  CoreOptions := TConfigCoreOptions.Create(SphinxConfig);
  UsrMgr := TUserManager.Create(CoreOptions, FObjMgr, false);

  // Check if user does not already exist
  if rbUserName.Checked then
    Usr := UsrMgr.FindByName(edtFind.Text) as TSphinxUserEx
  else
    Usr := UsrMgr.FindByEmail(edtFind.Text) as TSphinxUserEx;
  if assigned(Usr) then
  begin
    messageDlg(Format('User %s already exists.', [edtFind.Text]) + sLineBreak + 'Edit user to modify profile.',
      mtWarning, [mbOK], 0);
    exit;
  end;

  // Create a new user
  Usr := UsrMgr.CreateUserInstance as TSphinxUserEx;

  dlgUser := TdlgSphinxUserEx.Create(self);
  try
    if rbUserName.Checked then
      dlgUser.UserName := edtFind.Text
    else
      dlgUser.UserEmail := edtFind.Text;
    dlgUser.Password := GeneratePassword(6, cbPasswordUpper.Checked, cbPasswordLower.Checked, cbPasswordDigit.Checked,
      cbPasswordSpecial.Checked);
    dlgUser.TwoFactorEnabledVisible := false; // Never set TwoFactorEnabled.  See below...
    dlgUser.UserAccessLevel := 'reader'; // Default lowest level
    if dlgUser.ShowModal = mrOK then
    begin
      Usr.UserName.Value := dlgUser.UserName;
      Usr.Email.Value := dlgUser.UserEmail;
      Usr.EmailConfirmed.Value := dlgUser.EmailConfirmed;
      Usr.PhoneNumber.Value := dlgUser.UserPhoneNumber;
      Usr.TwoFactorEnabled := dlgUser.TwoFactorEnabled;
      Usr.TwoFactorRequired.Value := dlgUser.TwoFactorRequired;
      // User type determined by class (discriminator value)
      Usr.Access_Level.Value := dlgUser.UserAccessLevel;

      UsrMgr.CreateUser(Usr, dlgUser.Password);

      // Set 2FA, if required
      UsrMgr.SetTwoFactorRequired(Usr, dlgUser.TwoFactorRequired);
      // *******************************************************************************************************
      // Do NOT set 2FA Enabled for a new user! Setting to TRUE will cause QR not to show on first log in
      // Think of 2FA Enabled as "2FA was activated / set up for this user".
      // Ref. https://support.tmssoftware.com/t/sphinx-mfa-qr-code-not-showing-loginoptions-requiretwofactor-not-honoured/25763/2
      // UsrMgr.SetTwoFactorEnabled(Usr, dlgUser.TwoFactorEnabled);
      // *******************************************************************************************************

      // // Create mail module, if required
      // if not assigned(FMailer) then
      // FMailer := TSphinxMailer.Create;
      // try
      // LResponse := FMailer.SendNewAccountDetails(Usr.Email.Value, Usr.UserName.Value, dlgUser.Password);
      // messageDlg('Email with account details sent to: ' + Usr.Email.Value, TMsgDlgType.mtInformation, [mbOK], 0);
      // except
      // messageDlg('Sending email with new account details to ' + Usr.Email.Value + ' failed.' + sLineBreak +
      // 'Email response: ' + LResponse, mtError, [mbOK], 0);
      // end;
    end;
  finally
    dlgUser.Free;
  end;
end;

procedure TfrmManager.btnDeleteClick(Sender: TObject);
var
  CoreOptions: ICoreOptions;
  UsrMgr: IUserManager;
  Usr: TSphinxUserEx;
begin
  if not FindByValueIsValid then
    exit;

  CoreOptions := TConfigCoreOptions.Create(SphinxConfig);
  UsrMgr := TUserManager.Create(CoreOptions, FObjMgr, false); // Use object manager managed by form (create/destroy)
  if rbUserName.Checked then
    Usr := UsrMgr.FindByName(edtFind.Text) as TSphinxUserEx
  else
    Usr := UsrMgr.FindByEmail(edtFind.Text) as TSphinxUserEx;
  if assigned(Usr) then
  begin
    if messageDlg('Permanently delete user ' + edtFind.Text + ' from database?', TMsgDlgType.mtConfirmation,
      [mbYes, mbNo], 0) = mrYes then
    begin
      UsrMgr.DeleteUser(Usr);
      messageDlg('User ' + edtFind.Text + ' deleted from database.', TMsgDlgType.mtInformation, [mbOK], 0)
    end;
  end;
end;

procedure TfrmManager.btnEditUserClick(Sender: TObject);
var
  CoreOptions: ICoreOptions;
  UsrMgr: IUserManager;
  Usr: TSphinxUserEx;
  dlgUser: TdlgSphinxUserEx;
begin
  if not FindByValueIsValid then
    exit;

  CoreOptions := TConfigCoreOptions.Create(SphinxConfig);
  UsrMgr := TUserManager.Create(CoreOptions, FObjMgr, false);
  if rbUserName.Checked then
    Usr := UsrMgr.FindByName(edtFind.Text) as TSphinxUserEx
  else
    Usr := UsrMgr.FindByEmail(edtFind.Text) as TSphinxUserEx;
  if assigned(Usr) then
  begin
    dlgUser := TdlgSphinxUserEx.Create(self);
    try
      dlgUser.UserName := Usr.UserName.ValueOrDefault;
      dlgUser.UserEmail := Usr.Email.ValueOrDefault;
      dlgUser.EmailConfirmed := Usr.EmailConfirmed.ValueOrDefault;

      dlgUser.Password := ''; // Hides password edit

      dlgUser.UserPhoneNumber := Usr.PhoneNumber.ValueOrDefault;
      dlgUser.TwoFactorRequired := Usr.TwoFactorRequired.ValueOrDefault;
      dlgUser.TwoFactorEnabledVisible := true;
      dlgUser.TwoFactorEnabled := Usr.TwoFactorEnabled;
      dlgUser.UserType := 'sphinx_ex';
      dlgUser.UserAccessLevel := Usr.Access_Level.ValueOrDefault;
      if dlgUser.ShowModal = mrOK then
      begin
        Usr.UserName.Value := dlgUser.UserName;
        Usr.Email.Value := dlgUser.UserEmail;
        Usr.EmailConfirmed.Value := dlgUser.EmailConfirmed;
        Usr.PhoneNumber.Value := dlgUser.UserPhoneNumber;
        // User.UserType determined by class (discriminator value)
        Usr.Access_Level.Value := dlgUser.UserAccessLevel;

        UsrMgr.UpdateUser(Usr);

        // Reset 2FA, if required
        UsrMgr.SetTwoFactorRequired(Usr, dlgUser.TwoFactorRequired);

        UsrMgr.SetTwoFactorEnabled(Usr, dlgUser.TwoFactorEnabled);
        if not Usr.TwoFactorEnabled then
          if UsrMgr.GetAuthenticatorKey(Usr) = '' then
            UsrMgr.ResetAuthenticatorKey(Usr);

        messageDlg(Format('User %s (%s) updated.', [Usr.UserName.Value, Usr.Email.Value]), TMsgDlgType.mtInformation,
          [mbOK], 0);
      end;
    finally
      dlgUser.Free;
    end;
  end
  else
    messageDlg(edtFind.Text + ' not found in database.', mtWarning, [mbOK], 0);
end;

procedure TfrmManager.btnSaveClick(Sender: TObject);
begin
  WriteIniFile;
  messageDlg('Configuration saved to ini file.' + sLineBreak +
    'For changes to take effect, restart the SphinxService...', TMsgDlgType.mtInformation, [mbOK], 0);
end;

function TfrmManager.FindByValueIsValid: boolean;
var
  LFindText: string;
begin
  LFindText := edtFind.Text;
  result := not(LFindText = '');
  // Some kind of check on email address
  if result and rbEmail.Checked then
    result := (Pos('@', LFindText) > 0) and (Pos('.', LFindText) > 0);
  if not result then
    if rbUserName.Checked then
      messageDlg('Please enter a valid user name.', mtError, [mbOK], 0)
    else
      messageDlg('Please enter a valid email address.', mtError, [mbOK], 0);
end;

procedure TfrmManager.FormCreate(Sender: TObject);
var
  LDatabase: string;
begin
  // We use an extended user class (ref. TmodServerContainer.SphinxConfigConfigureToken)!
  SphinxConfig.UserClass := TSphinxUserEx;

  // Setup database connection
  LDatabase := TPath.GetDirectoryName(ParamStr(0)) + '\SphinxService.db';
  acSphinx.DriverName := 'SQLite';
  acSphinx.Params.Clear;
  acSphinx.Params.Add(Format('Database=%s', [LDatabase]));
  acSphinx.Params.Add('EnableForeignKeys=True');

  lblDatabase.Caption := 'Database: ' + LDatabase;

  // Read SphinxConfig settings from ini file
  ReadIniFile;

  // Object manager for user management via IUserManager
  // Ref. https://support.tmssoftware.com/t/create-user-with-aurelius-and-set-initial-password/25703/8
  FObjMgr := TObjectManager.Create(acSphinx.CreateConnection, TMappingExplorer.Get('Biz.Sphinx'));
end;

procedure TfrmManager.FormDestroy(Sender: TObject);
begin
  FObjMgr.Free;
end;

function TfrmManager.GeneratePassword(const PasswordLength: Integer; const IncludeUppercase, IncludeLowercase,
  IncludeNumeric, IncludeSymbol: boolean): string;
const
  UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz';
  NUMERIC_CHARS   = '0123456789';
  SYMBOL_CHARS    = '!@#$%^&*()_+=-~[]\{}|;\: ",./ <> ? ';
var
  CharsToUse: string;
  ii, Idx: Integer;
begin
  // Utility function. Feel free to create/use your own
  result := '';
  // Build string to pick from
  CharsToUse := '';
  if IncludeUppercase then
    CharsToUse := CharsToUse + UPPERCASE_CHARS;
  if IncludeLowercase then
    CharsToUse := CharsToUse + LOWERCASE_CHARS;
  if IncludeNumeric then
    CharsToUse := CharsToUse + NUMERIC_CHARS;
  if IncludeSymbol then
    CharsToUse := CharsToUse + SYMBOL_CHARS;
  // Generate the password
  for ii := 1 to PasswordLength do
  begin
    Idx := Random(Length(CharsToUse)) + 1;
    result := result + CharsToUse[Idx];
  end;
  // Ensure mandatory characters are present
  if IncludeUppercase and (Pos('A', result) = 0) then
    result[Random(Length(result)) + 1] := UPPERCASE_CHARS[Random(Length(UPPERCASE_CHARS)) + 1];
  if IncludeLowercase and (Pos('a', result) = 0) then
    result[Random(Length(result)) + 1] := LOWERCASE_CHARS[Random(Length(LOWERCASE_CHARS)) + 1];
  if IncludeNumeric and (Pos('0', result) = 0) then
    result[Random(Length(result)) + 1] := NUMERIC_CHARS[Random(Length(NUMERIC_CHARS)) + 1];
  if IncludeSymbol and (Pos('!', result) = 0) then
    result[Random(Length(result)) + 1] := SYMBOL_CHARS[Random(Length(SYMBOL_CHARS)) + 1];
end;

procedure TfrmManager.PickFindBy(Sender: TObject);
begin
  // Hooked into OnClick for radiobuttons
  if rbUserName.Checked then
    lblFindBy.Caption := 'User name'
  else
    lblFindBy.Caption := 'Email address';
end;

procedure TfrmManager.ReadIniFile;
var
  LIniFile: TIniFile;
begin
  LIniFile := TIniFile.Create(TPath.GetDirectoryName(ParamStr(0)) + '\SphinxService.ini');
  try
    edtBaseUrl.Text := LIniFile.ReadString('Server', 'BaseURL', 'http://+:2001/example/sphinx');

    cbUsernameRequired.Checked := LIniFile.ReadBool('SphinxConfig', 'UserNameRequired', true);
    cbEmailRequired.Checked := LIniFile.ReadBool('SphinxConfig', 'EmailRequired', true);
    cbEmailUnique.Checked := LIniFile.ReadBool('SphinxConfig', 'EmailUnique', true);
    cbEmailConfirmation.Checked := LIniFile.ReadBool('SphinxConfig', 'EmailConfirmation', true);
    cbPhoneRequired.Checked := LIniFile.ReadBool('SphinxConfig', 'PhoneRequired', true);
    cbPhoneUnique.Checked := LIniFile.ReadBool('SphinxConfig', 'PhoneUnique', true);
    cbPhoneConfirmation.Checked := LIniFile.ReadBool('SphinxConfig', 'PhoneConfirmation', true);

    cbAllowUserName.Checked := LIniFile.ReadBool('SphinxConfig', 'AllowUserName', true);
    cbAllowEmail.Checked := LIniFile.ReadBool('SphinxConfig', 'AllowEmailAddress', true);
    cbAllowPhone.Checked := LIniFile.ReadBool('SphinxConfig', 'AllowPhoneNumber', false);

    cb2FA_All.Checked := LIniFile.ReadBool('SphinxConfig', 'TwoFactorAll', false);

    sePasswordLength.Value := LIniFile.ReadInteger('SphinxConfig', 'PasswordLength', 4);
    cbPasswordUpper.Checked := LIniFile.ReadBool('SphinxConfig', 'PasswordUpper', true);
    cbPasswordLower.Checked := LIniFile.ReadBool('SphinxConfig', 'PasswordLower', true);
    cbPasswordDigit.Checked := LIniFile.ReadBool('SphinxConfig', 'PasswordDigit', true);
    cbPasswordSpecial.Checked := LIniFile.ReadBool('SphinxConfig', 'PasswordSpecial', true);

    edtLoginAppFolder.Text := LIniFile.ReadString('SphinxConfig', 'LoginAppFolder', '');
  finally
    LIniFile.Free;
  end;
end;

procedure TfrmManager.WriteIniFile;
var
  LIniFile: TIniFile;
begin
  LIniFile := TIniFile.Create(TPath.GetDirectoryName(ParamStr(0)) + '\SphinxService.ini');
  try
    LIniFile.WriteString('Server', 'BaseURL', edtBaseUrl.Text);

    LIniFile.WriteBool('SphinxConfig', 'UserNameRequired', cbUsernameRequired.Checked);
    LIniFile.WriteBool('SphinxConfig', 'EmailRequired', cbEmailRequired.Checked);
    LIniFile.WriteBool('SphinxConfig', 'EmailUnique', cbEmailUnique.Checked);
    LIniFile.WriteBool('SphinxConfig', 'EmailConfirmation', cbEmailConfirmation.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PhoneRequired', cbPhoneRequired.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PhoneUnique', cbPhoneUnique.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PhoneConfirmation', cbPhoneConfirmation.Checked);

    LIniFile.WriteBool('SphinxConfig', 'AllowUserName', cbAllowUserName.Checked);
    LIniFile.WriteBool('SphinxConfig', 'AllowEmailAddress', cbAllowEmail.Checked);
    LIniFile.WriteBool('SphinxConfig', 'AllowPhoneNumber', cbAllowPhone.Checked);

    LIniFile.WriteBool('SphinxConfig', 'TwoFactorAll', cb2FA_All.Checked);

    LIniFile.WriteInteger('SphinxConfig', 'PasswordLength', sePasswordLength.Value);
    LIniFile.WriteBool('SphinxConfig', 'PasswordUpper', cbPasswordUpper.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PasswordLower', cbPasswordLower.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PasswordDigit', cbPasswordDigit.Checked);
    LIniFile.WriteBool('SphinxConfig', 'PasswordSpecial', cbPasswordSpecial.Checked);

    LIniFile.WriteString('SphinxConfig', 'LoginAppFolder', edtLoginAppFolder.Text);
  finally
    LIniFile.Free;
  end;
end;

end.
