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
/// True for AppUserModelID-like strings (e.g. Publisher.App_xxx), not file paths
function LooksLikeAppUserModelId(const APath: string): Boolean;
/// File, directory, or resolvable shell namespace item
function ObjectExists(const APath: string): Boolean;
/// True if file/dir exists; on Win32 also checks past WOW64 FS redirection
function FsPathExists(const APath: string): Boolean;
/// Return an existing filesystem path (WOW64 + ProgramW6432 remap), or ''
function ResolveExistingFsPath(const APath: string): string;
/// If APath is a known-folder GUID that resolves to a real file/dir, return that
/// path for UI; otherwise return APath unchanged (This PC, Control Panel, …)
function PreferFilesystemPath(const APath: string): string;
/// Friendly name for a shell parsing path (AppsFolder AUMID, ::{GUID}, …)
function GetShellDisplayName(const APath: string): string;
/// Load display image for shell: / ::{GUID} into ABitmap (UWP AppsFolder etc.)
function TryLoadShellItemImage(const APath: string; ASize: Integer;
  ABitmap: TBitmap): Boolean;
/// Prefix ::{GUID} with shell: for ShellExecute / SHGetFileInfo
function NormalizeShellParsingName(const APath: string): string;
/// Try to store a portable known-folder GUID form (:: {GUID}\relative)
function TryPathToKnownFolderGuidForm(const APath: string;
  out AGuidPath: string): Boolean;
/// Find a Start Menu .lnk by UI display name (Win11 Start often drops AUMID only)
function FindStartMenuShortcutByName(const ADisplayName: string;
  const AExtraHint: string = ''): string;
// Преобразование битмапа в PNG с сохранением альфы
procedure AlphaToPng(Src: TBitmap; Dest: TPngImage);
/// Copy PNG pixels into a 32-bit bitmap including the alpha channel
procedure CopyPngToBitmap32(Png: TPngImage; ABitmap: TBitmap);
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
  // Virtual shell items expose one display icon, not ExtractIconEx slots
  if LooksLikeShellGuidPath(FileName) then
    Exit(1);
  Result := ExtractIconEx(PChar(FileName), -1, LIC, SIC, 1);
end;

function GetNegativeCount(FileName: string): Integer;
var
  LIC, SIC: HICON;
  icount, I: Integer;
begin
  Result := 0;
  if LooksLikeShellGuidPath(FileName) then
    Exit;
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

function GetPackagesByPackageFamily(PackageFamilyName: PWideChar;
  var Count: UINT; PackageFullNames: Pointer; var BufferLength: UINT;
  Buffer: PWideChar): LONG; stdcall;
  external kernel32 name 'GetPackagesByPackageFamily';

function GetPackagePathByFullName(PackageFullName: PWideChar;
  var PathLength: UINT; Path: PWideChar): LONG; stdcall;
  external kernel32 name 'GetPackagePathByFullName';

function Wow64DisableWow64FsRedirection(out OldValue: Pointer): BOOL; stdcall;
  external kernel32 name 'Wow64DisableWow64FsRedirection';

function Wow64RevertWow64FsRedirection(OldValue: Pointer): BOOL; stdcall;
  external kernel32 name 'Wow64RevertWow64FsRedirection';

type
  TWow64FsRedirGuard = record
    Active: Boolean;
    Old: Pointer;
    procedure Enter;
    procedure Leave;
  end;

procedure TWow64FsRedirGuard.Enter;
begin
  Active := False;
  Old := nil;
  // Win32 FreeLaunch: WOW64 redirects "C:\Program Files\WindowsApps" to
  // "Program Files (x86)\WindowsApps" where package files are invisible.
{$IFDEF WIN32}
  Active := Wow64DisableWow64FsRedirection(Old);
{$ENDIF}
end;

procedure TWow64FsRedirGuard.Leave;
begin
  if Active then
  begin
    Wow64RevertWow64FsRedirection(Old);
    Active := False;
  end;
end;

function TryGetShellItemBitmapHandle(const APath: string; ASize: Integer;
  out AHbm: HBITMAP): Boolean;
type
  TGetImageProc = function(Self: Pointer; SizeCx, SizeCy: LongInt;
    Flags: DWORD; out Bitmap: HBITMAP): HRESULT; stdcall;
var
  Item: IShellItem;
  FactoryUnk: IUnknown;
  Path: string;
  Proc: TGetImageProc;
  Hr: HRESULT;
begin
  Result := False;
  AHbm := 0;
  Path := NormalizeShellParsingName(Trim(APath));
  if (Path = '') or
    not (LooksLikeShellGuidPath(APath) or StartsText('shell:', Path)) then
    Exit;
  if ASize < 16 then
    ASize := 16;

  // Prefer creating IShellItemImageFactory directly (avoids Delphi TSize thunk)
  FactoryUnk := nil;
  Hr := SHCreateItemFromParsingName(PWideChar(Path), nil,
    IID_IShellItemImageFactory, FactoryUnk);
  if Failed(Hr) or (FactoryUnk = nil) then
  begin
    Item := nil;
    if Failed(SHCreateItemFromParsingName(PWideChar(Path), nil, IID_IShellItem,
      Item)) or (Item = nil) then
      Exit;
    if Failed(Item.QueryInterface(IID_IShellItemImageFactory, FactoryUnk)) or
      (FactoryUnk = nil) then
      Exit;
  end;

  // Raw vtable call: slot 3 = GetImage(SIZE{cx,cy}, flags, *hbm)
  // VTable is Pointer to first slot; index via byte offset (PPointer is not an array)
  Proc := TGetImageProc(PPointer(NativeUInt(PPointer(Pointer(FactoryUnk))^) +
    3 * SizeOf(Pointer))^);
  AHbm := 0;
  Hr := Proc(Pointer(FactoryUnk), ASize, ASize,
    SIIGBF_RESIZETOFIT or SIIGBF_BIGGERSIZEOK or SIIGBF_ICONONLY, AHbm);
  if Failed(Hr) or (AHbm = 0) then
  begin
    AHbm := 0;
    Hr := Proc(Pointer(FactoryUnk), ASize, ASize,
      SIIGBF_RESIZETOFIT or SIIGBF_BIGGERSIZEOK, AHbm);
    if Failed(Hr) then
      AHbm := 0;
  end;
  Result := AHbm <> 0;
end;

function AppsFolderPackageFamily(const APath: string): string;
var
  S: string;
  P: Integer;
begin
  Result := '';
  S := Trim(APath);
  if not StartsText('shell:AppsFolder\', S) then
    Exit;
  S := Copy(S, Length('shell:AppsFolder\') + 1, MaxInt);
  P := Pos('!', S);
  if P > 0 then
    SetLength(S, P - 1);
  Result := Trim(S);
end;

function TryGetPackagePathByFamily(const AFamily: string;
  out APackagePath: string): Boolean;
var
  Count, BufLen, PathLen: UINT;
  Buf: array of WideChar;
  Names: array of PWideChar;
  FullName: string;
  PathBuf: array of WideChar;
  Hr: LONG;
begin
  Result := False;
  APackagePath := '';
  if AFamily = '' then
    Exit;
  Count := 0;
  BufLen := 0;
  Hr := GetPackagesByPackageFamily(PWideChar(AFamily), Count, nil, BufLen, nil);
  if ((Hr <> ERROR_INSUFFICIENT_BUFFER) and (Hr <> ERROR_SUCCESS)) or
    (Count = 0) or (BufLen = 0) then
    Exit;
  SetLength(Names, Count);
  SetLength(Buf, BufLen);
  Hr := GetPackagesByPackageFamily(PWideChar(AFamily), Count, @Names[0], BufLen,
    @Buf[0]);
  if (Hr <> ERROR_SUCCESS) or (Count = 0) or (Names[0] = nil) then
    Exit;
  FullName := Names[0];
  PathLen := 0;
  Hr := GetPackagePathByFullName(PWideChar(FullName), PathLen, nil);
  if ((Hr <> ERROR_INSUFFICIENT_BUFFER) and (Hr <> ERROR_SUCCESS)) or
    (PathLen = 0) then
    Exit;
  SetLength(PathBuf, PathLen);
  Hr := GetPackagePathByFullName(PWideChar(FullName), PathLen, @PathBuf[0]);
  if Hr <> ERROR_SUCCESS then
    Exit;
  APackagePath := ExcludeTrailingPathDelimiter(PWideChar(@PathBuf[0]));
  Result := APackagePath <> '';
end;

function ResolveAppxLogoFile(const APackagePath, ARelative: string): string;
var
  Rel, Base, Ext, NameOnly, Candidate: string;
  Suffixes: array[0..7] of string;
  I: Integer;
begin
  Result := '';
  Rel := StringReplace(Trim(ARelative), '/', '\', [rfReplaceAll]);
  if Rel = '' then
    Exit;
  while (Rel <> '') and ((Rel[1] = '\') or (Rel[1] = '/')) do
    Delete(Rel, 1, 1);
  Base := ChangeFileExt(Rel, '');
  Ext := ExtractFileExt(Rel);
  if Ext = '' then
    Ext := '.png';
  NameOnly := ExtractFileName(Base);
  Suffixes[0] := '.scale-200';
  Suffixes[1] := '.scale-100';
  Suffixes[2] := '.scale-400';
  Suffixes[3] := '.scale-150';
  Suffixes[4] := '.targetsize-48';
  Suffixes[5] := '.targetsize-32';
  Suffixes[6] := '.targetsize-256';
  Suffixes[7] := '';
  for I := 0 to High(Suffixes) do
  begin
    Candidate := IncludeTrailingPathDelimiter(APackagePath) + Base +
      Suffixes[I] + Ext;
    if FileExists(Candidate) then
      Exit(Candidate);
    Candidate := IncludeTrailingPathDelimiter(APackagePath) + 'Assets\' +
      NameOnly + Suffixes[I] + Ext;
    if FileExists(Candidate) then
      Exit(Candidate);
  end;
  Candidate := IncludeTrailingPathDelimiter(APackagePath) + Rel;
  if FileExists(Candidate) then
    Result := Candidate;
end;

function ExtractAppxManifestLogo(const AManifestXml: string): string;
const
  AttrKeys: array[0..3] of string = (
    'Square44x44Logo="',
    'Square150x150Logo="',
    'Square83x83Logo="',
    'StoreLogo="');
  ElemKeys: array[0..1] of string = ('<Logo>', '<StoreLogo>');
var
  Key: string;
  P, Q, I: Integer;
begin
  Result := '';
  for I := 0 to High(AttrKeys) do
  begin
    Key := AttrKeys[I];
    P := Pos(Key, AManifestXml);
    if P = 0 then
      Continue;
    P := P + Length(Key);
    Q := P;
    while (Q <= Length(AManifestXml)) and (AManifestXml[Q] <> '"') do
      Inc(Q);
    if Q > P then
      Exit(Copy(AManifestXml, P, Q - P));
  end;
  for I := 0 to High(ElemKeys) do
  begin
    Key := ElemKeys[I];
    P := Pos(Key, AManifestXml);
    if P = 0 then
      Continue;
    P := P + Length(Key);
    Q := Pos('</', Copy(AManifestXml, P, MaxInt));
    if Q > 1 then
      Exit(Trim(Copy(AManifestXml, P, Q - 1)));
  end;
end;

procedure CopyPngToBitmap32(Png: TPngImage; ABitmap: TBitmap);
var
  X, Y: Integer;
  Dest: PRGBQuad;
  Alpha: Vcl.Imaging.PNGImage.PByteArray;
  C: TColor;
  HasAlpha: Boolean;
  TransRGB: Longint;
begin
  ABitmap.SetSize(0, 0);
  ABitmap.PixelFormat := pf32bit;
  ABitmap.AlphaFormat := afIgnored;
  ABitmap.SetSize(Png.Width, Png.Height);
  HasAlpha := Png.TransparencyMode = ptmPartial;
  if Png.Transparent then
    TransRGB := ColorToRGB(Png.TransparentColor)
  else
    TransRGB := -1;
  for Y := 0 to Png.Height - 1 do
  begin
    Dest := ABitmap.ScanLine[Y];
    if HasAlpha then
      Alpha := Png.AlphaScanline[Y]
    else
      Alpha := nil;
    for X := 0 to Png.Width - 1 do
    begin
      C := Png.Pixels[X, Y];
      Dest^.rgbRed := GetRValue(C);
      Dest^.rgbGreen := GetGValue(C);
      Dest^.rgbBlue := GetBValue(C);
      if Alpha <> nil then
        Dest^.rgbReserved := Alpha[X]
      else if (TransRGB >= 0) and (ColorToRGB(C) = TransRGB) then
        Dest^.rgbReserved := 0
      else
        Dest^.rgbReserved := 255;
      Inc(Dest);
    end;
  end;
  ABitmap.AlphaFormat := afDefined;
end;

function TryLoadImageFileToBitmap(const AFile: string; ASize: Integer;
  ABitmap: TBitmap): Boolean;
var
  Pic: TPicture;
  Src: TBitmap;
  Png: TPngImage;
  X, Y: Integer;
  Dest: PRGBQuad;
begin
  Result := False;
  if (ABitmap = nil) or (not FileExists(AFile)) then
    Exit;
  Src := TBitmap.Create;
  try
    if SameText(ExtractFileExt(AFile), '.png') then
    begin
      Png := TPngImage.Create;
      try
        try
          Png.LoadFromFile(AFile);
        except
          Exit;
        end;
        if (Png.Width <= 0) or (Png.Height <= 0) then
          Exit;
        CopyPngToBitmap32(Png, Src);
      finally
        Png.Free;
      end;
    end
    else
    begin
      Pic := TPicture.Create;
      try
        try
          Pic.LoadFromFile(AFile);
        except
          Exit;
        end;
        if (Pic.Width <= 0) or (Pic.Height <= 0) then
          Exit;
        Src.PixelFormat := pf32bit;
        Src.AlphaFormat := afIgnored;
        Src.SetSize(Pic.Width, Pic.Height);
        Src.Canvas.Draw(0, 0, Pic.Graphic);
        for Y := 0 to Src.Height - 1 do
        begin
          Dest := Src.ScanLine[Y];
          for X := 0 to Src.Width - 1 do
          begin
            Dest^.rgbReserved := 255;
            Inc(Dest);
          end;
        end;
        Src.AlphaFormat := afDefined;
      finally
        Pic.Free;
      end;
    end;
    if (Src.Width = ASize) and (Src.Height = ASize) then
      ABitmap.Assign(Src)
    else
    begin
      ABitmap.PixelFormat := pf32bit;
      ABitmap.SetSize(ASize, ASize);
      SmoothResize(Src, ABitmap);
    end;
    ABitmap.AlphaFormat := afDefined;
    Result := (ABitmap.Width > 0) and (ABitmap.Height > 0);
  finally
    Src.Free;
  end;
end;

function TryLoadAppxLogoImage(const APath: string; ASize: Integer;
  ABitmap: TBitmap): Boolean;
var
  Family, PackagePath, Manifest, LogoRel, LogoFile: string;
  Guard: TWow64FsRedirGuard;
begin
  Result := False;
  Family := AppsFolderPackageFamily(APath);
  if Family = '' then
    Exit;
  if not TryGetPackagePathByFamily(Family, PackagePath) then
    Exit;

  Guard.Enter;
  try
    Manifest := IncludeTrailingPathDelimiter(PackagePath) + 'AppxManifest.xml';
    if not FileExists(Manifest) then
      Exit;
    try
      LogoRel := ExtractAppxManifestLogo(TFile.ReadAllText(Manifest, TEncoding.UTF8));
    except
      try
        LogoRel := ExtractAppxManifestLogo(TFile.ReadAllText(Manifest));
      except
        Exit;
      end;
    end;
    if LogoRel = '' then
      LogoRel := 'Assets\StoreLogo.png';
    LogoFile := ResolveAppxLogoFile(PackagePath, LogoRel);
    if LogoFile = '' then
      LogoFile := ResolveAppxLogoFile(PackagePath, 'Assets\Square44x44Logo.png');
    if LogoFile = '' then
      LogoFile := ResolveAppxLogoFile(PackagePath, 'Assets\StoreLogo.png');
    if LogoFile = '' then
      Exit;
    Result := TryLoadImageFileToBitmap(LogoFile, ASize, ABitmap);
  finally
    Guard.Leave;
  end;
end;

function CopyHBitmapToBitmap(hbm: HBITMAP; ABitmap: TBitmap): Boolean;
var
  BM: BITMAP;
  SrcDC: HDC;
  OldBmp: HGDIOBJ;
  W, H: Integer;
  BI: TBitmapInfo;
  DC: HDC;
begin
  Result := False;
  if (hbm = 0) or (ABitmap = nil) then
    Exit;
  FillChar(BM, SizeOf(BM), 0);
  if GetObject(hbm, SizeOf(BM), @BM) = 0 then
    Exit;
  W := BM.bmWidth;
  H := Abs(BM.bmHeight);
  if (W <= 0) or (H <= 0) then
    Exit;

  // Do not assign Shell HBITMAP via TBitmap.Handle — VCL often rejects those
  // DIB sections (UWP logos become empty).
  ABitmap.SetSize(0, 0);
  ABitmap.PixelFormat := pf32bit;
  ABitmap.AlphaFormat := afIgnored;
  ABitmap.SetSize(W, H);

  SrcDC := CreateCompatibleDC(0);
  if SrcDC <> 0 then
  try
    OldBmp := SelectObject(SrcDC, hbm);
    if OldBmp <> 0 then
    try
      Result := BitBlt(ABitmap.Canvas.Handle, 0, 0, W, H, SrcDC, 0, 0, SRCCOPY);
    finally
      SelectObject(SrcDC, OldBmp);
    end;
  finally
    DeleteDC(SrcDC);
  end;

  // Shell DIB sections sometimes refuse SelectObject — copy pixels via GetDIBits
  if not Result then
  begin
    FillChar(BI, SizeOf(BI), 0);
    BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
    BI.bmiHeader.biWidth := W;
    BI.bmiHeader.biHeight := -H; // top-down, matches ScanLine[0]
    BI.bmiHeader.biPlanes := 1;
    BI.bmiHeader.biBitCount := 32;
    BI.bmiHeader.biCompression := BI_RGB;
    DC := GetDC(0);
    if DC <> 0 then
    try
      Result := GetDIBits(DC, hbm, 0, Cardinal(H), ABitmap.ScanLine[0], BI,
        DIB_RGB_COLORS) <> 0;
    finally
      ReleaseDC(0, DC);
    end;
  end;

  if Result then
    ABitmap.AlphaFormat := afDefined;
end;

function DrawIconToBitmap(AIcon: HICON; ASize: Integer; ABitmap: TBitmap): Boolean;
begin
  Result := False;
  if (AIcon = 0) or (ABitmap = nil) or (ASize < 1) then
    Exit;
  ABitmap.SetSize(0, 0);
  ABitmap.PixelFormat := pf32bit;
  ABitmap.AlphaFormat := afIgnored;
  ABitmap.SetSize(ASize, ASize);
  // Transparent clear
  ABitmap.Canvas.Brush.Style := bsClear;
  ABitmap.Canvas.FillRect(Rect(0, 0, ASize, ASize));
  Result := DrawIconEx(ABitmap.Canvas.Handle, 0, 0, AIcon, ASize, ASize, 0, 0,
    DI_NORMAL);
  if Result then
    ABitmap.AlphaFormat := afDefined;
end;

function TryExtractShellIcon(const APath: string; ASize: Integer;
  out AIcon: HICON): Boolean;
var
  Path: string;
  Pidl, Child: PItemIDList;
  AttrIn, AttrOut: DWORD;
  Folder: IShellFolder;
  FolderPtr: Pointer;
  Extract: IExtractIconW;
  Loc: array[0..MAX_PATH] of WideChar;
  Idx: Integer;
  Flags: UINT;
  Large, Small: HICON;
  Hr: HRESULT;
begin
  Result := False;
  AIcon := 0;
  Path := NormalizeShellParsingName(Trim(APath));
  if Path = '' then
    Exit;
  if ASize < 16 then
    ASize := 16;

  Pidl := nil;
  AttrIn := 0;
  AttrOut := 0;
  if Failed(SHParseDisplayName(PChar(Path), nil, Pidl, AttrIn, AttrOut)) or
    (Pidl = nil) then
    Exit;
  try
    Child := nil;
    FolderPtr := nil;
    Folder := nil;
    // SHBindToParent takes var ppv: Pointer (not an interface out-param)
    if Failed(SHBindToParent(Pidl, IID_IShellFolder, FolderPtr, Child)) or
      (FolderPtr = nil) or (Child = nil) then
      Exit;
    // Take ownership of the refcount returned by SHBindToParent
    Pointer(Folder) := FolderPtr;
    Extract := nil;
    if Failed(Folder.GetUIObjectOf(0, 1, Child, IID_IExtractIconW, nil, Extract)) or
      (Extract = nil) then
      Exit;

    FillChar(Loc, SizeOf(Loc), 0);
    Idx := 0;
    Flags := 0;
    if Failed(Extract.GetIconLocation(GIL_FORSHELL, Loc, MAX_PATH, Idx, Flags)) then
      Exit;

    Large := 0;
    Small := 0;
    Hr := Extract.Extract(Loc, Cardinal(Idx), Large, Small,
      MakeLong(Word(ASize), Word(ASize)));
    // S_FALSE = caller should ExtractIconEx from Loc; S_OK = icons returned
    if (Large = 0) and (Small = 0) and Succeeded(Hr) and (Loc[0] <> #0) and
      ((Flags and GIL_NOTFILENAME) = 0) then
      ExtractIconEx(Loc, Idx, Large, Small, 1);

    if Large <> 0 then
    begin
      AIcon := Large;
      if (Small <> 0) and (Small <> Large) then
        DestroyIcon(Small);
    end
    else if Small <> 0 then
      AIcon := Small;
    Result := AIcon <> 0;
  finally
    CoTaskMemFree(Pidl);
  end;
end;

function TryLoadShellItemImage(const APath: string; ASize: Integer;
  ABitmap: TBitmap): Boolean;
var
  Hbm: HBITMAP;
  Icon: HICON;
  Path: string;
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
  SFI: TSHFileInfo;
  IsAppsFolder: Boolean;
begin
  Result := False;
  if ABitmap = nil then
    Exit;
  if ASize < 16 then
    ASize := 16;
  Path := NormalizeShellParsingName(Trim(APath));
  if Path = '' then
    Exit;
  IsAppsFolder := StartsText('shell:AppsFolder\', Path);

  // 1) UWP: read package logo with WOW64 FS redirection disabled
  if IsAppsFolder and TryLoadAppxLogoImage(APath, ASize, ABitmap) then
    Exit(True);

  // 2) IShellItemImageFactory via raw vtable
  if TryGetShellItemBitmapHandle(APath, ASize, Hbm) then
  try
    Result := CopyHBitmapToBitmap(Hbm, ABitmap);
  finally
    DeleteObject(Hbm);
  end;
  if Result then
    Exit;

  // 3) IExtractIcon
  if TryExtractShellIcon(APath, ASize, Icon) then
  try
    Result := DrawIconToBitmap(Icon, ASize, ABitmap);
  finally
    DestroyIcon(Icon);
  end;
  if Result then
    Exit;

  // 4) SHGetFileInfo — not for AppsFolder (often blank stub under WOW64)
  if IsAppsFolder then
    Exit;

  Pidl := nil;
  AttrIn := 0;
  AttrOut := 0;
  if Succeeded(SHParseDisplayName(PChar(Path), nil, Pidl, AttrIn, AttrOut)) and
    (Pidl <> nil) then
  try
    FillChar(SFI, SizeOf(SFI), 0);
    if (SHGetFileInfo(PChar(Pidl), 0, SFI, SizeOf(SFI),
      SHGFI_PIDL or SHGFI_ICON or SHGFI_LARGEICON) <> 0) and
      (SFI.hIcon <> 0) then
    try
      Result := DrawIconToBitmap(SFI.hIcon, ASize, ABitmap);
    finally
      DestroyIcon(SFI.hIcon);
    end;
  finally
    CoTaskMemFree(Pidl);
  end;
end;

function BitmapHandleToIcon(hbm: HBITMAP): HICON;
var
  BM: BITMAP;
  Himl: HIMAGELIST;
begin
  Result := 0;
  // CreateIconIndirect on 32-bpp Shell bitmaps yields a fully transparent
  // icon; ImageList COLOR32 preserves alpha correctly.
  if (hbm = 0) or (GetObject(hbm, SizeOf(BM), @BM) = 0) then
    Exit;
  Himl := ImageList_Create(BM.bmWidth, BM.bmHeight, ILC_COLOR32, 1, 1);
  if Himl = 0 then
    Exit;
  try
    if ImageList_Add(Himl, hbm, 0) >= 0 then
      Result := ImageList_GetIcon(Himl, 0, ILD_NORMAL);
  finally
    ImageList_Destroy(Himl);
  end;
end;

function GetShellIcon(FileName: string; Size: Integer = 32): HIcon;
var
  SFI: TSHFileInfo;
  Path: string;
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
  Flags: UINT;
  Bmp: TBitmap;
  Himl: HIMAGELIST;
begin
  Result := 0;
  if Size < 16 then
    Size := 16;

  Path := NormalizeShellParsingName(Trim(FileName));
  if LooksLikeShellGuidPath(FileName) or StartsText('shell:', Path) then
  begin
    Bmp := TBitmap.Create;
    try
      if TryLoadShellItemImage(FileName, Size, Bmp) and (Bmp.Width > 0) then
      begin
        Himl := ImageList_Create(Bmp.Width, Bmp.Height, ILC_COLOR32, 1, 1);
        if Himl <> 0 then
        try
          if ImageList_Add(Himl, Bmp.Handle, 0) >= 0 then
            Result := ImageList_GetIcon(Himl, 0, ILD_NORMAL);
        finally
          ImageList_Destroy(Himl);
        end;
      end;
    finally
      Bmp.Free;
    end;
    if Result <> 0 then
      Exit;

    Pidl := nil;
    AttrIn := 0;
    AttrOut := 0;
    if Succeeded(SHParseDisplayName(PChar(Path), nil, Pidl, AttrIn, AttrOut)) and
      (Pidl <> nil) then
    try
      FillChar(SFI, SizeOf(SFI), 0);
      Flags := SHGFI_PIDL or SHGFI_ICON;
      if Size <= 16 then
        Flags := Flags or SHGFI_SMALLICON
      else
        Flags := Flags or SHGFI_LARGEICON;
      if (SHGetFileInfo(PChar(Pidl), 0, SFI, SizeOf(SFI), Flags) <> 0) and
        (SFI.hIcon <> 0) then
        Result := SFI.hIcon;
    finally
      CoTaskMemFree(Pidl);
    end;
    if Result <> 0 then
      Exit;
  end;

  Path := GetAbsolutePath(FileName);
  if (Path <> '') and (not LooksLikeShellGuidPath(Path)) then
  begin
    FillChar(SFI, SizeOf(SFI), 0);
    Flags := SHGFI_ICON;
    if Size <= 16 then
      Flags := Flags or SHGFI_SMALLICON
    else
      Flags := Flags or SHGFI_LARGEICON;
    if SHGetFileInfo(PChar(Path), 0, SFI, SizeOf(SFI), Flags) <> 0 then
      Result := SFI.hIcon;
  end;
end;

//--Функция извлекает иконку из файла по индексу
function GetFileIcon(FileName: string; Index, Size: Integer): HIcon;
var
  LIC, SIC: HICON;
  FsPath, Norm: string;
  Guard: TWow64FsRedirGuard;
begin
  Result := 0;
  Norm := NormalizeShellParsingName(FileName);

  // Virtual shell items (AppsFolder, Control Panel applets, This PC, …)
  if LooksLikeShellGuidPath(FileName) or StartsText('shell:', Norm) then
  begin
    FsPath := GetAbsolutePath(FileName);
    if (FsPath <> '') and (not LooksLikeShellGuidPath(FsPath)) then
    begin
      Guard.Enter;
      try
        if GetIconCount(FsPath) > 0 then
        begin
          ExtractIconEx(PChar(FsPath), Index, LIC, SIC, 1);
          Result := LIC;
          if Result = 0 then
            Result := SIC;
        end;
      finally
        Guard.Leave;
      end;
      if Result = 0 then
        Result := GetShellIcon(FsPath, Size);
    end;
    if Result = 0 then
      Result := GetShellIcon(FileName, Size);
    if Result = 0 then
      Result := LoadIcon(HInstance, 'RBLANKICON');
    Exit;
  end;

  FsPath := GetAbsolutePath(FileName);
  if (FsPath <> '') and (not LooksLikeShellGuidPath(FsPath)) then
  begin
    Guard.Enter;
    try
      if GetIconCount(FsPath) > 0 then
      begin
        ExtractIconEx(PChar(FsPath), Index, LIC, SIC, 1);
        Result := LIC;
        if Result = 0 then
          Result := SIC;
      end;
    finally
      Guard.Leave;
    end;
    if Result = 0 then
      Result := GetShellIcon(FsPath, Size);
  end;
  if Result = 0 then
    Result := GetShellIcon(FileName, Size);
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

function LooksLikeAppUserModelId(const APath: string): Boolean;
var
  S: string;
begin
  // AUMID: "Publisher.Product_hash" / "Embarcadero.DesktopToasts.C5E43BD0"
  // — has dots, no drive/path separators, not a shell GUID form.
  S := Trim(APath);
  Result := (S <> '') and
    (not LooksLikeShellGuidPath(S)) and
    (Pos('\', S) = 0) and
    (Pos('/', S) = 0) and
    (Pos(':', S) = 0) and
    (Pos('.', S) > 0);
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
  Absolute, FolderFs, Suffix, Pf64: string;
  Mgr: IKnownFolderManager;
  Folder: IKnownFolder;
  FolderId: TKnownFolderID;
  FolderPathPtr: LPWSTR;
  Buf: array[0..MAX_PATH] of Char;
  Len: DWORD;
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

  // Win32: IKnownFolderManager often maps "C:\Program Files\..." to
  // ProgramFilesX86. Prefer ProgramFilesX64 when under %ProgramW6432%.
  Len := ExpandEnvironmentStrings('%ProgramW6432%', Buf, Length(Buf));
  if Len > 1 then
  begin
    SetString(Pf64, PChar(@Buf[0]), Len - 1);
    Pf64 := ExcludeTrailingPathDelimiter(Pf64);
    if (Pf64 <> '') and
      (SameText(Absolute, Pf64) or
       StartsText(IncludeTrailingPathDelimiter(Pf64), Absolute)) then
    begin
      if SameText(Absolute, Pf64) then
        Suffix := ''
      else
        Suffix := Copy(Absolute, Length(Pf64) + 1, MaxInt);
      AGuidPath := '::{6D809377-6AF0-444B-8957-A3773F02200E}' + Suffix;
      Exit(True);
    end;
  end;

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

function FindStartMenuShortcutByName(const ADisplayName: string;
  const AExtraHint: string = ''): string;
var
  Hint, Extra, Root, Lnk, Base, ChosenLnk: string;
  Roots: array[0..3] of string;
  Tokens: TArray<string>;
  Files: TArray<string>;
  R, I, T, Score, BestScore: Integer;

  procedure AddToken(const AToken: string; AllowGeneric: Boolean = False);
  var
    S: string;
    K: Integer;

    function IsGenericToken(const A: string): Boolean;
    begin
      // Publisher fragments like "Microsoft" match Edge and break Settings / mstsc
      Result := SameText(A, 'Microsoft') or SameText(A, 'Windows') or
        SameText(A, 'System') or SameText(A, 'App') or SameText(A, 'Application') or
        SameText(A, 'Shell') or SameText(A, 'Immersive') or SameText(A, 'Host') or
        SameText(A, 'Desktop') or SameText(A, 'Experience') or
        SameText(A, 'Inc') or SameText(A, 'Corp') or SameText(A, 'Corporation') or
        SameText(A, 'Client') or SameText(A, 'Server') or SameText(A, 'Service') or
        SameText(A, 'UI') or SameText(A, 'UWP') or SameText(A, 'Win32');
    end;

  begin
    S := Trim(AToken);
    if S = '' then
      Exit;
    if (not AllowGeneric) and IsGenericToken(S) then
      Exit;
    for K := 0 to High(Tokens) do
      if SameText(Tokens[K], S) then
        Exit;
    SetLength(Tokens, Length(Tokens) + 1);
    Tokens[High(Tokens)] := S;
  end;

  function AnyTokenIn(const S: string): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    if S = '' then
      Exit;
    for K := 0 to High(Tokens) do
      if (Tokens[K] <> '') and
        (ContainsText(S, Tokens[K]) or ContainsText(Tokens[K], S)) then
        Exit(True);
  end;

  function MatchScore(const ABase, ADescr, ATarget, APath: string): Integer;
  var
    K: Integer;
  begin
    Result := 0;
    if (ABase <> '') and SameText(ABase, Hint) then
      Exit(100);
    if (ADescr <> '') and SameText(ADescr, Hint) then
      Exit(95);
    if (ABase <> '') and AnyTokenIn(ABase) then
      Result := Max(Result, 80);
    if (ADescr <> '') and AnyTokenIn(ADescr) then
      Result := Max(Result, 75);
    if (APath <> '') and AnyTokenIn(APath) then
      Result := Max(Result, 70);
    if (ATarget <> '') and AnyTokenIn(ATarget) then
      Result := Max(Result, 72);
    // Brand / product heuristics
    for K := 0 to High(Tokens) do
    begin
      if SameText(Tokens[K], 'Yandex') or ContainsText(Tokens[K], 'Яндекс') then
      begin
        if ContainsText(ATarget, 'YandexBrowser') or
          ContainsText(ATarget, 'browser.exe') or
          ContainsText(APath, 'Yandex') or ContainsText(APath, 'Яндекс') then
          Result := Max(Result, 88);
      end;
      if ContainsText(Tokens[K], 'RAD Studio') or SameText(Tokens[K], 'Delphi') or
        SameText(Tokens[K], 'Embarcadero') then
      begin
        if ContainsText(ATarget, 'bds.exe') then
          Result := Max(Result, 90);
      end;
    end;
  end;

  procedure Consider(const ALnk: string; AScore: Integer);
  begin
    if AScore <= BestScore then
      Exit;
    if FileExists(ALnk) then
    begin
      BestScore := AScore;
      Result := ALnk;
      ChosenLnk := ALnk;
    end;
  end;

begin
  Result := '';
  ChosenLnk := '';
  BestScore := 0;
  Hint := Trim(ADisplayName);
  Extra := Trim(AExtraHint);
  if (Hint = '') and (Extra = '') then
    Exit;

  SetLength(Tokens, 0);
  AddToken(Hint, True);
  AddToken(Extra, True);
  // First word / AUMID publisher segment (Yandex.Browser_… → Yandex)
  if Pos(' ', Hint) > 0 then
    AddToken(Copy(Hint, 1, Pos(' ', Hint) - 1));
  if Pos('.', Extra) > 0 then
  begin
    AddToken(Copy(Extra, 1, Pos('.', Extra) - 1)); // often "Microsoft" — filtered
    // SimonTatham.PuTTY → also token "PuTTY" (product leaf)
    AddToken(Copy(Extra, LastDelimiter('.', Extra) + 1, MaxInt));
  end
  else if Pos('_', Extra) > 0 then
    AddToken(Copy(Extra, 1, Pos('_', Extra) - 1));
  // Common localized aliases
  if AnyTokenIn('Yandex') then
    AddToken('Яндекс', True);
  if AnyTokenIn('Яндекс') then
    AddToken('Yandex', True);

  Roots[0] := GetSpecialDir(CSIDL_PROGRAMS);
  Roots[1] := GetSpecialDir(CSIDL_COMMON_PROGRAMS);
  Roots[2] := GetSpecialDir(CSIDL_DESKTOPDIRECTORY);
  Roots[3] := GetSpecialDir(CSIDL_COMMON_DESKTOPDIRECTORY);

  // Filename match only via token masks — do NOT enumerate every *.lnk
  // (that + GetLinkInfo was freezing DragEnter for UWP apps like Armoury Crate).
  for R := Low(Roots) to High(Roots) do
  begin
    Root := Roots[R];
    if (Root = '') or not DirectoryExists(Root) then
      Continue;
    for T := 0 to High(Tokens) do
    begin
      if Length(Tokens[T]) < 3 then
        Continue;
      // AUMID strings are unsafe as file masks (!, _, long ids)
      if (Pos('!', Tokens[T]) > 0) or (Pos('*', Tokens[T]) > 0) or
        (Pos('?', Tokens[T]) > 0) or (Length(Tokens[T]) > 40) then
        Continue;
      try
        Files := TDirectory.GetFiles(Root, '*' + Tokens[T] + '*.lnk',
          TSearchOption.soAllDirectories);
      except
        Continue;
      end;
      for I := 0 to High(Files) do
      begin
        Lnk := Files[I];
        Base := ExtractFileNameNoExt(Lnk);
        Score := MatchScore(Base, '', '', Lnk);
        // Only strong name matches — weak token hits mapped Control Panel → Edge
        if Score >= 95 then
          Consider(Lnk, Score);
      end;
    end;
  end;

  if (BestScore >= 95) and (ChosenLnk <> '') then
    Result := ChosenLnk;
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
  if (Absolute <> '') and FsPathExists(Absolute) then
    Exit(True);
  if LooksLikeShellGuidPath(APath) or LooksLikeShellGuidPath(Absolute) then
    Exit(ShellItemExists(APath) or ShellItemExists(Absolute));
  Result := False;
end;

function FsPathExists(const APath: string): Boolean;
begin
  Result := ResolveExistingFsPath(APath) <> '';
end;

function MapProgramFiles32To64(const APath: string): string;
var
  Pf32, Pf64: string;
  Buf: array[0..MAX_PATH] of Char;
  Len: DWORD;
begin
  Result := APath;
{$IFDEF WIN32}
  // 32-bit IShellLink/SHGetNameFromIDList rewrite "Program Files" → "(x86)"
  Pf32 := GetSpecialDir(CSIDL_PROGRAM_FILES);
  if (Pf32 = '') or (not StartsText(Pf32, APath)) then
    Exit;
  Len := ExpandEnvironmentStrings('%ProgramW6432%', Buf, Length(Buf));
  if Len <= 1 then
    Exit;
  SetString(Pf64, PChar(@Buf[0]), Len - 1);
  Pf64 := IncludeTrailingPathDelimiter(Pf64);
  if SameText(Pf32, Pf64) then
    Exit;
  Result := Pf64 + Copy(APath, Length(Pf32) + 1, MaxInt);
{$ENDIF}
end;

function ResolveExistingFsPath(const APath: string): string;
var
  Guard: TWow64FsRedirGuard;
  Candidate: string;

  function ExistsPlain(const P: string): Boolean;
  begin
    Result := (P <> '') and (FileExists(P) or DirectoryExists(P));
  end;

  function ExistsWithWow64(const P: string): Boolean;
  begin
    if ExistsPlain(P) then
      Exit(True);
    Guard.Enter;
    try
      Result := ExistsPlain(P);
    finally
      Guard.Leave;
    end;
  end;

begin
  Result := '';
  if Trim(APath) = '' then
    Exit;
  if ExistsWithWow64(APath) then
    Exit(APath);
  // Git Extensions etc.: link APIs yield (x86) path that does not exist
  Candidate := MapProgramFiles32To64(APath);
  if (Candidate <> '') and (not SameText(Candidate, APath)) and
    ExistsWithWow64(Candidate) then
    Exit(Candidate);
end;

function PreferFilesystemPath(const APath: string): string;
var
  Abs: string;
begin
  Result := Trim(APath);
  if (Result = '') or (not LooksLikeShellGuidPath(Result)) then
    Exit;
  Abs := GetAbsolutePath(Result);
  if (Abs <> '') and (not LooksLikeShellGuidPath(Abs)) and FsPathExists(Abs) then
    Result := Abs;
end;

function GetShellDisplayName(const APath: string): string;
var
  Candidate, Leaf: string;
  I, LastGuid: Integer;

  function TryName(const AParsing: string): string;
  var
    It: IShellItem;
    Nm: LPWSTR;
    Pid: PItemIDList;
    Ain, Aout: DWORD;
    Info: TSHFileInfo;
  begin
    Result := '';
    if AParsing = '' then
      Exit;
    It := nil;
    if Succeeded(SHCreateItemFromParsingName(PWideChar(AParsing), nil,
      IID_IShellItem, It)) and (It <> nil) then
    begin
      Nm := nil;
      if Succeeded(It.GetDisplayName(SIGDN_NORMALDISPLAY, Nm)) and (Nm <> nil) then
      try
        Result := Trim(Nm);
        if Result <> '' then
          Exit;
      finally
        CoTaskMemFree(Nm);
      end;
    end;
    Pid := nil;
    Ain := 0;
    Aout := 0;
    if Failed(SHParseDisplayName(PChar(AParsing), nil, Pid, Ain, Aout)) or
      (Pid = nil) then
      Exit;
    try
      Nm := nil;
      if Succeeded(SHGetNameFromIDList(Pid,
        Integer(Cardinal(SIGDN_NORMALDISPLAY)), Nm)) and (Nm <> nil) then
      try
        Result := Trim(Nm);
        if Result <> '' then
          Exit;
      finally
        CoTaskMemFree(Nm);
      end;
      FillChar(Info, SizeOf(Info), 0);
      if SHGetFileInfo(PChar(Pid), 0, Info, SizeOf(Info),
        SHGFI_PIDL or SHGFI_DISPLAYNAME) <> 0 then
        Result := Trim(Info.szDisplayName);
    finally
      CoTaskMemFree(Pid);
    end;
  end;

begin
  Result := '';
  Candidate := NormalizeShellParsingName(Trim(APath));
  if Candidate = '' then
    Exit;

  Result := TryName(Candidate);
  if Result <> '' then
    Exit;

  // Control Panel applet: ::{AllControlPanel}\0\::{AppletId} → try leaf GUID
  LastGuid := 0;
  for I := 1 to Length(Candidate) - 2 do
    if (Candidate[I] = ':') and (Candidate[I + 1] = ':') and
      (Candidate[I + 2] = '{') then
      LastGuid := I;
  if LastGuid > 1 then
  begin
    Leaf := 'shell:' + Copy(Candidate, LastGuid, MaxInt);
    if not SameText(Leaf, Candidate) then
      Result := TryName(Leaf);
  end;
end;

function TryResolveKnownFolderPath(const APath: string; out AResolved: string): Boolean;
var
  S, GuidStr, Suffix, Base: string;
  BraceOpen, BraceClose: Integer;
  FolderId: TGUID;
  FolderPath: LPWSTR;
  Buf: array[0..MAX_PATH] of Char;
  Len: DWORD;
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
  if Succeeded(SHGetKnownFolderPath(FolderId, 0, 0, FolderPath)) and
    (FolderPath <> nil) then
  try
    AResolved := ExcludeTrailingPathDelimiter(string(FolderPath)) + Suffix;
    Result := AResolved <> '';
  finally
    CoTaskMemFree(FolderPath);
  end;
  if Result then
    Exit;

  // 32-bit: FOLDERID_ProgramFilesX64 fails with HRESULT 0x80070002 —
  // fall back to %ProgramW6432% (same physical folder).
  if IsEqualGUID(FolderId, StringToGUID('{6D809377-6AF0-444B-8957-A3773F02200E}')) then
  begin
    Len := ExpandEnvironmentStrings('%ProgramW6432%', Buf, Length(Buf));
    if Len > 1 then
    begin
      SetString(Base, PChar(@Buf[0]), Len - 1);
      AResolved := ExcludeTrailingPathDelimiter(Base) + Suffix;
      Result := AResolved <> '';
    end;
  end;
end;

function ResolveShellPath(const APath: string): string;
var
  Pidl: PItemIDList;
  AttrIn, AttrOut: DWORD;
  PathBuf: array[0..MAX_PATH] of Char;
  Name: LPWSTR;
  Candidate: string;
  Resolved, Existing: string;

  function TakeExisting(const ACandidate: string): string;
  begin
    // May remap Program Files (x86) → ProgramW6432 when the x86 path is missing
    Result := ResolveExistingFsPath(ACandidate);
  end;

begin
  Result := APath;
  if APath = '' then
    Exit;

  // ::{GUID}\file — primary form from Win11 Start / known-folder links (bug #59)
  if TryResolveKnownFolderPath(APath, Resolved) then
  begin
    Existing := TakeExisting(Resolved);
    if Existing <> '' then
      Exit(Existing);
  end;

  Candidate := NormalizeShellParsingName(APath);

  Pidl := nil;
  AttrIn := 0;
  AttrOut := 0;
  if Failed(SHParseDisplayName(PChar(Candidate), nil, Pidl, AttrIn, AttrOut)) then
  begin
    if TryResolveKnownFolderPath(APath, Resolved) then
    begin
      Existing := TakeExisting(Resolved);
      if Existing <> '' then
        Result := Existing;
    end;
    Exit;
  end;
  try
    if SHGetPathFromIDList(Pidl, PathBuf) and (PathBuf[0] <> #0) then
    begin
      Existing := TakeExisting(PathBuf);
      if Existing <> '' then
        Exit(Existing);
      Exit(PathBuf);
    end;
    Name := nil;
    // SIGDN_FILESYSPATH is $80058000; cast avoids W1012 on Integer param
    if Succeeded(SHGetNameFromIDList(Pidl, Integer(Cardinal(SIGDN_FILESYSPATH)),
      Name)) and (Name <> nil) then
    try
      if Name[0] <> #0 then
      begin
        Existing := TakeExisting(string(Name));
        if Existing <> '' then
          Exit(Existing);
        Exit(string(Name));
      end;
    finally
      CoTaskMemFree(Name);
    end;
    // Fall back: known-folder GUID parsing name from the PIDL
    Name := nil;
    if Succeeded(SHGetNameFromIDList(Pidl,
      Integer(Cardinal(SIGDN_DESKTOPABSOLUTEPARSING)), Name)) and (Name <> nil) then
    try
      if TryResolveKnownFolderPath(string(Name), Resolved) then
      begin
        Existing := TakeExisting(Resolved);
        if Existing <> '' then
          Exit(Existing);
      end;
    finally
      CoTaskMemFree(Name);
    end;
  finally
    CoTaskMemFree(Pidl);
  end;

  if TryResolveKnownFolderPath(APath, Resolved) then
  begin
    Existing := TakeExisting(Resolved);
    if Existing <> '' then
      Result := Existing;
  end;
end;

function GetAbsolutePath(s: string): string;
var
  Resolved: string;
begin
  Result := ExpandEnvironmentVariables(s);
  // Keep AppsFolder AUMIDs as Shell parsing names. Resolving them to
  // C:\Program Files\WindowsApps\... breaks icon extraction and previews.
  if StartsText('shell:AppsFolder\', Result) then
    Exit;
  if LooksLikeShellGuidPath(Result) then
  begin
    // Control Panel / This PC stay as parsing names. Only replace when the
    // known-folder form resolves to a real filesystem path (Program Files\…).
    Resolved := ResolveShellPath(Result);
    if (Resolved <> '') and (not LooksLikeShellGuidPath(Resolved)) and
      FsPathExists(Resolved) then
      Result := Resolved;
  end;
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
  LinkFilePath, RawPath, AbsolutePath, ParsingName, FileSysPath, SelectedPath,
    ExpandedPath, ProgramFiles64, IconPath, FriendlyName, LeafName,
    WorkDir: string;
  ExpandedLen: DWORD;
  Pidl: PItemIDList;
  Name: LPWSTR;

  function TargetExists(const APath: string): Boolean;
  begin
    Result := FsPathExists(APath);
  end;

  function ExpandTarget(const APath: string): string;
  begin
    Result := APath;
    if Result = '' then
      Exit;
    try
      Result := ExpandEnvironmentVariables(Result);
    except
      Result := APath;
    end;
  end;

  function PreferStoredTarget(const ARaw, AAbsolute, AParsing,
    AFileSys: string): string;
  var
    Candidate, Expanded: string;

    function IsAppsFolderTarget(const APath: string): Boolean;
    begin
      Result := StartsText('shell:AppsFolder\', APath) or
        LooksLikeAppUserModelId(APath);
    end;

    function TryTakePath(const APath: string): string;
    begin
      Result := '';
      if APath = '' then
        Exit;
      // PuTTY etc.: Start .lnk IDList often has AppsFolder AUMID alongside a
      // real putty.exe path — never prefer AppsFolder here (wrong generic icon).
      if IsAppsFolderTarget(APath) then
        Exit;
      if LooksLikeShellGuidPath(APath) then
        Exit(APath);
      Expanded := ExpandTarget(APath);
      Expanded := ResolveExistingFsPath(Expanded);
      if Expanded = '' then
        Exit;
      // Keep filesystem path (not known-folder GUID) for readable Properties
      Exit(Expanded);
    end;

  begin
    // 1) Real filesystem / non-AppsFolder GUID targets first
    Result := TryTakePath(AFileSys);
    if Result <> '' then
      Exit;
    Result := TryTakePath(AAbsolute);
    if Result <> '' then
      Exit;
    Result := TryTakePath(ARaw);
    if Result <> '' then
      Exit;
    Result := TryTakePath(AParsing);
    if Result <> '' then
      Exit;

    // 2) GUID parsing names (Control Panel, …) — not AppsFolder
    if LooksLikeShellGuidPath(AParsing) and (not IsAppsFolderTarget(AParsing)) then
      Exit(AParsing);
    if LooksLikeShellGuidPath(ARaw) and (not IsAppsFolderTarget(ARaw)) then
      Exit(ARaw);

    // 3) Non-AUMID leftovers
    Candidate := AAbsolute;
    if Candidate = '' then
      Candidate := ARaw;
    if Candidate = '' then
      Candidate := AFileSys;
    if (Candidate <> '') and (not IsAppsFolderTarget(Candidate)) then
    begin
      if LooksLikeShellGuidPath(Candidate) then
        Exit(Candidate);
      Expanded := ResolveExistingFsPath(ExpandTarget(Candidate));
      if Expanded <> '' then
        Exit(Expanded);
      Exit(Candidate);
    end;
    if (AParsing <> '') and LooksLikeShellGuidPath(AParsing) and
      (not IsAppsFolderTarget(AParsing)) then
      Exit(AParsing);

    // Do not promote AppsFolder / bare AUMIDs — caller falls back to the .lnk
    Result := '';
  end;

begin
  AnObj  := CreateComObject(CLSID_ShellLink);
  ShellLink := AnObj as IShellLink;
  PersistFile := AnObj as IPersistFile;
  // ::{GUID}\file.lnk must be resolved to a filesystem path before IPersistFile.Load
  LinkFilePath := Trim(string(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile));
  if LooksLikeShellGuidPath(LinkFilePath) then
  begin
    ExpandedPath := GetAbsolutePath(LinkFilePath);
    if (ExpandedPath <> '') and FileExists(ExpandedPath) then
      LinkFilePath := ExpandedPath;
  end;
  PersistFile.Load(PChar(LinkFilePath), 0);
  with ShellLink do
    begin
      // Skip IShellLink.Resolve: GetPath/IDList already return the stored target.
      // Resolve can hang for seconds when WOW64 rewrites the path to a missing
      // Program Files (x86) location (AmneziaVPN and other 64-bit apps).

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
      FileSysPath := '';
      Pidl := nil;
      if Succeeded(GetIDList(Pidl)) and (Pidl <> nil) then
      try
        Name := nil;
        if Succeeded(SHGetNameFromIDList(Pidl,
          Integer(Cardinal(SIGDN_FILESYSPATH)), Name)) and (Name <> nil) then
        try
          FileSysPath := string(Name);
        finally
          CoTaskMemFree(Name);
        end;
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

      SelectedPath := PreferStoredTarget(RawPath, AbsolutePath, ParsingName,
        FileSysPath);
      // Never keep AppsFolder/AUMID as the .lnk target — FLPanelDropFile will
      // fall back to the .lnk itself (correct PuTTY icon from the shortcut).
      if StartsText('shell:AppsFolder\', SelectedPath) or
        LooksLikeAppUserModelId(SelectedPath) then
        SelectedPath := '';

      // 32-bit: remapping Program Files → ProgramW6432 (filesystem paths only)
      if (SelectedPath <> '') and (not LooksLikeShellGuidPath(SelectedPath)) and
        (not LooksLikeAppUserModelId(SelectedPath)) and
        (not StartsText('shell:AppsFolder\', SelectedPath)) then
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

      // AppsFolder targets: .lnk Description is often the AUMID leaf; WorkDir is
      // usually shell:AppsFolder\ — prefer Shell friendly name, clear WorkDir.
      if StartsText('shell:AppsFolder\', SelectedPath) then
      begin
        FriendlyName := Trim(string(lpShellLinkInfoStruct^.Description));
        LeafName := ExtractFileName(SelectedPath);
        if (FriendlyName = '') or SameText(FriendlyName, LeafName) or
          LooksLikeAppUserModelId(FriendlyName) then
        begin
          FriendlyName := GetShellDisplayName(SelectedPath);
          if FriendlyName <> '' then
            StrPLCopy(lpShellLinkInfoStruct^.Description, FriendlyName,
              Length(lpShellLinkInfoStruct^.Description) - 1);
        end;
        WorkDir := Trim(string(
          lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy));
        if (WorkDir = '') or StartsText('shell:AppsFolder', WorkDir) then
          FillChar(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy,
            SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfWorkingDirectroy), 0);
      end;

      GetIconLocation(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon,
        Length(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon),
        lpShellLinkInfoStruct^.IconIndex);

      IconPath := string(lpShellLinkInfoStruct^.FullPathAndNameOfFileContiningIcon);
      if (IconPath = '') or LooksLikeAppUserModelId(IconPath) then
        IconPath := SelectedPath
      else
        IconPath := PreferFilesystemPath(IconPath);
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
