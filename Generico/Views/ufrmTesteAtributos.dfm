object frmTesteAtributos: TfrmTesteAtributos
  Left = 0
  Top = 0
  Caption = 'Teste Atributos'
  ClientHeight = 415
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 67
    Height = 13
    Caption = 'Objeto: Teste'
  end
  object Memo1: TMemo
    Left = 24
    Top = 27
    Width = 265
    Height = 142
    TabOrder = 0
  end
  object btnExcluir: TButton
    Left = 16
    Top = 275
    Width = 276
    Height = 25
    Caption = 'D - Excluir cod. 1'
    TabOrder = 4
    OnClick = btnExcluirClick
  end
  object btnInserir: TButton
    Left = 16
    Top = 182
    Width = 276
    Height = 25
    Caption = 'C - Inserir cod. 1'
    TabOrder = 1
    OnClick = btnInserirClick
  end
  object btnSalvar: TButton
    Left = 16
    Top = 244
    Width = 276
    Height = 25
    Caption = 'U - Salvar cod. 1'
    TabOrder = 3
    OnClick = btnSalvarClick
  end
  object btnBuscar: TButton
    Left = 16
    Top = 213
    Width = 276
    Height = 25
    Caption = 'R - Buscar cod. 1'
    TabOrder = 2
    OnClick = btnBuscarClick
  end
  object btnDataSet: TButton
    Left = 16
    Top = 315
    Width = 276
    Height = 25
    Caption = 'Retorna DataSet'
    TabOrder = 5
    OnClick = btnDataSetClick
  end
  object Button1: TButton
    Left = 16
    Top = 347
    Width = 276
    Height = 25
    Caption = 'Retorna Objetos'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 379
    Width = 276
    Height = 25
    Caption = 'Conta Registros'
    TabOrder = 7
    OnClick = Button2Click
  end
end
