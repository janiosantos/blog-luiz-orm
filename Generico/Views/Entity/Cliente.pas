unit Cliente;

interface

uses PrsBase, PrsAtributos, Cidade;

type
  [AttTabela('Cliente')]
  TCliente = class(TTabela)
  private
    FID: string;
    FNOME: string;
    FCIDADEID: string;
    procedure SetID(const Value: string);
    procedure SetNOME(const Value: string);
    procedure SetCIDADEID(const Value: string);
  public
    [AttPk]
    [AttNotNull('ID n�o informado.')]
    property ID : string read FID write SetID;
    [AttNotNull('Nome do Cliente n�o informado.')]
    property NOME : string read FNOME write SetNOME;
    [AttNotNull('Cidade n�o informada.')]
    property CIDADEID: string read FCIDADEID write SetCIDADEID;
  end;

implementation

{ TCliente }

procedure TCliente.SetCIDADEID(const Value: string);
begin
  FCIDADEID := Value;
end;

procedure TCliente.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TCliente.SetNOME(const Value: string);
begin
  FNOME := Value;
end;

end.
