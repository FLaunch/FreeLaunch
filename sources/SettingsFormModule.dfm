object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  ActiveControl = pgc
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 432
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Scaled = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object pgc: TPageControl
    Left = 0
    Top = 0
    Width = 448
    Height = 390
    ActivePage = TabGeneral
    Align = alTop
    TabOrder = 0
    OnChange = pgcChange
    object TabGeneral: TTabSheet
      Caption = 'General'
      object AutorunCheckBox: TCheckBox
        Left = 10
        Top = 10
        Width = 420
        Height = 17
        Caption = 'Autostart with system'
        TabOrder = 0
      end
      object TopCheckBox: TCheckBox
        Left = 10
        Top = 35
        Width = 420
        Height = 17
        Caption = 'Always on top'
        TabOrder = 1
      end
      object ReloadIconsButton: TButton
        Left = 10
        Top = 325
        Width = 145
        Height = 25
        Caption = 'Reload icons'
        TabOrder = 8
        OnClick = ReloadIconsButtonClick
      end
      object StartHideBox: TCheckBox
        Left = 10
        Top = 85
        Width = 420
        Height = 17
        Caption = 'Start hidden'
        TabOrder = 3
      end
      object StatusBarBox: TCheckBox
        Left = 10
        Top = 110
        Width = 420
        Height = 17
        Caption = 'Show status bar'
        TabOrder = 4
        OnClick = StatusBarBoxClick
      end
      object DateTimeBox: TCheckBox
        Left = 30
        Top = 135
        Width = 400
        Height = 17
        Caption = 'Show the date and time in the status bar'
        TabOrder = 5
      end
      object DelLnkCheckBox: TCheckBox
        Left = 10
        Top = 160
        Width = 420
        Height = 17
        Caption = 'Delete shortcut file after creating a button'
        TabOrder = 6
      end
      object ClearCheckBox: TCheckBox
        Left = 10
        Top = 185
        Width = 420
        Height = 17
        Caption = 
          'When reloading icons, delete the button if the object is not fou' +
          'nd'
        TabOrder = 7
      end
      object TaskBarBox: TCheckBox
        Left = 10
        Top = 60
        Width = 420
        Height = 17
        Caption = 'Show on taskbar'
        TabOrder = 2
      end
    end
    object TabInterface: TTabSheet
      Caption = 'Interface'
      ImageIndex = 1
      object lblWndTitle: TLabel
        Left = 190
        Top = 65
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Window title style:'
      end
      object lblTabStyle: TLabel
        Left = 190
        Top = 90
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Tab style:'
      end
      object lblLang: TLabel
        Left = 190
        Top = 15
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Language:'
      end
      object lblNumofTabs: TLabel
        Left = 265
        Top = 115
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Number of tabs:'
      end
      object lblNumofRows: TLabel
        Left = 265
        Top = 140
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Number of rows on the tab:'
      end
      object lblNumofCols: TLabel
        Left = 265
        Top = 165
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Number of columns on the tab:'
      end
      object lblPadding: TLabel
        Left = 265
        Top = 190
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Padding between buttons:'
      end
      object lblTheme: TLabel
        Left = 190
        Top = 40
        Width = 3
        Height = 13
        Alignment = taRightJustify
        Caption = 'Theme:'
      end
      object TBarBox: TComboBox
        Left = 200
        Top = 60
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 2
        Items.Strings = (
          'Normal'
          'Mini'
          'Hidden')
      end
      object TabsBox: TComboBox
        Left = 200
        Top = 85
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 3
        Items.Strings = (
          'Pages'
          'Buttons'
          'Flat buttons')
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
      end
      object PaddingEdit: TSpinEdit
        Left = 275
        Top = 185
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 0
        TabOrder = 7
        Value = 1
      end
      object TabsEdit: TSpinEdit
        Left = 275
        Top = 110
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 4
        Value = 1
      end
      object RowsEdit: TSpinEdit
        Left = 275
        Top = 135
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 5
        Value = 1
      end
      object ColsEdit: TSpinEdit
        Left = 275
        Top = 160
        Width = 70
        Height = 22
        MaxValue = 100
        MinValue = 1
        TabOrder = 6
        Value = 1
      end
      object ThemesBox: TComboBox
        Left = 200
        Top = 35
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 1
        Items.Strings = (
          'Classic'
          'Slate Gray'
          'Light')
      end
      object ABlendCheckBox: TCheckBox
        Left = 10
        Top = 220
        Width = 400
        Height = 17
        Caption = 'Enable main window transparency:'
        TabOrder = 8
        OnClick = ABlendCheckBoxClick
      end
      object ABlendBar: TTrackBar
        Left = 10
        Top = 270
        Width = 400
        Height = 35
        Max = 90
        Frequency = 10
        PositionToolTip = ptTop
        ShowSelRange = False
        TabOrder = 10
      end
      object ABOffCheckBox: TCheckBox
        Left = 30
        Top = 245
        Width = 380
        Height = 17
        Caption = 'Turn off transparency if the cursor is over the window'
        TabOrder = 9
      end
    end
    object TabNewButtons: TTabSheet
      Caption = 'Buttons'
      ImageIndex = 2
      object grpNewBtns: TGroupBox
        Left = 20
        Top = 20
        Width = 400
        Height = 190
        Caption = 'Properties of new buttons'
        TabOrder = 0
        object lblWState: TLabel
          Left = 230
          Top = 130
          Width = 3
          Height = 13
          Alignment = taRightJustify
          Caption = 'Window state:'
        end
        object lblPriority: TLabel
          Left = 230
          Top = 155
          Width = 3
          Height = 13
          Alignment = taRightJustify
          Caption = 'Priority:'
        end
        object HideCheckBox: TCheckBox
          Left = 10
          Top = 25
          Width = 380
          Height = 17
          Caption = 'Hide FreeLaunch after launching a button'
          TabOrder = 0
        end
        object QoLCheckBox: TCheckBox
          Left = 10
          Top = 50
          Width = 380
          Height = 17
          Caption = 'Request confirmation before launching a button'
          TabOrder = 1
        end
        object WSBox: TComboBox
          Left = 240
          Top = 125
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 4
          Items.Strings = (
            'Normal'
            'Maximized'
            'Minimized'
            'Hidden')
        end
        object AdminCheckBox: TCheckBox
          Left = 10
          Top = 75
          Width = 380
          Height = 17
          Caption = 'Run with Administrator rights'
          TabOrder = 2
          OnClick = AdminCheckBoxClick
        end
        object PriorityBox: TComboBox
          Left = 240
          Top = 150
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 5
          Items.Strings = (
            'Normal'
            'High'
            'Idle'
            'Below normal'
            'Above normal')
        end
        object DropCheckBox: TCheckBox
          Left = 10
          Top = 100
          Width = 380
          Height = 17
          Caption = 'Accept dropped files'
          TabOrder = 3
        end
      end
      object grpBtnSize: TGroupBox
        Left = 20
        Top = 230
        Width = 400
        Height = 70
        Caption = 'Button size'
        TabOrder = 1
        object lblBtnW: TLabel
          Left = 245
          Top = 15
          Width = 3
          Height = 13
          Alignment = taRightJustify
          Caption = 'Width:'
        end
        object lblBtnH: TLabel
          Left = 245
          Top = 40
          Width = 3
          Height = 13
          Alignment = taRightJustify
          Caption = 'Height:'
        end
        object IWEdit: TSpinEdit
          Left = 255
          Top = 10
          Width = 70
          Height = 22
          MaxValue = 256
          MinValue = 16
          TabOrder = 0
          Value = 32
        end
        object IHEdit: TSpinEdit
          Left = 255
          Top = 35
          Width = 70
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
    Left = 75
    Top = 400
    Width = 100
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 325
    Top = 400
    Width = 100
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    TabStop = False
    OnClick = CancelButtonClick
  end
  object ApplyButton: TButton
    Left = 200
    Top = 400
    Width = 100
    Height = 25
    Caption = 'Apply'
    Default = True
    TabOrder = 2
    OnClick = ApplyButtonClick
  end
end
