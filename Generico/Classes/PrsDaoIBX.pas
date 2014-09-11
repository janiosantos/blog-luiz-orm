unit PrsDaoIBX;

interface

uses Db, PrsBase, Rtti, PrsAtributos, system.SysUtils, system.Classes,
  ibx.IB, ibx.IBQuery, ibx.IBDatabase, system.Generics.Collections;

type
  TTransacaoIbx = class(TTransacaoBase)
  private
    // transa��o para crud
    FTransaction: TIbTransaction;

  public
    constructor Create(ABanco: TIBDatabase);
    destructor Destroy; override;

    function InTransaction: Boolean; override;
    procedure Snapshot;
    procedure Read_Commited;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure RollBack; override;

    property Transaction: TIbTransaction read FTransaction write FTransaction;
  end;

  TConexaoIbx = class(TConexaoBase)
  private
    // conexao com o banco de dados
    FDatabase: TIBDatabase;
    // transa��o para consultas
    FTransQuery: TIbTransaction;
  public
    constructor Create();
    destructor Destroy; override;

    function Conectado: Boolean; override;

    procedure Conecta; override;

    property Database: TIBDatabase read FDatabase write FDatabase;
    property TransQuery: TIbTransaction read FTransQuery write FTransQuery;
  end;

  TDaoIbx = class(TDaoBase)
  private
    FConexao: TConexaoIbx;
    // query para execu��o dos comandos crud
    Qry: TIBQuery;

    Function DbToTabela<T: TTabela>(ATabela: TTabela; ADataSet: TDataSet)
      : TObjectList<T>;
  protected
    // m�todos respons�veis por setar os par�metros
    procedure QryParamInteger(ARecParams: TRecParams); override;
    procedure QryParamString(ARecParams: TRecParams); override;
    procedure QryParamDate(ARecParams: TRecParams); override;
    procedure QryParamCurrency(ARecParams: TRecParams); override;
    procedure QryParamVariant(ARecParams: TRecParams); override;

    // m�todos para setar os variados tipos de campos
    procedure SetaCamposInteger(ARecParams: TRecParams); override;
    procedure SetaCamposString(ARecParams: TRecParams); override;
    procedure SetaCamposDate(ARecParams: TRecParams); override;
    procedure SetaCamposCurrency(ARecParams: TRecParams); override;

    function ExecutaQuery: Integer; override;
  public
    constructor Create(AConexao: TConexaoIbx; ATransacao: TTransacaoIbx);
    destructor Destroy; override;

    // dataset para as consultas
    function ConsultaSql(ASql: string): TDataSet; override;
    function ConsultaTab(ATabela: TTabela; ACampos: array of string)
      : TDataSet; override;
    function ConsultaGen<T: TTabela>(ATabela: TTabela; ACampos: array of string)
      : TObjectList<T>;

    // pega campo autoincremento
    function GetID(ATabela: TTabela; ACampo: string): Integer; override;
    function GetMax(ATabela: TTabela; ACampo: string;
      ACamposChave: array of string): Integer;

    // recordcount
    function GetRecordCount(ATabela: TTabela; ACampos: array of string)
      : Integer; override;

    // crud
    function Inserir(ATabela: TTabela): Integer; override;
    function Salvar(ATabela: TTabela): Integer; override;
    function Excluir(ATabela: TTabela): Integer; override;
    function Buscar(ATabela: TTabela): Integer; override;
  end;

implementation

uses Vcl.forms, dialogs, system.TypInfo;

{ TTransIbx }

constructor TTransacaoIbx.Create(ABanco: TIBDatabase);
begin
  inherited Create;

  FTransaction := TIbTransaction.Create(Application);
  with FTransaction do
  begin
    DefaultDatabase := ABanco;
    Read_Commited;
  end;
end;

destructor TTransacaoIbx.Destroy;
begin
  inherited;
end;

function TTransacaoIbx.InTransaction: Boolean;
begin
  Result := FTransaction.InTransaction;
end;

procedure TTransacaoIbx.Snapshot;
begin
  with FTransaction do
  begin
    Params.Clear;
    Params.Add('concurrency');
    Params.Add('nowait');
  end;
end;

procedure TTransacaoIbx.StartTransaction;
begin
  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;
end;

procedure TTransacaoIbx.Read_Commited;
begin
  with FTransaction do
  begin
    Params.Clear;
    Params.Add('read_committed');
    Params.Add('rec_version');
    Params.Add('nowait');
  end;
end;

procedure TTransacaoIbx.RollBack;
begin
  FTransaction.RollBack;
end;

procedure TTransacaoIbx.Commit;
begin
  FTransaction.Commit;
end;

constructor TConexaoIbx.Create();
begin
  inherited Create;
  FDatabase := TIBDatabase.Create(Application);
  FDatabase.ServerType := 'IBServer';
  FDatabase.LoginPrompt := false;
end;

destructor TConexaoIbx.Destroy;
begin
  inherited;
end;

function TConexaoIbx.Conectado: Boolean;
begin
  Result := Database.Connected;
end;

procedure TConexaoIbx.Conecta;
begin
  inherited;
  with Database do
  begin
    DatabaseName := LocalBD;
    Params.Clear;
    Params.Add('user_name=' + Usuario);
    Params.Add('password=' + Senha);
    Connected := True;
  end;
end;

{ TDaoIbx }

constructor TDaoIbx.Create(AConexao: TConexaoIbx; ATransacao: TTransacaoIbx);
var
  MeuDataSet: TIBQuery;
begin
  inherited Create;

  FConexao := AConexao;

  with FConexao do
  begin
    // configura��es iniciais da transacao para consultas
    FTransQuery := TIbTransaction.Create(Application);
    with TransQuery do
    begin
      DefaultDatabase := Database;
      Params.Add('read_committed');
      Params.Add('rec_version');
      Params.Add('nowait');
    end;

    Database.DefaultTransaction := TransQuery;
  end;

  Qry := TIBQuery.Create(Application);
  Qry.Database := FConexao.Database;
  Qry.Transaction := ATransacao.Transaction;

  MeuDataSet := TIBQuery.Create(Application);
  MeuDataSet.Database := FConexao.Database;

  DataSet := MeuDataSet;
end;

destructor TDaoIbx.Destroy;
begin
  inherited;
end;

procedure TDaoIbx.QryParamCurrency(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    TIBQuery(Qry).ParamByName(Campo).AsCurrency := Prop.GetValue(Tabela)
      .AsCurrency;
  end;
end;

procedure TDaoIbx.QryParamDate(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    if Prop.GetValue(Tabela).AsType<TDateTime> = 0 then
      TIBQuery(Qry).ParamByName(Campo).Clear
    else
      TIBQuery(Qry).ParamByName(Campo).AsDateTime := Prop.GetValue(Tabela).AsType<TDateTime>;
  end;
end;

procedure TDaoIbx.QryParamInteger(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    TIBQuery(Qry).ParamByName(Campo).AsInteger := Prop.GetValue(Tabela)
      .AsInteger;
  end;
end;

procedure TDaoIbx.QryParamString(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    TIBQuery(Qry).ParamByName(Campo).AsString := Prop.GetValue(Tabela).AsString;
  end;
end;

procedure TDaoIbx.QryParamVariant(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    TIBQuery(Qry).ParamByName(Campo).Value := Prop.GetValue(Tabela).AsVariant;
  end;
end;

procedure TDaoIbx.SetaCamposCurrency(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    Prop.SetValue(Tabela, TIBQuery(Qry).FieldByName(Campo).AsCurrency);
  end;
end;

procedure TDaoIbx.SetaCamposDate(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    Prop.SetValue(Tabela, TIBQuery(Qry).FieldByName(Campo).AsDateTime);
  end;
end;

procedure TDaoIbx.SetaCamposInteger(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    Prop.SetValue(Tabela, TIBQuery(Qry).FieldByName(Campo).AsInteger);
  end;
end;

procedure TDaoIbx.SetaCamposString(ARecParams: TRecParams);
begin
  inherited;
  with ARecParams do
  begin
    Prop.SetValue(Tabela, TIBQuery(Qry).FieldByName(Campo).AsString);
  end;
end;

function TDaoIbx.DbToTabela<T>(ATabela: TTabela; ADataSet: TDataSet)
  : TObjectList<T>;
var
  AuxValue: TValue;
  TipoRtti: TRttiType;
  Contexto: TRttiContext;
  PropRtti: TRttiProperty;
  DataType: TFieldType;
  Campo: String;
begin
  Result := TObjectList<T>.Create;

  while not ADataSet.Eof do
  begin
    AuxValue := GetTypeData(PTypeInfo(TypeInfo(T)))^.ClassType.Create;
    TipoRtti := Contexto.GetType(AuxValue.AsObject.ClassInfo);
    for PropRtti in TipoRtti.GetProperties do
    begin
      Campo := PropRtti.Name;
      DataType := ADataSet.FieldByName(Campo).DataType;

      case DataType of
        ftInteger:
          begin
            PropRtti.SetValue(AuxValue.AsObject,
              TValue.FromVariant(ADataSet.FieldByName(Campo).AsInteger));
          end;
        ftString, ftWideString:
          begin
            PropRtti.SetValue(AuxValue.AsObject,
              TValue.FromVariant(ADataSet.FieldByName(Campo).AsString));
          end;
        ftBCD, ftFloat:
          begin
            PropRtti.SetValue(AuxValue.AsObject,
              TValue.FromVariant(ADataSet.FieldByName(Campo).AsFloat));
          end;
        ftDateTime:
          begin
            PropRtti.SetValue(AuxValue.AsObject,
              TValue.FromVariant(ADataSet.FieldByName(Campo).AsDateTime));
          end;
      else
        raise Exception.Create('Tipo de campo n�o conhecido: ' +
          PropRtti.PropertyType.ToString);
      end;
    end;
    Result.Add(AuxValue.AsType<T>);

    ADataSet.Next;
  end;
end;

function TDaoIbx.ConsultaGen<T>(ATabela: TTabela; ACampos: array of string)
  : TObjectList<T>;
var
  Dados: TIBQuery;
  Contexto: TRttiContext;
  Campo: string;
  TipoRtti: TRttiType;
  PropRtti: TRttiProperty;
begin
  Dados := TIBQuery.Create(Application);
  try
    Contexto := TRttiContext.Create;
    try
      TipoRtti := Contexto.GetType(ATabela.ClassType);
      with Dados do
      begin
        Database := FConexao.Database;
        sql.Text := GerarSqlSelect(ATabela, ACampos);

        for Campo in ACampos do
        begin
          if not PropExiste(Campo, PropRtti, TipoRtti) then
            raise Exception.Create('Campo ' + Campo + ' n�o existe no objeto!');

          // setando os par�metros
          for PropRtti in TipoRtti.GetProperties do
          begin
            if CompareText(PropRtti.Name, Campo) = 0 then
            begin
              ConfiguraParametro(PropRtti, Campo, ATabela, Dados);
            end;
          end;
        end;

        Open;

        Result := DbToTabela<T>(ATabela, Dados);
      end;
    finally
      Contexto.Free;
    end;
  finally
    Dados.Free;
  end;
end;

function TDaoIbx.ConsultaSql(ASql: string): TDataSet;
var
  AQry: TIBQuery;
begin
  AQry := TIBQuery.Create(Application);
  with AQry do
  begin
    Database := FConexao.Database;
    sql.Clear;
    sql.Add(ASql);
    Open;
  end;
  Result := AQry;
end;

function TDaoIbx.ConsultaTab(ATabela: TTabela; ACampos: array of string)
  : TDataSet;
var
  Dados: TIBQuery;
  Contexto: TRttiContext;
  Campo: string;
  TipoRtti: TRttiType;
  PropRtti: TRttiProperty;
begin
  Dados := TIBQuery.Create(Application);
  Contexto := TRttiContext.Create;
  try
    TipoRtti := Contexto.GetType(ATabela.ClassType);

    with Dados do
    begin
      Database := FConexao.Database;
      sql.Text := GerarSqlSelect(ATabela, ACampos);

      for Campo in ACampos do
      begin
        // setando os par�metros
        for PropRtti in TipoRtti.GetProperties do
          if CompareText(PropRtti.Name, Campo) = 0 then
          begin
            ConfiguraParametro(PropRtti, Campo, ATabela, Dados);
          end;
      end;
      Open;
      Result := Dados;
    end;
  finally
    Contexto.Free;
  end;
end;

function TDaoIbx.GetID(ATabela: TTabela; ACampo: string): Integer;
var
  AQry: TIBQuery;
begin
  AQry := TIBQuery.Create(Application);
  with AQry do
  begin
    Database := FConexao.Database;
    sql.Clear;
    sql.Add('select max(' + ACampo + ') from ' + PegaNomeTab(ATabela));
    Open;
    Result := fields[0].AsInteger + 1;
  end;
end;

function TDaoIbx.GetMax(ATabela: TTabela; ACampo: string;
  ACamposChave: array of string): Integer;
var
  AQry: TIBQuery;
  Campo: string;
  Contexto: TRttiContext;
  TipoRtti: TRttiType;
  PropRtti: TRttiProperty;
  Separador: string;
begin
  AQry := TIBQuery.Create(Application);
  with AQry do
  begin
    Database := FConexao.Database;
    sql.Clear;
    sql.Add('select max(' + ACampo + ') from ' + PegaNomeTab(ATabela));
    sql.Add('Where');
    Separador := '';
    for Campo in ACamposChave do
    begin
      sql.Add(Separador + Campo + '= :' + Campo);
      Separador := ' and ';
    end;

    Contexto := TRttiContext.Create;
    try
      TipoRtti := Contexto.GetType(ATabela.ClassType);

      for Campo in ACamposChave do
      begin
        // setando os par�metros
        for PropRtti in TipoRtti.GetProperties do
          if CompareText(PropRtti.Name, Campo) = 0 then
          begin
            ConfiguraParametro(PropRtti, Campo, ATabela, AQry);
          end;
      end;

      Open;

      Result := fields[0].AsInteger;
    finally
      Contexto.Free;
    end;
  end;
end;

function TDaoIbx.GetRecordCount(ATabela: TTabela;
  ACampos: array of string): Integer;
var
  AQry: TIBQuery;
  Contexto: TRttiContext;
  Campo: string;
  TipoRtti: TRttiType;
  PropRtti: TRttiProperty;
begin
  AQry := TIBQuery.Create(Application);

  with AQry do
  begin
    Contexto := TRttiContext.Create;
    try
      TipoRtti := Contexto.GetType(ATabela.ClassType);
      Database := FConexao.Database;

      sql.Clear;

      sql.Add('select count(*) from ' + PegaNomeTab(ATabela));

      if High(ACampos) >= 0 then
        sql.Add('where 1=1');

      for Campo in ACampos do
        sql.Add('and ' + Campo + '=:' + Campo);

      for Campo in ACampos do
      begin
        for PropRtti in TipoRtti.GetProperties do
          if CompareText(PropRtti.Name, Campo) = 0 then
          begin
            ConfiguraParametro(PropRtti, Campo, ATabela, AQry);
          end;
      end;

      Open;

      Result := fields[0].AsInteger;
    finally
      Contexto.Free;
    end;
  end;
end;

function TDaoIbx.ExecutaQuery: Integer;
begin
  with Qry do
  begin
    Prepare();
    ExecSQL;
    Result := RowsAffected;
  end;
end;

function TDaoIbx.Excluir(ATabela: TTabela): Integer;
var
  Comando: TFuncReflexao;
begin
  // crio uma vari�vel do tipo TFuncReflexao - um m�todo an�nimo
  Comando := function(ACampos: TCamposAnoni): Integer
    var
      Campo: string;
      PropRtti: TRttiProperty;
    begin
      Qry.close;
      Qry.sql.Clear;
      Qry.sql.Text := GerarSqlDelete(ATabela);
      // percorrer todos os campos da chave prim�ria
      for Campo in PegaPks(ATabela) do
      begin
        // setando os par�metros
        for PropRtti in ACampos.TipoRtti.GetProperties do
          if CompareText(PropRtti.Name, Campo) = 0 then
          begin
            ConfiguraParametro(PropRtti, Campo, ATabela, Qry);
          end;
      end;
      Result := ExecutaQuery;
    end;

  // reflection da tabela e execu��o da query preparada acima.
  Result := ReflexaoSQL(ATabela, Comando);
end;

function TDaoIbx.Inserir(ATabela: TTabela): Integer;
var
  Comando: TFuncReflexao;
begin
  try
    ValidaTabela(ATabela);

    Comando := function(ACampos: TCamposAnoni): Integer
      var
        Campo: string;
        PropRtti: TRttiProperty;
      begin
        with Qry do
        begin
          close;
          sql.Clear;
          sql.Text := GerarSqlInsert(ATabela, ACampos.TipoRtti);
          // valor dos par�metros
          for PropRtti in ACampos.TipoRtti.GetProperties do
          begin
            Campo := PropRtti.Name;
            ConfiguraParametro(PropRtti, Campo, ATabela, Qry);
          end;
        end;
        Result := ExecutaQuery;
      end;

    // reflection da tabela e execu��o da query preparada acima.
    Result := ReflexaoSQL(ATabela, Comando);
  except
    raise;
  end;
end;

function TDaoIbx.Salvar(ATabela: TTabela): Integer;
var
  Comando: TFuncReflexao;
begin
  try
    ValidaTabela(ATabela);

    Comando := function(ACampos: TCamposAnoni): Integer
      var
        Campo: string;
        PropRtti: TRttiProperty;
      begin
        with Qry do
        begin
          close;
          sql.Clear;
          sql.Text := GerarSqlUpdate(ATabela, ACampos.TipoRtti);
          // valor dos par�metros
          for PropRtti in ACampos.TipoRtti.GetProperties do
          begin
            Campo := PropRtti.Name;
            ConfiguraParametro(PropRtti, Campo, ATabela, Qry);
          end;
        end;
        Result := ExecutaQuery;
      end;

    // reflection da tabela e execu��o da query preparada acima.
    Result := ReflexaoSQL(ATabela, Comando);
  except
    raise;
  end;
end;

function TDaoIbx.Buscar(ATabela: TTabela): Integer;
var
  Comando: TFuncReflexao;
  Dados: TIBQuery;
begin
  Dados := TIBQuery.Create(nil);
  try
    // crio uma vari�vel do tipo TFuncReflexao - um m�todo an�nimo
    Comando := function(ACampos: TCamposAnoni): Integer
      var
        Campo: string;
        PropRtti: TRttiProperty;
      begin
        with Dados do
        begin
          Database := FConexao.Database;
          sql.Text := GerarSqlSelect(ATabela);

          for Campo in ACampos.PKs do
          begin
            // setando os par�metros
            for PropRtti in ACampos.TipoRtti.GetProperties do
              if CompareText(PropRtti.Name, Campo) = 0 then
              begin
                ConfiguraParametro(PropRtti, Campo, ATabela, Dados);
              end;
          end;
          Open;
          Result := RecordCount;
          if Result > 0 then
          begin
            for PropRtti in ACampos.TipoRtti.GetProperties do
            begin
              Campo := PropRtti.Name;
              SetaDadosTabela(PropRtti, Campo, ATabela, Dados);
            end;
          end;
        end;
      end;

    // reflection da tabela e abertura da query preparada acima.
    Result := ReflexaoSQL(ATabela, Comando);
  finally
    Dados.Free;
  end;
end;

end.
