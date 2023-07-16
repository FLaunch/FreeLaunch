{
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

unit RenameTabFormModule;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  FLLanguage;

type
  TRenameTabForm = class(TForm)
    GroupBox1: TGroupBox;
    TabNameEdit: TEdit;
    Label1: TLabel;
    OKButton: TButton;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
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

procedure TRenameTabForm.FormShow(Sender: TObject);
begin
  if AlwaysOnTop then FormStyle := fsStayOnTop;
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  Caption := Language.TabRename;
  Label1.Caption := Caption + ':';
  TabNameEdit.SelectAll;
  TabNameEdit.SetFocus;
end;

end.
