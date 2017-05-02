{
  ##########################################################################
  #  FreeLaunch 2.5 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2017 FreeLaunch Team                                    #
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

unit FLFunctions;

interface

uses
  Windows, Messages, Graphics, System.Classes;

const
  TCM_GETITEMRECT = $130A;
  UM_ShowMainForm = WM_USER + 1;
  UM_HideMainForm = WM_USER + 2;
  UM_LaunchDone = WM_USER + 3;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

  TLink = record
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
    IsAdmin: Boolean;
  end;

  //--��������� ���������� � ������
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
  PShellLinkInfoStruct = ^TShellLinkInfoStruct;

//--������� �� ��������� ���� �������� �� ������� ����������
function InRange(Value, FromV, ToV: byte): byte;
//--������� ���������� ���������� ������ � �����
function GetIconCount(FileName: string): integer;
//--������� ��������� ������ �� ����� �� �������
function GetFileIcon(FileName: string; OpenIcon: boolean; Index: integer): HIcon;
//--������� ���������� ���� � ����������� ������ � Windows
function GetSpecialDir(const CSIDL: byte): string;
function GetAbsolutePath(s: string): string;
//--������� ����������� ������ ���� 0xXXXXXX � ����
function ColorStrToColor(ColorStr: string): TColor;
//--������� ������ ������ �����������
procedure SmoothResize(Src, Dst: TBitmap);
//--���������� ����� ���� ������
function GetColorBetween(StartColor, EndColor: TColor; Pointvalue, Von, Bis: Extended): TColor;
//--������� ��������� �������� ������������ �����
function GetFileDescription(FileName: string): string;
//--������� ��������� ��� ����� ��� ����������
function ExtractFileNameNoExt(FileName: string): string;
//--������� ��������� ���������� �� ������ (*.lnk)
procedure GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
//--�������� ������ Str �� ����� Len � ����������� ��������� � ����� (���� ������ ������ Len)
function MyCutting(Str: string; Len: byte): string;
/// ������� ������� ��� MessageBox
procedure WarningMessage(AHandle: HWND; AText: string);
/// ������� ��� CreateProcess
function CreateProcess(AExecutable, AParameters, APath: string; AWindowState,
  APriority: Integer; var AErrorCode: Integer): Boolean;
/// ������ �������� ������ ������
procedure ThreadLaunch(var ALink: TLink; AMainHandle: HWND; ADroppedFile: string);
//--��������� ��� ������� �������� � ������ (��� ����� �� ������)
procedure NewProcess(ALink: TLink; AMainHandle: HWND; ALaunchID: Integer;
  ADroppedFile: string);
/// ������ ���� ���������� ��������� �� ����������
function ExpandEnvironmentVariables(const AFileName: string): string;
/// ���������� ����� ���������� ���������
procedure AddEnvironmentVariable(const AName, AValue: string);
/// ����������� ����� � ����� �����
procedure LinkToStrings(ALink: TLink; AStrings: TStrings);
/// ����������� ������ ����� � ����
function StringsToLink(AStrings: TStrings): TLink;
/// ������ ������ ��� UAC �� �����
procedure DrawShieldIcon(ACanvas: TCanvas; APosition: TPoint; ASize: TSize);
/// ������������� �����
procedure InitEnvironment;

var
  fl_root, fl_dir, fl_WorkDir, FLVersion: string;
  SettingsMode: integer; //����� ������ (0 - �����������, ��������� �������� � APPDATA;
  //1 - �����������, ��������� �������� � ����� ���������;
  //2 - ������������ �����, �����������, ��������� �������� � ����� ���������)

implementation

uses
  ShellApi, ShFolder, SysUtils, ActiveX, ComObj, ShlObj, FLLanguage,
  System.IniFiles;

//--������� �� ��������� ���� �������� �� ������� ����������
//--������� ���������: ��������, ����������� ��������, ������������ ��������
function InRange(Value, FromV, ToV: byte): byte;
begin
  Result := Value;
  if Value < FromV then Result := FromV;
  if Value > ToV then Result := ToV;
end;

//--������� ���������� ���������� ������ � �����
function GetIconCount(FileName: string): integer;
begin
  Result := ExtractIcon(HInstance, PChar(FileName), MAXDWORD);
end;

//--������� ��������� ������ �� ����� �� �������
function GetFileIcon(FileName: string; OpenIcon: boolean; Index: integer): HIcon;
var
  SFI: TShFileInfo;
  Flags: integer;
begin
  if GetIconCount(FileName) > 0 then
    begin
      Result := ExtractIcon(hinstance, pchar(FileName), Index);
      exit;
    end;
  Flags := SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SYSICONINDEX;
  if OpenIcon then
    Flags := Flags or SHGFI_OPENICON;
  FillChar(SFI, sizeof(SFI), 0);
  ShGetFileInfo(PChar(FileName), 0, SFI, SizeOf(SFI), Flags);
  Result := SFI.hIcon;
end;

//--������� ���������� ���� � ����������� ������ � Windows
//--������� ��������: ������������� ����
//--  CSIDL_APPDATA - Application Data
//--  CSIDL_BITBUCKET - �������
//--  CSIDL_CONTROLS - ������ ����������
//--  CSIDL_COOKIES - Cookies
//--  CSIDL_DESKTOP - ������� ����
//--  CSIDL_DESKTOPDIRECTORY - ����� �������� �����
//--  CSIDL_DRIVES - ��� ���������
//--  CSIDL_FAVORITES - ���������
//--  CSIDL_FONTS - ������
function GetSpecialDir(const CSIDL: byte): string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if SHGetFolderPath(0, CSIDL, 0, 0, Buf) = 0 then
    Result := Buf
  else
    exit;
  if Result[length(Result)] <> '\' then Result := Result + '\';
end;

function GetAbsolutePath(s: string): string;
begin
  result := ExpandEnvironmentVariables(s);
end;

//--������� ����������� ������ ���� 0xXXXXXX � ����
function ColorStrToColor(ColorStr: string): TColor;
var
  e: integer;
begin
  //--������� �� ������ 0x
  delete(ColorStr, 1, 2);
  //--�������� ��������� � ���������� ���
  val('$' + ColorStr, Result, e);
  //--���� �� ����������, ���������� ����������� ����
  if e <> 0 then
    Result := clBtnFace;
end;

//--������� ������ ������ �����������
procedure SmoothResize(Src, Dst: TBitmap);
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

//--���������� ����� ���� ������
function GetColorBetween(StartColor, EndColor: TColor; Pointvalue, Von, Bis: Extended): TColor;
var
  F: Extended; 
  r1, r2, r3, g1, g2, g3, b1, b2, b3: Byte; 

  function CalcColorBytes(fb1, fb2: Byte): Byte;
    begin
      Result := fb1;
      if fb1 < fb2 then
        Result := FB1 + Trunc(F * (fb2 - fb1));
      if fb1 > fb2 then
        Result := FB1 - Trunc(F * (fb1 - fb2));
    end;

begin 
  if Pointvalue <= Von then
    begin
      Result := StartColor;
      exit;
    end;
  if Pointvalue >= Bis then 
    begin
      Result := EndColor;
      exit;
    end;
  F := (Pointvalue - von) / (Bis - Von); 
  asm
    mov EAX, Startcolor
    cmp EAX, EndColor
    je @@exit
    mov r1, AL
    shr EAX,8
    mov g1, AL
    shr Eax,8
    mov b1, AL
    mov Eax, Endcolor
    mov r2, AL
    shr EAX,8
    mov g2, AL
    shr EAX,8
    mov b2, AL
    push ebp
    mov al, r1
    mov dl, r2
    call CalcColorBytes
    pop ecx
    push ebp
    Mov r3, al
    mov dL, g2
    mov al, g1
    call CalcColorBytes
    pop ecx
    push ebp
    mov g3, Al
    mov dL, B2
    mov Al, B1
    call CalcColorBytes
    pop ecx
    mov b3, al
    XOR EAX,EAX
    mov AL, B3
    SHL EAX,8
    mov AL, G3
    SHL EAX,8
    mov AL, R3
    @@Exit:
    mov @Result, eax
  end;
end;

//--������� ��������� �������� ������������ �����
function GetFileDescription(FileName: string): string;
var
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString:string;
  FValid:boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  FSize := 0;
  FBuffer := nil;
  try
    FValid := False;
    FSize := GetFileVersionInfoSize(PChar(FileName), FHandle);
    if FSize > 0 then
      begin
        GetMem(FBuffer, FSize);
        FValid := GetFileVersionInfo(PChar(FileName), FHandle, FSize, FBuffer);
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
        if VerQueryValue(FBuffer,
          PChar('\StringFileInfo\' + GetTranslationString + '\FileDescription'),
          Value, Len)
        then
          Result := StrPas(PChar(Value));
      end;
  finally
    if FBuffer <> nil then
      FreeMem(FBuffer, FSize);
  end;
end;

//--������� ��������� ��� ����� ��� ����������
function ExtractFileNameNoExt(FileName: string): string;
var
  TempStr: string;
begin
  TempStr := ExtractFileName(FileName);
  Result := Copy(TempStr, 1, Length(TempStr) - Length(ExtractFileExt(FileName)));
end;

//--������� ��������� ���������� �� ������ (*.lnk)
procedure GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
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
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile), lpShellLinkInfoStruct^.FindData, SLGP_RAWPATH);
      GetDescription(lpShellLinkInfoStruct^.Description, SizeOf(lpShellLinkInfoStruct^.Description));
      GetArguments(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute));
      GetWorkingDirectory(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy));
      GetIconLocation(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon), lpShellLinkInfoStruct^.IconIndex);
      GetHotKey(lpShellLinkInfoStruct^.HotKey);
      GetShowCmd(lpShellLinkInfoStruct^.ShowCommand);
    end;
 end;

//--�������� ������ Str �� ����� Len � ����������� ��������� � ����� (���� ������ ������ Len)
function MyCutting(Str: string; Len: byte): string;
begin
  if Length(Str) <= Len then
    Result := Str
  else
    Result := Copy(Str, 1, Len) + '...';
end;

procedure WarningMessage(AHandle: HWND; AText: string);
begin
  MessageBox(AHandle, PChar(AText), PChar(Language.Messages.Caution),
    MB_ICONWARNING or MB_OK);
end;

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
    ExecInfo.fMask := SEE_MASK_NOASYNC { = SEE_MASK_FLAG_DDEWAIT ��� ������ ������ Delphi }
                   or SEE_MASK_FLAG_NO_UI;
    {$IFDEF UNICODE}
    // �������������, ��. http://www.transl-gunsmoker.ru/2015/01/what-does-SEEMASKUNICODE-flag-in-ShellExecuteEx-actually-do.html
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

function CreateProcess(AExecutable, AParameters, APath: string; AWindowState,
  APriority: Integer; var AErrorCode: Integer): Boolean;
var
  pi: TProcessInformation;
  si: TStartupInfo;
begin
  ZeroMemory(@si, sizeof(si));
  si.cb := SizeOf(si);
  si.dwFlags := STARTF_USESHOWWINDOW;
  si.wShowWindow := AWindowState;
  ZeroMemory(@PI, SizeOf(PI));

  SetLastError(ERROR_INVALID_PARAMETER);
  {$WARN SYMBOL_PLATFORM OFF}
  Result := Windows.CreateProcess(PChar(AExecutable), PChar(AParameters),
    nil, nil, false,
    APriority or CREATE_DEFAULT_ERROR_MODE or CREATE_UNICODE_ENVIRONMENT, nil,
    PChar(APath), si, pi);
  if Result then
    AErrorCode := 0
  else
    AErrorCode := GetLastError;
  {$WARN SYMBOL_PLATFORM ON}
  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);
end;

procedure LaunchInExecutor(ALink: TLink; AMainHandle: HWND;
  ADroppedFile: string);
var
  Executor, Parameters: string;
  LinkStrings: TStringList;
begin
  Executor := GetAbsolutePath('%FL_DIR%\FLExecutor.exe');

  LinkStrings := TStringList.Create;
  try
    LinkToStrings(ALink, LinkStrings);
    LinkStrings.Delimiter := ';';
    LinkStrings.QuoteChar := '''';
    Parameters := AnsiQuotedStr(LinkStrings.DelimitedText, '"');
  finally
    LinkStrings.Free;
  end;

  Parameters := Parameters + ' ' + IntToStr(AMainHandle);
  Parameters := Parameters + ' ' + AnsiQuotedStr(Language.FileName, '"');
  Parameters := Parameters + ' ' + AnsiQuotedStr(ADroppedFile, '"');

  ShellExecute(AMainHandle, '', Executor, Parameters);
end;

procedure ThreadLaunch(var ALink: TLink; AMainHandle: HWND; ADroppedFile: string);
var
  WinType, Prior, ErrorCode: integer;
  execparams, path, exec, params: string;
begin
  exec := GetAbsolutePath(ALink.exec);
  path := GetAbsolutePath(ALink.workdir);
  if path = '' then
    path := ExtractFilePath(exec);
  if not ALink.active then
    exit;
  if ((ALink.ques) and (MessageBox(AMainHandle,
    PChar(Format(Language.Messages.RunProgram, [ExtractFileName(exec)])),
    PChar(Language.Messages.Confirmation), MB_ICONQUESTION or MB_YESNO) = IDNO)) then
    exit;
  case ALink.wst of
    0: WinType := SW_SHOW;
    1: WinType := SW_SHOWMAXIMIZED;
    2: WinType := SW_SHOWMINIMIZED;
    3: WinType := SW_HIDE;
  end;
  if ALink.ltype = 0 then
  begin
    if ALink.IsAdmin then
      LaunchInExecutor(ALink, AMainHandle, ADroppedFile)
    else
    begin
      if not FileExists(exec) then
        begin
          WarningMessage(AMainHandle,
            format(Language.Messages.NotFound, [ExtractFileName(exec)]));
          exit;
        end;
      case ALink.pr of
        0: Prior := NORMAL_PRIORITY_CLASS;
        1: Prior := HIGH_PRIORITY_CLASS;
        2: Prior := IDLE_PRIORITY_CLASS;
      end;
      if ADroppedFile <> '' then
        params := stringreplace(ALink.dropparams, '%1', ADroppedFile, [rfReplaceAll])
      else
        params := ALink.params;
      params := GetAbsolutePath(params);
      execparams := Format('"%s" %s', [exec, params]);

      if not CreateProcess(exec, execparams, path, WinType, Prior, ErrorCode) then
      begin
        if ErrorCode = 740 then
        begin
          ALink.IsAdmin := True;
          LaunchInExecutor(ALink, AMainHandle, ADroppedFile)
        end
        else
          RaiseLastOSError(ErrorCode);
      end;
    end;
  end
  else
    ShellExecute(AMainHandle, '', exec, '', path, WinType);
  if ALink.hide then
    PostMessage(AMainHandle, UM_HideMainForm, 0, 0);
end;

procedure NewProcess(ALink: TLink; AMainHandle: HWND; ALaunchID: Integer;
  ADroppedFile: string);
begin
  TThread.CreateAnonymousThread(procedure
    begin
      try
        ThreadLaunch(ALink, AMainHandle, ADroppedFile);
      except
        on e: Exception do
          WarningMessage(AMainHandle,
            StringReplace(e.Message, '%1', ExtractFileName(ALink.exec), [rfReplaceAll]));
      end;
      PostMessage(AMainHandle, UM_LaunchDone, ALink.IsAdmin.ToInteger, ALaunchID);
    end).Start;
end;

function ExpandEnvironmentVariables(const AFileName: string): string;
var
  BuffSize: integer;
  Buffer: string;
begin
  Result := AFileName;
  SetLastError(0);
  BuffSize := ExpandEnvironmentStrings(PChar(AFileName), nil, 0);
  if BuffSize = 0 then
    RaiseLastOSError
  else
  begin
    SetLength(Buffer, BuffSize);
    if ExpandEnvironmentStrings(PChar(AFileName), PChar(Buffer), BuffSize) = 0 then
      RaiseLastOSError;
  end;
  Result := Copy(Buffer, 1, BuffSize - 1);
end;

procedure AddEnvironmentVariable(const AName, AValue: string);
begin
  SetLastError(0);
  if not SetEnvironmentVariable(PChar(AName),
    PChar(ExcludeTrailingPathDelimiter(AValue)))
  then
    RaiseLastOSError;
end;

const
  BUTTON_INI_SECTION = 'button';

procedure LinkToStrings(ALink: TLink; AStrings: TStrings);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create('');
  try
    Ini.WriteString(BUTTON_INI_SECTION, 'version', FLVersion);
    Ini.WriteString(BUTTON_INI_SECTION, 'object', ALink.Exec);
    Ini.WriteString(BUTTON_INI_SECTION, 'workdir', ALink.WorkDir);
    Ini.WriteString(BUTTON_INI_SECTION, 'icon', ALink.Icon);
    Ini.WriteInteger(BUTTON_INI_SECTION, 'iconindex', ALink.IconIndex);
    Ini.WriteString(BUTTON_INI_SECTION, 'parameters', ALink.Params);
    Ini.WriteBool(BUTTON_INI_SECTION, 'dropfiles', ALink.DropFiles);
    Ini.WriteString(BUTTON_INI_SECTION, 'dropparameters', ALink.DropParams);
    Ini.WriteString(BUTTON_INI_SECTION, 'describe', ALink.Descr);
    Ini.WriteBool(BUTTON_INI_SECTION, 'question', ALink.Ques);
    Ini.WriteBool(BUTTON_INI_SECTION, 'hide', ALink.Hide);
    Ini.WriteInteger(BUTTON_INI_SECTION, 'priority', ALink.Pr);
    Ini.WriteInteger(BUTTON_INI_SECTION, 'windowstate', ALink.WSt);
    Ini.WriteBool(BUTTON_INI_SECTION, 'IsAdmin', ALink.IsAdmin);

    Ini.GetStrings(AStrings);
  finally
    Ini.Free;
  end;
end;

function StringsToLink(AStrings: TStrings): TLink;
var
  Ini: TMemIniFile;
  Ext: string;
begin
  Ini := TMemIniFile.Create('');
  try
    Ini.SetStrings(AStrings);

    Result.Exec := Ini.ReadString(BUTTON_INI_SECTION, 'object', '');
    Result.WorkDir := Ini.ReadString(BUTTON_INI_SECTION, 'workdir', '');
    Result.Icon := Ini.ReadString(BUTTON_INI_SECTION, 'icon', '');
    Result.IconIndex := Ini.ReadInteger(BUTTON_INI_SECTION, 'iconindex', 0);
    Result.Params := Ini.ReadString(BUTTON_INI_SECTION, 'parameters', '');
    Result.DropFiles := Ini.ReadBool(BUTTON_INI_SECTION, 'dropfiles', false);
    Result.DropParams := Ini.ReadString(BUTTON_INI_SECTION, 'dropparameters', '');
    Result.Descr := Ini.ReadString(BUTTON_INI_SECTION, 'describe', '');
    Result.Ques := Ini.ReadBool(BUTTON_INI_SECTION, 'question', false);
    Result.Hide := Ini.ReadBool(BUTTON_INI_SECTION, 'hide', false);
    Result.Pr := Ini.ReadInteger(BUTTON_INI_SECTION, 'priority', 0);
    Result.WSt := Ini.ReadInteger(BUTTON_INI_SECTION, 'windowstate', 0);
    Result.IsAdmin := Ini.ReadBool(BUTTON_INI_SECTION, 'IsAdmin', False);

    Result.Active := True;
    Ext := ExtractFileExt(Result.Exec).ToLower;
    if (Ext = '.exe') or (Ext = '.bat') then
      Result.LType := 0
    else
      Result.LType := 1;
  finally
    Ini.Free;
  end;
end;

// Modified version of http://www.sql.ru/forum/actualutils.aspx?action=gotomsg&tid=1160302&msg=17742423
function GetSystemIcon(AIconID: PChar; ALarge: Boolean; ASz: PSize): HICON;
var
  IcoWidth: Integer;
  IcoHeight: Integer;
  LoadIconWithScaleDown: function(hinst: HMODULE; pszName: PWideChar; cx, cy: Integer; out Ico: HICON): HRESULT; stdcall;

  procedure SetStandartSize;
  begin
    if ALarge then
    begin
      IcoWidth := GetSystemMetrics(SM_CXICON);
      IcoHeight := GetSystemMetrics(SM_CYICON);
    end
    else
    begin
      IcoWidth := GetSystemMetrics(SM_CXSMICON);
      IcoHeight := GetSystemMetrics(SM_CYSMICON);
    end;
  end;

begin
  if Assigned(ASz) then
  begin
    IcoWidth := ASz.cx;
    IcoHeight := ASz.cy;
  end
  else
    SetStandartSize;

  LoadIconWithScaleDown := GetProcAddress(GetModuleHandle(comctl32), 'LoadIconWithScaleDown'); // Do Not Localize
  if Assigned(LoadIconWithScaleDown) then
  begin
    if Failed(LoadIconWithScaleDown(0, AIconID, IcoWidth, IcoHeight, Result)) then
      Result := 0;
  end
  else
    Result := 0;

  try
    if Result = 0 then
    begin
      SetStandartSize;
      Result := LoadImage(0, AIconID, IMAGE_ICON, IcoWidth, IcoHeight, LR_DEFAULTCOLOR or LR_SHARED);
      if Result = 0 then
        RaiseLastOSError;
      Result := CopyIcon(Result);
      if Result = 0 then
        RaiseLastOSError;
    end;
  except
    if Result <> 0 then
      DestroyIcon(Result);
    raise;
  end;

  if Assigned(ASz) then
  begin
    ASz.cx := IcoWidth;
    ASz.cy := IcoHeight;
  end;
end;

procedure DrawShieldIcon(ACanvas: TCanvas; APosition: TPoint; ASize: TSize);
var
  IconHandle: HICON;
begin
  if not TOSVersion.Check(6) then
    Exit;

  IconHandle := GetSystemIcon(IDI_SHIELD, False, @ASize);

  DrawIconEx(ACanvas.Handle, APosition.X, APosition.Y, IconHandle, ASize.cx,
    ASize.cy, 0, 0, DI_NORMAL);
end;

procedure InitEnvironment;
var
  sini: TIniFile;
begin
  fl_dir := ExtractFilePath(ParamStr(0));
  fl_root := IncludeTrailingPathDelimiter(ExtractFileDrive(fl_dir));

  sini := TIniFile.Create(fl_dir + 'UseProfile.ini'); //��������� ���� ��������� �������� ��� ����������� ������ ������ ��������� � ����� �������� ��������
  try
    SettingsMode := sini.ReadInteger('general', 'settingsmode', 0);
    if SettingsMode > 2 then SettingsMode := 0;
    if (SettingsMode = 0) then
    begin
      fl_WorkDir := GetSpecialDir(CSIDL_APPDATA) + 'FreeLaunch\';
      if not DirectoryExists(fl_WorkDir) then
        CreateDir(fl_WorkDir);
    end
    else
      fl_WorkDir := fl_dir;
  finally
    sini.Free;
  end;

  {*--��������� ���������� FL_*--*}
  AddEnvironmentVariable('FL_DIR', FL_DIR);
  AddEnvironmentVariable('FL_ROOT', FL_ROOT);
  AddEnvironmentVariable('FL_CONFIG', fl_WorkDir);
end;

end.
