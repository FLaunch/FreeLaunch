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
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ShellApi, IniFiles, ChangeIconFormModule, PNGExtra, SHlObj;

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
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ChangeIconButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefPropsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CommandEditChange(Sender: TObject);
  private
    function BrowseDialog(Handle: HWnd; Title: string; var OutDir: string): boolean;
  public
    procedure RefreshProps;
  end;

var
  ic: string;
  iconindex: integer;
  ques: boolean;
  CurHelp: boolean = false;
  BrowseExec, RefProps: TPNGButton;
  CurDir: array [0..MAX_PATH] of char;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

function BffCallBackF(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    begin
      if (lpData <> 0) then
        begin
          SendMessage(Wnd, BFFM_SETSELECTION, 1, Longint(@CurDir));
        end;
    end;
  result := 0;
end;

procedure TFilePropertiesForm.ChangeIconButtonClick(Sender: TObject);
var
  frm: TChangeIconForm;
begin
  Application.CreateForm(TChangeIconForm, frm);
  frm.ShowModal;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(ic), iconindex);
end;

procedure TFilePropertiesForm.CommandEditChange(Sender: TObject);
begin
  OKButton.Enabled := FileExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text)) or DirectoryExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
end;

procedure TFilePropertiesForm.OKButtonClick(Sender: TObject);
begin
  if (not FileExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) and (not DirectoryExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) then
    begin
      fillchar(links[GlobTab][GlobRow][GlobCol], sizeof(lnk), 0);
      FlaunchMainForm.LoadIc(GlobTab, GlobRow, GlobCol);
      exit;
    end;
  links[GlobTab][GlobRow][GlobCol].active := true;
  links[GlobTab][GlobRow][GlobCol].exec := CommandEdit.Text;
  links[GlobTab][GlobRow][GlobCol].workdir := WorkFolderEdit.Text;
  links[GlobTab][GlobRow][GlobCol].descr := DescrEdit.Text;
  links[GlobTab][GlobRow][GlobCol].icon := ic;
  links[GlobTab][GlobRow][GlobCol].iconindex := iconindex;
  links[GlobTab][GlobRow][GlobCol].ques := QuesCheckBox.Checked;
  links[GlobTab][GlobRow][GlobCol].hide := HideCheckBox.Checked;
  links[GlobTab][GlobRow][GlobCol].wst := WStyleBox.ItemIndex;
  FlaunchMainForm.LoadIc(GlobTab, GlobRow, GlobCol);
  FlaunchMainForm.SaveLinksCfgFile;
  Close;
end;

procedure TFilePropertiesForm.RefPropsClick(Sender: TObject);
begin
  RefreshProps;
end;

procedure TFilePropertiesForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFilePropertiesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  panels[GlobTab][GlobRow][GlobCol].RemoveFrame;
  action := CAFree;
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
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TFilePropertiesForm.FormShow(Sender: TObject);
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
  Label4.Caption := lng_properties_strings[5] + ':';
  Label7.Caption := lng_properties_strings[10] + ':';
  WStyleBox.Items.Add(lng_properties_strings[11]);
  WStyleBox.Items.Add(lng_properties_strings[12]);
  WStyleBox.Items.Add(lng_properties_strings[13]);
  WStyleBox.Items.Add(lng_properties_strings[14]);
  BrowseExec.Hint := lng_properties_strings[15];
  RefProps.Hint := lng_properties_strings[16];
  Label5.Caption := lng_properties_strings[17];
  Bevel2.Left := Label5.Left + Label5.Width + 7;
  Bevel2.Width := TabSheet1.Width - Bevel2.Left - 7;
  Label6.Caption := lng_properties_strings[18];
  Bevel3.Left := Label6.Left + Label6.Width + 7;
  Bevel3.Width := TabSheet1.Width - Bevel3.Left - 7;
  ChangeIconButton.Caption := lng_properties_strings[19];
  QuesCheckBox.Caption := lng_properties_strings[21];
  HideCheckBox.Caption := lng_properties_strings[22];

  CommandEdit.Text := string(links[GlobTab][GlobRow][GlobCol].exec);
  WorkFolderEdit.Text := string(links[GlobTab][GlobRow][GlobCol].workdir);
  DescrEdit.Text := string(links[GlobTab][GlobRow][GlobCol].descr);
  ic := string(links[GlobTab][GlobRow][GlobCol].icon);
  iconindex := links[GlobTab][GlobRow][GlobCol].iconindex;
  QuesCheckBox.Checked := links[GlobTab][GlobRow][GlobCol].ques;
  HideCheckBox.Checked := links[GlobTab][GlobRow][GlobCol].hide;
  WStyleBox.ItemIndex := links[GlobTab][GlobRow][GlobCol].wst;
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(links[GlobTab][GlobRow][GlobCol].icon), links[GlobTab][GlobRow][GlobCol].iconindex);
  CommandEditChange(nil);
  //CommandEdit.SetFocus;
  //CommandEdit.Text := FullEncrypt('Joker-jar (joker-jar@yandex.ru)');
end;

procedure TFilePropertiesForm.RefreshProps;
var
  lnkinfo: TShellLinkInfoStruct;
  pch: array[0..255] of char;
  //ext: string;
begin
  if (not FileExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) and (not DirectoryExists(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text))) then exit;

  if extractfileext(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text)).ToLower = '.lnk' then
    begin
      strpcopy(lnkinfo.FullPathAndNameOfLinkFile, FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
      FlaunchMainForm.GetLinkInfo(@lnkinfo);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileToExecute,pch,sizeof(pch));
      //ext := extractfileext(pch).ToLower;
      //if not ((ext = '.exe') or (ext = '.bat')) then exit;
      CommandEdit.Text := string(pch);
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfFileContiningIcon,pch,sizeof(pch));
      Ic := string(pch);
      if Ic = '' then Ic := CommandEdit.Text;
      iconindex := lnkinfo.IconIndex;
      ExpandEnvironmentStrings(lnkinfo.FullPathAndNameOfWorkingDirectroy,pch,sizeof(pch));
      WorkFolderEdit.Text := string(pch);
      DescrEdit.Text := string(lnkinfo.Description);
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
    DescrEdit.Text := ExtractFileName(FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
  FlaunchMainForm.LoadIcFromFileNoModif(IcImage, FlaunchMainForm.GetAbsolutePath(Ic), iconindex);
end;

function TFilePropertiesForm.BrowseDialog(Handle: HWnd; Title: string; var OutDir: string): boolean;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0..MAX_PATH] of char;
  TempPath: array [0..MAX_PATH] of char;
begin
  Result := false;
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  with BrowseInfo do
  begin
    hwndOwner := Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    lParam := 16561;
    lpfn := @BffCallBackF;  //BrowseCallbackProc
    ulFlags := BIF_RETURNONLYFSDIRS or BIF_BROWSEINCLUDEFILES;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    OutDir := TempPath;
    Result := true;
    GlobalFreePtr(lpItemID);
  end;
end;

procedure TFilePropertiesForm.BrowseExecClick(Sender: TObject);
var
  OutDir: string;
begin
  StrPCopy(CurDir, FlaunchMainForm.GetAbsolutePath(CommandEdit.Text));
  if BrowseDialog(Handle, 'Select file or directory', OutDir) then
    CommandEdit.Text := OutDir;
  {if fileexists(GetAbsolutePath(CommandEdit.Text)) then
    OpenExec.FileName := GetAbsolutePath(CommandEdit.Text);
  if OpenExec.Execute(Handle) then
    begin
      CommandEdit.Text := OpenExec.FileName;
    end; }
end;

end.
