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
  Position = poScreenCenter
  OnShow = FormShow
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
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object CancelButton: TButton
    Left = 254
    Top = 71
    Width = 75
    Height = 25
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
end
