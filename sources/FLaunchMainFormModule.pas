{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2022 Alexey Tatuyko <feedback@ta2i4.ru>                 #
  #  Copyright (C) 2021 Mykola Petrivskiy                                  #
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

unit FLaunchMainFormModule;

{$DEFINE NIGHTLYBUILD}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.ActiveX,
  Winapi.ShlObj, Winapi.Shfolder,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.IniFiles,
  System.Win.ComObj, System.Win.Registry,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Menus,
  ProgrammPropertiesFormModule,
  FilePropertiesFormModule, RenameTabFormModule, SettingsFormModule,
  AboutFormModule, FLFunctions, FLLanguage, FLClasses, madExcept;

const
  TCM_GETITEMRECT = $130A;
  HotKeyID = 27071987;

  inisection = 'general';

  //tabs and rows/cols limits
  mint = 1;
  minr = 1;
  minc = 1;
  minp = 1;
  maxt = 8;
  maxp = 5;
  maxr = 5;
  maxc = 15;

  TabsCountMax = 50;
  RowsCountMax = 100;
  ColsCountMax = 150;

  MultKey = 13574;
  AddKey = 46287;

  cr_author = 'Joker-jar';
  cr_authormail = 'joker-jar@yandex.ru';
  cr_progname = 'FreeLaunch';
  {$IFDEF NIGHTLYBUILD}
  cr_nightly = True;
  {$ELSE}
  cr_nightly = False;
  {$ENDIF}

  DesignDPI = 96;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;

  link = array[0..maxr - 1,0..maxc - 1] of TLink;

  TFlaunchMainForm = class(TForm)
    StatusBar: TStatusBar;
    TrayMenu: TPopupMenu;
    NI_Close: TMenuItem;
    NI_Settings: TMenuItem;
    NI_Show: TMenuItem;
    Timer1: TTimer;
    NI_L5: TMenuItem;
    NI_About: TMenuItem;
    SaveButtonDialog: TSaveDialog;
    OpenButtonDialog: TOpenDialog;
    TrayIcon: TTrayIcon;
    MainTabsNew: TTabControl;
    ButtonPopupMenu: TPopupMenu;
    ButtonPopupItem_Run: TMenuItem;
    ButtonPopupItem_Line: TMenuItem;
    ButtonPopupItem_TypeProgramm: TMenuItem;
    ButtonPopupItem_TypeFile: TMenuItem;
    ButtonPopupItem_Line2: TMenuItem;
    ButtonPopupItem_Export: TMenuItem;
    ButtonPopupItem_Import: TMenuItem;
    ButtonPopupItem_Line3: TMenuItem;
    ButtonPopupItem_Clear: TMenuItem;
    ButtonPopupItem_Props: TMenuItem;
    TabPopupMenu: TPopupMenu;
    TabPopupItem_Rename: TMenuItem;
    TabPopupItem_Clear: TMenuItem;
    TabPopupItem_Delete: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NI_CloseClick(Sender: TObject);
    procedure NI_ShowClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure NI_AboutClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure NI_SettingsClick(Sender: TObject);
    procedure TrayMenuPopup(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ButtonPopupMenuPopup(Sender: TObject);
    procedure ButtonPopupItem_RunClick(Sender: TObject);
    procedure ButtonPopupItem_ExportClick(Sender: TObject);
    procedure ButtonPopupItem_ImportClick(Sender: TObject);
    procedure ButtonPopupItem_ClearClick(Sender: TObject);
    procedure ButtonPopupItem_PropsClick(Sender: TObject);
    //--Событие при переключении вкладки
    procedure MainTabsNewChange(Sender: TObject);
    procedure MainTabsNewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MainTabsNewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure MainTabsNewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabPopupItem_RenameClick(Sender: TObject);
    procedure TabPopupItem_DeleteClick(Sender: TObject);
    procedure TabPopupItem_ClearClick(Sender: TObject);
    procedure MainTabsNewMouseLeave(Sender: TObject);
  private
    //--Список имен вкладок
    TabNames: TStringList;
    /// <summary> Список кнопок в процессе запуска </summary>
    LaunchingButtons: TDictionary<Integer, TFLButton>;
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure WMDisplayChange(var Msg: TWMDisplayChange); message WM_DISPLAYCHANGE;
    procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;
    procedure UMShowMainForm(var Msg: TMessage); message UM_ShowMainForm;
    procedure UMHideMainForm(var Msg: TMessage); message UM_HideMainForm;
    procedure UMLaunchDone(var Msg: TMessage); message UM_LaunchDone;
    procedure LaunchButton(AButton: TFLButton; ADroppedFile: string = '');
    procedure ImportButton(Button: TFLButton; FileName: string);
    procedure ExportButton(Button: TFLButton; FileName: string);
    function LoadCfgFileString(AFileHandle: THandle; ALength: Integer = 0): string;
    function LoadLinksCfgFileV121_12_11: boolean;
    function LoadLinksCfgFileV10: boolean;
    function LoadLinksCfgFile: boolean;
    function ConfirmDialog(Msg, Title: string): Boolean;
    //--Событие генерируется при клике по кнопке на панели
    procedure FLPanelButtonClick(Sender: TObject; Button: TFLButton);
    //--Событие генерируется при нажатии кнопки мыши на кнопке панели
    procedure FLPanelButtonMouseDown(Sender: TObject; MouseButton: TMouseButton; Button: TFLButton);
    //--Событие генерируется при движении мыши по панели
    procedure FLPanelButtonMouseMove(Sender: TObject; Button: TFLButton);
    //--Событие генерируется при покидании курсора мыши кнопки
    procedure FLPanelButtonMouseLeave(Sender: TObject; Button: TFLButton);
    //--Событие при перетаскивании файла на кнопку панели
    procedure FLPanelDropFile(Sender: TObject; Button: TFLButton; FileName: string);
    //--Установка имени определенной вкладки
    procedure SetTabName(i: integer);
    //--Вызов диалога переименовывания вкладки
    procedure RenameTab(i: integer);
    //--Удаление вкладки
    procedure DeleteTab(i: integer);
    /// <summary> Считывание настроек кнопок из xml-файла </summary>
    procedure LoadLinksSettings;
    /// <summary> Функция определяет, находятся ли координаты t,r,c в пределах
    /// текущего размера панели </summary>
    function IsTRCInRange(t, r, c: integer): boolean;
    /// <summary> Сохранение настроек в xml-файл </summary>
    procedure SaveLinksSettings;
    /// <summary> Считывание иконок кнопок из кэша </summary>
    procedure LoadLinksIconsFromCache;
    /// <summary> Сохранение иконок кнопок в кэш </summary>
    procedure SaveLinksIconsToCache;
  public
    FLPanel: TFLPanel;
    //--Количество вкладок
    TabsCount: integer;
    //--Ширина и высота кнопок
    ButtonWidth, ButtonHeight: integer;
    procedure EndWork;
    procedure ChangeWndSize;
    procedure GenerateWnd;
    procedure LoadLanguage;
    function DefNameOfTab(tn: string): boolean;
    procedure SetAutorun(b: boolean);
    procedure LoadIni;
    function GetAppVersion: string;
    function PositionToPercent(p: integer; iswidth: boolean): integer;
    function PercentToPosition(p: integer; iswidth: boolean): integer;
    procedure LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
    procedure ChWinView(b: boolean);
    procedure ReloadIcons;
    procedure GrowTabNames(ACount: Integer);
    //--Установка имен всех вкладок
    procedure SetTabNames;
  end;

var
  FlaunchMainForm: TFlaunchMainForm;
  PropertiesMode: integer; //Переменная содержит тип кнопки, свойства которой редактируются в данный момент
  rowscount, colscount, lpadding, tabind,
    LeftPer, TopPer: integer;
  templinks: link;
  links: array[0..maxt - 1] of link;
  GlobTab: integer = -1;
  GlobRow: integer = -1;
  GlobCol: integer = -1;
  FocusTab: integer = -1;
  FocusRow: integer = -1;
  FocusCol: integer = -1;
  GlobTabNum: integer = -1;
  Nim: TNotifyIconData;
  Ini: TIniFile;
  Autorun, AlwaysOnTop, nowactive, starthide, aboutshowing, settingsshowing,
    statusbarvis: boolean;
  titlebar, tabsview: integer;
  lngfilename: string;
  ChPos: boolean = false;

implementation

{$R *.dfm}

uses
  XMLDoc, XMLIntf, PngImage, IOUtils, Math;

function TFlaunchMainForm.GetAppVersion: string;
var
  Dummy, VInfoSize, VValueSize: DWORD;
  VInfo: Pointer;
  VValue: PVSFixedFileInfo;
begin
  Result := '';
  VInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VInfoSize > 0 then begin
    GetMem(VInfo, VInfoSize);
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), 0, VInfoSize, VInfo) then begin
        VerQueryValue(VInfo, '\', Pointer(VValue), VValueSize);
        Result := IntToStr(VValue^.dwFileVersionMS shr 16) + '.' + IntToStr(VValue^.dwFileVersionMS and $FFF)
          {$IFDEF NIGHTLYBUILD}
            + '.' + IntToStr(VValue^.dwFileVersionLS shr 16) + '.' + IntToStr(VValue^.dwFileVersionLS and $FFFF)
          {$ENDIF}
          ;
      end;
    finally
      FreeMem(VInfo, VInfoSize);
    end;
  end;
end;

function TFlaunchMainForm.PositionToPercent(p: integer; iswidth: boolean): integer;
begin
  if iswidth then
    result := round(p / (Screen.DesktopWidth - Width) * 100)
  else
    result := round(p / (Screen.DesktopHeight - Height) * 100);
end;

procedure TFlaunchMainForm.ReloadIcons;
var
  t, r, c: Integer;
begin
  for t := 0 to TabsCount - 1 do
    for r := 0 to RowsCount - 1 do
      for c := 0 to ColsCount - 1 do
        if FLPanel.Buttons[t,r,c].IsActive then
        begin
          FLPanel.Buttons[t,r,c].Data.AssignIcons;
          FLPanel.Buttons[t,r,c].Repaint;
        end;
  FLPanel.PageNumber := MainTabsNew.TabIndex;
end;

//--Вызов диалога переименовывания вкладки
procedure TFlaunchMainForm.RenameTab(i: integer);
begin
  MainTabsNew.Tabs.Strings[i] :=
    TRenameTabForm.Execute(MainTabsNew.Tabs.Strings[i]);
  TabNames[i] := MainTabsNew.Tabs.Strings[i];
end;

function TFlaunchMainForm.PercentToPosition(p: integer; iswidth: boolean): integer;
begin
  if iswidth then
    result := round(p * (Screen.DesktopWidth - Width) / 100)
  else
    result := round(p * (Screen.DesktopHeight - Height) / 100);
end;

procedure TFlaunchMainForm.LoadLanguage;
begin
  Caption := cr_progname;

  NI_Show.Caption := Language.Menu.Show;
  NI_Settings.Caption := Language.Menu.Settings;
  NI_About.Caption := Language.Menu.About;
  NI_Close.Caption := Language.Menu.Close;

  ButtonPopupItem_Run.Caption := Language.Menu.Run;
  ButtonPopupItem_TypeProgramm.Caption := Language.Menu.TypeProgramm;
  ButtonPopupItem_TypeFile.Caption := Language.Menu.TypeFile;
  ButtonPopupItem_Export.Caption := Language.Menu.Export;
  ButtonPopupItem_Import.Caption := Language.Menu.Import;
  ButtonPopupItem_Clear.Caption := Language.Menu.Clear;
  ButtonPopupItem_Props.Caption := Language.Menu.Prop;

  SaveButtonDialog.Filter := Language.FlbFilter + '|*.flb';
  OpenButtonDialog.Filter := Language.FlbFilter + '|*.flb';

  TabPopupItem_Rename.Caption := Language.Menu.Rename;
  TabPopupItem_Clear.Caption := Language.Menu.ClearTab;
  TabPopupItem_Delete.Caption := Language.Menu.DeleteTab;
end;

procedure TFlaunchMainForm.SetAutorun(b: boolean);
var
  reg: TRegistry;
begin
  if IsPortable then
    Exit;

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.LazyWrite := false;
    reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', false);
    if b then
      begin
        reg.WriteString(cr_progname, Application.ExeName);
      end
    else
      reg.DeleteValue(cr_progname);
    reg.CloseKey;
  finally
    reg.free;
  end;
end;

//--Установка имени определенной вкладки
procedure TFlaunchMainForm.SetTabName(i: integer);
var
  TabName: string;
begin
  //--Определение имени вкладки
  if TabNames.Strings[i] = '' then
    //--Имя по-умолчанию
    TabName := Format(Language.Main.TabName, [i + 1])
  else
    //--Имя, заданное пользователем
    TabName := TabNames.Strings[i];
  //--Если вкладка существует
  if MainTabsNew.Tabs[i] <> '' then
  begin
    //--Задаем ей актуальное имя
    MainTabsNew.Tabs.Strings[i] := TabName;
    TabNames.Strings[i] := TabName;
  end
  else
    //--Иначе создаем и задаем актуальное имя
    MainTabsNew.Tabs[i] := TabName;
end;

//--Установка имен всех вкладок
procedure TFlaunchMainForm.SetTabNames;
var
  i: Integer;
begin
  if TabsCount > 1 then
  begin
    {*--Задаем имена вкладок--*}
    for i := 0 to TabsCount - 1 do
      SetTabName(i);
  end
  else
    MainTabsNew.Tabs.Clear;
end;

function TFlaunchMainForm.DefNameOfTab(tn: string): boolean;
var
  i: integer;
begin
  result := true;
  if tn = '' then exit;
  for i := 1 to maxt do
    if tn = Format(Language.Main.TabName, [i]) then exit;
  result := false;
end;

//--Удаление вкладки
procedure TFlaunchMainForm.DeleteTab(i: integer);
begin
  if TabsCount = 1 then
    Exit;
  if not ConfirmDialog(format(Language.Messages.DeleteTab, [MainTabsNew.Tabs[i]]),
    Language.Messages.Confirmation)
  then
    Exit;
  //--Удаляем имя этой вкладки
  TabNames.Delete(i);
  //--Удаляем вкладку
  MainTabsNew.Tabs.Delete(i);
  //--Уменьшаем счетчик вкладок на 1
  Dec(TabsCount);
  //--Если осталась единственная вкладка, скрываем ее
  if TabsCount = 1 then begin
    MainTabsNew.Tabs.Clear;
    ChPos := True;
  end;
  SetTabNames;
  //--Удаляем страницу данных и делаем активной нужную вкладку
  MainTabsNew.TabIndex := FLPanel.DeletePage(i);
  //--Перерисовываем активную вкладку
  MainTabsNew.Repaint;
  //--Подгоняем размер окна под актуальный размер панели
  ChangeWndSize;
  if TabsCount = 1 then ChPos := False;
end;

function TFlaunchMainForm.ConfirmDialog(Msg, Title: string): Boolean;
begin
  Result := Application.MessageBox(PChar(Msg), PChar(Title),
    MB_ICONQUESTION or MB_YESNO) = ID_YES;
end;

procedure TFlaunchMainForm.LoadIni;
var
  i: integer;
begin
  Ini := TIniFile.Create(fl_WorkDir+'FLaunch.ini');
  lngfilename := ini.ReadString(inisection, 'language', 'English.lng');
  tabscount := ini.ReadInteger(inisection, 'tabs', 3);
  if tabscount > maxt then
    tabscount := maxt;
  if tabscount < mint then
    tabscount := mint;
  rowscount := ini.ReadInteger(inisection, 'rows', 2);
  if rowscount > maxr then
    rowscount := maxr;
  if rowscount < minr then
    rowscount := minr;
  colscount := ini.ReadInteger(inisection, 'cols', 10);
  if colscount > maxc then
    colscount := maxc;
  if colscount < minc then
    colscount := minc;
  lpadding := ini.ReadInteger(inisection, 'padding', 1);
  if lpadding > maxp then
    lpadding := maxp;
  if lpadding < minp then
    lpadding := minp;
  ButtonWidth := ini.ReadInteger(inisection, 'iconwidth', 32);
  if (ButtonWidth < 16) or (ButtonWidth > 256) then
    ButtonWidth := 32;
  ButtonHeight := ini.ReadInteger(inisection, 'iconheight', 32);
  if (ButtonHeight < 16) or (ButtonHeight > 256) then
    ButtonHeight := 32;
  tabind := ini.ReadInteger(inisection, 'activetab', 0);
  if (tabind < 0) or (tabind > tabscount-1) then
    tabind := 0;
  titlebar := ini.ReadInteger(inisection, 'titlebar', 0);
  if (titlebar < 0) or (titlebar > 2) then
    titlebar := 0;
  tabsview := ini.ReadInteger(inisection, 'tabsview', 0);
  if (tabsview < 0) or (tabsview > 2) then
    tabsview := 0;
  alwaysontop := ini.ReadBool(inisection, 'alwaysontop', false);
  statusbarvis := ini.ReadBool(inisection, 'statusbar', true);
  Timer1.Enabled := statusbarvis;
  autorun := ini.ReadBool(inisection, 'autorun', false);
  starthide := ini.ReadBool(inisection, 'starthide', false);
  GrowTabNames(tabscount);
  for i := 1 to tabscount do
    TabNames[i-1] := ini.ReadString(inisection, Format('tab%dname',[i]), '');

  LeftPer := ini.ReadInteger(inisection, 'formleftpos', 100);
  if LeftPer < 0 then LeftPer := 0;
  if LeftPer > 100 then LeftPer := 100;
  TopPer := ini.ReadInteger(inisection, 'formtoppos', 0);
  if TopPer < 0 then TopPer := 0;
  if TopPer > 100 then TopPer := 100;

  MainTabsNew.Font.Name := ini.ReadString(inisection, 'tabsfontname', 'Tahoma');
  MainTabsNew.Font.Size := ini.ReadInteger(inisection, 'tabsfontsize', 8);

  ini.Free;
end;

procedure TFlaunchMainForm.TrayMenuPopup(Sender: TObject);
begin
  NI_About.Enabled := not aboutshowing;
  NI_Settings.Enabled := not settingsshowing;
end;

procedure TFlaunchMainForm.UMHideMainForm(var Msg: TMessage);
begin
  ChWinView(False);
end;

procedure TFlaunchMainForm.UMLaunchDone(var Msg: TMessage);
var
  Button: TFLButton;

begin
  Button := LaunchingButtons.Items[Msg.LParam];
  LaunchingButtons.Remove(Msg.LParam);

  if (Button.IsActive) and (Button.Data.IsAdmin <> Msg.WParam.ToBoolean) then
  begin
    Button.Data.IsAdmin := Msg.WParam.ToBoolean;
    Button.Data.AssignIcons;
    Button.Repaint;
  end;
end;

procedure TFlaunchMainForm.UMShowMainForm(var Msg: TMessage);
begin
  ChWinView(True);
end;

procedure TFlaunchMainForm.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  inherited;
  Msg.Result := 1;
  Application.Terminate;
end;

{*--Обработка пунктов контекстного меню вкладок--*}
procedure TFlaunchMainForm.TabPopupItem_ClearClick(Sender: TObject);
begin
  if not ConfirmDialog(format(Language.Messages.ClearTab, [MainTabsNew.Tabs[MainTabsNew.TabIndex]]),
    Language.Messages.Confirmation)
  then
    exit;
  FLPanel.ClearPage(MainTabsNew.TabIndex);
end;

procedure TFlaunchMainForm.TabPopupItem_DeleteClick(Sender: TObject);
begin
  DeleteTab(MainTabsNew.TabIndex);
end;

procedure TFlaunchMainForm.TabPopupItem_RenameClick(Sender: TObject);
begin
  RenameTab(MainTabsNew.TabIndex);
end;

procedure TFlaunchMainForm.Timer1Timer(Sender: TObject);
begin
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TFlaunchMainForm.ChWinView(b: boolean);
begin
  if b then
    begin
      Visible := true;
      Timer1.Enabled := statusbarvis;
      Timer1Timer(Self);
      ShowWindow(Application.Handle, SW_HIDE);
      SetForegroundWindow(Application.Handle);
    end
  else
    begin
      Visible := false;
      Timer1.Enabled := False;
    end;
end;

procedure TFlaunchMainForm.TrayIconClick(Sender: TObject);
begin
  ChWinView((not nowactive) or not (Showing));
end;

var
  LaunchID: Integer = 0;

procedure TFlaunchMainForm.LaunchButton(AButton: TFLButton;
  ADroppedFile: string);
begin
  Inc(LaunchID);
  LaunchingButtons.Add(LaunchID, AButton);
  NewProcess(AButton.DataToLink, Handle, LaunchID, ADroppedFile);
end;

function TFlaunchMainForm.LoadCfgFileString(AFileHandle: THandle; ALength: Integer = 0): string;
var
  buff: array[0..255] of Char;
  bufflen: integer;
begin
  Result := '';

  if ALength > 0 then
    bufflen := ALength
  else
    if FileRead(AFileHandle, bufflen, sizeof(bufflen)) < sizeof(bufflen) then
      Exit;
  FillChar(buff, sizeof(buff), 0);
  if FileRead(AFileHandle, buff, bufflen) < bufflen then
    Exit;

  Result := buff;

  Result := StringReplace(Result, '{FL_ROOT}', '%FL_ROOT%\',
    [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{FL_DIR}', '%FL_DIR%\',
    [rfReplaceAll, rfIgnoreCase]);
end;

function TFlaunchMainForm.LoadLinksCfgFileV121_12_11: boolean;
var
  t,r,c: integer;
  FileName, ext: string;
  LinksCfgFile: THandle;
begin
  result := false;
  FileName := fl_WorkDir + 'FLaunch.dat';
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  LoadCfgFileString(LinksCfgFile, 4);
  LoadCfgFileString(LinksCfgFile);
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          links[t,r,c].exec := LoadCfgFileString(LinksCfgFile);
          ext := extractfileext(links[t,r,c].exec).ToLower;
          if (not links[t,r,c].active) or IsExecutable(ext) then
            links[t,r,c].ltype := 0
          else
            links[t,r,c].ltype := 1;
          links[t,r,c].workdir := ExtractFilePath(links[t,r,c].exec);
          links[t,r,c].icon := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          links[t,r,c].params := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          links[t,r,c].dropparams := LoadCfgFileString(LinksCfgFile);
          links[t,r,c].descr := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].ques, sizeof(boolean));
          FileRead(LinksCfgFile, links[t,r,c].hide, sizeof(boolean));
          FileRead(LinksCfgFile, links[t,r,c].pr, sizeof(byte));
          FileRead(LinksCfgFile, links[t,r,c].wst, sizeof(byte));
        end;
  FileClose(LinksCfgFile);
end;

function TFlaunchMainForm.LoadLinksCfgFileV10: boolean;
var
  t,r,c: integer;
  FileName, ext: string;
  LinksCfgFile: THandle;
begin
  result := false;
  FileName := fl_WorkDir + 'Flaunch.dat';
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  LoadCfgFileString(LinksCfgFile, 4);
  LoadCfgFileString(LinksCfgFile);
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          links[t,r,c].exec := LoadCfgFileString(LinksCfgFile);
          ext := extractfileext(links[t,r,c].exec).ToLower;
          if (not links[t,r,c].active) or IsExecutable(ext) then
            links[t,r,c].ltype := 0
          else
            links[t,r,c].ltype := 1;
          links[t,r,c].workdir := ExtractFilePath(links[t,r,c].exec);
          links[t,r,c].icon := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          links[t,r,c].params := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          links[t,r,c].dropparams := LoadCfgFileString(LinksCfgFile);
          links[t,r,c].descr := LoadCfgFileString(LinksCfgFile);
          FileRead(LinksCfgFile, links[t,r,c].ques, sizeof(boolean));
          links[t,r,c].hide := false;
          FileRead(LinksCfgFile, links[t,r,c].pr, sizeof(byte));
          FileRead(LinksCfgFile, links[t,r,c].wst, sizeof(byte));
        end;
  FileClose(LinksCfgFile);
end;

function TFlaunchMainForm.LoadLinksCfgFile: boolean;
var
  t,r,c: integer;
  FileName, VerStr: string;
  LinksCfgFile: THandle;
  Button: TFLButton;
begin
  result := false;
  FileName := fl_WorkDir + 'FLaunch.dat';
  if not (fileexists(FileName)) then exit;
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  if LoadCfgFileString(LinksCfgFile, 4) <> 'LCFG' then
    begin
      FileClose(LinksCfgFile);
      RenameFile(FileName, fl_WorkDir + 'Flaunch_Unknown.dat');
      exit;
    end;
  VerStr := LoadCfgFileString(LinksCfgFile);
  if VerStr <> '2.0 beta 1' then
  begin
    FileClose(LinksCfgFile);

    if ConfirmDialog(format(Language.Messages.OldSettings,[VerStr]),
      Language.Messages.Confirmation)
    then
    begin
      if (VerStr = '1.21') or (VerStr = '1.2') or ((VerStr = '1.1')) then
        LoadLinksCfgFileV121_12_11
      else
        if VerStr = '1.0' then
          LoadLinksCfgFileV10
        else
          RenameFile(FileName, fl_WorkDir + Format('Flaunch_%s.dat',[VerStr]));
    end
    else
      RenameFile(FileName, fl_WorkDir + Format('Flaunch_%s.dat',[VerStr]));
  end
  else
  begin
    for t := 0 to maxt - 1 do
      for r := 0 to maxr - 1 do
        for c := 0 to maxc - 1 do
          begin
            FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
            FileRead(LinksCfgFile, links[t,r,c].ltype, sizeof(byte));
            links[t,r,c].exec := LoadCfgFileString(LinksCfgFile);
            links[t,r,c].workdir := LoadCfgFileString(LinksCfgFile);
            links[t,r,c].icon := LoadCfgFileString(LinksCfgFile);
            FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
            links[t,r,c].params := LoadCfgFileString(LinksCfgFile);
            FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
            links[t,r,c].dropparams := LoadCfgFileString(LinksCfgFile);
            links[t,r,c].descr := LoadCfgFileString(LinksCfgFile);
            FileRead(LinksCfgFile, links[t,r,c].ques, sizeof(boolean));
            FileRead(LinksCfgFile, links[t,r,c].hide, sizeof(boolean));
            FileRead(LinksCfgFile, links[t,r,c].pr, sizeof(byte));
            FileRead(LinksCfgFile, links[t,r,c].wst, sizeof(byte));
          end;
    FileClose(LinksCfgFile);
  end;

  for t := 0 to TabsCount - 1 do
    for r := 0 to RowsCount - 1 do
      for c := 0 to ColsCount - 1 do
      begin
        Button := FLPanel.Buttons[t, r, c];
        Button.LinkToData(links[t,r,c]);
      end;
end;

procedure TFlaunchMainForm.SaveLinksIconsToCache;
var
  t,r,c: integer;
  PngImg: TPngImage;
  FilePath: string;
begin
  PngImg := TPngImage.Create;
  try
    FilePath := fl_WorkDir + IconCacheDir + TPath.DirectorySeparatorChar;
    if not TDirectory.Exists(FilePath) then
      TDirectory.CreateDirectory(FilePath);

    for t := 0 to TabsCount - 1 do
      for r := 0 to RowsCount - 1 do
        for c := 0 to ColsCount - 1 do
          //--Если кнопка активна и у нее есть иконка
          if (FLPanel.Buttons[t,r,c].IsActive) and (FLPanel.Buttons[t,r,c].HasIcon) then
          begin
            {*--Сохраняем обычную иконку в файл--*}
            AlphaToPng(FLPanel.Buttons[t,r,c].Data.IconBmp, PngImg);
            PngImg.SaveToFile(FLPanel.Buttons[t,r,c].Data.IconCache);
            FLPanel.Buttons[t,r,c].Data.IconCache := '';
          end;
  finally
    PngImg.Free;
  end;
end;

procedure TFlaunchMainForm.SaveLinksSettings;
var
  RootNode, LinkNode, PanelNode, TabNode, IconNode, DropNode, WindowNode,
    PositionNode, TabRootNode, PanelRootNode, WindowRootNode, FontNode: IXMLNode;
  t,r,c: integer;
  TempData: TFLDataItem;
  XMLDocument: IXMLDocument;
begin
  FLPanel.ExpandStrings := false;
  XMLDocument := TXMLDocument.Create(Self);
  XMLDocument.Options := [doNodeAutoIndent];
  XMLDocument.Active := true;
  RootNode := XMLDocument.AddChild('FLaunch');
  RootNode.AddChild('Version').NodeValue := FLVersion;

  RootNode.AddChild('AutoRun').NodeValue := autorun;
  RootNode.AddChild('Language').NodeValue := lngfilename;

  WindowRootNode := RootNode.AddChild('Windows');
  WindowNode := WindowRootNode.AddChild('Window');

  PositionNode := WindowNode.AddChild('Position');
  PositionNode.AddChild('Left').NodeValue := PositionToPercent(Left, true);
  PositionNode.AddChild('Top').NodeValue := PositionToPercent(Top, false);

  WindowNode.AddChild('TitleBar').NodeValue := titlebar;
  WindowNode.AddChild('AlwaysOnTop').NodeValue := alwaysontop;
  WindowNode.AddChild('StatusBar').NodeValue := statusbarvis;
  WindowNode.AddChild('StartHidden').NodeValue := starthide;

  TabRootNode := WindowNode.AddChild('Tabs');

  TabRootNode.AddChild('View').NodeValue := tabsview;

  FontNode := TabRootNode.AddChild('Font');
  FontNode.AddChild('Name').NodeValue := MainTabsNew.Font.Name;
  FontNode.AddChild('Size').NodeValue := MainTabsNew.Font.Size;

  TabRootNode.AddChild('ActiveTab').NodeValue := MainTabsNew.TabIndex + 1;

  PanelRootNode := RootNode.AddChild('Panels');
  for t := 0 to TabsCount - 1 do
  begin
    TabNode := TabRootNode.AddChild('Tab');
    TabNode.Attributes['Number'] := t + 1;
    TabNode.AddChild('Name').NodeValue := TabNames[t];

    PanelNode := PanelRootNode.AddChild('Panel');
    PanelNode.AddChild('TabNumber').NodeValue := t + 1;
    PanelNode.AddChild('Rows').NodeValue := rowscount;
    PanelNode.AddChild('Columns').NodeValue := colscount;

    IconNode := PanelNode.AddChild('Icons');
    IconNode.AddChild('Width').NodeValue := ButtonWidth;
    IconNode.AddChild('Height').NodeValue := ButtonHeight;

    PanelNode.AddChild('Padding').NodeValue := LPadding;

    for r := 0 to RowsCount - 1 do
      for c := 0 to ColsCount - 1 do
      begin
        if not FLPanel.Buttons[t,r,c].IsActive then
          Continue;
        TempData := FLPanel.Buttons[t,r,c].Data;
        LinkNode := PanelNode.AddChild('Link');
        LinkNode.AddChild('Row').NodeValue := r + 1;
        LinkNode.AddChild('Column').NodeValue := c + 1;
        LinkNode.AddChild('Type').NodeValue := TempData.LType;
        LinkNode.AddChild('Execute').NodeValue := TempData.Exec;
        LinkNode.AddChild('WorkingDir').NodeValue := TempData.WorkDir;

        IconNode := LinkNode.AddChild('Icon');
        IconNode.AddChild('File').NodeValue := TempData.Icon;
        IconNode.AddChild('Index').NodeValue := TempData.IconIndex;
        IconNode.AddChild('Cache').NodeValue := TempData.IconCache;

        LinkNode.AddChild('Parameters').NodeValue := TempData.Params;

        DropNode := LinkNode.AddChild('Drop');
        DropNode.AddChild('Allow').NodeValue := TempData.DropFiles;
        DropNode.AddChild('Parameters').NodeValue := TempData.DropParams;

        LinkNode.AddChild('Description').NodeValue := TempData.Descr;
        LinkNode.AddChild('NeedQuestion').NodeValue := TempData.Ques;
        LinkNode.AddChild('HideContainer').NodeValue := TempData.Hide;
        LinkNode.AddChild('Priority').NodeValue := TempData.Pr;
        LinkNode.AddChild('WindowState').NodeValue := TempData.WSt;
        LinkNode.AddChild('RequireAdmin').NodeValue := TempData.IsAdmin;
      end;
  end;
  XMLDocument.SaveToFile(fl_WorkDir + 'FLaunch.xml');
  XMLDocument.Active := false;
  FLPanel.ExpandStrings := true;
end;

procedure TFlaunchMainForm.LoadLinksIconsFromCache;
var
  t, r, c: Integer;
  PngImg: TPngImage;
begin
  PngImg := TPngImage.Create;
  try
    //--Пробегаем по всем кнопкам
    for t := 0 to TabsCount - 1 do
      for r := 0 to RowsCount - 1 do
        for c := 0 to ColsCount - 1 do
          if FLPanel.Buttons[t,r,c].IsActive then
          begin
            if (FLPanel.Buttons[t,r,c].Data.IconCache <> '') and
              TFile.Exists(FLPanel.Buttons[t,r,c].Data.IconCache) then
            begin
              PngImg.LoadFromFile(FLPanel.Buttons[t,r,c].Data.IconCache);

              if (PngImg.Width = ButtonWidth) and (PngImg.Height = ButtonHeight) then
              begin
                FLPanel.Buttons[t,r,c].Data.IconBmp.Assign(PngImg);
                FLPanel.Buttons[t,r,c].HasIcon := true;
                FLPanel.Buttons[t,r,c].Data.PushedIconBmp.Assign(PngImg);
              end
              else
                FLPanel.Buttons[t,r,c].Data.AssignIcons;
            end
            else
              FLPanel.Buttons[t,r,c].Data.AssignIcons;
          end;
  finally
    PngImg.Free;
  end;
end;

procedure TFlaunchMainForm.GrowTabNames(ACount: Integer);
begin
  while TabNames.Count < ACount do
    TabNames.Add('');
  while TabNames.Count > ACount do
    TabNames.Delete(TabNames.Count - 1);
  while MainTabsNew.Tabs.Count < ACount do
    MainTabsNew.Tabs.Add('');
  while MainTabsNew.Tabs.Count > ACount do
    MainTabsNew.Tabs.Delete(MainTabsNew.Tabs.Count - 1);
  FLPanel.PagesCount := ACount;
end;

procedure TFlaunchMainForm.LoadLinksSettings;
var
  RootNode, LinkNode, IconNode, TabNode, WindowNode, PositionNode,
    TabRootNode, PanelRootNode, PanelNode, DropNode, FontNode: IXMLNode;
  TabNumber, Row, Column: Integer;
  TempData: TFLDataItem;
  XMLDocument: IXMLDocument;
  Version: string;

  function GetStr(AParent: IXMLNode; AChildName: string): string;
  var
    Child: IXMLNode;
  begin
    Result := '';
    Child := AParent.ChildNodes.FindNode(AChildName);
    if Assigned(Child) and Child.IsTextElement then
      Result := Child.Text;
  end;

  function GetInt(AParent: IXMLNode; AChildName: string): integer;
  var
    Child: IXMLNode;
  begin
    Result := 0;
    Child := AParent.ChildNodes.FindNode(AChildName);
    if Assigned(Child) and (Child.NodeValue <> NULL) then
      Result := Child.NodeValue;
  end;

  function GetBool(AParent: IXMLNode; AChildName: string): Boolean;
  var
    Child: IXMLNode;
  begin
    Result := False;
    Child := AParent.ChildNodes.FindNode(AChildName);
    if Assigned(Child) and (Child.NodeValue <> NULL) then
      Result := Child.NodeValue;
  end;

begin
  if not FileExists(fl_WorkDir + 'FLaunch.xml') then
    Exit;
  XMLDocument := TXMLDocument.Create(Self);
  XMLDocument.Options := [doNodeAutoIndent];
  XMLDocument.Active := true;
  XMLDocument.LoadFromFile(fl_WorkDir + 'FLaunch.xml');
  RootNode := XMLDocument.ChildNodes.FindNode('FLaunch');
  if (not Assigned(RootNode)) or (not RootNode.HasChildNodes) then
    Exit;

  Version := GetStr(RootNode, 'Version');

  autorun := GetBool(RootNode, 'AutoRun');
  lngfilename := GetStr(RootNode, 'Language');

  WindowNode := RootNode.ChildNodes.FindNode('Windows');
  if (not Assigned(WindowNode)) or (not WindowNode.HasChildNodes) then
    Exit;

  WindowNode := WindowNode.ChildNodes.FindNode('Window');
  if (not Assigned(WindowNode)) or (not WindowNode.HasChildNodes) then
    Exit;

  PositionNode := WindowNode.ChildNodes.FindNode('Position');
  if Assigned(PositionNode) and PositionNode.HasChildNodes then
  begin
    LeftPer := GetInt(PositionNode, 'Left');
    if LeftPer < 0 then LeftPer := 0;
    if LeftPer > 100 then LeftPer := 100;
    TopPer := GetInt(PositionNode, 'Top');
    if TopPer < 0 then TopPer := 0;
    if TopPer > 100 then TopPer := 100;
  end;

  titlebar := GetInt(WindowNode, 'TitleBar');
  alwaysontop := GetBool(WindowNode, 'AlwaysOnTop');
  statusbarvis := GetBool(WindowNode, 'StatusBar');
  starthide := GetBool(WindowNode, 'StartHidden');

  TabsCount := 0;
  TabNumber := 0;
  TabNames.Clear;
  TabRootNode := WindowNode.ChildNodes.FindNode('Tabs');
  if (not Assigned(TabRootNode)) or (not TabRootNode.HasChildNodes) then
    Exit;

  tabsview := GetInt(TabRootNode, 'View');

  FontNode := TabRootNode.ChildNodes.FindNode('Font');
  if Assigned(FontNode) and FontNode.HasChildNodes then
  begin
    MainTabsNew.Font.Name := GetStr(FontNode, 'Name');
    MainTabsNew.Font.Size := GetInt(FontNode, 'Size');
  end;

  TabNode := TabRootNode.ChildNodes.FindNode('Tab');
  while Assigned(TabNode) and TabNode.HasChildNodes do
  begin
    Inc(TabsCount);
    TabNumber := TabNode.Attributes['Number'];
    GrowTabNames(TabNumber);
    TabNames.Strings[TabNumber - 1] := GetStr(TabNode, 'Name');

    TabNode := TabNode.NextSibling;
  end;

  TabsCount := Min(TabsCount, TabsCountMax);
  GrowTabNames(TabNumber);

  MainTabsNew.TabIndex := GetInt(TabRootNode, 'ActiveTab') - 1;

  PanelRootNode := RootNode.ChildNodes.FindNode('Panels');
  if (not Assigned(PanelRootNode)) or (not PanelRootNode.HasChildNodes) then
    Exit;

  PanelNode := PanelRootNode.ChildNodes.First;
  for TabNumber := 0 to TabsCount - 1 do
  begin
    if (not Assigned(PanelNode)) or (not PanelNode.HasChildNodes) then
      Exit;

    RowsCount := GetInt(PanelNode, 'Rows');
    ColsCount := GetInt(PanelNode, 'Columns');
    RowsCount := Min(RowsCount, RowsCountMax);
    ColsCount := Min(ColsCount, ColsCountMax);
    FLPanel.RowsCount := RowsCount;
    FLPanel.ColsCount := ColsCount;

    IconNode := PanelNode.ChildNodes.FindNode('Icons');
    if Assigned(IconNode) and IconNode.HasChildNodes then
    begin
      ButtonWidth := GetInt(IconNode, 'Width');
      ButtonHeight := GetInt(IconNode, 'Height');
      FLPanel.ButtonWidth := ButtonWidth;
      FLPanel.ButtonHeight := ButtonHeight;
    end;

    LPadding := GetInt(PanelNode, 'Padding');
    FLPanel.Padding := LPadding;

    LinkNode := PanelNode.ChildNodes.FindNode('Link');
    while Assigned(LinkNode) and LinkNode.HasChildNodes do
    begin
      Row := GetInt(LinkNode, 'Row') - 1;
      Column := GetInt(LinkNode, 'Column') - 1;
      if not IsTRCInRange(TabNumber, Row, Column) then
        Continue;

      TempData := FLPanel.Buttons[TabNumber, Row, Column].InitializeData;
      TempData.LType := GetInt(LinkNode, 'Type');
      TempData.Exec := GetStr(LinkNode, 'Execute');
      TempData.WorkDir := GetStr(LinkNode, 'WorkingDir');

      IconNode := LinkNode.ChildNodes.FindNode('Icon');
      if Assigned(IconNode) and IconNode.HasChildNodes then
      begin
        TempData.Icon := GetStr(IconNode, 'File');
        TempData.IconIndex := GetInt(IconNode, 'Index');
        TempData.IconCache := GetStr(IconNode, 'Cache');
      end;

      TempData.Params := GetStr(LinkNode, 'Parameters');

      DropNode := LinkNode.ChildNodes.FindNode('Drop');
      if Assigned(DropNode) and DropNode.HasChildNodes then
      begin
        TempData.DropFiles := GetBool(DropNode, 'Allow');
        TempData.DropParams := GetStr(DropNode, 'Parameters');
      end;

      TempData.Descr := GetStr(LinkNode, 'Description');
      TempData.Ques := GetBool(LinkNode, 'NeedQuestion');
      TempData.Hide := GetBool(LinkNode, 'HideContainer');
      TempData.Pr := GetInt(LinkNode, 'Priority');
      TempData.WSt := GetInt(LinkNode, 'WindowState');
      TempData.IsAdmin := GetBool(LinkNode, 'RequireAdmin');

      TempData.AssignIcons;

      LinkNode := LinkNode.NextSibling;
    end;

    PanelNode := PanelNode.NextSibling;
  end;
  XMLDocument.Active := false;
end;

procedure TFlaunchMainForm.WMHotKey(var Msg: TWMHotKey);
begin
  if Msg.Msg = WM_HOTKEY then
    begin
      if Msg.HotKey = HotKeyID then
        begin
          nowactive := Active;
          ChWinView((not nowactive) or not (Showing));
        end;
    end;
  inherited;
end;

procedure TFlaunchMainForm.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
begin
  if not ChPos then
  begin
    LeftPer := PositionToPercent(Left, true);
    TopPer := PositionToPercent(Top, false);
  end;

  inherited;
end;

procedure TFlaunchMainForm.WMDisplayChange(var Msg: TWMDisplayChange);
begin
  ChPos := true;
  Left := PercentToPosition(LeftPer, true);
  Top := PercentToPosition(TopPer, false);
  ChPos := false;
  inherited;
end;

procedure TFlaunchMainForm.EndWork;
begin
  unregisterhotkey(Handle, HotKeyID);
  DeleteFile(fl_WorkDir + '.session');

  //--Сохраняем настройки кнопок
  SaveLinksSettings;
  //--Сохраняем иконки кнопок в кэш
  SaveLinksIconsToCache;

  LaunchingButtons.Free;
  //--Удаляем список имен вкладок
  TabNames.Free;
end;

procedure TFlaunchMainForm.LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
var
  icon: TIcon;
begin
  icon := TIcon.Create;
  if (not fileexists(FileName)) and (not directoryexists(FileName)) then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON')
  else
    icon.Handle := GetFileIcon(FileName, Index, Im.Height);
  if icon.Handle = 0 then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON');
  Im.Picture.Assign(icon);
  icon.Free;
end;

procedure TFlaunchMainForm.FormDestroy(Sender: TObject);
begin
  EndWork;
end;

procedure TFlaunchMainForm.CMDialogKey(var Msg: TCMDialogKey);
begin
  if (Msg.Msg = CM_DIALOGKEY) then
    begin
      if (Msg.CharCode <> VK_DOWN) and (Msg.CharCode <> VK_UP) and (Msg.CharCode <> VK_LEFT) and (Msg.CharCode <> VK_RIGHT) then
        inherited;
    end;
end;

procedure TFlaunchMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Key = ord('S')) and (ssCtrl in Shift)) then
    NI_SettingsClick(NI_Settings);
  if ((Key = ord('Q')) and (ssCtrl in Shift)) then
    Application.Terminate;
  //--Ctrl + W -> удалить вкладку
  if ((Key = ord('W')) and (ssCtrl in Shift)) then DeleteTab(MainTabsNew.TabIndex);
  //--F2 -> переименовать вкладку
  if key = VK_F2 then RenameTab(MainTabsNew.TabIndex);
end;

procedure TFlaunchMainForm.ButtonPopupItem_ClearClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;
  if ConfirmDialog(Format(Language.Messages.DeleteButton, [ExtractFileName(TempButton.Data.Exec)]),
    Language.Messages.Confirmation)
  then
    TempButton.FreeData;
end;

procedure TFlaunchMainForm.ButtonPopupItem_ExportClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;
  SaveButtonDialog.FileName := ExtractFileNameNoExt(TempButton.Data.Exec);
  if SaveButtonDialog.Execute(Handle) then
    ExportButton(TempButton, SaveButtonDialog.FileName);
end;

procedure TFlaunchMainForm.ButtonPopupItem_ImportClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;
  if OpenButtonDialog.Execute(Handle) then
    ImportButton(TempButton, OpenButtonDialog.FileName);
end;

procedure TFlaunchMainForm.ButtonPopupItem_PropsClick(Sender: TObject);
var
  TempButton: TFLButton;
  Link: TLink;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;

  PropertiesMode := 0;
  if Assigned(TempButton.Data) then
  begin
    PropertiesMode := TempButton.Data.LType;
    Link := TempButton.DataToLink;
  end
  else
  begin
    TempButton.InitializeData;
    Link := TempButton.DataToLink;
    Link.active := False;
    if ButtonPopupItem_TypeFile.Checked then
      PropertiesMode := 1;
  end;

  if PropertiesMode = 0 then
    TempButton.LinkToData(TProgrammPropertiesForm.Execute(Link));
  if PropertiesMode = 1 then
    TempButton.LinkToData(TFilePropertiesForm.Execute(Link));
end;

procedure TFlaunchMainForm.ButtonPopupItem_RunClick(Sender: TObject);
begin
  FLPanel.LastUsedButton.Click;
end;

procedure TFlaunchMainForm.ButtonPopupMenuPopup(Sender: TObject);
begin
  FLPanel.LastUsedButton.MouseUp(mbLeft, [], 0, 0);
end;

procedure TFlaunchMainForm.ChangeWndSize;
var
  MainWidth, MainHeight: Integer;
  TabInternalRect: TRect;
begin
  if TabsCount > 1 then
  begin
    MainTabsNew.Show;
    TabInternalRect := MainTabsNew.DisplayRect;
    FLPanel.Parent := MainTabsNew;
    FLPanel.Left := TabInternalRect.Left;
    FLPanel.Top := TabInternalRect.Top;
    FLPanel.DoubleBuffered := True;
    GlassFrame.Enabled := False;

    MainTabsNew.Width := MainTabsNew.Width + FLPanel.Width - TabInternalRect.Width;
    MainTabsNew.Height := MainTabsNew.Height + FLPanel.Height - TabInternalRect.Height;
    MainTabsNew.TabIndex := FLPanel.PageNumber;

    MainHeight := MainTabsNew.Height;
    MainWidth := MainTabsNew.Width;
  end
  else
  begin
    FLPanel.Parent := Self;
    MainTabsNew.Hide;
    FLPanel.Left := 0;
    FLPanel.Top := 0;
    FLPanel.DoubleBuffered := False;
    GlassFrame.Enabled := True;

    MainHeight := FLPanel.Height;
    MainWidth := FLPanel.Width;
  end;

  //--Позволяем перетягивать файлы на кнопку
  DragAcceptFiles(FLPanel.Handle, True);

  StatusBar.Top := MainHeight + 1;
  StatusBar.Panels[0].Width := MainWidth - MulDiv(122, Screen.PixelsPerInch, DesignDPI);

  ClientWidth := MainWidth;
  if statusbarvis then
    ClientHeight := MainHeight + StatusBar.Height
  else
    ClientHeight := MainHeight;

  Left := PercentToPosition(LeftPer, true);
  Top := PercentToPosition(TopPer, false);
end;

procedure TFlaunchMainForm.GenerateWnd;
begin
  StatusBar.Visible := statusbarvis;
  case titlebar of
    0: BorderStyle := bsSingle;
    1: BorderStyle := bsToolWindow;
    2: BorderStyle := bsNone;
  end;
  case tabsview of
    0: MainTabsNew.Style := tsTabs;
    1: MainTabsNew.Style := tsButtons;
    2: MainTabsNew.Style := tsFlatButtons;
  end;
  if AlwaysOnTop then
    FormStyle := fsStayOnTop;

  ChangeWndSize;
end;

procedure TFlaunchMainForm.FLPanelButtonClick(Sender: TObject;
  Button: TFLButton);
begin
  if not Button.IsActive then
    Exit;
  LaunchButton(Button);
end;

procedure TFlaunchMainForm.FLPanelButtonMouseDown(Sender: TObject;
  MouseButton: TMouseButton; Button: TFLButton);
begin
  //--Если была нажата правая кнопка мыши
  if MouseButton = mbRight then
  begin
    {*--Активируем/деактивируем необходимые пункты контекстного меню кнопки--*}
    if Assigned(Button.Data) then
    begin
      ButtonPopupItem_TypeFile.Checked := Button.Data.LType = 1;
      ButtonPopupItem_TypeProgramm.Checked := not ButtonPopupItem_TypeFile.Checked;
    end
    else
      if (not ButtonPopupItem_TypeProgramm.Checked) and
        (not ButtonPopupItem_TypeFile.Checked)
      then
        ButtonPopupItem_TypeProgramm.Checked := True;

    ButtonPopupItem_Run.Enabled := Button.IsActive;
    ButtonPopupItem_Import.Enabled := not Button.IsActive;
    ButtonPopupItem_Export.Enabled := Button.IsActive;
    ButtonPopupItem_Clear.Enabled := Button.IsActive;
    ButtonPopupItem_TypeFile.Enabled := not Button.IsActive;
    ButtonPopupItem_TypeProgramm.Enabled := not Button.IsActive;
  end;
end;

procedure TFlaunchMainForm.FLPanelButtonMouseLeave(Sender: TObject;
  Button: TFLButton);
begin
  StatusBar.Panels[0].Text := '';
end;

procedure TFlaunchMainForm.FLPanelButtonMouseMove(Sender: TObject;
  Button: TFLButton);
begin
  if statusbarvis then
    if Button.IsActive then
    begin
      StatusBar.Panels[0].Text := Button.Data.Descr;
      Button.Hint := Format(Language.Main.Location + #13#10 +
        Language.Main.Parameters + #13#10 + Language.Main.Description,
        [Button.Data.Exec, Button.Data.Params, MyCutting(Button.Data.Descr, 60)]);
    end
    else
    begin
      StatusBar.Panels[0].Text := '';
      Button.Hint := '';
    end;
end;

procedure TFlaunchMainForm.FLPanelDropFile(Sender: TObject; Button: TFLButton;
  FileName: string);
var
  LnkInfo: TShellLinkInfoStruct;
  ext: string;
begin
  //--Если кнопка активна и "умеет" принимать перетягиваемые файлы
  if (Button.IsActive) and (Button.Data.DropFiles) then
  begin
    LaunchButton(Button, FileName);
    exit;
  end;
  {*--Если кнопка активна, просим подтверждение замены--*}
  if Button.IsActive then
  begin
    Button.Highlight;
    if not ConfirmDialog(Language.Messages.BusyReplace,
      Language.Messages.Confirmation)
    then
      Exit;
  end;
  Ext := ExtractFileExt(FileName).ToLower;
  //--Если был перетянут файл кнопки
  if Ext = '.flb' then
  begin
    Button.Highlight;
    if ConfirmDialog(format(Language.Messages.ImportButton,[FileName]), Language.Messages.Confirmation) then
      ImportButton(Button, FileName);
    exit;
  end;
  //--Инициализируем ячейку данных
  if not Button.IsActive then
    Button.InitializeData;
  //--Если был перетянут ярлык
  if Ext = '.lnk' then
  begin
    StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, FileName, MAX_PATH - 1);
    //--Извлекаем информацию о ярлыке
    GetLinkInfo(@lnkinfo);
    {*--Заполняем информацию в поля кнопки--*}
    Button.Data.Exec := LnkInfo.FullPathAndNameOfFileToExecute;
    Button.Data.IconIndex := LnkInfo.IconIndex;
    Button.Data.Icon := LnkInfo.FullPathAndNameOfFileContiningIcon;
    if Button.Data.Icon = '' then
    begin
      FLPanel.ExpandStrings := False;
      try
        Button.Data.Icon := Button.Data.Exec;
      finally
        FLPanel.ExpandStrings := True;
      end;
    end;
    Button.Data.WorkDir := LnkInfo.FullPathAndNameOfWorkingDirectroy;
    Button.Data.Params := LnkInfo.ParamStringsOfFileToExecute;
    Button.Data.Descr := LnkInfo.Description;
    {*--------------------------------------*}
    FileName := Button.Data.Exec;
    Ext := ExtractFileExt(FileName).ToLower;
  end
  else
  begin
    Button.Data.Exec := FileName;
    Button.Data.IconIndex := 0;
    Button.Data.Icon := FileName;
    Button.Data.WorkDir := ExtractFilePath(FileName);
    Button.Data.Params := '';
    Button.Data.Descr := '';
  end;
  //--Если исполняемый файл
  if IsExecutable(Ext) then
  begin
    Button.Data.LType := 0;
    if Button.Data.Descr = '' then
      Button.Data.Descr := GetFileDescription(FileName);
    if Button.Data.Descr = '' then
      Button.Data.Descr := ExtractFileNameNoExt(FileName);
  end
  else
  begin
    Button.Data.LType := 1;
    if Button.Data.Descr = '' then
      Button.Data.Descr := ExtractFileName(FileName);
  end;

  if IsPortable then
  begin
    Button.Data.Exec := PathToPortable(Button.Data.Exec);
    Button.Data.WorkDir := PathToPortable(Button.Data.WorkDir);
    Button.Data.Icon := PathToPortable(Button.Data.Icon);
  end;
  //--Рисуем иконки на кнопке
  Button.Data.AssignIcons;
  //--Перерисовываем кнопку
  Button.Repaint;
end;

procedure TFlaunchMainForm.FormActivate(Sender: TObject);
begin
  nowactive := Active;
end;

procedure TFlaunchMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := false;
  ChWinView(False);
end;

procedure TFlaunchMainForm.FormCreate(Sender: TObject);
begin
  FLVersion := GetAppVersion;

  //--Создаем список имен вкладок
  TabNames := TStringList.Create;
  //--Создаем экземпляр панели с кнопками
  FLPanel := TFLPanel.Create(MainTabsNew, 1);
  LaunchingButtons := TDictionary<Integer, TFLButton>.Create;
  ChPos := true;
  randomize;
  registerhotkey(Handle, HotKeyID, mod_control or mod_win, 0);

  InitEnvironment;
  MESettings().BugReportFile := fl_WorkDir + 'bugReport.mbr';

  if FileExists(fl_WorkDir + 'FLaunch.xml') then
  begin
    //--Читаем настройки кнопок
    LoadLinksSettings;
    //--Читаем иконки кнопок из кэша
    LoadLinksIconsFromCache;
  end
  else
  begin
    LoadIni;

    FLPanel.Padding := LPadding;
    FLPanel.ButtonWidth := ButtonWidth;
    FLPanel.ButtonHeight := ButtonHeight;
    FLPanel.RowsCount := RowsCount;
    FLPanel.ColsCount := ColsCount;

    GrowTabNames(TabsCount);
    MainTabsNew.TabIndex := tabind;

    LoadLinksCfgFile;
  end;

  FLPanel.PageNumber := MainTabsNew.TabIndex;

  Language.AddNotifier(LoadLanguage);
  Language.Load(lngfilename);
  //--Разрешаем/запрешаем автозагрузку
  SetAutorun(Autorun);
  {*--Связываем события панели--*}
  FLPanel.OnButtonMouseDown := FLPanelButtonMouseDown;
  FLPanel.OnButtonClick := FLPanelButtonClick;
  FLPanel.OnButtonMouseMove := FLPanelButtonMouseMove;
  FLPanel.OnButtonMouseLeave := FLPanelButtonMouseLeave;
  FLPanel.OnDropFile := FLPanelDropFile;
  FLPanel.ButtonsPopup := ButtonPopupMenu;
  SetTabNames;

  GenerateWnd;

  //--Разрешено перетаскивание файлов в окно FreeLaunch, когда он запущен с правами Администратора
  if TOSVersion.Check(6) then
  begin
    ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ADD);
    ChangeWindowMessageFilter (WM_COPYDATA, MSGFLT_ADD);
    ChangeWindowMessageFilter ($0049, MSGFLT_ADD);
  end;

  if not fileexists(fl_WorkDir + '.session') then
  begin
    //--Создаем файл, который будет идентифицировать сессию. При корректном завершении программы файл будет удален
    FileClose(FileCreate(fl_WorkDir + '.session'));
    SetFileAttributes(PChar(fl_WorkDir + '.session'), FILE_ATTRIBUTE_HIDDEN);
  end;
  TrayIcon.Hint := Format('%s %s',[cr_progname, FLVersion]);
  if not StartHide then
    ChWinView(True)
  else
    Application.ShowMainForm := False;
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
  ChPos := false;
end;

//--Событие при переключении вкладки
procedure TFlaunchMainForm.MainTabsNewChange(Sender: TObject);
begin
  //--Устанавливаем текущую страницу <- индекс вкладки
  FLPanel.PageNumber := MainTabsNew.TabIndex;
  MainTabsNew.SetFocus;
end;

//--Событие при отпускании перетягиваемого над вкладкой объекта
//--Изменение порядка вкладок с помощью Drag'N'Drop
procedure TFlaunchMainForm.MainTabsNewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: integer;
  Rect: TRect;
  TempStr: string;
begin
  //--Если перетягиваемый объект - вкладка
  if (Source is TTabControl) then
  begin
    //--Перебираем все вкладки
    for i := 0 to TabsCount - 1 do
    begin
      //--Определяем регион вкладки
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--Если найдена вкладка, над которой находится курсор
      if (PtInRect(Rect, Point(X, Y))) and (MainTabsNew.TabIndex <> i) then
      begin
        TempStr := TabNames.Strings[MainTabsNew.TabIndex];
        TabNames.Strings[MainTabsNew.TabIndex] := TabNames.Strings[i];
        TabNames.Strings[i] := TempStr;
        FLPanel.SwapData(MainTabsNew.TabIndex, i);
        SetTabNames;
        MainTabsNew.TabIndex := i;
        MainTabsNewChange(MainTabsNew);
      end;
    end;
  end;
end;

//--Событие при перетягивании над вкладкой объекта
procedure TFlaunchMainForm.MainTabsNewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  i: integer;
  Rect: TRect;
begin
  //--Если перетягиваемый объект - кнопка
  if (Source is TFLButton) then
  begin
    //--Если перетягиваемая кнопка активна, разрешаем Drop
    Accept := FLPanel.LastDraggedButton.IsActive;
    if not Accept then
      Exit;
    //--Перебираем все вкладки
    for i := 0 to TabsCount - 1 do
    begin
      //--Определяем регион вкладки
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--Если найдена вкладка, над которой находится курсор
      if (PtInRect(Rect, Point(X, Y))) and (MainTabsNew.TabIndex <> i) then
      begin
        MainTabsNew.TabIndex := i;
        MainTabsNewChange(MainTabsNew);
      end;
    end;
  end;
  if (Source is TTabControl) then
    Accept := true;
end;

//--Событие при нажатии кнопкой мыши по вкладке
procedure TFlaunchMainForm.MainTabsNewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  Rect: TRect;
  MousePos: TPoint;
begin
  if Button = mbLeft then
    if ssCtrl in Shift then
      MainTabsNew.BeginDrag(false);
  if Button = mbRight then
  begin
    //--Перебираем все вкладки
    for i := 0 to TabsCount - 1 do
    begin
      //--Определяем регион вкладки
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--Если найдена вкладка, над которой находится курсор
      if PtInRect(Rect, Point(X, Y)) then
      begin
        if MainTabsNew.TabIndex <> i then
          begin
            MainTabsNew.TabIndex := i;
            MainTabsNewChange(MainTabsNew);
          end;
        GetCursorPos(MousePos);
        TabPopupMenu.Popup(MousePos.X, MousePos.Y);
      end;
    end;
  end;
end;

procedure TFlaunchMainForm.MainTabsNewMouseLeave(Sender: TObject);
begin
  StatusBar.Panels[0].Text := '';
end;

procedure TFlaunchMainForm.NI_CloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

//--Экспортирование настроек кнопки в файл
procedure TFlaunchMainForm.ExportButton(Button: TFLButton; FileName: string);
var
  Strings: TStringList;
  Link: TLink;
begin
  Link := Button.DataToLink;
  Strings := TStringList.Create;
  try
    LinkToStrings(Link, Strings);
    Strings.SaveToFile(FileName);
  finally
    Strings.Free;
  end;
end;

//--Импортирование настроек кнопки из файла
procedure TFlaunchMainForm.ImportButton(Button: TFLButton; FileName: string);
var
  Strings: TStringList;
  Link: TLink;
begin
  Strings := TStringList.Create;
  try
    Strings.LoadFromFile(FileName);
    Link := StringsToLink(Strings);
  finally
    Strings.Free;
  end;

  Button.LinkToData(Link);
end;

function TFlaunchMainForm.IsTRCInRange(t, r, c: integer): boolean;
begin
  Result := (t >= 0) and (t < TabsCount) and (r >= 0) and (r < RowsCount) and (c >= 0) and (c < ColsCount);
end;

procedure TFlaunchMainForm.NI_AboutClick(Sender: TObject);
var
  frm: TAboutForm;
begin
  Application.CreateForm(TAboutForm, frm);
  frm.ShowModal;
end;

procedure TFlaunchMainForm.NI_SettingsClick(Sender: TObject);
var
  frm: TSettingsForm;
begin
  Application.CreateForm(TSettingsForm, frm);
  frm.ShowModal;
end;

procedure TFlaunchMainForm.NI_ShowClick(Sender: TObject);
begin
  ChWinView(true);
end;

end.
