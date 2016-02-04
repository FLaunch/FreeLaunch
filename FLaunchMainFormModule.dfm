object FlaunchMainForm: TFlaunchMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 118
  ClientWidth = 325
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 99
    Width = 325
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Alignment = taCenter
        Width = 50
      end>
  end
  object MainTabs: TPageControl
    Left = 0
    Top = 0
    Width = 325
    Height = 99
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    OnDragDrop = MainTabsDragDrop
    OnDragOver = MainTabsDragOver
    OnMouseDown = MainTabsMouseDown
    object TabSheet1: TTabSheet
      object GroupPanel1: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      ImageIndex = 1
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel2: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      ImageIndex = 2
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel3: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      ImageIndex = 3
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel4: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet5: TTabSheet
      ImageIndex = 4
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel5: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet6: TTabSheet
      ImageIndex = 5
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel6: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet7: TTabSheet
      ImageIndex = 6
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel7: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
    object TabSheet8: TTabSheet
      ImageIndex = 7
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupPanel8: TPanel
        Left = 0
        Top = 0
        Width = 317
        Height = 71
        Align = alClient
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 0
      end
    end
  end
  object PopupMenu: TPopupMenu
    OnPopup = PopupMenuPopup
    Left = 48
    Top = 32
    object NI_Run: TMenuItem
      Default = True
      OnClick = NI_RunClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NI_TypeProgramm: TMenuItem
      OnClick = NI_TypeProgrammClick
    end
    object NI_TypeFile: TMenuItem
      OnClick = NI_TypeFileClick
    end
    object NI_L1: TMenuItem
      Caption = '-'
    end
    object NI_Export: TMenuItem
      OnClick = NI_ExportClick
    end
    object NI_Import: TMenuItem
      OnClick = NI_ImportClick
    end
    object NI_L2: TMenuItem
      Caption = '-'
    end
    object NI_Clear: TMenuItem
      OnClick = NI_ClearClick
    end
    object NI_L7: TMenuItem
      Caption = '-'
    end
    object NI_prop: TMenuItem
      OnClick = NI_propClick
    end
  end
  object TrayMenu: TPopupMenu
    Left = 16
    Top = 32
    object NI_Show: TMenuItem
      Default = True
      OnClick = NI_ShowClick
    end
    object NI_Settings: TMenuItem
      OnClick = NI_SettingsClick
    end
    object NI_L5: TMenuItem
      Caption = '-'
    end
    object NI_About: TMenuItem
      OnClick = NI_AboutClick
    end
    object NI_Close: TMenuItem
      OnClick = NI_CloseClick
    end
  end
  object PagesMenu: TPopupMenu
    Left = 80
    Top = 32
    object NI_Rename: TMenuItem
      OnClick = NI_RenameClick
    end
    object NI_L3: TMenuItem
      Caption = '-'
    end
    object NI_ClearTab: TMenuItem
      OnClick = NI_ClearTabClick
    end
    object NI_DeleteTab: TMenuItem
      OnClick = NI_DeleteTabClick
    end
    object NI_L4: TMenuItem
      Caption = '-'
    end
    object NI_Group: TMenuItem
      OnClick = NI_GroupClick
    end
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 112
    Top = 32
  end
  object SaveButtonDialog: TSaveDialog
    DefaultExt = '.flb'
    Left = 144
    Top = 32
  end
  object OpenButtonDialog: TOpenDialog
    DefaultExt = '.flb'
    Options = [ofEnableSizing]
    Left = 176
    Top = 32
  end
end
