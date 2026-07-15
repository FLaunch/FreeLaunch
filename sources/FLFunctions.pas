{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2026 Alexey Tatuyko <feedback@ta2i4.ru>                 #
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

unit FLFunctions;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShlObj, Winapi.ActiveX,
  System.Classes,
  Vcl.Graphics, Vcl.Imaging.PNGImage, Vcl.Themes, Vcl.Styles;

type

  TFLThemeInfo = record
    ID: Integer;
    Name: string;
    NameForGUI: string;
  end;

const
  UM_ShowMainForm = WM_USER + 1;
  UM_HideMainForm = WM_USER + 2;
  UM_LaunchDone   = WM_USER + 3;
  //default themes (integrated in exe)
  FLThemes : array [0..2] of TFLThemeInfo = (
      /// first theme is always classic
      (ID: 0; Name: 'Windows'; NameForGUI: 'Classic'),
      // second theme is always for Windows 10+ dark mode
      (ID: 1; Name: 'Windows10 SlateGray'; NameForGUI: 'Slate Gray'),
      /// third theme is always for Windows 10+ light mode
      (ID: 2; Name: 'Windows10'; NameForGUI: 'Light')
    );


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
    AsAdminPerm: Boolean;
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

// Функция не позволяет уйти значению за пределы допустимых
function InRange(Value, FromV, ToV: byte): byte;
// Функции определяют количество иконок в файле
function GetIconCount(FileName: string): integer;
function GetNegativeCount(FileName: string): Integer;
// Функция извлекает иконку из файла по индексу
function GetFileIcon(FileName: string; Index: integer; Size: Integer = 32): HIcon;
// Функция возвращает путь к специальным папкам в Windows
function GetSpecialDir(const CSIDL: Byte): string;
function GetAbsolutePath(s: string): string;
/// Resolves shell GUID / known-folder parsing names to a filesystem path
function ResolveShellPath(const APath: string): string;
/// True for ::{GUID} / shell: parsing names
function LooksLikeShellGuidPath(const APath: string): Boolean;
/// File, directory, or resolvable shell namespace item
function ObjectExists(const APath: string): Boolean;
/// Prefix ::{GUID} with shell: for ShellExecute / SHGetFileInfo
function NormalizeShellParsingName(const APath: string): string;
/// Try to store a portable known-folder GUID form (:: {GUID}\relative)
function TryPathToKnownFolderGuidForm(const APath: string;
  out AGuidPath: string): Boolean;
// Преобразование битмапа в PNG с сохранением альфы
procedure AlphaToPng(Src: TBitmap; Dest: TPngImage);
// Функция делает ресайз изображения
procedure SmoothResize(Src, Dst: TBitmap);
// Функция извлекает описание исполняемого файла
function GetFileDescription(FileName: string): string;
// Функция извлекает имя файла без разширения
function ExtractFileNameNoExt(FileName: string): string;
// Функция извлекает информацию из ярлыка (*.lnk)
procedure GetLinkInfo(lpShellLinkInfoStruct: PShellLinkInfoStruct);
// Обрезает строку Str до длины Len с добавлением троеточия в конец
function MyCutting(Str: string; Len: byte): string;
// Простая обертка над MessageBox
procedure WarningMessage(AHandle: HWND; AText: string);
/// MessageBox with YES and NO buttons
function RequestMessage(AHandle: HWND; AText: string): Integer;
// Определение типа файла
function IsExecutable(Ext: string): Boolean;
// Обертка над CreateProcess
function CreateProcessFL(AExecutable, AParameters, APath: string; AWindowState,
  APriority: Integer; var AErrorCode: Integer): Boolean;
// Запуск процесса внутри потока
procedure ThreadLaunch(var ALink: TLink; AMainHandle: HWND; ADroppedFile: string);
// Процедура для запуска процесса в потоке (при клике по кнопке)
procedure NewProcess(ALink: TLink; AMainHandle: HWND; ALaunchID: Integer;
  ADroppedFile: string);
// launch help file
procedure ExecHelpFile(AMainHandle: HWND; AHelpFileName: string);
// Замена всех переменных окружения их значениями
function ExpandEnvironmentVariables(const AFileName: string): string;
// Добавление новой переменной окружения
procedure AddEnvironmentVariable(const AName, AValue: string);
// Конвертация линка в набор строк
procedure LinkToStrings(ALink: TLink; AStrings: TStrings);
/// <summary> Конвертация набора строк в линк </summary>
function StringsToLink(AStrings: TStrings): TLink;
/// <summary> Рисует иконку Щит UAC на канве </summary>
procedure DrawShieldIcon(ACanvas: TCanvas; APosition: TPoint; ASize: TSize);
/// <summary> Инициализация путей </summary>
procedure InitEnvironment;
/// <summary> Проверка режима работы программы </summary>
function IsPortable: Boolean;
/// <summary> Конвертация пути в путь с использованием переменных окружения </summary>
function PathToPortable(APath: string): string;
/// Check Windows visual theme
function WinThemeDetect: string;
/// Get current App visual theme
function GetAppTheme: string;
/// Get index of visual theme by name
function GetAppThemeIndex(AName: string): Integer;
/// Set App visual theme
procedure SetAppTheme(AName: string);
/// Set App visual theme by ID
function FindSysUserDefLangFile: string;

var
  fl_root, fl_dir, fl_WorkDir, FLVersion: string;
  SettingsMode: integer; //Режим работы (0 - инсталляция, настройки хранятся в APPDATA;
  //1 - инсталляция, настройки хранятся в папке программы;
  //2 - портабельный режим, инсталляция, настройки хранятся в папке программы)

implementation

uses
  System.SysUtils, System.IniFiles, System.IOUtils, System.StrUtils,
  System.Win.ComObj, System.Win.Registry, System.Math,
  Winapi.CommCtrl, Winapi.ShellApi, Winapi.ShFolder,
  FLLanguage;

type

  PBGRAInt = ^TBGRAInt;

  TBGRAInt = record
    R: Integer;
    G: Integer;
    B: Integer;
    A: Integer;
  end;

  PBGRA = ^TBGRA;

  TBGRA = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    A: Byte;
  end;


  PContributor = ^TContributor;

  TContributor = record
    Weight:  Integer;
    Pixel:   Integer;
  end;

  TContributors = array of TContributor;

  PContributorEntry = ^TContributorEntry;
  TContributorEntry = record
    N:            Integer;
    Contributors: TContributors;
  end;

  TContributorList = array of TContributorEntry;

  TBGRAIntArray = array of TBGRAInt;

procedure FillLineCacheHorz(N: Integer; Line: Pointer;
                              const ACurrentLine: TBGRAIntArray);
var
  Run:  PBGRA;
  Data: PBGRAInt;
begin
  Run := Line;
  Data := @ACurrentLine[0];
  Dec(N);
  while N >= 0 do begin
    Data.B := Run.B;
    Data.G := Run.G;
    Data.R := Run.R;
    Data.A := Run.A;
    Inc(Run);
    Inc(Data);
    Dec(N);
  end;
end;

function IntToByte(Value: Integer): Byte;
begin
  Result := 255;
  if Value >= 0 then begin
    if Value <= 255 then Result := Value;
  end else Result := 0;
end;

function BitmapFilter(Value: Single): Single;
const
  B = 1.0 / 3.0;
  C = 1.0 / 3.0;
  OneSixth = 1.0 / 6.0;
var
  Temp: Single;
begin
  if Value < 0.0 then Value := - Value;
  Temp := Sqr(Value);
  if Value < 1.0 then begin
    Value := (((12.0 - 9.0 * B - 6.0 * C) * (Value * Temp)) +
              ((-18.0 + 12.0 * B + 6.0 * C) * Temp) + (6.0 - 2.0 * B));
    Result := Value * OneSixth;
  end else
    if Value < 2.0 then begin
      Value := (((-B - 6.0 * C) * (Value * Temp)) +
                ((6.0 * B + 30.0 * C) * Temp) +
                ((-12.0 * B - 48.0 * C) * Value) +
                (8.0 * B + 24.0 * C));
      Result := Value * OneSixth;
    end else Result := 0.0;
end;

procedure FillLineCacheVert(N, Delta: Integer; Line: Pointer;
                              const ACurrentLine: TBGRAIntArray);
var
  Run: PBGRA;
  Data: PBGRAInt;
begin
  Run := Line;
  Data := @ACurrentLine[0];
  Dec(N);
  while N >= 0 do begin
    Data.B := Run.B;
    Data.G := Run.G;
    Data.R := Run.R;
    Data.A := Run.A;
    Inc(PByte(Run), Delta);
    Inc(Data);
    Dec(N);
  end;
end;

function ApplyContributors(Contributor: PContributorEntry;
                            const ACurrentLine: TBGRAIntArray): TBGRA;
var
  J, Total, Weight: Integer;
  RGB:              TBGRAInt;
  Contr:            PContributor;
  Data:             PBGRAInt;
begin
  Total := 0;
  RGB.B := Total;
  RGB.G := Total;
  RGB.R := Total;
  RGB.A := Total;
  Contr := @Contributor.Contributors[0];
  for J := 0 to Contributor.N - 1 do begin
    Weight := Contr.Weight;
    Inc(Total, Weight);
    Data := @ACurrentLine[Contr.Pixel];
    Inc(RGB.R, Data.R * Weight);
    Inc(RGB.G, Data.G * Weight);
    Inc(RGB.B, Data.B * Weight);
    Inc(RGB.A, Data.A * Weight);
    Inc(Contr);
  end;
  Result.B := IntToByte(IfThen(Total <> 0, RGB.B div Total, RGB.B shr 8));
  Result.G := IntToByte(IfThen(Total <> 0, RGB.G div Total, RGB.G shr 8));
  Result.R := IntToByte(IfThen(Total <> 0, RGB.R div Total, RGB.R shr 8));
  Result.A := IntToByte(IfThen(Total <> 0, RGB.A div Total, RGB.A shr 8));
end;

procedure DoStretch(Source, Target: TBitmap);
var
  ScaleX, ScaleY: Single;
  I, J, K, N: Integer;
  Center: Single;
  Width: Single;
  Weight: Integer;
  Left, Right: Integer;
  Work: TBitmap;
  ContributorList: TContributorList;
  SourceLine, DestLine: PBGRA;
  DestPixel: PBGRA;
  Delta, DestDelta: Integer;
  SourceHeight, SourceWidth: Integer;
  TargetHeight, TargetWidth: Integer;
  CurrentLine: TBGRAIntArray;
begin
  SourceHeight := Source.Height;
  SourceWidth := Source.Width;
  TargetHeight := Target.Height;
  TargetWidth := Target.Width;
  Work := TBitmap.Create;
  try
    Work.PixelFormat := pf32bit;
    Work.Height := SourceHeight;
    Work.Width := TargetWidth;
    ScaleX := IfThen(SourceWidth = 1, TargetWidth / SourceWidth,
                      Pred(TargetWidth) / Pred(SourceWidth));
    ScaleY := IfThen(SourceHeight = 1, TargetHeight / SourceHeight,
                      Pred(TargetHeight) / Pred(SourceHeight));
    SetLength(ContributorList, TargetWidth);
    if ScaleX < 1 then begin
      Width := 2.0 / ScaleX;
      for I := 0 to Pred(TargetWidth) do begin
        ContributorList[I].N := 0;
        Center := I / ScaleX;
        Left := System.Math.Floor(Center - Width);
        Right := System.Math.Ceil(Center + Width);
        SetLength(ContributorList[I].Contributors, Right - Left + 1);
        for J := Left to Right do begin
          Weight := Round(BitmapFilter((Center - J) * ScaleX) * ScaleX * 256);
          if Weight <> 0 then begin
            if J < 0 then N := -J
            else  N := IfThen(J >= SourceWidth, 2 * SourceWidth - J - 1, J);
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end else begin
      for I := 0 to Pred(TargetWidth) do begin
        ContributorList[I].N := 0;
        Center := I / ScaleX;
        Left := System.Math.Floor(Center - 2.0);
        Right := System.Math.Ceil(Center + 2.0);
        SetLength(ContributorList[I].Contributors, Right - Left + 1);
        for J := Left to Right do begin
          Weight := Round(BitmapFilter(Center - J) * 256);
          if Weight <> 0 then begin
            if J < 0 then N := -J
            else N := IfThen(J >= SourceWidth, 2 * SourceWidth - J - 1, J);
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end;
    if SourceWidth > SourceHeight then SetLength(CurrentLine, SourceWidth)
    else SetLength(CurrentLine, SourceHeight);
    for K := 0 to Pred(SourceHeight) do begin
      SourceLine := Source.ScanLine[K];
      FillLineCacheHorz(SourceWidth, SourceLine, CurrentLine);
      DestPixel := Work.ScanLine[K];
      for I := 0 to Pred(TargetWidth) do begin
        DestPixel^ := ApplyContributors(@ContributorList[I], CurrentLine);
        Inc(DestPixel);
      end;
    end;
    for I := 0 to Pred(TargetWidth) do ContributorList[I].Contributors := nil;
    ContributorList := nil;
    SetLength(ContributorList, TargetHeight);
    if ScaleY < 1 then begin
      Width := 2.0 / ScaleY;
      for I := 0 to Pred(TargetHeight) do begin
        ContributorList[I].N := 0;
        Center := I / ScaleY;
        Left := System.Math.Floor(Center - Width);
        Right := System.Math.Ceil(Center + Width);
        SetLength(ContributorList[I].Contributors, Right - Left + 1);
        for J := Left to Right do
        begin
          Weight := Round(BitmapFilter((Center - J) * ScaleY) * ScaleY * 256);
          if Weight <> 0 then begin
            if J < 0 then N := -J
            else N := IfThen(J >= SourceHeight, 2 * SourceHeight - J - 1, J);
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end else begin
      for I := 0 to Pred(TargetHeight) do begin
        ContributorList[I].N := 0;
        Center := I / ScaleY;
        Left := System.Math.Floor(Center - 2.0);
        Right := System.Math.Ceil(Center + 2.0);
        SetLength(ContributorList[I].Contributors, Right - Left + 1);
        for J := Left to Right do begin
          Weight := Round(BitmapFilter(Center - J) * 256);
          if Weight <> 0 then begin
            if J < 0 then N := -J
            else N := IfThen(J >= SourceHeight, 2 * SourceHeight - J - 1, J);
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end;
    SourceLine := Work.ScanLine[0];
    Delta := PAnsiChar(Work.ScanLine[1]) - PAnsiChar(SourceLine);
    DestLine := Target.ScanLine[0];
    DestDelta := PAnsiChar(Target.ScanLine[1]) - PAnsiChar(DestLine);
    for K := 0 to Pred(TargetWidth) do begin
      DestPixel := Pointer(DestLine);
      FillLineCacheVert(SourceHeight, Delta, SourceLine, CurrentLine);
      for I := 0 to Pred(TargetHeight) do begin
        DestPixel^ := ApplyContributors(@ContributorList[I], CurrentLine);
        Inc(Integer(DestPixel), DestDelta);
      end;
      Inc(SourceLine);
      Inc(DestLine);
    end;
    for I := 0 to Pred(TargetHeight) do ContributorList[I].Contributors := nil;
    ContributorList := nil;
  finally
    Work.Free;
    Target.Modified := True;
  end;
end;

procedure Stretch(NewWidth, NewHeight: Cardinal; Source: TGraphic;
                    Target: TBitmap);
var
  Temp:                 TBitmap;
  OriginalPixelFormat:  TPixelFormat;
begin
  if Source.Empty then Exit;
  Temp := TBitmap.Create;
  try
    Temp.Assign(Source);
    Temp.PixelFormat := pf32bit;
    OriginalPixelFormat := Target.PixelFormat;
    Target.FreeImage;
    Target.PixelFormat := pf32bit;
    Target.Width := NewWidth;
    Target.Height := NewHeight;
    DoStretch(Temp, Target);
    Target.PixelFormat := OriginalPixelFormat;
  finally
    Temp.Free;
  end;
end;

//--Функция не позволяет уйти значению за пределы допустимых
//--Входные параметры: значение, минимальное значение, максимальное значение
function InRange(Value, FromV, ToV: byte): byte;
begin
  Result := Value;
  if Value < FromV then Result := FromV;
  if Value > ToV then Result := ToV;
end;

//--Функция определяет количество иконок в файле
function GetIconCount(FileName: string): Integer;
var
  LIC, SIC: HICON;
begin
  Result := ExtractIconEx(PChar(FileName), -1, LIC, SIC, 1);
end;

function GetNegativeCount(FileName: string): Integer;
var
  LIC, SIC: HICON;
  icount, I: Integer;
begin
  Result := 0;
  icount := GetIconCount(FileName);
  LIC := 0;
  SIC := 0;
  for I := - icount + 1 to 0 do begin
    LIC := 0;
    SIC := 0;
    if ExtractIconEx(PChar(FileName), I, LIC, SIC, 1) <> 0 then begin
      Result := -I + 1;
      Break;
    end;
  end;
end;

function GetShellIcon(FileName: string): HIcon;
var
  SFI: TSHFileInfo;
  Path: string;
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
begin
  Result := 0;
  // Prefer a real filesystem path first (Documents / known folders resolve
  // to a path; SHGetFileInfo on the path works reliably).
  Path := GetAbsolutePath(FileName);
  if (Path <> '') and (not LooksLikeShellGuidPath(Path)) then
  begin
    if SHGetFileInfo(PChar(Path), 0, SFI, SizeOf(SFI),
      SHGFI_ICON or SHGFI_LARGEICON) <> 0 then
      Result := SFI.hIcon;
    if Result <> 0 then
      Exit;
  end;

  // Virtual shell items (Control Panel, This PC): PIDL lookup like Explorer
  Path := NormalizeShellParsingName(FileName);
  if LooksLikeShellGuidPath(FileName) or StartsText('shell:', Path) then
  begin
    Pidl := nil;
    AttrIn := 0;
    AttrOut := 0;
    if Succeeded(SHParseDisplayName(PChar(Path), nil, Pidl, AttrIn, AttrOut)) and
      (Pidl <> nil) then
    try
      if (SHGetFileInfo(PChar(Pidl), 0, SFI, SizeOf(SFI),
        SHGFI_PIDL or SHGFI_ICON or SHGFI_LARGEICON) <> 0) and
        (SFI.hIcon <> 0) then
        Result := SFI.hIcon;
    finally
      CoTaskMemFree(Pidl);
    end;
  end;
end;

//--Функция извлекает иконку из файла по индексу
function GetFileIcon(FileName: string; Index, Size: Integer): HIcon;
var
  LIC, SIC: HICON;
  FsPath: string;
begin
  Result := 0;
  // Known-folder GUIDs often resolve to a real file/folder — use that for icons
  FsPath := GetAbsolutePath(FileName);
  if (FsPath <> '') and (not LooksLikeShellGuidPath(FsPath)) then
  begin
    if GetIconCount(FsPath) > 0 then
    begin
      ExtractIconEx(PChar(FsPath), Index, LIC, SIC, 1);
      Result := LIC;
      if Result = 0 then
        Result := SIC;
    end;
    if Result = 0 then
      Result := GetShellIcon(FsPath);
  end;
  if Result = 0 then
    Result := GetShellIcon(FileName);
  if Result = 0 then
    Result := LoadIcon(HInstance, 'RBLANKICON');
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
  if SHGetFolderPath(0, CSIDL, 0, 0, Buf) = 0 then Result := Buf else Exit;
  if Result[length(Result)] <> '\' then Result := Result + '\';
end;

function LooksLikeShellGuidPath(const APath: string): Boolean;
begin
  Result := (Pos('::{', APath) > 0) or StartsText('shell:', APath);
end;

function NormalizeShellParsingName(const APath: string): string;
begin
  Result := Trim(APath);
  if StartsText('::{', Result) then
    Result := 'shell:' + Result;
end;

function TryPathToKnownFolderGuidForm(const APath: string;
  out AGuidPath: string): Boolean;
var
  Absolute, FolderFs, Suffix: string;
  Mgr: IKnownFolderManager;
  Folder: IKnownFolder;
  FolderId: TKnownFolderID;
  FolderPathPtr: LPWSTR;
begin
  Result := False;
  AGuidPath := '';
  Absolute := Trim(APath);
  if (Absolute = '') or LooksLikeShellGuidPath(Absolute) then
    Exit;
  try
    Absolute := ExpandEnvironmentVariables(Absolute);
  except
    // keep Absolute as-is
  end;
  Absolute := ExcludeTrailingPathDelimiter(Absolute);
  if Absolute = '' then
    Exit;

  if Failed(CoCreateInstance(CLSID_KnownFolderManager, nil, CLSCTX_INPROC_SERVER,
    IID_IKnownFolderManager, Mgr)) then
    Exit;
  if Failed(Mgr.FindFolderFromPath(PChar(Absolute), FFFP_NEARESTPARENTMATCH,
    Folder)) then
    Exit;
  if Failed(Folder.GetId(FolderId)) then
    Exit;

  FolderPathPtr := nil;
  if Failed(Folder.GetPath(0, FolderPathPtr)) or (FolderPathPtr = nil) then
    Exit;
  try
    FolderFs := ExcludeTrailingPathDelimiter(string(FolderPathPtr));
  finally
    CoTaskMemFree(FolderPathPtr);
  end;
  if FolderFs = '' then
    Exit;

  if SameText(Absolute, FolderFs) then
    Suffix := ''
  else if StartsText(IncludeTrailingPathDelimiter(FolderFs), Absolute) or
    StartsText(FolderFs + '\', Absolute) or StartsText(FolderFs + '/', Absolute) then
    Suffix := Copy(Absolute, Length(FolderFs) + 1, MaxInt)
  else
    Exit; // path is outside the known folder

  AGuidPath := '::' + GUIDToString(FolderId) + Suffix;
  Result := AGuidPath <> '';
end;

function ShellItemExists(const APath: string): Boolean;
var
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
  Candidate: string;
begin
  Result := False;
  Candidate := NormalizeShellParsingName(APath);
  if Candidate = '' then
    Exit;
  Pidl := nil;
  AttrIn := 0;
  AttrOut := 0;
  if Succeeded(SHParseDisplayName(PChar(Candidate), nil, Pidl, AttrIn, AttrOut)) and
    (Pidl <> nil) then
  begin
    Result := True;
    CoTaskMemFree(Pidl);
  end;
end;

function ObjectExists(const APath: string): Boolean;
var
  Absolute: string;
begin
  if Trim(APath) = '' then
    Exit(False);
  Absolute := GetAbsolutePath(APath);
  if (Absolute <> '') and (FileExists(Absolute) or DirectoryExists(Absolute)) then
    Exit(True);
  if LooksLikeShellGuidPath(APath) or LooksLikeShellGuidPath(Absolute) then
    Exit(ShellItemExists(APath) or ShellItemExists(Absolute));
  Result := False;
end;

function TryResolveKnownFolderPath(const APath: string; out AResolved: string): Boolean;
var
  S, GuidStr, Suffix: string;
  BraceOpen, BraceClose: Integer;
  FolderId: TGUID;
  FolderPath: LPWSTR;
begin
  Result := False;
  AResolved := '';
  S := Trim(APath);
  if StartsText('shell:', S) then
    Delete(S, 1, Length('shell:'));
  // Expect ::{GUID} or ::{GUID}\relative\path
  if not StartsText('::{', S) then
    Exit;
  BraceOpen := Pos('{', S);
  BraceClose := Pos('}', S);
  if (BraceOpen = 0) or (BraceClose <= BraceOpen) then
    Exit;
  GuidStr := Copy(S, BraceOpen, BraceClose - BraceOpen + 1);
  try
    FolderId := StringToGUID(GuidStr);
  except
    Exit;
  end;
  if BraceClose < Length(S) then
    Suffix := Copy(S, BraceClose + 1, MaxInt)
  else
    Suffix := '';
  FolderPath := nil;
  if Failed(SHGetKnownFolderPath(FolderId, 0, 0, FolderPath)) or (FolderPath = nil) then
    Exit;
  try
    AResolved := ExcludeTrailingPathDelimiter(string(FolderPath)) + Suffix;
    Result := AResolved <> '';
  finally
    CoTaskMemFree(FolderPath);
  end;
end;

function ResolveShellPath(const APath: string): string;
var
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
  PathBuf: array[0..MAX_PATH] of Char;
  Name: LPWSTR;
  Candidate: string;
  Resolved: string;

  function UsableFsPath(const ACandidate: string): Boolean;
  begin
    Result := (ACandidate <> '') and
      (FileExists(ACandidate) or DirectoryExists(ACandidate));
  end;

begin
  Result := APath;
  if APath = '' then
    Exit;

  // ::{GUID}\file — primary form from Win11 Start / known-folder links (bug #59)
  if TryResolveKnownFolderPath(APath, Resolved) and UsableFsPath(Resolved) then
    Exit(Resolved);

  Candidate := NormalizeShellParsingName(APath);

  Pidl := nil;
  AttrIn := 0;
  AttrOut := 0;
  if Failed(SHParseDisplayName(PChar(Candidate), nil, Pidl, AttrIn, AttrOut)) then
  begin
    // Keep original GUID string when known-folder expand does not yield a real path
    if TryResolveKnownFolderPath(APath, Resolved) and UsableFsPath(Resolved) then
      Result := Resolved;
    Exit;
  end;
  try
    if SHGetPathFromIDList(Pidl, PathBuf) and (PathBuf[0] <> #0) then
      Exit(PathBuf);
    Name := nil;
    // SIGDN_FILESYSPATH is $80058000; cast avoids W1012 on Integer param
    if Succeeded(SHGetNameFromIDList(Pidl, Integer(Cardinal(SIGDN_FILESYSPATH)),
      Name)) and (Name <> nil) then
    try
      if Name[0] <> #0 then
        Exit(string(Name));
    finally
      CoTaskMemFree(Name);
    end;
    // Fall back: known-folder GUID parsing name from the PIDL
    Name := nil;
    if Succeeded(SHGetNameFromIDList(Pidl,
      Integer(Cardinal(SIGDN_DESKTOPABSOLUTEPARSING)), Name)) and (Name <> nil) then
    try
      if TryResolveKnownFolderPath(string(Name), Resolved) and UsableFsPath(Resolved) then
        Exit(Resolved);
    finally
      CoTaskMemFree(Name);
    end;
  finally
    CoTaskMemFree(Pidl);
  end;

  if TryResolveKnownFolderPath(APath, Resolved) and UsableFsPath(Resolved) then
    Result := Resolved;
end;

function GetAbsolutePath(s: string): string;
begin
  Result := ExpandEnvironmentVariables(s);
  if LooksLikeShellGuidPath(Result) then
    Result := ResolveShellPath(Result);
end;

type
  TRGBQuadArray  = array[0..MaxInt div sizeof(TRGBQuad) - 1] of TRGBQuad;
  PRGBQuadArray  = ^TRGBQuadArray;

procedure AlphaToPng(Src: TBitmap; Dest: TPngImage);
var
  X, Y: Integer;
  LineS:  PRGBQuadArray;
  ALineD: VCL.Imaging.PNGImage.PByteArray;
begin
  Src.PixelFormat := pf32bit; //На всякий случай
  Src.AlphaFormat := afIgnored;
  Dest.Assign(Src);
  Dest.CreateAlpha;

  for Y := 0 to Pred(Src.Height) do
  begin
    LineS  := Src.ScanLine[Y];
    ALineD := Dest.AlphaScanline[Y];

    for X := 0 to Pred(Src.Width) do
      ALineD[X] := LineS[X].rgbReserved;
  end;

  Src.AlphaFormat := afDefined;
  Dest.Modified := True;
end;


//--Функция делает ресайз изображения
procedure SmoothResize(Src, Dst: TBitmap);
begin
  Dst.PixelFormat := pf32bit;
  Stretch(Dst.Width, Dst.Height, Src, Dst);
  Dst.AlphaFormat := afDefined;
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
  ch_temp: array [0..MAX_PATH] of Char;
  RawPath, AbsolutePath, ParsingName, SelectedPath, ExpandedPath,
    GuidForm, ProgramFiles64, IconPath: string;
  ExpandedLen: DWORD;
  Pidl: PItemIDList;
  Name: LPWSTR;

  function TargetExists(const APath: string): Boolean;
  begin
    Result := (APath <> '') and (FileExists(APath) or DirectoryExists(APath));
  end;

  function PreferStoredTarget(const ARaw, AAbsolute, AParsing: string): string;
  var
    Candidate, GuidPath: string;
  begin
    // Priority: keep shell GUID forms (portable + Correct for virtual items).
    if LooksLikeShellGuidPath(ARaw) then
      Exit(ARaw);
    if LooksLikeShellGuidPath(AParsing) then
      Exit(AParsing);
    Candidate := AAbsolute;
    if Candidate = '' then
      Candidate := ARaw;
    if (Candidate <> '') and TryPathToKnownFolderGuidForm(Candidate, GuidPath) then
      Exit(GuidPath);
    if ARaw <> '' then
      Exit(ARaw);
    Result := AAbsolute;
  end;

begin
  AnObj  := CreateComObject(CLSID_ShellLink);
  ShellLink := AnObj as IShellLink;
  PersistFile := AnObj as IPersistFile;
  PersistFile.Load(PChar(string(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile)), 0);
  with ShellLink do
    begin
      Resolve(0, SLR_NO_UI or SLR_NOUPDATE);

      FillChar(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute,
        SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute), 0);
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute),
        lpShellLinkInfoStruct^.FindData, SLGP_RAWPATH);
      RawPath := string(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute);

      FillChar(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute,
        SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute), 0);
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute),
        lpShellLinkInfoStruct^.FindData, 0);
      AbsolutePath := string(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute);

      ParsingName := '';
      Pidl := nil;
      if Succeeded(GetIDList(Pidl)) and (Pidl <> nil) then
      try
        Name := nil;
        if Succeeded(SHGetNameFromIDList(Pidl,
          Integer(Cardinal(SIGDN_DESKTOPABSOLUTEPARSING)), Name)) and
          (Name <> nil) then
        try
          ParsingName := string(Name);
        finally
          CoTaskMemFree(Name);
        end;
      finally
        CoTaskMemFree(Pidl);
      end;

      SelectedPath := PreferStoredTarget(RawPath, AbsolutePath, ParsingName);

      // 32-bit: remapping Program Files → ProgramW6432 (filesystem paths only)
      if (SelectedPath <> '') and (not LooksLikeShellGuidPath(SelectedPath)) then
      begin
        ExpandedPath := '';
        try
          ExpandedPath := ExpandEnvironmentVariables(SelectedPath);
        except
          ExpandedPath := SelectedPath;
        end;
        if (ExpandedPath <> '') and (not TargetExists(ExpandedPath)) then
        begin
          ExpandedLen := ExpandEnvironmentStrings('%ProgramW6432%', ch_temp,
            Length(ch_temp));
          if ExpandedLen > 1 then
          begin
            SetString(ProgramFiles64, PChar(@ch_temp[0]), ExpandedLen - 1);
            SelectedPath := StringReplace(SelectedPath,
              GetSpecialDir(CSIDL_PROGRAM_FILES),
              IncludeTrailingPathDelimiter(ProgramFiles64),
              [rfReplaceAll, rfIgnoreCase]);
          end;
        end;
      end;

      StrPLCopy(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute,
        SelectedPath,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute) - 1);

      GetDescription(lpShellLinkInfoStruct^.Description,
        Length(lpShellLinkInfoStruct^.Description));
      GetArguments(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute,
        Length(lpShellLinkInfoStruct^.ParamStringsOfFileToExecute));
      GetWorkingDirectory(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy));
      GetIconLocation(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon),
        lpShellLinkInfoStruct^.IconIndex);

      IconPath := string(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon);
      if IconPath = '' then
        IconPath := SelectedPath
      else if (not LooksLikeShellGuidPath(IconPath)) and
        TryPathToKnownFolderGuidForm(IconPath, GuidForm) then
        IconPath := GuidForm;
      // Keep GUID icon locations as-is (do not resolve to FS)
      StrPLCopy(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon,
        IconPath,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon) - 1);

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

function RequestMessage(AHandle: HWND; AText: string): Integer;
begin
  Result := MessageBox(AHandle, PChar(AText),
    PChar(Language.Messages.Confirmation),
    MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2 or MB_TOPMOST);
end;

procedure WarningMessage(AHandle: HWND; AText: string);
begin
  MessageBox(AHandle, PChar(AText), PChar(Language.Messages.Caution),
    MB_ICONWARNING or MB_OK);
end;

function IsExecutable(Ext: string): Boolean;
var
  Pathext: string;
  Token: string;
  I: Integer;
  C: Char;
  function NormalizeExt(const S: string): string;
  begin
    Result := Trim(S).ToLower;
    if Result = '' then
      Exit;
    if Result[1] <> '.' then
      Result := '.' + Result;
  end;
begin
  Ext := NormalizeExt(Ext);
  if Ext = '' then
    Exit(False);

  // If PATHEXT is present, follow the current system configuration.
  Pathext := GetEnvironmentVariable('PATHEXT');
  if Pathext <> '' then
  begin
    Token := '';
    for I := 1 to Length(Pathext) do
    begin
      C := Pathext[I];
      if C = ';' then
      begin
        if NormalizeExt(Token) = Ext then
          Exit(True);
        Token := '';
      end
      else
        Token := Token + C;
    end;
    if NormalizeExt(Token) = Ext then
      Exit(True);
  end;

  // Fallback (should be rare): keep historical defaults.
  Result := (Ext = '.exe') or (Ext = '.com') or (Ext = '.bat') or (Ext = '.cmd');
end;

procedure ShellExecuteFL(const AWnd: HWND; const AOperation, AFileName: String;
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

function CreateProcessFL(AExecutable, AParameters, APath: string; AWindowState,
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
  Result := Winapi.Windows.CreateProcess(PChar(AExecutable), PChar(AParameters),
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

procedure ThreadLaunch(var ALink: TLink; AMainHandle: HWND; ADroppedFile: string);
const
  ERROR_ELEVATION_REQUIRED = 740;
var
  WinType, Prior, ErrorCode: integer;
  path, exec, params: string;
  Ext: string;

  function RunasCanBeUsed: Boolean;
  begin
    Result := Prior = NORMAL_PRIORITY_CLASS;
  end;

  procedure RunElevated;
  begin
    if RunasCanBeUsed
    then ShellExecuteFL(AMainHandle, 'runas', exec, params, path, WinType);
  end;

begin
  if not ALink.active then Exit;
  path := GetAbsolutePath(ALink.workdir);

  // GUID / shell: targets: use a real filesystem path when known-folder resolves
  // (Documents, Windows\notepad, ...). shell:::ShellExecute often returns
  // ERROR_NO_ASSOCIATION (1155) for those. Pure virtual items (Control Panel)
  // stay on explorer.exe + shell::: parsing name.
  if LooksLikeShellGuidPath(ALink.exec) then
  begin
    exec := ResolveShellPath(ALink.exec);
    if not (FileExists(exec) or DirectoryExists(exec)) then
    begin
      exec := NormalizeShellParsingName(ALink.exec);
      case ALink.wst of
        0: WinType := SW_SHOW;
        1: WinType := SW_SHOWMAXIMIZED;
        2: WinType := SW_SHOWMINIMIZED;
        3: WinType := SW_HIDE;
      else
        WinType := SW_SHOW;
      end;
      if (ALink.IsAdmin or ALink.AsAdminPerm) then
        ShellExecuteFL(AMainHandle, 'runas', 'explorer.exe', exec, path, WinType)
      else
        ShellExecuteFL(AMainHandle, '', 'explorer.exe', exec, path, WinType);
      if ALink.hide then
        PostMessage(AMainHandle, UM_HideMainForm, 0, 0);
      Exit;
    end;
    // else: fall through with resolved filesystem path in exec
  end
  else
    exec := GetAbsolutePath(ALink.exec);

  if path = '' then path := ExtractFilePath(exec);
  Ext := ExtractFileExt(exec).ToLower;
  case ALink.wst of
    0: WinType := SW_SHOW;
    1: WinType := SW_SHOWMAXIMIZED;
    2: WinType := SW_SHOWMINIMIZED;
    3: WinType := SW_HIDE;
  end;
  if ALink.ltype = 0 then begin
    case ALink.pr of
      0: Prior := NORMAL_PRIORITY_CLASS;
      1: Prior := HIGH_PRIORITY_CLASS;
      2: Prior := IDLE_PRIORITY_CLASS;
      3: Prior := REALTIME_PRIORITY_CLASS;
      4: Prior := BELOW_NORMAL_PRIORITY_CLASS;
      5: Prior := ABOVE_NORMAL_PRIORITY_CLASS;
    end;
    params := GetAbsolutePath(IfThen(
                ADroppedFile <> '',
                StringReplace(ALink.dropparams, '%1', ADroppedFile,
                                [rfReplaceAll]),
                ALink.params
                )
              );
    // Use CreateProcess only for real binaries (.exe/.com). For everything else
    // (including custom extensions from PATHEXT), rely on ShellExecute and file
    // associations for maximum compatibility.
    if (Ext = '.exe') or (Ext = '.com') then
    begin
      if (ALink.IsAdmin or ALink.AsAdminPerm) then
        RunElevated
      else if not CreateProcessFL(exec, params, path, WinType, Prior, ErrorCode) then
      begin
        if ErrorCode = ERROR_ELEVATION_REQUIRED then
        begin
          ALink.IsAdmin := True;
          RunElevated;
        end
        else
          RaiseLastOSError(ErrorCode);
      end;
    end
    else
    begin
      if (ALink.IsAdmin or ALink.AsAdminPerm) then
        ShellExecuteFL(AMainHandle, 'runas', exec, params, path, WinType)
      else
        ShellExecuteFL(AMainHandle, '', exec, params, path, WinType);
    end;
  end else ShellExecuteFL(AMainHandle, '', exec, '', path, WinType);
  if ALink.hide then PostMessage(AMainHandle, UM_HideMainForm, 0, 0);
end;

procedure NewProcess(ALink: TLink; AMainHandle: HWND; ALaunchID: Integer;
  ADroppedFile: string);
begin
  if (ALink.ques) and
    (RequestMessage(AMainHandle, Format(Language.Messages.RunProgram,
      [ExtractFileName(GetAbsolutePath(ALink.exec))])) = IDNO)
  then Exit;
  TThread.CreateAnonymousThread(procedure
    begin
      try
        ThreadLaunch(ALink, AMainHandle, ADroppedFile);
      except
        on E: EOSError do
          if not (e.ErrorCode = ERROR_CANCELLED) then
            WarningMessage(AMainHandle,
              StringReplace(e.Message, '%1', ExtractFileName(ALink.exec), [rfReplaceAll]));
        on E: Exception do
          WarningMessage(AMainHandle,
            StringReplace(e.Message, '%1', ExtractFileName(ALink.exec), [rfReplaceAll]));
      end;
      PostMessage(AMainHandle, UM_LaunchDone, ALink.IsAdmin.ToInteger, ALaunchID);
    end).Start;
end;

procedure ExecHelpFile(AMainHandle: HWND; AHelpFileName: string);
begin
  TThread.CreateAnonymousThread(procedure
    begin
      try
        ShellExecuteFL(AMainHandle, '', GetAbsolutePath(AHelpFileName), '',
          GetAbsolutePath(ExtractFilePath(AHelpFileName)), SW_SHOW);
      except
        on E: Exception do
          WarningMessage(AMainHandle,
            StringReplace(e.Message, '%1', ExtractFileName(AHelpFileName), [rfReplaceAll]));
      end;
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
    if IsExecutable(Ext) then
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
  //Считываем файл первичных настроек для определения режима работы программы
  //и места хранения настроек
  sini := TIniFile.Create(fl_dir + 'UseProfile.ini');
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
  {*--Заполняем переменные FL_*--*}
  AddEnvironmentVariable('FL_DIR', FL_DIR);
  AddEnvironmentVariable('FL_ROOT', FL_ROOT);
  AddEnvironmentVariable('FL_CONFIG', fl_WorkDir);
end;

function IsPortable: Boolean;
begin
  Result := SettingsMode = 2;
end;

function PathToPortable(APath: string): string;
var
  FullPath: string;
begin
  Result := APath;
  if APath = '' then Exit;
  FullPath := TPath.GetFullPath(GetAbsolutePath(APath));
  if ContainsText(FullPath, fl_dir) then
    Result := ReplaceText(FullPath, fl_dir, '%FL_DIR%\')
  else
    if ContainsText(FullPath, fl_root) then
      Result := ReplaceText(FullPath, fl_root, '%FL_ROOT%\');
end;

function WinThemeDetect: string;
const
  DarkKey = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\';
  DarkValue = 'AppsUseLightTheme';
var
  rval: Integer;
  reg: TRegistry;
begin
  Result := FLThemes[0].Name;
  reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if TOSVersion.Check(10) then begin
      if not reg.KeyExists(DarkKey) then Exit;
      if not reg.OpenKeyReadOnly(DarkKey) then Exit;
      if not reg.ValueExists(DarkValue) then Exit;
      rval := reg.ReadInteger(DarkValue) + 1;
      if not (rval in [0..2]) then rval := 0;
      Result := FLThemes[rval].Name;
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

procedure SetAppTheme(AName: string);
begin
  if AName = GetAppTheme then Exit;
  TStyleManager.TrySetStyle(AName, False);
end;

function GetAppTheme: string;
begin
  Result := TStyleManager.ActiveStyle.Name;
end;

function GetAppThemeIndex(AName: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(FLThemes) to High(FLThemes) do
    if FLThemes[I].Name = AName then begin
      Result := I;
      Exit;
    end;
end;

function FindSysUserDefLangFile: string;
var
  CurrLCID: Word;
  sRec: TSearchRec;
  Dir: string;
  lngfile: TIniFile;
begin
  Result := 'english.lng'; //default language
  // get current user language code ID. See the for LCID: https://learn.microsoft.com/ru-ru/openspecs/windows_protocols/ms-lcid/
  CurrLCID := GetUserDefaultUILanguage;
  Dir := ExtractFilePath(ParamStr(0)) + 'languages\';
  if FindFirst(Dir + '*.*', faAnyFile, sRec) = 0 then repeat
    if (sRec.Name = '.') or (sRec.Name = '..') then Continue;
    if ExtractFileExt(sRec.Name).ToLower = '.lng' then begin
      lngfile := TIniFile.Create(Dir + sRec.Name);
      try
        if lngfile.ReadInteger('information','langid', - 1) = CurrLCID
        then begin
          Result := sRec.Name;
          FindClose(sRec);
          Exit;
        end;
      finally
        lngfile.Free;
      end;
    end;
  until FindNext(sRec) <> 0;
  FindClose(sRec);
end;

end.
