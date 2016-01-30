object ChangeIconForm: TChangeIconForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 144
  ClientWidth = 383
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
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 367
    Height = 97
    TabOrder = 0
    object Label1: TLabel
      Left = 53
      Top = 23
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object Label2: TLabel
      Left = 53
      Top = 53
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object IcImage: TImage
      Left = 303
      Top = 49
      Width = 32
      Height = 32
    end
    object Label3: TLabel
      Left = 131
      Top = 53
      Width = 3
      Height = 13
    end
    object IconEdit: TEdit
      Left = 62
      Top = 20
      Width = 224
      Height = 21
      TabOrder = 0
    end
    object IndexEdit: TSpinEdit
      Left = 62
      Top = 50
      Width = 64
      Height = 22
      MaxValue = 1
      MinValue = 1
      TabOrder = 1
      Value = 0
      OnChange = IndexEditChange
    end
  end
  object CancelButton: TButton
    Left = 300
    Top = 111
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object OKButton: TButton
    Left = 219
    Top = 111
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object OpenIcon: TOpenDialog
    Filter = #1051#1102#1073#1086#1081' '#1092#1072#1081#1083' (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 16
    Top = 112
  end
end
