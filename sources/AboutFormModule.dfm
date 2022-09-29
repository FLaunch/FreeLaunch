object AboutForm: TAboutForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 208
  ClientWidth = 289
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 192
    TabOrder = 0
    object Image1: TImage
      Left = 35
      Top = 27
      Width = 32
      Height = 32
    end
    object Label1: TLabel
      Left = 77
      Top = 27
      Width = 6
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 18
      Top = 68
      Width = 236
      Height = 13
      Alignment = taCenter
      AutoSize = False
    end
    object Label3: TLabel
      Left = 18
      Top = 83
      Width = 236
      Height = 13
      Alignment = taCenter
      AutoSize = False
    end
    object Label4: TLabel
      Left = 18
      Top = 98
      Width = 236
      Height = 13
      Alignment = taCenter
      AutoSize = False
    end
  end
end
