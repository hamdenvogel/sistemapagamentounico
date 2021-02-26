unit unDataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient;

type
  TdmModule = class(TDataModule)
    ClPagamento: TClientDataSet;
    ClPagamentoFluxo: TIntegerField;
    ClPagamentoJuros: TFloatField;
    ClPagamentoAmortizacaoSaldoDevedor: TFloatField;
    ClPagamentoPagamento: TFloatField;
    ClPagamentoSaldoDevedor: TFloatField;
    ClPagamentoSomaJuros: TAggregateField;
    ClPagamentoFluxoApresentacao: TStringField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmModule: TdmModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
