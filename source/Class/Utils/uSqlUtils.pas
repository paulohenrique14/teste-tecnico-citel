unit uSqlUtils;

interface

uses
   FireDAC.Comp.Client,System.SysUtils, uDm;

type
   TSqlUtils = class
   public
      class function Locate(const ATable: string; AFDQuery: TFDQuery; const AValue: Variant; const ASearchField: string; const AFields : array of string):Boolean;
  end;

implementation

class function TSqlUtils.Locate(const ATable: string; AFDQuery: TFDQuery; const AValue: Variant; const ASearchField: string; const AFields : array of string):Boolean;
var
   mFields: string;
   i: Integer;
begin
   Result := False;

   AFDQuery.Connection := FrmDm.FDMainConnection;

   mFields := '';
   for i := 0 to High(AFields) do
   begin
      if i > 0 then
         mFields := mFields + ', ';

      mFields := mFields + AFields[i];
   end;

   if mFields = '' then
      mFields := ASearchField
   else
      mFields := ASearchField + ', ' + mFields;

   AFDQuery.Close;
   AFDQuery.SQL.Text := 'SELECT ' + mFields +
                        ' FROM ' + ATable +
                        ' WHERE ' + ASearchField + ' = :valor';

   AFDQuery.ParamByName('valor').Value := AValue;
   AFDQuery.Open;

   Result := not AFDQuery.IsEmpty;
end;

end.
