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
  PaddingMax = 100;
  RowsCountMax = 100;
  ColsCountMax = 150;

  MultKey = 13574;
  AddKey = 46287;

  cr_progname = 'FreeLaunch';

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;

  TFlVer = record
    Major, Minor, Release, Build: string;
  end;

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
    ButtonPopupItem_RunAsAdmin: TMenuItem;
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
    procedure ButtonPopupItem_RunAsAdminClick(Sender: TObject);
  private
    //--Список имен вкладок
    TabNames: TStringList;
    GHAtom: Word;
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
    procedure LaunchButton(AButton: TFLButton; ADroppedFile: string = ''; RunAsAdmin: Boolean = False);
    procedure ImportButton(Button: TFLButton; FileName: string);
    procedure ExportButton(Button: TFLButton; FileName: string);
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
    /// <summary> Считывание настроек из xml-файла </summary>
    procedure LoadSettings;
    /// <summary> Функция определяет, находятся ли координаты t,r,c в пределах
    /// текущего размера панели </summary>
    function IsTRCInRange(t, r, c: integer): boolean;
    /// <summary> Сохранение настроек в xml-файл </summary>
    procedure SaveLinksSettings;
    /// <summary> Считывание иконок кнопок из кэша </summary>
    procedure LoadLinksIconsFromCache;
    /// <summary> Сохранение иконок кнопок в кэш </summary>
    procedure SaveLinksIconsToCache;
    /// setting app theme by index
    procedure SetAppThemeByIndex(AIndex: Integer);
  public
    FLPanel: TFLPanel;
    //--Количество вкладок
    //--Ширина и высота кнопок
    procedure EndWork;
    procedure ChangeWndSize;
    procedure GenerateWnd;
    procedure LoadLanguage;
    procedure LaunchHelpFile;
    function DefNameOfTab(tn: string): boolean;
    procedure SetAutorun(b: boolean);
    function GetAppVersion: TFlVer;
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
  nowactive:       Boolean;
  ABlend:          Boolean = False;
  aboutshowing:    Boolean = False;
  AlwaysOnTop:     Boolean = False;
  Autorun:         Boolean = False;
  ChPos:           Boolean = True;
  defdrop:         Boolean = False;
  deletelnk:       Boolean = False;
  dtimeinstbar:    Boolean = False;
  hideafterlaunch: Boolean = False;
  queryonlaunch:   Boolean = False;
  rwar:            Boolean = False;
  settingsshowing: Boolean = False;
  starthide:       Boolean = False;
  ClearONF:        Boolean = True;
  nobgnotabs:      Boolean = True;
  statusbarvis:    Boolean = True;
  PropertiesMode:  Integer; //Переменная содержит тип кнопки, свойства которой редактируются в данный момент
  FocusCol:        Integer = -1;
  FocusRow:        Integer = -1;
  FocusTab:        Integer = -1;
  GlobCol:         Integer = -1;
  GlobRow:         Integer = -1;
  GlobTab:         Integer = -1;
  GlobTabNum:      Integer = -1;
  CurrAppTheme:    Integer = 0;
  lotabinsettings: Integer = 0;
  PriorDef:        Integer = 0;
  tabind:          Integer = 0;
  tabsview:        Integer = 0;
  titlebar:        Integer = 0;
  TopPer:          Integer = 0;
  WStateDef:       Integer = 0;
  lpadding:        Integer = 1;
  rowscount:       Integer = 2;
  TabsCount:       Integer = 3;
  TabsFontSize:    Integer = 8;
  colscount:       Integer = 10;
  ButtonHeight:    Integer = 32;
  ButtonWidth:     Integer = 32;
  LeftPer:         Integer = 100;
  ABlendVal:       Integer = 255;
  lngfilename:     string = '';
  TabsFontName:    string = 'Tahoma';
  FlVer:           TFlVer;
  templinks:       link;
  links:           array[0..maxt - 1] of link;
  Nim:             TNotifyIconData;
  FlaunchMainForm: TFlaunchMainForm;

implementation

{$R *.dfm}

uses
  Xml.XMLDoc, Xml.XMLIntf,
  Vcl.Imaging.pngimage,
  System.IOUtils, System.Math;

var
  LaunchID: Integer = 0;

//getting app version from executable file of freelaunch
function TFlaunchMainForm.GetAppVersion: TFlVer;
var
  Dummy, VInfoSize, VValueSize: DWORD;
  VInfo: Pointer;
  VValue: PVSFixedFileInfo;
begin
  Result.Major := '';
  Result.Minor := '';
  Result.Release := '';
  Result.Build := '';
  VInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VInfoSize > 0 then begin
    GetMem(VInfo, VInfoSize);
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), 0, VInfoSize, VInfo) then begin
        VerQueryValue(VInfo, '\', Pointer(VValue), VValueSize);
        Result.Major := IntToStr(VValue^.dwFileVersionMS shr $10);
        Result.Minor := IntToStr(VValue^.dwFileVersionMS and $FFF);
        Result.Release := IntToStr(VValue^.dwFileVersionLS shr $10);
        Result.Build := IntToStr(VValue^.dwFileVersionLS and $FFFF)
      end;
    finally
      FreeMem(VInfo, VInfoSize);
    end;
  end;
end;

//convert window position from pixels to percent
function TFlaunchMainForm.PositionToPercent(p: integer; iswidth: boolean): integer;
begin
  if iswidth then
    result := round(p / (Screen.DesktopWidth - Width) * 100)
  else
    result := round(p / (Screen.DesktopHeight - Height) * 100);
end;

//convert window position from percent to pixels
function TFlaunchMainForm.PercentToPosition(p: integer; iswidth: boolean): integer;
begin
  if iswidth then
    result := round(p * (Screen.DesktopWidth - Width) / 100)
  else
    result := round(p * (Screen.DesktopHeight - Height) / 100);
end;

//reload icons
procedure TFlaunchMainForm.ReloadIcons;
var
  t, r, c: Integer;
begin
  for t := 0 to TabsCount - 1 do
    for r := 0 to RowsCount - 1 do
      for c := 0 to ColsCount - 1 do
        if FLPanel.Buttons[t,r,c].IsActive then
        begin
          if not FileExists(FLPanel.Buttons[t,r,c].Data.Exec) and ClearONF
            then FLPanel.Buttons[t,r,c].FreeData
            else FLPanel.Buttons[t,r,c].Data.AssignIcons;
          FLPanel.Buttons[t,r,c].Repaint;
        end;
  FLPanel.PageNumber := MainTabsNew.TabIndex;
end;

//rename tab window
procedure TFlaunchMainForm.RenameTab(i: integer);
begin
  MainTabsNew.Tabs.Strings[i] :=
    TRenameTabForm.Execute(MainTabsNew.Tabs.Strings[i]);
  TabNames[i] := MainTabsNew.Tabs.Strings[i];
end;

//load localization
procedure TFlaunchMainForm.LoadLanguage;
begin
  Caption := cr_progname;
  NI_Show.Caption := Language.Menu.Show;
  NI_Settings.Caption := Language.Menu.Settings;
  NI_About.Caption := Language.Menu.About;
  NI_Close.Caption := Language.Menu.Close;
  ButtonPopupItem_Run.Caption := Language.Menu.Run;
  ButtonPopupItem_RunAsAdmin.Caption := Language.Menu.RunAsAdmin;
  ButtonPopupItem_TypeProgramm.Caption := Language.Menu.TypeProgramm;
  ButtonPopupItem_TypeFile.Caption := Language.Menu.TypeFile;
  ButtonPopupItem_Export.Caption := Language.Menu.ExportBtn;
  ButtonPopupItem_Import.Caption := Language.Menu.Import;
  ButtonPopupItem_Clear.Caption := Language.Menu.Clear;
  ButtonPopupItem_Props.Caption := Language.Menu.Prop;
  SaveButtonDialog.Filter := Language.FlbFilter + '|*.flb';
  OpenButtonDialog.Filter := Language.FlbFilter + '|*.flb';
  TabPopupItem_Rename.Caption := Language.Menu.Rename;
  TabPopupItem_Clear.Caption := Language.Menu.ClearTab;
  TabPopupItem_Delete.Caption := Language.Menu.DeleteTab;
end;

procedure TFlaunchMainForm.LaunchHelpFile;
var
  AHelpFile: string;
begin
  AHelpFile := ExtractFilePath(ParamStr(0)) + 'help\' + Language.Main.HelpFile;
  if FileExists(AHelpFile)
    then ExecHelpFile(Handle, AHelpFile);
end;

//autostart with Windows
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
  if not RequestMessage(Handle, format(Language.Messages.DeleteTab,
      [MainTabsNew.Tabs[i]])) = IDYES
    then Exit;
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
  if not RequestMessage(Handle, format(Language.Messages.ClearTab,
      [MainTabsNew.Tabs[MainTabsNew.TabIndex]])) = IDYES
    then Exit;
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
  if StatusBar.Panels.Count = 1
  then begin
    StatusBar.Panels.Add;
    StatusBar.Panels[1].Alignment := taCenter;
    GenerateWnd;
  end;
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TFlaunchMainForm.ChWinView(b: boolean);
begin
  if b then
    begin
      Visible := true;
      Timer1.Enabled := statusbarvis and dtimeinstbar;
      ShowWindow(Application.Handle, SW_HIDE);
      SetForegroundWindow(Application.Handle);
    end
  else
    begin
      Visible := false;
      Timer1.Enabled := False;
    end;
  if (dtimeinstbar = False) and (StatusBar.Panels.Count > 1)
    then StatusBar.Panels.Delete(1);
end;

procedure TFlaunchMainForm.TrayIconClick(Sender: TObject);
begin
  ChWinView((not nowactive) or not (Showing));
end;

procedure TFlaunchMainForm.LaunchButton(AButton: TFLButton;
  ADroppedFile: string; RunAsAdmin: Boolean);
var
  tempexec: string;
  TempLink: TLink;
begin
  Inc(LaunchID);
  LaunchingButtons.Add(LaunchID, AButton);
  TempLink := AButton.DataToLink;
  TempLink.AsAdminPerm := RunAsAdmin;
  tempexec := StringReplace(TempLink.exec, '%FL_ROOT%\', fl_root,
    [rfReplaceAll, rfIgnoreCase]);
  tempexec := StringReplace(tempexec, '%FL_DIR%\', fl_dir,
    [rfReplaceAll, rfIgnoreCase]);
  if not FileExists(tempexec)
      and (not DirectoryExists(tempexec))
    then begin
      if RequestMessage(Handle,
          Format(Language.Messages.NotFound, [TempLink.exec])) = IDYES
        then AButton.FreeData;
    end else
      NewProcess(TempLink, Handle, LaunchID, ADroppedFile);
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
  WindowNode.AddChild('AlphaBlend').NodeValue := ABlend;
  WindowNode.AddChild('AlphaBlendValue').NodeValue := ABlendVal;
  WindowNode.AddChild('AlwaysOnTop').NodeValue := alwaysontop;
  WindowNode.AddChild('StatusBar').NodeValue := statusbarvis;
  WindowNode.AddChild('DateTimeInStatusBar').NodeValue := dtimeinstbar;
  WindowNode.AddChild('StartHidden').NodeValue := starthide;
  WindowNode.AddChild('HideAfterLaunchBtn').NodeValue := hideafterlaunch;
  WindowNode.AddChild('QueryOnLaunchBtn').NodeValue := queryonlaunch;
  WindowNode.AddChild('RunBtnAsAdmin').NodeValue := rwar;
  WindowNode.AddChild('DeleteLNK').NodeValue := deletelnk;
  WindowNode.AddChild('DefAcceptDropFiles').NodeValue := defdrop;
  WindowNode.AddChild('DefWinState').NodeValue := WStateDef;
  WindowNode.AddChild('DefPriority').NodeValue := PriorDef;
  WindowNode.AddChild('GlassWhenNoTabs').NodeValue := nobgnotabs;
  WindowNode.AddChild('ClearBtnIfONF').NodeValue := ClearONF;
  WindowNode.AddChild('CurrentThemeID').NodeValue := CurrAppTheme;
  WindowNode.AddChild('LastTabInSettings').NodeValue := lotabinsettings;

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
  try
    XMLDocument.SaveToFile(fl_WorkDir + 'FLaunch.xml');
  except
    {do nothing}
  end;
  if XMLDocument.Active then XMLDocument.Active := false;
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

procedure TFlaunchMainForm.LoadSettings;
var
  gtabscount, gthemeid: Boolean;

  RootNode, WindowsNode, WindowNode, PositionNode, TabRootNode, TabFontNode,
  LinkNode, IconNode, TabNode, IconsNode,
  PanelRootNode, PanelNode, DropNode: IXMLNode;
  TabNumber, Row, Column: Integer;
  TempData: TFLDataItem;
  XMLDocument: IXMLDocument;

  function GetStr(AParent: IXMLNode; AChild: string;
    DefValue: string = ''): string;
  var
    Child: IXMLNode;
  begin
    Result := DefValue;
    Child := AParent.ChildNodes.FindNode(AChild);
    if Assigned(Child) and Child.IsTextElement
      then Result := Child.Text;
  end;

  function GetInt(AParent: IXMLNode; AChild: string;
    DefValue: Integer = 0): Integer;
  var
    Child: IXMLNode;
  begin
    Result := DefValue;
    Child := AParent.ChildNodes.FindNode(AChild);
    if Assigned(Child) and (Child.NodeValue <> NULL)
      then Result := Child.NodeValue;
  end;

  function GetBool(AParent: IXMLNode; AChildName: string;
    DefValue: Boolean = False): Boolean;
  var
    Child: IXMLNode;
  begin
    Result := DefValue;
    Child := AParent.ChildNodes.FindNode(AChildName);
    if Assigned(Child) and (Child.NodeValue <> NULL) then
      Result := Child.NodeValue;
  end;

  function LimitInt(AInt, AMin, AMax: Integer): Integer;
  begin
    Result := Min(Max(AInt, AMin), AMax);
  end;

  function ToMinInt(AInt, AMin, AMax: Integer): Integer;
  begin
    Result := AInt;
    if not (AInt in [Max(AMin, 0)..Min(AMax, 255)]) then Result := AMin;
  end;

  function ToMaxInt(AInt, AMin, AMax: Integer): Integer;
  begin
    Result := AInt;
    if not (AInt in [Max(AMin, 0)..Min(AMax, 255)]) then Result := AMax;
  end;

  procedure SetSettings;
  var
    I: Integer;
  begin
    if not gthemeid then CurrAppTheme := GetAppThemeIndex(GetAppTheme);
    MainTabsNew.Font.Name := TabsFontName;
    MainTabsNew.Font.Size := TabsFontSize;
    if not gtabscount then begin
      TabsCount := 3;
      GrowTabNames(TabsCount);
      for I := 1 to TabsCount
        do TabNames[I - 1] := '';
    end;
    MainTabsNew.TabIndex := tabind;
    FLPanel.ColsCount := colscount;
    FLPanel.RowsCount := rowscount;
    FLPanel.ButtonHeight := ButtonHeight;
    FLPanel.ButtonHeight := ButtonHeight;
    FLPanel.Padding := lpadding;
  end;

begin
  gtabscount := False;
  gthemeid := False;
  if not FileExists(fl_WorkDir + 'FLaunch.xml') then begin
    SetSettings;
    Exit;
  end;
  XMLDocument := TXMLDocument.Create(Self);
  XMLDocument.Options := [doNodeAutoIndent];
  XMLDocument.Active := True;
  try
    XMLDocument.LoadFromFile(fl_WorkDir + 'FLaunch.xml');
  except
    // if settings XML file is corrupted
    SetSettings;
    if XMLDocument.Active then XMLDocument.Active := False;
    Exit;
  end;
  try
    //root node
    RootNode := XMLDocument.ChildNodes.FindNode('FLaunch');
    if Assigned(RootNode) and RootNode.HasChildNodes then begin
      Autorun := GetBool(RootNode, 'AutoRun');
      lngfilename := GetStr(RootNode, 'Language');
      //windows node
      WindowsNode := RootNode.ChildNodes.FindNode('Windows');
      if Assigned(WindowsNode) and WindowsNode.HasChildNodes then begin
        //window node
        WindowNode := WindowsNode.ChildNodes.FindNode('Window');
        if Assigned(WindowNode) and WindowNode.HasChildNodes then begin
          ABlend := GetBool(WindowNode, 'AlphaBlend');
          ABlendVal := ToMaxInt(GetInt(WindowNode, 'AlphaBlendValue', 255),
            26, 255);
          alwaysontop := GetBool(WindowNode, 'AlwaysOnTop');
          ClearONF := GetBool(WindowNode, 'ClearBtnIfONF', True);
          gthemeid := not (GetStr(WindowNode, 'CurrentThemeID') = '');
          if gthemeid
            then CurrAppTheme := ToMinInt(GetInt(WindowNode, 'CurrentThemeID'),
              Low(FLThemes), High(FLThemes));
          dtimeinstbar := GetBool(WindowNode, 'DateTimeInStatusBar');
          defdrop := GetBool(WindowNode, 'DefAcceptDropFiles');
          PriorDef := ToMinInt(GetInt(WindowNode, 'DefPriority'), 0, 5);
          WStateDef := ToMinInt(GetInt(WindowNode, 'DefWinState'), 0, 3);
          deletelnk := GetBool(WindowNode, 'DeleteLNK');
          nobgnotabs := GetBool(WindowNode, 'GlassWhenNoTabs', True);
          hideafterlaunch := GetBool(WindowNode, 'HideAfterLaunchBtn');
          lotabinsettings := GetInt(WindowNode, 'LastTabInSettings');
          //position node
          PositionNode := WindowNode.ChildNodes.FindNode('Position');
          if Assigned(PositionNode) and PositionNode.HasChildNodes then begin
            LeftPer := LimitInt(GetInt(PositionNode, 'Left', 100), 0, 100);
            TopPer := LimitInt(GetInt(PositionNode, 'Top'), 0, 100);
          end;
          //position node end
          queryonlaunch := GetBool(WindowNode, 'QueryOnLaunchBtn');
          rwar := GetBool(WindowNode, 'RunBtnAsAdmin');
          starthide := GetBool(WindowNode, 'StartHidden');
          statusbarvis := GetBool(WindowNode, 'StatusBar', True);
          //tabs node
          TabRootNode := WindowNode.ChildNodes.FindNode('Tabs');
          if Assigned(TabRootNode) and TabRootNode.HasChildNodes then begin
            TabNumber := 0;
            TabsCount := 0;
            tabind := ToMinInt(GetInt(TabRootNode, 'ActiveTab'), 0,
              TabsCountMax) - 1;
            TabNames.Clear;
            //font node
            TabFontNode := TabRootNode.ChildNodes.FindNode('Font');
            if Assigned(TabFontNode) and TabFontNode.HasChildNodes then begin
              TabsFontName := GetStr(TabFontNode, 'Name', 'Tahoma');
              TabsFontSize := LimitInt(GetInt(TabFontNode, 'Size', 8), 1,
                MaxInt);
            end;
            //font node end
            //tab N node
            TabNode := TabRootNode.ChildNodes.FindNode('Tab');
            while Assigned(TabNode) and TabNode.HasChildNodes do begin
              gtabscount := True;
              Inc(TabsCount);
              TabNumber := TabNode.Attributes['Number'];
              GrowTabNames(TabNumber);
              TabNames.Strings[TabNumber - 1] := GetStr(TabNode, 'Name');
              TabNode := TabNode.NextSibling;
            end;
            GrowTabNames(TabNumber);
            //tab N node end
            tabsview := ToMinInt(GetInt(TabRootNode, 'View'), 0, 2);
          end;
          //tabs node end
          titlebar := ToMinInt(GetInt(WindowNode, 'TitleBar'), 0, 2);
        end;
      end;
      //windows node end
      //panels node
      PanelRootNode := RootNode.ChildNodes.FindNode('Panels');
      if Assigned(PanelRootNode) and PanelRootNode.HasChildNodes then begin
        //panel N node
        //where is tabnumber value?
        PanelNode := PanelRootNode.ChildNodes.First;
        for TabNumber := 0 to TabsCount - 1 do begin
          if Assigned(PanelNode) and PanelNode.HasChildNodes then begin
            colscount := ToMaxInt(GetInt(PanelNode, 'ColsCount', 10), 0,
              ColsCountMax);
            rowscount := ToMaxInt(GetInt(PanelNode, 'Rows', 2), 0,
              RowsCountMax);
            //icons node
            lpadding := LimitInt(GetInt(PanelNode, 'Padding', 1), 0,
              PaddingMax);
            IconsNode := PanelNode.ChildNodes.FindNode('Icons');
            if Assigned(IconsNode) and IconsNode.HasChildNodes then begin
              ButtonHeight := LimitInt(GetInt(IconsNode, 'Height', 32),
               16, 256);
              ButtonWidth := LimitInt(GetInt(IconsNode, 'Width', 32), 16, 256);
            end;
            //icons node end
            //link node
            LinkNode := PanelNode.ChildNodes.FindNode('Link');
            while Assigned(LinkNode) and LinkNode.HasChildNodes do begin
              Column := GetInt(LinkNode, 'Column') - 1;
              Row := GetInt(LinkNode, 'Row') - 1;
              if not IsTRCInRange(TabNumber, Row, Column) then Continue;
              TempData :=
                FLPanel.Buttons[TabNumber, Row, Column].InitializeData;
              TempData.LType := GetInt(LinkNode, 'Type');
              TempData.Exec := GetStr(LinkNode, 'Execute');
              TempData.WorkDir := GetStr(LinkNode, 'WorkingDir');
              //link icon node
              IconNode := LinkNode.ChildNodes.FindNode('Icon');
              if Assigned(IconNode) and IconNode.HasChildNodes then begin
                TempData.Icon := GetStr(IconNode, 'File');
                TempData.IconIndex := GetInt(IconNode, 'Index');
                TempData.IconCache := GetStr(IconNode, 'Cache');
              end;
              //link icon node end
              TempData.Params := GetStr(LinkNode, 'Parameters');
              //link drop node
              DropNode := LinkNode.ChildNodes.FindNode('Drop');
              if Assigned(DropNode) and DropNode.HasChildNodes then begin
                TempData.DropFiles := GetBool(DropNode, 'Allow');
                TempData.DropParams := GetStr(DropNode, 'Parameters');
              end;
              //link drop node end
              TempData.Descr := GetStr(LinkNode, 'Description');
              TempData.Ques := GetBool(LinkNode, 'NeedQuestion');
              TempData.Hide := GetBool(LinkNode, 'HideContainer');
              TempData.Pr := GetInt(LinkNode, 'Priority');
              TempData.WSt := GetInt(LinkNode, 'WindowState');
              TempData.IsAdmin := GetBool(LinkNode, 'RequireAdmin');
              TempData.AssignIcons;
              LinkNode := LinkNode.NextSibling;
            end;
            //link node end
            PanelNode := PanelNode.NextSibling;
          end;
        end;
        //panel N node end
      end;
      //panels node end
    end;
    //root node end
    SetSettings;
  except
    SetSettings;
    if XMLDocument.Active then XMLDocument.Active := False;
  end;
end;

procedure TFlaunchMainForm.WMHotKey(var Msg: TWMHotKey);
begin
  if Msg.Msg = WM_HOTKEY then
    begin
      if Msg.HotKey = GHAtom then
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
  UnregisterHotKey(Handle, GHAtom);
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
  if key = VK_F1 then LaunchHelpFile;
  if key = VK_F2 then RenameTab(MainTabsNew.TabIndex);
end;

procedure TFlaunchMainForm.ButtonPopupItem_ClearClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;
  if RequestMessage(Handle, Format(Language.Messages.DeleteButton,
      [ExtractFileName(TempButton.Data.Exec)])) = IDYES
    then TempButton.FreeData;
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

procedure TFlaunchMainForm.ButtonPopupItem_RunAsAdminClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.Highlight;
  if not TempButton.IsActive
    then Exit;
  LaunchButton(TempButton, '', True);
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
  SetAppThemeByIndex(CurrAppTheme);
  if TabsCount > 1 then begin
    MainTabsNew.Show;
    TabInternalRect := MainTabsNew.DisplayRect;
    FLPanel.Parent := MainTabsNew;
    FLPanel.Left := TabInternalRect.Left;
    FLPanel.Top := TabInternalRect.Top;
    FLPanel.DoubleBuffered := True;
    GlassFrame.Enabled := False;
    MainTabsNew.Width := MainTabsNew.Width + FLPanel.Width -
        TabInternalRect.Width;
    MainTabsNew.Height := MainTabsNew.Height + FLPanel.Height -
        TabInternalRect.Height;
    MainTabsNew.TabIndex := FLPanel.PageNumber;
    MainHeight := MainTabsNew.Height;
    MainWidth := MainTabsNew.Width;
  end else begin
    FLPanel.Parent := Self;
    MainTabsNew.Hide;
    FLPanel.Left := 0;
    FLPanel.Top := 0;
    FLPanel.DoubleBuffered := not nobgnotabs;
    GlassFrame.Enabled := nobgnotabs;
    MainHeight := FLPanel.Height;
    MainWidth := FLPanel.Width;
  end;
  //--Позволяем перетягивать файлы на кнопку
  DragAcceptFiles(FLPanel.Handle, True);
  StatusBar.Top := MainHeight + 1;
  StatusBar.Width := MainWidth;
  if StatusBar.Panels.Count > 1 then begin
    StatusBar.Panels[1].Width :=
      StatusBar.Canvas.TextWidth(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now)
      + Space + Space + Space + Space);
    StatusBar.Height := 2 *
      StatusBar.Canvas.TextHeight(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now));
    StatusBar.Panels[0].Width := StatusBar.Width - StatusBar.Panels[1].Width;
  end else StatusBar.Panels[0].Width := StatusBar.Width;
  ClientWidth := MainWidth;
  if statusbarvis
    then ClientHeight := MainHeight + StatusBar.Height
    else ClientHeight := MainHeight;
  Left := PercentToPosition(LeftPer, true);
  Top := PercentToPosition(TopPer, false);
  AlphaBlend := ABlend;
  AlphaBlendValue := ABlendVal;
  //fix for change panel size without app restart
  FLPanel.ButtonsPopup := ButtonPopupMenu;
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
  if AlwaysOnTop then FormStyle := fsStayOnTop;
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
    ButtonPopupItem_RunAsAdmin.Enabled := Button.IsActive;
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
    if not RequestMessage(Handle, Language.Messages.BusyReplace) = IDYES
      then Exit;
  end;
  Ext := ExtractFileExt(FileName).ToLower;
  //--Если был перетянут файл кнопки
  if Ext = '.flb' then
  begin
    Button.Highlight;
    if RequestMessage(Handle,
        format(Language.Messages.ImportButton,[FileName])) = IDYES
      then ImportButton(Button, FileName);
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
    //need to delete filename here
    if FileExists(FileName) and deletelnk then
      try
        DeleteFile(FileName);
      finally
        //do nothing
      end;
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
  Button.Data.Hide := hideafterlaunch;
  Button.Data.Ques := queryonlaunch;
  Button.Data.WSt := WStateDef;
  Button.Data.IsAdmin := rwar;
  Button.Data.DropFiles := defdrop;
  Button.Data.Pr := PriorDef;
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

procedure TFlaunchMainForm.SetAppThemeByIndex(AIndex: Integer);
begin
  UnregisterHotKey(Handle, GHAtom);
  if AIndex in [Low(FLThemes)..High(FLThemes)]
    then SetAppTheme(FLThemes[AIndex].Name)
    else SetAppTheme(FLThemes[0].Name);
  GHAtom := GlobalAddAtom('FL_Hotkey');
  RegisterHotKey(Handle, GHAtom, MOD_CONTROL or MOD_WIN, 0);
end;

procedure TFlaunchMainForm.FormCreate(Sender: TObject);
begin
  //get app version
  FlVer := GetAppVersion;
  FLVersion := FlVer.Major + '.' + FlVer.Minor + '.' + FlVer.Release + '.'
    + FlVer.Build;
  //--Создаем список имен вкладок
  TabNames := TStringList.Create;
  //--Создаем экземпляр панели с кнопками
  FLPanel := TFLPanel.Create(MainTabsNew, 1);
  LaunchingButtons := TDictionary<Integer, TFLButton>.Create;
  Randomize;
  //initialize environment variables
  InitEnvironment;
  //initialize bugreport file
  MESettings().BugReportFile := fl_WorkDir + 'bugReport.mbr';
  //loading settings
  LoadSettings;
  LoadLinksIconsFromCache;
  FLPanel.PageNumber := MainTabsNew.TabIndex;
  if not FileExists(ExtractFilePath(ParamStr(0)) + 'languages\' + lngfilename)
  then lngfilename := FindSysUserDefLangFile;
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
  SetTabNames;
  GenerateWnd;
  //--Разрешено перетаскивание файлов в окно FreeLaunch, когда он запущен с правами Администратора
  ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
  ChangeWindowMessageFilter(WM_COPYDATA, MSGFLT_ADD);
  ChangeWindowMessageFilter(WM_COPYGLOBALDATA, MSGFLT_ADD);
  if not fileexists(fl_WorkDir + '.session') then
  begin
    //--Создаем файл, который будет идентифицировать сессию. При корректном завершении программы файл будет удален
    FileClose(FileCreate(fl_WorkDir + '.session'));
    SetFileAttributes(PChar(fl_WorkDir + '.session'), FILE_ATTRIBUTE_HIDDEN);
  end;
  TrayIcon.Hint := cr_progname;
  if not StartHide then ChWinView(True) else Application.ShowMainForm := False;
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

function TFlaunchMainForm.IsTRCInRange(t, r, c: integer): Boolean;
begin
  Result := (t >= 0) and (t < TabsCount) and (r >= 0) and (r < RowsCount)
    and (c >= 0) and (c < ColsCount);
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
