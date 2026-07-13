{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2026 Alexey Tatuyko <feedback@ta2i4.ru>                 #
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

unit FLDpi;

interface

uses
  Winapi.Windows, Winapi.MultiMon, Winapi.ShellScaling, System.SysUtils,
  System.Types, Vcl.Forms;

const
  FLDefaultDpi = 96;

function FLGetWindowDpi(AHandle: HWND): Integer;
function FLScaleToDpi(const AValue: Integer; ADpi: Integer): Integer;
function FLUnscaleFromDpi(const AValue: Integer; ADpi: Integer): Integer;
function FLGetWindowMonitor(AHandle: HWND): TMonitor;
function FLGetMonitorDeviceName(AMonitor: TMonitor): string;
function FLFindMonitorByDeviceName(const ADeviceName: string): TMonitor;
function FLMonitorWorkArea(AMonitor: TMonitor): TRect;
function FLMonitorFromPoint(const APoint: TPoint): TMonitor;
function FLGetMonitorDpi(AMonitor: TMonitor): Integer;
function FLRectSpansDpiMonitors(const ARect: TRect): Boolean;
function FLSnapRectToMonitorWorkArea(const ARect: TRect; AMonitor: TMonitor): TRect;

implementation

function FLGetDpiForWindowSafe(AHandle: HWND): UINT; stdcall;
  external 'user32.dll' name 'GetDpiForWindow';

function FLGetDpiForMonitorHandle(HMon: HMONITOR): Integer;
var
  Xdpi, Ydpi: UINT;
begin
  Result := 0;
  if HMon = 0 then
    Exit;
  if GetDpiForMonitor(HMon, MDT_EFFECTIVE_DPI, Xdpi, Ydpi) = S_OK then
    Result := Ydpi;
end;

function FLGetWindowDpi(AHandle: HWND): Integer;
var
  HMon: HMONITOR;
begin
  if AHandle <> 0 then
  begin
    Result := FLGetDpiForWindowSafe(AHandle);
    if Result > 0 then
      Exit;
    HMon := MonitorFromWindow(AHandle, MONITOR_DEFAULTTONEAREST);
    Result := FLGetDpiForMonitorHandle(HMon);
    if Result > 0 then
      Exit;
  end;
  if Screen <> nil then
    Result := Screen.PixelsPerInch
  else
    Result := FLDefaultDpi;
end;

function FLScaleToDpi(const AValue: Integer; ADpi: Integer): Integer;
begin
  if ADpi <= 0 then
    ADpi := FLDefaultDpi;
  Result := MulDiv(AValue, ADpi, FLDefaultDpi);
end;

function FLUnscaleFromDpi(const AValue: Integer; ADpi: Integer): Integer;
begin
  if ADpi <= 0 then
    ADpi := FLDefaultDpi;
  Result := MulDiv(AValue, FLDefaultDpi, ADpi);
end;

function FLGetWindowMonitor(AHandle: HWND): TMonitor;
var
  WindowRect: TRect;
  Center: TPoint;
begin
  Result := nil;
  if Screen = nil then
    Exit;
  if (AHandle <> 0) and GetWindowRect(AHandle, WindowRect) then
  begin
    Center := Point((WindowRect.Left + WindowRect.Right) div 2,
      (WindowRect.Top + WindowRect.Bottom) div 2);
    Result := Screen.MonitorFromPoint(Center);
  end;
  if Result = nil then
    Result := Screen.PrimaryMonitor;
end;

function FLGetMonitorDeviceName(AMonitor: TMonitor): string;
var
  Info: MONITORINFOEX;
  Bounds: TRect;
  HMon: HMONITOR;
begin
  Result := '';
  if AMonitor = nil then
    Exit;
  Bounds := AMonitor.BoundsRect;
  HMon := MonitorFromRect(@Bounds, MONITOR_DEFAULTTONEAREST);
  Info.cbSize := SizeOf(Info);
  if GetMonitorInfo(HMon, @Info) then
    Result := string(PChar(@Info.szDevice[0]));
end;

function FLFindMonitorByDeviceName(const ADeviceName: string): TMonitor;
var
  I: Integer;
begin
  Result := nil;
  if (Screen = nil) or (ADeviceName = '') then
    Exit;
  for I := 0 to Screen.MonitorCount - 1 do
    if SameText(FLGetMonitorDeviceName(Screen.Monitors[I]), ADeviceName) then
      Exit(Screen.Monitors[I]);
end;

function FLMonitorWorkArea(AMonitor: TMonitor): TRect;
begin
  if AMonitor <> nil then
    Result := AMonitor.WorkareaRect
  else
    Result := Rect(0, 0, Screen.DesktopWidth, Screen.DesktopHeight);
end;

function FLMonitorFromPoint(const APoint: TPoint): TMonitor;
begin
  Result := Screen.MonitorFromPoint(APoint);
  if Result = nil then
    Result := Screen.PrimaryMonitor;
end;

function FLGetMonitorDpi(AMonitor: TMonitor): Integer;
begin
  if AMonitor <> nil then
    Result := AMonitor.PixelsPerInch
  else if Screen <> nil then
    Result := Screen.PixelsPerInch
  else
    Result := FLDefaultDpi;
end;

function FLRectSpansDpiMonitors(const ARect: TRect): Boolean;
var
  M1, M2: TMonitor;
  P1, P2: TPoint;
begin
  P1 := Point(ARect.Left + 4, ARect.Top + 4);
  P2 := Point(ARect.Right - 4, ARect.Bottom - 4);
  M1 := FLMonitorFromPoint(P1);
  M2 := FLMonitorFromPoint(P2);
  Result := FLGetMonitorDpi(M1) <> FLGetMonitorDpi(M2);
end;

function FLSnapRectToMonitorWorkArea(const ARect: TRect; AMonitor: TMonitor): TRect;
var
  WorkArea: TRect;
  W, H: Integer;
begin
  Result := ARect;
  if AMonitor = nil then
    Exit;
  WorkArea := FLMonitorWorkArea(AMonitor);
  W := Result.Right - Result.Left;
  H := Result.Bottom - Result.Top;
  if W >= WorkArea.Width then
    Result.Left := WorkArea.Left
  else
  begin
    if Result.Left < WorkArea.Left then
      Result.Left := WorkArea.Left;
    if Result.Left + W > WorkArea.Right then
      Result.Left := WorkArea.Right - W;
  end;
  if H >= WorkArea.Height then
    Result.Top := WorkArea.Top
  else
  begin
    if Result.Top < WorkArea.Top then
      Result.Top := WorkArea.Top;
    if Result.Top + H > WorkArea.Bottom then
      Result.Top := WorkArea.Bottom - H;
  end;
  Result.Right := Result.Left + W;
  Result.Bottom := Result.Top + H;
end;

end.
