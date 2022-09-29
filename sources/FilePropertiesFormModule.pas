{
  ##########################################################################
  #  FreeLaunch 2.7 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2022 FreeLaunch Team                                    #
  #  WEB https://github.com/Ta2i4/FreeLaunch                               #
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

unit FilePropertiesFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ShellApi, IniFiles, FLLanguage,
  ChangeIconFormModule, FLData, FLFunctions;

type
  TFilePropertiesForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label4: TLabel;
    DescrEdit: TEdit;
    Label7: TLabel;
    WStyleBox: TComboBox;
    Bevel1: TBevel;
    Label5: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label6: TLabel;
    IcImage: TImage;
    ChangeIconButton: TButton;
    QuesCheckBox: TCheckBox;
    OKButton: TButton;
    CancelButton: TButton;
    HideCheckBox: TCheckBox;
    Label9: TLabel;
    CommandEdit: TButtonedEdit;
    RefProps: TButton;
    WorkFolderEdit: TButtonedEdit;
    procedure FormShow(Sender: TObject);
    procedure BrowseExecClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChangeIconButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RefPropsClick(Sender: TObject);
    procedure CommandEditChange(Sender: TObject);
    procedure WorkFolderClick(Sender: TObject);
  private
    Link: TLink;
  public
    procedure RefreshProps;
    class function Execute(ALink: TLink): TLink;
  end;

var
  ic: string;
  iconindex: integer;

implementation

uses
  FLaunchMainFormModule, FLDialogs;

{$R *.dfm}

procedure TFilePropertiesForm.ChangeIconButtonClick(Sender: TObject);
var
  frm: TChangeIconForm;
begin
  Application.CreateForm(TChangeIconForm, frm);
  frm.ShowModal;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(ic), iconindex);
end;

procedure TFilePropertiesForm.CommandEditChange(Sender: TObject);
begin
  OKButton.Enabled := FileExists(GetAbsolutePath(CommandEdit.Text)) or DirectoryExists(GetAbsolutePath(CommandEdit.Text));
end;

class function TFilePropertiesForm.Execute(ALink: TLink): TLink;
begin
  with TFilePropertiesForm.Create(Application.MainForm) do
  try
    Link := ALink;
    ShowModal;
  finally
    Result := Link;
    Free;
  end;
end;

procedure TFilePropertiesForm.OKButtonClick(Sender: TObject);
begin
  if (not FileExists(GetAbsolutePath(CommandEdit.Text))) and (not DirectoryExists(GetAbsolutePath(CommandEdit.Text))) then
    begin
      fillchar(Link, sizeof(TLink), 0);
      exit;
    end;
  Link.active := true;
  Link.ltype := 1;
  Link.exec := CommandEdit.Text;
  Link.workdir := WorkFolderEdit.Text;
  Link.descr := DescrEdit.Text;
  Link.icon := ic;
  Link.iconindex := iconindex;
  Link.ques := QuesCheckBox.Checked;
  Link.hide := HideCheckBox.Checked;
  Link.wst := WStyleBox.ItemIndex;
end;

procedure TFilePropertiesForm.RefPropsClick(Sender: TObject);
begin
  RefreshProps;
end;

procedure TFilePropertiesForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButton.Click;
  if key = vk_escape then
    ModalResult := mrCancel;
end;

procedure TFilePropertiesForm.FormShow(Sender: TObject);
begin
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  PageControl1.Pages[0].Caption := Language.Properties.Caption;
  Caption := Language.Properties.Caption;
  Label9.Caption := Language.Properties.Folder + ':';
  Label1.Caption := Language.Properties.LblObject + ':';
  Label4.Caption := Language.Properties.Description + ':';
  Label7.Caption := Language.Properties.View + ':';
  WStyleBox.Items.Add(Language.Properties.ViewNormal);
  WStyleBox.Items.Add(Language.Properties.ViewMax);
  WStyleBox.Items.Add(Language.Properties.ViewMin);
  WStyleBox.Items.Add(Language.Properties.ViewHidden);
  CommandEdit.RightButton.Hint := Language.Properties.BeHint;
  RefProps.Hint := Language.Properties.RpHint;
  Label5.Caption := Language.Properties.Options;
  Bevel2.Left := Label5.Left + Label5.Width + 7;
  Bevel2.Width := TabSheet1.Width - Bevel2.Left - 7;
  Label6.Caption := Language.Properties.Icon;
  Bevel3.Left := Label6.Left + Label6.Width + 7;
  Bevel3.Width := TabSheet1.Width - Bevel3.Left - 7;
  ChangeIconButton.Caption := Language.Properties.Change;
  QuesCheckBox.Caption := Language.Properties.ChbQuestion;
  HideCheckBox.Caption := Language.Properties.ChbHide;

  CommandEdit.Text := Link.exec;
  WorkFolderEdit.Text := Link.workdir;
  DescrEdit.Text := Link.descr;
  ic := Link.icon;
  iconindex := Link.iconindex;
  QuesCheckBox.Checked := Link.ques;
  HideCheckBox.Checked := Link.hide;
  WStyleBox.ItemIndex := Link.wst;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(Link.icon),
    Link.iconindex);
  CommandEditChange(nil);
end;

procedure TFilePropertiesForm.RefreshProps;
var
  lnkinfo: TShellLinkInfoStruct;
begin
  if (not FileExists(GetAbsolutePath(CommandEdit.Text))) and (not DirectoryExists(GetAbsolutePath(CommandEdit.Text))) then exit;

  if extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower = '.lnk' then
    begin
      StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, GetAbsolutePath(CommandEdit.Text), MAX_PATH - 1);
      GetLinkInfo(@lnkinfo);
      CommandEdit.Text := lnkinfo.FullPathAndNameOfFileToExecute;
      Ic := lnkinfo.FullPathAndNameOfFileContiningIcon;
      if Ic = '' then Ic := CommandEdit.Text;
      iconindex := lnkinfo.IconIndex;
      WorkFolderEdit.Text := lnkinfo.FullPathAndNameOfWorkingDirectroy;
      DescrEdit.Text := lnkinfo.Description;
    end
  else
    begin
      //ext := extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower;
      //if not IsExecutable(ext) then exit;
      Ic := CommandEdit.Text;
      //ParamsEdit.Text := '';
      DescrEdit.Text := '';
      iconindex := 0;
    end;
  if DescrEdit.Text = '' then
    DescrEdit.Text := ExtractFileName(GetAbsolutePath(CommandEdit.Text));
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(Ic), iconindex);
end;

procedure TFilePropertiesForm.WorkFolderClick(Sender: TObject);
begin
  WorkFolderEdit.Text := ExtractFileDir(FileOrDirSelect(WorkFolderEdit.Text));
end;

procedure TFilePropertiesForm.BrowseExecClick(Sender: TObject);
begin
  CommandEdit.Text := FileOrDirSelect(CommandEdit.Text);
end;

end.
