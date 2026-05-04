unit uCad;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.WinXPanels, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, dxGDIPlusClasses;

type
  TFrmCad = class(TForm)
    PnlMain: TPanel;
    PnlButtons: TPanel;
    PnlTop: TPanel;
    CardPanel: TCardPanel;
    CardCreate: TCard;
    CardBrowse: TCard;
    FDCad: TFDQuery;
    DSCad: TDataSource;
    BtnDelete: TButton;
    BtnCreate: TButton;
    BtnEdit: TButton;
    DBGrid: TDBGrid;
    LblScreenName: TLabel;
    BtnClose: TImage;
    BtnSave: TButton;
    BtnCancel: TButton;
    procedure DSCadStateChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnCreateClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCad: TFrmCad;

implementation

{$R *.dfm}

uses uDm;

procedure TFrmCad.BtnCancelClick(Sender: TObject);
begin
   FDCad.Cancel;
end;

procedure TFrmCad.BtnCloseClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TFrmCad.BtnCreateClick(Sender: TObject);
begin
   FDCad.Append;
end;

procedure TFrmCad.BtnEditClick(Sender: TObject);
begin
   FDCad.Edit;
end;

procedure TFrmCad.DSCadStateChange(Sender: TObject);
begin
   if (DsCad.State = dsBrowse) then
      CardPanel.ActiveCard := CardBrowse
   else
      CardPanel.ActiveCard := CardCreate;

   BtnCreate.Enabled := DSCad.State = dsBrowse;
   BtnEdit.Enabled   := DSCad.State = dsBrowse;
   BtnDelete.Enabled := DSCad.State = dsBrowse;

   BtnSave.Enabled   := dsCad.State in [dsEdit, dsInsert];
   BtnCancel.Enabled := dsCad.State in [dsEdit, dsInsert];
end;

procedure TFrmCad.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = #27) and (DSCad.State = dsBrowse) Then
      Close
end;

procedure TFrmCad.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
   if (PnlButtons.Enabled) and (PnlButtons.Visible) then
   begin

      if (Msg.CharCode = VK_F3) then
      begin
         if ((BtnCreate.Visible) and (BtnCreate.Enabled)) then
         begin
            BtnCreate.SetFocus;
            BtnCreate.Click;
         end;
      end;

      if (Msg.CharCode = VK_F4) then
      begin
         if ((BtnEdit.Visible) and (BtnEdit.Enabled)) then
         begin
            BtnEdit.SetFocus;
            BtnEdit.Click;
         end;
      end;

      if (Msg.CharCode = VK_F5) then
      begin
         if ((BtnSave.Visible) and (BtnSave.Enabled)) then
         begin
            BtnSave.SetFocus;
            BtnSave.Click;
         end;
      end;

      if (Msg.CharCode = VK_F6) then
      begin
         if ((BtnDelete.Visible) and (BtnDelete.Enabled)) then
         begin
            BtnDelete.SetFocus;
            BtnDelete.Click;
         end;
      end;
   end;
end;

procedure TFrmCad.FormShow(Sender: TObject);
begin
   LblScreenName.Caption := Self.Caption;
   CardPanel.ActiveCard := CardBrowse;
end;

end.
