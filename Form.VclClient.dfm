object frmVclClient: TfrmVclClient
  Left = 0
  Top = 0
  Caption = 'VCL Client Application'
  ClientHeight = 862
  ClientWidth = 947
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Panel2: TPanel
    Left = 0
    Top = 313
    Width = 947
    Height = 209
    Align = alTop
    BorderWidth = 10
    Caption = 'Panel2'
    TabOrder = 0
    ExplicitTop = 393
    object DBNavigator2: TDBNavigator
      Left = 110
      Top = 10
      Width = 240
      Height = 25
      DataSource = dsSecret
      TabOrder = 0
    end
    object DBGrid2: TDBGrid
      Left = 11
      Top = 45
      Width = 925
      Height = 153
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = dsSecret
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Secret'
          Width = 296
          Visible = True
        end>
    end
    object btnSecret: TButton
      Left = 11
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Get secrets'
      TabOrder = 2
      OnClick = btnSecretClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 522
    Width = 947
    Height = 340
    Align = alClient
    BorderWidth = 10
    Caption = 'Panel3'
    TabOrder = 1
    ExplicitTop = 602
    ExplicitHeight = 295
    object memLog: TMemo
      Left = 11
      Top = 11
      Width = 925
      Height = 283
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      ExplicitHeight = 358
    end
    object Panel4: TPanel
      Left = 11
      Top = 294
      Width = 925
      Height = 35
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object btnClear: TButton
        Left = 842
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Clear log'
        TabOrder = 0
        OnClick = btnClearClick
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 947
    Height = 313
    Align = alTop
    BorderWidth = 10
    TabOrder = 2
    object Label1: TLabel
      Left = 10
      Top = 64
      Width = 11
      Height = 15
      Caption = 'ID'
      FocusControl = dbeID
    end
    object Label2: TLabel
      Left = 10
      Top = 93
      Width = 54
      Height = 15
      Caption = 'InvoiceNo'
    end
    object Label3: TLabel
      Left = 10
      Top = 122
      Width = 52
      Height = 15
      Caption = 'Customer'
    end
    object Label4: TLabel
      Left = 502
      Top = 122
      Width = 64
      Height = 15
      Caption = 'Invoice date'
    end
    object dbeID: TDBEdit
      Left = 100
      Top = 61
      Width = 377
      Height = 23
      DataField = 'ID'
      DataSource = dsInvoice
      ReadOnly = True
      TabOrder = 0
    end
    object dbInvoiceNo: TDBEdit
      Left = 101
      Top = 90
      Width = 140
      Height = 23
      DataField = 'InvoiceNo'
      DataSource = dsInvoice
      TabOrder = 1
    end
    object dbeInvoiceCustomer: TDBEdit
      Left = 100
      Top = 119
      Width = 377
      Height = 23
      DataField = 'Customer'
      DataSource = dsInvoice
      TabOrder = 2
    end
    object DBEdit1: TDBEdit
      Left = 593
      Top = 122
      Width = 140
      Height = 23
      DataField = 'InvoiceDate'
      DataSource = dsInvoice
      TabOrder = 3
    end
    object DBNavigator1: TDBNavigator
      Left = 198
      Top = 10
      Width = 240
      Height = 25
      DataSource = dsInvoice
      TabOrder = 4
    end
    object DBGrid1: TDBGrid
      Left = 11
      Top = 160
      Width = 925
      Height = 142
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = dsInvoiceItems
      TabOrder = 5
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          ReadOnly = True
          Title.Alignment = taCenter
          Width = 199
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ItemDescription'
          Title.Alignment = taCenter
          Title.Caption = 'Description'
          Width = 220
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Amount'
          Width = 109
          Visible = True
        end>
    end
    object btnLogin: TButton
      Left = 10
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Log in...'
      TabOrder = 6
      OnClick = btnLoginClick
    end
    object btnLogout: TButton
      Left = 101
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Log out'
      TabOrder = 7
      OnClick = btnLogoutClick
    end
  end
  object adsInvoice: TAureliusDataset
    FieldDefs = <
      item
        Name = 'Self'
        Attributes = [faReadonly]
        DataType = ftVariant
      end
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftGuid
        Size = 38
      end
      item
        Name = 'InvoiceNo'
        Attributes = [faRequired]
        DataType = ftString
        Size = 10
      end
      item
        Name = 'Customer'
        Attributes = [faRequired]
        DataType = ftString
        Size = 50
      end
      item
        Name = 'InvoiceDate'
        Attributes = [faRequired]
        DataType = ftDateTime
      end
      item
        Name = 'InvoiceItems'
        Attributes = [faReadonly]
        DataType = ftDataSet
      end>
    Left = 32
    Top = 200
    DesignClass = 'Entities.Example.TInvoice'
    object adsInvoiceSelf: TAureliusEntityField
      FieldName = 'Self'
      ReadOnly = True
    end
    object adsInvoiceID: TGuidField
      FieldName = 'ID'
      Required = True
      Size = 38
    end
    object adsInvoiceInvoiceNo: TStringField
      FieldName = 'InvoiceNo'
      Required = True
      Size = 10
    end
    object adsInvoiceCustomer: TStringField
      FieldName = 'Customer'
      Required = True
      Size = 50
    end
    object adsInvoiceInvoiceDate: TDateTimeField
      FieldName = 'InvoiceDate'
      Required = True
    end
    object adsInvoiceInvoiceItems: TDataSetField
      FieldName = 'InvoiceItems'
      ReadOnly = True
    end
  end
  object adsInvoiceItems: TAureliusDataset
    DatasetField = adsInvoiceInvoiceItems
    FieldDefs = <
      item
        Name = 'Self'
        Attributes = [faReadonly]
        DataType = ftVariant
      end
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftGuid
        Size = 38
      end
      item
        Name = 'ItemDescription'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'Amount'
        Attributes = [faRequired]
        DataType = ftFloat
      end
      item
        Name = 'Invoice'
        DataType = ftVariant
      end>
    Left = 88
    Top = 248
    DesignClass = 'Entities.Example.TInvoiceItem'
    object adsInvoiceItemsSelf: TAureliusEntityField
      FieldName = 'Self'
      ReadOnly = True
    end
    object adsInvoiceItemsID: TGuidField
      FieldName = 'ID'
      Required = True
      Size = 38
    end
    object adsInvoiceItemsItemDescription: TStringField
      FieldName = 'ItemDescription'
      Size = 50
    end
    object adsInvoiceItemsAmount: TFloatField
      FieldName = 'Amount'
      Required = True
    end
    object adsInvoiceItemsInvoice: TAureliusEntityField
      FieldName = 'Invoice'
    end
  end
  object dsInvoice: TDataSource
    DataSet = adsInvoice
    Left = 168
    Top = 200
  end
  object dsInvoiceItems: TDataSource
    DataSet = adsInvoiceItems
    Left = 232
    Top = 248
  end
  object SphinxLogin: TSphinxLogin
    Scope = 'openid email'
    OnUserLoggedIn = SphinxLoginUserLoggedIn
    Left = 840
    Top = 224
  end
  object adsSecret: TAureliusDataset
    FieldDefs = <
      item
        Name = 'Self'
        Attributes = [faReadonly]
        DataType = ftVariant
      end
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftGuid
        Size = 38
      end
      item
        Name = 'Secret'
        Attributes = [faRequired]
        DataType = ftString
        Size = 50
      end>
    Left = 288
    Top = 424
    DesignClass = 'Entities.Example.TSecret'
    object adsSecretSelf: TAureliusEntityField
      FieldName = 'Self'
      ReadOnly = True
    end
    object adsSecretID: TGuidField
      FieldName = 'ID'
      Required = True
      Size = 38
    end
    object adsSecretSecret: TStringField
      FieldName = 'Secret'
      Required = True
      Size = 50
    end
  end
  object dsSecret: TDataSource
    DataSet = adsSecret
    Left = 360
    Top = 432
  end
end
