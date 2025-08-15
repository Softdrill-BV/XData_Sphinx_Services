object frmManager: TfrmManager
  Left = 0
  Top = 0
  Caption = 'Sphinx Configuration and User Manager'
  ClientHeight = 427
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 600
    Height = 9
    Align = alTop
    Shape = bsSpacer
  end
  object pcManager: TPageControl
    Left = 0
    Top = 9
    Width = 600
    Height = 418
    ActivePage = tsSettings
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 387
    object tsSettings: TTabSheet
      Caption = 'Sphinx Settings'
      ImageIndex = 1
      object Label1: TLabel
        Left = 16
        Top = 64
        Width = 65
        Height = 15
        Caption = 'User name : '
      end
      object Label6: TLabel
        Left = 16
        Top = 89
        Width = 81
        Height = 15
        Caption = 'Email address : '
      end
      object Label7: TLabel
        Left = 16
        Top = 115
        Width = 88
        Height = 15
        Caption = 'Phone number : '
      end
      object lblPassword: TLabel
        Left = 17
        Top = 235
        Width = 123
        Height = 15
        Caption = 'Password min. length : '
      end
      object Label2: TLabel
        Left = 16
        Top = 24
        Width = 89
        Height = 15
        Caption = 'Server base URL: '
      end
      object Label3: TLabel
        Left = 17
        Top = 296
        Width = 97
        Height = 15
        Caption = 'Login App Folder: '
        Transparent = True
      end
      object Label4: TLabel
        Left = 16
        Top = 158
        Width = 68
        Height = 15
        Caption = 'Log in with : '
      end
      object cbUsernameRequired: TCheckBox
        Left = 152
        Top = 64
        Width = 100
        Height = 17
        Caption = 'Required'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object cbEmailRequired: TCheckBox
        Left = 152
        Top = 89
        Width = 100
        Height = 17
        Caption = 'Required'
        TabOrder = 1
      end
      object cbPhoneRequired: TCheckBox
        Left = 152
        Top = 115
        Width = 100
        Height = 17
        Caption = 'Required'
        TabOrder = 2
      end
      object cbEmailUnique: TCheckBox
        Left = 256
        Top = 89
        Width = 100
        Height = 17
        Caption = 'Require unique'
        TabOrder = 3
      end
      object cbPhoneUnique: TCheckBox
        Left = 256
        Top = 115
        Width = 100
        Height = 17
        Caption = 'Require unique'
        TabOrder = 4
      end
      object cbPhoneConfirmation: TCheckBox
        Left = 400
        Top = 115
        Width = 140
        Height = 17
        Caption = 'Require confirmation'
        TabOrder = 5
      end
      object cbEmailConfirmation: TCheckBox
        Left = 400
        Top = 89
        Width = 140
        Height = 17
        Caption = 'Require confirmation'
        TabOrder = 6
      end
      object sePasswordLength: TSpinEdit
        Left = 153
        Top = 232
        Width = 57
        Height = 24
        MaxValue = 255
        MinValue = 4
        TabOrder = 7
        Value = 4
      end
      object cbPasswordUpper: TCheckBox
        Left = 257
        Top = 235
        Width = 129
        Height = 17
        Caption = 'Require uppercase'
        Checked = True
        State = cbChecked
        TabOrder = 8
      end
      object cbPasswordLower: TCheckBox
        Left = 257
        Top = 258
        Width = 121
        Height = 17
        Caption = 'Require lowercase'
        Checked = True
        State = cbChecked
        TabOrder = 9
      end
      object cbPasswordDigit: TCheckBox
        Left = 400
        Top = 235
        Width = 97
        Height = 17
        Caption = 'Require digit'
        Checked = True
        State = cbChecked
        TabOrder = 10
      end
      object cbPasswordSpecial: TCheckBox
        Left = 400
        Top = 258
        Width = 169
        Height = 17
        Caption = 'Require special character'
        TabOrder = 11
      end
      object edtBaseUrl: TEdit
        Left = 152
        Top = 21
        Width = 417
        Height = 23
        TabOrder = 12
      end
      object cb2FA_All: TCheckBox
        Left = 153
        Top = 193
        Width = 296
        Height = 17
        Caption = 'Require two factor authentication for ALL users'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 13
      end
      object edtLoginAppFolder: TEdit
        Left = 153
        Top = 293
        Width = 417
        Height = 23
        TabOrder = 14
      end
      object btnSave: TButton
        Left = 456
        Top = 343
        Width = 113
        Height = 25
        Caption = 'Save configuration'
        TabOrder = 15
        OnClick = btnSaveClick
      end
      object cbAllowUserName: TCheckBox
        Left = 153
        Top = 158
        Width = 88
        Height = 17
        Caption = 'User name'
        TabOrder = 16
      end
      object cbAllowEmail: TCheckBox
        Left = 257
        Top = 158
        Width = 100
        Height = 17
        Caption = 'Email address'
        TabOrder = 17
      end
      object cbAllowPhone: TCheckBox
        Left = 401
        Top = 158
        Width = 112
        Height = 17
        Caption = 'Phone number'
        TabOrder = 18
      end
    end
    object tsUser: TTabSheet
      Caption = 'User Management'
      object lblFindType: TLabel
        Left = 14
        Top = 55
        Width = 64
        Height = 15
        Caption = 'Find user by'
      end
      object lblFindBy: TLabel
        Left = 16
        Top = 100
        Width = 56
        Height = 15
        Caption = 'User name'
      end
      object lblDatabase: TLabel
        Left = 14
        Top = 21
        Width = 68
        Height = 15
        Caption = 'No database'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object rbUserName: TRadioButton
        Left = 141
        Top = 55
        Width = 89
        Height = 17
        Caption = 'User name'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = PickFindBy
      end
      object rbEmail: TRadioButton
        Left = 256
        Top = 55
        Width = 97
        Height = 17
        Caption = 'Email address'
        TabOrder = 1
      end
      object edtFind: TEdit
        Left = 141
        Top = 97
        Width = 324
        Height = 23
        TabOrder = 2
      end
      object btnCreateUser: TButton
        Left = 141
        Top = 136
        Width = 100
        Height = 25
        Caption = 'Create user...'
        TabOrder = 3
        OnClick = btnCreateUserClick
      end
      object btnEditUser: TButton
        Left = 253
        Top = 136
        Width = 100
        Height = 25
        Caption = 'Edit user...'
        TabOrder = 4
        OnClick = btnEditUserClick
      end
      object btnDelete: TButton
        Left = 365
        Top = 136
        Width = 100
        Height = 25
        Caption = 'Delete user...'
        TabOrder = 5
        OnClick = btnDeleteClick
      end
    end
  end
  object SphinxConfig: TSphinxConfig
    Clients = <>
    LoginOptions.ForbidSelfRegistration = True
    PasswordOptions.RequiredLength = 4
    Left = 360
    Top = 32
  end
  object acSphinx: TAureliusConnection
    DriverName = 'SQLite'
    Params.Strings = (
      'EnableForeignKeys=True')
    Left = 445
    Top = 40
  end
end
