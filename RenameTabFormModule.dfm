object RenameTabForm: TRenameTabForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 102
  ClientWidth = 339
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 321
    Height = 57
    TabOrder = 0
    object Label1: TLabel
      Left = 87
      Top = 23
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object TabNameEdit: TEdit
      Left = 106
      Top = 20
      Width = 193
      Height = 21
      TabOrder = 0
    end
  end
  object OKButton: TButton
    Left = 173
    Top = 71
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 254
    Top = 71
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = CancelButtonClick
  end
end
