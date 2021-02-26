unit unPagamento;

interface

uses
  SysUtils;

type
  EPagamentoException = Exception;

type
  TPagamento = class
  private
    fFluxo: Integer;
    fJuros: Double;
    fAmortizacaoSaldoDevedor: Double;
    fPagamento: Double;
    fSaldoDevedor: Double;
    procedure SetFluxo(const Value: Integer);
    procedure SetJuros(const Value: Double);
    procedure SetAmortizacaoSaldoDevedor(const Value: Double);
    procedure SetPagamento(const Value: Double);
    procedure SetSaldoDevedor(const Value: Double);
  public
    property Fluxo: Integer read fFluxo write SetFluxo;
    property Juros: Double read fJuros write SetJuros;
    property AmortizacaoSaldoDevedor: Double read fAmortizacaoSaldoDevedor write SetAmortizacaoSaldoDevedor;
    property Pagamento: Double read fPagamento write SetPagamento;
    property SaldoDevedor: Double read fSaldoDevedor write SetSaldoDevedor;
    Constructor Create(AFluxo: Integer; AJuros: Double;
      AAmortizacaoSaldoDevedor: Double; APagamento: Double; ASaldoDevedor: Double);
    Destructor Destroy;
 end;

TObtemJurosProduto = reference to function (AProd: TPagamento): Double;

implementation

{ TPagamento }

uses unUtils;

constructor TPagamento.Create(AFluxo: Integer; AJuros, AAmortizacaoSaldoDevedor,
  APagamento, ASaldoDevedor: Double);
begin
  inherited Create;
  Fluxo := AFluxo;
  Juros := AJuros;
  AmortizacaoSaldoDevedor := AAmortizacaoSaldoDevedor;
  Pagamento := APagamento;
  SaldoDevedor := ASaldoDevedor;
end;

destructor TPagamento.Destroy;
begin
  inherited Destroy;
end;

procedure TPagamento.SetAmortizacaoSaldoDevedor(const Value: Double);
begin
  fAmortizacaoSaldoDevedor := Value;
end;

procedure TPagamento.SetPagamento(const Value: Double);
begin
  fPagamento := Value;
end;

procedure TPagamento.SetSaldoDevedor(const Value: Double);
begin
  fSaldoDevedor := Value;
end;

procedure TPagamento.SetFluxo(const Value: Integer);
begin
  fFluxo := Value;
end;

procedure TPagamento.SetJuros(const Value: Double);
begin
  fJuros := Value;
end;

end.
