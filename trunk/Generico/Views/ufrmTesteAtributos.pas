unit ufrmTesteAtributos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmTesteAtributos = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    btnExcluir: TButton;
    btnInserir: TButton;
    btnSalvar: TButton;
    btnBuscar: TButton;
    btnDataSet: TButton;
    Button1: TButton;
    Button2: TButton;
    procedure btnExcluirClick(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnDataSetClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTesteAtributos: TfrmTesteAtributos;

implementation

{$R *.dfm}

uses
  Cidade, udmPrin, db, System.Generics.Collections;

procedure TfrmTesteAtributos.btnInserirClick(Sender: TObject);
var
  ATab: TCidade;
  Registros: Integer;
begin
  Memo1.Clear;
  ATab := TCidade.Create;
  try
    with ATab do
    begin
      id := 1;
      UF := 'MA';
      Nome := 'MARANH�O';
      //testando campo obrigat�rio n�o informado
      IBGE := 0;
    end;

    dmPrin.Transacao.StartTransaction;
    try
      Registros := dmPrin.Dao.Inserir(ATab);

      dmPrin.Transacao.Commit;

      Memo1.Lines.Add(Format('Registro inserido: %d', [Registros]));
      Memo1.Lines.Add(Format('id: %s, nome: %s',[ATab.Id, atab.nome]));
    except
      on E: Exception do
      begin
        if dmPrin.Transacao.InTransaction then
          dmPrin.Transacao.RollBack;
        ShowMessage('Ocorreu um problema ao executar opera��o: ' + e.Message);
      end;
    end;
  finally
    ATab.Free;
  end;
end;

procedure TfrmTesteAtributos.btnSalvarClick(Sender: TObject);
var
  ATab: TCidade;
  Registros: Integer;
begin
  Memo1.Clear;
  ATab := TCidade.Create;
  try
    with ATab do
    begin
      id := 1;
      UF := 'MA';
      Nome := 'BALSAS2';
      IBGE := 0;
    end;
    dmPrin.Transacao.StartTransaction;
    try
      Registros := dmPrin.Dao.Salvar(ATab);

      dmPrin.Transacao.Commit;

      Memo1.Lines.Add(Format('Registro alterado: %d', [Registros]));
      Memo1.Lines.Add(Format('id: %s, nome: %s',[ATab.Id, atab.NOME]));
    except
      on E: Exception do
      begin
        if dmPrin.Transacao.InTransaction then
          dmPrin.Transacao.RollBack;
        ShowMessage('Ocorreu um problema ao executar opera��o: ' + e.Message);
      end;
    end;
  finally
    ATab.Free;
  end;
end;

procedure TfrmTesteAtributos.Button1Click(Sender: TObject);
var
  Objeto: TCidade;
  Lista: TObjectList<TCidade>;
  I: Integer;
begin
  Objeto := TCidade.Create;
  try
    Objeto.ID := 1;
    Objeto.UF := 'MA';
    Lista := dmPrin.dao.ConsultaGen<TCidade>(Objeto, ['uf']);
    try
      for I := 0 to Lista.Count - 1 do
        Memo1.Lines.Add(Lista.Items[i].Nome + ' Data/Cad: ' + DateToStr(lista.Items[i].DataCad));
    finally
      lista.Free;
    end;
  finally
    Objeto.free;
  end;
end;

procedure TfrmTesteAtributos.Button2Click(Sender: TObject);
var
  Tab: TCidade;
begin
  tab := tcidade.create;
  try
    tab.UF := 'MA';
    ShowMessage(IntToStr(dmprin.Dao.GetRecordCount(Tab, ['uf'])));
  finally
    tab.Free;
  end;
end;

procedure TfrmTesteAtributos.btnDataSetClick(Sender: TObject);
var
  ATab: TCidade;
  Registros: TDataset;
begin
  Memo1.Clear;
  ATab := TCidade.Create;
  try
    ATab.Id := 1;
    Registros := dmPrin.Dao.ConsultaSql('Select * from Teste');
    Memo1.Lines.Add('Registros no DataSet: ' + IntToStr(Registros.RecordCount));
  finally
    ATab.Free;
  end;
end;

procedure TfrmTesteAtributos.btnBuscarClick(Sender: TObject);
var
  ATab: TCidade;
  Registros: Integer;
begin
  Memo1.Clear;
  ATab := TCidade.Create;
  try
    ATab.Id := 1;
      Registros := dmPrin.Dao.Buscar(ATab);
      if Registros>0 then
      begin
        Memo1.Lines.Add(Format('Registro localizado: %d', [Registros]));
        Memo1.Lines.Add(Format('UF....: %s' , [ATab.UF]));
        Memo1.Lines.Add(Format('Descri��o.: %s' , [ATab.Nome]));
        Memo1.Lines.Add(Format('IBGE...: %d' , [ATab.IBGE]));
      end
      else
      ShowMessage('Registro n�o encontrado!');
  finally
    ATab.Free;
  end;
end;

procedure TfrmTesteAtributos.btnExcluirClick(Sender: TObject);
var
  ATab: TCidade;
  Registros: Integer;
begin
  Memo1.Clear;
  ATab := TCidade.Create;
  try
    ATab.Id := 1;
    dmPrin.Transacao.StartTransaction;
    try
      Registros := dmPrin.Dao.Excluir(ATab);

      dmPrin.Transacao.Commit;

      Memo1.Lines.Add(Format('Registro excluido: %d', [Registros]));
    except
      on E: Exception do
      begin
        if dmPrin.Transacao.InTransaction then
          dmPrin.Transacao.RollBack;
        ShowMessage('Ocorreu um problema ao executar opera��o: ' + e.Message);
      end;
    end;
  finally
    ATab.Free;
  end;
end;

end.
