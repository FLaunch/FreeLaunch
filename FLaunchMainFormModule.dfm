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
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormActivate
  OnKeyDown = FormKeyDown
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
    OnPopup = TrayMenuPopup
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
  object TrayIcon: TTrayIcon
    Icon.Data = {
      0000010002001010000000000000680500002600000010100000000000006804
      00008E0500002800000010000000200000000100080000000000000100000000
      00000000000000010000000100000000000050586B00696969001D884B000B94
      47000D96490014984E0032815500239154002491550002C1560008C25A0013C4
      610019C5650038CE790041CF7F001E5FBA000132D500095DC200014ADA000257
      DD00076ADF000075D4003075D400027CE4004562D3005C7BE4003C96BD007F82
      85005180B3004CD3870065D998006EDB9E006DDC9E007EDFA8002B87CA000A97
      E1000C97E2003F89E60003A5ED0000ABF00075ACC2004B9CEB007D96E90003C3
      F70001E3FE0013E6F90046F4FE008181840089898A008C8C8E008E8E90009090
      91009999990087BFA000A3A3A300A3A3A400A6A6A700A8A8A800A9ADAC00ACAD
      AD00B1B1B200B6B6B700BBBEBD00BEBEBE00C3C3C300C4C4C400C9C9CA00CFCF
      CF00D4D4D400D5DAD800E1E1E100EEEFEF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000B210A0000000000000000
      191A2B0000000A062100000000000000112E13181400220A051F000000000000
      2B152E280101070A0D0A000000000B0000262701484707070A0A000000000A1E
      00140148473F3507030A00000000000C0F0001463F3B353030301D000000000A
      0C040436483B3B122517101D000000000E0C0C043F482E2C1625171D00000000
      000C090909482F2D2C1B1C3B350000000000000048252DFF3B3302303D000000
      000000000023253B473B3302304200000000000000002947FF453B3202380000
      000000000000003B47FF43393233000000000000000000003D44FF4238340000
      000000000000000000003F403D34FE3F0000C71F0000C10F0000C00F0000600F
      0000200F00009007000080030000C0030000E0010000FC010000FE000000FF00
      0000FF800000FFC00000FFF00000280000001000000020000000010020000000
      00004004000000000000000000000000000000000000000000000029C3490029
      C3490029C33A0029C3250000000002C1564202C156F86DDC9EFF02C1561A0000
      00000000000000000000000000000000000000000000000000000029C33A0029
      C3BA0132D5A30132D5820132D5820132D50502C1563502C156FE0A9447F402C1
      56920000000000000000000000000000000000000000000000000029C31E0132
      D5FF13E6F9FF014ADAFF027CE4FF0257DDFF42A26E0E02C1568202C156FF0A95
      47FB02C1569B0000000000000000000000000000000000000000000000000132
      D5680267DFF913E6F9FF00ABF0FF50586BFF50586BFF338156FF02C156FF02C0
      55E702C1566F0000000000000000000000000000000009C35BFF02C0553A0000
      00000264DFC103A5EDFF50586BFFEEEFEFFFE2E2E2FF338156FF328155FF02C1
      56FF02C156FF0000000000000000000000000000000009C35B354CD387FF02C0
      552F0274E3B550586BFFEEEFEFFFE2E2E2FFBBBEBDFF989899FF328155FF0E81
      40EF02C156FF000000000000000000000000000000000000000013C461FF02C0
      55BF02C1563E50586BFFD5DAD8FFBBBEBDFFA8AEACFF989899FF818184FF8181
      84FF818184FF5180B3FF929292090000000000000000000000000000000013C4
      61FF0B9447FF0B9447FF87BFA0FFEEEFEFFFACADAEFFABACADFF095DC2FF0C97
      E2FF3075D4FF1E5FBAFF5180B3FF9292920300000000000000000000000038CE
      79FF13C461FF02C055ED0B9447FFBBBEBDFFEEEFEFFF13E6F9FF03C3F7FF0075
      D4FF0C97E2FF3075D4FF5180B3FF9292927E0000000000000000000000000000
      000013C461FF249155FF249155FF239154FEEEEFEFFF46F4FEFF01E3FEFF03C3
      F7FF3C96BDFF7F8285FFADADAEFF959595EF9292920600000000000000000000
      0000000000002199564275ACC268EEEFEFFF0C97E2FF01E3FEFFFFFFFFFFACAC
      ADFF8E8E90FF696969FF828284FFB1B1B2FF9292924B00000000000000000000
      000000000000000000000000000077AABE712886CAFB0A97E1FFAEAEAFFFE2E2
      E2FFACACADFF8D8D8EFF696969FF838385FF9494948B00000000000000000000
      00000000000000000000000000000000000075ACC2FF75ACC2FFE1E1E1FFFFFF
      FFFFD4D4D4FFA8A8A8FF8C8C8EFF696969FF909091D200000000000000000000
      000000000000000000000000000000000000000000009292926FAEAEAEFFE0E0
      E0FFFFFFFFFFC9C9CAFFA6A6A7FF89898AFF8A8A8BF100000000000000000000
      00000000000000000000000000000000000000000000000000009292923FA7A7
      A7DECFCFCFFFFFFFFFFFC3C3C3FFA3A3A3FF8C8C8DF500000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009898985BB0B0B0D4BEBEBEFAB5B5B6F9909091FF843F0000801F0000800F
      0000C00F0000200F0000000F000080030000C0010000C0010000E0000000F000
      0000FC000000FE000000FF000000FF800000FFE00000}
    PopupMenu = TrayMenu
    Visible = True
    OnClick = TrayIconClick
    OnDblClick = TrayIconClick
    Left = 244
    Top = 32
  end
end
