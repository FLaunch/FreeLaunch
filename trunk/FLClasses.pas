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

unit FLClasses;

interface

uses
  Windows, SysUtils, Classes, Controls, ExtCtrls, ShellApi, Messages, Graphics, Menus, Dialogs,
  FLFunctions;

const
  //--���� �������������� ����� � ������ � �������
  FocusColor = clRed;
  DraggedColor = clBlue;
  IconCacheDir = 'IconCache';

type

  {*--�������� ���� ������� ��������� ����--*}
  {**} TFLPanel = class;
  {**} TFLDataItem = class;
  {*----------------------------------------*}

  //--��������� ��� �������� ������� (������, ������). ������������ ��� �������� ������������ ������� ����������
  TSize = record
    Width, Height: integer;
  end;

  //--����� ������ �� ����������
  TFLButton = class(TCustomControl)
    private
      //--���� 255, �� ������������ ������� ��������, ����� ���� ����� ��������
      fCurPage: byte;
      //--����, ������������ ������ �� � ������ ������ ������
      fPushed: boolean;
      //--����, ����������� ��� �������������� ������� �� ������ ��� ��������������
      fCanClick: boolean;
      //--���� �������������� �����
      fFrameColor: TColor;
      //--����� ������ � ������� ������ ������
      fRowNumber, fColNumber: byte;
      //--���������� ������ �� ������������ ������ (read ��� �������� Father)
      function GetFather: TFLPanel;
      //--����� ������ �������������� �����
      procedure DrawFrame;
      //--������������� ���� �������������� ����� (write ��� �������� FrameColor)
      procedure SetFrameColor(FrameColor: TColor);
      //--���������� ������ (������, ������� ����� � �.�.) ��� ������� ������ ������� �������� (read ��� �������� Data)
      function GetDataItem: TFLDataItem;
      //--�������� �� ������� ������ ������� �������� �������� (read ��� �������� IsActive)
      function GetIsActive: boolean;
      //--����������� �� ������ �� ������ (read ��� �������� HasIcon)
      function GetHasIcon: boolean;
      //--����������� �� ������ �� ������ (write ��� �������� HasIcon)
      procedure SetHasIcon(NewHasIcon: boolean);
      //--����� ������������ ��� ��������� ������� ���� ������
      procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
      //--����� ������������ ��� ��������� ������� ������
      procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
      //--����� ������������ ��� ������ ������� ������
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
      //--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      //--����� ������������ ��� �������������� ����� �� ������
      procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    protected

    public
      //--�����������
      constructor Create(AOwner: TComponent; RowNumber, ColNumber: byte);
      //--����������
      destructor Destroy; override;
      //--������������� ������ ������ ������� ������ ������� ��������
      function InitializeData: TFLDataItem;
      //--������������ ������ ������ ������� ������ ������� ��������
      procedure FreeData;
      //--������ �� ������������ ������
      property Father: TFLPanel read GetFather;
      //--���� �������������� �����
      property FrameColor: TColor read fFrameColor write SetFrameColor;
      //--����� ������ � ������� ������ ������
      property RowNumber: byte read fRowNumber;
      property ColNumber: byte read fColNumber;
      //--������ ������ (������, ������� ����� � �.�.) ������� ������ ������� ��������
      property Data: TFLDataItem read GetDataItem;
      //--�������� �� ������ �������� (������� ���-����)
      property IsActive: boolean read GetIsActive;
      //--����������� �� ������ �� ������
      property HasIcon: boolean read GetHasIcon write SetHasIcon;
      //--������� �������������� ����� (�������)
      procedure RemoveFrame;
      //--����� ������������ ��� ������� ������ �� ����������
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
      //--����� ������������ ��� "�������" ������ �� ����������
      procedure KeyUp(var Key: Word; Shift: TShiftState); override;
      //--����� ������������ ��� ����� �����
      procedure Click; override;
      //--����� ������������ ��� ������� ������ ����
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      //--����� ������������ ��� "�������" ������ ����
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      //--����� ������������ ��� �������� ���� �� ������
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      //--����� ������������ ��� ������������� �� ������ ������� �������
      procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
      //--����� ������������ ��� ���������� ��������������� �������
      procedure DragDrop(Source: TObject; X, Y: Integer); override;
      //--����� ������������ ��� ����������� ������������� �������
      procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
      //--����� ������������ ��� ������ ������������ ����
      procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    published

  end;

  //--����� ��������� ������ ������, ���������� ���������� � ������
  TFLDataItem = class
    private
      //--������ �� ������������ ������
      fFather: TFLPanel;
      {*--���� �������--*}
      fLType: byte;
      fExec: string;
      fWorkDir: string;
      fIcon: string;
      fIconIndex: integer;
      fIconCache: string;
      fParams: string;
      fDropFiles: boolean;
      fDropParams: string;
      fDescr: string;
      fQues: boolean;
      fHide: boolean;
      fPr: byte;
      fWSt: byte;
      {*----------------*}
      //--���� ������
      fPanelColor: TColor;
      //--����, ������������, ����������� �� ������
      fHasIcon: boolean;
      //--read ��� �������� Exec
      function GetExec: string;
      //--read ��� �������� WorkDir
      function GetWorkDir: string;
      //--read ��� �������� Icon
      function GetIcon: string;
      function GetIconCache: string;
      //--read ��� �������� Params
      function GetParams: string;
      //--read ��� �������� DropParams
      function GetDropParams: string;
    public
      //--����������� ������
      IconBmp: TBitMap;
      //--����������� ������� ������
      PushedIconBmp: TBitMap;
      //--�����������
      constructor Create(ButtonWidth, ButtonHeight: byte; PanelColor: TColor);
      //--����������
      destructor Destroy; override;
      //--������ �� ������������ ������
      property Father: TFLPanel read fFather write fFather;
      //--������� ���������� ������ (������� � "�������" ��� ������ ������)
      procedure AssignIcons;
      //--��� ������ (0 - ����������� ����, 1 - ����, �����)
      property LType: byte read fLType write fLType;
      //--���� � �������
      property Exec: string read GetExec write fExec;
      //--������� �����
      property WorkDir: string read GetWorkDir write fWorkDir;
      //--���� � ������
      property Icon: string read GetIcon write fIcon;
      //--������ ������
      property IconIndex: integer read fIconIndex write fIconIndex;
      property IconCache: string read GetIconCache write fIconCache;
      //--���������
      property Params: string read GetParams write fParams;
      //--��������� �� �������������� �����
      property DropFiles: boolean read fDropFiles write fDropFiles;
      //--��������� (��� ������������� �����)
      property DropParams: string read GetDropParams write fDropParams;
      //--��������
      property Descr: string read fDescr write fDescr;
      //--���������� �� ������������� ��� �������
      property Ques: boolean read fQues write fQues;
      //--�������� �� ���� FL ��� �������
      property Hide: boolean read fHide write fHide;
      //--��������� ����������� ��������
      property Pr: byte read fPr write fPr;
      //--��������� ����
      property WSt: byte read fWSt write fWSt;
      function GetIconCacheRaw: string;
  end;

  //--����� ��������� �������� ������ (������� ������ ��� ������ ����� �������)
  TFLDataTable = class
    private
      //--������� ������� (���-�� ������� � �����)
      fColsCount, fRowsCount: byte;
      //--����� ��������
      fPageNumber: byte;
      //--������ ������
      fItems: array of array of TFLDataItem;
      //--���������� ������ �� �������� (read ��� Items)
      function GetItem(RowNumber, ColNumber: byte): TFLDataItem;
      //--����������, �������� �� ������ �������� (read ��� IsActive)
      function GetIsActive(RowNumber, ColNumber: byte): boolean;
    public
      //--�����������
      constructor Create(PageNumber, ColsCount, RowsCount: byte);
      //--����������
      destructor Destroy; override;
      //--�������� ���� �������� ������
      procedure Clear;
      //--������ ������ �� �� ��������
      property Items[RowNumber, ColNumber: byte]: TFLDataItem read GetItem;
      //--�������� �� ������ ��������
      property IsActive[RowNumber, ColNumber: byte]: boolean read GetIsActive;
  end;

  //--��������� �� ��������� ������
  PFLDataCollection = ^TFLDataCollection;

  //--��������� ������ - ���������� ������ ������� ������ ;)
  TFLDataCollection = packed record
    PrevNode: PFLDataCollection;
    Node: TFLDataTable;
    NextNode: PFLDataCollection;
  end;

  {*--���� ��� �������� �������--*}
  {**} TButtonClickEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseDownEvent = procedure(Sender: TObject; MouseButton: TMouseButton; Button: TFLButton) of object;
  {**} TButtonMouseMoveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseLeaveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TDropFileEvent = procedure(Sender: TObject; Button: TFLButton; FileName: string) of object;
  {*-----------------------------*}

  //--������� �����. ��������� ��������� - ������� ������
  TFLPanel = class(TCustomControl)
    private
      //--����� ���� ������ � ������
      fPanelColor: TColor;
      //--������� � ��� ������ ����� ������ (����)
      fLColor, fDColor1, fDColor2: TColor;
      //--���-�� �������, ������� � �����
      fPagesCount, fColsCount, fRowsCount: byte;
      //--����� ������� ��������
      fPageNumber: byte;
      //--������ � ������ ������
      fButtonWidth, fButtonHeight: byte;
      //--����� ����� ��������
      fPadding: byte;
      //--������ ������
      fButtons: array of array of TFLButton;
      //--��������� �� ��������� ������
      fDataCollection: PFLDataCollection;
      //--��������� �� ������� �������� ������ (�������� ��������)
      fCurrentData: PFLDataCollection;
      //--�������� �� � ��������� ���������� � ������� ������ ���������� FL_*
      fExpandStrings: boolean;
      {*--���������� FL_*--*}
      {**} fFL_DIR: string;
      {**} fFL_ROOT: string;
      {*-------------------*}
      //--����������� �� ������ ������������� ������
      fDragNow: boolean;
      //--������ �� ������ � �������
      fFocusedButton: TFLButton;
      //--������ �� ��������� ��������������� ������
      fLastUsedButton: TFLButton;
      //--������� ��� ����� �� ������
      fButtonClick: TButtonClickEvent;
      //--������� ��� ������� ������ ���� �� ������
      fButtonMouseDown: TButtonMouseDownEvent;
      //--������� ��� �������� ����
      fButtonMouseMove: TButtonMouseMoveEvent;
      //--������� ��� ��������� ������� ���� ������
      fButtonMouseLeave: TButtonMouseLeaveEvent;
      //--������� ��� �������������� ����� �� ������
      fDropFile: TDropFileEvent;
      //--����������� ���� ��� ������
      fButtonsPopup: TPopupMenu;
      //--����� ��������, �� ������� ������ ������������� ������
      fDraggedButtonPageNumber: byte;
      //--���������� ������ �� ��������� ��������������� ������ (read ��� LastDraggedButton)
      function GetLastDraggedButton: TFLButton;
      //--���������� ������ �� �������� (������� �������� ��������) (read ��� CurButtons)
      function GetCurButton(RowNumber, ColNumber: byte): TFLButton;
      //--���������� ������ �� �������� (������������ ��������) (read ��� Buttons)
      function GetButton(PageNumber, RowNumber, ColNumber: byte): TFLButton;
      //--��������� ������������ ���� ��� ������ (write ��� ButtonsPopup)
      procedure SetButtonsPopup(ButtonsPopup: TPopupMenu);
      //--��������� ������ ������� �������� (write ��� PageNumber)
      procedure SetPageNumber(PageNumber: byte);
      //--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      //--����������� ����������� ������� ���������� (�������� ���������� ����� � ������� ������, � ����� �� �������. write ��� ActualSize)
      function GetActualSize: TSize;
      //--����� ���������� ��������� �� �������� ������ �� ������ ��������
      function GetDataPageByPageNumber(PageNumber: byte): PFLDataCollection;
      //--����� ���������� ��������� �� ��������� �������� ������ ("�����")
      function GetLastDataPage: PFLDataCollection;
    protected

    public
      //--�����������
      constructor Create(AOwner: TComponent; PagesCount: byte = 3; ColsCount: byte = 10;
        RowsCount: byte = 2; Padding: byte = 1; ButtonsWidth: byte = 32; ButtonsHeight: byte = 32;
        Color: TColor = clBtnFace);
      //--����������
      destructor Destroy; override;
      //--������������� ������ ������
      procedure InitializeDataItem(PageNumber, RowNumber, ColNumber: byte);
      //--������ ������� ��� �������� ������
      procedure SwapData(PageNumber1, PageNumber2: byte);
      //--������� �������� ������
      procedure ClearPage(PageNumber: byte);
      //--������� �������� ������
      function DeletePage(PageNumber: byte): Byte;
      //--������� �������� ������
      function AddPage: Byte;
      //--����������� ���� ������
      procedure FullRepaint;
      //--��������� ���������� FL_*
      procedure SetFLVariable(VarName: string; VarVal: string);
      //--�������� �� � ��������� ���������� � ������� ������ ���������� FL_*
      property ExpandStrings: boolean read fExpandStrings write fExpandStrings;
      //--������ �� ������ � �������
      property FocusedButton: TFLButton read fFocusedButton;
      //--������ �� ��������� ��������������� ������
      property LastUsedButton: TFLButton read fLastUsedButton;
      //--���-�� �������, ������� � �����
      property PagesCount: byte read fPagesCount;
      property ColsCount: byte read fColsCount;
      property RowsCount: byte read fRowsCount;
      //--������ �� �� �������� (������� �������� ��������)
      property CurButtons[RowNumber, ColNumber: byte]: TFLButton read GetCurButton;
      //--������ �� �� �������� (������������ ��������)
      //--����� ������� ����� ���������� ��������� ���� �� ��������� �������/�������:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--����� ������, ������ ������/�������� � �������
      //--��������: Buttons[0, 0, 0].IsActive
      property Buttons[PageNumber, RowNumber, ColNumber: byte]: TFLButton read GetButton;
      //--��������� ��������������� ������
      //--����� ������� ����� ���������� ��������� ���� �� ��������� �������/�������:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--����� ������, ������ ������/�������� � �������
      //--��������: Buttons[0, 0, 0].IsActive
      property LastDraggedButton: TFLButton read GetLastDraggedButton;
      //--����� ������� ��������
      property PageNumber: byte read fPageNumber write SetPageNumber;
      //--���������� ������ ����������
      property ActualSize: TSize read GetActualSize;
      //--����������� ���� ��� ������
      property ButtonsPopup: TPopupMenu read fButtonsPopup write SetButtonsPopup;
      //--����� ������������ ��� ������� ������ �� ����������
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
      //--������� ��� ����� �� ������
      property OnButtonClick: TButtonClickEvent read fButtonClick write fButtonClick;
      //--������� ��� ������� ������ ���� �� ������
      property OnButtonMouseDown: TButtonMouseDownEvent read fButtonMouseDown write fButtonMouseDown;
      //--������� ��� �������� ����
      property OnButtonMouseMove: TButtonMouseMoveEvent read fButtonMouseMove write fButtonMouseMove;
      //--������� ��� ��������� ������� ���� ������
      property OnButtonMouseLeave: TButtonMouseLeaveEvent read fButtonMouseLeave write fButtonMouseLeave;
      //--������� ��� �������������� ����� �� ������
      property OnDropFile: TDropFileEvent read fDropFile write fDropFile;
    published

  end;

implementation

uses
  IOUtils;

{*******************************}
{*****-- ����� TFLButton --*****}
{*******************************}

//--����������� ������
//--������� ���������: ������������ ���������, ����� ����, ����� �������
constructor TFLButton.Create(AOwner: TComponent; RowNumber, ColNumber: byte);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ParentBackground := false;
  Width := Father.fButtonWidth;
  Height := Father.fButtonHeight;
  //--��������� ������������� �� Tab
  TabStop := true;
  Color := Father.fPanelColor;
  FrameColor := Father.fPanelColor;
  fRowNumber := RowNumber;
  fColNumber := ColNumber;
  fPushed := false;
  fCanClick := true;
  fCurPage := 255;
  //--��������� ������������ ����� �� ������
  DragAcceptFiles(Handle, True);
end;

//--���������� ������
destructor TFLButton.Destroy;
begin
  inherited Destroy;
end;

//--������������� ������ ������ ������� ������ ������� ��������
function TFLButton.InitializeData: TFLDataItem;
begin
  if not Assigned(Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber]) then
    Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber] :=
      TFLDataItem.Create(Father.fButtonWidth, Father.fButtonHeight, Father.fPanelColor);

  Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber].Father := Father;
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--������������ ������ ������ ������� ������ ������� ��������
procedure TFLButton.FreeData;
begin
  FreeAndNil(Father.fCurrentData.Node.fItems[fRowNumber, fColNumber]);
  Repaint;
end;

//--���������� ������ �� ������������ ������
function TFLButton.GetFather: TFLPanel;
begin
  Result := Parent as TFLPanel;
end;

//--����� ������ �������������� �����
procedure TFLButton.DrawFrame;
var
  i,j: integer;
  DrawColor: TColor;
begin
  //--���� ������ ����������� ������������� ���� ������, �� �������� ����� ����� DraggedColor
  if (IsActive) and (Father.fDragNow) and (Self = Father.fLastUsedButton) and (Father.fPageNumber = Father.fDraggedButtonPageNumber) then
    DrawColor := DraggedColor
  else
    if Focused then
      DrawColor := FocusColor
    else
      DrawColor := fFrameColor;

  //--���� ������ ������ ��� ���� ����� ��������� � ������ ������, �� ����� �� ��������
  if (fPushed) or (DrawColor = Father.fPanelColor) then Exit;

  for i := 0 to Width - 1 do
    for j := 0 to Height - 1 do
      begin
        Canvas.Pixels[i,j] := GetColorBetween(Canvas.Pixels[i,j], DrawColor, 18, 0, 100);
      end;
end;

//--������������� ���� �������������� �����
//--������� ��������: ���� �����
procedure TFLButton.SetFrameColor(FrameColor: TColor);
begin
  fFrameColor := FrameColor;
  Repaint;
end;

//--���������� ������ (������, ������� ����� � �.�.) ��� ������� ������ ������� ��������
function TFLButton.GetDataItem: TFLDataItem;
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> ������ ������ [fRowNumber, fColNumber] (����������� � ������������ ������)
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--�������� �� ������� ������ ������� �������� ��������
function TFLButton.GetIsActive: boolean;
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> �������� �� ������ ��������
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.IsActive[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--����������� �� ������ �� ������
function TFLButton.GetHasIcon: boolean;
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> ������ ������ � ������������ [fRowNumber, fColNumber] -> ����� �� ������
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber].fHasIcon;
  fCurPage := 255;
end;

//--����������� �� ������ �� ������
procedure TFLButton.SetHasIcon(NewHasIcon: boolean);
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> ������ ������ � ������������ [fRowNumber, fColNumber] -> ����� �� ������
  Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber].fHasIcon := NewHasIcon;
  fCurPage := 255;
end;

//--����� ������������ ��� ��������� ������� ���� ������
procedure TFLButton.WMMouseLeave(var Msg: TMessage);
begin
  //--���������� ������� ������������ ������ OnButtonMouseLeave, ��������� ������� ������
  if Assigned(Father.fButtonMouseLeave) then Father.fButtonMouseLeave(Father, Self);
end;

//--����� ������������ ��� ��������� ������� ������
procedure TFLButton.WMSetFocus(var Msg: TWMSetFocus);
begin
  //--������������� ������ �� ������ � ������� <- ������� ������
  Father.fFocusedButton := Self;
  //--���������� �������� ���� �� ������
  MouseMove([], 0, 0);
  Repaint;
end;

//--����� ������������ ��� ������ ������� ������
procedure TFLButton.WMKillFocus(var Msg: TWMKillFocus);
begin
  Father.fFocusedButton := nil;
  Repaint;
end;

//--������� �������������� ����� (�������)
procedure TFLButton.RemoveFrame;
begin
  //--������������� ���� ����� <- ���� ������
  fFrameColor := Father.fPanelColor;
  Repaint;
end;

//--����� ������������ ��� ������� ������ �� ����������
//--������������ ������� ����� ������� Enter
procedure TFLButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    MouseDown(mbLeft, [], 0, 0);
  inherited KeyDown(Key, Shift);
end;

//--����� ������������ ��� "�������" ������ �� ����������
//--��. �������� � KeyDown
procedure TFLButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    begin
      MouseUp(mbLeft, [], 0, 0);
      Click;
    end;
  inherited KeyUp(Key, Shift);
end;

//--����� ������������ ��� ����� �����
procedure TFLButton.Click;
begin
  //--���� ���� � ������ ������ ��������
  //--� ���������� �� �����, ����� �� ����� ���������� ������ � ������� Ctrl
  //--����� ��� ���������� ������ ���� ������������� �� ����
  if fCanClick then
    begin
      //--������������� ������ �� ��������� �������������� ������ <- ������� ������
      Father.fLastUsedButton := Self;
      //--���������� ������� ������������ ������ OnButtonClick, ��������� ������ �� ������� ������
      if Assigned(Father.fButtonClick) then Father.fButtonClick(Father, Self);
      inherited Click;
    end;
end;

//--����� ������������ ��� ������� ������ ����
procedure TFLButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //--���� ������ ���� - �����
  if button = mbLeft then
    //--���� ����� Ctrl
    if ssCtrl in Shift then
      begin
        //--��������� ��������� ����� �� ���� ������
        fCanClick := false;
        //--�������� ������������� ������
        BeginDrag(false);
        Father.fDragNow := true;
        //--���������� ����� ��������, �� ������� ������ ������������� ������
        Father.fDraggedButtonPageNumber := Father.fPageNumber;
        //--������������� ������ �� ��������� �������������� ������ <- ������� ������
        Father.fLastUsedButton := Self;
        //--�������������� (����� ��������� �����)
        Repaint;
      end
    else
      begin
        //--���� Ctrl ����� �� ���, ������ ����� �������
        fPushed := true;
        //--������������� ������ �� ��������� �������������� ������ <- ������� ������
        Father.fLastUsedButton := Self;
        Repaint;
      end;
  //--���������� ������� ������������ ������ OnButtonMouseDown, ��������� ������ �� ������� ������
  if Assigned(Father.fButtonMouseDown) then Father.fButtonMouseDown(Father, Button, Self);
  inherited MouseDown(Button, Shift, X, Y);
end;

//--����� ������������ ��� "�������" ������ ����
procedure TFLButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //--���� ������ ���� - �����
  if button = mbleft then
    begin
      //--������ ������ �������
      fPushed := false;
      Repaint;
    end;
  inherited MouseUp(Button, Shift, X, Y);
end;

//--����� ������������ ��� �������� ���� �� ������
procedure TFLButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //--���������� ������� ������������ ������ OnButtonMouseMove, ��������� ������� ������
  if Assigned(Father.fButtonMouseMove) then Father.fButtonMouseMove(Father, Self);
  inherited MouseMove(Shift, X, Y);
end;

//--����� ������������ ��� ������������� �� ������ ������� �������
procedure TFLButton.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
  //--���� �������������� ������ - �� ������ ������, �� ������� ������
  if not (Source is TFLButton) then Exit;
  (Source as TFLButton).fCurPage := Father.fDraggedButtonPageNumber;
  //--���� �������������� ������ - ������ �������� ������, �� ������� �����
  if ((Source as TFLButton).IsActive) and ((Father.fPageNumber <> Father.fDraggedButtonPageNumber) or (Source <> Self)) then Accept := true;
end;

//--����� ������������ ��� ���������� ��������������� �������
procedure TFLButton.DragDrop(Source: TObject; X, Y: Integer);
var
  TempDataItem: TFLDataItem;
begin
  {*--������ ������� ��� ������ ������--*}
  {**} TempDataItem := Father.fCurrentData.Node.fItems[fRowNumber, fColNumber];
  {**} Father.fCurrentData.Node.fItems[fRowNumber, fColNumber] := Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).Node.fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber];
  {**} Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).Node.fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber] := TempDataItem;
  {*--�������������� ������-�������� � ������-��������--*}
  {**} Repaint;
  {**} (Source as TFLButton).Repaint;
  {*----------------------------------------------------*}
  inherited DragDrop(Source, X, Y);
end;

//--����� ������������ ��� ����������� ������������� �������
procedure TFLButton.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  Father.fDragNow := false;
  Repaint;
  fCanClick := true;
end;

//--����� ������������ ��� ������ ������������ ����
procedure TFLButton.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  MouseDown(mbRight, [], 0, 0);
  Father.fLastUsedButton := Self;
  inherited DoContextPopup(MousePos, Handled);
end;

//--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
procedure TFLButton.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  //--���� ������ ������ � ������ ������
  if fPushed then
    begin
      {*--�� ������ ���� ��� ������� ������--*}
      {**} Canvas.Brush.Color := Father.fPanelColor;
      {**} Canvas.FillRect(Canvas.ClipRect);
      {**} Canvas.Pen.Color := Father.fDColor2;
      {**} Canvas.PenPos := Point(Width - 2, 0);
      {**} Canvas.LineTo(0, 0);
      {**} Canvas.LineTo(0, Height - 1);
      {**} Canvas.Pen.Color := Father.fDColor1;
      {**} Canvas.PenPos := Point(Width - 2, 1);
      {**} Canvas.LineTo(Width - 2, Height - 2);
      {**} Canvas.LineTo(0, Height - 2);
      {**} Canvas.Pen.Color := Father.fPanelColor;
      {*-------------------------------------*}
      //--���� ������ �������, ������ �� ������
      if (IsActive and HasIcon) then
        Canvas.Draw(3, 3, Data.PushedIconBmp);
    end
  else
    begin
      {*--����� ������ ������� ����--*}
      {**} Canvas.Brush.Color := Father.fPanelColor;
      {**} Canvas.FillRect(Canvas.ClipRect);
      {**} Canvas.Pen.Color := Father.fLColor;
      {**} Canvas.PenPos := Point(Width - 1, 0);
      {**} Canvas.LineTo(0, 0);
      {**} Canvas.LineTo(0, Height - 1);
      {**} Canvas.Pen.Color := Father.fDColor1;
      {**} Canvas.PenPos := Point(Width - 1, 0);
      {**} Canvas.LineTo(Width - 1, Height - 1);
      {**} Canvas.LineTo(-1, Height - 1);
      {**} Canvas.Pen.Color := Father.fPanelColor;
      {*-----------------------------*}
      //--���� ������ �������, ������ �� ������
      if (IsActive and HasIcon) then
        Canvas.Draw(2, 2, Data.IconBmp);
    end;
  //--������ �������������� ����� (���� �����������)
  DrawFrame;
end;

//--����� ������������ ��� �������������� ����� �� ������
procedure TFLButton.WMDropFiles(var Msg: TWMDropFiles);
var
  buf: array[0..MAX_PATH] of char;
begin
  if Assigned(Father.fDropFile) then
    begin
      DragQueryFile(Msg.Drop, 0, buf, SizeOf(buf));
      //--���������� ������� ������������ ������ OnDropFile, ��������� ������� ������ � ���� � �����
      Father.fDropFile(Father, Self, buf);
      DragFinish(Msg.Drop);
    end;
end;

{*********************************}
{*****-- ����� TFLDataItem --*****}
{*********************************}

//--�����������
//--������� ���������: ������ ������, ������ ������
constructor TFLDataItem.Create(ButtonWidth, ButtonHeight: byte; PanelColor: TColor);
begin
  fPanelColor := PanelColor;
  fHasIcon := false;
  IconBmp := TBitMap.Create;
  IconBmp.Width := ButtonWidth - 4;
  IconBmp.Height := ButtonHeight - 4;
  PushedIconBmp := TBitMap.Create;
  PushedIconBmp.Width := ButtonWidth - 7;
  PushedIconBmp.Height := ButtonHeight - 7;
end;

//--����������
destructor TFLDataItem.Destroy;
begin
  if TFile.Exists(IconCache) then
    TFile.Delete(IconCache);
  IconBmp.Free;
  PushedIconBmp.Free;
end;

//--read ��� �������� Exec
function TFLDataItem.GetExec: string;
begin
  Result := fExec;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read ��� �������� WorkDir
function TFLDataItem.GetWorkDir: string;
begin
  Result := fWorkDir;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read ��� �������� Icon
function TFLDataItem.GetIcon: string;
begin
  Result := fIcon;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

function TFLDataItem.GetIconCache: string;
begin
  Result := fIconCache;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

function TFLDataItem.GetIconCacheRaw: string;
begin
  Result := fIconCache;
end;

//--read ��� �������� Params
function TFLDataItem.GetParams: string;
begin
  Result := fParams;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read ��� �������� DropParams
function TFLDataItem.GetDropParams: string;
begin
  Result := fDropParams;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--������� ���������� ������ (������� � "�������" ��� ������ ������)
procedure TFLDataItem.AssignIcons;
var
  TempIcon: TIcon;
  TempBmp: TBitMap;
  icx,icy: integer;
begin
  TempIcon := TIcon.Create;
  // AbsolutePath fIcon

  //--���� ������� �� ����������
  if (not FileExists(GetIcon)) and (not DirectoryExists(GetIcon)) then
    //--��������� ����������� ������ "����� ����"
    TempIcon.Handle := LoadIcon(HInstance, 'RBLANKICON')
  else
    //--����� ��������� ������ �� �����
    TempIcon.Handle := GetFileIcon(GetIcon, true, fIconIndex);
  if TempIcon.Handle = 0 then
    TempIcon.Handle := LoadIcon(hinstance, 'RBLANKICON');
  {*--������ ������ �� ������� � �������� �����, �������� ����� �����--*}
  {**} icx := GetSystemMetrics(SM_CXICON);
  {**} icy := GetSystemMetrics(SM_CYICON);
  {**} TempBmp := TBitMap.Create;
  {**} TempBmp.Width := icx;
  {**} TempBmp.Height := icy;
  {**} TempBmp.Canvas.Brush.Color := fPanelColor;
  {**} TempBmp.Canvas.FillRect(TempBmp.Canvas.ClipRect);
  {**} DrawIcon(TempBmp.Canvas.Handle, 0, 0, TempIcon.Handle);
  {*--�������� ������ ������, ���� ��� ���������--*}
  {**} if (icx = IconBmp.Width) and (icy = IconBmp.Height) then
  {**}   IconBmp.Assign(TempBmp)
  {**} else
  {**}   SmoothResize(TempBmp, IconBmp);
  {*--����� �� ������� ������� "�������" ������--*}
  {**} if (icx = PushedIconBmp.Width) and (icy = PushedIconBmp.Height) then
  {**}   PushedIconBmp.Assign(TempBmp)
  {**} else
  {**}   SmoothResize(TempBmp, PushedIconBmp);
  {*---------------------------------------------*}
  IconCache := '%FL_DIR%' + IconCacheDir + TPath.DirectorySeparatorChar +
    ExtractFileNameNoExt(Exec) + '_' + TPath.GetGUIDFileName() + '.png';

  fHasIcon := true;
  TempIcon.Free;
  TempBmp.Free;
end;

{**********************************}
{*****-- ����� TFLDataTable --*****}
{**********************************}

//--�����������
//--������� ���������: ����� ��������, ���-�� ������� � �����
constructor TFLDataTable.Create(PageNumber, ColsCount, RowsCount: byte);
begin
  fPageNumber := PageNumber;
  fColsCount := ColsCount;
  fRowsCount := RowsCount;
  //--������� ������ ��� ������ ������
  SetLength(fItems, fRowsCount, fColsCount);
end;

//--����������
destructor TFLDataTable.Destroy;
var
  i, j: byte;
begin
  //--���������� ��������� ������
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then fItems[i][j].Destroy;
  //--����������� ������ ������
  SetLength(fItems, 0);
end;

//--�������� ���� �������� ������
procedure TFLDataTable.Clear;
var
  i, j: byte;
begin
  //--���������� ��������� ������
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
        begin
          fItems[i][j].Destroy;
          fItems[i][j] := nil;
        end;
end;

//--���������� ������ �� ��������
//--������� ���������: ����� ���� � �������
function TFLDataTable.GetItem(RowNumber, ColNumber: byte): TFLDataItem;
begin
  Result := fItems[RowNumber][ColNumber];
end;

//--����������, �������� �� ������ ��������
//--������� ���������: ����� ���� � �������
function TFLDataTable.GetIsActive(RowNumber, ColNumber: byte): boolean;
begin
  //--������ �������, ���� �����, �� �����������, ������
  Result := Assigned(fItems[RowNumber][ColNumber]);
end;

{******************************}
{*****-- ����� TFLPanel --*****}
{******************************}

//--����������� ����������� ������� ���������� (�������� ���������� ����� � ������� ������, � ����� �� �������. write ��� ActualSize)
//--��������� ��������� ����� ��� ������ ����������
function TFLPanel.GetActualSize: TSize;
begin
  Result.Width := fPadding * (fColsCount + 1) + (fButtonWidth * fColsCount) + 2;
  Result.Height := fPadding * (fRowsCount + 1) + (fButtonHeight * fRowsCount) + 2;
end;

//--����� ���������� ��������� �� �������� ������ �� ������ ��������
//--������� ��������: ����� ��������
function TFLPanel.GetDataPageByPageNumber(PageNumber: byte): PFLDataCollection;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := fCurrentData;
  if PageNumber = 255 then Exit;
  Result := nil;
  {*--����������� �� ��������� ������ � ������ �������� � ������ �������--*}
  {**} DataCurrent := fDataCollection;
  {**} repeat
  {**}   if DataCurrent.Node.fPageNumber = PageNumber then
  {**}     begin
  {**}       Result := DataCurrent;
  {**}       Exit;
  {**}     end;
  {**}   DataNext := DataCurrent.NextNode;
  {**}   DataCurrent := DataNext;
  {**} until
  {**}   DataCurrent = nil;
  {*----------------------------------------------------------------------*}
end;

//--����� ���������� ��������� �� ��������� �������� ������ ("�����")
function TFLPanel.GetLastDataPage: PFLDataCollection;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := nil;
  {*--����������� �� ��������� ������ �� �����--*}
  {**} DataCurrent := fDataCollection;
  {**} while DataCurrent.NextNode <> nil do
  {**}   begin
  {**}     DataNext := DataCurrent.NextNode;
  {**}     DataCurrent := DataNext;
  {**}   end;
  {*----------------------------------------------------------------------*}
  Result := DataCurrent;
end;

//--�����������
//--������� ���������: ������������ ���������, ���-�� �������, ���-�� �������, ���-�� �����, ����� ����� ��������, ������ ������, ������ ������, ���� ������
constructor TFLPanel.Create(AOwner: TComponent; PagesCount: byte = 3; ColsCount: byte = 10; RowsCount: byte = 2; Padding: byte = 1; ButtonsWidth: byte = 32; ButtonsHeight: byte = 32; Color: TColor = clBtnFace);
var
  TempColor: TColor;
  i, j: byte;
  DataCurrent, DataPrev: PFLDataCollection;
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ParentBackground := false;
  Align := alClient;
  Self.Color := Color;
  fPanelColor := Color;
  if fPanelColor = clBtnFace then
    TempColor := GetSysColor(COLOR_BTNFACE)
  else
    TempColor := fPanelColor;
  fLColor := GetColorBetween(TempColor, clwhite, 85, 0, 100);
  fDColor1 := GetColorBetween(TempColor, clblack, 35, 0, 100);
  fDColor2 := GetColorBetween(TempColor, clblack, 55, 0, 100);
  fPagesCount := PagesCount;
  fColsCount := ColsCount;
  fRowsCount := RowsCount;
  fPadding := Padding;
  fButtonWidth := ButtonsWidth + 4;
  fButtonHeight := ButtonsHeight + 4;
  fPageNumber := 0;
  fFocusedButton := nil;
  fLastUsedButton := nil;
  fExpandStrings := true;
  {*--�������������� ��������� ������--*}
  {**} for i := 0 to fPagesCount - 1 do
  {**}   begin
  {**}     New(DataCurrent);
  {**}     if i > 0 then
  {**}       begin
  {**}         DataPrev.NextNode := DataCurrent;
  {**}         DataCurrent.PrevNode := DataPrev;
  {**}       end
  {**}     else
  {**}       begin
  {**}         DataCurrent.PrevNode := nil;
  {**}         fDataCollection := DataCurrent;
  {**}       end;
  {**}     DataCurrent.NextNode := nil;
  {**}     DataCurrent.Node := TFLDataTable.Create(i, fColsCount, fRowsCount);
  {**}     DataPrev := DataCurrent;
  {**}   end;
  {**} fCurrentData := fDataCollection;
  {*-----------------------------------*}
  //--������� ������ ��� ������
  SetLength(fButtons, fRowsCount, fColsCount);
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      begin
        //--������� ������
        fButtons[i, j] := TFLButton.Create(Self, i, j);
        {*--������������� ������ � ������ �������--*}
        {**} fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
        {**} fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
        {*-----------------------------------------*}
      end;
  //--��������� �������������� ������ � ���� FreeLaunch, ����� �� ������� � ������� ��������������
  if TOSVersion.Check(6) then
  begin
    ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ADD);
    ChangeWindowMessageFilter (WM_COPYDATA, MSGFLT_ADD);
    ChangeWindowMessageFilter ($0049, MSGFLT_ADD);
  end;
end;

//--����������
destructor TFLPanel.Destroy;
var
  i, j: byte;
  DataCurrent, DataNext: PFLDataCollection;
begin
  {*--���������� ��� ������--*}
  {**} for i := 0 to fRowsCount - 1 do
  {**}   for j := 0 to fColsCount - 1 do
  {**}     fButtons[i, j].Free;
  {**} SetLength(fButtons, 0, 0);
  {*--����������� ��������� ������--*}
  {**} DataCurrent := fDataCollection;
  {**} repeat
  {**}   DataNext := DataCurrent.NextNode;
  {**}   DataCurrent.Node.Destroy;
  {**}   Dispose(DataCurrent);
  {**}   DataCurrent := DataNext;
  {**} until
  {**}   DataCurrent = nil;
  {*--------------------------------*}
  inherited Destroy;
end;

//--������������� ������ ������
//--������� ���������: ����� ��������, ����� ������, ����� �������
procedure TFLPanel.InitializeDataItem(PageNumber, RowNumber, ColNumber: byte);
begin
  if PageNumber = fPageNumber then
    fCurrentData.Node.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor)
  else
    GetDataPageByPageNumber(PageNumber).Node.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor);
end;

//--������ ������� ��� �������� ������
procedure TFLPanel.SwapData(PageNumber1, PageNumber2: byte);
var
  Page1, Page2: PFLDataCollection;
  TempPageNumber: byte;
begin
  //--���� �������� ������ 1
  Page1 := GetDataPageByPageNumber(PageNumber1);
  //--���� �������� ������ 2
  Page2 := GetDataPageByPageNumber(PageNumber2);
  {*--������ ����� ��������--*}
  {**} TempPageNumber := Page1.Node.fPageNumber;
  {**} Page1.Node.fPageNumber := Page2.Node.fPageNumber;
  {**} Page2.Node.fPageNumber := TempPageNumber;
  {*-------------------------*}
  Repaint;
end;

//--������� �������� ������
procedure TFLPanel.ClearPage(PageNumber: byte);
begin
  GetDataPageByPageNumber(PageNumber).Node.Clear;
  Repaint;
end;

//--������� �������� ������
//--���������� ����� ��������, ������� ������ ����� �������� ����� ��������
function TFLPanel.DeletePage(PageNumber: Byte): Byte;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := PageNumber;
  if PageNumber = fPagesCount - 1 then
    Result := PageNumber - 1;
  //--���� �������� ������ ��������� ��������
  DataCurrent := GetDataPageByPageNumber(PageNumber);
  //--���� ���������� ���������� ��������
  if DataCurrent.PrevNode <> nil then
    //--�� ��������� ���������� �� ���������
    DataCurrent.PrevNode.NextNode := DataCurrent.NextNode;
  //--���� ���������� ��������� ��������
  if DataCurrent.NextNode <> nil then
    //--�� ��������� ��������� � ����������
    DataCurrent.NextNode.PrevNode := DataCurrent.PrevNode;
  if DataCurrent.PrevNode = nil then
    fDataCollection := DataCurrent.NextNode;
  {*--������� �� ������ �������� ������--*}
  {**} DataCurrent.Node.Destroy;
  {**} FreeMem(DataCurrent, SizeOf(DataCurrent));
  {*--����������� �� ��������� ������ � ��������� �� 1 ��� ������ �������, ������� ��� ���������--*}
  {**} DataCurrent := fDataCollection;
  {**} repeat
  {**}   if DataCurrent.Node.fPageNumber > PageNumber then
  {**}     begin
  {**}       Dec(DataCurrent.Node.fPageNumber);
  {**}     end;
  {**}   DataNext := DataCurrent.NextNode;
  {**}   DataCurrent := DataNext;
  {**} until
  {**}   DataCurrent = nil;
  {*----------------------------------------------------------------------------------------------*}
  Dec(fPagesCount);
  SetPageNumber(Result);
end;

//--������� �������� ������
function TFLPanel.AddPage: Byte;
var
  DataNew, DataLast: PFLDataCollection;
begin
  Result := fPagesCount;
  //--������� ��������� �������� ������ ("�����")
  //--(� ����� �� �������� � ��������� � ������ ������?)
  DataLast := GetLastDataPage;
  //--������� ������ ��� ����� ��������
  GetMem(DataNew, SizeOf(DataNew));
  {*--��������� �������� � ����������--*}
  {**} DataLast.NextNode := DataNew;
  {**} DataNew.PrevNode := DataLast;
  {**} DataNew.NextNode := nil;
  {*-----------------------------------*}
  DataNew.Node := TFLDataTable.Create(Result, fColsCount, fRowsCount);
  Inc(fPagesCount);
  SetPageNumber(Result);
end;

//--����������� ���� ������
procedure TFLPanel.FullRepaint;
var
  i, j: byte;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].Repaint;
end;

//--��������� ���������� FL_*
//--������� ���������: ��� ����������, �������� ����������
procedure TFLPanel.SetFLVariable(VarName: string; VarVal: string);
begin
  if VarName = 'FL_ROOT' then fFL_ROOT := VarVal;
  if VarName = 'FL_DIR' then fFL_DIR := VarVal;
end;

//--���������� ������ �� ��������� ��������������� ������
function TFLPanel.GetLastDraggedButton: TFLButton;
begin
  //--����� LastUsedButton � ������� ��������, ������ ������ �������������
  //--���������� ������ ��� ������� � ������ ������
  Result := LastUsedButton;
  if LastUsedButton = nil then Exit;
  LastUsedButton.fCurPage := fDraggedButtonPageNumber;
end;

//--���������� ������ �� �������� (������� �������� ��������)
//--������� ���������: ����� ���� � �������
function TFLPanel.GetCurButton(RowNumber, ColNumber: byte): TFLButton;
begin
  Result := fButtons[RowNumber][ColNumber];
end;

//--���������� ������ �� �������� (������������ ��������)
//--������� ���������: ����� ��������, ���� � �������
function TFLPanel.GetButton(PageNumber, RowNumber, ColNumber: byte): TFLButton;
begin
  fButtons[RowNumber][ColNumber].fCurPage := PageNumber;
  Result := fButtons[RowNumber][ColNumber];
end;

//--��������� ������������ ���� ��� ������
//--������� ��������: ������ �� ����
procedure TFLPanel.SetButtonsPopup(ButtonsPopup: TPopupMenu);
var
  i, j: byte;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      begin
        fButtons[i, j].PopupMenu := ButtonsPopup;
      end;
end;

//--��������� ������ ������� ��������
//--������� ��������: ����� ��������
procedure TFLPanel.SetPageNumber(PageNumber: byte);
begin
  fPageNumber := PageNumber;
  //--������������� ��������� �� ������� �������� ������ <- ��������� �� �������� � ��������� �������
  fCurrentData := GetDataPageByPageNumber(fPageNumber);
  Repaint;
end;

//--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
procedure TFLPanel.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  {*--������ ���� ������--*}
  {**} Canvas.Brush.Color := fPanelColor;
//  {**} Canvas.FillRect(Canvas.ClipRect);
  {**} Canvas.Pen.Color := fDColor1;
  {**} Canvas.PenPos := Point(Width - 1, 0);
  {**} Canvas.LineTo(0, 0);
  {**} Canvas.LineTo(0, Height - 1);
  {**} Canvas.Pen.Color := fLColor;
  {**} Canvas.PenPos := Point(Width - 1, 0);
  {**} Canvas.LineTo(Width - 1, Height - 1);
  {**} Canvas.LineTo(-1, Height - 1);
  {**} Canvas.Pen.Color := fPanelColor;
  {*----------------------*}
end;

//--����� ������������ ��� ������� ������ �� ����������
//--����� ��������, ����� �������:
//--
//--procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//--begin
//--  FLPanel.KeyDown(Key, Shift);
//--end;
//--
//--����� ���������� ��������� ������� ������ �� ���������, ��� ��������� ������ �� �������
//--� ����� ���������� ��������� ����������� �������:
//--
//--private
//--  procedure CMDialogKey(var Msg: TCMDialogKey); message CM_DIALOGKEY;
//--...
//--procedure TMainForm.CMDialogKey(var Msg: TCMDialogKey);
//--begin
//--  if (Msg.Msg = CM_DIALOGKEY) then
//--    begin
//--      if (Msg.CharCode <> VK_DOWN) and (Msg.CharCode <> VK_UP) and (Msg.CharCode <> VK_LEFT) and (Msg.CharCode <> VK_RIGHT) then
//--        inherited;
//--    end;
//--end;
procedure TFLPanel.KeyDown(var Key: Word; Shift: TShiftState);
var
  d: integer;
begin
  //--���� ���������� ������ � �������
  if Assigned(fFocusedButton) then
    begin
      //--���� ������ ������� "����"
      if Key = vk_down then
        //--������ ����� ������, ����������� ����� (����������)
        fButtons[(fFocusedButton.RowNumber + 1) mod fRowsCount][fFocusedButton.ColNumber].SetFocus;
      //--���� ������ ������� "�����"
      if Key = vk_up then
        begin
          d := fFocusedButton.RowNumber - 1;
          if d < 0 then d := fRowsCount - 1;
          //--������ ����� ������, ����������� ������ (����������)
          fButtons[d mod fRowsCount][fFocusedButton.ColNumber].SetFocus;
        end;
      //--���� ������ ������� "�����"
      if Key = vk_left then
        begin
          d := fFocusedButton.ColNumber - 1;
          if d < 0 then
          d := ColsCount - 1;
          //--������ ����� ������, ����������� ����� (����������)
          fButtons[fFocusedButton.RowNumber][d mod fColsCount].SetFocus;
        end;
      //--���� ������ ������� "������"
      if Key = vk_right then
        //--������ ����� ������, ����������� ������ (����������)
        fButtons[fFocusedButton.RowNumber][(fFocusedButton.ColNumber + 1) mod fColsCount].SetFocus;
    end;
  inherited KeyDown(Key, Shift);
end;

end.
