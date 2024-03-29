﻿{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2023 Alexey Tatuyko                                     #
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

unit FLLanguage;

interface

uses
  System.IniFiles, Vcl.Graphics;

type
  TLngAbout = record
    Caption, Version, Contributors, License, Thanks: string;
  end;

  TLngIconSelect = record
    Caption, FileName, Index, LblOf, Negative: string;
  end;

  TLngProperties = record
    Caption, Folder, LblObject, Parameters, Description,
    Priority, PriorityNormal, PriorityHigh, PriorityIdle, PriorityAboveNormal,
    PriorityBelowNormal, PriorityRealTime,
    View, ViewNormal, ViewMax,
    ViewMin, ViewHidden, BeHint, RpHint, Options, Icon, Change, ChbDrop,
    ChbQuestion, ChbHide, ProgramFilter, ChbAdmin: string;
  end;

  TLngSettings = record
    Caption, General, NumOfTabs, Rows, Cols, Padding, Theme,
    ChbAutorun, ChbAdmin, ChbAlwaysOnTop, ChbStartHide, ChbStatusbar,
    ChbDateTime, ChbHideAL, ChbQoL, ChbDelLnk, ChbDrop, ChbGlass, ChbClear,
    ChbAlphaBlend, ChbABOff, ChbTaskbar,
    Priority, PriorityNormal, PriorityHigh, PriorityIdle, PriorityAboveNormal,
    PriorityBelowNormal, PriorityRealTime,
    Titlebar, TitlebarNormal, TitlebarMini,
    TitlebarHidden, TabStyle, TabStylePages, TabStyleButtons, TabStyleFButtons,
    Language, BtnSizes, BtnWidth, BtnHeight, ReloadIcons, GUIProperties,
    BtnProperties, NewBtnProperties,
    WState, WSNormal, WSMin, WSMax, WSHidden: string;
  end;

  TLngMenu = record
    Show, Settings, About, Close, Run, RunAsAdmin, TypeProgramm, TypeFile,
    ExportBtn, Import, Clear, Prop, Rename, ClearTab, DeleteTab, NewTab,
    Group: string;
  end;

  TLngMain = record
    TabName, Location, Parameters, Description, HelpFile: string;
  end;

  TLngMessages = record
    Caution, Confirmation, RunProgram, DeleteTab, DeleteButton, ClearTab,
    BusyReplace, ImportButton, NotFound, FileNotFound: string;
  end;

  TLngInfo = record
    Name, Authors: string;
    Image: TBitmap;
    procedure Load(AIni: TCustomIniFile);
  end;

  TLngNotifier = reference to procedure;

  TLanguage = record
    Info: TLngInfo;
    About: TLngAbout;
    IconSelect: TLngIconSelect;
    Properties: TLngProperties;
    Settings: TLngSettings;
    Menu: TLngMenu;
    Main: TLngMain;
    FileName: string;
    TabRename: string;
    FlbFilter: string;
    BtnOk, BtnCancel, BtnApply: string;
    Messages: TLngMessages;
    procedure Load(ALanguage: string);
    procedure AddNotifier(ANotifier: TLngNotifier);
  private
    FNotifiers: array of TLngNotifier;
  end;

var
  Language: TLanguage;

implementation

uses
  System.Classes, System.SysUtils,
  Vcl.Forms;

function Parse(Str: string; Frm: string = ''): string;
begin
  Result := StringReplace(Str, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]);

  if Frm <> '' then
  begin
    Result := StringReplace(Result, '%%', Frm, [rfReplaceAll]);
    if Pos(Frm, Result) = 0 then
      Result := Result + ' ' + Frm;
  end;
end;

{ TLanguage }

procedure TLanguage.AddNotifier(ANotifier: TLngNotifier);
var
  Len: Integer;
begin
  Len := Length(FNotifiers);
  SetLength(FNotifiers, Len + 1);
  FNotifiers[Len] := ANotifier;
end;

procedure TLanguage.Load(ALanguage: string);
const
  SctMain = 'main';
  SctAbout = 'about';
  SctIconSelect = 'iconselect';
  SctProperties = 'properties';
  SctTabname = 'tabname';
  SctSettings = 'settings';
  SctInfo = 'information';

var
  Ini: TMemIniFile;
  CurrentNotifier: TLngNotifier;
begin
  FileName := ALanguage;
  Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'languages\' +
    FileName);
  try
    Main.TabName :=      Parse(Ini.ReadString(SctMain, 'tabname',
      'Tab %%'), '%d');
    Main.Location :=     Parse(Ini.ReadString(SctMain, 'location',
      'Location: %%'), '%s');
    Main.Parameters :=   Parse(Ini.ReadString(SctMain, 'parameters',
      'Parameters: %%'), '%s');
    Main.Description :=  Parse(Ini.ReadString(SctMain, 'description',
      'Description: %%'), '%s');
    Main.HelpFile :=     Parse(Ini.ReadString(SctInfo, 'help', 'index.html'));

    Messages.Caution :=      Parse(Ini.ReadString(SctMain, 'caution', 'Caution'));
    Messages.Confirmation := Parse(Ini.ReadString(SctMain, 'confirmation',
      'Confirmation'));
    Messages.RunProgram :=   Parse(Ini.ReadString(SctMain, 'message2',
      'Do you wish to run this object?\n\n%%'), '%s');
    Messages.DeleteTab :=    Parse(Ini.ReadString(SctMain, 'message3',
      'Do you wish to delete this tab?\n\n%%'), '%s');
    Messages.DeleteButton := Parse(Ini.ReadString(SctMain, 'message4',
      'Do you wish to delete this button?\n\n%%'), '%s');
    Messages.ClearTab :=     Parse(Ini.ReadString(SctMain, 'message5',
      'Do you wish to clear this tab?\n\n%%'), '%s');
    Messages.BusyReplace :=  Parse(Ini.ReadString(SctMain, 'message6',
      'This button is busy yet. Do you wish to replace it?'));
    Messages.ImportButton := Parse(Ini.ReadString(SctMain, 'message7',
      'Do you wish to import button settings from this file?\n\n%%'), '%s');
    Messages.NotFound :=     Parse(Ini.ReadString(SctMain, 'message8',
      'Object not found\n\n%%\n\nDo you wish to delete this button?'), '%s');
    Messages.FileNotFound := Parse(Ini.ReadString(SctMain, 'message9',
      'File ''%%'' not found.'), '%s');

    Menu.Show :=         Parse(Ini.ReadString(SctMain, 'ni_show',
      '&FreeLaunch'));
    Menu.Settings :=     Parse(Ini.ReadString(SctMain, 'ni_settings',
      '&Settings...'));
    Menu.About :=        Parse(Ini.ReadString(SctMain, 'ni_about',
      '&About...'));
    Menu.Close :=        Parse(Ini.ReadString(SctMain, 'ni_close', '&Close'));
    Menu.Run :=          Parse(Ini.ReadString(SctMain, 'ni_run', '&Execute'));
    Menu.RunAsAdmin :=   Parse(Ini.ReadString(SctMain, 'ni_runasadmin',
      'Run as Administrator'));
    Menu.TypeProgramm := Parse(Ini.ReadString(SctMain, 'ni_tprogram',
      '&Executed file'));
    Menu.TypeFile :=     Parse(Ini.ReadString(SctMain, 'ni_tfile',
      '&File, folder'));
    Menu.ExportBtn :=    Parse(Ini.ReadString(SctMain, 'ni_export',
      '&Export...'));
    Menu.Import :=       Parse(Ini.ReadString(SctMain, 'ni_import',
      '&Import...'));
    Menu.Clear :=        Parse(Ini.ReadString(SctMain, 'ni_clear', '&Clear'));
    Menu.Prop :=         Parse(Ini.ReadString(SctMain, 'ni_prop',
      '&Properties...'));
    Menu.Rename :=       Parse(Ini.ReadString(SctMain, 'ni_rename', '&Rename'));
    Menu.NewTab :=       Parse(Ini.ReadString(SctMain, 'ni_newtab', '&Add'));
    Menu.ClearTab :=     Parse(Ini.ReadString(SctMain, 'ni_cleartab',
      '&Clear'));
    Menu.DeleteTab :=    Parse(Ini.ReadString(SctMain, 'ni_deletetab',
      '&Delete'));
    Menu.Group :=        Parse(Ini.ReadString(SctMain, 'ni_group', '&Group'));

    FlbFilter := Parse(Ini.ReadString(SctMain, 'flbfilter',
      'FreeLaunch button file (*.flb)')) + '|*.flb';
    BtnOk :=     Parse(Ini.ReadString(SctMain, 'ok', 'OK'));
    BtnCancel := Parse(Ini.ReadString(SctMain, 'cancel', 'Cancel'));
    BtnApply :=  Parse(Ini.ReadString(SctMain, 'apply', 'Apply'));

    About.Caption :=   Parse(Ini.ReadString(SctAbout, 'about', 'About'));
    About.Version :=   Parse(Ini.ReadString(SctAbout, 'version', 'Version'));
    About.Contributors := Parse(Ini.ReadString(SctAbout, 'contributors', 'Contributors'));
    About.License := Parse(Ini.ReadString(SctAbout, 'license', 'License'));
    About.Thanks := Parse(Ini.ReadString(SctAbout, 'thanks', 'Thanks'));

    IconSelect.Caption :=  Parse(Ini.ReadString(SctIconSelect, 'iconselect',
      'Icon select'));
    IconSelect.FileName := Parse(Ini.ReadString(SctIconSelect, 'file', 'File'));
    IconSelect.Index :=    Parse(Ini.ReadString(SctIconSelect, 'index', 'Index'));
    IconSelect.LblOf :=    Parse(Ini.ReadString(SctIconSelect, 'of', 'of %%'),  '%d');
    IconSelect.Negative := Parse(Ini.ReadString(SctIconSelect, 'negative',
      'Use negative index'));

    Properties.Caption :=        Parse(Ini.ReadString(SctProperties, 'properties',
      'Properties'));
    Properties.Folder :=         Parse(Ini.ReadString(SctProperties, 'folder',
      'Folder'));
    Properties.LblObject :=      Parse(Ini.ReadString(SctProperties, 'object',
      'Object'));
    Properties.Parameters :=     Parse(Ini.ReadString(SctProperties, 'parameters',
      'Parameters'));
    Properties.Description :=    Parse(Ini.ReadString(SctProperties, 'description',
      'Description'));
    Properties.Priority :=       Parse(Ini.ReadString(SctProperties, 'priority',
      'Priority'));
    Properties.PriorityNormal := Parse(Ini.ReadString(SctProperties,
      'priority_normal', 'Normal'));
    Properties.PriorityHigh :=   Parse(Ini.ReadString(SctProperties,
      'priority_high',  'High'));
    Properties.PriorityIdle :=   Parse(Ini.ReadString(SctProperties,
      'priority_idle', 'Idle'));
    Properties.PriorityRealTime := Parse(Ini.ReadString(SctProperties,
      'priority_realtime', 'Real time'));
    Properties.PriorityBelowNormal := Parse(Ini.ReadString(SctProperties,
      'priority_below_normal', 'Below normal'));
    Properties.PriorityAboveNormal := Parse(Ini.ReadString(SctProperties,
      'priority_above_normal', 'Above normal'));
    Properties.View :=           Parse(Ini.ReadString(SctProperties, 'view',
      'View'));
    Properties.ViewNormal :=     Parse(Ini.ReadString(SctProperties, 'view_normal',
      'Normal'));
    Properties.ViewMax :=        Parse(Ini.ReadString(SctProperties, 'view_max',
      'Maximized'));
    Properties.ViewMin :=        Parse(Ini.ReadString(SctProperties, 'view_min',
      'Minimized'));
    Properties.ViewHidden :=     Parse(Ini.ReadString(SctProperties, 'view_hidden',
      'Hidden'));
    Properties.BeHint :=         Parse(Ini.ReadString(SctProperties, 'be_hint',
      'Select object'));
    Properties.RpHint :=         Parse(Ini.ReadString(SctProperties, 'rp_hint',
      'Refresh properties'));
    Properties.Options :=        Parse(Ini.ReadString(SctProperties, 'options',
      'Options'));
    Properties.Icon :=           Parse(Ini.ReadString(SctProperties, 'icon',
      'Icon'));
    Properties.Change :=         Parse(Ini.ReadString(SctProperties, 'change',
      'Change...'));
    Properties.ChbDrop :=        Parse(Ini.ReadString(SctProperties, 'chb_drop',
      'Accept dropped files (%1 - filename)'));
    Properties.ChbQuestion :=    Parse(Ini.ReadString(SctProperties, 'chb_question',
      'Confirm launch'));
    Properties.ChbHide :=        Parse(Ini.ReadString(SctProperties, 'chb_hide',
      'Hide after launch'));
    Properties.ProgramFilter :=  Parse(Ini.ReadString(SctProperties, 'tprogramfilter',
      'Executable file (*.exe, *.bat)'));
    Properties.ChbAdmin :=       Parse(Ini.ReadString(SctProperties, 'chb_admin',
      'Run with Admin rights'));

    TabRename := Parse(Ini.ReadString(SctTabname, 'tabname', 'Tab name'));

    Settings.Caption :=          Parse(Ini.ReadString(SctSettings, 'settings',
      'Settings'));
    Settings.General :=          Parse(Ini.ReadString(SctSettings, 'general',
      'General'));
    Settings.GUIProperties :=    Parse(Ini.ReadString(SctSettings, 'interface',
      'Interface'));
    Settings.BtnProperties :=    Parse(Ini.ReadString(SctSettings, 'buttons',
      'Buttons'));
    Settings.NumofTabs :=        Parse(Ini.ReadString(SctSettings, 'tabs',
      'Number of tabs'));
    Settings.Rows :=             Parse(Ini.ReadString(SctSettings, 'rows',
      'Number of rows on the tab'));
    Settings.Cols :=             Parse(Ini.ReadString(SctSettings, 'cols',
      'Number of columns on the tab'));
    Settings.Padding :=          Parse(Ini.ReadString(SctSettings, 'padding',
      'Padding between buttons'));
    Settings.ChbAutorun :=       Parse(Ini.ReadString(SctSettings, 'chb_autorun',
      'Autostart with system'));
    Settings.ChbAlwaysOnTop :=   Parse(Ini.ReadString(SctSettings, 'chb_alwaysontop',
      'Always on top'));
    Settings.ChbAdmin :=         Parse(Ini.ReadString(SctSettings, 'chb_admin',
      'Run with Administrator rights'));
    Settings.ChbStartHide :=     Parse(Ini.ReadString(SctSettings, 'chb_starthide',
      'Start hidden'));
    Settings.ChbStatusbar :=     Parse(Ini.ReadString(SctSettings, 'chb_statusbar',
      'Show status bar'));
    Settings.ChbDateTime :=      Parse(Ini.ReadString(SctSettings, 'chb_datetime',
      'Show the date and time in the status bar'));
    Settings.ChbHideAL :=        Parse(Ini.ReadString(SctSettings, 'chb_hide',
      'Hide FreeLaunch after launching a button'));
    Settings.ChbQoL :=           Parse(Ini.ReadString(SctSettings, 'chb_query',
      'Request confirmation before launching a button'));
    Settings.ChbDelLnk :=        Parse(Ini.ReadString(SctSettings, 'chb_dellnk',
      'Delete shortcut file after creating a button'));
    Settings.ChbDrop :=          Parse(Ini.ReadString(SctSettings, 'chb_drop',
      'Accept dropped files'));
    Settings.ChbGlass :=         Parse(Ini.ReadString(SctSettings, 'chb_glass',
      'Make button background transparent if there are no tabs'));
    Settings.ChbClear :=         Parse(Ini.ReadString(SctSettings, 'chb_clear',
      'When reloading buttons, delete the button if the object is not found'));
    Settings.ChbAlphaBlend :=    Parse(Ini.ReadString(SctSettings, 'chb_ablend',
      'Enable main window transparency'));
    Settings.ChbABOff :=         Parse(Ini.ReadString(SctSettings, 'chb_aboff',
      'Turn off transparency if the cursor is over the window'));
    Settings.ChbTaskbar :=       Parse(Ini.ReadString(SctSettings, 'chb_taskbar'
      , 'Show on taskbar'));
    Settings.Titlebar :=         Parse(Ini.ReadString(SctSettings, 'titlebar',
      'Window title style'));
    Settings.TitlebarNormal :=   Parse(Ini.ReadString(SctSettings, 'titlebar_normal',
      'Normal'));
    Settings.TitlebarMini :=     Parse(Ini.ReadString(SctSettings, 'titlebar_mini',
      'Mini'));
    Settings.TitlebarHidden :=   Parse(Ini.ReadString(SctSettings, 'titlebar_hidden',
      'Hidden'));
    Settings.TabStyle :=         Parse(Ini.ReadString(SctSettings, 'tabstyle',
      'Tab style'));
    Settings.TabStylePages :=    Parse(Ini.ReadString(SctSettings, 'tabstyle_pages',
      'Pages'));
    Settings.TabStyleButtons :=  Parse(Ini.ReadString(SctSettings, 'tabstyle_buttons',
      'Buttons'));
    Settings.TabStyleFButtons := Parse(Ini.ReadString(SctSettings, 'tabstyle_fbuttons',
      'Flat buttons'));
    Settings.Language :=         Parse(Ini.ReadString(SctSettings, 'language',
      'Language'));
    Settings.BtnSizes :=         Parse(Ini.ReadString(SctSettings, 'btnsizes',
      'Button size'));
    Settings.BtnWidth :=         Parse(Ini.ReadString(SctSettings, 'btnwidth',
      'Width'));
    Settings.BtnHeight :=        Parse(Ini.ReadString(SctSettings, 'btnheight',
      'Height'));
    Settings.ReloadIcons :=      Parse(Ini.ReadString(SctSettings, 'reloadicons',
      'Reload icons'));
    Settings.NewBtnProperties := Parse(Ini.ReadString(SctSettings, 'newbtns_properties',
      'Properties of new buttons'));
    Settings.WState :=           Parse(Ini.ReadString(SctSettings, 'windowstate',
      'Window state'));
    Settings.WSNormal :=         Parse(Ini.ReadString(SctSettings, 'ws_normal',
      'Normal'));
    Settings.WSMin :=            Parse(Ini.ReadString(SctSettings, 'ws_min',
      'Minimized'));
    Settings.WSMax :=            Parse(Ini.ReadString(SctSettings, 'ws_max',
      'Maximized'));
    Settings.WSHidden :=         Parse(Ini.ReadString(SctSettings, 'ws_hidden',
      'Hidden'));
    Settings.Priority :=         Parse(Ini.ReadString(SctSettings, 'priority',
      'Priority'));
    Settings.PriorityNormal :=   Parse(Ini.ReadString(SctSettings,
      'priority_normal', 'Normal'));
    Settings.PriorityHigh :=     Parse(Ini.ReadString(SctSettings,
      'priority_high',  'High'));
    Settings.PriorityIdle :=     Parse(Ini.ReadString(SctSettings,
      'priority_idle', 'Idle'));
    Settings.PriorityRealTime := Parse(Ini.ReadString(SctSettings,
      'priority_realtime', 'Real time'));
    Settings.PriorityBelowNormal := Parse(Ini.ReadString(SctSettings,
      'priority_below_normal', 'Below normal'));
    Settings.PriorityAboveNormal := Parse(Ini.ReadString(SctSettings,
      'priority_above_normal', 'Above normal'));
    Settings.Theme :=            Parse(Ini.ReadString(SctSettings,
      'theme', 'Theme'));

    Info.Load(Ini);

    for CurrentNotifier in FNotifiers do
      CurrentNotifier;
  finally
    Ini.Free;
  end;
end;

const
  base64ABC='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

type
  TBase64 = record
    ByteArr: array[0..2] of Byte;
    ByteCount: Byte;
  end;

function DecodeBase64(StringValue: string): TBase64;
var
  M,N: Integer;
  Dest,Sour: Byte;
  NextNum: Byte;
  CurPos: Byte;
begin
  CurPos := 0;
  Dest := 0;
  NextNum := 1;
  FillChar(Result, SizeOf(Result), 0);

  for N := 1 to 4 do
  begin
    for M := 0 to 5 do
    begin
      if StringValue[N] = '=' then
        Sour := 0
      else
        Sour := Pos(StringValue[N],base64ABC) - 1;

      Sour := (Sour shl M) and 255;
      Dest := (Dest shl 1) and 255;

      if (Sour and 32)=32 then
        Dest := Dest or 1;

      Inc(NextNum);

      if NextNum > 8 then
      begin
        NextNum := 1;
        Result.ByteArr[CurPos] := Dest;

        if StringValue[N] = '=' then
          Result.ByteArr[CurPos] := 0
        else
          Result.ByteCount := CurPos + 1;

        Inc(CurPos);
        Dest:=0;
      end;
    end;
  end;
end;

procedure ImageStrToBMP(AStr: string; var ABitmap: TBitmap);
var
  i: Integer;
  Str: string;
  Base64: TBase64;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    for i := 1 to (Length(AStr) div 4) do
    begin
      Str := Copy(AStr, i * 4 - 3, 4);
      Base64 := DecodeBase64(Str);
      Stream.WriteBuffer(Base64.ByteArr, Base64.ByteCount);
    end;

    Stream.Position := 0;
    ABitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

{ TLngInfo }

procedure TLngInfo.Load(AIni: TCustomIniFile);
const
  SctInfo = 'information';
var
  ImageStr: string;
begin
  Name := Parse(AIni.ReadString(SctInfo, 'name', 'English'));
  Authors := Parse(AIni.ReadString(SctInfo, 'authors', 'no information'));
  ImageStr := Parse(AIni.ReadString(SctInfo, 'image', 'Qk1GAgAAAAAAADYAAAAoAA' +
    'AAEAAAAAsAAAABABgAAAAAABACAADEDgAAxA4AAAAAAAAAAAAAxJt7aUuYsWVQjisYjisYji' +
    'sY6tXNNxuFNxuF6tXNbRQAbRQAbRQAjisY07aQjisY07aQ//7+fIX53cTCx4Rxx4Rx//7+Tl' +
    'H+TlH++/39sWVQsWVQ3cTC+/39VWDqtXNkrFI81q2h////fIX5jZH5tXNk////NTT4NTT4+/' +
    '39rFI8+/39jZH5VWDqz5mKbRQArFI8z5mKsWVQ6tXN6uv/YmP+////NTT4NTT4////////NT' +
    'T4tZm/jisYsWVQbRQA7d3Z//7+////////////////////NTT4NTT4////////////+/39+/' +
    '39+/396tXNf2GsjZH5YmP+YmP+TlH+TlH+TlH+TlH+TlH+NTT4NTT4NTT4NTT4NTT4TlH+Nx' +
    'uF7d3Z//7+////////////////////TlH+TlH+//////////////////////7+6tXNwYNh1q' +
    '2hz5mK377hfIX5////////YmP+TlH+////YmP+6uv/6tXNrFI8x4RxjisYwYNh7c+6r678r6' +
    '78////z5mK////YmP+YmP+////x4Rxr678jZH5////1q2hjisY1q2hr678//7+9OHb1q2h1q' +
    '2h//7+jZH5jZH5//7+z5mKz5mK3cTCfIX5+/3907aQz5mK7c+6xJt7wYNhwYNhwYNh7d3Zf2' +
    'Gsf2Gs7d3ZsWVQsWVQrFI8wYNhaUuYxJt7x==='));
  if not Assigned(Image) then
    Image := TBitmap.Create;

  ImageStrToBMP(ImageStr, Image);
end;

initialization

finalization
  if Assigned(Language.Info.Image) then
    Language.Info.Image.Free;

end.
