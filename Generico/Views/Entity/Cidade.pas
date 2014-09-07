unit Cidade;

interface

uses PrsBase, PrsAtributos;

type
  [AttTabela('Cidade')]
  TCidade = class (TTabela)
  private
    FIBGE: integer;
    FUF: string;
    FID: Integer;
    FNome: string;
    procedure SetIBGE(const Value: integer);
    procedure SetID(const Value: Integer);
    procedure SetNome(const Value: string);
    procedure SetUF(const Value: string);
  public
    [AttPK]
    [AttNotNull('ID n�o informado.')]
    property ID: Integer read FID write SetID;
    [AttNotNull('Nome da cidade n�o informado.')]
    property Nome: string read FNome write SetNome;
    [AttNotNull('UF n�o informado.')]
    property UF: string read FUF write SetUF;
    [AttMinValue(1,'IBGE n�o informado.')]
    property IBGE: integer read FIBGE write SetIBGE;
  end;

implementation

{ TCidade }

procedure TCidade.SetIBGE(const Value: integer);
begin
  FIBGE := Value;
end;

procedure TCidade.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TCidade.SetNome(const Value: string);
begin
  FNome := Value;
end;

procedure TCidade.SetUF(const Value: string);
begin
  FUF := Value;
end;

end.
