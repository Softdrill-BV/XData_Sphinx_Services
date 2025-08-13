unit Entities.Example;

interface

uses
  SysUtils,
  Generics.Collections,
  Aurelius.Mapping.Attributes,
  Aurelius.Types.Blob,
  Aurelius.Types.DynamicProperties,
  Aurelius.Types.Nullable,
  Aurelius.Types.Proxy,

  XData.Security.Attributes;

type
  TInvoice = class;
  TInvoiceItem = class;
  TSecret = class;

  [Entity]

  // Readible by all, editable from editor level up
  [EntityAuthorizeScopes('reader,editor,poweruser,admin', EntitySetPermissionsRead)]
  [EntityAuthorizeScopes('editor,poweruser,admin', EntitySetPermissionsWrite)]

  [Table('Invoice')]
  [Id('FID', TIdGenerator.Guid)]
  TInvoice = class
  private
    [Column('ID', [TColumnProp.Required])]
    FID: TGuid;

    [Column('InvoiceNo', [TColumnProp.Required], 10)]
    FInvoiceNo: string;

    [Column('Customer', [TColumnProp.Required], 50)]
    FCustomer: string;

    [Column('InvoiceDate', [TColumnProp.Required])]
    FInvoiceDate: TDateTime;

    [ManyValuedAssociation([TAssociationProp.Lazy], [TCascadeType.SaveUpdate, TCascadeType.Merge, TCascadeType.Remove],
      'FInvoice')]
    FInvoiceItems: Proxy<TList<TInvoiceItem>>;
    function GetInvoiceItems: TList<TInvoiceItem>;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: TGuid read FID write FID;
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;
    property Customer: string read FCustomer write FCustomer;
    property InvoiceDate: TDateTime read FInvoiceDate write FInvoiceDate;
    property InvoiceItems: TList<TInvoiceItem> read GetInvoiceItems;
  end;

  [Entity]

  // Readible by all, editable from editor level up
  [EntityAuthorizeScopes('reader,editor,poweruser,admin', EntitySetPermissionsRead)]
  [EntityAuthorizeScopes('editor,poweruser,admin', EntitySetPermissionsWrite)]

  [Table('InvoiceItem')]
  [Id('FID', TIdGenerator.Guid)]
  TInvoiceItem = class
  private
    [Column('ID', [TColumnProp.Required])]
    FID: TGuid;

    [Column('ItemDescription', [], 50)]
    FItemDescription: Nullable<string>;

    [Column('Amount', [TColumnProp.Required])]
    FAmount: Double;

    [Association([TAssociationProp.Lazy], CascadeTypeAll - [TCascadeType.Remove])]
    [JoinColumn('InvoiceID', [], 'ID')
      ]
    FInvoice: Proxy<TInvoice>;
    function GetInvoice: TInvoice;
    procedure SetInvoice(const Value: TInvoice);
  public
    property Id: TGuid read FID write FID;
    property ItemDescription: Nullable<string> read FItemDescription write FItemDescription;
    property Amount: Double read FAmount write FAmount;
    property Invoice: TInvoice read GetInvoice write SetInvoice;
  end;

  [Entity]

  // Only readible by PowerUser and Admin.  Editing (deleting) only by Admin
  [EntityAuthorizeScopes('poweruser,admin', EntitySetPermissionsRead)]
  [EntityAuthorizeScopes('admin', EntitySetPermissionsWrite)]
  [Table('Secret')]
  [Id('FID', TIdGenerator.Guid)]
  TSecret = class
  private
    [Column('ID', [TColumnProp.Required])]
    FID: TGuid;

    [Column('Secret', [TColumnProp.Required], 50)]
    FSecret: string;
  public
    property Id: TGuid read FID write FID;
    property Secret: string read FSecret write FSecret;
  end;

implementation

{ TInvoice }

constructor TInvoice.Create;
begin
  inherited;
  FInvoiceItems.SetInitialValue(TList<TInvoiceItem>.Create);
end;

destructor TInvoice.Destroy;
begin
  FInvoiceItems.DestroyValue;
  inherited;
end;

function TInvoice.GetInvoiceItems: TList<TInvoiceItem>;
begin
  result := FInvoiceItems.Value;
end;

{ TInvoiceItem }

function TInvoiceItem.GetInvoice: TInvoice;
begin
  result := FInvoice.Value;
end;

procedure TInvoiceItem.SetInvoice(const Value: TInvoice);
begin
  FInvoice.Value := Value;
end;

initialization

RegisterEntity(TInvoice);
RegisterEntity(TInvoiceItem);
RegisterEntity(TSecret);

end.
