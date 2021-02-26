unit unt_Excel;

interface

uses
  SysUtils, Classes, ComObj, contnrs, unt_ExcelCommonClass, Variants;

function CreateExcelApp: variant;
function CreateWorkBook(ExcelApp: Variant): variant;
function CreateWorksheet(WorkBook: Variant): Variant;
function RefToCell(RowID, ColID: Integer): string;
procedure SaveAsExcelFile(aSheets: TSheets; AFileName: string);
function LoadExcelFile(var aSheets: TSheets; AFileName: string): Variant;

implementation

function CreateExcelApp: variant;
begin
  try
    Result := CreateOleObject('Excel.Application');
    Result.UserControl := True;
    Result.DisplayAlerts := False;
    Result.Visible := False;
  except
    //showMessage('Não foi possível abrir o Excel');
    Result := varNull;
  end;
end;

function CreateWorkBook(ExcelApp: Variant): variant;
begin
  try
    Result := ExcelApp.Workbooks.Add(xlWBATWorksheet);
  except
    //showMessage('Não foi possível criar uma nova planilha');
    Result := varNull;
  end;
end;

function OpenWorkBook(ExcelApp: Variant): variant;
begin
  try
    Result := ExcelApp.Workbooks.Open(ExcelApp);
  except
    //showMessage('Não foi possível criar uma nova planilha');
    Result := varNull;
  end;
end;

function CreateWorksheet(WorkBook: Variant): Variant;
begin
  try
    Result := WorkBook.WorkSheets.Add;
  except
    //showMessage('Não foi possível criar uma nova planilha');
    Result := varNull;
  end;
end;

function RefToCell(RowID, ColID: Integer): string;
var
  ACount, APos: Integer;
begin
  ACount := ColID div 26;
  APos := ColID mod 26;
  if APos = 0 then
  begin
    ACount := ACount - 1;
    APos := 26;
  end;

  if ACount = 0 then
    Result := Chr(Ord('A') + ColID - 1) + IntToStr(RowID);

  if ACount = 1 then
    Result := 'A' + Chr(Ord('A') + APos - 1) + IntToStr(RowID);

  if ACount > 1 then
    Result := Chr(Ord('A') + ACount - 1) + Chr(Ord('A') + APos - 1) + IntToStr(RowID);
end;

procedure SaveAsExcelFile(aSheets: TSheets; AFileName: string);
var
  XLApp, XLWorkbook: OLEVariant;
  Sheet: Variant;
  Data: TSheet;
  i: integer;
begin
  XLApp := CreateExcelApp;
  XLApp.Visible := False;
  XLWorkbook := CreateWorkBook(XLApp);

  try
    for i := MAXIMO_CAPTURAS downto 1 do
    begin
      Data := aSheets[i];
      if (Trim(Data.Name) <> '') then
      begin
        CreateWorksheet(XLWorkbook);
        Sheet := XLWorkbook.ActiveSheet;
        Sheet.Name := Data.Name;
        Sheet.Range[RefToCell(1, 1), RefToCell(VarArrayHighBound(Data.Data, 1), VarArrayHighBound(Data.Data, 2))].Value := Data.Data;
        Sheet.Range[RefToCell(1, 1), RefToCell(VarArrayHighBound(Data.Data, 1), VarArrayHighBound(Data.Data, 2))].Columns.AutoFit;
      end;
    end;

    if XLApp.WorkBooks[1].Sheets.Count > 1 then
    begin
      XLApp.WorkBooks[1].Sheets['Plan1'].Select;
      XLApp.ActiveWindow.SelectedSheets.Delete;
      XLApp.WorkBooks[1].Sheets[1].Select;
    end;

  finally
    XLWorkbook.SaveAs(AFileName);
    if not VarIsEmpty(XLApp) then
    begin
      XLApp.DisplayAlerts := False;
      XLApp.Quit;
      XLAPP := Unassigned;
      Sheet := Unassigned;
    end;
  end;
end;

function LoadExcelFile(var aSheets: TSheets; AFileName: string): Variant;
var
  XLApp, XLWorkbook: OLEVariant;
  i: integer;
begin
  XLApp := CreateExcelApp;
  XLApp.Visible := False;
  XLApp.Workbooks.Open(AFileName);
  for i := 1 to XLApp.Workbooks.Count do
  begin

  end;
end;

end.

