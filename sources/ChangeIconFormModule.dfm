object ChangeIconForm: TChangeIconForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 172
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 378
    Height = 130
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 50
      Top = 25
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object Label2: TLabel
      Left = 50
      Top = 55
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object IcImage: TImage
      Left = 328
      Top = 50
      Width = 32
      Height = 32
    end
    object Label3: TLabel
      Left = 135
      Top = 55
      Width = 3
      Height = 13
    end
    object IndexEdit: TSpinEdit
      Left = 60
      Top = 50
      Width = 65
      Height = 22
      MaxValue = 1
      MinValue = 1
      TabOrder = 2
      Value = 0
      OnChange = IndexEditChange
    end
    object RefProps: TButton
      Left = 340
      Top = 20
      Width = 20
      Height = 20
      HotImageIndex = 3
      ImageAlignment = iaCenter
      ImageIndex = 2
      Images = Data.Images
      TabOrder = 1
      OnClick = RefPropsClick
    end
    object IconEdit: TButtonedEdit
      Left = 60
      Top = 20
      Width = 250
      Height = 21
      Images = Data.Images
      RightButton.HotImageIndex = 1
      RightButton.ImageIndex = 0
      RightButton.Visible = True
      TabOrder = 0
      OnRightButtonClick = BrowseIconClick
    end
    object NegativeBox: TCheckBox
      Left = 60
      Top = 100
      Width = 250
      Height = 17
      TabOrder = 3
      OnClick = IndexEditChange
    end
  end
  object CancelButton: TButton
    Left = 300
    Top = 140
    Width = 75
    Height = 25
    Cancel = True
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object OKButton: TButton
    Left = 210
    Top = 140
    Width = 75
    Height = 25
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
end
