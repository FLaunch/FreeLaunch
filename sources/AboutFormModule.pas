{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2022 Alexey Tatuyko <feedback@ta2i4.ru>                 #
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

unit AboutFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, FLLanguage;

type
  TAboutForm = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

implementation

uses
  FLaunchMainFormModule, FLFunctions;

{$R *.dfm}

procedure TAboutForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  aboutshowing := false;
  action := CAFree;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  aboutshowing := true;
  //--Loading language
  Caption := Language.About.Caption;
  Label1.Caption := cr_progname;
  if cr_nightly then
    Label2.Caption := format('%s: %s %s',[Language.About.Version, FLVersion, '(nightly build)'])
  else
    Label2.Caption := format('%s: %s',[Language.About.Version, FLVersion]);
  Label3.Caption := format('%s: %s (%s)',[Language.About.Author, cr_author, cr_authormail]);
  Label4.Caption := format('%s: %s',[Language.About.Translate, Language.Info.Author]);
  Image1.Picture.Icon.Handle := LoadIcon(hinstance, 'MAINICON');
end;

end.
