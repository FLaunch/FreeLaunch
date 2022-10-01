{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
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

unit FLDialogs;

interface

function ProgramSelect(AFileName: string): string;
function FileOrDirSelect(AFileName: string): string;

implementation

uses
  System.SysUtils, VCL.Dialogs, Vcl.Forms, Winapi.Windows, Winapi.Messages,
  Winapi.ShlObj, Winapi.ActiveX, System.Win.ComObj, FLLanguage, FLFunctions;

type
  TFileOrDirDialog = class
    FOpenDialog: TFileOpenDialog;
    FFileName: string;
    procedure OpenDialogFolderChange(Sender: TObject);
    function BrowseDialog(Handle: HWnd; Title: string; var OutDir: string): boolean;
  public
    property FileName: string read FFileName;
    function Execute: Boolean;
    constructor Create(AFileName: string);
    destructor Destroy; override;
  end;

function ProgramSelect(AFileName: string): string;
var
  Dialog: TOpenDialog;
  CurrentFile: string;
begin
  Dialog := TOpenDialog.Create(Nil);
  try
    Dialog.Filter := Language.Properties.ProgramFilter + '|*.exe;*.bat';
    Dialog.Options := Dialog.Options + [ofFileMustExist, ofNoDereferenceLinks];

    CurrentFile := GetAbsolutePath(AFileName);
    if FileExists(CurrentFile) then
    begin
      Dialog.FileName := CurrentFile;
      Dialog.InitialDir := ExtractFilePath(CurrentFile);
    end;

    if Dialog.Execute then
    begin
      Result := Dialog.FileName;

      if IsPortable then
        Result := PathToPortable(Dialog.FileName);
    end
    else
      Result := AFileName;
  finally
    Dialog.Free;
  end;
end;

function BffCallBackF(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    begin
      if (lpData <> 0) then
        begin
          SendMessage(Wnd, BFFM_SETSELECTION, 1, lpData);
        end;
    end;
  result := 0;
end;

function TFileOrDirDialog.BrowseDialog(Handle: HWnd; Title: string;
  var OutDir: string): boolean;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName, CurDir: array [0..MAX_PATH] of char;
begin
  Result := false;
  FillChar(DisplayName, sizeof(DisplayName), #0);
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  StrPCopy(CurDir, OutDir);
  with BrowseInfo do
  begin
    hwndOwner := Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    lParam := Winapi.Windows.LPARAM(@CurDir);
    lpfn := @BffCallBackF;  //BrowseCallbackProc
    ulFlags := BIF_SHAREABLE or BIF_BROWSEINCLUDEFILES or BIF_USENEWUI or
      BIF_RETURNONLYFSDIRS;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, CurDir);
    OutDir := CurDir;
    Result := true;
    GlobalFreePtr(lpItemID);
  end;
end;

constructor TFileOrDirDialog.Create(AFileName: string);
begin
  FFileName := AFileName;
  FOpenDialog := TFileOpenDialog.Create(Nil);
  FOpenDialog.Options := [fdoNoValidate, fdoPathMustExist];
end;

destructor TFileOrDirDialog.Destroy;
begin
  FOpenDialog.Free;
  inherited;
end;

function TFileOrDirDialog.Execute: Boolean;
var
  FilePath: string;
begin
  if TOSVersion.Check(6) then
  begin
    FilePath := ExtractFilePath(FFileName);
    if DirectoryExists(FilePath) then
      FOpenDialog.DefaultFolder := FilePath;
    FOpenDialog.FileName := 'Select file or directory';

    Result := FOpenDialog.Execute;
    if Result then
    begin
      if FileExists(FOpenDialog.FileName) then
        FFileName := FOpenDialog.FileName
      else
        FFileName := ExtractFilePath(FOpenDialog.FileName);
    end;
  end
  else
    Result := BrowseDialog(Application.ActiveFormHandle,
      'Select file or directory', FFileName);
end;

procedure TFileOrDirDialog.OpenDialogFolderChange(Sender: TObject);
var
  DialogWnd: IOleWindow;
  DialogHandle, ComboHandle: HWND;
begin
  DialogWnd := FOpenDialog.Dialog as IOleWindow;
  OleCheck(DialogWnd.GetWindow(DialogHandle));
  ComboHandle := FindWindowEx(DialogHandle, 0, 'ComboBoxEx32', nil);
  if ComboHandle <> 0 then
    SendMessage(ComboHandle, WM_SETTEXT, 0, LPARAM(PChar('Select file or directory')));
end;

function FileOrDirSelect(AFileName: string): string;
var
  FileOrDirDialog: TFileOrDirDialog;
begin
  FileOrDirDialog := TFileOrDirDialog.Create(GetAbsolutePath(AFileName));
  try
    if FileOrDirDialog.Execute then
    begin
      Result := FileOrDirDialog.FileName;

      if IsPortable then
        Result := PathToPortable(FileOrDirDialog.FileName);
    end
    else
      Result := AFileName;
  finally
    FileOrDirDialog.Free;
  end;
end;

end.
