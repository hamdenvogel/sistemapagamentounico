unit unCalculoPagamento;

interface

uses Winapi.Windows, System.Classes, MidasLib,
  Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, System.SysUtils,
  generics.defaults, generics.Collections, Contnrs, unPagamento;

type
  TCalculoPagamento = class
    private
      fCapital: Double;
      fTaxaDeJuros: Double;
      fMeses: Integer;
      procedure SetCapital(const Value: Double);
      procedure SetTaxaDeJuros(const Value: Double);
      procedure SetMeses(const Value: Integer);
      private fClPagamento: TClientDataSet;
      procedure SetClPagamento(const Value: TClientDataSet);
      property clPagamento: TClientDataSet read fClPagamento write SetClPagamento;
    public
      property Capital: Double read fCapital write SetCapital;
      property TaxaDeJuros: Double read fTaxaDeJuros write SetTaxaDeJuros;
      property Meses: Integer read fMeses write SetMeses;
      procedure CalculaPagamento(Lista: TList<TPagamento>; DoProcProd: TObtemJurosProduto);
      constructor Create(ACapital: AnsiString; ATaxaDeJuros: AnsiString; AMeses: AnsiString; clPagamento: TClientDataSet);
      destructor Destroy;
  end;

implementation

{ TCalculoPagamento }

uses unUtils;

procedure TCalculoPagamento.CalculaPagamento(Lista: TList<TPagamento>;
  DoProcProd: TObtemJurosProduto);
var
  lProd : TPagamento;
begin
  for lProd in Lista do
    DoProcProd(lProd);
end;

constructor TCalculoPagamento.Create(ACapital, ATaxaDeJuros,
  AMeses: AnsiString; clPagamento: TClientDataSet);
var
  Lista: TList<TPagamento>;
  pagamento: TPagamento;
  i: Integer;
  fluxoAnterior: Integer;
  strCapital, strTaxaJuros, strMeses: string;
  totalFluxos: Integer;
  totalJuros: Double;
  totalPagamento: Double;
begin
  inherited Create;
  strCapital := unUtils.formatNumber(ACapital);
  strTaxaJuros := unUtils.formatNumber(ATaxaDeJuros);
  strMeses := AMeses;

  if not (unUtils.IsFloat(strCapital)) then
    raise EPagamentoException.Create('Valor de Capital inválido.');
  if not (unUtils.IsFloat(strTaxaJuros)) then
    raise EPagamentoException.Create('Valor de Taxa de Juros inválida.');
  if not (unUtils.IsNumber(strMeses)) then
    raise EPagamentoException.Create('Valor de Meses inválido.');
  if (StrToFloatDef(strMeses, 0) = 0) then
    raise EPagamentoException.Create('A quantidade de meses não pode ser zero.');

  Capital := StrToFloat(strCapital);
  TaxaDeJuros := StrToFloat(strTaxaJuros);
  Meses := StrToInt(strMeses);
  totalFluxos := Meses + 1;
  totalJuros := 0;
  totalPagamento := 0;

  Lista := TList<TPagamento>.Create;
  try
    for i := 0 to totalFluxos do
      Lista.Add(TPagamento.Create(i,0,0,0,0));

    i := 0;
    CalculaPagamento(Lista, function (APag: TPagamento): Double
    begin
      if i = 0 then
        APag.SaldoDevedor := Capital
      else if i = 1 then
      begin
        APag.Juros := Capital * (TaxaDeJuros/100);
        APag.SaldoDevedor := Lista[i-1].SaldoDevedor + APag.Juros;
      end
      else if (i > 1) and (i < totalFluxos) then
      begin
        APag.Juros := Lista[i-1].Juros + Lista[i-1].Juros * (TaxaDeJuros/100);
        if i < totalFluxos - 1 then
          APag.SaldoDevedor := Lista[i-1].SaldoDevedor + APag.Juros
        else
         APag.SaldoDevedor := 0
      end;

      Inc(i);
    end);

    i := 0;
    with ClPagamento do
    begin
      DisableControls;
      try
        EmptyDataSet;
        for pagamento in Lista do
        begin
          Append;
          FieldByName('Fluxo').AsInteger := pagamento.Fluxo;
          FieldByName('FluxoApresentacao').AsString :=
            ClPagamento.FieldByName('Fluxo').AsString;
          if i > 0 then
            FieldByName('Juros').AsFloat := pagamento.Juros;
          if i < totalFluxos then
            FieldByName('SaldoDevedor').AsFloat := pagamento.SaldoDevedor;
          if i = totalFluxos - 1 then
              FieldByName('AmortizacaoSaldoDevedor').AsFloat := Lista[i-1].SaldoDevedor;

          Inc(i);
        end;

        Edit;
        FieldByName('FluxoApresentacao').AsString := 'Totais:';
        totalJuros := StrToFloatDef(FieldByName('SomaJuros').AsString, 0);
        FieldByName('Juros').AsFloat := totalJuros;
        totalPagamento := Capital + totalJuros;
        FieldByName('Pagamento').AsFloat := totalPagamento;
        if (State in [dsInsert, dsEdit]) then Post;
      finally
        First;
        EnableControls;
      end;
    end;
  finally
    FreeAndNil(Lista);
  end;
end;

destructor TCalculoPagamento.Destroy;
begin
  inherited Destroy;
end;

procedure TCalculoPagamento.SetCapital(const Value: Double);
begin
  fCapital := Value;
end;

procedure TCalculoPagamento.SetClPagamento(const Value: TClientDataSet);
begin
  fClPagamento := Value;
end;

procedure TCalculoPagamento.SetMeses(const Value: Integer);
begin
  fMeses := Value;
end;

procedure TCalculoPagamento.SetTaxaDeJuros(const Value: Double);
begin
  fTaxaDeJuros := Value;
end;

end.
