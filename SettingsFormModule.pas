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

unit SettingsFormModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, IniFiles, Vcl.Samples.Spin;

const
  base64ABC='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  DesignDPI = 96;

type
  TBase64 = record
    ByteArr: array[0..2] of Byte;
    ByteCount: Byte;
  end;

  TSettingsForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    OKButton: TButton;
    CancelButton: TButton;
    Label2: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    AutorunCheckBox: TCheckBox;
    TopCheckBox: TCheckBox;
    Bevel1: TBevel;
    Label6: TLabel;
    Bevel3: TBevel;
    TBarBox: TComboBox;
    Label4: TLabel;
    Bevel2: TBevel;
    TabsBox: TComboBox;
    Label5: TLabel;
    ReloadIconsButton: TButton;
    Label9: TLabel;
    Bevel4: TBevel;
    Label7: TLabel;
    Label8: TLabel;
    StartHideBox: TCheckBox;
    Label10: TLabel;
    Bevel5: TBevel;
    LanguagesBox: TComboBox;
    StatusBarBox: TCheckBox;
    PaddingEdit: TSpinEdit;
    ColsEdit: TSpinEdit;
    RowsEdit: TSpinEdit;
    TabsEdit: TSpinEdit;
    IWEdit: TSpinEdit;
    IHEdit: TSpinEdit;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ReloadIconsButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LanguagesBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    function DecodeBase64(StringValue: string): TBase64;
  public
    procedure ProcLanguage(FileName: string);
    procedure ScanLanguagesDir;
  end;

var
  Flags: array of TBitMap;
  Langs: array of string;
  NoPopup: TPopupMenu;

implementation

uses
  FLaunchMainFormModule;

{$R *.dfm}

function TSettingsForm.DecodeBase64(StringValue: string): TBase64;
var
  M,N: Integer;
  Dest,Sour: Byte;
  NextNum: Byte;
  CurPos: Byte;
begin
  CurPos := 0;
  Dest := 0;
  NextNum := 1;
  FillChar(Result, SizeOf(Result), 0);
  for N := 1 to 4 do
    begin
      for M := 0 to 5 do
        begin
          if StringValue[N] = '=' then Sour := 0
          else
            Sour := Pos(StringValue[N],base64ABC) - 1;
          Sour := (Sour shl M) and 255;
          Dest := (Dest shl 1) and 255;
          if (Sour and 32)=32 then Dest := Dest or 1;
          Inc(NextNum);
          if NextNum > 8 then
            begin
              NextNum := 1;
              Result.ByteArr[CurPos] := Dest;
              if StringValue[N] = '=' then
                Result.ByteArr[CurPos] := 0
              else
                Result.ByteCount := CurPos + 1;
              Inc(CurPos);
              Dest:=0;
            end;
        end;
    end;
end;

procedure TSettingsForm.ProcLanguage(FileName: string);
const
  sect = 'information';
var
  lngfile: TIniFile;
  Stream: TMemoryStream;
  Base64: TBase64;
  Str, B64Str: string;
begin
  lngfile := TIniFile.Create(FileName);
  Str := lngfile.ReadString(sect, 'image', '');

  Stream := TMemoryStream.Create;
  while Length(Str) > 0 do
    begin
      B64Str := Copy(Str,1,4);
      Delete(Str,1,4);
      Base64 := DecodeBase64(B64Str);
      Stream.WriteBuffer(Base64.ByteArr, Base64.ByteCount);
    end;
  SetLength(Langs, Length(Langs) + 1);
  Langs[High(Langs)] := ExtractFileName(FileName);
  SetLength(Flags, Length(Flags) + 1);
  Flags[High(Flags)] := TBitMap.Create;
  Stream.Seek(0,0);
  Flags[High(Flags)].LoadFromStream(Stream);
  Stream.Free;
  LanguagesBox.Items.Add(lngfile.ReadString(sect,'name',''));
  if lngfilename = ExtractFileName(FileName) then
    LanguagesBox.ItemIndex := LanguagesBox.Items.Count - 1;
  lngfile.Free;
end;

procedure TSettingsForm.ScanLanguagesDir;
var
  SearchRec: TSearchRec;
  Dir: string;
begin
  LanguagesBox.Clear;
  SetLength(Flags, 0);
  Dir := ExtractFilePath(ParamStr(0)) + 'Languages\';
  if FindFirst(Dir+'*.*', faAnyFile, SearchRec) = 0 then
    repeat
      if (SearchRec.name='.') or (SearchRec.name='..') then continue;
      if (extractfileext(SearchRec.name).ToLower = '.lng') then
        begin
          ProcLanguage(Dir + SearchRec.name);
        end;
    until
      FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
end;

procedure TSettingsForm.ReloadIconsButtonClick(Sender: TObject);
begin
  Close;
  FlaunchMainForm.LoadLinks;
  FlaunchMainForm.SaveLinksToCash;
end;

procedure TSettingsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.LanguagesBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Multiplier: Double;
  FlagRect: TRect;
begin
  Multiplier := (Rect.Height - 4) / Flags[Index].Height;
  FlagRect.Left := Rect.Left + 2;
  FlagRect.Top := Rect.Top + 2;
  FlagRect.Height := Rect.Height - 4;
  FlagRect.Width := Round(Flags[Index].Width * Multiplier);

  LanguagesBox.Canvas.fillrect(rect);
  LanguagesBox.Canvas.StretchDraw(FlagRect, Flags[Index]);
  LanguagesBox.Canvas.textout(rect.left + FlagRect.Width + 4, rect.top + 2,
    LanguagesBox.items[index]);
end;

procedure TSettingsForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  NoPopup.Free;
  for i := 0 to high(Flags) do
    Flags[i].Free;
  SetLength(Flags, 0);
  settingsshowing := false;
  action := CAFree;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  NoPopup := TPopupMenu.Create(nil);
  TabsEdit.PopupMenu := NoPopup;
  RowsEdit.PopupMenu := NoPopup;
  ColsEdit.PopupMenu := NoPopup;
  PaddingEdit.PopupMenu := NoPopup;
  IWEdit.PopupMenu := NoPopup;
  IHEdit.PopupMenu := NoPopup;

  LanguagesBox.ItemHeight := MulDiv(LanguagesBox.ItemHeight,
    Screen.PixelsPerInch, DesignDPI);
end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    OKButtonClick(OKButton);
  if key = vk_escape then
    CancelButtonClick(CancelButton);
end;

procedure TSettingsForm.FormShow(Sender: TObject);
var
  w: integer;
begin
  Color := FormColor;
  settingsshowing := true;
  //--Loading language
  OKButton.Caption := lngstrings[15];
  CancelButton.Caption := lngstrings[16];
  PageControl1.Pages[0].Caption := lng_settings_strings[1];
  Caption := lng_settings_strings[2];
  Label2.Caption := lng_settings_strings[3] + ':';
  Label1.Caption := lng_settings_strings[4] + ':';
  Label3.Caption := lng_settings_strings[5] + ':';
  Label5.Caption := lng_settings_strings[6] + ':';
  AutorunCheckBox.Caption := lng_settings_strings[7];
  TopCheckBox.Caption := lng_settings_strings[8];
  StartHideBox.Caption := lng_settings_strings[9];
  StatusBarBox.Caption := lng_settings_strings[10];
  Label6.Caption := lng_settings_strings[11];
  TBarBox.Items.Add(lng_settings_strings[12]);
  TBarBox.Items.Add(lng_settings_strings[13]);
  TBarBox.Items.Add(lng_settings_strings[14]);
  Bevel3.Left := Label6.Left + Label6.Width + 7;
  w := 337 - Bevel3.Left;
  if w < 0 then w := 0;
  Bevel3.Width := w;
  Label4.Caption := lng_settings_strings[15];
  TabsBox.Items.Add(lng_settings_strings[16]);
  TabsBox.Items.Add(lng_settings_strings[17]);
  TabsBox.Items.Add(lng_settings_strings[18]);
  Bevel2.Left := Label4.Left + Label4.Width + 7;
  w := 337 - Bevel2.Left;
  if w < 0 then w := 0;
  Bevel2.Width := w;
  Label10.Caption := lng_settings_strings[19];
  Bevel5.Left := Label10.Left + Label10.Width + 7;
  w := 337 - Bevel5.Left;
  if w < 0 then w := 0;
  Bevel5.Width := w;
  Label9.Caption := lng_settings_strings[20];
  Bevel4.Left := Label9.Left + Label9.Width + 7;
  w := 337 - Bevel4.Left;
  if w < 0 then w := 0;
  Bevel4.Width := w;
  Label7.Caption := lng_settings_strings[21] + ':';
  ReloadIconsButton.Caption := lng_settings_strings[22];

  ScanLanguagesDir;
  TabsEdit.Text := inttostr(tabscount);
  RowsEdit.Text := inttostr(rowscount);
  ColsEdit.Text := inttostr(colscount);
  PaddingEdit.Text := inttostr(lpadding);
  IWEdit.Text := inttostr(iconwidth - 4);
  IHEdit.Text := inttostr(iconheight - 4);
  AutorunCheckBox.Checked := (SettingsMode <> 2) and (Autorun);
  TopCheckBox.Checked := AlwaysOnTop;
  StartHideBox.Checked := StartHide;
  StatusBarBox.Checked := StatusBarVis;
  TBarBox.ItemIndex := titlebar;
  TabsBox.ItemIndex := tabsview;
  TabsEdit.MaxValue := maxt;
  TabsEdit.Value := tabscount;
  TabsEdit.MinValue := mint;
  RowsEdit.MaxValue := maxr;
  RowsEdit.Value := rowscount;
  RowsEdit.MinValue := minr;
  ColsEdit.MaxValue := maxc;
  ColsEdit.Value := colscount;
  ColsEdit.MinValue := minc;
  PaddingEdit.MaxValue := maxp;
  PaddingEdit.Value := lpadding;
  PaddingEdit.MinValue := minp;
  IWEdit.Value := iconwidth - 4;
  IHEdit.Value := iconheight - 4;
  AutoRunCheckBox.Enabled := SettingsMode <> 2;
  TabsEdit.SetFocus;
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
var
  i,tabnum: integer;
begin
  ChPos := true;
  ShowWindow(FlaunchMainForm.Handle, SW_HIDE);
  Autorun := AutorunCheckBox.Checked;
  AlwaysOnTop := TopCheckBox.Checked;
  StartHide := StartHideBox.Checked;
  StatusBarVis := StatusBarBox.Checked;
  FlaunchMainForm.SetAutorun(Autorun);
  lngfilename := Langs[LanguagesBox.ItemIndex];
  tabsview := TabsBox.ItemIndex;
  titlebar := TBarBox.ItemIndex;
  //FlaunchMainForm.MainTabs.SetFocus;
  tabnum := FlaunchMainForm.MainTabs.ActivePageIndex;
  for i := 0 to tabscount - 1 do
    begin
      if i > 0 then
        FlaunchMainForm.MainTabs.Pages[i].TabVisible := false;
      FlaunchMainForm.DestroyPanel(i);
    end;
  for i := 0 to maxt - 1 do
     if FlaunchMainForm.DefNameOfTab(FlaunchMainForm.MainTabs.Pages[i].Caption) then
       FlaunchMainForm.MainTabs.Pages[i].Caption := '';
  tabscount := strtoint(TabsEdit.Text);
  rowscount := strtoint(RowsEdit.Text);
  colscount := strtoint(ColsEdit.Text);
  lpadding := strtoint(PaddingEdit.Text);
  iconwidth := strtoint(IWEdit.Text) + 4;
  iconheight := strtoint(IHEdit.Text) + 4;
  FlaunchMainForm.GenerateWnd;
  FlaunchMainForm.LoadLinks;
  if tabnum < tabscount then
    FlaunchMainForm.MainTabs.TabIndex := tabnum
  else
    FlaunchMainForm.MainTabs.TabIndex := 0;
  FlaunchMainForm.SaveIni;
  FlaunchMainForm.LoadLanguage(lngfilename);
  FlaunchMainForm.ChWinView(true);
  ChPos := false;
  Close;
end;

end.
