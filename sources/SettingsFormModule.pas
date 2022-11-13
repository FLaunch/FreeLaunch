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
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.Samples.Spin,
  FLLanguage, FLFunctions;

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
    TabNewButtons: TTabSheet;
    grpNewBtns: TGroupBox;
    HideCheckBox: TCheckBox;
    QoLCheckBox: TCheckBox;
    DelLnkCheckBox: TCheckBox;
    DateTimeBox: TCheckBox;
    WSBox: TComboBox;
    lblWState: TLabel;
    AdminCheckBox: TCheckBox;
    lblPriority: TLabel;
    PriorityBox: TComboBox;
    DropCheckBox: TCheckBox;
    GlassCheckBox: TCheckBox;
    ClearCheckBox: TCheckBox;
    ThemesBox: TComboBox;
    lblTheme: TLabel;
    ApplyButton: TButton;
    ABlendCheckBox: TCheckBox;
    ABlendBar: TTrackBar;
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ReloadIconsButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LanguagesBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure StatusBarBoxClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure pgcChange(Sender: TObject);
    procedure ABlendCheckBoxClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    Langs: array of TLngInfo;
    LngFiles: array of string;
    NoPopup: TPopupMenu;
    procedure ApplyLanguage;
    procedure ApplySettings;
    procedure ProcLanguage(FileName: string);
    procedure ScanLanguagesDir;
  end;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

procedure TSettingsForm.ApplyLanguage;
var
  I: Integer;
begin
  PriorityBox.Items.Clear;
  TabsBox.Items.Clear;
  TBarBox.Items.Clear;
  ThemesBox.Items.Clear;
  WSBox.Items.Clear;
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  ApplyButton.Caption := Language.BtnApply;
  TabGeneral.Caption := Language.Settings.General;
  TabInterface.Caption := Language.Settings.GUIProperties;
  TabNewButtons.Caption := Language.Settings.BtnProperties;
  Caption := Language.Settings.Caption;
  lblNumofTabs.Caption := Language.Settings.NumOfTabs + ':';
  lblNumofRows.Caption := Language.Settings.Rows + ':';
  lblNumofCols.Caption := Language.Settings.Cols + ':';
  lblPadding.Caption := Language.Settings.Padding + ':';
  AutorunCheckBox.Caption := Language.Settings.ChbAutorun;
  TopCheckBox.Caption := Language.Settings.ChbAlwaysOnTop;
  StartHideBox.Caption := Language.Settings.ChbStartHide;
  StatusBarBox.Caption := Language.Settings.ChbStatusbar;
  DateTimeBox.Caption := Language.Settings.ChbDateTime;
  HideCheckBox.Caption := Language.Settings.ChbHideAL;
  QoLCheckBox.Caption := Language.Settings.ChbQoL;
  DelLnkCheckBox.Caption := Language.Settings.ChbDelLnk;
  AdminCheckBox.Caption := Language.Settings.ChbAdmin;
  DropCheckBox.Caption := Language.Settings.ChbDrop;
  GlassCheckBox.Caption := Language.Settings.ChbGlass;
  ClearCheckBox.Caption := Language.Settings.ChbClear;
  ABlendCheckBox.Caption := Language.Settings.ChbAlphaBlend + ':';
  lblLang.Caption := Language.Settings.Language + ':';
  lblWndTitle.Caption := Language.Settings.Titlebar + ':';
  lblTabStyle.Caption := Language.Settings.TabStyle + ':';
  grpBtnSize.Caption := Language.Settings.BtnSizes;
  lblBtnW.Caption := Language.Settings.BtnWidth + ':';
  lblBtnH.Caption := Language.Settings.BtnHeight + ':';
  lblWState.Caption := Language.Settings.WState + ':';
  lblPriority.Caption := Language.Settings.Priority + ':';
  lblTheme.Caption := Language.Settings.Theme + ':';
  ReloadIconsButton.Caption := Language.Settings.ReloadIcons;
  grpNewBtns.Caption := Language.Settings.NewBtnProperties;
  PriorityBox.Items.Add(Language.Settings.PriorityNormal);
  PriorityBox.Items.Add(Language.Settings.PriorityHigh);
  PriorityBox.Items.Add(Language.Settings.PriorityIdle);
  PriorityBox.Items.Add(Language.Settings.PriorityRealTime);
  PriorityBox.Items.Add(Language.Settings.PriorityBelowNormal);
  PriorityBox.Items.Add(Language.Settings.PriorityAboveNormal);
  TabsBox.Items.Add(Language.Settings.TabStylePages);
  TabsBox.Items.Add(Language.Settings.TabStyleButtons);
  TabsBox.Items.Add(Language.Settings.TabStyleFButtons);
  TBarBox.Items.Add(Language.Settings.TitlebarNormal);
  TBarBox.Items.Add(Language.Settings.TitlebarMini);
  TBarBox.Items.Add(Language.Settings.TitlebarHidden);
  WSBox.Items.Add(Language.Settings.WSNormal);
  WSBox.Items.Add(Language.Settings.WSMax);
  WSBox.Items.Add(Language.Settings.WSMin);
  WSBox.Items.Add(Language.Settings.WSHidden);
  for i := Low(FLThemes) to High(FLThemes)
    do ThemesBox.Items.Add(FLThemes[i].NameForGUI);
  PriorityBox.ItemIndex := PriorDef;
  TabsBox.ItemIndex := tabsview;
  TBarBox.ItemIndex := titlebar;
  ThemesBox.ItemIndex := CurrAppTheme;
  WSBox.ItemIndex := WStateDef;
end;

procedure TSettingsForm.ApplySettings;
var
  tabnum: integer;
begin
  ChPos := True;
  FlaunchMainForm.ChWinView(False);
  Autorun := AutorunCheckBox.Checked;
  AlwaysOnTop := TopCheckBox.Checked;
  StartHide := StartHideBox.Checked;
  StatusBarVis := StatusBarBox.Checked;
  dtimeinstbar := DateTimeBox.Checked;
  hideafterlaunch := HideCheckBox.Checked;
  queryonlaunch := QoLCheckBox.Checked;
  deletelnk := DelLnkCheckBox.Checked;
  rwar := AdminCheckBox.Checked;
  defdrop := DropCheckBox.Checked;
  nobgnotabs := GlassCheckBox.Checked;
  ClearONF := ClearCheckBox.Checked;
  ABlend := ABlendCheckBox.Checked;
  ABlendVal := 255 - Round(2.55 * ABlendBar.Position);
  WStateDef := WSBox.ItemIndex;
  PriorDef := PriorityBox.ItemIndex;
  CurrAppTheme := ThemesBox.ItemIndex;
  FlaunchMainForm.SetAutorun(Autorun);
  if LanguagesBox.ItemIndex >= 0 then
    lngfilename := LngFiles[LanguagesBox.ItemIndex];
  tabsview := TabsBox.ItemIndex;
  titlebar := TBarBox.ItemIndex;
  //FlaunchMainForm.MainTabs.SetFocus;
  tabnum := FlaunchMainForm.MainTabsNew.TabIndex;
  tabscount := TabsEdit.Value;
  rowscount := RowsEdit.Value;
  colscount := ColsEdit.Value;
  lpadding := PaddingEdit.Value;
  FlaunchMainForm.GrowTabNames(tabscount);
  FlaunchMainForm.SetTabNames;
  FlaunchMainForm.FLPanel.ColsCount := colscount;
  FlaunchMainForm.FLPanel.RowsCount := rowscount;
  if (ButtonWidth <> IWEdit.Value) or (ButtonHeight <> IHEdit.Value)
  then
  begin
    ButtonWidth := IWEdit.Value;
    ButtonHeight := IHEdit.Value;
    FlaunchMainForm.FLPanel.ButtonWidth := ButtonWidth;
    FlaunchMainForm.FLPanel.ButtonHeight := ButtonHeight;
    FlaunchMainForm.ReloadIcons;
  end;
  FlaunchMainForm.FLPanel.Padding := lpadding;
  if tabnum < tabscount then
    FlaunchMainForm.MainTabsNew.TabIndex := tabnum
  else
    FlaunchMainForm.MainTabsNew.TabIndex := 0;
  Language.Load(lngfilename);
  FlaunchMainForm.GenerateWnd;
  FlaunchMainForm.ChWinView(true);
  ChPos := False;
end;

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
  LanguagesBox.Enabled := LanguagesBox.Items.Count > 0;
end;

procedure TSettingsForm.StatusBarBoxClick(Sender: TObject);
begin
  DateTimeBox.Enabled := StatusBarBox.Checked;
end;

procedure TSettingsForm.ReloadIconsButtonClick(Sender: TObject);
begin
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
  TabsEdit.MaxValue := TabsCountMax;
  PaddingEdit.MaxValue := PaddingMax;
  RowsEdit.MaxValue := RowsCountMax;
  ColsEdit.MaxValue := ColsCountMax;
  IWEdit.MinValue := MinIconParam;
  IWEdit.MaxValue := MaxIconParam;
  IWEdit.MinValue := MinIconParam;
  IWEdit.MaxValue := MaxIconParam;
end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (ssCtrl in Shift) then OKButton.Click;
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  ApplyLanguage;
  settingsshowing := true;
  ScanLanguagesDir;
  AutorunCheckBox.Checked := (not IsPortable) and (Autorun);
  TopCheckBox.Checked := AlwaysOnTop;
  StartHideBox.Checked := StartHide;
  StatusBarBox.Checked := StatusBarVis;
  DateTimeBox.Checked := dtimeinstbar;
  DateTimeBox.Enabled := StatusBarBox.Checked;
  GlassCheckBox.Checked := nobgnotabs;
  ClearCheckBox.Checked := ClearONF;
  ABlendCheckBox.Checked := ABlend;
  ABlendBar.Enabled := ABlendCheckBox.Checked;
  ABlendBar.Position := Round((255 - ABlendVal) / 2.55);
  TabsEdit.MaxValue := TabsCountMax;
  TabsEdit.Value := tabscount;
  RowsEdit.MaxValue := RowsCountMax;
  RowsEdit.Value := rowscount;
  ColsEdit.MaxValue := ColsCountMax;
  ColsEdit.Value := colscount;
  PaddingEdit.Value := lpadding;
  IWEdit.Value := ButtonWidth;
  IHEdit.Value := ButtonHeight;
  HideCheckBox.Checked := hideafterlaunch;
  QoLCheckBox.Checked := queryonlaunch;
  DelLnkCheckBox.Checked := deletelnk;
  AdminCheckBox.Checked := rwar;
  DropCheckBox.Checked := defdrop;
  AutoRunCheckBox.Enabled := not IsPortable;
  if lotabinsettings in [0..pgc.PageCount - 1]
    then pgc.ActivePageIndex := lotabinsettings
    else pgc.ActivePageIndex := 0;
  pgc.ActivePage.SetFocus;
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
begin
  ApplySettings;
  Close;
end;

procedure TSettingsForm.ABlendCheckBoxClick(Sender: TObject);
begin
  ABlendBar.Enabled := ABlendCheckBox.Checked;
end;

procedure TSettingsForm.ApplyButtonClick(Sender: TObject);
begin
  ApplySettings;
  ApplyLanguage;
end;

procedure TSettingsForm.pgcChange(Sender: TObject);
begin
  lotabinsettings := pgc.ActivePageIndex;
end;

end.
