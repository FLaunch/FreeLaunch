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
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles, PNGExtra;

type
  TChangeIconForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    IconEdit: TEdit;
    Label2: TLabel;
    IndexEdit: TEdit;
    UpDown1: TUpDown;
    CancelButton: TButton;
    OKButton: TButton;
    IcImage: TImage;
    Label3: TLabel;
    OpenIcon: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure BrowseIconClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IndexEditKeyPress(Sender: TObject; var Key: Char);
    procedure IndexEditChange(Sender: TObject);
    procedure RefPropsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure RefreshProps;
  end;

var
  icindex, iconcount: integer;
  BrowseIcon, RefProps: TPNGButton;
  _ic: string;
  _icindex: integer;

implementation

uses
  FLaunchMainFormModule,
  ProgrammPropertiesFormModule,
  FilePropertiesFormModule;

{$R *.dfm}

procedure TChangeIconForm.RefreshProps;
begin
  icindex := 1;
  iconcount := FlaunchMainForm.GetIconCount(FlaunchMainForm.GetAbsolutePath(IconEdit.Text));
  if iconcount = 0 then iconcount := 1;
  Label3.Caption := Format(lng_iconselect_strings[4], [iconcount]);
  IndexEdit.Text := inttostr(icindex);
  IndexEdit.Enabled := iconcount > 1;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(IconEdit.Text), icindex - 1);
  UpDown1.Min := 1;
  UpDown1.Position := icindex;
  UpDown1.Max := iconcount;
end;

procedure TChangeIconForm.BrowseIconClick(Sender: TObject);
begin
  if fileexists(FlaunchMainForm.GetAbsolutePath(IconEdit.Text)) then
    OpenIcon.FileName := FlaunchMainForm.GetAbsolutePath(IconEdit.Text);
 { else
    if directoryexists(IconEdit.Text) then
      OpenIcon.InitialDir := IconEdit.Text;}
  if OpenIcon.Execute(Handle) then
    begin
      IconEdit.Text := OpenIcon.FileName;
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
      Left := 292;
      Top := 20;
      Width := 21;
      Height := 21;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'OPEN');
      ImageOver.LoadFromResourceName(HInstance, 'OPEN_H');
      OnClick := BrowseIconClick;
    end;
  RefProps := TPNGButton.Create(GroupBox1);
  with RefProps do
    begin
      Parent := GroupBox1;
      Left := 313;
      Top := 20;
      Width := 21;
      Height := 21;
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
  OKButton.Caption := lngstrings[15];
  CancelButton.Caption := lngstrings[16];
  Caption := lng_iconselect_strings[1];
  Label1.Caption := lng_iconselect_strings[2] + ':';
  Label2.Caption := lng_iconselect_strings[3] + ':';

  if PropertiesMode = 0 then
    begin
      IconEdit.Text := ProgrammPropertiesFormModule.ic;
      iconcount := FlaunchMainForm.GetIconCount(FlaunchMainForm.GetAbsolutePath(ProgrammPropertiesFormModule.Ic));
      icindex := ProgrammPropertiesFormModule.iconindex + 1;
    end;
  if PropertiesMode = 1 then
    begin
      IconEdit.Text := FilePropertiesFormModule.ic;
      iconcount := FlaunchMainForm.GetIconCount(FlaunchMainForm.GetAbsolutePath(FilePropertiesFormModule.Ic));
      icindex := FilePropertiesFormModule.iconindex + 1;
    end;

  if iconcount = 0 then iconcount := 1;
  Label3.Caption := Format(lng_iconselect_strings[4], [iconcount]);
  IndexEdit.Text := inttostr(icindex);
  IndexEdit.Enabled := iconcount > 1;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(IconEdit.Text), icindex - 1);
  UpDown1.Min := 1;
  UpDown1.Position := icindex;
  UpDown1.Max := iconcount;
  IconEdit.SetFocus;
end;

procedure TChangeIconForm.IndexEditChange(Sender: TObject);
var
  val: integer;
begin
  if not TryStrToInt(IndexEdit.Text, val) then
    begin
      IndexEdit.Text := inttostr(UpDown1.Position);
      exit;
    end;
  if val > UpDown1.Max then
    begin
      val := UpDown1.Max;
      IndexEdit.Text := inttostr(UpDown1.Max);
    end;
  if val < UpDown1.Min then
    begin
      val := UpDown1.Min;
      IndexEdit.Text := inttostr(UpDown1.Min);
    end;
  UpDown1.Position := val;
  icindex := val;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, IconEdit.Text, icindex - 1);
end;

procedure TChangeIconForm.IndexEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8,'0'..'9']) then Key := #0;
end;

procedure TChangeIconForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  IndexEdit.Text := inttostr(UpDown1.Position);
  icindex := UpDown1.Position;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(IconEdit.Text), icindex - 1);
end;

end.
