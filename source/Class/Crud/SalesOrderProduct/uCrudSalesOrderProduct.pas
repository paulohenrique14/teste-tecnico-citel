unit uCrudSalesOrderProduct;

interface

uses uCrud, Data.DB, FireDAC.Stan.Intf, System.SysUtils,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  dxGDIPlusClasses, Vcl.ExtCtrls, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uSalesOrderProductDelete.Types, System.Generics.Collections;

type

   TCrudSalesOrderProduct = class(TCrud)
      private
      public
         function UpdateOrInsert(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean; override;
         function Delete(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean; override;
         function DeleteItemById(AItems: TList<TOrderItemDeleted>; ATransaction: TFDTransaction): Boolean; override;

         class function New: ICrud;
   end;

implementation

{ TCrudSalesOrderProduct }

function TCrudSalesOrderProduct.Delete(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean;
begin
   Result := False;

   FSqlSave.Transaction := ATransaction;
   try
      Data.First;
      while not Data.Eof do
      begin

         FSqlSave.SQL.Text := 'Delete from pedidos_produtos ' +
                              'WHERE id = :id ';

         FSqlSave.ParamByName('id').AsInteger  := Data.FieldByName('id').AsInteger;
         FSqlSave.ExecSQL;


         Data.Next;
      end;

      Result := True;

   except on E: Exception do
      begin
         raise Exception.Create('Erro ao salvar produtos do pedido: ' + E.Message);
      end;
   end;
end;

function TCrudSalesOrderProduct.UpdateOrInsert(Data: TFDMemTable; ATransaction: TFDTransaction; ACodeOrder: Integer): Boolean;
begin
   Result := False;


   FSqlSave.Transaction := ATransaction;
   try
      Data.First;
      while not Data.Eof do
      begin
         if StrToIntDef(Data.FieldByName('id').AsString, 0) = 0 then
         begin

            FSqlSave.SQL.Text := 'INSERT INTO pedidos_produtos ' +
                                 '        (num_pedido, cod_produto, quantidade, vr_unitario, vr_total) ' +
                                 'VALUES (:num_pedido,:cod_produto,:quantidade,:vr_unitario,:vr_total) ';

            FSqlSave.ParamByName('num_pedido' ).AsInteger  := ACodeOrder;
            FSqlSave.ParamByName('cod_produto').AsInteger  := Data.FieldByName('cod_produto').AsInteger;
            FSqlSave.ParamByName('quantidade' ).AsFloat    := Data.FieldByName('quantidade' ).AsFloat;
            FSqlSave.ParamByName('vr_unitario').AsCurrency := Data.FieldByName('vr_unitario').AsCurrency;
            FSqlSave.ParamByName('vr_total'   ).AsCurrency := Data.FieldByName('vr_total'   ).AsCurrency;

            FSqlSave.ExecSQL;
         end
         else
         begin
            FSqlSave.SQL.Text := 'UPDATE pedidos_produtos ' +
                                 '   SET quantidade  = :quantidade, ' +
                                 '       vr_unitario = :vr_unitario, ' +
                                 '       cod_produto = :cod_produto, ' +
                                 '       vr_total    = :vr_total ' +
                                 ' WHERE id = :id ';



            FSqlSave.ParamByName('id').AsInteger  := Data.FieldByName('id').AsInteger;

            FSqlSave.ParamByName('cod_produto').AsInteger  := Data.FieldByName('cod_produto').AsInteger;
            FSqlSave.ParamByName('quantidade' ).AsFloat    := Data.FieldByName('quantidade' ).AsFloat;
            FSqlSave.ParamByName('vr_unitario').AsCurrency := Data.FieldByName('vr_unitario').AsCurrency;
            FSqlSave.ParamByName('vr_total'   ).AsCurrency := Data.FieldByName('vr_total'   ).AsCurrency;

            FSqlSave.ExecSQL;
         end;

         Data.Next;
      end;

      Result := True;

   except on E: Exception do
      begin
         raise Exception.Create('Erro ao salvar produtos do pedido: ' + E.Message);
      end;
   end;

end;

function TCrudSalesOrderProduct.DeleteItemById(AItems: TList<TOrderItemDeleted>;
  ATransaction: TFDTransaction): Boolean;
var
   i: Integer;
begin
   Result := False;
   if AItems.Count = 0 then
   begin
      Result := True;
      Exit;
   end;

   try
      FSqlSave.Transaction := ATransaction;

      for i := 0 to AItems.Count - 1 do
      begin
         FSqlSave.Close;
         FSqlSave.SQL.Text := 'DELETE FROM pedidos_produtos ' +
                              'WHERE id = :id              ';

         FSqlSave.ParamByName('id').AsInteger := AItems[i].IdItem;

         FSqlSave.ExecSQL;
      end;

      Result := True;
   except on E: Exception do
      raise Exception.Create('Erro ao deletar itens do pedido: ' + E.Message);
   end;
end;

class function TCrudSalesOrderProduct.New: ICrud;
begin
   Result := Self.Create;
end;

end.
