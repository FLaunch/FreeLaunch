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

unit FilePropertiesFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ShellApi, IniFiles, FLLanguage,
  ChangeIconFormModule, PNGExtra, FLFunctions;

type
  TFilePropertiesForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label4: TLabel;
    CommandEdit: TEdit;
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
    WorkFolderEdit: TEdit;
    Label9: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BrowseExecClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChangeIconButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RefPropsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CommandEditChange(Sender: TObject);
  private
    Link: lnk;
    BrowseExec, RefProps: TPNGButton;
  public
    procedure RefreshProps;
    class function Execute(ALink: lnk): lnk;
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

class function TFilePropertiesForm.Execute(ALink: lnk): lnk;
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
      fillchar(Link, sizeof(lnk), 0);
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

procedure TFilePropertiesForm.FormCreate(Sender: TObject);
begin
  BrowseExec := TPNGButton.Create(TabSheet1);
  with BrowseExec do
    begin
      Parent := TabSheet1;
      Left := CommandEdit.Left + CommandEdit.Width + 4;
      Top := CommandEdit.Top;
      Height := CommandEdit.Height;
      Width := Height;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'OPEN');
      ImageOver.LoadFromResourceName(HInstance, 'OPEN_H');
      OnClick := BrowseExecClick;
    end;
  RefProps := TPNGButton.Create(TabSheet1);
  with RefProps do
    begin
      Parent := TabSheet1;
      Left := BrowseExec.Left + BrowseExec.Width + 4;;
      Top := BrowseExec.Top;
      Height := BrowseExec.Height;
      Width := Height;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'REFRESH');
      ImageOver.LoadFromResourceName(HInstance, 'REFRESH_H');
      OnClick := RefPropsClick;
    end;
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
  Color := FormColor;
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
  BrowseExec.Hint := Language.Properties.BeHint;
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
  pch: array[0..MAX_PATH] of char;
  //ext: string;
begin
  if (not FileExists(GetAbsolutePath(CommandEdit.Text))) and (not DirectoryExists(GetAbsolutePath(CommandEdit.Text))) then exit;

  if extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower = '.lnk' then
    begin
      StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, GetAbsolutePath(CommandEdit.Text), MAX_PATH - 1);
      GetLinkInfo(@lnkinfo);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileToExecute,pch,sizeof(pch));
      //ext := extractfileext(pch).ToLower;
      //if not ((ext = '.exe') or (ext = '.bat')) then exit;
      CommandEdit.Text := pch;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileContiningIcon,pch,sizeof(pch));
      Ic := pch;
      if Ic = '' then Ic := CommandEdit.Text;
      iconindex := lnkinfo.IconIndex;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfWorkingDirectroy,pch,sizeof(pch));
      WorkFolderEdit.Text := pch;
      DescrEdit.Text := lnkinfo.Description;
    end
  else
    begin
      //ext := extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower;
      //if not ((ext = '.exe') or (ext = '.bat')) then exit;
      Ic := CommandEdit.Text;
      //ParamsEdit.Text := '';
      DescrEdit.Text := '';
      iconindex := 0;
    end;
  if DescrEdit.Text = '' then
    DescrEdit.Text := ExtractFileName(GetAbsolutePath(CommandEdit.Text));
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(Ic), iconindex);
end;

procedure TFilePropertiesForm.BrowseExecClick(Sender: TObject);
begin
  CommandEdit.Text := FileOrDirSelect(CommandEdit.Text);
end;

end.