object ProgrammPropertiesForm: TProgrammPropertiesForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 309
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    538
    309)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 521
    Height = 264
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    object TabSheet1: TTabSheet
      DesignSize = (
        513
        236)
      object Label1: TLabel
        Left = 69
        Top = 18
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label2: TLabel
        Left = 69
        Top = 78
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label4: TLabel
        Left = 69
        Top = 164
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label3: TLabel
        Left = 69
        Top = 194
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Bevel1: TBevel
        Left = 351
        Top = 9
        Width = 9
        Height = 214
        Anchors = [akLeft, akTop, akBottom]
        Shape = bsLeftLine
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
      object Label7: TLabel
        Left = 226
        Top = 194
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label8: TLabel
        Left = 69
        Top = 134
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Enabled = False
      end
      object Label9: TLabel
        Left = 69
        Top = 48
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object CommandEdit: TEdit
        Left = 78
        Top = 15
        Width = 211
        Height = 21
        TabOrder = 0
        OnChange = CommandEditChange
      end
      object ParamsEdit: TEdit
        Left = 78
        Top = 75
        Width = 259
        Height = 21
        TabOrder = 2
      end
      object DescrEdit: TEdit
        Left = 78
        Top = 161
        Width = 259
        Height = 21
        TabOrder = 5
      end
      object PriorBox: TComboBox
        Left = 78
        Top = 191
        Width = 107
        Height = 21
        Style = csDropDownList
        TabOrder = 6
      end
      object ChangeIconButton: TButton
        Left = 423
        Top = 128
        Width = 75
        Height = 25
        TabOrder = 10
        OnClick = ChangeIconButtonClick
      end
      object QuesCheckBox: TCheckBox
        Left = 372
        Top = 37
        Width = 138
        Height = 17
        TabOrder = 8
      end
      object WStyleBox: TComboBox
        Left = 235
        Top = 191
        Width = 102
        Height = 21
        Style = csDropDownList
        TabOrder = 7
      end
      object DropBox: TCheckBox
        Left = 78
        Top = 105
        Width = 259
        Height = 17
        TabOrder = 3
        OnClick = DropBoxClick
      end
      object DropParamsEdit: TEdit
        Left = 78
        Top = 131
        Width = 259
        Height = 21
        Enabled = False
        TabOrder = 4
      end
      object HideCheckBox: TCheckBox
        Left = 372
        Top = 60
        Width = 138
        Height = 17
        TabOrder = 9
      end
      object WorkFolderEdit: TEdit
        Left = 78
        Top = 45
        Width = 259
        Height = 21
        TabOrder = 1
      end
    end
  end
  object OKButton: TButton
    Left = 373
    Top = 278
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 454
    Top = 278
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object OpenExec: TOpenDialog
    Filter = #1051#1102#1073#1086#1081' '#1092#1072#1081#1083' (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofNoDereferenceLinks, ofEnableSizing]
    Left = 16
    Top = 280
  end
end
