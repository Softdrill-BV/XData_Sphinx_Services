unit Entities.SphinxUserEx;

interface

uses Bcl.Types.Nullable, Aurelius.Mapping.Attributes, Sphinx.Consts, Sphinx.Entities;

type

{$RTTI EXPLICIT METHODS([vcProtected..vcPublished])}

  [Entity]
  [Model('Biz.Sphinx')]
  [DiscriminatorValue('sphinx_ex')]
  TSphinxUserEx = class(TUser)
  strict private[Column('access_level', [], 255)]
    FAccess_Level: NullableString;
  public
    property Access_Level: NullableString read FAccess_Level write FAccess_Level;
  end;

implementation

end.
