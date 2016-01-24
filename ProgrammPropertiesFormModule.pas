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

unit ProgrammPropertiesFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ShellApi, IniFiles, ChangeIconFormModule, PNGExtra;

type
  TProgrammPropertiesForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    CommandEdit: TEdit;
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
    OpenExec: TOpenDialog;
    DropBox: TCheckBox;
    DropParamsEdit: TEdit;
    Label8: TLabel;
    HideCheckBox: TCheckBox;
    WorkFolderEdit: TEdit;
    Label9: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BrowseExecClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChangeIconButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DropBoxClick(Sender: TObject);
    procedure LoadLanguage(filename: string);
    procedure RefPropsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CommandEditChange(Sender: TObject);
  private

  public
    procedure RefreshProps;
  end;

var
  ic: string;
  iconindex: integer;
  ques: boolean;
  CurHelp: boolean = false;
  BrowseExec, RefProps: TPNGButton;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

procedure TProgrammPropertiesForm.LoadLanguage(filename: string);
const
  mainsect = 'properties';
var
  lfile: TIniFile;
  w: integer;
begin
  lfile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + filename);
  OKButton.Caption := lngstrings[15];
  CancelButton.Caption := lngstrings[16];
  PageControl1.Pages[0].Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'properties',''));
  Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'properties',''));
  Label9.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'folder','')) + ':';
  Label1.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'object','')) + ':';
  Label2.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'parameters','')) + ':';
  Label8.Caption := Label2.Caption;
  Label4.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'description','')) + ':';
  Label3.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'priority','')) + ':';
  PriorBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'priority_normal','')));
  PriorBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'priority_high','')));
  PriorBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'priority_low','')));
  Label7.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'view','')) + ':';
  WStyleBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'view_normal','')));
  WStyleBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'view_max','')));
  WStyleBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'view_min','')));
  WStyleBox.Items.Add(FlaunchMainForm.parse(lfile.ReadString(mainsect,'view_hidden','')));
  BrowseExec.Hint := FlaunchMainForm.parse(lfile.ReadString(mainsect,'be_hint',''));
  RefProps.Hint := FlaunchMainForm.parse(lfile.ReadString(mainsect,'rp_hint',''));
  Label5.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'options',''));
  Bevel2.Left := Label5.Left + Label5.Width + 7;
  w := 505 - Bevel2.Left;
  if w < 0 then w := 0;
  Bevel2.Width := w;
  Label6.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'icon',''));
  Bevel3.Left := Label6.Left + Label6.Width + 7;
  w := 505 - Bevel3.Left;
  if w < 0 then w := 0;
  Bevel3.Width := w;
  ChangeIconButton.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'change',''));
  DropBox.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'chb_drop',''));
  QuesCheckBox.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'chb_question',''));
  HideCheckBox.Caption := FlaunchMainForm.parse(lfile.ReadString(mainsect,'chb_hide',''));
  OpenExec.Filter := FlaunchMainForm.parse(lfile.ReadString(mainsect,'tprogramfilter','')) + '|*.exe;*.bat';
  lfile.Free;
end;

procedure TProgrammPropertiesForm.ChangeIconButtonClick(Sender: TObject);
var
  frm: TChangeIconForm;
begin
  Application.CreateForm(TChangeIconForm, frm);
  frm.ShowModal;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(ic), iconindex);
end;

procedure TProgrammPropertiesForm.CommandEditChange(Sender: TObject);
var
  ext: string;
begin
  ext := strlower(PAnsiChar(extractfileext(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))));
  OKButton.Enabled := FileExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text)) and ((ext = '.exe') or (ext = '.bat'));
end;

procedure TProgrammPropertiesForm.OKButtonClick(Sender: TObject);
begin
  if (not fileexists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) then
    begin
      fillchar(links[GlobTab][GlobRow][GlobCol], sizeof(lnk), 0);
      FlaunchMainForm.LoadIc(GlobTab, GlobRow, GlobCol);
      exit;
    end;
  links[GlobTab][GlobRow][GlobCol].active := true;
  links[GlobTab][GlobRow][GlobCol].exec := CommandEdit.Text;
  links[GlobTab][GlobRow][GlobCol].workdir := WorkFolderEdit.Text;
  links[GlobTab][GlobRow][GlobCol].params := ParamsEdit.Text;
  links[GlobTab][GlobRow][GlobCol].dropfiles := DropBox.Checked;
  links[GlobTab][GlobRow][GlobCol].dropparams := DropParamsEdit.Text;
  links[GlobTab][GlobRow][GlobCol].descr := DescrEdit.Text;
  links[GlobTab][GlobRow][GlobCol].icon := ic;
  links[GlobTab][GlobRow][GlobCol].iconindex := iconindex;
  links[GlobTab][GlobRow][GlobCol].ques := QuesCheckBox.Checked;
  links[GlobTab][GlobRow][GlobCol].hide := HideCheckBox.Checked;
  links[GlobTab][GlobRow][GlobCol].pr := PriorBox.ItemIndex;
  links[GlobTab][GlobRow][GlobCol].wst := WStyleBox.ItemIndex;
  FlaunchMainForm.LoadIc(GlobTab, GlobRow, GlobCol);
  FlaunchMainForm.SaveLinksCfgFile;
  Close;
end;

procedure TProgrammPropertiesForm.RefPropsClick(Sender: TObject);
begin
  RefreshProps;
end;

procedure TProgrammPropertiesForm.CancelButtonClick(Sender: TObject);
begin
  Close;
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

procedure TProgrammPropertiesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  panels[GlobTab][GlobRow][GlobCol].RemoveFrame;
  action := CAFree;
end;

procedure TProgrammPropertiesForm.FormCreate(Sender: TObject);
begin
  BrowseExec := TPNGButton.Create(TabSheet1);
  with BrowseExec do
    begin
      Parent := TabSheet1;
      Left := 295;
      Top := 15;
      Width := 21;
      Height := 21;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'OPEN');
      ImageOver.LoadFromResourceName(HInstance, 'OPEN_H');
      OnClick := BrowseExecClick;
    end;
  RefProps := TPNGButton.Create(TabSheet1);
  with RefProps do
    begin
      Parent := TabSheet1;
      Left := 316;
      Top := 15;
      Width := 21;
      Height := 21;
      ButtonStyle := pbsFlat;
      ImageNormal.LoadFromResourceName(HInstance, 'REFRESH');
      ImageOver.LoadFromResourceName(HInstance, 'REFRESH_H');
      OnClick := RefPropsClick;
    end;
end;

procedure TProgrammPropertiesForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TProgrammPropertiesForm.FormShow(Sender: TObject);
var
  w: integer;
begin
  Color := FormColor;
  panels[GlobTab][GlobRow][GlobCol].SetBlueFrame;
  //--Loading language
  OKButton.Caption := lngstrings[15];
  CancelButton.Caption := lngstrings[16];
  PageControl1.Pages[0].Caption := lng_properties_strings[1];
  Caption := lng_properties_strings[1];
  Label9.Caption := lng_properties_strings[2] + ':';
  Label1.Caption := lng_properties_strings[3] + ':';

  Label2.Caption := lng_properties_strings[4] + ':';
  Label8.Caption := Label2.Caption;
  Label4.Caption := lng_properties_strings[5] + ':';
  Label3.Caption := lng_properties_strings[6] + ':';
  PriorBox.Items.Add(lng_properties_strings[7]);
  PriorBox.Items.Add(lng_properties_strings[8]);
  PriorBox.Items.Add(lng_properties_strings[9]);
  Label7.Caption := lng_properties_strings[10] + ':';
  WStyleBox.Items.Add(lng_properties_strings[11]);
  WStyleBox.Items.Add(lng_properties_strings[12]);
  WStyleBox.Items.Add(lng_properties_strings[13]);
  WStyleBox.Items.Add(lng_properties_strings[14]);
  BrowseExec.Hint := lng_properties_strings[15];
  RefProps.Hint := lng_properties_strings[16];
  Label5.Caption := lng_properties_strings[17];
  Bevel2.Left := Label5.Left + Label5.Width + 7;
  w := 505 - Bevel2.Left;
  if w < 0 then w := 0;
  Bevel2.Width := w;
  Label6.Caption := lng_properties_strings[18];
  Bevel3.Left := Label6.Left + Label6.Width + 7;
  w := 505 - Bevel3.Left;
  if w < 0 then w := 0;
  Bevel3.Width := w;
  ChangeIconButton.Caption := lng_properties_strings[19];
  DropBox.Caption := lng_properties_strings[20];
  QuesCheckBox.Caption := lng_properties_strings[21];
  HideCheckBox.Caption := lng_properties_strings[22];
  OpenExec.Filter := lng_properties_strings[23] + '|*.exe;*.bat';

  CommandEdit.Text := string(links[GlobTab][GlobRow][GlobCol].exec);
  WorkFolderEdit.Text := string(links[GlobTab][GlobRow][GlobCol].workdir);
  ParamsEdit.Text := string(links[GlobTab][GlobRow][GlobCol].params);
  DropBox.Checked := links[GlobTab][GlobRow][GlobCol].dropfiles;
  DropBoxClick(nil);
  DropParamsEdit.Text := string(links[GlobTab][GlobRow][GlobCol].dropparams);
  DescrEdit.Text := string(links[GlobTab][GlobRow][GlobCol].descr);
  ic := string(links[GlobTab][GlobRow][GlobCol].icon);
  iconindex := links[GlobTab][GlobRow][GlobCol].iconindex;
  QuesCheckBox.Checked := links[GlobTab][GlobRow][GlobCol].ques;
  HideCheckBox.Checked := links[GlobTab][GlobRow][GlobCol].hide;
  PriorBox.ItemIndex := links[GlobTab][GlobRow][GlobCol].pr;
  WStyleBox.ItemIndex := links[GlobTab][GlobRow][GlobCol].wst;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(links[GlobTab][GlobRow][GlobCol].icon), links[GlobTab][GlobRow][GlobCol].iconindex);
  CommandEditChange(nil);
  //CommandEdit.SetFocus;
  //CommandEdit.Text := FullEncrypt('Joker-jar (joker-jar@yandex.ru)');
end;

procedure TProgrammPropertiesForm.RefreshProps;
var
  lnkinfo: TShellLinkInfoStruct;
  pch: array[0..255] of char;
  ext: string;
begin
  if (not fileexists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) then exit;

  if strlower(PAnsiChar(extractfileext(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text)))) = '.lnk' then
    begin
      strpcopy(lnkinfo.FullPathAndNameOfLinkFile, FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
      FlaunchMainForm.GetLinkInfo(@lnkinfo);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileToExecute,pch,sizeof(pch));
      ext := strlower(PAnsiChar(extractfileext(pch)));
      if not ((ext = '.exe') or (ext = '.bat')) then exit;
      CommandEdit.Text := string(pch);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileContiningIcon,pch,sizeof(pch));
      Ic := string(pch);
      if Ic = '' then Ic := CommandEdit.Text;
      iconindex := lnkinfo.IconIndex;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfWorkingDirectroy,pch,sizeof(pch));
      WorkFolderEdit.Text := string(pch);
      ParamsEdit.Text := string(lnkinfo.ParamStringsOfFileToExecute);
      DescrEdit.Text := string(lnkinfo.Description);
    end
  else
    begin
      ext := strlower(PAnsiChar(extractfileext(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))));
      if not ((ext = '.exe') or (ext = '.bat')) then exit;
      Ic := CommandEdit.Text;
      //ParamsEdit.Text := '';
      DescrEdit.Text := '';
      iconindex := 0;
    end;
  if DescrEdit.Text = '' then
    DescrEdit.Text := FlaunchMainForm.GetFileDescription(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
  if DescrEdit.Text = '' then
    DescrEdit.Text := FlaunchMainForm.ExtractFileNameNoExt(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(Ic), iconindex);
end;

procedure TProgrammPropertiesForm.BrowseExecClick(Sender: TObject);
begin
  if fileexists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text)) then
    OpenExec.FileName := FlaunchMainForm.GetAbsolutePath(CommandEdit.Text);
  if OpenExec.Execute(Handle) then
    begin
      CommandEdit.Text := OpenExec.FileName;
    end;
end;

end.
