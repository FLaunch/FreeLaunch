{
  ##########################################################################
  #  FreeLaunch 2.5 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2017 FreeLaunch Team                                    #
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
  Dialogs, StdCtrls, FLLanguage;

type
  TRenameTabForm = class(TForm)
    GroupBox1: TGroupBox;
    TabNameEdit: TEdit;
    Label1: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public
    class function Execute(ACaption: string): string;
  end;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

class function TRenameTabForm.Execute(ACaption: string): string;
begin
  with TRenameTabForm.Create(Application.MainForm) do
  try
    Result := ACaption;
    TabNameEdit.Text := ACaption;
    if ShowModal = mrOk then
      Result := TabNameEdit.Text;
  finally
    Free;
  end;
end;

procedure TRenameTabForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButton.Click;
  if key = vk_escape then
    CancelButton.Click;
end;

procedure TRenameTabForm.FormShow(Sender: TObject);
begin
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  Caption := Language.TabRename;
  Label1.Caption := Caption + ':';

  TabNameEdit.SelectAll;
  TabNameEdit.SetFocus;
end;

end.
