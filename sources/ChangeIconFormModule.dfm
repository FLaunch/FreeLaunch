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
    object IndexEdit: TSpinEdit
      Left = 62
      Top = 50
      Width = 64
      Height = 22
      MaxValue = 1
      MinValue = 1
      TabOrder = 2
      Value = 0
      OnChange = IndexEditChange
    end
    object RefProps: TButton
      Left = 314
      Top = 20
      Width = 21
      Height = 21
      HotImageIndex = 3
      ImageAlignment = iaCenter
      ImageIndex = 2
      Images = Data.Images
      TabOrder = 1
      OnClick = RefPropsClick
    end
    object IconEdit: TButtonedEdit
      Left = 62
      Top = 20
      Width = 246
      Height = 21
      Images = Data.Images
      RightButton.HotImageIndex = 1
      RightButton.ImageIndex = 0
      RightButton.Visible = True
      TabOrder = 0
      OnRightButtonClick = BrowseIconClick
    end
  end
  object CancelButton: TButton
    Left = 300
    Top = 111
    Width = 75
    Height = 25
    Cancel = True
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object OKButton: TButton
    Left = 219
    Top = 111
    Width = 75
    Height = 25
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
end
