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

unit ProgrammPropertiesFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ShellApi, IniFiles, FLLanguage,
  ChangeIconFormModule, FLData, FLFunctions;

type
  TProgrammPropertiesForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    ParamsEdit: TEdit;
    DescrEdit: TEdit;
    Label3: TLabel;
    PriorBox: TComboBox;
    Bevel1: TBevel;
    Label5: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label6: TLabel;
    IcImage: TImage;
    ChangeIconButton: TButton;
    QuesCheckBox: TCheckBox;
    Label7: TLabel;
    WStyleBox: TComboBox;
    OKButton: TButton;
    CancelButton: TButton;
    DropBox: TCheckBox;
    DropParamsEdit: TEdit;
    Label8: TLabel;
    HideCheckBox: TCheckBox;
    Label9: TLabel;
    RefProps: TButton;
    CommandEdit: TButtonedEdit;
    AdminBox: TCheckBox;
    WorkFolderEdit: TButtonedEdit;
    procedure FormShow(Sender: TObject);
    procedure BrowseExecClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChangeIconButtonClick(Sender: TObject);
    procedure DropBoxClick(Sender: TObject);
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

procedure TProgrammPropertiesForm.ChangeIconButtonClick(Sender: TObject);
var
  frm: TChangeIconForm;
begin
  Application.CreateForm(TChangeIconForm, frm);
  frm.ShowModal;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(ic), iconindex);
end;

procedure TProgrammPropertiesForm.CommandEditChange(Sender: TObject);
var
  ext: string;
begin
  ext := extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower;
  OKButton.Enabled := FileExists(GetAbsolutePath(CommandEdit.Text)) and IsExecutable(ext);
end;

procedure TProgrammPropertiesForm.OKButtonClick(Sender: TObject);
begin
  if (not fileexists(GetAbsolutePath(CommandEdit.Text))) then
    begin
      fillchar(Link, sizeof(TLink), 0);
      exit;
    end;
  link.active := true;
  link.ltype := 0;
  link.exec := CommandEdit.Text;
  link.workdir := WorkFolderEdit.Text;
  link.params := ParamsEdit.Text;
  link.dropfiles := DropBox.Checked;
  link.dropparams := DropParamsEdit.Text;
  link.descr := DescrEdit.Text;
  link.icon := ic;
  link.iconindex := iconindex;
  link.ques := QuesCheckBox.Checked;
  link.hide := HideCheckBox.Checked;
  link.pr := PriorBox.ItemIndex;
  link.wst := WStyleBox.ItemIndex;
  Link.IsAdmin := AdminBox.Checked;
end;

procedure TProgrammPropertiesForm.RefPropsClick(Sender: TObject);
begin
  RefreshProps;
end;

procedure TProgrammPropertiesForm.DropBoxClick(Sender: TObject);
begin
  Label8.Enabled := DropBox.Checked;
  DropParamsEdit.Enabled := DropBox.Checked;
  if DropBox.Checked then
    begin
      if DropParamsEdit.Text = '' then
        DropParamsEdit.Text := '"%1"';
      DropParamsEdit.SetFocus;
    end;
end;

class function TProgrammPropertiesForm.Execute(ALink: TLink): TLink;
begin
  with TProgrammPropertiesForm.Create(Application.MainForm) do
  try
    Link := ALink;
    ShowModal;
  finally
    Result := Link;
    Free;
  end;
end;

procedure TProgrammPropertiesForm.FormShow(Sender: TObject);
begin
  //--Loading language
  OKButton.Caption := Language.BtnOk;
  CancelButton.Caption := Language.BtnCancel;
  PageControl1.Pages[0].Caption := Language.Properties.Caption;
  Caption := Language.Properties.Caption;
  Label9.Caption := Language.Properties.Folder + ':';
  Label1.Caption := Language.Properties.LblObject + ':';
  Label2.Caption := Language.Properties.Parameters + ':';
  Label8.Caption := Label2.Caption;
  Label4.Caption := Language.Properties.Description + ':';
  Label3.Caption := Language.Properties.Priority + ':';
  PriorBox.Items.Add(Language.Properties.PriorityNormal);
  PriorBox.Items.Add(Language.Properties.PriorityHigh);
  PriorBox.Items.Add(Language.Properties.PriorityIdle);
  PriorBox.Items.Add(Language.Properties.PriorityRealTime);
  PriorBox.Items.Add(Language.Properties.PriorityBelowNormal);
  PriorBox.Items.Add(Language.Properties.PriorityAboveNormal);
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
  DropBox.Caption := Language.Properties.ChbDrop;
  QuesCheckBox.Caption := Language.Properties.ChbQuestion;
  HideCheckBox.Caption := Language.Properties.ChbHide;
  AdminBox.Caption := Language.Properties.ChbAdmin;

  CommandEdit.Text := Link.exec;
  WorkFolderEdit.Text := Link.workdir;
  ParamsEdit.Text := Link.params;
  DropBox.Checked := Link.dropfiles;
  DropBoxClick(nil);
  DropParamsEdit.Text := Link.dropparams;
  DescrEdit.Text := Link.descr;
  ic := Link.icon;
  iconindex := Link.iconindex;
  QuesCheckBox.Checked := Link.ques;
  HideCheckBox.Checked := Link.hide;
  PriorBox.ItemIndex := Link.pr;
  WStyleBox.ItemIndex := Link.wst;
  AdminBox.Checked := Link.IsAdmin;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(Link.icon),
    Link.iconindex);
  CommandEditChange(nil);
end;

procedure TProgrammPropertiesForm.RefreshProps;
var
  lnkinfo: TShellLinkInfoStruct;
  FName: string;
  ext: string;
begin
  if (not fileexists(GetAbsolutePath(CommandEdit.Text))) then exit;

  if extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower = '.lnk' then
    begin
      StrPLCopy(lnkinfo.FullPathAndNameOfLinkFile, GetAbsolutePath(CommandEdit.Text), MAX_PATH - 1);
      GetLinkInfo(@lnkinfo);
      FName := lnkinfo.FullPathAndNameOfFileToExecute;
      ext := extractfileext(FName).ToLower;
      if not IsExecutable(ext) then
        exit;
      CommandEdit.Text := FName;
      Ic := lnkinfo.FullPathAndNameOfFileContiningIcon;
      if Ic = '' then Ic := CommandEdit.Text;
      iconindex := lnkinfo.IconIndex;
      WorkFolderEdit.Text := lnkinfo.FullPathAndNameOfWorkingDirectroy;
      ParamsEdit.Text := lnkinfo.ParamStringsOfFileToExecute;
      DescrEdit.Text := lnkinfo.Description;
    end
  else
    begin
      ext := extractfileext(GetAbsolutePath(CommandEdit.Text)).ToLower;
      if not IsExecutable(ext) then
        Exit;
      Ic := CommandEdit.Text;
      //ParamsEdit.Text := '';
      DescrEdit.Text := '';
      iconindex := 0;
    end;
  if DescrEdit.Text = '' then
    DescrEdit.Text := GetFileDescription(GetAbsolutePath(CommandEdit.Text));
  if DescrEdit.Text = '' then
    DescrEdit.Text := ExtractFileNameNoExt(GetAbsolutePath(CommandEdit.Text));
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, GetAbsolutePath(Ic), iconindex);
end;

procedure TProgrammPropertiesForm.WorkFolderClick(Sender: TObject);
begin
  WorkFolderEdit.Text := ExtractFileDir(FileOrDirSelect(WorkFolderEdit.Text));
end;

procedure TProgrammPropertiesForm.BrowseExecClick(Sender: TObject);
begin
  CommandEdit.Text := ProgramSelect(CommandEdit.Text);
end;

end.
