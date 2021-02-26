unit CHILDWIN;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.Mask, Vcl.Buttons, MidasLib,
  Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, System.SysUtils,
  generics.defaults, generics.Collections, Contnrs, unPagamento, Dialogs,
  Variants, ComObj, unt_Excel;

type
  TMDIChild = class(TForm)
    pnlCenter: TPanel;
    pnlTop: TPanel;
    pnlGrid: TPanel;
    splTopGrid: TSplitter;
    splGridBottom: TSplitter;
    Label1: TLabel;
    pnlTitle: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    mskCapital: TMaskEdit;
    mskTaxaDeJuros: TMaskEdit;
    spnMeses: TSpinEdit;
    btnCalcular: TBitBtn;
    dsPagamento: TDataSource;
    dbgPagamento: TDBGrid;
    ClPagamento: TClientDataSet;
    ClPagamentoFluxo: TIntegerField;
    ClPagamentoFluxoApresentacao: TStringField;
    ClPagamentoJuros: TFloatField;
    ClPagamentoAmortizacaoSaldoDevedor: TFloatField;
    ClPagamentoPagamento: TFloatField;
    ClPagamentoSaldoDevedor: TFloatField;
    ClPagamentoSomaJuros: TAggregateField;
    btnExportaExcel: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgPagamentoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnExportaExcelClick(Sender: TObject);
    procedure spnMesesKeyPress(Sender: TObject; var Key: Char);
    procedure mskCapitalKeyPress(Sender: TObject; var Key: Char);
    procedure mskTaxaDeJurosKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CalculaPagamento(Lista: TList<TPagamento>; DoProcProd: TObtemJurosProduto);
    procedure CarregaDataSetProExcel(var objXLWorkbook: OLEVariant; const objDataSet: TDataSet; const strFields: TStringList; strAlias: TStringList);
  end;

implementation

{$R *.dfm}

uses unUtils, unCalculoPagamento;

procedure TMDIChild.btnExportaExcelClick(Sender: TObject);
var
  strListaFields, strListaAlias: TStringList;
  XLApp, XLWorkbook: OLEVariant;
begin
  if ClPagamento.IsEmpty then
    raise Exception.Create('A simulação está vazia.');

  strListaFields := TStringList.Create;
  strListaAlias := TStringList.Create;
  try
    if not VarIsEmpty(XLApp) then
    begin
      XLApp.Quit;
      XLApp := Unassigned;
    end;

    try
      XLApp := CreateOleObject('Excel.Application');
      XLWorkbook := CreateOleObject('Excel.Application');
      try
        XLWorkbook.UserControl := True;
        XLWorkbook.DisplayAlerts := False;
        XLWorkbook.Visible := False;
        XLWorkbook := CreateWorkBook(XLApp);
        XLApp.columns.NumberFormat := AnsiChar('@');

        CreateWorksheet(XLWorkbook);
        XLWorkbook.ActiveSheet.Name := 'Sistema Pagamento Único';
        strListaFields.Clear;  strListaAlias.Clear;
        strListaFields.Add('FluxoApresentacao'); strListaAlias.Add('Fluxo');
        strListaFields.Add('Juros'); strListaAlias.Add('Juros');
        strListaFields.Add('AmortizacaoSaldoDevedor'); strListaAlias.Add('Amortização Saldo Devedor');
        strListaFields.Add('Pagamento'); strListaAlias.Add('Pagamento');
        strListaFields.Add('SaldoDevedor'); strListaAlias.Add('Saldo Devedor');

        try
          CarregaDataSetProExcel(XLWorkbook, ClPagamento, strListaFields, strListaAlias);
        except on E:Exception do
          raise Exception.Create(E.Message);
        end;

        XLApp.columns.AutoFit;
        XLApp.Visible := True;
        //XLWorkbook.SaveAs(nomeArq);
        //XLApp.Quit;
      except on E:Exception do
        raise Exception.Create('Excel.Application Error ' +#13#10 + E.Message);
      end;
    finally
      //XLApp := Unassigned;
      //XLWorkbook := Unassigned;
    end;
  finally
    FreeAndNil(strListaFields);
    FreeAndNil(strListaAlias);
  end;
end;

procedure TMDIChild.btnCalcularClick(Sender: TObject);
begin
  TCalculoPagamento.Create(mskCapital.Text, mskTaxaDeJuros.Text,
    spnMeses.Text, ClPagamento).Free;
end;

procedure TMDIChild.CalculaPagamento(Lista: TList<TPagamento>;
  DoProcProd: TObtemJurosProduto);
var
  lProd : TPagamento;
begin
  for lProd in Lista do
    DoProcProd(lProd);
end;

procedure TMDIChild.CarregaDataSetProExcel(var objXLWorkbook: OLEVariant;
  const objDataSet: TDataSet; const strFields: TStringList;
  strAlias: TStringList);
const
  xlThick = 4;
  xlThin = 2;
var
  arrData: Variant;
  i, j: integer;
  Range: OLEVariant;
begin
  if objDataSet.RecordCount = 0 then Exit;
  arrData := VarArrayCreate([0, objDataSet.RecordCount+4, 0, strFields.Count], varOleStr);

  arrData[0,3] := 'Sistema Pagamento Único';

  for j := 0 to strFields.Count - 1 do
    arrData[1, j] := strAlias.Strings[j];

  i := 2;
  objDataSet.DisableControls;
  try
    while not objDataSet.Eof do
    begin
      for j := 0 to strFields.Count - 1 do
        arrData[i, j] := Trim(objDataSet.FieldByName(strFields.Strings[j]).AsString);  //objDBGrid.Fields[j].AsString; //objDataSet.Fields[j].AsString;
      Inc(i);
      Application.ProcessMessages;
      objDataSet.Next;
    end;
  finally
    objDataSet.First;
    objDataSet.EnableControls;
  end;
  {NumberFormat := '0,000'; //Number
   NumberFormat := '@';  ou AnsiChar('@'); //Text
   NumberFormat := 'm/d/yyyy'; ou AnsiString('m/d/yyyy'); //Date
  }

   objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[1, 1],
    objXLWorkbook.ActiveSheet.Cells[2, strFields.Count]].Font.Bold := True;

  objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+3, 1],
    objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+4, strFields.Count]].Font.Bold := True;

  objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[1, 1],
    objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+4, strFields.Count]].Font.Name := 'Arial';

  objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[1, 1],
    objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+4, strFields.Count]].Font.Size := 8;

  objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[1, 1],
    objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+2, strFields.Count]].NumberFormat := '@';

  objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[2, 1],
    objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+2, strFields.Count]].Borders.Weight := xlThin;

  Range := objXLWorkbook.ActiveSheet.Range[objXLWorkbook.ActiveSheet.Cells[1, 1], objXLWorkbook.ActiveSheet.Cells[objDataSet.RecordCount+4, strFields.Count]];

  Range.Value := arrData;
end;

procedure TMDIChild.dbgPagamentoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Shift = [ssCtrl]) and (Key = vk_delete)) then
    Abort;
end;

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIChild.mskCapitalKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then mskTaxaDeJuros.SetFocus;
end;

procedure TMDIChild.mskTaxaDeJurosKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then spnMeses.SetFocus;
end;

procedure TMDIChild.spnMesesKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then btnCalcular.Click;
end;

end.
