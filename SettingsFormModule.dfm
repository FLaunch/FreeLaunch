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
        Left = 288
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
      object TabsEdit: TEdit
        Left = 67
        Top = 10
        Width = 51
        Height = 21
        TabOrder = 0
        Text = '1'
        OnChange = TabsEditChange
        OnKeyPress = EditKeyPress
      end
      object UpDown1: TUpDown
        Left = 118
        Top = 10
        Width = 13
        Height = 21
        TabOrder = 1
        OnClick = UpDown1Click
      end
      object RowsEdit: TEdit
        Left = 67
        Top = 37
        Width = 51
        Height = 21
        TabOrder = 2
        Text = '1'
        OnChange = RowsEditChange
        OnKeyPress = EditKeyPress
      end
      object UpDown2: TUpDown
        Left = 118
        Top = 37
        Width = 13
        Height = 21
        TabOrder = 3
        OnClick = UpDown2Click
      end
      object ColsEdit: TEdit
        Left = 67
        Top = 64
        Width = 51
        Height = 21
        TabOrder = 4
        Text = '1'
        OnChange = ColsEditChange
        OnKeyPress = EditKeyPress
      end
      object UpDown3: TUpDown
        Left = 118
        Top = 64
        Width = 13
        Height = 21
        TabOrder = 5
        OnClick = UpDown3Click
      end
      object AutorunCheckBox: TCheckBox
        Left = 14
        Top = 128
        Width = 148
        Height = 17
        TabOrder = 8
      end
      object TopCheckBox: TCheckBox
        Left = 14
        Top = 151
        Width = 148
        Height = 17
        TabOrder = 9
      end
      object TBarBox: TComboBox
        Left = 198
        Top = 36
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 11
      end
      object TabsBox: TComboBox
        Left = 198
        Top = 92
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 12
      end
      object PaddingEdit: TEdit
        Left = 67
        Top = 90
        Width = 51
        Height = 21
        TabOrder = 6
        Text = '1'
        OnChange = PaddingEditChange
      end
      object UpDown4: TUpDown
        Left = 118
        Top = 90
        Width = 13
        Height = 21
        TabOrder = 7
        OnClick = UpDown4Click
      end
      object ReloadIconsButton: TButton
        Left = 198
        Top = 174
        Width = 145
        Height = 25
        TabOrder = 17
        OnClick = ReloadIconsButtonClick
      end
      object IWEdit: TEdit
        Left = 245
        Top = 141
        Width = 25
        Height = 21
        TabOrder = 13
        Text = '32'
        OnChange = IWEditChange
        OnKeyPress = EditKeyPress
      end
      object UpDown5: TUpDown
        Left = 270
        Top = 141
        Width = 13
        Height = 21
        Min = 20
        Max = 32
        Position = 20
        TabOrder = 14
        OnClick = UpDown5Click
      end
      object IHEdit: TEdit
        Left = 298
        Top = 141
        Width = 25
        Height = 21
        TabOrder = 15
        Text = '32'
        OnChange = IHEditChange
        OnKeyPress = EditKeyPress
      end
      object UpDown6: TUpDown
        Left = 323
        Top = 141
        Width = 13
        Height = 21
        Min = 20
        Max = 32
        Position = 20
        TabOrder = 16
        OnClick = UpDown6Click
      end
      object StartHideBox: TCheckBox
        Left = 14
        Top = 174
        Width = 148
        Height = 17
        TabOrder = 10
      end
      object LanguagesBox: TComboBox
        Left = 198
        Top = 232
        Width = 145
        Height = 21
        Style = csOwnerDrawFixed
        ItemHeight = 15
        TabOrder = 18
        OnDrawItem = LanguagesBoxDrawItem
        Items.Strings = (
          #1056#1091#1089#1089#1082#1080#1081)
      end
      object StatusBarBox: TCheckBox
        Left = 14
        Top = 197
        Width = 148
        Height = 17
        TabOrder = 19
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
