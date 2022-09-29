{
  ##########################################################################
  #  FreeLaunch 2.7 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2022 FreeLaunch Team                                    #
  #  WEB https://github.com/Ta2i4/FreeLaunch                        #
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

program FLExecutor;

{$R *.res}

uses
  System.SysUtils, Winapi.Windows, FLFunctions, FLLanguage, System.Classes;

var
  WinHandle: HWND;
  ErrorCode: Integer;
  LinkStrings: TStringList;
  Link: TLink;

begin
  try
    InitEnvironment;
    if ParamCount = 0 then
    begin
      if not CreateProcess(fl_dir + 'FLaunch.exe', '', fl_dir, SW_NORMAL,
        NORMAL_PRIORITY_CLASS, ErrorCode)
      then
        RaiseLastOSError(ErrorCode);
    end
    else
    begin
      WinHandle := StrToIntDef(ParamStr(2), 0);
      Language.Load(ParamStr(3));

      LinkStrings := TStringList.Create;
      try
        LinkStrings.Delimiter := ';';
        LinkStrings.QuoteChar := '''';
        LinkStrings.StrictDelimiter := True;
        LinkStrings.DelimitedText := ParamStr(1);
        Link := StringsToLink(LinkStrings);
      finally
        LinkStrings.Free;
      end;

      ThreadLaunch(Link, WinHandle, ParamStr(4));
    end;
  except
    on E: Exception do
      WarningMessage(WinHandle, StringReplace(e.Message, '%1',
        ExtractFileName(Link.exec), [rfReplaceAll]));
  end;
end.
