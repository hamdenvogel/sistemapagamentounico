unit unUtils;

interface

uses
  SysUtils, Math, dialogs;

function DefaultDateFormat(const Value: AnsiString): AnsiString;
function RoundWithDecimals(X: double; Decimals: integer): Double;
Function IsNumber(strNumber: AnsiString): Boolean;
function IsFloat(strNumber: AnsiString): Boolean;
function formatNumber(strNumber: AnsiString): AnsiString;

implementation

const
  VALID_NUMBERS: set of Char = ['0'..'9',','];

function DefaultDateFormat(const Value: AnsiString): AnsiString;
var
  AuxDay, AuxMonth, AuxYear: AnsiString;
  IntDay, IntMonth, IntYear: smallint;
begin
  Result := Value;
  if (Value = '') then Exit;
  if System.Pos('-', Value) = 0 then Exit;

  AuxYear := copy(Value,1,4);
  AuxMonth := copy(Value,6,2);
  AuxDay := copy(Value,9,2);

  IntDay := StrToIntDef(AuxDay, 10);
  IntMonth := StrToIntDef(AuxMonth, 10);
  IntYear := StrToIntDef(AuxYear, 1900);

  Result := SysUtils.FormatFloat('00', IntDay) + '/' + SysUtils.FormatFloat('00', IntMonth) + '/' + IntToStr(IntYear);
end;

function RoundWithDecimals(X: double;
  Decimals: integer): Double;
var
  Mult: Double;
begin
  Mult := Power(10, Decimals);
  Result := Trunc(X*Mult+0.5*Sign(X))/Mult;
end;

Function IsNumber(strNumber : AnsiString) : Boolean;
var
  i : Integer;
begin
  for i:=1 to Length(strNumber) do
  begin
    if not (strNumber[i] in [#48..#57]) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := (strNumber <> '');
end;

function IsFloat(strNumber: AnsiString): Boolean;
var
  i : Integer;
begin
  for i:=1 to Length(strNumber) do
  begin
    if not (strNumber[i] in VALID_NUMBERS) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := (strNumber <> '');
end;

function formatNumber(strNumber: AnsiString): AnsiString;
begin
  strNumber := Trim(strNumber);
  strNumber := StringReplace(strNumber, ' ', '', [rfReplaceAll]);
  if strNumber[length(strNumber)] = ',' then
    strNumber := Trim(StringReplace(Trim(strNumber), ',', '', [rfReplaceAll]));
  Result := strNumber;
end;

end.
