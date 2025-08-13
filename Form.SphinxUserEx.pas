unit Form.SphinxUserEx;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Entities.SphinxUserEx;

type
  TdlgSphinxUserEx = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edtUserName: TEdit;
    edtEmail: TEdit;
    cbEmailConfirmed: TCheckBox;
    edtPhone: TEdit;
    cb2FA_Enabled: TCheckBox;
    cb2FA_Required: TCheckBox;
    cbUserType: TComboBox;
    cbAccess_Level: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    lblPassword: TLabel;
    edtPassword: TEdit;
  private
    { Private declarations }
    procedure SetPassword(const Value: string);
    function GetPassword: string;
    function GetEmailConfirmed: boolean;
    function GetTwoFactorEnabled: boolean;
    function GetTwoFactorRequired: boolean;
    function GetUserAccessLevel: string;
    function GetUserEmail: string;
    function GetUserName: string;
    function GetUserPhoneNumber: string;
    function GetUserType: string;
    procedure SetEmailConfirmed(const Value: boolean);
    procedure SetTwoFactorRequired(const Value: boolean);
    procedure SetTwoFactorEnabled(const Value: boolean);
    procedure SetUserAccessLevel(const Value: string);
    procedure SetUserEmail(const Value: string);
    procedure SetUserName(const Value: string);
    procedure SetUserPhoneNumber(const Value: string);
    procedure SetUserType(const Value: string);
    function GetTwoFactorEnabledVisible: boolean;
    procedure SetTwoFactorEnabledVisible(const Value: boolean);
  protected
  public
    { Public declarations }
    property UserName: string read GetUserName write SetUserName;
    property UserEmail: string read GetUserEmail write SetUserEmail;
    property EmailConfirmed: boolean read GetEmailConfirmed write SetEmailConfirmed;
    property Password: string read GetPassword write SetPassword;
    property UserPhoneNumber: string read GetUserPhoneNumber write SetUserPhoneNumber;
    property TwoFactorRequired: boolean read GetTwoFactorRequired write SetTwoFactorRequired;
    property TwoFactorEnabled: boolean read GetTwoFactorEnabled write SetTwoFactorEnabled;
    property TwoFactorEnabledVisible: boolean read GetTwoFactorEnabledVisible write SetTwoFactorEnabledVisible;
    property UserType: string read GetUserType write SetUserType;
    property UserAccessLevel: string read GetUserAccessLevel write SetUserAccessLevel;
  end;

  // var
  // dlgSphinxUserEx: TdlgSphinxUserEx;

implementation

{$R *.dfm}
{ TdlgSphinxUserEx }

function TdlgSphinxUserEx.GetEmailConfirmed: boolean;
begin
  result := cbEmailConfirmed.Checked;
end;

function TdlgSphinxUserEx.GetPassword: string;
begin
  result := edtPassword.Text;
end;

function TdlgSphinxUserEx.GetTwoFactorEnabled: boolean;
begin
  result := cb2FA_Enabled.Checked;
end;

function TdlgSphinxUserEx.GetTwoFactorEnabledVisible: boolean;
begin
  result := cb2FA_Enabled.Visible;
end;

function TdlgSphinxUserEx.GetTwoFactorRequired: boolean;
begin
  result := cb2FA_Required.Checked;
end;

function TdlgSphinxUserEx.GetUserAccessLevel: string;
begin
  result := cbAccess_Level.Items[cbAccess_Level.ItemIndex];
end;

function TdlgSphinxUserEx.GetUserEmail: string;
begin
  result := edtEmail.Text;
end;

function TdlgSphinxUserEx.GetUserName: string;
begin
  result := edtUserName.Text;
end;

function TdlgSphinxUserEx.GetUserPhoneNumber: string;
begin
  result := edtPhone.Text;
end;

function TdlgSphinxUserEx.GetUserType: string;
begin
  result := cbUserType.Items[cbUserType.ItemIndex];
end;

procedure TdlgSphinxUserEx.SetEmailConfirmed(const Value: boolean);
begin
  cbEmailConfirmed.Checked := Value;
end;

procedure TdlgSphinxUserEx.SetPassword(const Value: string);
begin
  edtPassword.Text := Value;
  lblPassword.Visible := (edtPassword.Text <> '');
  edtPassword.Visible := lblPassword.Visible;
end;

procedure TdlgSphinxUserEx.SetTwoFactorEnabled(const Value: boolean);
begin
  cb2FA_Enabled.Checked := Value;
end;

procedure TdlgSphinxUserEx.SetTwoFactorEnabledVisible(const Value: boolean);
begin
  cb2FA_Enabled.Visible := Value;
end;

procedure TdlgSphinxUserEx.SetTwoFactorRequired(const Value: boolean);
begin
  cb2FA_Required.Checked := Value;
end;

procedure TdlgSphinxUserEx.SetUserAccessLevel(const Value: string);
begin
  cbAccess_Level.ItemIndex := cbAccess_Level.Items.IndexOf(Value);
end;

procedure TdlgSphinxUserEx.SetUserEmail(const Value: string);
begin
  edtEmail.Text := Value;
end;

procedure TdlgSphinxUserEx.SetUserName(const Value: string);
begin
  edtUserName.Text := Value;
end;

procedure TdlgSphinxUserEx.SetUserPhoneNumber(const Value: string);
begin
  edtPhone.Text := Value;
end;

procedure TdlgSphinxUserEx.SetUserType(const Value: string);
begin
  // For this demo, default to sphinx_ex
  cbUserType.ItemIndex := 0;
  // cbUserType.ItemIndex := cbUserType.Items.IndexOf(Value);
end;

end.
