{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2024 Alexey Tatuyko <feedback@ta2i4.ru>                 #
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
  Winapi.Windows, Winapi.Messages, System.Classes,
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
  Winapi.CommCtrl, Winapi.ShellApi, Winapi.ShFolder, Winapi.ActiveX,
  Winapi.ShlObj,
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
                      (TargetWidth - 1) / (SourceWidth - 1));
    ScaleY := IfThen(SourceHeight = 1, TargetHeight / SourceHeight,
                      (TargetHeight - 1) / (SourceHeight - 1));
    SetLength(ContributorList, TargetWidth);
    if ScaleX < 1 then begin
      Width := 2.0 / ScaleX;
      for I := 0 to TargetWidth - 1 do begin
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
      for I := 0 to TargetWidth - 1 do begin
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
    for K := 0 to SourceHeight - 1 do begin
      SourceLine := Source.ScanLine[K];
      FillLineCacheHorz(SourceWidth, SourceLine, CurrentLine);
      DestPixel := Work.ScanLine[K];
      for I := 0 to TargetWidth - 1 do begin
        DestPixel^ := ApplyContributors(@ContributorList[I], CurrentLine);
        Inc(DestPixel);
      end;
    end;
    for I := 0 to TargetWidth - 1 do ContributorList[I].Contributors := nil;
    ContributorList := nil;
    SetLength(ContributorList, TargetHeight);
    if ScaleY < 1 then begin
      Width := 2.0 / ScaleY;
      for I := 0 to TargetHeight - 1 do begin
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
      for I := 0 to TargetHeight - 1 do begin
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
    for K := 0 to TargetWidth - 1 do begin
      DestPixel := Pointer(DestLine);
      FillLineCacheVert(SourceHeight, Delta, SourceLine, CurrentLine);
      for I := 0 to TargetHeight - 1 do begin
        DestPixel^ := ApplyContributors(@ContributorList[I], CurrentLine);
        Inc(Integer(DestPixel), DestDelta);
      end;
      Inc(SourceLine);
      Inc(DestLine);
    end;
    for I := 0 to TargetHeight - 1 do ContributorList[I].Contributors := nil;
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
  for I := -icount + 1 to 0 do begin
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
begin
  ShGetFileInfo(PChar(FileName), 0, SFI, SizeOf(TShFileInfo), SHGFI_ICON);
  Result := SFI.hIcon;
end;

//--Функция извлекает иконку из файла по индексу
function GetFileIcon(FileName: string; Index, Size: Integer): HIcon;
var
  LIC, SIC: HICON;
begin
  Result := 0;
  if GetIconCount(FileName) > 0 then begin
    ExtractIconEx(PChar(FileName), Index, LIC, SIC, 1);
    Result := LIC;
    if Result = 0 then Result := SIC;
  end;
  if Result = 0 then Result := GetShellIcon(FileName);
  if Result = 0 then Result := LoadIcon(HInstance, 'RBLANKICON');
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

  for Y := 0 to Src.Height - 1 do
  begin
    LineS  := Src.ScanLine[Y];
    ALineD := Dest.AlphaScanline[Y];

    for X := 0 to Src.Width - 1 do
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
  s_temp: string;
begin
  AnObj  := CreateComObject(CLSID_ShellLink);
  ShellLink := AnObj as IShellLink;
  PersistFile := AnObj as IPersistFile;
  PersistFile.Load(PChar(string(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile)), 0);
  with ShellLink do
    begin
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile), lpShellLinkInfoStruct^.FindData, SLGP_RAWPATH);
      //32-bit app specific code for 64-bit Windows below
      if not FileExists(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute) then
        begin
          ExpandEnvironmentStrings('%ProgramW6432%', ch_temp, SizeOf(ch_temp));
          SetString(s_temp, PChar(@ch_temp[0]), High(ch_temp));
          StrPCopy(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, StringReplace(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, GetSpecialDir(CSIDL_PROGRAM_FILES), IncludeTrailingPathDelimiter(TrimRight(s_temp)), [rfReplaceAll, rfIgnoreCase]));
        end;
      //end of specific code
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
begin
  Result := Ext.EndsWith('.exe', True) or Ext.EndsWith('.bat', True);
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

  ShellExecuteFL(AMainHandle, '', Executor, Parameters);
end;

procedure ThreadLaunch(var ALink: TLink; AMainHandle: HWND; ADroppedFile: string);
const
  ERROR_ELEVATION_REQUIRED = 740;
var
  WinType, Prior, ErrorCode: integer;
  execparams, path, exec, params: string;

  function RunasCanBeUsed: Boolean;
  begin
    Result := Prior = NORMAL_PRIORITY_CLASS;
  end;

  procedure RunElevated;
  begin
    if RunasCanBeUsed then
      ShellExecuteFL(AMainHandle, 'runas', exec, execparams, path, WinType)
    else
      LaunchInExecutor(ALink, AMainHandle, ADroppedFile);
  end;

begin
  exec := GetAbsolutePath(ALink.exec);
  path := GetAbsolutePath(ALink.workdir);
  if path = '' then
    path := ExtractFilePath(exec);
  if not ALink.active then
    Exit;
  if (ALink.ques) and
    (RequestMessage(AMainHandle, Format(Language.Messages.RunProgram,
      [ExtractFileName(exec)])) = IDNO)
    then Exit;
  case ALink.wst of
    0: WinType := SW_SHOW;
    1: WinType := SW_SHOWMAXIMIZED;
    2: WinType := SW_SHOWMINIMIZED;
    3: WinType := SW_HIDE;
  end;
  if ALink.ltype = 0 then
  begin
    case ALink.pr of
      0: Prior := NORMAL_PRIORITY_CLASS;
      1: Prior := HIGH_PRIORITY_CLASS;
      2: Prior := IDLE_PRIORITY_CLASS;
      3: Prior := REALTIME_PRIORITY_CLASS;
      4: Prior := BELOW_NORMAL_PRIORITY_CLASS;
      5: Prior := ABOVE_NORMAL_PRIORITY_CLASS;
    end;
    if ADroppedFile <> '' then
      params := stringreplace(ALink.dropparams, '%1', ADroppedFile, [rfReplaceAll])
    else
      params := ALink.params;
    params := GetAbsolutePath(params);
    execparams := Format('"%s" %s', [exec, params]);
    if (ALink.IsAdmin or ALink.AsAdminPerm) and (not ParamStr(0).Contains('FLExecutor.exe')) then
      RunElevated
    else
      if not CreateProcessFL(exec, execparams, path, WinType, Prior, ErrorCode)
      then begin
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
    ShellExecuteFL(AMainHandle, '', exec, '', path, WinType);
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
        if lngfile.ReadInteger('information','langid', -1) = CurrLCID
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
