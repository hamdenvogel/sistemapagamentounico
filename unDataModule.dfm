object dmModule: TdmModule
  OldCreateOrder = False
  Height = 150
  Width = 215
  object ClPagamento: TClientDataSet
    Aggregates = <>
    AggregatesActive = True
    FieldDefs = <>
    IndexDefs = <
      item
        Name = 'indxFluxo'
        Fields = 'Fluxo'
      end>
    IndexName = 'indxFluxo'
    Params = <>
    StoreDefs = True
    Left = 96
    Top = 56
    object ClPagamentoFluxo: TIntegerField
      FieldName = 'Fluxo'
    end
    object ClPagamentoFluxoApresentacao: TStringField
      FieldName = 'FluxoApresentacao'
      Size = 2000
    end
    object ClPagamentoJuros: TFloatField
      FieldName = 'Juros'
    end
    object ClPagamentoAmortizacaoSaldoDevedor: TFloatField
      FieldName = 'AmortizacaoSaldoDevedor'
    end
    object ClPagamentoPagamento: TFloatField
      FieldName = 'Pagamento'
    end
    object ClPagamentoSaldoDevedor: TFloatField
      FieldName = 'SaldoDevedor'
    end
    object ClPagamentoSomaJuros: TAggregateField
      FieldName = 'SomaJuros'
      Visible = True
      Active = True
      DisplayName = ''
      Expression = 'SUM(Juros)'
      IndexName = 'indxFluxo'
    end
  end
end
