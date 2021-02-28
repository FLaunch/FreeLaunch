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

program FLaunch;

{$R *.dres}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  Windows,
  FLaunchMainFormModule in 'FLaunchMainFormModule.pas' {FlaunchMainForm},
  ProgrammPropertiesFormModule in 'ProgrammPropertiesFormModule.pas' {ProgrammPropertiesForm},
  FilePropertiesFormModule in 'FilePropertiesFormModule.pas' {FilePropertiesForm},
  ChangeIconFormModule in 'ChangeIconFormModule.pas' {ChangeIconForm},
  RenameTabFormModule in 'RenameTabFormModule.pas' {RenameTabForm},
  SettingsFormModule in 'SettingsFormModule.pas' {SettingsForm},
  AboutFormModule in 'AboutFormModule.pas' {AboutForm},
  FLFunctions in 'FLFunctions.pas',
  FLClasses in 'FLClasses.pas',
  FLLanguage in 'FLLanguage.pas',
  FLDialogs in 'FLDialogs.pas',
  FLData in 'FLData.pas' {Data: TDataModule};

{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}

{$R *.res}

var
  Wnd: Hwnd;

begin
  Wnd := FindWindow('TFlaunchMainForm', nil);
  if Wnd <> 0 then
    PostMessage(Wnd, UM_ShowMainForm, 0, 0)
  else
  begin
    Application.Initialize;
    Application.CreateForm(TData, Data);
  Application.CreateForm(TFlaunchMainForm, FlaunchMainForm);
  Application.Run;
  end;
end.
