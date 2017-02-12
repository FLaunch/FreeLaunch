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

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

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

  //--Структура информации о ярлыке
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

//--Функция не позволяет уйти значению за пределы допустимых
function InRange(Value, FromV, ToV: byte): byte;
//--Функция определяет количество иконок в файле
function GetIconCount(FileName: string): integer;
//--Функция извлекает иконку из файла по индексу
function GetFileIcon(FileName: string; OpenIcon: boolean; Index: integer): HIcon;
//--Функция возвращает путь к специальным папкам в Windows
function GetSpecialDir(const CSIDL: byte): string;
function GetAbsolutePath(s: string): string;
//--Функция бреобразует строку вида 0xXXXXXX в цвет
function ColorStrToColor(ColorStr: string): TColor;
//--Функция делает ресайз изображения
procedure SmoothResize(Src, Dst: TBitmap);
//--Нахождение микса двух цветов
function GetColorBetween(StartColor, EndColor: TColor; Pointvalue, Von, Bis: Extended): TColor;
//--Функция извлекает описание исполняемого файла
function GetFileDescription(FileName: string): string;
//--Функция извлекает имя файла без разширения
function ExtractFileNameNoExt(FileName: string): string;
//--Функция извлекает информацию из ярлыка (*.lnk)
procedure GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
//--Обрезает строку Str до длины Len с добавлением троеточия в конец (если строка длинее Len)
function MyCutting(Str: string; Len: byte): string;
//--Процедура для запуска процесса в потоке (при клике по кнопке)
procedure NewProcess(ALink: lnk; AMainHandle: HWND; ADroppedFile: string = '');
/// Замена всех переменных окружения их значениями
function ExpandEnvironmentVariables(const AFileName: string): string;
/// Добавление новой переменной окружения
procedure AddEnvironmentVariable(const AName, AValue: string);
/// Конвертация линка в набор строк
procedure LnkToStrings(ALink: Lnk; AStrings: TStrings);
/// Конвертация набора строк в линк
function StringsToLnk(AStrings: TStrings): Lnk;

var
  fl_root, fl_dir, FLVersion: string;

implementation

uses
  ShellApi, ShFolder, SysUtils, ActiveX, ComObj, ShlObj, FLLanguage,
  System.IniFiles;

//--Функция не позволяет уйти значению за пределы допустимых
//--Входные параметры: значение, минимальное значение, максимальное значение
function InRange(Value, FromV, ToV: byte): byte;
begin
  Result := Value;
  if Value < FromV then Result := FromV;
  if Value > ToV then Result := ToV;
end;

//--Функция определяет количество иконок в файле
function GetIconCount(FileName: string): integer;
begin
  Result := ExtractIcon(HInstance, PChar(FileName), MAXDWORD);
end;

//--Функция извлекает иконку из файла по индексу
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

//--Функция возвращает путь к специальным папкам в Windows
//--Входной параметр: идентификатор пути
//--  CSIDL_APPDATA - Application Data
//--  CSIDL_BITBUCKET - Корзина
//--  CSIDL_CONTROLS - Панель управления
//--  CSIDL_COOKIES - Cookies
//--  CSIDL_DESKTOP - Рабочий стол
//--  CSIDL_DESKTOPDIRECTORY - папка Рабочего стола
//--  CSIDL_DRIVES - Мой компьютер
//--  CSIDL_FAVORITES - Избранное
//--  CSIDL_FONTS - Шрифты
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

//--Функция бреобразует строку вида 0xXXXXXX в цвет
function ColorStrToColor(ColorStr: string): TColor;
var
  e: integer;
begin
  //--Удаляем из строки 0x
  delete(ColorStr, 1, 2);
  //--Пытаемся перевести в десятичный вид
  val('$' + ColorStr, Result, e);
  //--Если не получилось, используем стандартный цвет
  if e <> 0 then
    Result := clBtnFace;
end;

//--Функция делает ресайз изображения
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

//--Нахождение микса двух цветов
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

//--Функция извлекает описание исполняемого файла
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

//--Функция извлекает имя файла без разширения
function ExtractFileNameNoExt(FileName: string): string;
var
  TempStr: string;
begin
  TempStr := ExtractFileName(FileName);
  Result := Copy(TempStr, 1, Length(TempStr) - Length(ExtractFileExt(FileName)));
end;

//--Функция извлекает информацию из ярлыка (*.lnk)
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

//--Обрезает строку Str до длины Len с добавлением троеточия в конец (если строка длинее Len)
function MyCutting(Str: string; Len: byte): string;
begin
  if Length(Str) <= Len then
    Result := Str
  else
    Result := Copy(Str, 1, Len) + '...';
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

procedure ThreadLaunch(ALink: lnk; AMainHandle: HWND; ADroppedFile: string);
var
  WinType, Prior: integer;
  execparams, path, exec, params: string;
  pi: TProcessInformation;
  si: TStartupInfo;
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
      if not FileExists(exec) then
        begin
          MessageBox(AMainHandle,
            PChar(format(Language.Messages.NotFound,[ExtractFileName(exec)])),
            PChar(Language.Messages.Caution), MB_ICONWARNING or MB_OK);
          exit;
        end;
      case ALink.pr of
        0: Prior := NORMAL_PRIORITY_CLASS;
        1: Prior := HIGH_PRIORITY_CLASS;
        2: Prior := IDLE_PRIORITY_CLASS;
      end;
      if ADroppedFile <> '' then
        params := stringreplace(ALink.dropparams, '%1', ADroppedFile, [])
      else
        params := ALink.params;
      params := GetAbsolutePath(params);
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
    end;
  if ALink.ltype = 1 then
    ShellExecute(AMainHandle, '', exec, '', path, WinType);
  if ALink.hide then
    PostMessage(AMainHandle, UM_HideMainForm, 0, 0);
end;

procedure NewProcess(ALink: lnk; AMainHandle: HWND; ADroppedFile: string);
begin
  TThread.CreateAnonymousThread(procedure
    begin
      ThreadLaunch(ALink, AMainHandle, ADroppedFile);
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
    RaiseLastWin32Error
  else
  begin
    SetLength(Buffer, BuffSize);
    if ExpandEnvironmentStrings(PChar(AFileName), PChar(Buffer), BuffSize) = 0 then
      RaiseLastWin32Error;
  end;
  Result := Copy(Buffer, 1, BuffSize - 1);
end;

procedure AddEnvironmentVariable(const AName, AValue: string);
begin
  SetLastError(0);
  if not SetEnvironmentVariable(PChar(AName),
    PChar(ExcludeTrailingPathDelimiter(AValue)))
  then
    RaiseLastWin32Error;
end;

const
  BUTTON_INI_SECTION = 'button';

procedure LnkToStrings(ALink: Lnk; AStrings: TStrings);
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

    Ini.GetStrings(AStrings);
  finally
    Ini.Free;
  end;
end;

function StringsToLnk(AStrings: TStrings): Lnk;
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

    Ext := ExtractFileExt(Result.Exec).ToLower;
    if (Ext = '.exe') or (Ext = '.bat') then
      Result.LType := 0
    else
      Result.LType := 1;
  finally
    Ini.Free;
  end;
end;

end.
