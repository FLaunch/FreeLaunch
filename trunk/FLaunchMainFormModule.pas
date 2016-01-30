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
  ComObj, ActiveX, ShlObj, IniFiles, Registry, Shfolder,
  ProgrammPropertiesFormModule,
  FilePropertiesFormModule,
  RenameTabFormModule,
  SettingsFormModule,
  AboutFormModule;

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

  cr_wmr = 'LwdGh0Gehoi5S8vIsRwbUkYGR/yi6o4mEjQsjPYydAtpExXAvpcd2NJKwIEGb/zT9+fiVy+wLE/bm83PjfhnJb4eEd6K3W8/2PSbJau1/NBsTQllniOKilzhthmOdvnPNj3Cew==';
  cr_wmz = 'CPvMa7jQbIiPoQQLkNiH/SgUxBOi08nhPIGBYQEmFwgEqvdjJlgbiiQ2v246uZJSsj92oKN4D9L6tzKGHw36VapUjhR9nOx7/HcnpuE5vy7w8oENw4mZX6Hird+Bd3UYQzNlcg==';
  cr_author = 'MqAVLYAp+ClMW0OvEbG72b+iQDhRquregVJVIjOGUDOLS1FnkDRTYpcF7yaseE7WloZhVOTry3gHi56YZOM6JokvdlHd6fzDGNiqA1j0KrxaeL1/zycevC4Cie1i2e+QmqNtsw==';
  cr_authormail = 'RxA9cIJJqF4Z4YkH7ZgDB8P5TBlbTAugS+pTNXN7b3lTVTngf6HkEnvHI4s9osqBuqYE6Tz8WFbbijvbbDJUOGHlA65BWVIoZB+NKBoGSPP9vyhG4OwCRoZfw5TaLXZiAdWz+g==';
  cr_progname = 'M9QS02WOy2aVszJjgS9A3pATAVKX+OJBUawqI/WDDBjbx2uEpfseaVLC5gxHXj63Hr7eXYlmkwFc1ZryCzofRotorHA3hs1EhMA9y92GkyvZw6zmMhGQXQtXB7J5vlZTXCkdkQ==';

  DesignDPI = 96;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;
  PShellLinkInfoStruct = ^TShellLinkInfoStruct;
  TShellLinkInfoStruct = record
    FullPathAndNameOfLinkFile: array[0..MAX_PATH] of Char;
    FullPathAndNameOfFileToExecute: array[0..MAX_PATH] of Char;
    ParamStringsOfFileToExecute: array[0..MAX_PATH] of Char;
    FullPathAndNameOfWorkingDirectroy: array[0..MAX_PATH] of Char;
    Description: array[0..MAX_PATH] of Char;
    FullPathAndNameOfFileContiningIcon: array[0..MAX_PATH] of Char;
    IconIndex: Integer;
    HotKey: Word;
    ShowCommand: Integer;
    FindData: TWIN32FINDDATA;
  end;

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
    procedure FormCreate(Sender: TObject);
    procedure MainTabsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure NI_propClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NI_ClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  private
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure WMDisplayChange(var Msg: TWMDisplayChange); message WM_DISPLAYCHANGE;
    procedure TrayIconMouse(var Msg: TMessage); message WM_USER + 20;
    procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;

    procedure TrayIconProc(n: integer);
    procedure LoadLinksFromCash;
    procedure LoadPanelLinks(Index: integer);
    procedure ClearLinks(Index: integer);
    procedure ImportButton(filename: string; t,r,c: integer);
    //function B64Encode(data:string): string;
    //function Encrypt(const InString: string; StartKey: integer): string;
    function Decrypt(const InString: AnsiString; StartKey: integer): string;
    //function FormatStr(s: string): string;
    function DeFormatStr(s: string): string;
    function GetSpecialDir(const CSIDL: byte): string;
    function ColorStrToColor(s: string): integer;
    function LoadLinksCfgFileV121_12_11: boolean;
    function LoadLinksCfgFileV10: boolean;
    function LoadLinksCfgFile: boolean;
    function GetFileIcon(FileName: String; OpenIcon: Boolean; Index: integer): hicon;
    function MyCutting(s: string; l: integer): string;
    procedure GetCoordinates(Sender: TObject; var t: integer; var r: integer; var c: integer);
    procedure SmoothResize(Src, Dst: TBitmap);
    //procedure ModColors(Bitmap: TBitmap; Color: TColor);
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
    procedure LoadLanguage(filename: string);
    function DefNameOfTab(tn: string): boolean;
    procedure SetAutorun(b: boolean);
    procedure LoadIni;
    procedure SaveIni;
    procedure DefaultHandler(var Msg); override;
    function PositionToPercent(p: integer; iswidth: boolean): integer;
    function PercentToPosition(p: integer; iswidth: boolean): integer;
    function GetFLVersion: string;
    procedure LoadIc(t, r, c: integer);
    function GetAbsolutePath(s: string): string;
    procedure LoadLinks;
    function parse(s: string; frm: string = ''): string;
    function FullDecrypt(s: string): string;
    procedure LoadIcFromFileNoModif(var Im: TImage; FileName: string; Index: integer);
    procedure SaveLinksCfgFile;
    procedure GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
    function GetFileDescription(FileName: string): string;
    function ExtractFileNameNoExt(FileName: string): string;
    function GetIconCount(FileName: String): integer;
    procedure SaveLinksToCash;
    procedure ChWinView(b: boolean);
    function B64Decode(data: AnsiString): AnsiString;
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
  lngstrings: array[1..20] of string;
  lng_about_strings: array[1..6] of string;
  lng_iconselect_strings: array[1..4] of string;
  lng_properties_strings: array[1..23] of string;
  lng_tabname_strings: array[1..1] of string;
  lng_settings_strings: array[1..22] of string;
  ChPos: boolean = false;
  WM_TASKBARCREATED: Cardinal;

implementation

{$R Manifest.res}
{$R png.res}
{$R *.dfm}

procedure ThreadLaunch(p: pointer);
var
  WinType,Prior: integer;
  params: string;
  execparams, path: string;
  pi : TProcessInformation;
  si : TStartupInfo;
  t,r,c: integer;
begin
  t := GlobTab;
  r := GlobRow;
  c := GlobCol;
  if not links[t][r][c].active then
    exit;
  if ((links[t][r][c].ques) and (MessageBox(FlaunchMainForm.Handle,
    PChar(Format(lngstrings[9], [ExtractFileName(FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec))])),
    PChar(lngstrings[7]), MB_ICONQUESTION or MB_YESNO) = IDNO)) then
    exit;
  case links[t][r][c].wst of
    0: WinType := SW_SHOW;
    1: WinType := SW_SHOWMAXIMIZED;
    2: WinType := SW_SHOWMINIMIZED;
    3: WinType := SW_HIDE;
  end;
  if links[t][r][c].ltype = 0 then
    begin
      if not FileExists(FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec)) then
        begin
          MessageBox(FlaunchMainForm.Handle,
            PChar(format(lngstrings[18],[ExtractFileName(FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec))])),
            PChar(lngstrings[17]), MB_ICONWARNING or MB_OK);
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
      execparams := Format('"%s" %s', [FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec), params]);
      path := FlaunchMainForm.GetAbsolutePath(links[t][r][c].workdir);

      ZeroMemory(@si, sizeof(si));
      si.cb := SizeOf(si);
      si.dwFlags := STARTF_USESHOWWINDOW;
      si.wShowWindow := WinType;
      CreateProcess(nil, PChar(execparams), nil, nil, false, Prior, nil,
        PChar(path), si, pi);
      if links[t][r][c].hide then FlaunchMainForm.ChWinView(false);
    end;
  if links[t][r][c].ltype = 1 then
    begin
      path := FlaunchMainForm.GetAbsolutePath(links[t][r][c].workdir);
      ShellExecute(FlaunchMainForm.Handle, 'open',
        PChar(FlaunchMainForm.GetAbsolutePath(links[t][r][c].exec)), nil, PChar(path), WinType);
    end;
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
  s := StringReplace(s, '{FL_ROOT}', fl_root, [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(s, '{FL_DIR}', fl_dir, [rfReplaceAll, rfIgnoreCase]);
end;

function TFlaunchMainForm.parse(s: string; frm: string = ''): string;
begin
  result := StringReplace(s, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);
  if frm <> '' then
    begin
      result := StringReplace(result, '%%', frm, [rfReplaceAll]);
      if pos(frm, result) = 0 then
        result := result + ' ' + frm;
    end;
end;

{function TFlaunchMainForm.B64Encode(data:string): string;
const
  b64 : array [0..63] of char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  ic,len : integer;
  pi, po : TPAByte;
  c1 : dword;
begin
  len:=length(data);
  if len > 0 then
    begin
      SetLength(result, ((len + 2) div 3) * 4);
      pi := pointer(data);
      po := pointer(result);
      for ic := 1 to len div 3 do
        begin
          c1 := pi^[0] shl 16 + pi^[1] shl 8 + pi^[2];
          po^[0] := byte(b64[(c1 shr 18) and $3f]);
          po^[1] := byte(b64[(c1 shr 12) and $3f]);
          po^[2] := byte(b64[(c1 shr 6) and $3f]);
          po^[3] := byte(b64[(c1 ) and $3f]);
          inc(dword(po), 4);
          inc(dword(pi), 3);
        end;
      case len mod 3 of
        1 : begin
          c1 := pi^[0] shl 16;
          po^[0] := byte(b64[(c1 shr 18) and $3f]);
          po^[1] := byte(b64[(c1 shr 12) and $3f]);
          po^[2] := byte('=');
          po^[3] := byte('=');
        end;
        2 : begin
          c1 := pi^[0] shl 16 + pi^[1] shl 8;
          po^[0] := byte(b64[(c1 shr 18) and $3f]);
          po^[1] := byte(b64[(c1 shr 12) and $3f]);
          po^[2] := byte(b64[(c1 shr 6) and $3f]);
          po^[3] := byte('=');
        end;
      end;
    end
  else
    result := '';
end;}

function TFlaunchMainForm.B64Decode(data: AnsiString): AnsiString;
var
  i1,i2,len : integer;
  pi, po : TPAByte;
  ch1 : AnsiChar;
  c1 : dword;
begin
  len:=length(data);
  if (len > 0) and (len mod 4 = 0) then
    begin
      len := len shr 2;
      SetLength(result, len * 3);
      pi := pointer(data);
      po := pointer(result);
      for i1 := 1 to len do
        begin
          c1 := 0;
          i2 := 0;
          while true do
            begin
              ch1 := AnsiChar(pi^[i2]);
              case ch1 of
                'A'..'Z' : c1 := c1 or (dword(ch1) - byte('A') );
                'a'..'z' : c1 := c1 or (dword(ch1) - byte('a') + 26);
                '0'..'9' : c1 := c1 or (dword(ch1) - byte('0') + 52);
                '+' : c1 := c1 or 62;
                '/' : c1 := c1 or 63;
              else
                begin
                  if i2 = 3 then
                    begin
                      po^[0] := c1 shr 16;
                      po^[1] := byte(c1 shr 8);
                      SetLength(result, Length(result) - 1);
                    end
                  else
                    begin
                      po^[0] := c1 shr 10;
                      SetLength(result, Length(result) - 2);
                    end;
                  exit;
                end;
              end;
              if i2 = 3 then break;
              inc(i2);
              c1 := c1 shl 6;
            end;
          po^[0] := c1 shr 16;
          po^[1] := byte(c1 shr 8);
          po^[2] := byte(c1);
          inc(dword(pi), 4);
          inc(dword(po), 3);
        end;
    end
  else
    result := '';
end;

{function TFlaunchMainForm.Encrypt(const InString: string; StartKey: integer): string;
var
  I: Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  end;
end;}

function TFlaunchMainForm.Decrypt(const InString: AnsiString; StartKey: integer): string;
var
  I: Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + AnsiCHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  end;
end;

{function TFlaunchMainForm.FormatStr(s: string): string;
var
  pos, len, i: byte;
begin
  result := '';
  len := byte(length(s));
  pos := random(86 - len) + 4;
  result := chr(pos) + chr(len);
  for i := 3 to 100 do
    result := result + chr(random(256));
  for i := 1 to len do
    result[pos + i - 1] := s[i];
end;}

function TFlaunchMainForm.DeFormatStr(s: string): string;
var
  pos, len: byte;
begin
  result := '';
  pos := ord(s[1]);
  len := ord(s[2]);
  result := copy(s, pos, len);
end;

function TFlaunchMainForm.FullDecrypt(s: string): string;
begin
  result := '';
  if length(s) <> 136 then exit;
  result := DeFormatStr(Decrypt(B64Decode(s), 674));
end;

{function TFlaunchMainForm.FullEncrypt(s: string): string;
begin
  result := B64Encode(Encrypt(FormatStr(s), 674));
end;}

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

procedure TFlaunchMainForm.LoadLanguage(filename: string);
const
  mainsect = 'main';
  aboutsect = 'about';
  iconselectsect = 'iconselect';
  propertiessect = 'properties';
  tabnamesect = 'tabname';
  settingssect = 'settings';
var
  i: integer;
  lfile: TIniFile;
begin
  lfile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + filename);
  Caption := FullDecrypt(cr_progname);
  lngstrings[1] := parse(lfile.ReadString(mainsect,'tabname',''), '%d');
  for i := 1 to maxt do
    if FlaunchMainForm.MainTabs.Pages[i-1].Caption = '' then FlaunchMainForm.MainTabs.Pages[i-1].Caption := Format(lngstrings[1],[i]);
  lngstrings[2] := parse(lfile.ReadString(mainsect,'ni_settings',''));
  lngstrings[3] := parse(lfile.ReadString(mainsect,'ni_about',''));
  lngstrings[4] := parse(lfile.ReadString(mainsect,'location',''), '%s');
  lngstrings[5] := parse(lfile.ReadString(mainsect,'parameters',''), '%s');
  lngstrings[6] := parse(lfile.ReadString(mainsect,'description',''), '%s');
  lngstrings[7] := parse(lfile.ReadString(mainsect,'confirmation',''));
  lngstrings[8] := parse(lfile.ReadString(mainsect,'message1',''), '%s');
  lngstrings[9] := parse(lfile.ReadString(mainsect,'message2',''), '%s');
  lngstrings[10] := parse(lfile.ReadString(mainsect,'message3',''), '%s');
  lngstrings[11] := parse(lfile.ReadString(mainsect,'message4',''), '%s');
  lngstrings[12] := parse(lfile.ReadString(mainsect,'message5',''), '%s');
  lngstrings[13] := parse(lfile.ReadString(mainsect,'message6',''));
  lngstrings[14] := parse(lfile.ReadString(mainsect,'message7',''), '%s');
  lngstrings[17] := parse(lfile.ReadString(mainsect,'caution',''));
  lngstrings[18] := parse(lfile.ReadString(mainsect,'message8',''), '%s');
  NI_Show.Caption := parse(lfile.ReadString(mainsect,'ni_show',''));
  NI_Settings.Caption := lngstrings[2];
  NI_About.Caption := lngstrings[3];
  NI_Close.Caption := parse(lfile.ReadString(mainsect,'ni_close',''));
  NI_Run.Caption := parse(lfile.ReadString(mainsect,'ni_run',''));
  NI_TypeProgramm.Caption := parse(lfile.ReadString(mainsect,'ni_tprogram',''));
  NI_TypeFile.Caption := parse(lfile.ReadString(mainsect,'ni_tfile',''));
  NI_Export.Caption := parse(lfile.ReadString(mainsect,'ni_export',''));
  NI_Import.Caption := parse(lfile.ReadString(mainsect,'ni_import',''));
  NI_Clear.Caption := parse(lfile.ReadString(mainsect,'ni_clear',''));
  NI_Prop.Caption := parse(lfile.ReadString(mainsect,'ni_prop',''));
  NI_Rename.Caption := parse(lfile.ReadString(mainsect,'ni_rename',''));
  NI_ClearTab.Caption := parse(lfile.ReadString(mainsect,'ni_cleartab',''));
  NI_DeleteTab.Caption := parse(lfile.ReadString(mainsect,'ni_deletetab',''));
  NI_Group.Caption := parse(lfile.ReadString(mainsect,'ni_group',''));
  SaveButtonDialog.Filter := parse(lfile.ReadString(mainsect,'flbfilter','')) + '|*.flb';
  OpenButtonDialog.Filter := parse(lfile.ReadString(mainsect,'flbfilter','')) + '|*.flb';
  lngstrings[15] := parse(lfile.ReadString(mainsect,'ok',''));
  lngstrings[16] := parse(lfile.ReadString(mainsect,'cancel',''));

  lng_about_strings[1] := parse(lfile.ReadString(aboutsect,'about',''));
  lng_about_strings[2] := parse(lfile.ReadString(aboutsect,'version',''));
  lng_about_strings[3] := parse(lfile.ReadString(aboutsect,'author',''));
  lng_about_strings[4] := parse(lfile.ReadString(aboutsect,'translate',''));
  lng_about_strings[5] := parse(lfile.ReadString('information','author',''));
  lng_about_strings[6] := parse(lfile.ReadString(aboutsect,'donate',''));

  lng_iconselect_strings[1] := parse(lfile.ReadString(iconselectsect,'iconselect',''));
  lng_iconselect_strings[2] := parse(lfile.ReadString(iconselectsect,'file',''));
  lng_iconselect_strings[3] := parse(lfile.ReadString(iconselectsect,'index',''));
  lng_iconselect_strings[4] := parse(lfile.ReadString(iconselectsect,'of',''), '%d');

  lng_properties_strings[1] := parse(lfile.ReadString(propertiessect,'properties',''));
  lng_properties_strings[2] := parse(lfile.ReadString(propertiessect,'folder',''));
  lng_properties_strings[3] := parse(lfile.ReadString(propertiessect,'object',''));
  lng_properties_strings[4] := parse(lfile.ReadString(propertiessect,'parameters',''));
  lng_properties_strings[5] := parse(lfile.ReadString(propertiessect,'description',''));
  lng_properties_strings[6] := parse(lfile.ReadString(propertiessect,'priority',''));
  lng_properties_strings[7] := parse(lfile.ReadString(propertiessect,'priority_normal',''));
  lng_properties_strings[8] := parse(lfile.ReadString(propertiessect,'priority_high',''));
  lng_properties_strings[9] := parse(lfile.ReadString(propertiessect,'priority_low',''));
  lng_properties_strings[10] := parse(lfile.ReadString(propertiessect,'view',''));
  lng_properties_strings[11] := parse(lfile.ReadString(propertiessect,'view_normal',''));
  lng_properties_strings[12] := parse(lfile.ReadString(propertiessect,'view_max',''));
  lng_properties_strings[13] := parse(lfile.ReadString(propertiessect,'view_min',''));
  lng_properties_strings[14] := parse(lfile.ReadString(propertiessect,'view_hidden',''));
  lng_properties_strings[15] := parse(lfile.ReadString(propertiessect,'be_hint',''));
  lng_properties_strings[16] := parse(lfile.ReadString(propertiessect,'rp_hint',''));
  lng_properties_strings[17] := parse(lfile.ReadString(propertiessect,'options',''));
  lng_properties_strings[18] := parse(lfile.ReadString(propertiessect,'icon',''));
  lng_properties_strings[19] := parse(lfile.ReadString(propertiessect,'change',''));
  lng_properties_strings[20] := parse(lfile.ReadString(propertiessect,'chb_drop',''));
  lng_properties_strings[21] := parse(lfile.ReadString(propertiessect,'chb_question',''));
  lng_properties_strings[22] := parse(lfile.ReadString(propertiessect,'chb_hide',''));
  lng_properties_strings[23] := parse(lfile.ReadString(propertiessect,'tprogramfilter',''));

  lng_tabname_strings[1] := parse(lfile.ReadString(tabnamesect,'tabname',''));

  lng_settings_strings[1] := parse(lfile.ReadString(settingssect,'general',''));
  lng_settings_strings[2] := parse(lfile.ReadString(settingssect,'settings',''));
  lng_settings_strings[3] := parse(lfile.ReadString(settingssect,'tabs',''));
  lng_settings_strings[4] := parse(lfile.ReadString(settingssect,'rows',''));
  lng_settings_strings[5] := parse(lfile.ReadString(settingssect,'buttons',''));
  lng_settings_strings[6] := parse(lfile.ReadString(settingssect,'spacing',''));
  lng_settings_strings[7] := parse(lfile.ReadString(settingssect,'chb_autorun',''));
  lng_settings_strings[8] := parse(lfile.ReadString(settingssect,'chb_alwaysontop',''));
  lng_settings_strings[9] := parse(lfile.ReadString(settingssect,'chb_starthide',''));
  lng_settings_strings[10] := parse(lfile.ReadString(settingssect,'chb_statusbar',''));
  lng_settings_strings[11] := parse(lfile.ReadString(settingssect,'titlebar',''));
  lng_settings_strings[12] := parse(lfile.ReadString(settingssect,'titlebar_normal',''));
  lng_settings_strings[13] := parse(lfile.ReadString(settingssect,'titlebar_mini',''));
  lng_settings_strings[14] := parse(lfile.ReadString(settingssect,'titlebar_hidden',''));
  lng_settings_strings[15] := parse(lfile.ReadString(settingssect,'tabstyle',''));
  lng_settings_strings[16] := parse(lfile.ReadString(settingssect,'tabstyle_pages',''));
  lng_settings_strings[17] := parse(lfile.ReadString(settingssect,'tabstyle_buttons',''));
  lng_settings_strings[18] := parse(lfile.ReadString(settingssect,'tabstyle_fbuttons',''));
  lng_settings_strings[19] := parse(lfile.ReadString(settingssect,'language',''));
  lng_settings_strings[20] := parse(lfile.ReadString(settingssect,'icons',''));
  lng_settings_strings[21] := parse(lfile.ReadString(settingssect,'size',''));
  lng_settings_strings[22] := parse(lfile.ReadString(settingssect,'reloadicons',''));

  lfile.Free;
end;

{
 - CSIDL_APPDATA - Application Data
 - CSIDL_BITBUCKET - Корзина
 - CSIDL_CONTROLS - Панель управления
 - CSIDL_COOKIES - Cookies
 - CSIDL_DESKTOP - Рабочий стол
 - CSIDL_DESKTOPDIRECTORY - папка Рабочего стола
 - CSIDL_DRIVES - Мой компьютер
 - CSIDL_FAVORITES - Избранное
 - CSIDL_FONTS - Шрифты

procedure TFlaunchMainForm.OpenSpecialDir(const CSIDL: byte);
var
  PIDL: PItemIDList;
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
begin
  SHGetSpecialFolderLocation(0, CSIDL, PIDL);
  pInfo := @Info;
  with Info do
    begin
      cbSize := SizeOf(Info);
      fMask := SEE_MASK_NOCLOSEPROCESS+SEE_MASK_IDLIST;
      wnd := 0;
      lpVerb := nil;
      lpFile := nil;
      lpParameters := nil;
      lpDirectory := nil;
      nShow := SW_ShowNormal;
      hInstApp := 0;
      lpIDList := PIDL;
    end;
  ShellExecuteEx(pInfo);
end;}

function TFlaunchMainForm.GetSpecialDir(const CSIDL: byte): string;
var
  Buf: array[0..255] of Char;
begin
  Result := '';
  if SHGetFolderPath(0, CSIDL, 0, 0, Buf) = 0 then
    Result := Buf
  else
    exit;
  if Result[length(Result)] <> '\' then Result := Result + '\';
end;

procedure TFlaunchMainForm.SetAutorun(b: boolean);
var
   reg: TRegistry;
   rkey: Cardinal;
begin
  case SettingsMode of
    0: rkey := HKEY_CURRENT_USER;
    1: rkey := HKEY_LOCAL_MACHINE;
    2: exit;
  end;

  reg := TRegistry.Create;
  try
    reg.RootKey := rkey;
    reg.LazyWrite := false;
    reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', false);
    if b then
      begin
        reg.WriteString(FullDecrypt(cr_progname), Application.ExeName);
      end
    else
      reg.DeleteValue(FullDecrypt(cr_progname));
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
    if tn = Format(lngstrings[1], [i]) then exit;
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

function TFlaunchMainForm.ColorStrToColor(s: string): integer;
var
  e: integer;
begin
  delete(s, 1, 2);
  val('$' + s, result, e);
  if e <> 0 then
    result := clBtnFace;
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

function TFlaunchMainForm.GetFileDescription(FileName: string): string;
var
  szName: array[0..255] of Char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString:string;
  FValid:boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  FBuffer := nil;
  try
    FValid := False;
    FSize := GetFileVersionInfoSize(PChar(FileName), FHandle);
    if FSize > 0 then
      try
        GetMem(FBuffer, FSize);
        FValid := GetFileVersionInfo(PChar(FileName), FHandle, FSize, FBuffer);
      except
        FValid := False;
        raise;
      end;
    Result := '';
    if FValid then
      VerQueryValue(FBuffer, '\VarFileInfo\Translation', p, Len)
    else
      p := nil;
    if P <> nil then
      GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)), LoWord(Longint(P^))), 8);
    if FValid then
      begin
        StrPCopy(szName, '\StringFileInfo\' + GetTranslationString + '\FileDescription');
        if VerQueryValue(FBuffer, szName, Value, Len) then
          Result := StrPas(PChar(Value));
      end;
  finally
    if FBuffer <> nil then
      FreeMem(FBuffer, FSize);
  end;
end;

function TFlaunchMainForm.ExtractFileNameNoExt(FileName: string): string;
var
  tempstr: string;
begin
  tempstr := ExtractFileName(FileName);
  result := copy(tempstr, 1, length(tempstr) - length(ExtractFileExt(FileName)));
end;

procedure TFlaunchMainForm.TrayIconProc(n: integer);
begin
  FillChar(NIm, SizeOf(NotifyIconData), 0);
  with Nim do
    begin
      cbSize := SizeOf;
      Wnd := FlaunchMainForm.Handle;
      uID := 1;
      uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
      hicon := LoadIcon(hinstance, 'RTRAYICON');
      uCallbackMessage := wm_user + 20;
      strpcopy(szTip, Format('%s %s',[FullDecrypt(cr_progname), GetFLVersion]));
    end;
  case n of
    1: begin Shell_NotifyIcon(Nim_Add, @Nim); end;
    2: begin Shell_NotifyIcon(Nim_Delete, @Nim); end;
    3: begin Shell_NotifyIcon(Nim_Modify, @Nim); end;
  end;
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
      ShowWindow(FlaunchMainForm.Handle, SW_SHOW);
      SetForegroundWindow(application.Handle);
    end
  else
    begin
      FlaunchMainForm.Visible := false;
      ShowWindow(FlaunchMainForm.Handle, SW_HIDE);
    end;
end;

procedure TFlaunchMainForm.TrayIconMouse(var Msg: TMessage);
var
  p: tpoint;
begin
  GetCursorPos(p);
  case Msg.LParam of
    WM_MOUSEMOVE: nowactive := FlaunchMainForm.Active;
    WM_RBUTTONUP:
      begin
        SetForegroundWindow(Handle);
        NI_About.Enabled := not aboutshowing;
        NI_Settings.Enabled := not settingsshowing;
        TrayMenu.Popup(p.X, p.Y);
        PostMessage(Handle, WM_NULL, 0, 0);
      end;
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
       ChWinView((not nowactive) or not (FlaunchMainForm.Showing));
       Application.ProcessMessages;
       nowactive := FlaunchMainForm.Active;
      end;
  end;
end;

function TFlaunchMainForm.LoadLinksCfgFileV121_12_11: boolean;
var
  t,r,c: integer;
  FileName, ext: string;
  LinksCfgFile: integer;
  buff: array[0..255] of AnsiChar;
  bufflen: integer;
begin
  result := false;
  FileName := workdir + 'FLaunch.dat';
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, 4);
  FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, bufflen);
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].exec := strpas(buff);
          ext := extractfileext(links[t,r,c].exec).ToLower;
          if (not links[t,r,c].active) or (ext = '.exe') or (ext = '.bat') then
            links[t,r,c].ltype := 0
          else
            links[t,r,c].ltype := 1;
          links[t,r,c].workdir := ExtractFilePath(links[t,r,c].exec);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].icon := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].params := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].dropparams := strpas(buff);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].descr := strpas(buff);
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
  LinksCfgFile: integer;
  buff: array[0..255] of AnsiChar;
  bufflen: integer;
begin
  result := false;
  FileName := workdir + 'Flaunch.dat';
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, 4);
  FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, bufflen);
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].exec := strpas(buff);
          ext := extractfileext(links[t,r,c].exec).ToLower;
          if (not links[t,r,c].active) or (ext = '.exe') or (ext = '.bat') then
            links[t,r,c].ltype := 0
          else
            links[t,r,c].ltype := 1;
          links[t,r,c].workdir := ExtractFilePath(links[t,r,c].exec);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].icon := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].params := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].dropparams := strpas(buff);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].descr := strpas(buff);
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
  FileName: string;
  LinksCfgFile: integer;
  buff: array[0..255] of AnsiChar;
  bufflen: integer;
begin
  result := false;
  FileName := workdir + 'FLaunch.dat';
  if not (fileexists(FileName)) then exit;
  LinksCfgFile := FileOpen(FileName, fmOpenRead);
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, 4);
  if buff <> 'LCFG' then
    begin
      FileClose(LinksCfgFile);
      RenameFile(FileName, workdir + 'Flaunch_Unknown.dat');
      exit;
    end;
  FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCfgFile, buff, bufflen);
  if buff <> version then
    begin
      FileClose(LinksCfgFile);
      if (buff = '1.21') or (buff = '1.2') or ((buff = '1.1')) then
        if ConfirmDialog(format(lngstrings[8],[buff]), lngstrings[7]) then
          begin
            LoadLinksCfgFileV121_12_11;
            exit;
          end;
      if buff = '1.0' then
        if ConfirmDialog(format(lngstrings[8],[buff]), lngstrings[7]) then
          begin
            LoadLinksCfgFileV10;
            exit;
          end;
      RenameFile(FileName, workdir + Format('Flaunch_%s.dat',[buff]));
      exit;
    end;
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileRead(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          FileRead(LinksCfgFile, links[t,r,c].ltype, sizeof(byte));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].exec := strpas(buff);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].workdir := strpas(buff);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].icon := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].params := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].dropparams := strpas(buff);
          FileRead(LinksCfgFile, bufflen, sizeof(bufflen));
          fillchar(buff, sizeof(buff), 0);
          FileRead(LinksCfgFile, buff, bufflen);
          links[t,r,c].descr := strpas(buff);
          FileRead(LinksCfgFile, links[t,r,c].ques, sizeof(boolean));
          FileRead(LinksCfgFile, links[t,r,c].hide, sizeof(boolean));
          FileRead(LinksCfgFile, links[t,r,c].pr, sizeof(byte));
          FileRead(LinksCfgFile, links[t,r,c].wst, sizeof(byte));
        end;
  FileClose(LinksCfgFile);
end;

procedure TFlaunchMainForm.SaveLinksCfgFile;
var
  t,r,c: integer;
  FileName: string;
  LinksCfgFile: integer;
  buff: array[0..255] of AnsiChar;
  bufflen: integer;
begin
  FileName := workdir + 'FLaunch.dat';
  {if (fileexists(FileName)) and not (fileexists(FileName + '.bak')) then
    RenameFile(FileName, FileName + '.bak');}
  LinksCfgFile := FileCreate(FileName);
  FileWrite(LinksCfgFile, AnsiString('LCFG'), 4);
  bufflen := length(version);
  FileWrite(LinksCfgFile, byte(bufflen), sizeof(bufflen));
  FileWrite(LinksCfgFile, AnsiString(version), length(version));
  for t := 0 to maxt - 1 do
    for r := 0 to maxr - 1 do
      for c := 0 to maxc - 1 do
        begin
          FileWrite(LinksCfgFile, links[t,r,c].active, sizeof(boolean));
          FileWrite(LinksCfgFile, links[t,r,c].ltype, sizeof(byte));
          bufflen := length(links[t,r,c].exec);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].exec);
          FileWrite(LinksCfgFile, buff, bufflen);
          bufflen := length(links[t,r,c].workdir);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].workdir);
          FileWrite(LinksCfgFile, buff, bufflen);
          bufflen := length(links[t,r,c].icon);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].icon);
          FileWrite(LinksCfgFile, buff, bufflen);
          FileWrite(LinksCfgFile, links[t,r,c].iconindex, sizeof(integer));
          bufflen := length(links[t,r,c].params);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].params);
          FileWrite(LinksCfgFile, buff, bufflen);
          FileWrite(LinksCfgFile, links[t,r,c].dropfiles, sizeof(boolean));
           bufflen := length(links[t,r,c].dropparams);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].dropparams);
          FileWrite(LinksCfgFile, buff, bufflen);
          bufflen := length(links[t,r,c].descr);
          FileWrite(LinksCfgFile, bufflen, sizeof(bufflen));
          strpcopy(buff, links[t,r,c].descr);
          FileWrite(LinksCfgFile, buff, bufflen);
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
  LinksCashFile: integer;
  buff: array[0..255] of AnsiChar;
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
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCashFile, buff, 5);
  if buff <> 'LCASH' then
    begin
      FileClose(LinksCashFile);
      //RenameFile(FileName, ExtractFilePath(ParamStr(0)) + 'IconCache_Unknown.dat');
      LoadLinks;
      exit;
    end;
  FileRead(LinksCashFile, bufflen, sizeof(bufflen));
  fillchar(buff, sizeof(buff), 0);
  FileRead(LinksCashFile, buff, bufflen);
  if buff <> version then
    begin
      FileClose(LinksCashFile);
      //RenameFile(FileName, ExtractFilePath(ParamStr(0)) + Format('IconCache_%s.dat',[buff]));
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
  LinksCashFile: integer;
  tt,rr,cc: integer;
  bufflen: integer;
  Stream: TMemoryStream;
begin
  FileName := workdir + 'IconCache.dat';
  {if (fileexists(FileName)) and not (fileexists(FileName + '.bak')) then
    RenameFile(FileName, FileName + '.bak');}
  LinksCashFile := FileCreate(FileName);
  FileWrite(LinksCashFile, AnsiString('LCASH'), 5);
  bufflen := length(version);
  FileWrite(LinksCashFile, bufflen, sizeof(bufflen));
  FileWrite(LinksCashFile, AnsiString(version), length(version));
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
      //Caption := inttostr(LeftPer) + ':' + inttostr(TopPer);
    end;
  inherited;
end;

procedure TFlaunchMainForm.WMDisplayChange(var Msg: TWMDisplayChange);
begin
  ChPos := true;
  Left := PercentToPosition(LeftPer, true);
  Top := PercentToPosition(TopPer, false);
  ChPos := false;
  {if Left + Width > Msg.Width then
    Left := Msg.Width - Width;
  if Top + Height > Msg.Height then
    Top := Msg.Height - Height; }
  inherited;
end;

procedure TFlaunchMainForm.EndWork;
begin
  unregisterhotkey(Handle, HotKeyID);
  DeleteFile(workdir + '.session');
  SaveIni;
  TrayIconProc(2);
  SaveLinksCfgFile;
  SaveLinksToCash;
end;

function TFlaunchMainForm.GetIconCount(FileName: String): integer;
var
  Ind: integer;
begin
  Ind := -1;
  Result := ExtractIcon(hinstance, PChar(FileName), Ind);
  //if Result = 0 then Result := 1;
end;

function TFlaunchMainForm.GetFileIcon(FileName: String; OpenIcon: Boolean; Index: integer): hicon;
var
  SFI: TShFileInfo;
  Flags: Integer;
begin
  if GetIconCount(FileName) > 0 then
    begin
      Result := ExtractIcon(hinstance, PChar(FileName), Index);
      exit;
    end;
  Flags := SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SYSICONINDEX;
  if OpenIcon then
    Flags := Flags or SHGFI_OPENICON;
  FillChar(SFI, sizeof(SFI), 0);
  ShGetFileInfo(PChar(FileName), 0, SFI, SizeOf(SFI), Flags);
  Result := SFI.hIcon;
end;

function TFlaunchMainForm.MyCutting(s: string; l: integer): string;
begin
  if length(s) <= l then
    result := s
  else
    result := copy(s, 1, l) + '...';
end;

procedure TFlaunchMainForm.GetCoordinates(Sender: TObject; var t: integer; var r: integer; var c: integer);
begin
  t := (Sender as TMyPanel).TabNum;
  r := (Sender as TMyPanel).RowNum;
  c := (Sender as TMyPanel).ColNum;
end;

procedure TFlaunchMainForm.GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
var
  ShellLink: IShellLink;
  PersistFile: IPersistFile;
  AnObj: IUnknown;
begin
  AnObj  := CreateComObject(CLSID_ShellLink);
  ShellLink := AnObj as IShellLink;
  PersistFile := AnObj as IPersistFile;
  PersistFile.Load(PWChar(WideString(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile)), 0);
  with ShellLink do
    begin
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile), lpShellLinkInfoStruct^.FindData, SLGP_UNCPRIORITY);
      GetDescription(lpShellLinkInfoStruct^.Description, SizeOf(lpShellLinkInfoStruct^.Description));
      GetArguments(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute));
      GetWorkingDirectory(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy));
      GetIconLocation(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon), lpShellLinkInfoStruct^.IconIndex);
      GetHotKey(lpShellLinkInfoStruct^.HotKey);
      GetShowCmd(lpShellLinkInfoStruct^.ShowCommand);
    end;
 end;

procedure TFlaunchMainForm.SmoothResize(Src, Dst: TBitmap);
var
  x, y: Integer;
  xP, yP: Integer; 
  xP2, yP2: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer; 
  z, z2, iz2: Integer; 
  DstLine: pRGBArray; 
  DstGap: Integer; 
  w1, w2, w3, w4: Integer;
begin
  Src.PixelFormat := pf24Bit;
  Dst.PixelFormat := pf24Bit; 
  if (Src.Width = Dst.Width) and (Src.Height = Dst.Height) then
    Dst.Assign(Src) 
  else 
    begin
      DstLine := Dst.ScanLine[0];
      DstGap  := Integer(Dst.ScanLine[1]) - Integer(DstLine);
      xP2 := MulDiv(pred(Src.Width), $10000, Dst.Width);
      yP2 := MulDiv(pred(Src.Height), $10000, Dst.Height);
      yP  := 0;
      for y := 0 to pred(Dst.Height) do
        begin
          xP := 0;
          SrcLine1 := Src.ScanLine[yP shr 16];
          if (yP shr 16 < pred(Src.Height)) then
            SrcLine2 := Src.ScanLine[succ(yP shr 16)]
          else
            SrcLine2 := Src.ScanLine[yP shr 16];
          z2  := succ(yP and $FFFF);
          iz2 := succ((not yp) and $FFFF);
          for x := 0 to pred(Dst.Width) do
            begin
              t3 := xP shr 16;
              z  := xP and $FFFF;
              w2 := MulDiv(z, iz2, $10000);
              w1 := iz2 - w2;
              w4 := MulDiv(z, z2, $10000);
              w3 := z2 - w4;
              DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 +
              SrcLine1[t3 + 1].rgbtRed * w2 +
              SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;
              DstLine[x].rgbtGreen := (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 +
              SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;
              DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 +
              SrcLine1[t3 + 1].rgbtBlue * w2 +
              SrcLine2[t3].rgbtBlue * w3 +
              SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
              Inc(xP, xP2);
            end;
          Inc(yP, yP2);
          DstLine := pRGBArray(Integer(DstLine) + DstGap);
        end;
    end;
end;

{procedure LoadIcFromFile(t, r, c: integer; FileName: string; Index: integer);
var
  icx,icy,i,j: integer;
  icon: TIcon;
  IconInfo: TIconInfo;
  TempBmp,NewBmp,Mask: TBitMap;
begin
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
end;   }

{procedure TFlaunchMainForm.ModColors(Bitmap: TBitmap; Color: TColor);

function GetR(const Color: TColor): Byte;
begin
  Result := Lo(Color);
end;

function GetG(const Color: TColor): Byte;
begin
  Result := Lo(Color shr 8);
end;

function GetB(const Color: TColor): Byte;
begin
  Result := Lo((Color shr 8) shr 8);
end;
 
function BLimit(B: Integer): Byte;
begin
  if B < 0 then
    Result := 0
  else 
    if B > 255 then
      Result := 255
    else
      Result := B;
end;
 
type
  TRGB = record
    B, G, R: Byte;
  end;
  pRGB = ^TRGB;
var
  r1, g1, b1: Byte;
  x, y: Integer;
  Dest: pRGB;
  A: Double;
begin
  Bitmap.PixelFormat := pf24Bit;
  r1 := Round(255 / 100 * GetR(Color));
  g1 := Round(255 / 100 * GetG(Color));
  b1 := Round(255 / 100 * GetB(Color));
  for y := 0 to Bitmap.Height - 1 do
    begin
      Dest := Bitmap.ScanLine[y];
      for x := 0 to Bitmap.Width - 1 do
        begin
          with Dest^ do
            begin
              A := (r + b + g) / 300;
              with Dest^ do
                begin
                  R := BLimit(Round(r1 * A));
                  G := BLimit(Round(g1 * A));
                  B := BLimit(Round(b1 * A));
                end;
            end;
          Inc(Dest);
        end;
    end;
end; }

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

procedure TFlaunchMainForm.FormShow(Sender: TObject);
begin
  ShowWindow(Application.handle, SW_HIDE);
  Application.ProcessMessages;
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
      //panels[tt][rr][cc].Free;
      panels[tt][rr][cc].Destroy;
end;

procedure TFlaunchMainForm.ClearLinks(Index: integer);
begin
  fillchar(links[Index], sizeof(link), 0);
  LoadPanelLinks(Index);
end;

procedure TFlaunchMainForm.ChangeWndSize;
begin
 //GroupPanel1.Width := 500;
 //GroupPanel1.Height := 500;
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
    0: FlaunchMainForm.BorderStyle := bsSingle;
    1: FlaunchMainForm.BorderStyle := bsToolWindow;
    2: FlaunchMainForm.BorderStyle := bsNone;
  end;
  case tabsview of
    0: FlaunchMainForm.MainTabs.Style := tsTabs;
    1: FlaunchMainForm.MainTabs.Style := tsButtons;
    2: FlaunchMainForm.MainTabs.Style := tsFlatButtons;
  end;
  if AlwaysOnTop then
    SetWindowPos( handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE)
  else
    SetWindowPos( handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
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

procedure TFlaunchMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  canclose := false;
  Showwindow(Handle, SW_HIDE);
end;

procedure TFlaunchMainForm.DefaultHandler(var Msg);
begin
  inherited;
  if (WM_TASKBARCREATED <> 0) and (TMessage(Msg).Msg = WM_TASKBARCREATED) then
    begin
      TrayIconProc(1);
    end;
end;

procedure TFlaunchMainForm.FormCreate(Sender: TObject);
var
  sini: TIniFile;
begin
  ChPos := true;
  randomize;
  registerhotkey(Handle, HotKeyID, mod_control or mod_win, 0);
  fl_dir := ExtractFilePath(paramstr(0));
  fl_root := Copy(fl_dir, 1, 3);
  sini := TIniFile.Create(fl_dir + 'UseProfile.ini'); //Считываем файл первичных настроек для определения режима работы программы и места хранения настроек
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
    end;

  LoadIni;
  LoadLanguage(lngfilename);
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
  TrayIconProc(1);
  if not StartHide then
    Show;
  //ChangeWndSize;
  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
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
  if not ConfirmDialog(format(lngstrings[10], [MainTabs.Pages[GlobTabNum].Caption]),
    lngstrings[7]) then exit;
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
  if ConfirmDialog(format(lngstrings[11],[ExtractFileName(GetAbsolutePath(links[t][r][c].exec))]),
    lngstrings[7]) then
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
  if not ConfirmDialog(format(lngstrings[12], [MainTabs.Pages[GlobTabNum].Caption]),
    lngstrings[7]) then exit;
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
  h: cardinal;
begin
  GlobParam := '';
  CreateThread(nil,0,@ThreadLaunch,nil,0,h);
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
  h: cardinal;
  t,r,c: integer;
begin
  GetCoordinates(Sender, t, r, c);
  GlobTab := t;
  GlobRow := r;
  GlobCol := c;
  GlobParam := '';
  CreateThread(nil,0,@ThreadLaunch,nil,0,h);
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
  pch: array[0..255] of char;
  t,r,c: integer;
  h: cardinal;
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
      CreateThread(nil,0,@ThreadLaunch,nil,0,h);
      exit;
    end;
  if (links[t][r][c].active) and (not ConfirmDialog(lngstrings[13], lngstrings[7])) then
    exit;
  fillchar(links[t,r,c],sizeof(lnk),0);
  if extractfileext(FileName).ToLower = '.flb' then
    if ConfirmDialog(format(lngstrings[14],[FileName]), lngstrings[7]) then
      begin
        ImportButton(FileName, t, r, c);
        exit;
      end;
  if extractfileext(FileName).ToLower = '.lnk' then
    begin
      strpcopy(lnkinfo.FullPathAndNameOfLinkFile, FileName);
      GetLinkInfo(@lnkinfo);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileToExecute,pch,sizeof(pch));
      links[t,r,c].exec := string(pch);
      FileName := links[t,r,c].exec;
      ext := extractfileext(links[t,r,c].exec).ToLower;
      fromlnk := true;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileContiningIcon,pch,sizeof(pch));
      links[t,r,c].icon := string(pch);
      if links[t,r,c].icon = '' then
        links[t,r,c].icon := links[t,r,c].exec;
      links[t,r,c].iconindex := lnkinfo.IconIndex;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfWorkingDirectroy,pch,sizeof(pch));
      links[t,r,c].workdir := string(pch);
      links[t,r,c].params := string(lnkinfo.ParamStringsOfFileToExecute);
      links[t,r,c].descr := string(lnkinfo.Description);
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
      panels[t][r][c].Hint := Format(lngstrings[4] + #13#10 +lngstrings[5] +#13#10 + lngstrings[6],[links[t][r][c].exec, links[t][r][c].params, MyCutting(links[t][r][c].descr, 60)]);
      StatusBar.Panels[0].Text := MyCutting(links[t][r][c].descr, 60);
    end
  else
    StatusBar.Panels[0].Text := ''; 
end;

end.
