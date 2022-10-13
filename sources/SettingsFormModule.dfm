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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgc: TPageControl
    Left = 8
    Top = 8
    Width = 377
    Height = 301
    ActivePage = TabGeneral
    TabOrder = 0
    object TabGeneral: TTabSheet
      object AutorunCheckBox: TCheckBox
        Left = 10
        Top = 10
        Width = 350
        Height = 17
        TabOrder = 0
      end
      object TopCheckBox: TCheckBox
        Left = 10
        Top = 35
        Width = 350
        Height = 17
        TabOrder = 1
      end
      object ReloadIconsButton: TButton
        Left = 210
        Top = 240
        Width = 145
        Height = 25
        TabOrder = 5
        OnClick = ReloadIconsButtonClick
      end
      object StartHideBox: TCheckBox
        Left = 10
        Top = 60
        Width = 350
        Height = 17
        TabOrder = 2
      end
      object StatusBarBox: TCheckBox
        Left = 10
        Top = 85
        Width = 350
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = StatusBarBoxClick
      end
      object DateTimeBox: TCheckBox
        Left = 30
        Top = 110
        Width = 330
        Height = 17
        TabOrder = 4
      end
    end
    object TabInterface: TTabSheet
      ImageIndex = 1
      object lblWndTitle: TLabel
        Left = 190
        Top = 55
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblTabStyle: TLabel
        Left = 190
        Top = 85
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblLang: TLabel
        Left = 190
        Top = 15
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblNumofTabs: TLabel
        Left = 240
        Top = 125
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblNumofRows: TLabel
        Left = 240
        Top = 155
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblNumofCols: TLabel
        Left = 240
        Top = 185
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object lblPadding: TLabel
        Left = 240
        Top = 215
        Width = 3
        Height = 13
        Alignment = taRightJustify
      end
      object TBarBox: TComboBox
        Left = 200
        Top = 50
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 1
      end
      object TabsBox: TComboBox
        Left = 200
        Top = 80
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 2
      end
      object LanguagesBox: TComboBox
        Left = 200
        Top = 10
        Width = 145
        Height = 21
        Style = csOwnerDrawFixed
        ItemHeight = 15
        TabOrder = 0
        OnDrawItem = LanguagesBoxDrawItem
        Items.Strings = (
          #1056#1091#1089#1089#1082#1080#1081)
      end
      object PaddingEdit: TSpinEdit
        Left = 250
        Top = 210
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 0
        TabOrder = 6
        Value = 1
      end
      object TabsEdit: TSpinEdit
        Left = 250
        Top = 120
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 3
        Value = 1
      end
      object RowsEdit: TSpinEdit
        Left = 250
        Top = 150
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 4
        Value = 1
      end
      object ColsEdit: TSpinEdit
        Left = 250
        Top = 180
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 5
        Value = 1
      end
    end
    object TabNewButtons: TTabSheet
      ImageIndex = 2
      object grpNewBtns: TGroupBox
        Left = 10
        Top = 10
        Width = 350
        Height = 150
        TabOrder = 0
        object HideCheckBox: TCheckBox
          Left = 10
          Top = 50
          Width = 330
          Height = 17
          TabOrder = 1
        end
        object QoLCheckBox: TCheckBox
          Left = 10
          Top = 75
          Width = 330
          Height = 17
          TabOrder = 2
        end
        object DelLnkCheckBox: TCheckBox
          Left = 10
          Top = 25
          Width = 330
          Height = 17
          TabOrder = 0
        end
      end
      object grpBtnSize: TGroupBox
        Left = 10
        Top = 180
        Width = 350
        Height = 80
        TabOrder = 1
        object lblBtnW: TLabel
          Left = 230
          Top = 20
          Width = 3
          Height = 13
          Alignment = taRightJustify
        end
        object lblBtnH: TLabel
          Left = 230
          Top = 50
          Width = 3
          Height = 13
          Alignment = taRightJustify
        end
        object IWEdit: TSpinEdit
          Left = 240
          Top = 15
          Width = 50
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 0
          Value = 32
        end
        object IHEdit: TSpinEdit
          Left = 240
          Top = 45
          Width = 50
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 1
          Value = 32
        end
      end
    end
  end
  object OKButton: TButton
    Left = 229
    Top = 315
    Width = 75
    Height = 25
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 310
    Top = 315
    Width = 75
    Height = 25
    Cancel = True
    TabOrder = 2
    OnClick = CancelButtonClick
  end
end
