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

unit FLFunctions;

interface

uses
  Windows, ShellApi, Graphics, ShFolder, SysUtils, ActiveX, ComObj, ShlObj;

const
  TCM_GETITEMRECT = $130A;

type
  TAByte = array [0..maxInt-1] of byte;
  TPAByte = ^TAByte;
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

  PShellLinkInfoStruct = ^TShellLinkInfoStruct;
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

//--������� �� ��������� ���� �������� �� ������� ����������
function InRange(Value, FromV, ToV: byte): byte;
//--������� ���������� ���������� ������ � �����
function GetIconCount(FileName: string): integer;
//--������� ��������� ������ �� ����� �� �������
function GetFileIcon(FileName: string; OpenIcon: boolean; Index: integer): HIcon;
//--������� ���������� ���� � ����������� ������ � Windows
function GetSpecialDir(const CSIDL: byte): string;
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

implementation

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
      GetPath(lpShellLinkInfoStruct^.FullPathAndNameOfFileToExecute, SizeOf(lpShellLinkInfoStruct^.FullPathAndNameOfLinkFile), lpShellLinkInfoStruct^.FindData, SLGP_UNCPRIORITY);
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

end.
