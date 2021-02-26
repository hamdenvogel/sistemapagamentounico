unit unt_ExcelCommonClass;

interface
uses classes, Sysutils;

const
  MAXIMO_CAPTURAS = 20;
  xlWBATWorksheet = -4167;

type
  TSheet = record
    Name: string;
    Data: Variant;
  end;

type
  TSheets = array[1..MAXIMO_CAPTURAS] of TSheet;

implementation

end.
