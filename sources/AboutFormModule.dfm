object AboutForm: TAboutForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 321
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 10
    Top = 10
    Width = 370
    Height = 300
    TabOrder = 0
    object LogoImg: TImage
      Left = 10
      Top = 10
      Width = 32
      Height = 32
    end
    object AppName: TLabel
      Left = 50
      Top = 10
      Width = 6
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object VerInfo: TLabel
      Left = 50
      Top = 40
      Width = 3
      Height = 13
    end
    object Contributors: TLabel
      Left = 10
      Top = 70
      Width = 4
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = ContributorsClick
    end
    object License: TLabel
      Left = 258
      Top = 70
      Width = 4
      Height = 16
      Alignment = taRightJustify
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = LicenseClick
    end
    object Credits: TMemo
      Left = 2
      Top = 98
      Width = 366
      Height = 200
      Align = alBottom
      BorderStyle = bsNone
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      ExplicitTop = 148
    end
  end
end
