object dlgSphinxUserEx: TdlgSphinxUserEx
  Left = 0
  Top = 0
  Caption = 'dlgSphinxUserEx'
  ClientHeight = 334
  ClientWidth = 397
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 13
    Top = 24
    Width = 56
    Height = 15
    Caption = 'User name'
  end
  object Label2: TLabel
    Left = 13
    Top = 53
    Width = 29
    Height = 15
    Caption = 'Email'
  end
  object Label4: TLabel
    Left = 13
    Top = 131
    Width = 79
    Height = 15
    Caption = 'Phone number'
  end
  object Label7: TLabel
    Left = 20
    Top = 219
    Width = 49
    Height = 15
    Caption = 'User type'
  end
  object Label8: TLabel
    Left = 20
    Top = 255
    Width = 63
    Height = 15
    Caption = 'Access level'
  end
  object lblPassword: TLabel
    Left = 144
    Top = 88
    Width = 50
    Height = 15
    Caption = 'Password'
  end
  object edtUserName: TEdit
    Left = 112
    Top = 21
    Width = 265
    Height = 23
    TabOrder = 0
  end
  object edtEmail: TEdit
    Left = 112
    Top = 50
    Width = 265
    Height = 23
    TabOrder = 1
  end
  object cbEmailConfirmed: TCheckBox
    Left = 12
    Top = 88
    Width = 122
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Email confirmed'
    TabOrder = 2
  end
  object edtPhone: TEdit
    Left = 112
    Top = 128
    Width = 265
    Height = 23
    TabOrder = 3
  end
  object cb2FA_Enabled: TCheckBox
    Left = 170
    Top = 176
    Width = 121
    Height = 17
    Alignment = taLeftJustify
    Caption = '2FA enabled'
    TabOrder = 4
  end
  object cb2FA_Required: TCheckBox
    Left = 13
    Top = 176
    Width = 121
    Height = 17
    Alignment = taLeftJustify
    Caption = '2FA required'
    TabOrder = 5
  end
  object cbUserType: TComboBox
    Left = 119
    Top = 216
    Width = 161
    Height = 23
    Style = csDropDownList
    Enabled = False
    ItemIndex = 0
    TabOrder = 6
    Text = 'sphinx_ex'
    Items.Strings = (
      'sphinx_ex')
  end
  object cbAccess_Level: TComboBox
    Left = 119
    Top = 252
    Width = 161
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 7
    Text = 'reader'
    Items.Strings = (
      'reader'
      'editor'
      'poweruser'
      'admin')
  end
  object btnOK: TButton
    Left = 216
    Top = 296
    Width = 75
    Height = 25
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 8
  end
  object btnCancel: TButton
    Left = 302
    Top = 296
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 9
  end
  object edtPassword: TEdit
    Left = 200
    Top = 85
    Width = 177
    Height = 23
    TabOrder = 10
  end
end
