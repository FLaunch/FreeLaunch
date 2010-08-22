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

unit RenameTabFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type
  TRenameTabForm = class(TForm)
    GroupBox1: TGroupBox;
    TabNameEdit: TEdit;
    Label1: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

  public

  end;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

procedure TRenameTabForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TRenameTabForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := CAFree;
end;

procedure TRenameTabForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TRenameTabForm.FormShow(Sender: TObject);
begin
  Color := FormColor;
  //--Loading language
  OKButton.Caption := lngstrings[15];
  CancelButton.Caption := lngstrings[16];
  Caption := lng_tabname_strings[1];
  Label1.Caption := Caption + ':';

  TabNameEdit.Text := FlaunchMainForm.MainTabs.Pages[GlobTabNum].Caption;
  TabNameEdit.SelectAll;
  TabNameEdit.SetFocus;
end;

procedure TRenameTabForm.OKButtonClick(Sender: TObject);
begin
  if TabNameEdit.Text <> '' then
    FlaunchMainForm.MainTabs.Pages[GlobTabNum].Caption := TabNameEdit.Text;
  FlaunchMainForm.SaveIni;
  Close;
end;

end.
