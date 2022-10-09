{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2022 Alexey Tatuyko <feedback@ta2i4.ru>                 #
  #  Copyright (C) 2019 Mykola Petrivskiy                                  #
  #  Copyright (C) 2010 Joker-jar <joker-jar@yandex.ru>                    #
  #                                                                        #
  #  This file is part of FreeLaunch.                                      #
  #                                                                        #
  #  FreeLaunch is free software: you can redistribute it and/or modify    #
  #  it under the terms of the GNU General Public License as published by  #
  #  the Free Software Foundation, either version 3 of the License, or     #
  #  (at your option) any later version.                                   #
  #                                                                        #
  #  FreeLaunch is distributed in the hope that it will be useful,         #
  #  but WITHOUT ANY WARRANTY; without even the implied warranty of        #
  #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
  #  GNU General Public License for more details.                          #
  #                                                                        #
  #  You should have received a copy of the GNU General Public License     #
  #  along with FreeLaunch. If not, see <http://www.gnu.org/licenses/>.    #
  ##########################################################################
}

unit SettingsFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, IniFiles, Vcl.Samples.Spin,
  FLLanguage, FLFunctions;

const
  DesignDPI = 96;

type
  TSettingsForm = class(TForm)
    pgc: TPageControl;
    TabGeneral: TTabSheet;
    OKButton: TButton;
    CancelButton: TButton;
    lblNumofTabs: TLabel;
    lblNumofRows: TLabel;
    lblNumofCols: TLabel;
    AutorunCheckBox: TCheckBox;
    TopCheckBox: TCheckBox;
    lblWndTitle: TLabel;
    TBarBox: TComboBox;
    lblTabStyle: TLabel;
    TabsBox: TComboBox;
    lblPadding: TLabel;
    ReloadIconsButton: TButton;
    lblBtnW: TLabel;
    lblBtnH: TLabel;
    StartHideBox: TCheckBox;
    lblLang: TLabel;
    LanguagesBox: TComboBox;
    StatusBarBox: TCheckBox;
    PaddingEdit: TSpinEdit;
    ColsEdit: TSpinEdit;
    RowsEdit: TSpinEdit;
    TabsEdit: TSpinEdit;
    IWEdit: TSpinEdit;
    IHEdit: TSpinEdit;
    TabInterface: TTabSheet;
    grpBtnSize: TGroupBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ReloadIconsButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LanguagesBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  public
    Langs: array of TLngInfo;
    LngFiles: array of string;
    NoPopup: TPopupMenu;
    procedure ProcLanguage(FileName: string);
    procedure ScanLanguagesDir;
  end;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

procedure TSettingsForm.ProcLanguage(FileName: string);
var
  lngfile: TIniFile;
  LangCount: Integer;
begin
  lngfile := TIniFile.Create(FileName);
  try
    LangCount := Length(Langs);
    SetLength(Langs, LangCount + 1);
    SetLength(LngFiles, LangCount + 1);
    LngFiles[LangCount] := ExtractFileName(FileName);
    Langs[LangCount].Load(lngfile);
    LanguagesBox.Items.Add(Langs[LangCount].Name);
    if Language.Info.Name = Langs[LangCount].Name then
      LanguagesBox.ItemIndex := LanguagesBox.Items.Count - 1;
  finally
    lngfile.Free;
  end;
end;

procedure TSettingsForm.ScanLanguagesDir;
var
  SearchRec: TSearchRec;
  Dir: string;
begin
  LanguagesBox.Clear;
  Dir := ExtractFilePath(ParamStr(0)) + 'languages\';
  if FindFirst(Dir + '*.*', faAnyFile, SearchRec) = 0 then
    repeat
      if (SearchRec.name = '.') or (SearchRec.name = '..') then
        continue;
      if (extractfileext(SearchRec.name).ToLower = '.lng') then
        ProcLanguage(Dir + SearchRec.name);
    until
      FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
end;

procedure TSettingsForm.ReloadIconsButtonClick(Sender: TObject);
begin
  Close;
  FlaunchMainForm.ReloadIcons;
end;

procedure TSettingsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.LanguagesBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Multiplier: Double;
  FlagRect: TRect;
  Image: TBitmap;
begin
  Image := Langs[Index].Image;
  Multiplier := (Rect.Height - 4) / Image.Height;
  FlagRect.Left := Rect.Left + 2;
  FlagRect.Top := Rect.Top + 2;
  FlagRect.Height := Rect.Height - 4;
  FlagRect.Width := Round(Image.Width * Multiplier);

  LanguagesBox.Canvas.fillrect(rect);
  LanguagesBox.Canvas.StretchDraw(FlagRect, Image);
  LanguagesBox.Canvas.textout(rect.left + FlagRect.Width + 4, rect.top + 2,
    LanguagesBox.items[index]);
end;

procedure TSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  NoPopup.Free;
  for i := 0 to high(Langs) do
    Langs[i].Image.Free;
  SetLength(Langs, 0);
  settingsshowing := false;
  action := CAFree;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  NoPopup := TPopupMenu.Create(nil);
  TabsEdit.PopupMenu := NoPopup;
  RowsEdit.PopupMenu := NoPopup;
  ColsEdit.PopupMenu := NoPopup;
  PaddingEdit.PopupMenu := NoPopup;
  IWEdit.PopupMenu := NoPopup;
  IHEdit.PopupMenu := NoPopup;

  LanguagesBox.ItemHeight := MulDiv(LanguagesBox.ItemHeight,
    Screen.PixelsPerInch, DesignDPI);
end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  settingsshowing := true;
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  TabGeneral.Caption := Language.Settings.General;
  TabInterface.Caption := Language.Settings.GUIProperties;
  Caption := Language.Settings.Caption;
  lblNumofTabs.Caption := Language.Settings.NumOfTabs + ':';
  lblNumofRows.Caption := Language.Settings.Rows + ':';
  lblNumofCols.Caption := Language.Settings.Cols + ':';
  lblPadding.Caption := Language.Settings.Padding + ':';
  AutorunCheckBox.Caption := Language.Settings.ChbAutorun;
  TopCheckBox.Caption := Language.Settings.ChbAlwaysOnTop;
  StartHideBox.Caption := Language.Settings.ChbStartHide;
  StatusBarBox.Caption := Language.Settings.ChbStatusbar;
  TBarBox.Items.Add(Language.Settings.TitlebarNormal);
  TBarBox.Items.Add(Language.Settings.TitlebarMini);
  TBarBox.Items.Add(Language.Settings.TitlebarHidden);
  TabsBox.Items.Add(Language.Settings.TabStylePages);
  TabsBox.Items.Add(Language.Settings.TabStyleButtons);
  TabsBox.Items.Add(Language.Settings.TabStyleFButtons);
  lblLang.Caption := Language.Settings.Language + ':';
  lblWndTitle.Caption := Language.Settings.Titlebar + ':';
  lblTabStyle.Caption := Language.Settings.TabStyle + ':';
  grpBtnSize.Caption := Language.Settings.BtnSizes;
  lblBtnW.Caption := Language.Settings.BtnWidth + ':';
  lblBtnH.Caption := Language.Settings.BtnHeight + ':';
  ReloadIconsButton.Caption := Language.Settings.ReloadIcons;
  ScanLanguagesDir;
  AutorunCheckBox.Checked := (not IsPortable) and (Autorun);
  TopCheckBox.Checked := AlwaysOnTop;
  StartHideBox.Checked := StartHide;
  StatusBarBox.Checked := StatusBarVis;
  TBarBox.ItemIndex := titlebar;
  TabsBox.ItemIndex := tabsview;
  TabsEdit.MaxValue := TabsCountMax;
  TabsEdit.Value := FlaunchMainForm.tabscount;
  RowsEdit.MaxValue := RowsCountMax;
  RowsEdit.Value := rowscount;
  ColsEdit.MaxValue := ColsCountMax;
  ColsEdit.Value := colscount;
  PaddingEdit.Value := lpadding;
  IWEdit.Value := FlaunchMainForm.ButtonWidth;
  IHEdit.Value := FlaunchMainForm.ButtonHeight;
  AutoRunCheckBox.Enabled := not IsPortable;
  pgc.ActivePageIndex := 0;
  pgc.ActivePage.SetFocus;
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
var
  tabnum: integer;
begin
  ChPos := true;
  FlaunchMainForm.ChWinView(False);
  Autorun := AutorunCheckBox.Checked;
  AlwaysOnTop := TopCheckBox.Checked;
  StartHide := StartHideBox.Checked;
  StatusBarVis := StatusBarBox.Checked;
  FlaunchMainForm.SetAutorun(Autorun);
  if LanguagesBox.ItemIndex >= 0 then
    lngfilename := LngFiles[LanguagesBox.ItemIndex];
  tabsview := TabsBox.ItemIndex;
  titlebar := TBarBox.ItemIndex;
  //FlaunchMainForm.MainTabs.SetFocus;
  tabnum := FlaunchMainForm.MainTabsNew.TabIndex;
  FlaunchMainForm.tabscount := strtoint(TabsEdit.Text);
  rowscount := strtoint(RowsEdit.Text);
  colscount := strtoint(ColsEdit.Text);
  lpadding := strtoint(PaddingEdit.Text);

  FlaunchMainForm.GrowTabNames(FlaunchMainForm.tabscount);
  FlaunchMainForm.SetTabNames;
  FlaunchMainForm.FLPanel.ColsCount := colscount;
  FlaunchMainForm.FLPanel.RowsCount := rowscount;
  if (FlaunchMainForm.ButtonWidth <> IWEdit.Value) or
    (FlaunchMainForm.ButtonHeight <> IHEdit.Value)
  then
  begin
    FlaunchMainForm.ButtonWidth := IWEdit.Value;
    FlaunchMainForm.ButtonHeight := IHEdit.Value;
    FlaunchMainForm.FLPanel.ButtonWidth := FlaunchMainForm.ButtonWidth;
    FlaunchMainForm.FLPanel.ButtonHeight := FlaunchMainForm.ButtonHeight;
    FlaunchMainForm.ReloadIcons;
  end;
  FlaunchMainForm.FLPanel.Padding := lpadding;
  if tabnum < FlaunchMainForm.tabscount then
    FlaunchMainForm.MainTabsNew.TabIndex := tabnum
  else
    FlaunchMainForm.MainTabsNew.TabIndex := 0;
  Language.Load(lngfilename);
  FlaunchMainForm.GenerateWnd;
  FlaunchMainForm.ChWinView(true);
  ChPos := false;
  Close;
end;

end.
