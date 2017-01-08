object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 345
  ClientWidth = 393
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
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 377
    Height = 301
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      object Label2: TLabel
        Left = 58
        Top = 13
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label1: TLabel
        Left = 58
        Top = 40
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label3: TLabel
        Left = 58
        Top = 67
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Bevel1: TBevel
        Left = 172
        Top = 3
        Width = 9
        Height = 264
        Shape = bsLeftLine
      end
      object Label6: TLabel
        Left = 198
        Top = 13
        Width = 3
        Height = 13
      end
      object Bevel3: TBevel
        Left = 243
        Top = 20
        Width = 94
        Height = 10
        Shape = bsTopLine
      end
      object Label4: TLabel
        Left = 198
        Top = 69
        Width = 3
        Height = 13
      end
      object Bevel2: TBevel
        Left = 269
        Top = 76
        Width = 68
        Height = 10
        Shape = bsTopLine
      end
      object Label5: TLabel
        Left = 58
        Top = 93
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label9: TLabel
        Left = 198
        Top = 121
        Width = 3
        Height = 13
      end
      object Bevel4: TBevel
        Left = 241
        Top = 128
        Width = 96
        Height = 10
        Shape = bsTopLine
      end
      object Label7: TLabel
        Left = 234
        Top = 144
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object Label8: TLabel
        Left = 287
        Top = 144
        Width = 6
        Height = 13
        Caption = 'x'
      end
      object Label10: TLabel
        Left = 198
        Top = 209
        Width = 3
        Height = 13
      end
      object Bevel5: TBevel
        Left = 234
        Top = 216
        Width = 103
        Height = 10
        Shape = bsTopLine
      end
      object AutorunCheckBox: TCheckBox
        Left = 14
        Top = 128
        Width = 148
        Height = 17
        TabOrder = 0
      end
      object TopCheckBox: TCheckBox
        Left = 14
        Top = 151
        Width = 148
        Height = 17
        TabOrder = 1
      end
      object TBarBox: TComboBox
        Left = 198
        Top = 36
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 3
      end
      object TabsBox: TComboBox
        Left = 198
        Top = 92
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 4
      end
      object ReloadIconsButton: TButton
        Left = 198
        Top = 174
        Width = 145
        Height = 25
        TabOrder = 5
        OnClick = ReloadIconsButtonClick
      end
      object StartHideBox: TCheckBox
        Left = 14
        Top = 174
        Width = 148
        Height = 17
        TabOrder = 2
      end
      object LanguagesBox: TComboBox
        Left = 198
        Top = 232
        Width = 145
        Height = 21
        Style = csOwnerDrawFixed
        ItemHeight = 15
        TabOrder = 6
        OnDrawItem = LanguagesBoxDrawItem
        Items.Strings = (
          #1056#1091#1089#1089#1082#1080#1081)
      end
      object StatusBarBox: TCheckBox
        Left = 14
        Top = 197
        Width = 148
        Height = 17
        TabOrder = 7
      end
      object PaddingEdit: TSpinEdit
        Left = 67
        Top = 91
        Width = 64
        Height = 22
        MaxValue = 100
        MinValue = 0
        TabOrder = 8
        Value = 1
      end
      object ColsEdit: TSpinEdit
        Left = 67
        Top = 63
        Width = 64
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 9
        Value = 1
      end
      object RowsEdit: TSpinEdit
        Left = 67
        Top = 37
        Width = 64
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 10
        Value = 1
      end
      object TabsEdit: TSpinEdit
        Left = 67
        Top = 9
        Width = 64
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 11
        Value = 1
      end
      object IWEdit: TSpinEdit
        Left = 237
        Top = 141
        Width = 44
        Height = 22
        MaxValue = 256
        MinValue = 16
        TabOrder = 12
        Value = 32
      end
      object IHEdit: TSpinEdit
        Left = 299
        Top = 141
        Width = 44
        Height = 22
        MaxValue = 256
        MinValue = 16
        TabOrder = 13
        Value = 32
      end
    end
  end
  object OKButton: TButton
    Left = 229
    Top = 315
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 310
    Top = 315
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = CancelButtonClick
  end
end
