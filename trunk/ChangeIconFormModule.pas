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

unit ChangeIconFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles, PNGExtra, Vcl.Samples.Spin,
  FLFunctions, FLLanguage;

type
  TChangeIconForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    IconEdit: TEdit;
    Label2: TLabel;
    CancelButton: TButton;
    OKButton: TButton;
    IcImage: TImage;
    Label3: TLabel;
    IndexEdit: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure BrowseIconClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefPropsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IndexEditChange(Sender: TObject);
  private
    icindex, iconcount: integer;
    BrowseIcon, RefProps: TPNGButton;
    _ic: string;
    _icindex: integer;
  public
    procedure RefreshProps;
  end;

implementation

uses
  FLaunchMainFormModule, ProgrammPropertiesFormModule, FilePropertiesFormModule,
  FLDialogs;

{$R *.dfm}

procedure TChangeIconForm.RefreshProps;
begin
  icindex := 1;
  iconcount := GetIconCount(GetAbsolutePath(IconEdit.Text));
  if iconcount = 0 then iconcount := 1;
  Label3.Caption := Format(Language.IconSelect.LblOf, [iconcount]);
  IndexEdit.Value := icindex;
  IndexEdit.Enabled := iconcount > 1;
  IndexEdit.MaxValue := iconcount;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(IconEdit.Text), icindex - 1);
end;

procedure TChangeIconForm.BrowseIconClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := FileOrDirSelect(IconEdit.Text);

  if FileName <> IconEdit.Text then
  begin
    IconEdit.Text := FileName;
    RefreshProps;
  end;
end;

procedure TChangeIconForm.OKButtonClick(Sender: TObject);
begin
  if PropertiesMode = 0 then
    begin
      ProgrammPropertiesFormModule.ic := IconEdit.Text;
      ProgrammPropertiesFormModule.iconindex := icindex - 1;
    end;
  if PropertiesMode = 1 then
    begin
      FilePropertiesFormModule.ic := IconEdit.Text;
      FilePropertiesFormModule.iconindex := icindex - 1;
    end;
  Close;
end;

procedure TChangeIconForm.RefPropsClick(Sender: TObject);
begin
  RefreshProps;
end;

procedure TChangeIconForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TChangeIconForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := CAFree;
end;

procedure TChangeIconForm.FormCreate(Sender: TObject);
begin
  BrowseIcon := TPNGButton.Create(GroupBox1);
  with BrowseIcon do
    begin
      Parent := GroupBox1;
      Left := IconEdit.Left + IconEdit.Width + 4;
      Top := IconEdit.Top;
      Height := IconEdit.Height;
      Width := Height;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'OPEN');
      ImageOver.LoadFromResourceName(HInstance, 'OPEN_H');
      OnClick := BrowseIconClick;
    end;
  RefProps := TPNGButton.Create(GroupBox1);
  with RefProps do
    begin
      Parent := GroupBox1;
      Left := BrowseIcon.Left + BrowseIcon.Width + 4;;
      Top := BrowseIcon.Top;
      Height := BrowseIcon.Height;
      Width := Height;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'REFRESH');
      ImageOver.LoadFromResourceName(HInstance, 'REFRESH_H');
      OnClick := RefPropsClick;
    end;
end;

procedure TChangeIconForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TChangeIconForm.FormShow(Sender: TObject);
begin
  Color := FormColor;
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  Caption := Language.IconSelect.Caption;
  Label1.Caption := Language.IconSelect.FileName + ':';
  Label2.Caption := Language.IconSelect.Index + ':';

  if PropertiesMode = 0 then
    begin
      IconEdit.Text := ProgrammPropertiesFormModule.ic;
      iconcount := GetIconCount(GetAbsolutePath(ProgrammPropertiesFormModule.Ic));
      icindex := ProgrammPropertiesFormModule.iconindex + 1;
    end;
  if PropertiesMode = 1 then
    begin
      IconEdit.Text := FilePropertiesFormModule.ic;
      iconcount := GetIconCount(GetAbsolutePath(FilePropertiesFormModule.Ic));
      icindex := FilePropertiesFormModule.iconindex + 1;
    end;

  if iconcount = 0 then iconcount := 1;
  Label3.Caption := Format(Language.IconSelect.LblOf, [iconcount]);
  IndexEdit.Value := icindex;
  IndexEdit.Enabled := iconcount > 1;
  IndexEdit.MaxValue := iconcount;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(IconEdit.Text), icindex - 1);
  IconEdit.SetFocus;
end;

procedure TChangeIconForm.IndexEditChange(Sender: TObject);
begin
  icindex := IndexEdit.Value;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(IconEdit.Text), icindex - 1);
end;

end.
