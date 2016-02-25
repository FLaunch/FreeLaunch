{
  ##########################################################################
  #  FreeLaunch 2.0 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2010 Joker-jar                                          #
  #  E-Mail joker-jar@yandex.ru                                            #
  #  WEB http://sourceforge.net/projects/freelaunch                        #
  #  ====================================================================  #
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

{$DEFINE NIGHTBUILD}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ShellApi, Menus, Types, PanelClass,
  ComObj, ActiveX, ShlObj, IniFiles, Registry, Shfolder, ExceptionLog7,
  ProgrammPropertiesFormModule, FilePropertiesFormModule, RenameTabFormModule,
  SettingsFormModule, AboutFormModule, FLFunctions, FLLanguage;

const
  TCM_GETITEMRECT = $130A;
  HotKeyID = 27071987;

  inisection = 'general';

  mint = 1;
  minr = 1;
  minc = 1;
  minp = 1;

  maxt = 8;
  maxr = 5;
  maxc = 15;
  maxp = 5;

  panelzoom = 4;

  MultKey = 13574;
  AddKey = 46287;

  version = '2.0 beta 1';
  dev_version = '2.0.xxx beta'; // xxx is revision number, may be replaced
  releasedate = '__BUILDDATE__'; // build date in dd-mm-yyyy format

  cr_wmr = 'R273772850462';
  cr_wmz = 'Z234078607788';
  cr_author = 'Joker-jar';
  cr_authormail = 'joker-jar@yandex.ru';
  cr_progname = 'FreeLaunch';

  DesignDPI = 96;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;

  lnk = record
    ltype: byte;
    active: boolean;
    exec: string;
    workdir: string;
    icon: string;
    iconindex: integer;
    params: string;
    dropfiles: boolean;
    dropparams: string;
    descr: string;
    ques: boolean;
    hide: boolean;
    pr: byte;
    wst: byte;
  end;

  link = array[0..maxr - 1,0..maxc - 1] of lnk;
  panel = array[0..maxr - 1,0..maxc - 1] of TMyPanel;

  TFlaunchMainForm = class(TForm)
    StatusBar: TStatusBar;
    PopupMenu: TPopupMenu;
    NI_prop: TMenuItem;
    NI_Clear: TMenuItem;
    MainTabs: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    GroupPanel1: TPanel;
    GroupPanel2: TPanel;
    GroupPanel3: TPanel;
    GroupPanel4: TPanel;
    GroupPanel5: TPanel;
    GroupPanel6: TPanel;
    GroupPanel7: TPanel;
    GroupPanel8: TPanel;
    NI_Run: TMenuItem;
    NI_L1: TMenuItem;
    NI_L2: TMenuItem;
    TrayMenu: TPopupMenu;
    NI_Close: TMenuItem;
    PagesMenu: TPopupMenu;
    NI_Rename: TMenuItem;
    NI_DeleteTab: TMenuItem;
    NI_Settings: TMenuItem;
    NI_Show: TMenuItem;
    NI_ClearTab: TMenuItem;
    NI_L3: TMenuItem;
    NI_L4: TMenuItem;
    NI_Group: TMenuItem;
    Timer1: TTimer;
    NI_L5: TMenuItem;
    NI_About: TMenuItem;
    NI_L7: TMenuItem;
    NI_Export: TMenuItem;
    NI_Import: TMenuItem;
    SaveButtonDialog: TSaveDialog;
    OpenButtonDialog: TOpenDialog;
    NI_TypeProgramm: TMenuItem;
    N1: TMenuItem;
    NI_TypeFile: TMenuItem;
    TrayIcon: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure MainTabsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure NI_propClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NI_ClearClick(Sender: TObject);
    procedure NI_CloseClick(Sender: TObject);
    procedure NI_RunClick(Sender: TObject);
    procedure MainTabsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MainTabsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure NI_RenameClick(Sender: TObject);
    procedure NI_DeleteTabClick(Sender: TObject);
    procedure NI_ShowClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NI_ClearTabClick(Sender: TObject);
    procedure NI_GroupClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure NI_AboutClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure NI_SaveClick(Sender: TObject);
    procedure NI_ExportClick(Sender: TObject);
    procedure NI_ImportClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure NI_TypeProgrammClick(Sender: TObject);
    procedure NI_TypeFileClick(Sender: TObject);
    procedure NI_SettingsClick(Sender: TObject);
    procedure TrayMenuPopup(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure WMDisplayChange(var Msg: TWMDisplayChange); message WM_DISPLAYCHANGE;
    procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;

    procedure LoadLinksFromCash;
    procedure LoadPanelLinks(Index: integer);
    procedure ClearLinks(Index: integer);
    procedure ImportButton(filename: string; t,r,c: integer);
    function LoadCfgFileString(AFileHandle: THandle; ALength: Integer = 0): string;
    function LoadLinksCfgFileV121_12_11: boolean;
    function LoadLinksCfgFileV10: boolean;
    function LoadLinksCfgFile: boolean;
    procedure GetCoordinates(Sender: TObject; var t: integer; var r: integer; var c: integer);
    procedure DropExecProgram(FileName: string; t,r,c: integer; fromlnk: boolean);
    procedure DropFileFolder(FileName: string; t,r,c: integer; fromlnk: boolean);
    function ConfirmDialog(Msg, Title: string): Boolean;
  public
    procedure EndWork;
    procedure ChangeWndSize;
    procedure GenerateWnd;
    procedure CreatePanel(PanelIndex: integer);
    procedure DestroyPanel(PanelIndex: integer);
    procedure PanelDragFile(Sender: TObject; FileName: string);
    procedure PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PanelClick(Sender: TObject);
    procedure PanelSetFocus(Sender: TObject);
    procedure PanelKillFocus(Sender: TObject);
    procedure PanelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseLeave(Sender: TObject);
    procedure LoadLanguage;
    function DefNameOfTab(tn: string): boolean;
    procedure SetAutorun(b: boolean);
    procedure LoadIni;
    procedure SaveIni;
    function PositionToPercent(p: integer; iswidth: boolean): integer;
    function PercentToPosition(p: integer; iswidth: boolean): integer;
    function GetFLVersion: string;
    procedure LoadIc(t, r, c: integer);
    function GetAbsolutePath(s: string): string;
    procedure LoadLinks;
    procedure LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
    procedure SaveCfgFileString(AFileHandle: THandle; AString: string;
      AWriteLength: Boolean = True);
    procedure SaveLinksCfgFile;
    procedure SaveLinksToCash;
    procedure ChWinView(b: boolean);
  end;

var
  FlaunchMainForm: TFlaunchMainForm;
  SettingsMode: byte; //Режим работы (0 - инсталляция, настройки хранятся в APPDATA; 1 - инсталляция, настройки хранятся в папке программы; 2 - портабельный режим, инсталляция, настройки хранятся в папке программы)
  PropertiesMode: integer; //Переменная содержит тип кнопки, свойства которой редактируются в данный момент
  iconwidth, iconheight, tabscount, rowscount, colscount, lpadding, tabind, LeftPer, TopPer, CurScrW, CurScrH: integer;
  templinks: link;
  links: array[0..maxt - 1] of link;
  panels: array[0..maxt - 1] of panel;
  GlobParam: string;
  GlobTab: integer = -1;
  GlobRow: integer = -1;
  GlobCol: integer = -1;
  FocusTab: integer = -1;
  FocusRow: integer = -1;
  FocusCol: integer = -1;
  GlobTabNum: integer = -1;
  Nim: TNotifyIconData;
  Ini: TIniFile;
  Autorun, AlwaysOnTop, nowactive, starthide, aboutshowing, settingsshowing, statusbarvis, altlinkscolor, altformscolor: boolean;
  titlebar, tabsview: integer;
  PanelColor, FormColor: TColor;
  lngfilename: string;
  workdir, fl_root, fl_dir: string;
  ChPos: boolean = false;

implementation

{$R Manifest.res}
{$R png.res}
{$R *.dfm}

procedure ShellExecute(const AWnd: HWND; const AOperation, AFileName: String;
  const AParameters: String = ''; const ADirectory: String = ''; const AShowCmd: Integer = SW_SHOWNORMAL);
var
  ExecInfo: TShellExecuteInfo;
  NeedUninitialize: Boolean;
begin
  Assert(AFileName <> '');

  NeedUninitialize := SUCCEEDED(CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE));
  try
    FillChar(ExecInfo, SizeOf(ExecInfo), 0);
    ExecInfo.cbSize := SizeOf(ExecInfo);

    ExecInfo.Wnd := AWnd;
    ExecInfo.lpVerb := Pointer(AOperation);
    ExecInfo.lpFile := PChar(AFileName);
    ExecInfo.lpParameters := Pointer(AParameters);
    ExecInfo.lpDirectory := Pointer(ADirectory);
    ExecInfo.nShow := AShowCmd;
    ExecInfo.fMask := SEE_MASK_NOASYNC { = SEE_MASK_FLAG_DDEWAIT для старых версий Delphi }
                   or SEE_MASK_FLAG_NO_UI;
    {$IFDEF UNICODE}
    // Необязательно, см. http://www.transl-gunsmoker.ru/2015/01/what-does-SEEMASKUNICODE-flag-in-ShellExecuteEx-actually-do.html
    ExecInfo.fMask := ExecInfo.fMask or SEE_MASK_UNICODE;
    {$ENDIF}

    {$WARN SYMBOL_PLATFORM OFF}
    Win32Check(ShellExecuteEx(@ExecInfo));
    {$WARN SYMBOL_PLATFORM ON}
  finally
    if NeedUninitialize then
      CoUninitialize;
  end;
end;

function ThreadLaunch(p: pointer): Integer;
var
  WinType,Prior: integer;
  params: string;
  execparams, path, exec: string;
  pi : TProcessInformation;
  si : TStartupInfo;
  t,r,c: integer;
begin
  Result := 0;
  t := GlobTab;
  r := GlobRow;
  c := GlobCol;
  exec := FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec);
  path := FlaunchMainForm.GetAbsolutePath(links[t][r][c].workdir);
  if path = '' then
    path := ExtractFilePath(exec);
  if not links[t][r][c].active then
    exit;
  if ((links[t][r][c].ques) and (MessageBox(FlaunchMainForm.Handle,
    PChar(Format(Language.Messages.RunProgram, [ExtractFileName(exec)])),
    PChar(Language.Messages.Confirmation), MB_ICONQUESTION or MB_YESNO) = IDNO)) then
    exit;
  case links[t][r][c].wst of
    0: WinType := SW_SHOW;
    1: WinType := SW_SHOWMAXIMIZED;
    2: WinType := SW_SHOWMINIMIZED;
    3: WinType := SW_HIDE;
  end;
  if links[t][r][c].ltype = 0 then
    begin
      if not FileExists(exec) then
        begin
          MessageBox(FlaunchMainForm.Handle,
            PChar(format(Language.Messages.NotFound,[ExtractFileName(exec)])),
            PChar(Language.Messages.Caution), MB_ICONWARNING or MB_OK);
          exit;
        end;
      case links[t][r][c].pr of
        0: Prior := NORMAL_PRIORITY_CLASS;
        1: Prior := HIGH_PRIORITY_CLASS;
        2: Prior := IDLE_PRIORITY_CLASS;
      end;
      if GlobParam <> '' then
        params := stringreplace(links[t][r][c].dropparams, '%1', GlobParam, [])
      else
        params := links[t][r][c].params;
      params := FlaunchMainForm.GetAbsolutePath(params);
      execparams := Format('"%s" %s', [exec, params]);

      ZeroMemory(@si, sizeof(si));
      si.cb := SizeOf(si);
      si.dwFlags := STARTF_USESHOWWINDOW;
      si.wShowWindow := WinType;
      ZeroMemory(@PI, SizeOf(PI));

      SetLastError(ERROR_INVALID_PARAMETER);
      {$WARN SYMBOL_PLATFORM OFF}
      Win32Check(CreateProcess(PChar(exec), PChar(execparams), nil, nil, false,
        Prior or CREATE_DEFAULT_ERROR_MODE or CREATE_UNICODE_ENVIRONMENT, nil,
        PChar(path), si, pi));
      {$WARN SYMBOL_PLATFORM ON}
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);

      if links[t][r][c].hide then FlaunchMainForm.ChWinView(false);
    end;
  if links[t][r][c].ltype = 1 then
    ShellExecute(FlaunchMainForm.Handle, '', exec, '', path, WinType);
end;

function TFlaunchMainForm.GetFLVersion: string;
begin
  {$IFDEF NIGHTBUILD}
    result := dev_version;
  {$ELSE}
    result := version;
  {$ENDIF}
end;

function TFlaunchMainForm.GetAbsolutePath(s: string): string;
begin
  result := StringReplace(s, '{FL_ROOT}', fl_root, [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result, '{FL_DIR}', fl_dir, [rfReplaceAll, rfIgnoreCase]);
end;

function TFlaunchMainForm.PositionToPercent(p: integer; iswidth: boolean): integer;
var
  WorkArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  if iswidth then
    result := round(p / (WorkArea.Right - Width) * 100)
  else
    result := round(p / (WorkArea.Bottom - Height) * 100);
end;

function TFlaunchMainForm.PercentToPosition(p: integer; iswidth: boolean): integer;
var
  WorkArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  CurScrW := WorkArea.Right;
  CurScrH := WorkArea.Bottom;
  if iswidth then
    result := round(p * (WorkArea.Right - Width) / 100)
  else
    result := round(p * (WorkArea.Bottom - Height) / 100);
end;

procedure TFlaunchMainForm.LoadLanguage;
var
  i: integer;
begin
  Caption := cr_progname;
  for i := 1 to maxt do
    if FlaunchMainForm.MainTabs.Pages[i-1].Caption = '' then
      FlaunchMainForm.MainTabs.Pages[i-1].Caption :=
        Format(Language.Main.TabName,[i]);

  NI_Show.Caption := Language.Menu.Show;
  NI_Settings.Caption := Language.Menu.Settings;
  NI_About.Caption := Language.Menu.About;
  NI_Close.Caption := Language.Menu.Close;
  NI_Run.Caption := Language.Menu.Run;
  NI_TypeProgramm.Caption := Language.Menu.TypeProgramm;
  NI_TypeFile.Caption := Language.Menu.TypeFile;
  NI_Export.Caption := Language.Menu.Export;
  NI_Import.Caption := Language.Menu.Import;
  NI_Clear.Caption := Language.Menu.Clear;
  NI_Prop.Caption := Language.Menu.Prop;
  NI_Rename.Caption := Language.Menu.Rename;
  NI_ClearTab.Caption := Language.Menu.ClearTab;
  NI_DeleteTab.Caption := Language.Menu.DeleteTab;
  NI_Group.Caption := Language.Menu.Group;
  SaveButtonDialog.Filter := Language.FlbFilter + '|*.flb';
  OpenButtonDialog.Filter := Language.FlbFilter + '|*.flb';
end;

procedure TFlaunchMainForm.SetAutorun(b: boolean);
var
  reg: TRegistry;
begin
  if SettingsMode = 2 then
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

procedure TFlaunchMainForm.SaveIni;
var
  i: integer;
begin
  Ini := TIniFile.Create(workdir+'FLaunch.ini');
  ini.WriteInteger(inisection, 'tabs', tabscount);
  ini.WriteInteger(inisection, 'rows', rowscount);
  ini.WriteInteger(inisection, 'cols', colscount);
  ini.WriteInteger(inisection, 'padding', lpadding);
  ini.WriteInteger(inisection, 'iconwidth', iconwidth - panelzoom);
  ini.WriteInteger(inisection, 'iconheight', iconheight - panelzoom);
  ini.WriteInteger(inisection, 'activetab', FlaunchMainForm.MainTabs.TabIndex);
  for i := 1 to maxt do
    if not DefNameOfTab(MainTabs.Pages[i-1].Caption) then
      ini.WriteString(inisection, Format('tab%dname',[i]), FlaunchMainForm.MainTabs.Pages[i-1].Caption)
    else
      ini.WriteString(inisection, Format('tab%dname',[i]), '');

  ini.WriteInteger(inisection, 'formleftpos', PositionToPercent(Left, true));
  ini.WriteInteger(inisection, 'formtoppos', PositionToPercent(Top, false));
  ini.WriteInteger(inisection, 'titlebar', titlebar);
  ini.WriteInteger(inisection, 'tabsview', tabsview);
  ini.WriteBool(inisection, 'alwaysontop', alwaysontop);
  ini.WriteBool(inisection, 'statusbar', statusbarvis);
  ini.WriteBool(inisection, 'autorun', autorun);
  ini.WriteBool(inisection, 'starthide', starthide);
  ini.WriteString(inisection, 'language', lngfilename);
  ini.WriteString(inisection, 'tabsfontname', MainTabs.Font.Name);
  ini.WriteInteger(inisection, 'tabsfontsize', MainTabs.Font.Size);
  ini.Free;
end;

function TFlaunchMainForm.ConfirmDialog(Msg, Title: string): Boolean;
begin
  Result := Application.MessageBox(PChar(Msg), PChar(Title),
    MB_ICONQUESTION or MB_YESNO) = ID_YES;
end;

procedure TFlaunchMainForm.LoadIni;
var
  i: integer;
  WorkArea: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  Ini := TIniFile.Create(workdir+'FLaunch.ini');
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
  iconwidth := ini.ReadInteger(inisection, 'iconwidth', 32) + panelzoom;
  if (iconwidth < 16 + panelzoom) or (iconwidth > 256 + panelzoom) then
    iconwidth := 32 + panelzoom;
  iconheight:= ini.ReadInteger(inisection, 'iconheight', 32) + panelzoom;
  if (iconheight < 16 + panelzoom) or (iconheight > 256 + panelzoom) then
    iconheight := 32 + panelzoom;
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
  for i := 1 to maxt do
    MainTabs.Pages[i-1].Caption := ini.ReadString(inisection, Format('tab%dname',[i]), '');

  LeftPer := ini.ReadInteger(inisection, 'formleftpos', 100);
  if LeftPer < 0 then LeftPer := 0;
  if LeftPer > 100 then LeftPer := 100;
  TopPer := ini.ReadInteger(inisection, 'formtoppos', 0);
  if TopPer < 0 then TopPer := 0;
  if TopPer > 100 then TopPer := 100;

  altlinkscolor := ini.ReadBool(inisection, 'altlinkscolor', false);
  if altlinkscolor then
    PanelColor := ColorStrToColor(ini.ReadString(inisection, 'linkscolor', 'default'))
  else
    PanelColor := clBtnFace;
  altformscolor := ini.ReadBool(inisection, 'altformscolor', false);
  if altformscolor then
    FormColor := ColorStrToColor(ini.ReadString(inisection, 'formscolor', 'default'))
  else
    FormColor := clBtnFace;
  try
    MainTabs.Font.Name := ini.ReadString(inisection, 'tabsfontname', 'Tahoma');
    MainTabs.Font.Size := ini.ReadInteger(inisection, 'tabsfontsize', 8);
  except
  end;
  ini.Free;
end;

procedure TFlaunchMainForm.TrayMenuPopup(Sender: TObject);
begin
  NI_About.Enabled := not aboutshowing;
  NI_Settings.Enabled := not settingsshowing;
end;

procedure TFlaunchMainForm.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  inherited;
  Msg.Result := 1;
  Application.Terminate;
end;

procedure TFlaunchMainForm.Timer1Timer(Sender: TObject);
begin
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TFlaunchMainForm.ChWinView(b: boolean);
begin
  if b then
    begin
      FlaunchMainForm.Visible := true;
      Timer1.Enabled := statusbarvis;
      Timer1Timer(Self);
      ShowWindow(Application.Handle, SW_HIDE);
      SetForegroundWindow(Application.Handle);
    end
  else
    begin
      FlaunchMainForm.Visible := false;
      Timer1.Enabled := False;
    end;
end;

procedure TFlaunchMainForm.TrayIconClick(Sender: TObject);
begin
  ChWinView((not nowactive) or not (FlaunchMainForm.Showing));
end;

function TFlaunchMainForm.LoadCfgFileString(AFileHandle: THandle; ALength: Integer = 0): string;
var
  buff: array[0..255] of AnsiChar;
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
end;

function TFlaunchMainForm.LoadLinksCfgFileV121_12_11: boolean;
var
  t,r,c: integer;
  FileName, ext: string;
  LinksCfgFile: THandle;
begin
  result := false;
  FileName := workdir + 'FLaunch.dat';
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
          if (not links[t,r,c].active) or (ext = '.exe') or (ext = '.bat') then
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
  FileName := workdir + 'Flaunch.dat';
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
          if (not links[t,r,c].active) or (ext = '.exe') or (ext = '.bat') then
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
begin
  result := false;
  FileName := workdir + 'FLaunch.dat';
  if not (fileexists(FileName)) then exit;
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  if LoadCfgFileString(LinksCfgFile, 4) <> 'LCFG' then
    begin
      FileClose(LinksCfgFile);
      RenameFile(FileName, workdir + 'Flaunch_Unknown.dat');
      exit;
    end;
  VerStr := LoadCfgFileString(LinksCfgFile);
  if VerStr <> version then
    begin
      FileClose(LinksCfgFile);
      if (VerStr = '1.21') or (VerStr = '1.2') or ((VerStr = '1.1')) then
        if ConfirmDialog(format(Language.Messages.OldSettings,[VerStr]),
          Language.Messages.Confirmation) then
          begin
            LoadLinksCfgFileV121_12_11;
            exit;
          end;
      if VerStr = '1.0' then
        if ConfirmDialog(format(Language.Messages.OldSettings,[VerStr]),
          Language.Messages.Confirmation) then
          begin
            LoadLinksCfgFileV10;
            exit;
          end;
      RenameFile(FileName, workdir + Format('Flaunch_%s.dat',[VerStr]));
      exit;
    end;
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

procedure TFlaunchMainForm.SaveCfgFileString(AFileHandle: THandle; AString: string;
  AWriteLength: Boolean = True);
var
  buff: AnsiString;
  bufflen: integer;
begin
  bufflen := AString.Length;

  if AWriteLength then
    if FileWrite(AFileHandle, bufflen, sizeof(bufflen)) < sizeof(bufflen) then
      Exit;
  buff := Copy(AString, 1, 255);

  if bufflen > 0 then
    FileWrite(AFileHandle, buff[1], bufflen);
end;

procedure TFlaunchMainForm.SaveLinksCfgFile;
var
  t,r,c: integer;
  FileName: string;
  LinksCfgFile: THandle;
begin
  FileName := workdir + 'FLaunch.dat';
  LinksCfgFile := FileCreate(FileName);
  SaveCfgFileString(LinksCfgFile, 'LCFG', False);
  SaveCfgFileString(LinksCfgFile, version);
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileWrite(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          FileWrite(LinksCfgFile, links[t,r,c].ltype, sizeof(byte));
          SaveCfgFileString(LinksCfgFile, links[t,r,c].exec);
          SaveCfgFileString(LinksCfgFile, links[t,r,c].workdir);
          SaveCfgFileString(LinksCfgFile, links[t,r,c].icon);
          FileWrite(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          SaveCfgFileString(LinksCfgFile, links[t,r,c].params);
          FileWrite(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          SaveCfgFileString(LinksCfgFile, links[t,r,c].dropparams);
          SaveCfgFileString(LinksCfgFile, links[t,r,c].descr);
          FileWrite(LinksCfgFile, links[t,r,c].ques, sizeof(boolean));
          FileWrite(LinksCfgFile, links[t,r,c].hide, sizeof(boolean));
          FileWrite(LinksCfgFile, links[t,r,c].pr, sizeof(byte));
          FileWrite(LinksCfgFile, links[t,r,c].wst, sizeof(byte));
        end;
  FileClose(LinksCfgFile);
end;

procedure TFlaunchMainForm.LoadLinksFromCash;
var
  t,r,c,tt,rr,cc: integer;
  FileName: string;
  LinksCashFile: THandle;
  bufflen: integer;
  Stream: TMemoryStream;
  iw,ih: integer;
begin
  FileName := workdir + 'IconCache.dat';
  if not (fileexists(FileName)) then
    begin
      LoadLinks;
      exit;
    end;
  LinksCashFile := FileOpen(FileName, fmOpenRead);
  if LoadCfgFileString(LinksCashFile, 5) <> 'LCASH' then
    begin
      FileClose(LinksCashFile);
      LoadLinks;
      exit;
    end;
  if LoadCfgFileString(LinksCashFile) <> version then
    begin
      FileClose(LinksCashFile);
      LoadLinks;
      exit;
    end;
  FileRead(LinksCashFile, iw, sizeof(integer));
  FileRead(LinksCashFile, ih, sizeof(integer));
  if (iw <> iconwidth) or (ih <> iconheight) then
    begin
      FileClose(LinksCashFile);
      LoadLinks;
      exit;
    end;
  Stream := TMemoryStream.Create;
  for tt := 0 to tabscount - 1 do
    for rr := 0 to rowscount - 1 do
      for cc := 0 to colscount - 1 do
        begin
          FileRead(LinksCashFile, t, sizeof(integer));
          FileRead(LinksCashFile, r, sizeof(integer));
          FileRead(LinksCashFile, c, sizeof(integer));
          FileRead(LinksCashFile, bufflen, sizeof(bufflen));
          if bufflen > 0 then
            begin
              Stream.Clear;
              Stream.SetSize(bufflen);
              FileRead(LinksCashFile, (Stream.Memory)^, bufflen);
              if links[t][r][c].active then
                begin
                  panels[tt][rr][cc].Icon.LoadFromStream(Stream);
                  panels[tt,rr,cc].HasIcon := true;
                  panels[t,r,c].Repaint;
                end;
              Stream.Clear;
              FileRead(LinksCashFile, bufflen, sizeof(bufflen));
              Stream.SetSize(bufflen);
              if bufflen > 0 then
                begin
                  FileRead(LinksCashFile, (Stream.Memory)^, bufflen);
                  if links[t][r][c].active then
                    panels[tt][rr][cc].PushedIcon.LoadFromStream(Stream);
                end;
            end
          else
            begin
              LoadIc(tt,rr,cc);
            end;
        end;
  Stream.Free;
  FileClose(LinksCashFile);
end;

procedure TFlaunchMainForm.SaveLinksToCash;
var
  FileName: string;
  LinksCashFile: THandle;
  tt,rr,cc: integer;
  bufflen: integer;
  Stream: TMemoryStream;
begin
  FileName := workdir + 'IconCache.dat';
  LinksCashFile := FileCreate(FileName);
  SaveCfgFileString(LinksCashFile, 'LCASH', False);
  SaveCfgFileString(LinksCashFile, version);
  FileWrite(LinksCashFile, iconwidth, sizeof(integer));
  FileWrite(LinksCashFile, iconheight, sizeof(integer));
  Stream := TMemoryStream.Create;
  for tt := 0 to tabscount - 1 do
    for rr := 0 to rowscount - 1 do
      for cc := 0 to colscount - 1 do
        begin
          FileWrite(LinksCashFile, tt, sizeof(integer));
          FileWrite(LinksCashFile, rr, sizeof(integer));
          FileWrite(LinksCashFile, cc, sizeof(integer));
          if (links[tt][rr][cc].active) and (panels[tt][rr][cc].HasIcon) then
            begin
              Stream.Clear;
              panels[tt][rr][cc].Icon.SaveToStream(Stream);
              bufflen := Stream.Size;
              FileWrite(LinksCashFile, bufflen,  sizeof(bufflen));
              FileWrite(LinksCashFile, (Stream.Memory)^, bufflen);
              Stream.Clear;
              panels[tt][rr][cc].PushedIcon.SaveToStream(Stream);
              bufflen := Stream.Size;
              FileWrite(LinksCashFile, bufflen,  sizeof(bufflen));
              FileWrite(LinksCashFile, (Stream.Memory)^, bufflen);
            end
          else
            begin
              bufflen := 0;
              FileWrite(LinksCashFile, bufflen, sizeof(bufflen));
            end;
        end;
  Stream.Free;
  FileClose(LinksCashFile);
end;

procedure TFlaunchMainForm.WMHotKey(var Msg: TWMHotKey);
begin
  if Msg.Msg = WM_HOTKEY then
    begin
      if Msg.HotKey = HotKeyID then
        begin
          nowactive := FlaunchMainForm.Active;
          ChWinView((not nowactive) or not (FlaunchMainForm.Showing));
        end;
    end;
  inherited;
end;

procedure TFlaunchMainForm.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
var
  WorkArea: TRect;
  StickAt : Word;
begin
  StickAt := 10;
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  if (not ChPos) and (CurScrW = WorkArea.Right) and (CurScrH = WorkArea.Bottom) then
    begin
      with WorkArea, Msg.WindowPos^ do
        begin
          Right:=Right-cx;
          Bottom:=Bottom-cy;
          if (abs(Left - x) <= StickAt) or (x < Left) then x := Left;
          if (abs(Right - x) <= StickAt) or (x > Right) then x := Right;
          if (abs(Top - y) <= StickAt) or (y < Top) then y := Top;
          if (abs(Bottom - y) <= StickAt) or (y > Bottom) then y := Bottom;
        end;
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
  DeleteFile(workdir + '.session');
  SaveIni;
  SaveLinksCfgFile;
  SaveLinksToCash;
end;

procedure TFlaunchMainForm.GetCoordinates(Sender: TObject; var t: integer; var r: integer; var c: integer);
begin
  t := (Sender as TMyPanel).TabNum;
  r := (Sender as TMyPanel).RowNum;
  c := (Sender as TMyPanel).ColNum;
end;

procedure TFlaunchMainForm.LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
var
  icon: TIcon;
begin
  icon := TIcon.Create;
  if (not fileexists(FileName)) and (not directoryexists(FileName)) then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON')
  else
    icon.Handle := GetFileIcon(FileName, true, Index);
  if icon.Handle = 0 then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON');
  Im.Picture.Assign(icon);
  icon.Free;
end;

procedure TFlaunchMainForm.LoadIc(t, r, c: integer);
var
  icx,icy: integer;
  icon: TIcon;
  TempBmp: TBitMap;
  FileName: string;
  Index: integer;
begin
  if not links[t][r][c].active then
    begin
      panels[t][r][c].HasIcon := false;
      panels[t,r,c].Repaint;
      exit;
    end;

  FileName := GetAbsolutePath(links[t][r][c].icon);
  Index := links[t][r][c].iconindex;
  icon := TIcon.Create;
  if (not fileexists(FileName)) and (not directoryexists(FileName)) then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON')
  else
    icon.Handle := GetFileIcon(FileName, true, Index);
  if icon.Handle = 0 then
    icon.Handle := LoadIcon(hinstance, 'RBLANKICON');
  icx := GetSystemMetrics(SM_CXICON);
  icy := GetSystemMetrics(SM_CYICON);

  TempBmp := TBitMap.Create;
  TempBmp.Width := icx;
  TempBmp.Height := icy;
  TempBmp.Canvas.Brush.Color := PanelColor;
  TempBmp.Canvas.FillRect(TempBmp.Canvas.ClipRect);
  DrawIcon(TempBmp.Canvas.Handle,0,0,icon.Handle);

  if (icx = iconwidth - panelzoom) and (icy = iconheight - panelzoom) then
    panels[t,r,c].Icon.Assign(TempBmp)
  else
    SmoothResize(TempBmp, panels[t,r,c].Icon);

  if (icx = iconwidth - 7) and (icy = iconheight - 7) then
    panels[t,r,c].PushedIcon.Assign(TempBmp)
  else
    SmoothResize(TempBmp, panels[t,r,c].PushedIcon);

  panels[t,r,c].HasIcon := true;
  panels[t,r,c].Repaint;
  icon.Free;
  TempBmp.Free;
end;

procedure TFlaunchMainForm.LoadPanelLinks(Index: integer);
var
  rr,cc: integer;
begin
  for rr := 0 to rowscount - 1 do
    for cc := 0 to colscount - 1 do
      LoadIc(Index,rr,cc);
end;

procedure TFlaunchMainForm.LoadLinks;
var
  tt,rr,cc: integer;
begin
  for tt := 0 to tabscount - 1 do
    for rr := 0 to rowscount - 1 do
      for cc := 0 to colscount - 1 do
        LoadIc(tt,rr,cc);
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
var
  d: integer;
begin
  if Key = vk_F2 then
    begin
      GlobTabNum := MainTabs.ActivePageIndex;
      NI_RenameClick(NI_Rename);
    end;
  if ((Key = ord('S')) and (ssCtrl in Shift)) then
    NI_SettingsClick(NI_Settings);
  if ((Key = ord('Q')) and (ssCtrl in Shift)) then
    Application.Terminate;
  if (FocusTab > -1) and (FocusRow > -1) and (FocusCol > -1) then
    begin
      if Key = vk_down then
        Panels[FocusTab][(FocusRow+1) mod rowscount][FocusCol].SetFocus;
      if Key = vk_up then
        begin
          d := FocusRow-1;
          if d < 0 then d := rowscount - 1;
          Panels[FocusTab][d mod rowscount][FocusCol].SetFocus;
        end;
      if Key = vk_left then
        begin
          d := FocusCol-1;
          if d < 0 then d := colscount - 1;
          Panels[FocusTab][FocusRow][d mod colscount].SetFocus;
        end;
      if Key = vk_right then
        Panels[FocusTab][FocusRow][(FocusCol+1) mod colscount].SetFocus;
    end;
end;

procedure TFlaunchMainForm.CreatePanel(PanelIndex: integer);
var
  rr,cc,tt: integer;
begin
  tt := PanelIndex;
  for rr := 0 to rowscount - 1 do
    for cc := 0 to colscount - 1 do
      begin
        (FindComponent(Format('GroupPanel%d',[tt+1])) as TPanel).Color := PanelColor;
        panels[tt][rr][cc] := TMyPanel.Create(self, (FindComponent(Format('GroupPanel%d',[tt+1])) as TPanel), iconwidth, iconheight, PanelColor);
        with panels[tt][rr][cc] do
          begin
            Left := (lpadding*(cc + 1)) + (iconwidth*cc);
            Top := (lpadding*(rr + 1)) + (iconheight*rr);
            TabNum := tt;
            RowNum := rr;
            ColNum := cc;
            PopupMenu := FlaunchMainForm.PopupMenu;
            OnMouseMove := PanelMouseMove;
            OnMouseLeave := PanelMouseLeave;
            OnMouseDown := PanelMouseDown;
            OnClick := PanelClick;
            OnSetFocus := PanelSetFocus;
            OnKillFocus := PanelKillFocus;
            OnDragFile := PanelDragFile;
            OnDragOver := PanelDragOver;
            OnDragDrop := PanelDragDrop;
            Show;
          end;
        end;
end;

procedure TFlaunchMainForm.DestroyPanel(PanelIndex: integer);
var
  rr,cc,tt: integer;
begin
  tt := PanelIndex;
  for rr := 0 to rowscount - 1 do
    for cc := 0 to colscount - 1 do
      panels[tt][rr][cc].Destroy;
end;

procedure TFlaunchMainForm.ClearLinks(Index: integer);
begin
  fillchar(links[Index], sizeof(link), 0);
  LoadPanelLinks(Index);
end;

procedure TFlaunchMainForm.ChangeWndSize;
begin
  StatusBar.Height := MulDiv(19, Screen.PixelsPerInch, DesignDPI);
  Width := Width + (lpadding*(colscount + 1)) + (iconwidth*colscount) - GroupPanel1.Width;
  Height := Height + (lpadding*(rowscount + 1)) + (iconheight*rowscount) - GroupPanel1.Height;
  StatusBar.Panels[0].Width := Width - MulDiv(122, Screen.PixelsPerInch, DesignDPI);
  Left := PercentToPosition(LeftPer, true);
  Top := PercentToPosition(TopPer, false);
end;

procedure TFlaunchMainForm.GenerateWnd;
var
  tt: integer;
begin
  StatusBar.Visible := statusbarvis;
  case titlebar of
    0: BorderStyle := bsSingle;
    1: BorderStyle := bsToolWindow;
    2: BorderStyle := bsNone;
  end;
  case tabsview of
    0: MainTabs.Style := tsTabs;
    1: MainTabs.Style := tsButtons;
    2: MainTabs.Style := tsFlatButtons;
  end;
  if AlwaysOnTop then
    FormStyle := fsStayOnTop;
  if tabscount = 1 then
    MainTabs.Pages[0].TabVisible := false
  else
    for tt := 0 to tabscount - 1 do
      MainTabs.Pages[tt].TabVisible := true;

  for tt := 0 to tabscount - 1 do
    CreatePanel(tt);

  ChangeWndSize;
end;

procedure TFlaunchMainForm.PanelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  GlobTab := t;
  GlobRow := r;
  GlobCol := c;
  if button = mbright then
    begin
      case links[t][r][c].ltype of
        0:
          begin
            NI_TypeProgramm.Checked := true;
            NI_TypeFile.Checked := false;
          end;
        1:
          begin
            NI_TypeProgramm.Checked := false;
            NI_TypeFile.Checked := true;
          end;
      end;
      NI_Run.Enabled := links[t][r][c].active;
      NI_Import.Enabled := not links[t][r][c].active;
      NI_Export.Enabled := links[t][r][c].active;
      NI_Clear.Enabled := links[t][r][c].active;
      NI_TypeProgramm.Enabled := not links[t][r][c].active;
      NI_TypeFile.Enabled := not links[t][r][c].active;
    end; 
end;

procedure TFlaunchMainForm.PanelMouseLeave(Sender: TObject);
begin
  StatusBar.Panels[0].Text := '';
end;

procedure TFlaunchMainForm.PanelSetFocus(Sender: TObject);
var
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  GlobTab := t;
  GlobRow := r;
  GlobCol := c;
  FocusTab := t;
  FocusRow := r;
  FocusCol := c;
  NI_Run.Enabled := links[t][r][c].active;
  NI_Clear.Enabled := links[t][r][c].active;
end;

procedure TFlaunchMainForm.PopupMenuPopup(Sender: TObject);
begin
  Panels[GlobTab][GlobRow][GlobCol].MouseUp(mbleft, [], 0, 0);
end;

procedure TFlaunchMainForm.PanelKillFocus(Sender: TObject);
begin
  Panels[GlobTab][GlobRow][GlobCol].MouseUp(mbleft, [], 0, 0);
  FocusTab := -1;
  FocusRow := -1;
  FocusCol := -1;
end;

procedure TFlaunchMainForm.PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  t,t2,r,r2,c,c2: integer;
  templ: lnk;
begin
  GetCoordinates(Sender, t, r, c);
  GetCoordinates(Source, t2, r2, c2);
  templ := links[t2][r2][c2];
  links[t2][r2][c2] := links[t][r][c];
  links[t][r][c] := templ;
  LoadIc(t,r,c);
  LoadIc(t2,r2,c2);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.PanelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  t,r,c: integer;
begin
  if (Source is TMyPanel) then
    begin
      GetCoordinates(Source, t, r, c);
      Accept := (links[t][r][c].active) and (Sender <> Source);
    end
  else
    Accept := false;
end;

procedure TFlaunchMainForm.FormActivate(Sender: TObject);
begin
  nowactive := FlaunchMainForm.Active;
end;

procedure TFlaunchMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  canclose := false;
  Showwindow(Handle, SW_HIDE);
end;

procedure TFlaunchMainForm.FormCreate(Sender: TObject);
var
  sini: TIniFile;
begin
  ChPos := true;
  randomize;
  registerhotkey(Handle, HotKeyID, mod_control or mod_win, 0);
  fl_dir := ExtractFilePath(Application.ExeName);
  fl_root := IncludeTrailingPathDelimiter(ExtractFileDrive(fl_dir));

  sini := TIniFile.Create(fl_dir + 'UseProfile.ini'); //Считываем файл первичных настроек для определения режима работы программы и места хранения настроек
  try
    SettingsMode := sini.ReadInteger('general', 'settingsmode', 0);
    if SettingsMode > 2 then SettingsMode := 0;
    if (SettingsMode = 0) then
    begin
      workdir := GetSpecialDir(CSIDL_APPDATA) + 'FreeLaunch\';
      if not DirectoryExists(workdir) then
        CreateDir(workdir);
    end
    else
    begin
      workdir := ExtractFilePath(ParamStr(0));
      CurrentEurekaLogOptions.OutputPath := workdir;
    end;
  finally
    sini.Free;
  end;

  LoadIni;
  Language.AddNotifier(LoadLanguage);
  Language.Load(lngfilename);
  SetAutorun(Autorun);
  GenerateWnd;
  MainTabs.TabIndex := tabind;
  LoadLinksCfgFile;
  if fileexists(workdir + '.session') then
    LoadLinks
  else
    begin
      LoadLinksFromCash;
      //--Создаем файл, который будет идентифицировать сессию. При корректном завершении программы файл будет удален
      FileClose(FileCreate(workdir + '.session'));
      SetFileAttributes(PChar(workdir + '.session'), FILE_ATTRIBUTE_HIDDEN);
    end;
  TrayIcon.Hint := Format('%s %s',[cr_progname, GetFLVersion]);
  if not StartHide then
    Show
  else
    Application.ShowMainForm := False;
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
  ChPos := false;
end;

procedure TFlaunchMainForm.MainTabsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: Integer;
  rct: TRect;
  s: string;
begin
  if Source is TPageControl then
    begin
      with MainTabs do
        begin
          for i := 0 to PageCount - 1 do
            begin
              Perform(TCM_GETITEMRECT, i, lParam(@rct));
              if PtInRect(rct, Point(X, Y)) then
                begin
                  if i = ActivePage.PageIndex then exit;
                  s := Pages[i].Caption;
                  Pages[i].Caption := ActivePage.Caption;
                  ActivePage.Caption := s;
                  templinks := links[i];
                  links[i] := links[ActivePage.PageIndex];
                  links[ActivePage.PageIndex] := templinks;
                  LoadPanelLinks(ActivePage.PageIndex);
                  LoadPanelLinks(i);
                  MainTabs.TabIndex := i;
                  SaveIni;
                  SaveLinksCfgFile;
                  exit;
                end;
            end;
        end;
    end;
end;

procedure TFlaunchMainForm.MainTabsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
const
  TCM_GETITEMRECT = $130A;
var
  i: Integer;
  rct: TRect;
  t,r,c: integer;
begin
  if (Source is TMyPanel) then
    begin
      GetCoordinates(Source, t, r, c);
      Accept := links[t][r][c].active;
      if not Accept then
        exit;
      with MainTabs do
        begin
          for i := 0 to PageCount - 1 do
            begin
              Perform(TCM_GETITEMRECT, i, lParam(@rct));
              if PtInRect(rct, Point(X, Y)) then
                begin
                  MainTabs.TabIndex := i;
                  exit;
                end;
            end;
        end;
    end;
  if (Source is TPageControl) then
    Accept := true;
end;

procedure TFlaunchMainForm.MainTabsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  rct: TRect;
  i: integer;
  p: tpoint;
begin
  if button = mbleft then
    if ssCtrl in Shift then
      MainTabs.BeginDrag(false);
  if button = mbright then
    begin
      with MainTabs do
        begin
          GetCursorPos(p);
          for i := 0 to PageCount - 1 do
            begin
              Perform(TCM_GETITEMRECT, i, lParam(@rct));
              if PtInRect(rct, Point(X, Y)) then
                begin
                  TabIndex := i;
                  GlobTabNum := i;
                  NI_DeleteTab.Enabled := tabscount > mint;
                  PagesMenu.Popup(p.X, p.Y);
                end;
            end;
        end;
    end;
end;

procedure TFlaunchMainForm.NI_CloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFlaunchMainForm.NI_RenameClick(Sender: TObject);
var
  frm: TRenameTabForm;
begin
  Application.CreateForm(TRenameTabForm, frm);
  frm.ShowModal;
end;

procedure TFlaunchMainForm.NI_DeleteTabClick(Sender: TObject);
var
  i: integer;
begin
  if not ConfirmDialog(format(Language.Messages.DeleteTab, [MainTabs.Pages[GlobTabNum].Caption]),
    Language.Messages.Confirmation) then exit;
  ClearLinks(GlobTabNum);
  for i := GlobTabNum to tabscount - 2 do
    begin
      links[i] := links[i+1];
      MainTabs.Pages[i].Caption := MainTabs.Pages[i+1].Caption;
    end;
  DestroyPanel(tabscount - 1);
  dec(tabscount);
  FlaunchMainForm.MainTabs.Pages[tabscount].Caption := '';
  MainTabs.Pages[tabscount].TabVisible := false;
  if tabscount = 1 then
    begin
      FlaunchMainForm.DestroyPanel(0);
      MainTabs.Pages[0].TabVisible := false;
      MainTabs.TabIndex := 0;
      FlaunchMainForm.CreatePanel(0);
    end;
  ChangeWndSize;
  LoadLinks;
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.ImportButton(filename: string; t,r,c: integer);
const
  sect = 'button';
var
  fbut: TIniFile;
begin
  fbut := TIniFile.Create(filename);
  if (not fileexists(fbut.ReadString(sect,'object',''))) and (not directoryexists(fbut.ReadString(sect,'object',''))) then
    begin
      fbut.Free;
      exit;
    end;
  links[t][r][c].active := true;
  links[t][r][c].exec := fbut.ReadString(sect,'object','');
  links[t][r][c].workdir := fbut.ReadString(sect,'workdir','');
  links[t][r][c].icon := fbut.ReadString(sect,'icon','');
  links[t][r][c].iconindex := fbut.ReadInteger(sect,'iconindex',0);
  links[t][r][c].params := fbut.ReadString(sect,'parameters','');
  links[t][r][c].dropfiles := fbut.ReadBool(sect,'dropfiles',false);
  links[t][r][c].dropparams := fbut.ReadString(sect,'dropparameters','');
  links[t][r][c].descr := fbut.ReadString(sect,'describe','');
  links[t][r][c].ques := fbut.ReadBool(sect,'question',false);
  links[t][r][c].hide := fbut.ReadBool(sect,'hide',false);
  links[t][r][c].pr := fbut.ReadInteger(sect,'priority',0);
  links[t][r][c].wst := fbut.ReadInteger(sect,'windowstate',0);
  fbut.Free;
  LoadIc(t,r,c);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.NI_ExportClick(Sender: TObject);
const
  sect = 'button';
var
  fbut: TIniFile;
  t,r,c: integer;
begin
  t := GlobTab;
  r := GlobRow;
  c := GlobCol;
  SaveButtonDialog.FileName := ExtractFileNameNoExt(links[t][r][c].exec);
  if SaveButtonDialog.Execute(Handle) then
    begin
      fbut := TIniFile.Create(SaveButtonDialog.FileName);
      fbut.WriteString(sect,'object',links[t][r][c].exec);
      fbut.WriteString(sect,'workdir',links[t][r][c].workdir);
      fbut.WriteString(sect,'icon',links[t][r][c].icon);
      fbut.WriteInteger(sect,'iconindex',links[t][r][c].iconindex);
      fbut.WriteString(sect,'parameters',links[t][r][c].params);
      fbut.WriteBool(sect,'dropfiles',links[t][r][c].dropfiles);
      fbut.WriteString(sect,'dropparameters',links[t][r][c].dropparams);
      fbut.WriteString(sect,'describe',links[t][r][c].descr);
      fbut.WriteBool(sect,'question',links[t][r][c].ques);
      fbut.WriteBool(sect,'hide',links[t][r][c].hide);
      fbut.WriteInteger(sect,'priority',links[t][r][c].pr);
      fbut.WriteInteger(sect,'windowstate',links[t][r][c].wst);
      fbut.Free;
    end;
end;

procedure TFlaunchMainForm.NI_ImportClick(Sender: TObject);
var
  t,r,c: integer;
begin
  t := GlobTab;
  r := GlobRow;
  c := GlobCol;
  if OpenButtonDialog.Execute(Handle) then
    ImportButton(OpenButtonDialog.FileName, t, r, c);
end;

procedure TFlaunchMainForm.NI_GroupClick(Sender: TObject);
var
  r1,r2,c1,c2: integer;
  flag: boolean;
begin
  flag := false;
  for r1 := 0 to rowscount - 1 do
    for c1 := 0 to colscount - 1 do
      begin
        if not links[GlobTabNum][r1][c1].active then continue;
        flag := false;
        for r2 := 0 to rowscount - 1 do
          begin
            if flag then
              break;
            for c2 := 0 to colscount - 1 do
              begin
                if (r1 = r2) and (c1 - c2 < 1) then
                  begin
                    flag := true;
                    break;
                  end;
                if not links[GlobTabNum][r2][c2].active then
                  begin
                    links[GlobTabNum][r2][c2] := links[GlobTabNum][r1][c1];
                    fillchar(links[GlobTabNum][r1][c1], sizeof(lnk), 0);
                    flag := true;
                    break;
                  end;
              end;
          end;
      end;
  LoadPanelLinks(GlobTabNum);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.NI_AboutClick(Sender: TObject);
var
  frm: TAboutForm;
begin
  Application.CreateForm(TAboutForm, frm);
  frm.ShowModal;
end;

procedure TFlaunchMainForm.NI_ClearClick(Sender: TObject);
var
  t,r,c: integer;
begin
  t := GlobTab;
  r := GlobRow;
  c := GlobCol;
  panels[t][r][c].SetBlueFrame;
  if ConfirmDialog(format(Language.Messages.DeleteButton,[ExtractFileName(GetAbsolutePath(links[t][r][c].exec))]),
    Language.Messages.Confirmation) then
    begin
      fillchar(links[t][r][c],sizeof(lnk),0);
      panels[t][r][c].HasIcon := false;
      panels[t][r][c].Repaint;
    end;
  panels[t][r][c].RemoveFrame;
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.NI_ClearTabClick(Sender: TObject);
begin
  if not ConfirmDialog(format(Language.Messages.ClearTab, [MainTabs.Pages[GlobTabNum].Caption]),
    Language.Messages.Confirmation) then exit;
  ClearLinks(GlobTabNum);
  LoadPanelLinks(GlobTabNum);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.NI_propClick(Sender: TObject);
var
  prfrm: TProgrammPropertiesForm;
  flfrm: TFilePropertiesForm;
begin
  PropertiesMode := links[GlobTab][GlobRow][GlobCol].ltype;
  if links[GlobTab][GlobRow][GlobCol].ltype = 0 then
    begin
      Application.CreateForm(TProgrammPropertiesForm, prfrm);
      prfrm.ShowModal;
    end;
  if links[GlobTab][GlobRow][GlobCol].ltype = 1 then
    begin
      Application.CreateForm(TFilePropertiesForm, flfrm);
      flfrm.ShowModal;
    end;
end;

procedure TFlaunchMainForm.NI_RunClick(Sender: TObject);
var
  h, id: cardinal;
begin
  GlobParam := '';
  h := BeginThread(nil, 0, ThreadLaunch, nil, 0, id);
  if h = 0 then
    RaiseLastOSError
  else
    CloseHandle(h);
end;

procedure TFlaunchMainForm.NI_SaveClick(Sender: TObject);
begin
  SaveIni;
  SaveLinksCfgFile;
  SaveLinksToCash;
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

procedure TFlaunchMainForm.NI_TypeFileClick(Sender: TObject);
begin
  NI_TypeProgramm.Checked := false;
  NI_TypeFile.Checked := true;
  links[GlobTab][GlobRow][GlobCol].ltype := 1;
end;

procedure TFlaunchMainForm.NI_TypeProgrammClick(Sender: TObject);
begin
  NI_TypeProgramm.Checked := true;
  NI_TypeFile.Checked := false;
  links[GlobTab][GlobRow][GlobCol].ltype := 0;
end;

procedure TFlaunchMainForm.PanelClick(Sender: TObject);
var
  h, id: cardinal;
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  GlobTab := t;
  GlobRow := r;
  GlobCol := c;
  GlobParam := '';
  h := BeginThread(nil, 0, ThreadLaunch, nil, 0, id);
  if h = 0 then
    RaiseLastOSError
  else
    CloseHandle(h);
end;

procedure TFlaunchMainForm.DropExecProgram(FileName: string; t,r,c: integer; fromlnk: boolean);
begin
  links[t,r,c].ltype := 0;
  if links[t,r,c].exec = '' then
    links[t,r,c].exec := FileName;
  if not fromlnk then
    begin
      links[t,r,c].workdir := ExtractFilePath(FileName);
      links[t,r,c].icon := FileName;
    end;
  if links[t,r,c].descr = '' then
    links[t,r,c].descr := GetFileDescription(links[t,r,c].exec);
  if links[t,r,c].descr = '' then
    links[t,r,c].descr := ExtractFileNameNoExt(links[t,r,c].exec);
end;

procedure TFlaunchMainForm.DropFileFolder(FileName: string; t,r,c: integer; fromlnk: boolean);
begin
  links[t,r,c].ltype := 1;
  if links[t,r,c].exec = '' then
    links[t,r,c].exec := FileName;
  if not fromlnk then
    begin
      links[t,r,c].workdir := ExtractFilePath(FileName);
      links[t,r,c].icon := FileName;
    end;
  if links[t,r,c].descr = '' then
    links[t,r,c].descr := ExtractFileName(links[t,r,c].exec);
end;

procedure TFlaunchMainForm.PanelDragFile(Sender: TObject; FileName: string);
var
  lnkinfo: TShellLinkInfoStruct;
  pch: array[0..MAX_PATH] of char;
  t,r,c: integer;
  h, id: cardinal;
  ext: string;
  fromlnk: boolean;
begin
  GetCoordinates(Sender, t, r, c);
  if (links[t][r][c].active) and (links[t][r][c].dropfiles) then
    begin
      GlobParam := FileName;
      GlobTab := t;
      GlobRow := r;
      GlobCol := c;
      h := BeginThread(nil, 0, ThreadLaunch, nil, 0, id);
      if h = 0 then
        RaiseLastOSError
      else
        CloseHandle(h);
      exit;
    end;
  if (links[t][r][c].active) and (not ConfirmDialog(Language.Messages.BusyReplace,
    Language.Messages.Confirmation)) then
    exit;
  fillchar(links[t,r,c],sizeof(lnk),0);
  if extractfileext(FileName).ToLower = '.flb' then
    if ConfirmDialog(format(Language.Messages.ImportButton,[FileName]), Language.Messages.Confirmation) then
      begin
        ImportButton(FileName, t, r, c);
        exit;
      end;
  if extractfileext(FileName).ToLower = '.lnk' then
    begin
      StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, FileName, MAX_PATH - 1);
      GetLinkInfo(@lnkinfo);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileToExecute,pch,sizeof(pch));
      links[t,r,c].exec := pch;
      FileName := links[t,r,c].exec;
      ext := extractfileext(links[t,r,c].exec).ToLower;
      fromlnk := true;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileContiningIcon,pch,sizeof(pch));
      links[t,r,c].icon := pch;
      if links[t,r,c].icon = '' then
        links[t,r,c].icon := links[t,r,c].exec;
      links[t,r,c].iconindex := lnkinfo.IconIndex;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfWorkingDirectroy,pch,sizeof(pch));
      links[t,r,c].workdir := pch;
      links[t,r,c].params := lnkinfo.ParamStringsOfFileToExecute;
      links[t,r,c].descr := lnkinfo.Description;
    end
  else
    begin
      ext := extractfileext(FileName).ToLower;
      fromlnk := false;
    end;
  if (ext = '.exe') or (ext = '.bat') then
    DropExecProgram(FileName, t, r, c, fromlnk)
  else
    DropFileFolder(FileName, t, r, c, fromlnk);

  links[t,r,c].active := true;
  LoadIc(t,r,c);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  if links[t][r][c].active then
    begin
      panels[t][r][c].Hint := Format(Language.Main.Location + #13#10 +
        Language.Main.Parameters + #13#10 + Language.Main.Description,
        [links[t][r][c].exec, links[t][r][c].params, MyCutting(links[t][r][c].descr, 60)]);
      StatusBar.Panels[0].Text := MyCutting(links[t][r][c].descr, 60);
    end
  else
    StatusBar.Panels[0].Text := ''; 
end;

end.
