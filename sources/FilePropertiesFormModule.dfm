object FilePropertiesForm: TFilePropertiesForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 258
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  ShowHint = True
  OnShow = FormShow
  DesignSize = (
    538
    258)
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 521
    Height = 213
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    ExplicitHeight = 212
    object TabSheet1: TTabSheet
      DesignSize = (
        513
        185)
      object Label1: TLabel
        Left = 69
        Top = 18
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label4: TLabel
        Left = 69
        Top = 78
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label7: TLabel
        Left = 69
        Top = 108
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Bevel1: TBevel
        Left = 351
        Top = 9
        Width = 9
        Height = 163
        Anchors = [akLeft, akTop, akBottom]
        Shape = bsLeftLine
        ExplicitHeight = 214
      end
      object Label5: TLabel
        Left = 366
        Top = 17
        Width = 3
        Height = 13
      end
      object Bevel2: TBevel
        Left = 405
        Top = 24
        Width = 100
        Height = 10
        Shape = bsTopLine
      end
      object Bevel3: TBevel
        Left = 410
        Top = 109
        Width = 94
        Height = 10
        Shape = bsTopLine
      end
      object Label6: TLabel
        Left = 366
        Top = 102
        Width = 3
        Height = 13
      end
      object IcImage: TImage
        Left = 379
        Top = 125
        Width = 32
        Height = 32
      end
      object Label9: TLabel
        Left = 69
        Top = 48
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object DescrEdit: TEdit
        Left = 78
        Top = 75
        Width = 259
        Height = 21
        TabOrder = 3
      end
      object WStyleBox: TComboBox
        Left = 78
        Top = 105
        Width = 107
        Height = 21
        Style = csDropDownList
        TabOrder = 4
      end
      object ChangeIconButton: TButton
        Left = 423
        Top = 128
        Width = 75
        Height = 25
        TabOrder = 7
        OnClick = ChangeIconButtonClick
      end
      object QuesCheckBox: TCheckBox
        Left = 372
        Top = 37
        Width = 138
        Height = 17
        TabOrder = 5
      end
      object HideCheckBox: TCheckBox
        Left = 372
        Top = 60
        Width = 138
        Height = 17
        TabOrder = 6
      end
      object CommandEdit: TButtonedEdit
        Left = 78
        Top = 15
        Width = 236
        Height = 21
        Images = Data.Images
        RightButton.HotImageIndex = 1
        RightButton.ImageIndex = 0
        RightButton.Visible = True
        TabOrder = 0
        OnChange = CommandEditChange
        OnRightButtonClick = BrowseExecClick
      end
      object RefProps: TButton
        Left = 316
        Top = 15
        Width = 21
        Height = 21
        HotImageIndex = 3
        ImageAlignment = iaCenter
        ImageIndex = 2
        Images = Data.Images
        TabOrder = 1
        OnClick = RefPropsClick
      end
      object WorkFolderEdit: TButtonedEdit
        Left = 78
        Top = 45
        Width = 259
        Height = 21
        Images = Data.Images
        RightButton.HotImageIndex = 1
        RightButton.ImageIndex = 0
        RightButton.Visible = True
        TabOrder = 2
        OnRightButtonClick = WorkFolderClick
      end
    end
  end
  object OKButton: TButton
    Left = 373
    Top = 227
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = OKButtonClick
    ExplicitTop = 226
  end
  object CancelButton: TButton
    Left = 454
    Top = 227
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    ModalResult = 2
    TabOrder = 2
    ExplicitTop = 226
  end
end
