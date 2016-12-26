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
  SettingsFormModule, AboutFormModule, FLFunctions, FLLanguage, FLClasses;

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

  BUTTON_INI_SECTION = 'button';

  DesignDPI = 96;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;

  link = array[0..maxr - 1,0..maxc - 1] of lnk;
  panel = array[0..maxr - 1,0..maxc - 1] of TMyPanel;

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
    procedure NI_SaveClick(Sender: TObject);
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
    //--������� ��� ������������ �������
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
    //--������ ���� �������
    TabNames: TStringList;
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure WMDisplayChange(var Msg: TWMDisplayChange); message WM_DISPLAYCHANGE;
    procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;
    procedure UMShowMainForm(var Msg: TMessage); message UM_ShowMainForm;
    procedure UMHideMainForm(var Msg: TMessage); message UM_HideMainForm;

    procedure LoadLinksFromCash;
    procedure LoadPanelLinks(Index: integer);
    procedure ClearLinks(Index: integer);
    procedure ImportButton(filename: string; t,r,c: integer); overload;
    procedure ImportButton(Button: TFLButton; FileName: string); overload;
    procedure ExportButton(Button: TFLButton; FileName: string);
    function LoadCfgFileString(AFileHandle: THandle; ALength: Integer = 0): string;
    function LoadLinksCfgFileV121_12_11: boolean;
    function LoadLinksCfgFileV10: boolean;
    function LoadLinksCfgFile: boolean;
    procedure GetCoordinates(Sender: TObject; var t: integer; var r: integer; var c: integer);
    procedure DropExecProgram(FileName: string; t,r,c: integer; fromlnk: boolean);
    procedure DropFileFolder(FileName: string; t,r,c: integer; fromlnk: boolean);
    function ConfirmDialog(Msg, Title: string): Boolean;
    function ButtonToLnk(AButton: TFLButton): lnk;
    procedure LnkToButton(ALink: Lnk; var AButton: TFLButton);
    //--������� ������������ ��� ����� �� ������ �� ������
    procedure FLPanelButtonClick(Sender: TObject; Button: TFLButton);
    //--������� ������������ ��� ������� ������ ���� �� ������ ������
    procedure FLPanelButtonMouseDown(Sender: TObject; MouseButton: TMouseButton; Button: TFLButton);
    //--������� ������������ ��� �������� ���� �� ������
    procedure FLPanelButtonMouseMove(Sender: TObject; Button: TFLButton);
    //--������� ������������ ��� ��������� ������� ���� ������
    procedure FLPanelButtonMouseLeave(Sender: TObject; Button: TFLButton);
    //--������� ��� �������������� ����� �� ������ ������
    procedure FLPanelDropFile(Sender: TObject; Button: TFLButton; FileName: string);
    //--��������� ����� ������������ �������
    procedure SetTabName(i: byte);
    //--����� ������� ���������������� �������
    procedure RenameTab(i: byte);
    //--�������� �������
    procedure DeleteTab(i: byte);
    //--���������� �������� ������ �� xml-�����
    procedure LoadLinksSettings;
    //--������� ����������, ��������� �� ���������� t,r,c � �������� �������� ������� ������
    function IsTRCInRange(t, r, c: byte): boolean;
    //--���������� �������� ������ � xml-����
    procedure SaveLinksSettings;
    //--���������� ������ ������ �� ����
    procedure LoadLinksIconsFromCache;
    //--���������� ������ ������ � ���
    procedure SaveLinksIconsToCache;
  public
    FLPanel: TFLPanel;
    //--���������� �������
    TabsCountNew: byte;
    //--������ � ������ ������
    ButtonWidth, ButtonHeight: byte;
    //--���� ������
    ButtonsColor: TColor;
    procedure EndWork;
    procedure ChangeWndSize;
    procedure GenerateWnd;
    procedure CreatePanel(PanelIndex: integer);
    procedure DestroyPanel(PanelIndex: integer);
    procedure PanelDragFile(Sender: TObject; FileName: string);
    procedure PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PanelClick(Sender: TObject);
    procedure PanelDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PanelDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LoadLanguage;
    function DefNameOfTab(tn: string): boolean;
    procedure SetAutorun(b: boolean);
    procedure LoadIni;
    procedure SaveIni;
    function PositionToPercent(p: integer; iswidth: boolean): integer;
    function PercentToPosition(p: integer; iswidth: boolean): integer;
    function GetFLVersion: string;
    procedure LoadIc(t, r, c: integer);
    procedure LoadLinks;
    procedure LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
    procedure SaveCfgFileString(AFileHandle: THandle; AString: string;
      AWriteLength: Boolean = True);
    procedure SaveLinksCfgFile;
    procedure SaveLinksToCash;
    procedure ChWinView(b: boolean);
    procedure ReloadIcons;
    procedure GrowTabNames(ACount: Integer);
    //--��������� ���� ���� �������
    procedure SetTabNames;
  end;

var
  FlaunchMainForm: TFlaunchMainForm;
  SettingsMode: byte; //����� ������ (0 - �����������, ��������� �������� � APPDATA; 1 - �����������, ��������� �������� � ����� ���������; 2 - ������������ �����, �����������, ��������� �������� � ����� ���������)
  PropertiesMode: integer; //���������� �������� ��� ������, �������� ������� ������������� � ������ ������
  iconwidth, iconheight, tabscount, rowscount, colscount, lpadding, tabind, LeftPer, TopPer, CurScrW, CurScrH: integer;
  templinks: link;
  links: array[0..maxt - 1] of link;
  panels: array[0..maxt - 1] of panel;
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
  workdir: string;
  ChPos: boolean = false;

implementation

{$R Manifest.res}
{$R png.res}
{$R *.dfm}

uses
  XMLDoc, XMLIntf, PngImage, IOUtils;

function TFlaunchMainForm.GetFLVersion: string;
begin
  {$IFDEF NIGHTBUILD}
    result := dev_version;
  {$ELSE}
    result := version;
  {$ENDIF}
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

//--����� ������� ���������������� �������
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
end;

procedure TFlaunchMainForm.RenameTab(i: byte);
begin
  MainTabsNew.Tabs.Strings[i] :=
    TRenameTabForm.Execute(MainTabsNew.Tabs.Strings[i]);
  TabNames[i] := MainTabsNew.Tabs.Strings[i];
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

//--��������� ����� ������������ �������
procedure TFlaunchMainForm.SetTabName(i: byte);
var
  TabName: string;
begin
  //--����������� ����� �������
  if TabNames.Strings[i] = '' then
    //--��� ��-���������
    TabName := Format(Language.Main.TabName, [i + 1])
  else
    //--���, �������� �������������
    TabName := TabNames.Strings[i];
  //--���� ������� ����������
  if MainTabsNew.Tabs[i] <> '' then
  begin
    //--������ �� ���������� ���
    MainTabsNew.Tabs.Strings[i] := TabName;
    TabNames.Strings[i] := TabName;
  end
  else
    //--����� ������� � ������ ���������� ���
    MainTabsNew.Tabs[i] := TabName;
end;

//--��������� ���� ���� �������
procedure TFlaunchMainForm.SetTabNames;
var
  i: Integer;
begin
  if TabsCountNew > 1 then
    {*--������ ����� �������--*}
    for i := 0 to TabsCountNew - 1 do
      SetTabName(i);
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

//--�������� �������
procedure TFlaunchMainForm.DeleteTab(i: byte);
begin
  if TabsCountNew = 1 then
    Exit;
  if not ConfirmDialog(format(Language.Messages.DeleteTab, [MainTabsNew.Tabs[i]]),
    Language.Messages.Confirmation)
  then
    exit;
  //--������� ��� ���� �������
  TabNames.Delete(i);
  //--������� �������
  MainTabsNew.Tabs.Delete(i);
  //--��������� ������� ������� �� 1
  Dec(TabsCountNew);
  //--���� �������� ������������ �������, �������� ��
  if TabsCountNew = 1 then
    MainTabsNew.Tabs.Clear;
  SetTabNames;
  //--������� �������� ������ � ������ �������� ������ �������
  MainTabsNew.TabIndex := FLPanel.DeletePage(i);
  //--��������� ������ ���� ��� ���������� ������ ������
  ChangeWndSize;

  SaveLinksCfgFile;
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
  ini.WriteInteger(inisection, 'activetab', MainTabsNew.TabIndex);
  for i := 1 to TabsCountNew do
    if not DefNameOfTab(TabNames[i-1]) then
      ini.WriteString(inisection, Format('tab%dname',[i]), TabNames[i-1])
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
  ini.WriteString(inisection, 'tabsfontname', MainTabsNew.Font.Name);
  ini.WriteInteger(inisection, 'tabsfontsize', MainTabsNew.Font.Size);
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
  GrowTabNames(maxt);
  for i := 1 to maxt do
    TabNames[i-1] := ini.ReadString(inisection, Format('tab%dname',[i]), '');

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
    MainTabsNew.Font.Name := ini.ReadString(inisection, 'tabsfontname', 'Tahoma');
    MainTabsNew.Font.Size := ini.ReadInteger(inisection, 'tabsfontsize', 8);
  except
  end;
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

{*--��������� ������� ������������ ���� �������--*}
procedure TFlaunchMainForm.TabPopupItem_ClearClick(Sender: TObject);
begin
  if not ConfirmDialog(format(Language.Messages.ClearTab, [MainTabsNew.Tabs[MainTabsNew.TabIndex]]),
    Language.Messages.Confirmation)
  then
    exit;
  FLPanel.ClearPage(MainTabsNew.TabIndex);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.TabPopupItem_DeleteClick(Sender: TObject);
begin
  DeleteTab(MainTabsNew.TabIndex);
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.TabPopupItem_RenameClick(Sender: TObject);
begin
  RenameTab(MainTabsNew.TabIndex);
  SaveLinksCfgFile;
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

procedure TFlaunchMainForm.LnkToButton(ALink: Lnk; var AButton: TFLButton);
begin
  if ALink.active then
  begin
    AButton.InitializeData;
    AButton.Data.LType := ALink.ltype;
    AButton.Data.Exec := ALink.exec;
    AButton.Data.WorkDir := ALink.workdir;
    AButton.Data.Icon := ALink.icon;
    AButton.Data.IconIndex := ALink.iconindex;
    AButton.Data.Params := ALink.params;
    AButton.Data.DropFiles := ALink.dropfiles;
    AButton.Data.DropParams := ALink.dropparams;
    AButton.Data.Descr := ALink.descr;
    AButton.Data.Ques := ALink.ques;
    AButton.Data.Hide := ALink.hide;
    AButton.Data.Pr := ALink.pr;
    AButton.Data.WSt := ALink.wst;

    AButton.Data.AssignIcons;
    AButton.Repaint;
  end
  else
    AButton.FreeData;
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

/// <summary>���������� ������ ������ � ���</summary>
procedure TFlaunchMainForm.SaveLinksIconsToCache;
var
  ICFile: integer;
  Buffer: array[0..255] of char;
  BuffLen: integer;
  Stream: TMemoryStream;
  t,r,c: byte;
  PngImg: TPngImage;
  FilePath: string;
begin
  PngImg := TPngImage.Create;
  try
    FilePath := WorkDir + IconCacheDir + TPath.DirectorySeparatorChar;
    if not TDirectory.Exists(FilePath) then
      TDirectory.CreateDirectory(FilePath);

    for t := 0 to TabsCount - 1 do
      for r := 0 to RowsCount - 1 do
        for c := 0 to ColsCount - 1 do
          //--���� ������ ������� � � ��� ���� ������
          if (FLPanel.Buttons[t,r,c].IsActive) and (FLPanel.Buttons[t,r,c].HasIcon) then
          begin
            {*--��������� ������� � ������� ������ � ����--*}
            PngImg.Assign(FLPanel.Buttons[t,r,c].Data.IconBmp);
            PngImg.SaveToFile(FLPanel.Buttons[t,r,c].Data.IconCache);
            FLPanel.Buttons[t,r,c].Data.IconCache := '';
          end;
  finally
    PngImg.Free;
  end;
end;

/// <summary>���������� �������� � xml-����</summary>
procedure TFlaunchMainForm.SaveLinksSettings;
var
  RootNode, LinkNode, PanelNode, TabNode, IconNode, DropNode, WindowNode,
    PositionNode, TabRootNode, PanelRootNode, WindowRootNode: IXMLNode;
  t,r,c: byte;
  TempData: TFLDataItem;
  XMLDocument: IXMLDocument;
begin
  FLPanel.ExpandStrings := false;
  XMLDocument := TXMLDocument.Create(Self);
  XMLDocument.Options := [doNodeAutoIndent];
  XMLDocument.Active := true;
  RootNode := XMLDocument.AddChild('FLaunch');
  RootNode.AddChild('Version').NodeValue := GetFLVersion;
  RootNode.AddChild('Padding').NodeValue := lpadding;

  IconNode := RootNode.AddChild('Icons');
  IconNode.AddChild('Width').NodeValue := ButtonWidth;
  IconNode.AddChild('Height').NodeValue := ButtonHeight;

  RootNode.AddChild('TabsView').NodeValue := tabsview;
  RootNode.AddChild('AutoRun').NodeValue := autorun;
  RootNode.AddChild('Language').NodeValue := lngfilename;

  TabNode := RootNode.AddChild('TabsFont');
  TabNode.AddChild('Name').NodeValue := MainTabsNew.Font.Name;
  TabNode.AddChild('Size').NodeValue := MainTabsNew.Font.Size;

  WindowRootNode := RootNode.AddChild('Windows');
  WindowNode := WindowRootNode.AddChild('Window');

  PositionNode := WindowNode.AddChild('Position');
  PositionNode.AddChild('Left').NodeValue := PositionToPercent(Left, true);
  PositionNode.AddChild('Top').NodeValue := PositionToPercent(Top, false);

  WindowNode.AddChild('TitleBar').NodeValue := titlebar;
  WindowNode.AddChild('AlwaysOnTop').NodeValue := alwaysontop;
  WindowNode.AddChild('StatusBar').NodeValue := statusbarvis;
  WindowNode.AddChild('StartHidden').NodeValue := starthide;
  WindowNode.AddChild('ActiveTab').NodeValue := MainTabsNew.TabIndex + 1;

  TabRootNode := WindowNode.AddChild('Tabs');
  PanelRootNode := RootNode.AddChild('Panels');
  for t := 0 to TabsCountNew - 1 do
  begin
    TabNode := TabRootNode.AddChild('Tab');
    TabNode.Attributes['Number'] := t + 1;
    TabNode.AddChild('Name').NodeValue := TabNames[t];

    PanelNode := PanelRootNode.AddChild('Panel');
    PanelNode.AddChild('TabNumber').NodeValue := t + 1;
    PanelNode.AddChild('Rows').NodeValue := rowscount;
    PanelNode.AddChild('Columns').NodeValue := colscount;
    PanelNode.AddChild('Padding').NodeValue := LPadding;
    PanelNode.AddChild('Color').NodeValue := ColorToString(ButtonsColor);

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
        IconNode.AddChild('Cache').NodeValue := TempData.GetIconCacheRaw;

        LinkNode.AddChild('Parameters').NodeValue := TempData.Params;

        DropNode := LinkNode.AddChild('Drop');
        DropNode.AddChild('Allow').NodeValue := TempData.DropFiles;
        DropNode.AddChild('Parameters').NodeValue := TempData.DropParams;

        LinkNode.AddChild('Description').NodeValue := TempData.Descr;
        LinkNode.AddChild('NeedQuestion').NodeValue := TempData.Ques;
        LinkNode.AddChild('HideContainer').NodeValue := TempData.Hide;
        LinkNode.AddChild('Priority').NodeValue := TempData.Pr;
        LinkNode.AddChild('WindowState').NodeValue := TempData.WSt;
      end;
  end;
  XMLDocument.SaveToFile(WorkDir + 'FLaunch.xml');
  XMLDocument.Active := false;
  FLPanel.ExpandStrings := true;
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

/// <summary>���������� ������ ������ �� ����</summary>
procedure TFlaunchMainForm.LoadLinksIconsFromCache;
var
  t, r, c: Integer;
  PngImg: TPngImage;
begin
  PngImg := TPngImage.Create;
  try
    //--��������� �� ���� �������
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

/// <summary>���������� �������� ������ �� xml-�����</summary>
procedure TFlaunchMainForm.LoadLinksSettings;
var
  RootNode, LinkNode, IconNode, TabNode, WindowNode, PositionNode,
    TabRootNode, PanelRootNode, PanelNode, DropNode: IXMLNode;
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

  function GetColor(AParent: IXMLNode; AChildName: string): TColor;
  var
    Color: string;
  begin
    Result := clBtnFace;
    Color := GetStr(AParent, AChildName);
    if Color <> '' then
      Result := StringToColor(Color);
  end;

begin
  if not FileExists(WorkDir + 'FLaunch.xml') then
    Exit;
  XMLDocument := TXMLDocument.Create(Self);
  XMLDocument.Options := [doNodeAutoIndent];
  XMLDocument.Active := true;
  XMLDocument.LoadFromFile(WorkDir + 'FLaunch.xml');
  RootNode := XMLDocument.ChildNodes.FindNode('FLaunch');
  if (not Assigned(RootNode)) or (not RootNode.HasChildNodes) then
    Exit;

  Version := GetStr(RootNode, 'Version');
  lpadding := GetInt(RootNode, 'Padding');

  IconNode := RootNode.ChildNodes.FindNode('Icons');
  if Assigned(IconNode) and IconNode.HasChildNodes then
  begin
    ButtonWidth := GetInt(IconNode, 'Width');
    ButtonHeight := GetInt(IconNode, 'Height');
    FLPanel.ButtonWidth := ButtonWidth;
    FLPanel.ButtonHeight := ButtonHeight;
  end;

  tabsview := GetInt(RootNode, 'TabsView');
  autorun := GetBool(RootNode, 'AutoRun');
  lngfilename := GetStr(RootNode, 'Language');

  TabNode := RootNode.ChildNodes.FindNode('TabsFont');
  if Assigned(TabNode) and TabNode.HasChildNodes then
  begin
    MainTabsNew.Font.Name := GetStr(TabNode, 'Name');
    MainTabsNew.Font.Size := GetInt(TabNode, 'Size');
  end;

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
  MainTabsNew.TabIndex := GetInt(WindowNode, 'ActiveTab') - 1;

  TabsCountNew := 0;
  TabNames.Clear;
  TabRootNode := WindowNode.ChildNodes.FindNode('Tabs');
  if (not Assigned(TabRootNode)) or (not TabRootNode.HasChildNodes) then
    Exit;

  TabNode := TabRootNode.ChildNodes.First;
  while Assigned(TabNode) do
  begin
    Inc(TabsCountNew);
    TabNumber := TabNode.Attributes['Number'];
    GrowTabNames(TabNumber);
    TabNames.Strings[TabNumber - 1] := GetStr(TabNode, 'Name');

    TabNode := TabNode.NextSibling;
  end;

  PanelRootNode := RootNode.ChildNodes.FindNode('Panels');
  if (not Assigned(PanelRootNode)) or (not PanelRootNode.HasChildNodes) then
    Exit;

  PanelNode := PanelRootNode.ChildNodes.First;
  for TabNumber := 0 to TabsCountNew - 1 do
  begin
    if (not Assigned(PanelNode)) or (not PanelNode.HasChildNodes) then
      Exit;

    RowsCount := GetInt(PanelNode, 'Rows');
    ColsCount := GetInt(PanelNode, 'Columns');
    FLPanel.RowsCount := RowsCount;
    FLPanel.ColsCount := ColsCount;
    LPadding := GetInt(PanelNode, 'Padding');
    FLPanel.Padding := LPadding;
    ButtonsColor := GetColor(PanelNode, 'Color');
    FLPanel.ButtonColor := ButtonsColor;

    LinkNode := PanelNode.ChildNodes.FindNode('Link');
    if Assigned(LinkNode) and LinkNode.HasChildNodes then
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
    end;

    PanelNode := PanelNode.NextSibling;
  end;
  XMLDocument.Active := false;
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
          nowactive := Active;
          ChWinView((not nowactive) or not (Showing));
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

  //--��������� ��������� ������
  SaveLinksSettings;
  //--��������� ������ ������ � ���
  SaveLinksIconsToCache;

  //--������� ������ ���� �������
  TabNames.Free;
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
begin
  if FLPanel.Buttons[t, r, c].IsActive then
    FLPanel.Buttons[t, r, c].Data.AssignIcons;
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
      ButtonPopupItem_RunClick(Nil);
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
            OnClick := PanelClick;
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

procedure TFlaunchMainForm.ButtonPopupItem_ClearClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.FrameColor := clBlue;
  if ConfirmDialog(Format(Language.Messages.DeleteButton, [ExtractFileName(TempButton.Data.Exec)]),
    Language.Messages.Confirmation)
  then
    TempButton.FreeData;
  TempButton.RemoveFrame;
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.ButtonPopupItem_ExportClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.FrameColor := clBlue;
  SaveButtonDialog.FileName := ExtractFileNameNoExt(TempButton.Data.Exec);
  if SaveButtonDialog.Execute(Handle) then
    ExportButton(TempButton, SaveButtonDialog.FileName);
  TempButton.RemoveFrame;
end;

procedure TFlaunchMainForm.ButtonPopupItem_ImportClick(Sender: TObject);
var
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.FrameColor := clBlue;
  if OpenButtonDialog.Execute(Handle) then
    ImportButton(TempButton, OpenButtonDialog.FileName);
  TempButton.RemoveFrame;
  SaveLinksCfgFile;
end;

procedure TFlaunchMainForm.ButtonPopupItem_PropsClick(Sender: TObject);
var
  flfrm: TFilePropertiesForm;
  TempButton: TFLButton;
begin
  TempButton := FLPanel.LastUsedButton;
  TempButton.FrameColor := clBlue;

  PropertiesMode := 0;
  if Assigned(TempButton.Data) then
    PropertiesMode := TempButton.Data.LType
  else
    if ButtonPopupItem_TypeFile.Checked then
      PropertiesMode := 1;

  if PropertiesMode = 0 then
    LnkToButton(TProgrammPropertiesForm.Execute(ButtonToLnk(TempButton)), TempButton);
  if PropertiesMode = 1 then
    LnkToButton(TFilePropertiesForm.Execute(ButtonToLnk(TempButton)), TempButton);
  TempButton.RemoveFrame;
end;

procedure TFlaunchMainForm.ButtonPopupItem_RunClick(Sender: TObject);
begin
  FLPanel.LastUsedButton.Click;
end;

procedure TFlaunchMainForm.ButtonPopupMenuPopup(Sender: TObject);
begin
  FLPanel.LastUsedButton.MouseUp(mbLeft, [], 0, 0);
end;

function TFlaunchMainForm.ButtonToLnk(AButton: TFLButton): lnk;
begin
  Result.active := AButton.IsActive;
  if Assigned(AButton.Data) then
  begin
    Result.ltype := AButton.Data.LType;
    Result.exec := AButton.Data.Exec;
    Result.workdir := AButton.Data.WorkDir;
    Result.icon := AButton.Data.Icon;
    Result.iconindex := AButton.Data.IconIndex;
    Result.params := AButton.Data.Params;
    Result.dropfiles := AButton.Data.DropFiles;
    Result.dropparams := AButton.Data.DropParams;
    Result.descr := AButton.Data.Descr;
    Result.ques := AButton.Data.Ques;
    Result.hide := AButton.Data.Hide;
    Result.pr := AButton.Data.Pr;
    Result.wst := AButton.Data.WSt;
  end;
end;

procedure TFlaunchMainForm.ChangeWndSize;
begin
  StatusBar.Height := MulDiv(19, Screen.PixelsPerInch, DesignDPI);
  Width := Width + FLPanel.ActualSize.Width - FLPanel.Width;
  Height := Height + FLPanel.ActualSize.Height - FLPanel.Height;
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
    0: MainTabsNew.Style := tsTabs;
    1: MainTabsNew.Style := tsButtons;
    2: MainTabsNew.Style := tsFlatButtons;
  end;
  if AlwaysOnTop then
    FormStyle := fsStayOnTop;

  ChangeWndSize;
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

procedure TFlaunchMainForm.FLPanelButtonClick(Sender: TObject;
  Button: TFLButton);
begin
  if not Button.IsActive then Exit;
  NewProcess(ButtonToLnk(Button), Handle);
end;

procedure TFlaunchMainForm.FLPanelButtonMouseDown(Sender: TObject;
  MouseButton: TMouseButton; Button: TFLButton);
begin
  //--���� ���� ������ ������ ������ ����
  if MouseButton = mbRight then
  begin
    {*--����������/������������ ����������� ������ ������������ ���� ������--*}
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
  Link: lnk;

  //--����������� ��������� ���� (��������� %SYSTEMROOT% � �.�.)
  function GetRealPath(Path: PChar): string;
  var
    TempPChar: array[0..MAX_PATH] of char;
  begin
    ExpandEnvironmentStrings(Path, TempPChar, SizeOf(TempPChar));
    Result := string(TempPChar);
  end;
begin
  Link := ButtonToLnk(Button);
  //--���� ������ ������� � "�����" ��������� �������������� �����
  if (Link.active) and (Link.dropfiles) then
  begin
    NewProcess(Link, Handle, FileName);
    exit;
  end;
  {*--���� ������ �������, ������ ������������� ������--*}
  if Link.active then
  begin
    Button.FrameColor := clBlue;
    if not ConfirmDialog(Language.Messages.BusyReplace,
      Language.Messages.Confirmation)
    then
    begin
      Button.RemoveFrame;
      Exit;
    end;
    Button.RemoveFrame;
  end;
  Ext := ExtractFileExt(FileName).ToLower;
  //--���� ��� ��������� ���� ������
  if Ext = '.flb' then
  begin
    Button.FrameColor := clBlue;
    if ConfirmDialog(format(Language.Messages.ImportButton,[FileName]), Language.Messages.Confirmation) then
      ImportButton(Button, FileName);
    Button.RemoveFrame;
    exit;
  end;
  //--�������������� ������ ������
  if not Button.IsActive then
    Button.InitializeData;
  //--���� ��� ��������� �����
  if Ext = '.lnk' then
  begin
    StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, FileName, MAX_PATH - 1);
    //--��������� ���������� � ������
    GetLinkInfo(@lnkinfo);
    {*--��������� ���������� � ���� ������--*}
    Button.Data.Exec := GetRealPath(LnkInfo.FullPathAndNameOfFileToExecute);
    Button.Data.IconIndex := LnkInfo.IconIndex;
    Button.Data.Icon := GetRealPath(LnkInfo.FullPathAndNameOfFileContiningIcon);
    if Button.Data.Icon = '' then
      Button.Data.Icon := Button.Data.Exec;
    Button.Data.WorkDir := GetRealPath(LnkInfo.FullPathAndNameOfWorkingDirectroy);
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
  //--���� ����������� ����
  if (Ext = '.exe') or (Ext = '.bat') then
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
  //--������ ������ �� ������
  Button.Data.AssignIcons;
  //--�������������� ������
  Button.Repaint;

  SaveLinksCfgFile;
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
var
  sini: TIniFile;
  i: Integer;
begin
  //--������� ������ ���� �������
  TabNames := TStringList.Create;
  //--������� ��������� ������ � ��������
  FLPanel := TFLPanel.Create(MainTabsNew, 1);
  ChPos := true;
  PanelColor := clBtnFace;
  FormColor := clBtnFace;
  randomize;
  registerhotkey(Handle, HotKeyID, mod_control or mod_win, 0);
  fl_dir := ExtractFilePath(Application.ExeName);
  fl_root := IncludeTrailingPathDelimiter(ExtractFileDrive(fl_dir));

  sini := TIniFile.Create(fl_dir + 'UseProfile.ini'); //��������� ���� ��������� �������� ��� ����������� ������ ������ ��������� � ����� �������� ��������
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
  ButtonsColor := PanelColor;
  TabsCountNew := tabscount;
  ButtonWidth := iconwidth - panelzoom;
  ButtonHeight := iconheight - panelzoom;

  //--������ ��������� ������
  LoadLinksSettings;
  Language.AddNotifier(LoadLanguage);
  Language.Load(lngfilename);
  //--���������/��������� ������������
  SetAutorun(Autorun);
  {*--��������� ���������� FL_*--*}
  FLPanel.SetFLVariable('FL_DIR', FL_DIR);
  FLPanel.SetFLVariable('FL_ROOT', FL_ROOT);
  {*--��������� ������� ������--*}
  FLPanel.OnButtonMouseDown := FLPanelButtonMouseDown;
  FLPanel.OnButtonClick := FLPanelButtonClick;
  FLPanel.OnButtonMouseMove := FLPanelButtonMouseMove;
  FLPanel.OnButtonMouseLeave := FLPanelButtonMouseLeave;
  FLPanel.OnDropFile := FLPanelDropFile;
  FLPanel.ButtonsPopup := ButtonPopupMenu;
  for I := 1 to TabsCountNew do
    TabNames.Add('');
  SetTabNames;
  //--������ ������ ������ �� ����
  LoadLinksIconsFromCache;

  GenerateWnd;
  MainTabsNew.TabIndex := tabind;
  LoadLinksCfgFile;
  if fileexists(workdir + '.session') then
    LoadLinks
  else
    begin
      LoadLinksFromCash;
      //--������� ����, ������� ����� ���������������� ������. ��� ���������� ���������� ��������� ���� ����� ������
      FileClose(FileCreate(workdir + '.session'));
      SetFileAttributes(PChar(workdir + '.session'), FILE_ATTRIBUTE_HIDDEN);
    end;
  TrayIcon.Hint := Format('%s %s',[cr_progname, GetFLVersion]);
  if not StartHide then
    ChWinView(True)
  else
    Application.ShowMainForm := False;
  StatusBar.Panels[1].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
  ChPos := false;
end;

//--������� ��� ������������ �������
procedure TFlaunchMainForm.MainTabsNewChange(Sender: TObject);
begin
  //--������������� ������� �������� <- ������ �������
  FLPanel.PageNumber := MainTabsNew.TabIndex;
  MainTabsNew.SetFocus;
end;

//--������� ��� ���������� ��������������� ��� �������� �������
//--��������� ������� ������� � ������� Drag'N'Drop
procedure TFlaunchMainForm.MainTabsNewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: byte;
  Rect: TRect;
  TempStr: string;
begin
  //--���� �������������� ������ - �������
  if (Source is TTabControl) then
  begin
    //--���������� ��� �������
    for i := 0 to TabsCountNew - 1 do
    begin
      //--���������� ������ �������
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--���� ������� �������, ��� ������� ��������� ������
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

//--������� ��� ������������� ��� �������� �������
procedure TFlaunchMainForm.MainTabsNewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  i: byte;
  Rect: TRect;
begin
  //--���� �������������� ������ - ������
  if (Source is TFLButton) then
  begin
    //--���� �������������� ������ �������, ��������� Drop
    Accept := FLPanel.LastDraggedButton.IsActive;
    if not Accept then
      Exit;
    //--���������� ��� �������
    for i := 0 to TabsCountNew - 1 do
    begin
      //--���������� ������ �������
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--���� ������� �������, ��� ������� ��������� ������
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

//--������� ��� ������� ������� ���� �� �������
procedure TFlaunchMainForm.MainTabsNewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: byte;
  Rect: TRect;
  MousePos: TPoint;
begin
  if Button = mbLeft then
    if ssCtrl in Shift then
      MainTabsNew.BeginDrag(false);
  if Button = mbRight then
  begin
    //--���������� ��� �������
    for i := 0 to TabsCountNew - 1 do
    begin
      //--���������� ������ �������
      MainTabsNew.Perform(TCM_GETITEMRECT, i, lParam(@Rect));
      //--���� ������� �������, ��� ������� ��������� ������
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

//--��������������� �������� ������ � ����
procedure TFlaunchMainForm.ExportButton(Button: TFLButton; FileName: string);
var
  SIni: TIniFile;
begin
  FLPanel.ExpandStrings := false;
  SIni := TIniFile.Create(FileName);
  SIni.WriteString(BUTTON_INI_SECTION, 'version', GetFLVersion);
  SIni.WriteString(BUTTON_INI_SECTION, 'object', Button.Data.Exec);
  SIni.WriteString(BUTTON_INI_SECTION, 'workdir', Button.Data.WorkDir);
  SIni.WriteString(BUTTON_INI_SECTION, 'icon', Button.Data.Icon);
  SIni.WriteInteger(BUTTON_INI_SECTION, 'iconindex', Button.Data.IconIndex);
  SIni.WriteString(BUTTON_INI_SECTION, 'parameters', Button.Data.Params);
  SIni.WriteBool(BUTTON_INI_SECTION, 'dropfiles', Button.Data.DropFiles);
  SIni.WriteString(BUTTON_INI_SECTION, 'dropparameters', Button.Data.DropParams);
  SIni.WriteString(BUTTON_INI_SECTION, 'describe', Button.Data.Descr);
  SIni.WriteBool(BUTTON_INI_SECTION, 'question', Button.Data.Ques);
  SIni.WriteBool(BUTTON_INI_SECTION, 'hide', Button.Data.Hide);
  SIni.WriteInteger(BUTTON_INI_SECTION, 'priority', Button.Data.Pr);
  SIni.WriteInteger(BUTTON_INI_SECTION, 'windowstate', Button.Data.WSt);
  SIni.Free;
  FLPanel.ExpandStrings := true;
end;

//--�������������� �������� ������ �� �����
procedure TFlaunchMainForm.ImportButton(Button: TFLButton; FileName: string);
var
  SIni: TIniFile;
begin
  SIni := TIniFile.Create(FileName);
  //--�������������� ������ ������
  if not Button.IsActive then Button.InitializeData;
  Button.Data.Exec := SIni.ReadString(BUTTON_INI_SECTION, 'object', '');
  Button.Data.WorkDir := SIni.ReadString(BUTTON_INI_SECTION, 'workdir', '');
  Button.Data.Icon := SIni.ReadString(BUTTON_INI_SECTION, 'icon', '');
  Button.Data.IconIndex := SIni.ReadInteger(BUTTON_INI_SECTION, 'iconindex', 0);
  Button.Data.Params := SIni.ReadString(BUTTON_INI_SECTION, 'parameters', '');
  Button.Data.DropFiles := SIni.ReadBool(BUTTON_INI_SECTION, 'dropfiles', false);
  Button.Data.DropParams := SIni.ReadString(BUTTON_INI_SECTION, 'dropparameters', '');
  Button.Data.Descr := SIni.ReadString(BUTTON_INI_SECTION, 'describe', '');
  Button.Data.Ques := SIni.ReadBool(BUTTON_INI_SECTION, 'question', false);
  Button.Data.Hide := SIni.ReadBool(BUTTON_INI_SECTION, 'hide', false);
  Button.Data.Pr := SIni.ReadInteger(BUTTON_INI_SECTION, 'priority', 0);
  Button.Data.WSt := SIni.ReadInteger(BUTTON_INI_SECTION, 'windowstate', 0);
  SIni.Free;
  //--������ ������ �� ������
  Button.Data.AssignIcons;
  //--�������������� ������
  Button.Repaint;
end;

/// <summary>������� ����������, ��������� �� ���������� t,r,c � ��������
/// �������� ������� ������</summary>
function TFlaunchMainForm.IsTRCInRange(t, r, c: byte): boolean;
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

procedure TFlaunchMainForm.PanelClick(Sender: TObject);
var
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  GlobTab := t;
  GlobRow := r;
  GlobCol := c;
  NewProcess(links[GlobTab][GlobRow][GlobCol], Handle);
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
      GlobTab := t;
      GlobRow := r;
      GlobCol := c;
      NewProcess(links[GlobTab][GlobRow][GlobCol], Handle, FileName);
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
