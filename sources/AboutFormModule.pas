﻿{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2023 Alexey Tatuyko <feedback@ta2i4.ru>                 #
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

//define nightly build directive if DEBUG release configuration enabled
{$IFDEF DEBUG}
  {$DEFINE NIGHTLYBUILD}
{$ENDIF}

unit AboutFormModule;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  FLLanguage;

const
  fn_authors = 'AUTHORS.txt';
  fn_license = 'COPYING.txt';
  fn_thanks  = 'THANKS.txt';

type
  TAboutForm = class(TForm)
    grp1: TGroupBox;
    LogoImg: TImage;
    AppName: TLabel;
    VerInfo: TLabel;
    Credits: TMemo;
    Contributors: TLabel;
    License: TLabel;
    Thanks: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ContributorsClick(Sender: TObject);
    procedure LicenseClick(Sender: TObject);
    procedure ThanksClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure LoadFile(FileName: string);
  end;

implementation

uses
  FLaunchMainFormModule, FLFunctions;

{$R *.dfm}

//loading file to credits
procedure TAboutForm.LoadFile(FileName: string);
begin
  Credits.Lines.Clear;
  try
    Credits.Lines.LoadFromFile(ExtractFilePath(Application.Exename) + FileName);
  except
    Credits.Lines.Text := Format(Language.Messages.FileNotFound, [FileName]);
  end;
end;

//click on "Contributors" label
procedure TAboutForm.ContributorsClick(Sender: TObject);
begin
  LoadFile(fn_authors);
end;

//click on "Thanks" label
procedure TAboutForm.ThanksClick(Sender: TObject);
begin
  LoadFile(fn_thanks);
end;

//click on "License" label
procedure TAboutForm.LicenseClick(Sender: TObject);
begin
  LoadFile(fn_license);
end;

procedure TAboutForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  aboutshowing := false;
  action := CAFree;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  aboutshowing := true;
  if AlwaysOnTop then FormStyle := fsStayOnTop;
  //--Loading language
  Caption := Language.About.Caption;
  AppName.Caption := cr_progname;
  VerInfo.Caption := Format('%s: %s.%s (%s build: %s%s)',
    [Language.About.Version, FlVer.Major, FlVer.Minor,
    {$IFDEF NIGHTLYBUILD}'nightly'{$ELSE}'release'{$ENDIF}, FlVer.Release,
    FlVer.Build]);
  Contributors.Caption := Language.About.Contributors;
  License.Caption := Language.About.License;
  License.Left := grp1.Width - license.Width - 20;
  Thanks.Caption := Language.About.Thanks;
  Thanks.Left := Thanks.Left - Round(Thanks.Width / 2);
  LogoImg.Picture.Icon.Handle := LoadIcon(hinstance, 'MAINICON');
  LoadFile(fn_authors);
end;

end.
