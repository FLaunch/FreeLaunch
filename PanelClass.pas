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

unit PanelClass;

interface

uses
  Windows, SysUtils, Classes, Controls, ExtCtrls, ShellApi, Messages, Graphics,
  Types;

const
  FocusColor = clred;
  PropColor = clblue;

type

  tDragFileEvent = procedure(Sender: TObject; FileName: string) of object;
  tSetFocusEvent = procedure(Sender: TObject) of object;
  tKillFocusEvent = procedure(Sender: TObject) of object;

  TMyPanel = class(TCustomControl)
  private
    fCanClick: boolean;
    fPanelColor: TColor;
    fPushed: boolean;
    fFrameColor: TColor;
    fLColor, fDColor1, fDColor2: TColor;
    fTabNum: integer;
    fColNum: integer;
    fRowNum: integer;
    fDragFile: tDragFileEvent;
    fSetFocus: tSetFocusEvent;
    fKillFocus: tKillFocusEvent;
    fHasIcon: boolean;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure DrawFrame(Color: TColor);
    function GetColorBetween(StartColor, EndColor: TColor; Pointvalue, Von, Bis: Extended): TColor;
  protected

  public
    Icon: TBitMap;
    PushedIcon: TBitMap;
    constructor Create(AOwner: TComponent; P: TWinControl; W, H: integer; Col: TColor);
    destructor Destroy; override;
    property HasIcon: boolean read fHasIcon write fHasIcon;
    property TabNum: integer read fTabNum write fTabNum;
    property ColNum: integer read fColNum write fColNum;
    property RowNum: integer read fRowNum write fRowNum;
    property FrameColor: TColor read fFrameColor write fFrameColor;
    property OnDragFile: tDragFileEvent read fDragFile write fDragFile;
    property OnSetFocus: tSetFocusEvent read fSetFocus write fSetFocus;
    property OnKillFocus: tKillFocusEvent read fKillFocus write fKillFocus;
    property OnMouseMove;
    property OnMouseLeave;
    property OnMouseDown;
    property OnClick;
    property OnDragOver;
    property OnDragDrop;
    property PopupMenu;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);  override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);  override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Click; override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure SetBlueFrame;
    procedure RemoveFrame;
  published

  end;

implementation

function TMyPanel.GetColorBetween(StartColor, EndColor: TColor; Pointvalue, Von, Bis: Extended): TColor;
var
  F: Extended; 
  r1, r2, r3, g1, g2, g3, b1, b2, b3: Byte; 

  function CalcColorBytes(fb1, fb2: Byte): Byte;
    begin
      result := fb1;
      if fb1 < fb2 then
        Result := FB1 + Trunc(F * (fb2 - fb1));
      if fb1 > fb2 then
        Result := FB1 - Trunc(F * (fb1 - fb2));
    end;

begin 
  if Pointvalue <= Von then
    begin
      result := StartColor;
      exit;
    end;
  if Pointvalue >= Bis then 
    begin
      result := EndColor;
      exit;
    end;
  F := (Pointvalue - von) / (Bis - Von); 
  asm
    mov EAX, Startcolor
    cmp EAX, EndColor
    je @@exit
    mov r1, AL
    shr EAX,8
    mov g1, AL
    shr Eax,8
    mov b1, AL
    mov Eax, Endcolor
    mov r2, AL
    shr EAX,8
    mov g2, AL
    shr EAX,8
    mov b2, AL
    push ebp
    mov al, r1
    mov dl, r2
    call CalcColorBytes
    pop ecx
    push ebp
    Mov r3, al
    mov dL, g2
    mov al, g1
    call CalcColorBytes
    pop ecx
    push ebp
    mov g3, Al
    mov dL, B2
    mov Al, B1
    call CalcColorBytes
    pop ecx
    mov b3, al
    XOR EAX,EAX
    mov AL, B3
    SHL EAX,8
    mov AL, G3
    SHL EAX,8
    mov AL, R3
    @@Exit:
    mov @result, eax
  end;
end;

constructor TMyPanel.Create(AOwner: TComponent; P: TWinControl; W, H: integer; Col: Tcolor);
var
  TempColor: TColor;
begin
  inherited Create(AOwner);
  fCanClick := true;
  FrameColor := col;
  Parent := P;
  Width := W;
  Height := H;
  TabStop := true;

  //BevelKind := bknone;
  ParentBackground := false;
  Color := Col;
  fPanelColor := Col;
  if fPanelColor = clBtnFace then
    TempColor := GetSysColor(COLOR_BTNFACE)
  else
    TempColor := fPanelColor;
  fLColor := GetColorBetween(TempColor, clwhite, 85, 0, 100);
  fDColor1 := GetColorBetween(TempColor, clblack, 35, 0, 100);
  fDColor2 := GetColorBetween(TempColor, clblack, 55, 0, 100);
  Icon := TBitMap.Create;
  Icon.Width := self.Width - 4;
  Icon.Height := self.Height - 4;
  PushedIcon := TBitMap.Create;
  PushedIcon.Width := self.Width - 7;
  PushedIcon.Height := self.Height - 7;
  DragAcceptFiles(Handle, True);
  if TOSVersion.Check(6) then
  begin
    ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ADD);
    ChangeWindowMessageFilter (WM_COPYDATA, MSGFLT_ADD);
    ChangeWindowMessageFilter ($0049, MSGFLT_ADD);
  end;
end;

destructor TMyPanel.Destroy;
begin
  //DragAcceptFiles(Handle, False);
  Icon.Free;
  PushedIcon.Free;
  inherited Destroy;
end;

procedure TMyPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbleft then
    if ssCtrl in Shift then
      begin
        fCanClick := false;
        BeginDrag(false);
      end
    else
      begin
        fPushed := true;
        Repaint;
      end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TMyPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbleft then
    begin
      fPushed := false;
      Repaint;
    end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TMyPanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if key = vk_return then
    MouseDown(mbleft,[],0,0);
  inherited KeyDown(Key, Shift);
end;

procedure TMyPanel.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if key = vk_return then
    begin
      MouseUp(mbleft,[],0,0);
      Click;
    end;
  inherited KeyUp(Key, Shift);
end;

procedure TMyPanel.Click;
begin
  if fCanClick then
    inherited Click;
end;

procedure TMyPanel.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  fCanClick := true;
end;

procedure TMyPanel.WMDropFiles(var Msg: TWMDropFiles);
var
  buf: array[0..255] of char;
begin
  if (Msg.Msg = WM_DROPFILES) and assigned(fDragFile) then
    begin
      DragQueryFile(Msg.Drop, 0, buf, sizeof(buf));
      fDragFile(Self, buf);
      DragFinish(Msg.Drop);
    end;
end;

procedure TMyPanel.DrawFrame(Color: TColor);
var
  i,j: integer;
begin
  if (fPushed) or (Color = fPanelColor) then exit;
  for i := 0 to self.Width - 1 do
    for j := 0 to self.Height - 1 do
      begin
        if (i = self.Width - 1) or (j = self.Width - 1) then
          self.Canvas.Pixels[i,j] := GetColorBetween(self.Canvas.Pixels[i,j], Color, 10, 0, 100)
        else
          self.Canvas.Pixels[i,j] := GetColorBetween(self.Canvas.Pixels[i,j], Color, 30, 0, 100);
      end;
  {self.Canvas.Pen.Color := Color;
  self.Canvas.Pen.Width := 2;
  self.Canvas.PenPos := Point(0, 1);
  self.Canvas.LineTo(self.Width - 1, 1);
  self.Canvas.LineTo(self.Width - 1, self.Height - 1);
  self.Canvas.LineTo(1, self.Height - 1);
  self.Canvas.LineTo(1, 0);
  self.Canvas.Pen.Color := fPanelColor;
  self.Canvas.Pen.Width := 1;}
end;

procedure TMyPanel.WMSetFocus(var Msg: TWMSetFocus);
begin
  if (Msg.Msg = WM_SETFOCUS) then
    begin
      FrameColor := FocusColor;
      fSetFocus(self);
      OnMouseMove(self, [], 0, 0);
      Repaint;
    end;
end;

procedure TMyPanel.WMKillFocus(var Msg: TWMKillFocus);
begin
  if (Msg.Msg = WM_KILLFOCUS) then
    begin
      if FrameColor <> PropColor then
        FrameColor := fPanelColor;
      fKillFocus(self);
      Repaint;
    end;
end;

procedure TMyPanel.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  if fPushed then
    begin
      self.Canvas.Brush.Color := fPanelColor;
      self.Canvas.FillRect(self.Canvas.ClipRect);
      self.Canvas.Pen.Color := fDColor2;
      self.Canvas.PenPos := Point(self.Width - 2, 0);
      self.Canvas.LineTo(0, 0);
      self.Canvas.LineTo(0, self.Height - 1);
      self.Canvas.Pen.Color := fDColor1;
      self.Canvas.PenPos := Point(self.Width - 2, 1);
      self.Canvas.LineTo(self.Width - 2, self.Height - 2);
      self.Canvas.LineTo(0, self.Height - 2);
      self.Canvas.Pen.Color := fPanelColor;
      if fHasIcon then
        self.Canvas.Draw(3,3,PushedIcon);
    end
  else
    begin
      self.Canvas.Brush.Color := fPanelColor;
      self.Canvas.FillRect(self.Canvas.ClipRect);
      self.Canvas.Pen.Color := fLColor;
      self.Canvas.PenPos := Point(self.Width - 1, 0);
      self.Canvas.LineTo(0, 0);
      self.Canvas.LineTo(0, self.Height - 1);
      self.Canvas.Pen.Color := fDColor1;
      self.Canvas.PenPos := Point(self.Width - 1, 0);
      self.Canvas.LineTo(self.Width - 1, self.Height - 1);
      self.Canvas.LineTo(-1, self.Height - 1);
      self.Canvas.Pen.Color := fPanelColor;
      if fHasIcon then
        self.Canvas.Draw(2,2,Icon);
    end;

  DrawFrame(FrameColor);
end;

procedure TMyPanel.SetBlueFrame;
begin
  FrameColor := PropColor;
  Repaint;
end;

procedure TMyPanel.RemoveFrame;
begin
  FrameColor := fPanelColor;
  Repaint;
end;

end.
