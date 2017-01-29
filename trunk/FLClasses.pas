{
  ##########################################################################
  #  FreeLaunch 2.5 - free links manager for Windows                       #
  #  ====================================================================  #
  #  Copyright (C) 2017 FreeLaunch Team                                    #
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
  FLFunctions, System.Generics.Collections;

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
  TFLButton = class(TGraphicControl)
    private
      //--���� 255, �� ������������ ������� ��������, ����� ���� ����� ��������
      fCurPage: Integer;
      //--����, ������������ ������ �� � ������ ������ ������
      fPushed: boolean;
      //--����, ����������� ��� �������������� ������� �� ������ ��� ��������������
      fCanClick: boolean;
      //--���� �������������� �����
      fFrameColor: TColor;
      //--����� ������ � ������� ������ ������
      fRowNumber, fColNumber: Integer;
      FFocused: Boolean;
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
      procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      procedure SetFocused(const Value: Boolean);
    protected
      //--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
      procedure Paint; override;
    public
      //--�����������
      constructor Create(AOwner: TComponent; RowNumber, ColNumber: Integer);
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
      property RowNumber: integer read fRowNumber;
      property ColNumber: integer read fColNumber;
      //--������ ������ (������, ������� ����� � �.�.) ������� ������ ������� ��������
      property Data: TFLDataItem read GetDataItem;
      //--�������� �� ������ �������� (������� ���-����)
      property IsActive: boolean read GetIsActive;
      property Focused: Boolean read FFocused write SetFocused;
      //--����������� �� ������ �� ������
      property HasIcon: boolean read GetHasIcon write SetHasIcon;
      //--������� �������������� ����� (�������)
      procedure RemoveFrame;
      //--����� ������������ ��� ������� ������ �� ����������
      procedure KeyDown(var Key: Word; Shift: TShiftState);
      //--����� ������������ ��� "�������" ������ �� ����������
      procedure KeyUp(var Key: Word; Shift: TShiftState);
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
      fLType: integer;
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
      fPr: integer;
      fWSt: integer;
      {*----------------*}
      //--���� ������
      fPanelColor: TColor;
      //--����, ������������, ����������� �� ������
      fHasIcon: boolean;
      FHeight: Integer;
      FWidth: Integer;
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
      procedure SetHeight(const Value: Integer);
      procedure SetWidth(const Value: Integer);
      procedure SetColor(const Value: TColor);
    public
      //--����������� ������
      IconBmp: TBitMap;
      //--����������� ������� ������
      PushedIconBmp: TBitMap;
      //--�����������
      constructor Create(ButtonWidth, ButtonHeight: integer; PanelColor: TColor);
      //--����������
      destructor Destroy; override;
      //--������ �� ������������ ������
      property Father: TFLPanel read fFather write fFather;
      //--������� ���������� ������ (������� � "�������" ��� ������ ������)
      procedure AssignIcons;
      //--��� ������ (0 - ����������� ����, 1 - ����, �����)
      property LType: integer read fLType write fLType;
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
      property Pr: integer read fPr write fPr;
      //--��������� ����
      property WSt: integer read fWSt write fWSt;
      property Height: Integer read FHeight write SetHeight;
      property Width: Integer read FWidth write SetWidth;
      property Color: TColor read fPanelColor write SetColor;
  end;

  //--����� ��������� �������� ������ (������� ������ ��� ������ ����� �������)
  TFLDataTable = class
    private
      //--������� ������� (���-�� ������� � �����)
      fColsCount, fRowsCount: integer;
      //--����� ��������
      fPageNumber: integer;
      //--������ ������
      fItems: array of array of TFLDataItem;
      //--���������� ������ �� �������� (read ��� Items)
      function GetItem(RowNumber, ColNumber: integer): TFLDataItem;
      //--����������, �������� �� ������ �������� (read ��� IsActive)
      function GetIsActive(RowNumber, ColNumber: integer): boolean;
      procedure SetColsCount(const Value: Integer);
      procedure SetRowsCount(const Value: Integer);
      function GetColor: TColor;
      procedure SetColor(const Value: TColor);
      function GetImagesHeight: Integer;
      function GetImagesWidth: Integer;
      procedure SetImagesHeight(const Value: Integer);
      procedure SetImagesWidth(const Value: Integer);
    public
      //--�����������
      constructor Create(PageNumber, ColsCount, RowsCount: integer);
      //--����������
      destructor Destroy; override;
      //--�������� ���� �������� ������
      procedure Clear;
      //--������ ������ �� �� ��������
      property Items[RowNumber, ColNumber: integer]: TFLDataItem read GetItem;
      //--�������� �� ������ ��������
      property IsActive[RowNumber, ColNumber: integer]: boolean read GetIsActive;
      property ColsCount: Integer read FColsCount write SetColsCount;
      property RowsCount: Integer read FRowsCount write SetRowsCount;
      property Color: TColor read GetColor write SetColor;
      property ImagesWidth: Integer read GetImagesWidth write SetImagesWidth;
      property ImagesHeight: Integer read GetImagesHeight write SetImagesHeight;
  end;

  //--��������� ������ - ���������� ������ ������� ������ ;)
  TFLDataCollection = TObjectList<TFLDataTable>;

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
      fPagesCount, fColsCount, fRowsCount: Integer;
      //--������ � ������ ������
      fButtonWidth, fButtonHeight: integer;
      //--����� ����� ��������
      fPadding: integer;
      //--������ ������
      fButtons: array of array of TFLButton;
      //--��������� �� ��������� ������
      fDataCollection: TFLDataCollection;
      //--����� ������� �������� ������ (�������� ��������)
      fCurrentDataIndex: Integer;
      //--�������� �� � ��������� ���������� � ������� ������ ���������� FL_*
      fExpandStrings: boolean;
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
      fDraggedButtonPageNumber: integer;
      //--���������� ������ �� ��������� ��������������� ������ (read ��� LastDraggedButton)
      function GetLastDraggedButton: TFLButton;
      //--���������� ������ �� �������� (������� �������� ��������) (read ��� CurButtons)
      function GetCurButton(RowNumber, ColNumber: integer): TFLButton;
      //--���������� ������ �� �������� (������������ ��������) (read ��� Buttons)
      function GetButton(PageNumber, RowNumber, ColNumber: integer): TFLButton;
      //--��������� ������������ ���� ��� ������ (write ��� ButtonsPopup)
      procedure SetButtonsPopup(ButtonsPopup: TPopupMenu);
      //--��������� ������ ������� �������� (write ��� PageNumber)
      procedure SetPageNumber(PageNumber: Integer);
      //--����� ������������ ��� ��������� ������� ��������� � ������������� �����������
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      //--����� ������������ ��� �������������� ����� �� ������
      procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
      //--����� ������������ ��� ������ ������� ������
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
      //--����������� ����������� ������� ���������� (�������� ���������� ����� � ������� ������, � ����� �� �������. write ��� ActualSize)
      function GetActualSize: TSize;
      //--����� ���������� ��������� �� �������� ������ �� ������ ��������
      function GetDataPageByPageNumber(PageNumber: integer): TFLDataTable;
      //--����� ���������� ��������� �� ������� �������� ������
      function GetCurrentDataPage: TFLDataTable;
      procedure SetColsCount(const Value: Integer);
      procedure SetPagesCount(const Value: Integer);
      procedure SetRowsCount(const Value: Integer);
      procedure SetButtonWidth(const Value: integer);
      procedure SetButtonHeight(const Value: Integer);
      procedure SetButtonColor(const Value: TColor);
      procedure SetPadding(const Value: Integer);
      function GetButtonHeight: Integer;
      function GetButtonWidth: Integer;
      procedure SetFocusedButton(const Value: TFLButton);
    protected

    public
      //--�����������
      constructor Create(AOwner: TComponent; PagesCount: integer = 3; ColsCount: integer = 10;
        RowsCount: integer = 2; Padding: integer = 1; ButtonsWidth: integer = 32; ButtonsHeight: integer = 32;
        Color: TColor = clBtnFace);
      //--����������
      destructor Destroy; override;
      //--������������� ������ ������
      procedure InitializeDataItem(PageNumber, RowNumber, ColNumber: integer);
      //--������ ������� ��� �������� ������
      procedure SwapData(PageNumber1, PageNumber2: integer);
      //--������� �������� ������
      procedure ClearPage(PageNumber: integer);
      //--������� �������� ������
      function DeletePage(PageNumber: integer): integer;
      //--������� �������� ������
      function AddPage: integer;
      //--����������� ���� ������
      procedure FullRepaint;
      //--�������� �� � ��������� ���������� � ������� ������ ���������� FL_*
      property ExpandStrings: boolean read fExpandStrings write fExpandStrings;
      //--������ �� ������ � �������
      property FocusedButton: TFLButton read fFocusedButton write SetFocusedButton;
      //--������ �� ��������� ��������������� ������
      property LastUsedButton: TFLButton read fLastUsedButton;
      //--���-�� �������, ������� � �����
      property PagesCount: Integer read fPagesCount write SetPagesCount;
      property ColsCount: Integer read fColsCount write SetColsCount;
      property RowsCount: Integer read fRowsCount write SetRowsCount;
      property ButtonWidth: Integer read GetButtonWidth write SetButtonWidth;
      property ButtonHeight: Integer read GetButtonHeight write SetButtonHeight;
      property ButtonColor: TColor read fPanelColor write SetButtonColor;
      property Padding: Integer read FPadding write SetPadding;
      //--������ �� �� �������� (������� �������� ��������)
      property CurButtons[RowNumber, ColNumber: integer]: TFLButton read GetCurButton;
      //--������ �� �� �������� (������������ ��������)
      //--����� ������� ����� ���������� ��������� ���� �� ��������� �������/�������:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--����� ������, ������ ������/�������� � �������
      //--��������: Buttons[0, 0, 0].IsActive
      property Buttons[PageNumber, RowNumber, ColNumber: integer]: TFLButton read GetButton;
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
      property PageNumber: Integer read fCurrentDataIndex write SetPageNumber;
      //--���������� ������ ����������
      property ActualSize: TSize read GetActualSize;
      //--����������� ���� ��� ������
      property ButtonsPopup: TPopupMenu read fButtonsPopup write SetButtonsPopup;
      //--����� ������������ ��� "�������" ������ �� ����������
      procedure KeyUp(var Key: Word; Shift: TShiftState); override;
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
constructor TFLButton.Create(AOwner: TComponent; RowNumber, ColNumber: integer);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  Width := Father.fButtonWidth;
  Height := Father.fButtonHeight;
  Color := Father.fPanelColor;
  FrameColor := Father.fPanelColor;
  fRowNumber := RowNumber;
  fColNumber := ColNumber;
  fPushed := false;
  fCanClick := true;
  fCurPage := 255;
end;

//--���������� ������
destructor TFLButton.Destroy;
begin
  inherited Destroy;
end;

//--������������� ������ ������ ������� ������ ������� ��������
function TFLButton.InitializeData: TFLDataItem;
begin
  if not Assigned(Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber]) then
    Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber] :=
      TFLDataItem.Create(Father.fButtonWidth, Father.fButtonHeight, Father.fPanelColor);

  Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber].Father := Father;
  Result := Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber];
end;

//--������������ ������ ������ ������� ������ ������� ��������
procedure TFLButton.FreeData;
begin
  FreeAndNil(Father.GetCurrentDataPage.fItems[fRowNumber, fColNumber]);
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
  if (IsActive) and (Father.fDragNow) and (Self = Father.fLastUsedButton) and
    (Father.fCurrentDataIndex = Father.fDraggedButtonPageNumber)
  then
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

procedure TFLButton.SetFocused(const Value: Boolean);
begin
  FFocused := Value;

  if FFocused then
    //--���������� �������� ���� �� ������
    MouseMove([], 0, 0);

  Repaint;
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
  Result := Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber];
end;

//--�������� �� ������� ������ ������� �������� ��������
function TFLButton.GetIsActive: boolean;
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> �������� �� ������ ��������
  Result := Father.GetDataPageByPageNumber(fCurPage).IsActive[fRowNumber, fColNumber];
end;

//--����������� �� ������ �� ������
function TFLButton.GetHasIcon: boolean;
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> ������ ������ � ������������ [fRowNumber, fColNumber] -> ����� �� ������
  Result := Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber].fHasIcon;
end;

//--����������� �� ������ �� ������
procedure TFLButton.SetHasIcon(NewHasIcon: boolean);
begin
  //--������������ ������ -> ������� �������� ������ (��� �� �������) -> ������ ������ � ������������ [fRowNumber, fColNumber] -> ����� �� ������
  Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber].fHasIcon := NewHasIcon;
end;

//--����� ������������ ��� ��������� ������� ���� ������
procedure TFLButton.CMMouseLeave(var Msg: TMessage);
begin
  //--���������� ������� ������������ ������ OnButtonMouseLeave, ��������� ������� ������
  if Assigned(Father.fButtonMouseLeave) then Father.fButtonMouseLeave(Father, Self);
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
        Father.fDraggedButtonPageNumber := Father.fCurrentDataIndex;
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

  Father.FocusedButton := nil;

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
  if ((Source as TFLButton).IsActive) and
    ((Father.fCurrentDataIndex <> Father.fDraggedButtonPageNumber) or (Source <> Self))
  then
    Accept := true;
end;

//--����� ������������ ��� ���������� ��������������� �������
procedure TFLButton.DragDrop(Source: TObject; X, Y: Integer);
var
  TempDataItem: TFLDataItem;
begin
  {*--������ ������� ��� ������ ������--*}
  {**} TempDataItem := Father.GetCurrentDataPage.fItems[fRowNumber, fColNumber];
  {**} Father.GetCurrentDataPage.fItems[fRowNumber, fColNumber] := Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber];
  {**} Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber] := TempDataItem;
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
procedure TFLButton.Paint;
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

{*********************************}
{*****-- ����� TFLDataItem --*****}
{*********************************}

//--�����������
//--������� ���������: ������ ������, ������ ������
constructor TFLDataItem.Create(ButtonWidth, ButtonHeight: integer; PanelColor: TColor);
begin
  fPanelColor := PanelColor;
  fHasIcon := false;
  FHeight := ButtonHeight;
  FWidth := ButtonWidth;
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
  Result := ExpandEnvironmentVariables(Result);
end;

//--read ��� �������� WorkDir
function TFLDataItem.GetWorkDir: string;
begin
  Result := fWorkDir;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

procedure TFLDataItem.SetColor(const Value: TColor);
begin
  fPanelColor := Value;
  AssignIcons;
end;

procedure TFLDataItem.SetHeight(const Value: Integer);
begin
  FHeight := Value;

  IconBmp.Height := FHeight - 4;
  PushedIconBmp.Height := FHeight - 7;
end;

procedure TFLDataItem.SetWidth(const Value: Integer);
begin
  FWidth := Value;

  IconBmp.Width := FWidth - 4;
  PushedIconBmp.Width := FWidth - 7;
end;

//--read ��� �������� Icon
function TFLDataItem.GetIcon: string;
begin
  Result := fIcon;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

function TFLDataItem.GetIconCache: string;
begin
  Result := fIconCache;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

//--read ��� �������� Params
function TFLDataItem.GetParams: string;
begin
  Result := fParams;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

//--read ��� �������� DropParams
function TFLDataItem.GetDropParams: string;
begin
  Result := fDropParams;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
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
  if TFile.Exists(IconCache) then
    TFile.Delete(IconCache);
  IconCache := '%FL_CONFIG%' + TPath.DirectorySeparatorChar + IconCacheDir +
    TPath.DirectorySeparatorChar + ExtractFileNameNoExt(Exec) + '_' +
    TPath.GetGUIDFileName() + '.png';

  fHasIcon := true;
  TempIcon.Free;
  TempBmp.Free;
end;

{**********************************}
{*****-- ����� TFLDataTable --*****}
{**********************************}

//--�����������
//--������� ���������: ����� ��������, ���-�� ������� � �����
constructor TFLDataTable.Create(PageNumber, ColsCount, RowsCount: integer);
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
  i, j: integer;
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
  i, j: integer;
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
function TFLDataTable.GetItem(RowNumber, ColNumber: integer): TFLDataItem;
begin
  Result := fItems[RowNumber][ColNumber];
end;

procedure TFLDataTable.SetColor(const Value: TColor);
var
  i, j: Integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
        fItems[i][j].Color := Value;
end;

procedure TFLDataTable.SetColsCount(const Value: Integer);
var
  i, j: Integer;
begin
  if fColsCount = Value then
    Exit;

  if fColsCount > Value then
    for i := 0 to fRowsCount - 1 do
    begin
      for j := Value to fColsCount - 1 do
        if Assigned(fItems[i][j]) then
          fItems[i][j].Destroy;

      SetLength(fItems[i], Value);
    end
  else
    for i := 0 to fRowsCount - 1 do
      SetLength(fItems[i], Value);

  fColsCount := Value;
end;

procedure TFLDataTable.SetImagesHeight(const Value: Integer);
var
  i, j: Integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
        fItems[i][j].Height := Value;
end;

procedure TFLDataTable.SetImagesWidth(const Value: Integer);
var
  i, j: Integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
        fItems[i][j].Width := Value;
end;

procedure TFLDataTable.SetRowsCount(const Value: Integer);
var
  i, j: Integer;
begin
  if fRowsCount = Value then
    Exit;

  if fRowsCount > Value then
  begin
    for i := Value to fRowsCount - 1 do
      for j := 0 to fColsCount - 1 do
        if Assigned(fItems[i][j]) then
          fItems[i][j].Destroy;

    SetLength(fItems, Value);
  end
  else
  begin
    SetLength(fItems, Value);

    for i := fRowsCount to Value - 1 do
      SetLength(fItems[i], fColsCount);
  end;

  fRowsCount := Value;
end;

function TFLDataTable.GetColor: TColor;
var
  i, j: Integer;
begin
  Result := clBtnFace;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
      begin
        Result := fItems[i][j].Color;
        Exit;
      end;
end;

//--����������, �������� �� ������ ��������
//--������� ���������: ����� ���� � �������
function TFLDataTable.GetImagesHeight: Integer;
var
  i, j: Integer;
begin
  Result := 0;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
      begin
        Result := fItems[i][j].Height;
        Exit;
      end;
end;

function TFLDataTable.GetImagesWidth: Integer;
var
  i, j: Integer;
begin
  Result := 0;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
      begin
        Result := fItems[i][j].Width;
        Exit;
      end;
end;

function TFLDataTable.GetIsActive(RowNumber, ColNumber: integer): boolean;
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
function TFLPanel.GetDataPageByPageNumber(PageNumber: integer): TFLDataTable;
begin
  Result := GetCurrentDataPage;
  if PageNumber = 255 then
    Exit;
  Result := fDataCollection[PageNumber];
end;

//--�����������
//--������� ���������: ������������ ���������, ���-�� �������, ���-�� �������,
//--���-�� �����, ����� ����� ��������, ������ ������, ������ ������, ���� ������
constructor TFLPanel.Create(AOwner: TComponent; PagesCount: integer = 3;
  ColsCount: integer = 10; RowsCount: integer = 2; Padding: integer = 1;
  ButtonsWidth: integer = 32; ButtonsHeight: integer = 32; Color: TColor = clBtnFace);
var
  TempColor: TColor;
  i, j: integer;
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ParentBackground := false;
  TabStop := True;
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
  fFocusedButton := nil;
  fLastUsedButton := nil;
  fExpandStrings := true;
  {*--�������������� ��������� ������--*}
  fDataCollection := TFLDataCollection.Create;
  {**} for i := 0 to fPagesCount - 1 do
  {**}   fDataCollection.Add(TFLDataTable.Create(i, fColsCount, fRowsCount));
  {**} fCurrentDataIndex := 0;
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
  //--��������� ������������ ����� �� ������
  DragAcceptFiles(Handle, True);
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
  i, j: integer;
begin
  {*--���������� ��� ������--*}
  {**} for i := 0 to fRowsCount - 1 do
  {**}   for j := 0 to fColsCount - 1 do
  {**}     fButtons[i, j].Free;
  {**} SetLength(fButtons, 0, 0);
  {*--����������� ��������� ������--*}
  {**} fDataCollection.Free;
  {*--------------------------------*}
  inherited Destroy;
end;

//--������������� ������ ������
//--������� ���������: ����� ��������, ����� ������, ����� �������
procedure TFLPanel.InitializeDataItem(PageNumber, RowNumber, ColNumber: integer);
begin
  if PageNumber = fCurrentDataIndex then
    GetCurrentDataPage.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor)
  else
    GetDataPageByPageNumber(PageNumber).fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor);
end;

//--������ ������� ��� �������� ������
procedure TFLPanel.SwapData(PageNumber1, PageNumber2: integer);
var
  Page1, Page2: TFLDataTable;
  TempPageNumber: Integer;
begin
  //--���� �������� ������ 1
  Page1 := GetDataPageByPageNumber(PageNumber1);
  //--���� �������� ������ 2
  Page2 := GetDataPageByPageNumber(PageNumber2);
  {*--������ ����� ��������--*}
  {**} TempPageNumber := Page1.fPageNumber;
  {**} Page1.fPageNumber := Page2.fPageNumber;
  {**} Page2.fPageNumber := TempPageNumber;
  {*-------------------------*}
  Repaint;
end;

//--������� �������� ������
procedure TFLPanel.ClearPage(PageNumber: integer);
begin
  GetDataPageByPageNumber(PageNumber).Clear;
  Repaint;
end;

//--������� �������� ������
//--���������� ����� ��������, ������� ������ ����� �������� ����� ��������
function TFLPanel.DeletePage(PageNumber: integer): integer;
begin
  Result := PageNumber;
  if PageNumber = fPagesCount - 1 then
    Result := PageNumber - 1;
  {*--������� �� ������ �������� ������--*}
  fDataCollection.Delete(PageNumber);
  {*----------------------------------------------------------------------------------------------*}
  Dec(fPagesCount);
  SetPageNumber(Result);
end;

//--������� �������� ������
function TFLPanel.AddPage: integer;
begin
  Result := fPagesCount;
  {*-----------------------------------*}
  Result := fDataCollection.Add(TFLDataTable.Create(Result, fColsCount, fRowsCount));
  Inc(fPagesCount);
  SetPageNumber(Result);
end;

//--����������� ���� ������
procedure TFLPanel.FullRepaint;
var
  i, j: integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].Repaint;
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
function TFLPanel.GetCurButton(RowNumber, ColNumber: integer): TFLButton;
begin
  Result := fButtons[RowNumber][ColNumber];
end;

function TFLPanel.GetCurrentDataPage: TFLDataTable;
begin
  Result := fDataCollection[fCurrentDataIndex];
end;

//--���������� ������ �� �������� (������������ ��������)
//--������� ���������: ����� ��������, ���� � �������
function TFLPanel.GetButton(PageNumber, RowNumber, ColNumber: integer): TFLButton;
begin
  fCurrentDataIndex := PageNumber;
  fButtons[RowNumber][ColNumber].fCurPage := PageNumber;
  Result := fButtons[RowNumber][ColNumber];
end;

function TFLPanel.GetButtonHeight: Integer;
begin
  Result := fButtonHeight - 4;
end;

function TFLPanel.GetButtonWidth: Integer;
begin
  Result := fButtonWidth - 4;
end;

procedure TFLPanel.SetButtonColor(const Value: TColor);
var
  TempColor: TColor;
  DataTable: TFLDataTable;
  i, j: integer;
begin
  if fPanelColor = Value then
    Exit;

  fPanelColor := Value;
  if fPanelColor = clBtnFace then
    TempColor := GetSysColor(COLOR_BTNFACE)
  else
    TempColor := fPanelColor;
  fLColor := GetColorBetween(TempColor, clwhite, 85, 0, 100);
  fDColor1 := GetColorBetween(TempColor, clblack, 35, 0, 100);
  fDColor2 := GetColorBetween(TempColor, clblack, 55, 0, 100);

  for DataTable in fDataCollection do
    DataTable.Color := Value;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].Repaint;

  Repaint;
end;

procedure TFLPanel.SetButtonHeight(const Value: Integer);
var
  i, j: integer;
  DataTable: TFLDataTable;
begin
  if FButtonHeight = Value + 4 then
    Exit;

  FButtonHeight := Value + 4;

  for DataTable in fDataCollection do
    DataTable.ImagesHeight := FButtonHeight;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
    begin
      fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
      fButtons[i, j].Height := FButtonHeight;
    end;
end;

//--��������� ������������ ���� ��� ������
//--������� ��������: ������ �� ����
procedure TFLPanel.SetButtonsPopup(ButtonsPopup: TPopupMenu);
var
  i, j: integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      begin
        fButtons[i, j].PopupMenu := ButtonsPopup;
      end;
end;

procedure TFLPanel.SetButtonWidth(const Value: integer);
var
  i, j: integer;
  DataTable: TFLDataTable;
begin
  if FButtonWidth = Value + 4 then
    Exit;

  FButtonWidth := Value + 4;

  for DataTable in fDataCollection do
    DataTable.ImagesWidth := FButtonWidth;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
    begin
      fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
      fButtons[i, j].Width := FButtonWidth;
    end;
end;

procedure TFLPanel.SetColsCount(const Value: Integer);
var
  i, j: integer;
  DataTable: TFLDataTable;
begin
  if fColsCount = Value then
    Exit;

  for DataTable in fDataCollection do
    DataTable.ColsCount := Value;

  if fColsCount > Value then
    for i := 0 to fRowsCount - 1 do
    begin
      for j := Value to fColsCount - 1 do
        if Assigned(fButtons[i][j]) then
          fButtons[i][j].Free;

      SetLength(fButtons[i], Value);
    end
  else
    for i := 0 to fRowsCount - 1 do
    begin
      SetLength(fButtons[i], Value);

      for j := fColsCount to Value - 1 do
      begin
        fButtons[i, j] := TFLButton.Create(Self, i, j);

        fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
        fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
      end;
    end;

  fColsCount := Value;
end;

procedure TFLPanel.SetFocusedButton(const Value: TFLButton);
begin
  if Assigned(fFocusedButton) then
    fFocusedButton.Focused := False;
  if Assigned(Value) then
    Value.Focused := True;

  fFocusedButton := Value;
end;

procedure TFLPanel.SetPadding(const Value: Integer);
var
  i, j: integer;
begin
  FPadding := Value;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
    begin
      fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
      fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
    end;
end;

//--��������� ������ ������� ��������
//--������� ��������: ����� ��������
procedure TFLPanel.SetPageNumber(PageNumber: Integer);
var
  i, j: integer;
begin
  if fCurrentDataIndex = PageNumber then
    Exit;

  //--������������� ��������� �� ������� �������� ������ <- ��������� �� �������� � ��������� �������
  fCurrentDataIndex := PageNumber;
  if fCurrentDataIndex < 0 then
    fCurrentDataIndex := 0;

  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].fCurPage := fCurrentDataIndex;

  FocusedButton := nil;
  Repaint;
end;

procedure TFLPanel.SetPagesCount(const Value: Integer);
var
  i: Integer;
begin
  fDataCollection.Count := Value;

  for i := fPagesCount to Value - 1 do
    fDataCollection.Items[i] := TFLDataTable.Create(i, fColsCount, fRowsCount);

  fPagesCount := Value;
end;

procedure TFLPanel.SetRowsCount(const Value: Integer);
var
  i, j: integer;
  DataTable: TFLDataTable;
begin
  if fRowsCount = Value then
    Exit;

  for DataTable in fDataCollection do
    DataTable.RowsCount := Value;

  if fRowsCount > Value then
  begin
    for i := Value to fRowsCount - 1 do
      for j := 0 to fColsCount - 1 do
        if Assigned(fButtons[i][j]) then
          fButtons[i][j].Free;

    SetLength(fButtons, Value);
  end
  else
  begin
    SetLength(fButtons, Value);

    for i := fRowsCount to Value - 1 do
    begin
      SetLength(fButtons[i], fColsCount);

      for j := 0 to fColsCount - 1 do
      begin
        fButtons[i, j] := TFLButton.Create(Self, i, j);

        fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
        fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
      end;
    end;
  end;

  fRowsCount := Value;
end;

//--����� ������������ ��� �������������� ����� �� ������
procedure TFLPanel.WMDropFiles(var Msg: TWMDropFiles);
var
  buf: array[0..MAX_PATH] of char;
  Button: TFLButton;
begin
  if Assigned(fDropFile) then
  begin
    DragQueryFile(Msg.Drop, 0, buf, SizeOf(buf));
    Button := ControlAtPos(ScreenToClient(Mouse.CursorPos), False) as TFLButton;
    //--���������� ������� ������������ ������ OnDropFile, ��������� ������� ������ � ���� � �����
    fDropFile(Self, Button, buf);
    DragFinish(Msg.Drop);
  end;
end;

procedure TFLPanel.WMKillFocus(var Msg: TWMKillFocus);
begin
  FocusedButton := nil;
  inherited;
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
//--����� ���������� ��������� ������� ������ �� ���������, ��� ��������� ������ �� �������
//--����� ��������, ����� ���������� ��������� ����������� �������:
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
  //--���� ���� ������ � �������, �� �������� � ������
  if not Assigned(fFocusedButton) then
  begin
    FocusedButton := fButtons[0, 0];
  end
  else
  begin
    //--���� ������ ������� "����"
    if Key = vk_down then
      //--������ ����� ������, ����������� ����� (����������)
      FocusedButton :=
        fButtons[(fFocusedButton.RowNumber + 1) mod fRowsCount][fFocusedButton.ColNumber];
    //--���� ������ ������� "�����"
    if Key = vk_up then
      begin
        d := fFocusedButton.RowNumber - 1;
        if d < 0 then d := fRowsCount - 1;
        //--������ ����� ������, ����������� ������ (����������)
        FocusedButton := fButtons[d mod fRowsCount][fFocusedButton.ColNumber];
      end;
    //--���� ������ ������� "�����"
    if Key = vk_left then
      begin
        d := fFocusedButton.ColNumber - 1;
        if d < 0 then
        d := ColsCount - 1;
        //--������ ����� ������, ����������� ����� (����������)
        FocusedButton := fButtons[fFocusedButton.RowNumber][d mod fColsCount];
      end;
    //--���� ������ ������� "������"
    if Key = vk_right then
      //--������ ����� ������, ����������� ������ (����������)
      FocusedButton :=
        fButtons[fFocusedButton.RowNumber][(fFocusedButton.ColNumber + 1) mod fColsCount];
  end;

  fFocusedButton.KeyDown(Key, Shift);

  inherited KeyDown(Key, Shift);
end;

procedure TFLPanel.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Assigned(fFocusedButton) then
    fFocusedButton.KeyUp(Key, Shift);
end;

end.
