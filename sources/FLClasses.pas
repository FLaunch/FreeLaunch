{
  ##########################################################################
  #  FreeLaunch is a free links manager for Microsoft Windows              #
  #                                                                        #
  #  Copyright (C) 2026 Alexey Tatuyko <feedback@ta2i4.ru>                 #
  #  Copyright (C) 2021 Mykola Petrivskiy                                  #
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

unit FLClasses;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, Winapi.ShlObj, Winapi.ActiveX, Winapi.Messages,
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Menus, Vcl.Dialogs, VCL.Buttons,
  FLFunctions;

const
  IconCacheDir = 'IconCache';

type

  {*--Описание этих классов находится ниже--*}
  {**} TFLPanel = class;
  {**} TFLDataItem = class;
  {*----------------------------------------*}

  //--Класс кнопки на компоненте
  TFLButton = class(TSpeedButton)
    private
      //--Если 255, то используется текущая страница, иначе этот номер страницы
      fCurPage: Integer;
      //--Флаг, определяющий нажата ли в данный момент кнопка
      fPushed: boolean;
      //--Флаг, необходимый для предотвращения нажатия на кнопку при перетаскивании
      fCanClick: boolean;
      //--Номер строки и колонки данной кнопки
      fRowNumber, fColNumber: Integer;
      FFocused: Boolean;
      //--Возвращает ссылку на родительскую панель (read для свойства Father)
      function GetFather: TFLPanel;
      //--Возвращает данные (объект, рабочая папка и т.д.) для текущей кнопки текущей страницы (read для свойства Data)
      function GetDataItem: TFLDataItem;
      //--Является ли текущая кнопка текущей страницы активной (read для свойства IsActive)
      function GetIsActive: boolean;
      //--Установлена ли иконка на кнопке (read для свойства HasIcon)
      function GetHasIcon: boolean;
      //--Установлена ли иконка на кнопке (write для свойства HasIcon)
      procedure SetHasIcon(NewHasIcon: boolean);
      //--Метод генерируется при покидании курсора мыши кнопки
      procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      procedure SetFocused(const Value: Boolean);
    protected
      //--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
      procedure Paint; override;
      procedure RemoveHighlight;
    public
      //--Конструктор
      constructor Create(AOwner: TComponent; RowNumber, ColNumber: Integer); reintroduce;
      //--Деструктор
      destructor Destroy; override;
      //--Инициализация ячейки данных текущей кнопки текущей страницы
      function InitializeData: TFLDataItem;
      //--Освобождение ячейки данных текущей кнопки текущей страницы
      procedure FreeData;
      //--Ссылка на родительскую панель
      property Father: TFLPanel read GetFather;
      property CurPage: Integer read fCurPage;
      //--Номер строки и колонки данной кнопки
      property RowNumber: integer read fRowNumber;
      property ColNumber: integer read fColNumber;
      //--Ячейка данных (объект, рабочая папка и т.д.) текущей кнопки текущей страницы
      property Data: TFLDataItem read GetDataItem;
      //--Является ли кнопка активной (занятой чем-либо)
      property IsActive: boolean read GetIsActive;
      property Focused: Boolean read FFocused write SetFocused;
      //--Установлена ли иконка на кнопке
      property HasIcon: boolean read GetHasIcon write SetHasIcon;
      //--Метод генерируется при нажатии кнопки на клавиатуре
      procedure KeyDown(var Key: Word; Shift: TShiftState);
      //--Метод генерируется при "отжатии" кнопки на клавиатуре
      procedure KeyUp(var Key: Word; Shift: TShiftState);
      //--Метод генерируется при клике мышью
      procedure Click; override;
      //--Метод генерируется при нажатии кнопки мыши
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      //--Метод генерируется при "отжатии" кнопки мыши
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      //--Метод генерируется при движении мыши по кнопке
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      //--Метод генерируется при перетягивании на кнопку другого объекта
      procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
      //--Метод генерируется при отпускании перетягиваемого объекта
      procedure DragDrop(Source: TObject; X, Y: Integer); override;
      //--Метод генерируется при прекращении перетягивания объекта
      procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
      //--Метод генерируется при вызове контекстного меню
      procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
      /// <summary> Конвертация TFLDataItem в TLink </summary>
      function DataToLink: TLink;
      /// <summary> Конвертация TLink в TFLDataItem </summary>
      procedure LinkToData(const ALink: TLink);
      function Highlight: IInterface;
    published

  end;

  //--Класс описывает ячейку памяти, содержащую информацию о кнопке
  TFLDataItem = class
    private
      //--Ссылка на родительскую панель
      fFather: TFLPanel;
      {*--Поля свойств--*}
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
      FIsAdmin: Boolean;
      FASAdminPerm: Boolean;
      {*----------------*}
      //--Флаг, определяюший, установлена ли иконка
      fHasIcon: boolean;
      FHeight: Integer;
      FWidth: Integer;
      //--read для свойства Exec
      function GetExec: string;
      //--read для свойства WorkDir
      function GetWorkDir: string;
      //--read для свойства Icon
      function GetIcon: string;
      function GetIconCache: string;
      //--read для свойства Params
      function GetParams: string;
      //--read для свойства DropParams
      function GetDropParams: string;
      procedure SetHeight(const Value: Integer);
      procedure SetWidth(const Value: Integer);
    public
      //--Изображение иконки
      IconBmp: TBitMap;
      //--Изображение нажатой иконки
      PushedIconBmp: TBitMap;
      //--Конструктор
      constructor Create(ButtonWidth, ButtonHeight: integer);
      //--Деструктор
      destructor Destroy; override;
      //--Ссылка на родительскую панель
      property Father: TFLPanel read fFather write fFather;
      //--Функция генерирует иконки (обычную и "нажатую" для ячейки памяти)
      procedure AssignIcons;
      //--Тип кнопки (0 - исполняемый файл, 1 - файл, папка)
      property LType: integer read fLType write fLType;
      //--Путь к объекту
      property Exec: string read GetExec write fExec;
      //--Рабочая папка
      property WorkDir: string read GetWorkDir write fWorkDir;
      //--Путь к иконке
      property Icon: string read GetIcon write fIcon;
      //--Индекс иконки
      property IconIndex: integer read fIconIndex write fIconIndex;
      property IconCache: string read GetIconCache write fIconCache;
      //--Параметры
      property Params: string read GetParams write fParams;
      //--Принимать ли перетягиваемые файлы
      property DropFiles: boolean read fDropFiles write fDropFiles;
      //--Параметры (при перетягивании файла)
      property DropParams: string read GetDropParams write fDropParams;
      //--Описание
      property Descr: string read fDescr write fDescr;
      //--Спрашивать ли подтверждение при запуске
      property Ques: boolean read fQues write fQues;
      //--Скрывать ли окно FL при запуске
      property Hide: boolean read fHide write fHide;
      //--Приоритет запущенного процесса
      property Pr: integer read fPr write fPr;
      property IsAdmin: Boolean read FIsAdmin write FIsAdmin;
      property AsAdminPerm: Boolean read FAsAdminPerm write FASAdminPerm
        default False;
      //--Состояние окна
      property WSt: integer read fWSt write fWSt;
      property Height: Integer read FHeight write SetHeight;
      property Width: Integer read FWidth write SetWidth;
  end;

  //--Класс описывает страницу данных (матрица данных для кнопок одной вкладки)
  TFLDataTable = class
    private
      //--Размеры таблицы (кол-во колонок и строк)
      fColsCount, fRowsCount: integer;
      //--Номер страницы
      fPageNumber: integer;
      //--Ячейки данных
      fItems: array of array of TFLDataItem;
      //--Возвращает ячейку по индексам (read для Items)
      function GetItem(RowNumber, ColNumber: integer): TFLDataItem;
      //--Определяет, является ли ячейка активной (read для IsActive)
      function GetIsActive(RowNumber, ColNumber: integer): boolean;
      procedure SetColsCount(const Value: Integer);
      procedure SetRowsCount(const Value: Integer);
      function GetImagesHeight: Integer;
      function GetImagesWidth: Integer;
      procedure SetImagesHeight(const Value: Integer);
      procedure SetImagesWidth(const Value: Integer);
    public
      //--Конструктор
      constructor Create(PageNumber, ColsCount, RowsCount: integer);
      //--Деструктор
      destructor Destroy; override;
      //--Очищение всей страницы данных
      procedure Clear;
      //--Ячейка данных по ее индексам
      property Items[RowNumber, ColNumber: integer]: TFLDataItem read GetItem;
      //--Является ли ячейка активной
      property IsActive[RowNumber, ColNumber: integer]: boolean read GetIsActive;
      property ColsCount: Integer read FColsCount write SetColsCount;
      property RowsCount: Integer read FRowsCount write SetRowsCount;
      property ImagesWidth: Integer read GetImagesWidth write SetImagesWidth;
      property ImagesHeight: Integer read GetImagesHeight write SetImagesHeight;
  end;

  //--Коллекция данных - двусвязный список страниц данных ;)
  TFLDataCollection = TObjectList<TFLDataTable>;

  {*--Типы для создания событий--*}
  {**} TButtonClickEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseDownEvent = procedure(Sender: TObject; MouseButton: TMouseButton; Button: TFLButton) of object;
  {**} TButtonMouseMoveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseLeaveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TDropFileEvent = procedure(Sender: TObject; Button: TFLButton; FileName: string) of object;
  {*-----------------------------*}

  //--Главный класс. Описывает компонент - таблицу кнопок
  TFLPanel = class(TPanel)
    private
      //--Кол-во страниц, колонок и строк
      fPagesCount, fColsCount, fRowsCount: Integer;
      //--Ширина и высота кнопок
      fButtonWidth, fButtonHeight: integer;
      //--Зазор между кнопками
      fPadding: integer;
      //--Массив кнопок
      fButtons: array of array of TFLButton;
      //--Указатель на коллекцию данных
      fDataCollection: TFLDataCollection;
      //--Номер текущей страницы данных (активная страница)
      fCurrentDataIndex: Integer;
      //--Заменять ли в строковых параметрах в ячейках данных переменные FL_*
      fExpandStrings: boolean;
      {*-------------------*}
      //--Выполняется ли сейчас перетягивание кнопки
      fDragNow: boolean;
      //--Ссылка на кнопку с фокусом
      fFocusedButton: TFLButton;
      //--Ссылка на последнюю задействованную кнопку
      fLastUsedButton: TFLButton;
      //--Событие при клике по кнопке
      fButtonClick: TButtonClickEvent;
      //--Событие при нажатии кнопки мыши на кнопке
      fButtonMouseDown: TButtonMouseDownEvent;
      //--Событие при движении мыши
      fButtonMouseMove: TButtonMouseMoveEvent;
      //--Событие при покидании курсора мыши кнопки
      fButtonMouseLeave: TButtonMouseLeaveEvent;
      //--Событие при перетаскивании файла на кнопку
      fDropFile: TDropFileEvent;
      //--OLE drop target (Start Menu / Explorer shell DnD); kept alive while HWND exists
      fOleDropTarget: IDropTarget;
      //--Контекстное меню для кнопок
      fButtonsPopup: TPopupMenu;
      //--Номер страницы, на которой начали перетаскивать кнопку
      fDraggedButtonPageNumber: integer;
      //--Возвращает ссылку на последнюю перетаскиваемую кнопку (read для LastDraggedButton)
      function GetLastDraggedButton: TFLButton;
      //--Возвращает кнопку по индексам (текущая активная страница) (read для CurButtons)
      function GetCurButton(RowNumber, ColNumber: integer): TFLButton;
      //--Возвращает кнопку по индексам (произвольная страница) (read для Buttons)
      function GetButton(PageNumber, RowNumber, ColNumber: integer): TFLButton;
      //--Установка контекстного меню для кнопок (write для ButtonsPopup)
      procedure SetButtonsPopup(ButtonsPopup: TPopupMenu);
      //--Установка номера текущей страницы (write для PageNumber)
      procedure SetPageNumber(PageNumber: Integer);
      //--Метод генерируется при перетаскивании файла на кнопку
      procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
      //--Метод генерируется при потере кнопкой фокуса
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
      /// Resolve drop target button under screen coordinates (nearest empty preferred)
      function FindButtonForDrop(const AScreenPos: TPoint): TFLButton;
      /// Fire OnDropFile for a filesystem path at screen position
      procedure NotifyDropFile(const AFileName: string; const AScreenPos: TPoint);
      //--Определение актуального размера компонента (согласно количеству строк и колонок кнопок, а также их размера. write для ActualSize)
      function GetActualSize: TSize;
      //--Метод возвращает указатель на страницу данных по номеру страницы
      function GetDataPageByPageNumber(PageNumber: integer): TFLDataTable;
      //--Метод возвращает указатель на текущую страницу данных
      function GetCurrentDataPage: TFLDataTable;
      procedure SetColsCount(const Value: Integer);
      procedure SetPagesCount(const Value: Integer);
      procedure SetRowsCount(const Value: Integer);
      procedure SetButtonWidth(const Value: integer);
      procedure SetButtonHeight(const Value: Integer);
      procedure SetPadding(const Value: Integer);
      function GetButtonHeight: Integer;
      function GetButtonWidth: Integer;
      procedure SetFocusedButton(const Value: TFLButton);
      procedure UpdateSize;
    protected
      procedure CreateWnd; override;
      procedure DestroyWnd; override;
    public
      //--Конструктор
      constructor Create(AOwner: TComponent; PagesCount: integer = 3; ColsCount: integer = 10;
        RowsCount: integer = 2; Padding: integer = 1; ButtonsWidth: integer = 32; ButtonsHeight: integer = 32); reintroduce;
      //--Деструктор
      destructor Destroy; override;
      //--Инициализация ячейки данных
      procedure InitializeDataItem(PageNumber, RowNumber, ColNumber: integer);
      //--Меняет местами две страницы данных
      procedure SwapData(PageNumber1, PageNumber2: integer);
      //--Очищает страницу данных
      procedure ClearPage(PageNumber: integer);
      //--Удаляет страницу данных
      function DeletePage(PageNumber: integer): integer;
      //--Создает страницу данных
      function AddPage: integer;
      //--Перерисовка всех кнопок
      procedure FullRepaint;
      //--Заменять ли в строковых параметрах в ячейках данных переменные FL_*
      property ExpandStrings: boolean read fExpandStrings write fExpandStrings;
      //--Ссылка на кнопку с фокусом
      property FocusedButton: TFLButton read fFocusedButton write SetFocusedButton;
      //--Ссылка на последнюю задействованную кнопку
      property LastUsedButton: TFLButton read fLastUsedButton;
      //--Кол-во страниц, колонок и строк
      property PagesCount: Integer read fPagesCount write SetPagesCount;
      property ColsCount: Integer read fColsCount write SetColsCount;
      property RowsCount: Integer read fRowsCount write SetRowsCount;
      property ButtonWidth: Integer read GetButtonWidth write SetButtonWidth;
      property ButtonHeight: Integer read GetButtonHeight write SetButtonHeight;
      property Padding: Integer read FPadding write SetPadding;
      //--Кнопка по ее индексам (текущая активная страница)
      property CurButtons[RowNumber, ColNumber: integer]: TFLButton read GetCurButton;
      //--Кнопка по ее индексам (произвольная страница)
      //--После доступа сразу НЕОБХОДИМО выполнить один из следующих свойств/методов:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--Проще говоря, только доступ/операции с данными
      //--Например: Buttons[0, 0, 0].IsActive
      property Buttons[PageNumber, RowNumber, ColNumber: integer]: TFLButton read GetButton;
      //--Последняя перетаскиваемая кнопка
      //--После доступа сразу НЕОБХОДИМО выполнить один из следующих свойств/методов:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--Проще говоря, только доступ/операции с данными
      //--Например: Buttons[0, 0, 0].IsActive
      property LastDraggedButton: TFLButton read GetLastDraggedButton;
      //--Номер текущей страницы
      property PageNumber: Integer read fCurrentDataIndex write SetPageNumber;
      //--Актуальный размер компонента
      property ActualSize: TSize read GetActualSize;
      //--Контекстное меню для кнопок
      property ButtonsPopup: TPopupMenu read fButtonsPopup write SetButtonsPopup;
      //--Метод генерируется при "отжатии" кнопки на клавиатуре
      procedure KeyUp(var Key: Word; Shift: TShiftState); override;
      //--Метод генерируется при нажатии кнопки на клавиатуре
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
      //--Событие при клике по кнопке
      property OnButtonClick: TButtonClickEvent read fButtonClick write fButtonClick;
      //--Событие при нажатии кнопки мыши на кнопке
      property OnButtonMouseDown: TButtonMouseDownEvent read fButtonMouseDown write fButtonMouseDown;
      //--Событие при движении мыши
      property OnButtonMouseMove: TButtonMouseMoveEvent read fButtonMouseMove write fButtonMouseMove;
      //--Событие при покидании курсора мыши кнопки
      property OnButtonMouseLeave: TButtonMouseLeaveEvent read fButtonMouseLeave write fButtonMouseLeave;
      //--Событие при перетаскивании файла на кнопку
      property OnDropFile: TDropFileEvent read fDropFile write fDropFile;
    published

  end;

implementation

uses
  System.IOUtils, System.StrUtils, Winapi.PropSys,
  FLaunchMainFormModule;

const
  FLDropTempDirName = 'FreeLaunchDrop';

type
  /// OLE IDropTarget for Explorer / Start Menu drops.
  /// Accepts filesystem paths only (regular .lnk / files); UWP later.
  TFLOleDropTarget = class(TInterfacedObject, IDropTarget)
  private
    FPanel: TFLPanel;
    FCanAccept: Boolean;
    FLastEffect: Longint;
    class function SelectDropEffect(Available: Longint): Longint; static;
    class function PathIsDroppable(const APath: string): Boolean; static;
    class function AcceptResolvedTarget(const APath: string;
      out FileName: string): Boolean; static;
    class function TryPathFromShellItem(const Item: IShellItem;
      out FileName: string): Boolean; static;
    class function TryExtractFileContents(const DataObj: IDataObject;
      out FileName: string): Boolean; static;
    function ExtractDropPath(const DataObj: IDataObject; out FileName: string): Boolean;
  public
    constructor Create(APanel: TFLPanel);
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;

{ TFLOleDropTarget }

constructor TFLOleDropTarget.Create(APanel: TFLPanel);
begin
  inherited Create;
  FPanel := APanel;
end;

class function TFLOleDropTarget.SelectDropEffect(Available: Longint): Longint;
begin
  // Start Menu / shortcuts often offer LINK only — COPY-only reject breaks drop
  if (Available and DROPEFFECT_COPY) <> 0 then
    Result := DROPEFFECT_COPY
  else if (Available and DROPEFFECT_LINK) <> 0 then
    Result := DROPEFFECT_LINK
  else if (Available and DROPEFFECT_MOVE) <> 0 then
    Result := DROPEFFECT_MOVE
  else
    Result := DROPEFFECT_NONE;
end;

class function TFLOleDropTarget.PathIsDroppable(const APath: string): Boolean;
begin
  Result := (APath <> '') and
    (not LooksLikeAppUserModelId(APath)) and
    FsPathExists(APath);
end;

class function TFLOleDropTarget.AcceptResolvedTarget(const APath: string;
  out FileName: string): Boolean;
var
  Expanded, AppsTarget, Resolved: string;

  function IsBadToastAumid(const S: string): Boolean;
  begin
    // Delphi/RAD Studio Start tiles sometimes expose the toast helper AUMID
    Result := ContainsText(S, 'DesktopToasts');
  end;

begin
  Result := False;
  FileName := '';
  if Trim(APath) = '' then
    Exit;

  // Store / AppsFolder apps (Excel, Armoury Crate, many Yandex builds): no Win32 path
  AppsTarget := '';
  if LooksLikeAppUserModelId(APath) then
    AppsTarget := 'shell:AppsFolder\' + APath
  else if SameText(Copy(APath, 1, Length('shell:AppsFolder\')), 'shell:AppsFolder\') then
    AppsTarget := APath;
  if AppsTarget <> '' then
  begin
    if IsBadToastAumid(AppsTarget) then
      Exit;
    if ObjectExists(AppsTarget) then
    begin
      FileName := AppsTarget;
      Exit(True);
    end;
    Exit;
  end;

  // Prefer a path that actually exists (ProgramW6432 remap for 32-bit Shell).
  // Keep the filesystem path — known-folder GUID form is cryptic in Properties
  // (Desktop\file.lnk → ::{B4BFCC3A-…}\file.lnk).
  Resolved := ResolveExistingFsPath(APath);
  if Resolved <> '' then
  begin
    FileName := Resolved;
    Exit(True);
  end;

  Expanded := APath;
  try
    Expanded := ExpandEnvironmentVariables(APath);
  except
    Expanded := APath;
  end;
  if Expanded <> APath then
  begin
    Resolved := ResolveExistingFsPath(Expanded);
    if Resolved <> '' then
    begin
      // Keep env-var form when possible; else store resolved filesystem path
      if Pos('%', APath) > 0 then
        FileName := APath
      else
        FileName := Resolved;
      Exit(True);
    end;
  end;

  if LooksLikeShellGuidPath(APath) and ObjectExists(APath) then
  begin
    FileName := APath;
    Exit(True);
  end;
end;

class function TFLOleDropTarget.TryPathFromShellItem(const Item: IShellItem;
  out FileName: string): Boolean;
var
  Name: PWideChar;
  Attr: DWORD;
  LinkTarget: IShellItem;
  ShellLink: IShellLink;
  Item2: IShellItem2;
  Buf: array[0..MAX_PATH] of Char;
  FindData: TWin32FindData;
  Pidl: PItemIDList;
  PropKey: TPropertyKey;
  PropStr: LPWSTR;
  Candidate: string;
  DisplayHint, AumidHint: string;
  PropNames: array[0..5] of string;
  I: Integer;

  function TakeFileSysName(const AItem: IShellItem): Boolean;
  var
    N: PWideChar;
  begin
    Result := False;
    N := nil;
    if Failed(AItem.GetDisplayName(SIGDN_FILESYSPATH, N)) or (N = nil) then
      Exit;
    try
      Result := AcceptResolvedTarget(N, FileName);
    finally
      CoTaskMemFree(N);
    end;
  end;

  function TryShellLink(const Link: IShellLink): Boolean;
  begin
    Result := False;
    if Link = nil then
      Exit;
    // Do not call IShellLink.Resolve here: when the 32-bit Shell rewrites the
    // target to a missing Program Files (x86) path (AmneziaVPN etc.), Resolve
    // searches the disk/network for a long time and freezes DragEnter.
    FillChar(Buf, SizeOf(Buf), 0);
    FillChar(FindData, SizeOf(FindData), 0);
    if Succeeded(Link.GetPath(Buf, Length(Buf), FindData, SLGP_RAWPATH)) and
      AcceptResolvedTarget(Buf, FileName) then
      Exit(True);
    FillChar(Buf, SizeOf(Buf), 0);
    if Succeeded(Link.GetPath(Buf, Length(Buf), FindData, 0)) and
      AcceptResolvedTarget(Buf, FileName) then
      Exit(True);
    Pidl := nil;
    if Succeeded(Link.GetIDList(Pidl)) and (Pidl <> nil) then
    try
      Name := nil;
      if Succeeded(SHGetNameFromIDList(Pidl,
        Integer(Cardinal(SIGDN_FILESYSPATH)), Name)) and (Name <> nil) then
      try
        Result := AcceptResolvedTarget(Name, FileName);
      finally
        CoTaskMemFree(Name);
      end;
      if Result then
        Exit;
      Name := nil;
      if Succeeded(SHGetNameFromIDList(Pidl,
        Integer(Cardinal(SIGDN_DESKTOPABSOLUTEPARSING)), Name)) and
        (Name <> nil) then
      try
        Result := AcceptResolvedTarget(Name, FileName);
      finally
        CoTaskMemFree(Name);
      end;
    finally
      CoTaskMemFree(Pidl);
    end;
  end;

begin
  Result := False;
  FileName := '';
  if Item = nil then
    Exit;

  // 1) Item is a real file/folder (typical .lnk under Start Menu\Programs)
  if TakeFileSysName(Item) then
    Exit(True);

  // 2) Shortcut → resolve link target item
  Attr := 0;
  if Succeeded(Item.GetAttributes(SFGAO_LINK, Attr)) and
    ((Attr and SFGAO_LINK) <> 0) then
  begin
    LinkTarget := nil;
    if Succeeded(Item.BindToHandler(nil, BHID_LinkTargetItem, IID_IShellItem,
      LinkTarget)) and (LinkTarget <> nil) then
      if TakeFileSysName(LinkTarget) then
        Exit(True);
  end;

  // 3) IShellLink via UI object / folder object
  ShellLink := nil;
  if Succeeded(Item.BindToHandler(nil, BHID_SFUIObject, IID_IShellLink, ShellLink)) and
    TryShellLink(ShellLink) then
    Exit(True);
  ShellLink := nil;
  if Succeeded(Item.BindToHandler(nil, BHID_SFObject, IID_IShellLink, ShellLink)) and
    TryShellLink(ShellLink) then
    Exit(True);

  // 4) Property store: filesystem / URL targets first.
  // Defer AppUserModelID / AppsFolder — Win32 apps like PuTTY often expose an
  // AUMID that resolves to AppsFolder with a generic icon, while a real
  // Start Menu .lnk still exists (PuTTY.lnk → putty.exe).
  PropNames[0] := 'System.Link.TargetParsingPath';
  PropNames[1] := 'System.ParsingPath';
  PropNames[2] := 'System.ItemPathDisplay';
  PropNames[3] := 'System.AppUserModel.RelaunchCommand';
  PropNames[4] := 'System.Link.TargetUrl';
  PropNames[5] := 'System.AppUserModel.ID';
  DisplayHint := '';
  AumidHint := '';
  Item2 := nil;
  if Supports(Item, IShellItem2, Item2) then
  begin
    for I := Low(PropNames) to High(PropNames) do
    begin
      if Failed(PSGetPropertyKeyFromName(PWideChar(PropNames[I]), PropKey)) then
        Continue;
      PropStr := nil;
      if Failed(Item2.GetString(PropKey, PropStr)) or (PropStr = nil) then
        Continue;
      try
        Candidate := Trim(PropStr);
        if Candidate = '' then
          Continue;
        // Collect AUMID / AppsFolder for later; do not accept yet
        if SameText(PropNames[I], 'System.AppUserModel.ID') or
          LooksLikeAppUserModelId(Candidate) or
          StartsText('shell:AppsFolder\', Candidate) then
        begin
          if AumidHint = '' then
          begin
            if StartsText('shell:AppsFolder\', Candidate) then
              AumidHint := Copy(Candidate, Length('shell:AppsFolder\') + 1, MaxInt)
            else
              AumidHint := Candidate;
          end;
          Continue;
        end;
        // RelaunchCommand may be: "C:\Path\app.exe" arg1
        if (Length(Candidate) > 0) and (Candidate[1] = '"') then
        begin
          Candidate := Copy(Candidate, 2, MaxInt);
          if Pos('"', Candidate) > 0 then
            Candidate := Copy(Candidate, 1, Pos('"', Candidate) - 1);
        end
        else if Pos(' ', Candidate) > 0 then
          Candidate := Copy(Candidate, 1, Pos(' ', Candidate) - 1);
        if AcceptResolvedTarget(Candidate, FileName) then
          Exit(True);
      finally
        CoTaskMemFree(PropStr);
      end;
    end;
  end;

  // 5) GUID / shell: parsing names — skip AppsFolder / bare AUMID (handled below)
  Name := nil;
  if Succeeded(Item.GetDisplayName(SIGDN_DESKTOPABSOLUTEPARSING, Name)) and
    (Name <> nil) then
  try
    Candidate := Trim(Name);
    if LooksLikeAppUserModelId(Candidate) then
    begin
      if AumidHint = '' then
        AumidHint := Candidate;
    end
    else if StartsText('shell:AppsFolder\', Candidate) then
    begin
      if AumidHint = '' then
        AumidHint := Copy(Candidate, Length('shell:AppsFolder\') + 1, MaxInt);
    end
    else if AcceptResolvedTarget(Candidate, FileName) then
      Exit(True);
  finally
    CoTaskMemFree(Name);
  end;

  // 6) Prefer a real Start Menu / Desktop .lnk over AppsFolder (correct icons)
  Name := nil;
  if Succeeded(Item.GetDisplayName(SIGDN_NORMALDISPLAY, Name)) and (Name <> nil) then
  try
    DisplayHint := Trim(Name);
  finally
    CoTaskMemFree(Name);
  end;
  Candidate := FindStartMenuShortcutByName(DisplayHint, AumidHint);
  if AcceptResolvedTarget(Candidate, FileName) then
    Exit(True);

  // 7) Last resort: Store / AppsFolder app (Excel, Armoury Crate, …)
  if AumidHint <> '' then
  begin
    if LooksLikeAppUserModelId(AumidHint) then
      Candidate := 'shell:AppsFolder\' + AumidHint
    else
      Candidate := AumidHint;
    if AcceptResolvedTarget(Candidate, FileName) then
      Exit(True);
  end;
end;

class function TFLOleDropTarget.TryExtractFileContents(const DataObj: IDataObject;
  out FileName: string): Boolean;
var
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  Group: PFileGroupDescriptorW;
  Stream: IStream;
  TempDir, DestName, DestPath: string;
  FS: TFileStream;
  BytesRead: FixedUInt;
  Buf: array[0..8191] of Byte;
  HGlob: HGLOBAL;
  P: Pointer;
  Size, Done: NativeUInt;
  Chunk: Longint;
begin
  Result := False;
  FileName := '';
  if DataObj = nil then
    Exit;

  FillChar(FormatEtc, SizeOf(FormatEtc), 0);
  FormatEtc.cfFormat := RegisterClipboardFormat(CFSTR_FILEDESCRIPTORW);
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := -1;
  FormatEtc.tymed := TYMED_HGLOBAL;
  if Failed(DataObj.GetData(FormatEtc, Medium)) then
    Exit;
  try
    if Medium.tymed <> TYMED_HGLOBAL then
      Exit;
    Group := GlobalLock(Medium.hGlobal);
    if (Group = nil) or (Group.cItems < 1) then
      Exit;
    try
      DestName := Group.fgd[0].cFileName;
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  finally
    ReleaseStgMedium(Medium);
  end;

  DestName := ExtractFileName(DestName);
  if DestName = '' then
    DestName := 'drop.lnk';

  TempDir := TPath.Combine(TPath.GetTempPath, FLDropTempDirName);
  ForceDirectories(TempDir);
  DestPath := TPath.Combine(TempDir, DestName);
  if FileExists(DestPath) then
    DeleteFile(DestPath);

  FillChar(FormatEtc, SizeOf(FormatEtc), 0);
  FormatEtc.cfFormat := RegisterClipboardFormat(CFSTR_FILECONTENTS);
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := 0; // first file in the group
  FormatEtc.tymed := TYMED_ISTREAM or TYMED_HGLOBAL;
  if Failed(DataObj.GetData(FormatEtc, Medium)) then
    Exit;
  try
    if Medium.tymed = TYMED_ISTREAM then
    begin
      Stream := IStream(Medium.stm);
      if Stream = nil then
        Exit;
      FS := TFileStream.Create(DestPath, fmCreate);
      try
        repeat
          BytesRead := 0;
          if Failed(Stream.Read(@Buf[0], SizeOf(Buf), @BytesRead)) then
            Break;
          if BytesRead > 0 then
            FS.WriteBuffer(Buf[0], BytesRead);
        until BytesRead = 0;
      finally
        FS.Free;
      end;
    end
    else if Medium.tymed = TYMED_HGLOBAL then
    begin
      HGlob := Medium.hGlobal;
      Size := GlobalSize(HGlob);
      P := GlobalLock(HGlob);
      if (P = nil) or (Size = 0) then
        Exit;
      try
        FS := TFileStream.Create(DestPath, fmCreate);
        try
          Done := 0;
          while Done < Size do
          begin
            Chunk := Size - Done;
            if Chunk > SizeOf(Buf) then
              Chunk := SizeOf(Buf);
            Move(Pointer(NativeUInt(P) + Done)^, Buf[0], Chunk);
            FS.WriteBuffer(Buf[0], Chunk);
            Inc(Done, NativeUInt(Chunk));
          end;
        finally
          FS.Free;
        end;
      finally
        GlobalUnlock(HGlob);
      end;
    end
    else
      Exit;
  finally
    ReleaseStgMedium(Medium);
  end;

  if PathIsDroppable(DestPath) then
  begin
    FileName := DestPath;
    Result := True;
  end
  else if FileExists(DestPath) then
    DeleteFile(DestPath);
end;

function TFLOleDropTarget.ExtractDropPath(const DataObj: IDataObject;
  out FileName: string): Boolean;
var
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  Buf: array[0..MAX_PATH] of Char;
  PCida: PIDA;
  Offsets: PUINT;
  FolderPidl, ItemPidl, AbsolutePidl: PItemIDList;
  Len: UINT;
  Raw: Pointer;
  ItemArray: IShellItemArray;
  Item: IShellItem;
  Count: DWORD;
  ShellItem: IShellItem;
  Candidate: string;
begin
  Result := False;
  FileName := '';
  if DataObj = nil then
    Exit;

  // 1) CF_HDROP
  FillChar(FormatEtc, SizeOf(FormatEtc), 0);
  FormatEtc.cfFormat := CF_HDROP;
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := -1;
  FormatEtc.tymed := TYMED_HGLOBAL;
  if Succeeded(DataObj.GetData(FormatEtc, Medium)) then
  try
    if Medium.tymed = TYMED_HGLOBAL then
    begin
      Len := DragQueryFile(Medium.hGlobal, 0, Buf, Length(Buf));
      if Len > 0 then
      begin
        SetString(Candidate, Buf, Len);
        if AcceptResolvedTarget(Candidate, FileName) then
          Exit(True);
      end;
    end;
  finally
    ReleaseStgMedium(Medium);
  end;

  // 2) FileNameW
  FillChar(FormatEtc, SizeOf(FormatEtc), 0);
  FormatEtc.cfFormat := RegisterClipboardFormat(CFSTR_FILENAMEW);
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := -1;
  FormatEtc.tymed := TYMED_HGLOBAL;
  if Succeeded(DataObj.GetData(FormatEtc, Medium)) then
  try
    if (Medium.tymed = TYMED_HGLOBAL) and (Medium.hGlobal <> 0) then
    begin
      Candidate := PWideChar(GlobalLock(Medium.hGlobal));
      GlobalUnlock(Medium.hGlobal);
      if AcceptResolvedTarget(Candidate, FileName) then
        Exit(True);
    end;
  finally
    ReleaseStgMedium(Medium);
  end;

  // 3) FileGroupDescriptor + FileContents (virtual .lnk from Start Menu)
  if TryExtractFileContents(DataObj, FileName) then
    Exit(True);

  // 4) Shell IDList
  FillChar(FormatEtc, SizeOf(FormatEtc), 0);
  FormatEtc.cfFormat := RegisterClipboardFormat(CFSTR_SHELLIDLIST);
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := -1;
  FormatEtc.tymed := TYMED_HGLOBAL;
  if Succeeded(DataObj.GetData(FormatEtc, Medium)) then
  try
    if Medium.tymed = TYMED_HGLOBAL then
    begin
      PCida := GlobalLock(Medium.hGlobal);
      if PCida <> nil then
      try
        if PCida.cidl >= 1 then
        begin
          Offsets := @PCida.aoffset[0];
          FolderPidl := PItemIDList(NativeUInt(PCida) + Offsets^);
          Inc(Offsets);
          ItemPidl := PItemIDList(NativeUInt(PCida) + Offsets^);
          AbsolutePidl := ILCombine(FolderPidl, ItemPidl);
          if AbsolutePidl <> nil then
          try
            FillChar(Buf, SizeOf(Buf), 0);
            if SHGetPathFromIDList(AbsolutePidl, Buf) and
              AcceptResolvedTarget(Buf, FileName) then
              Exit(True);
            ShellItem := nil;
            if Succeeded(SHCreateItemFromIDList(AbsolutePidl, IID_IShellItem,
              ShellItem)) and TryPathFromShellItem(ShellItem, FileName) then
              Exit(True);
          finally
            ILFree(AbsolutePidl);
          end;
        end;
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
    end;
  finally
    ReleaseStgMedium(Medium);
  end;

  // 5) IShellItemArray (resolve via link/properties; reject bare AUMID)
  Raw := nil;
  if Succeeded(SHCreateShellItemArrayFromDataObject(DataObj, IID_IShellItemArray, Raw)) and
    (Raw <> nil) then
  begin
    ItemArray := IShellItemArray(Raw);
    Count := 0;
    if Succeeded(ItemArray.GetCount(Count)) and (Count > 0) then
    begin
      Item := nil;
      if Succeeded(ItemArray.GetItemAt(0, Item)) and
        TryPathFromShellItem(Item, FileName) then
        Exit(True);
    end;
  end;
end;

function TFLOleDropTarget.DragEnter(const dataObj: IDataObject;
  grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult;
var
  Dummy: string;
begin
  // Cursor must match Drop: only accept when a real path/.lnk can be extracted now
  FCanAccept := ExtractDropPath(dataObj, Dummy);
  if FCanAccept and (FPanel.FindButtonForDrop(pt) <> nil) then
  begin
    FLastEffect := SelectDropEffect(dwEffect);
    dwEffect := FLastEffect;
  end
  else
  begin
    FLastEffect := DROPEFFECT_NONE;
    dwEffect := DROPEFFECT_NONE;
  end;
  Result := S_OK;
end;

function TFLOleDropTarget.DragOver(grfKeyState: Longint; pt: TPoint;
  var dwEffect: Longint): HResult;
begin
  if FCanAccept and (FPanel.FindButtonForDrop(pt) <> nil) then
  begin
    FLastEffect := SelectDropEffect(dwEffect);
    dwEffect := FLastEffect;
  end
  else
  begin
    FLastEffect := DROPEFFECT_NONE;
    dwEffect := DROPEFFECT_NONE;
  end;
  Result := S_OK;
end;

function TFLOleDropTarget.DragLeave: HResult;
begin
  FCanAccept := False;
  FLastEffect := DROPEFFECT_NONE;
  Result := S_OK;
end;

function TFLOleDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Longint;
  pt: TPoint; var dwEffect: Longint): HResult;
var
  FileName: string;
  Effect: Longint;
begin
  Result := S_OK;
  Effect := SelectDropEffect(dwEffect);
  dwEffect := DROPEFFECT_NONE;
  if not ExtractDropPath(dataObj, FileName) then
    Exit;
  if FPanel.FindButtonForDrop(pt) = nil then
    Exit;
  FPanel.NotifyDropFile(FileName, pt);
  dwEffect := Effect;
end;

{*******************************}
{*****-- Класс TFLButton --*****}
{*******************************}

//--Конструктор класса
//--Входные параметры: родительский компонент, номер ряда, номер колонки
constructor TFLButton.Create(AOwner: TComponent; RowNumber, ColNumber: integer);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  Width := Father.fButtonWidth;
  Height := Father.fButtonHeight;
  Flat := True;
  fRowNumber := RowNumber;
  fColNumber := ColNumber;
  fPushed := false;
  fCanClick := true;
  fCurPage := 255;
  ShowHint := False;
end;

function TFLButton.DataToLink: TLink;
var
  TmpData: TFLDataItem;
begin
  Father.ExpandStrings := False;
  try
    Result.active := IsActive;
    TmpData := GetDataItem;
    if Assigned(TmpData) then
    begin
      Result.ltype := TmpData.LType;
      Result.exec := TmpData.Exec;
      Result.workdir := TmpData.WorkDir;
      Result.icon := TmpData.Icon;
      Result.iconindex := TmpData.IconIndex;
      Result.params := TmpData.Params;
      Result.dropfiles := TmpData.DropFiles;
      Result.dropparams := TmpData.DropParams;
      Result.descr := TmpData.Descr;
      Result.ques := TmpData.Ques;
      Result.hide := TmpData.Hide;
      Result.pr := TmpData.Pr;
      Result.wst := TmpData.WSt;
      Result.IsAdmin := TmpData.IsAdmin;
      Result.AsAdminPerm := TmpData.AsAdminPerm;
    end;
  finally
    Father.ExpandStrings := True;
  end;
end;

//--Деструктор класса
destructor TFLButton.Destroy;
begin
  inherited Destroy;
end;

//--Инициализация ячейки данных текущей кнопки текущей страницы
function TFLButton.InitializeData: TFLDataItem;
begin
  if not Assigned(Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber]) then
    Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber] :=
      TFLDataItem.Create(Father.fButtonWidth, Father.fButtonHeight);

  Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber].Father := Father;
  Result := Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber];
end;

//--Освобождение ячейки данных текущей кнопки текущей страницы
procedure TFLButton.FreeData;
var
  Item: TFLDataItem;
begin
  Item := Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber];
  if Assigned(Item) then
  begin
    // If button data is explicitly removed by user/action, remove its cache file.
    if TFile.Exists(Item.IconCache) then
      TFile.Delete(Item.IconCache);
    Item.IconCache := '';
  end;
  FreeAndNil(Father.GetDataPageByPageNumber(fCurPage).fItems[fRowNumber, fColNumber]);
  Invalidate;
end;

//--Возвращает ссылку на родительскую панель
function TFLButton.GetFather: TFLPanel;
begin
  Result := Parent as TFLPanel;
end;

procedure TFLButton.SetFocused(const Value: Boolean);
begin
  FFocused := Value;

  if FFocused then
    //--Иммитируем движение мыши по кнопке
    Perform(CM_MOUSEENTER, 0, 0)
  else
    Perform(CM_MOUSELEAVE, 0, 0);
end;

//--Возвращает данные (объект, рабочая папка и т.д.) для текущей кнопки текущей страницы
function TFLButton.GetDataItem: TFLDataItem;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Данные ячейки [fRowNumber, fColNumber] (совпадающие с координатами кнопки)
  Result := Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber];
end;

//--Является ли текущая кнопка текущей страницы активной
function TFLButton.GetIsActive: boolean;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Является ли ячейка активной
  Result := Father.GetDataPageByPageNumber(fCurPage).IsActive[fRowNumber, fColNumber];
end;

type
  THighlightRemover = class(TInterfacedObject)
    FButton: TFLButton;
    constructor Create(AButton: TFLButton);
    destructor Destroy; override;
  end;

function TFLButton.Highlight: IInterface;
begin
  FState := bsExclusive;
  Invalidate;
  Result := THighlightRemover.Create(Self);
end;

//--Установлена ли иконка на кнопке
function TFLButton.GetHasIcon: boolean;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Ячейка данных с координатами [fRowNumber, fColNumber] -> Имеет ли иконку
  Result := Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber].fHasIcon;
end;

//--Установлена ли иконка на кнопке
procedure TFLButton.SetHasIcon(NewHasIcon: boolean);
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Ячейка данных с координатами [fRowNumber, fColNumber] -> Имеет ли иконку
  Father.GetDataPageByPageNumber(fCurPage).Items[fRowNumber, fColNumber].fHasIcon := NewHasIcon;
end;

//--Метод генерируется при покидании курсора мыши кнопки
procedure TFLButton.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  //--Генерируем событие родительской панели OnButtonMouseLeave, передавая текущую кнопку
  if Assigned(Father.fButtonMouseLeave)
  then Father.fButtonMouseLeave(Father, Self);
end;

//--Метод генерируется при нажатии кнопки на клавиатуре
//--Обрабатываем нажатие здесь клавиши Enter
procedure TFLButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    MouseDown(mbLeft, [], 0, 0);
end;

//--Метод генерируется при "отжатии" кнопки на клавиатуре
//--См. описание к KeyDown
procedure TFLButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    begin
      MouseUp(mbLeft, [], 0, 0);
    end;
end;

procedure TFLButton.LinkToData(const ALink: TLink);
var
  TmpData: TFLDataItem;
begin
  if ALink.active then
  begin
    TmpData := InitializeData;
    TmpData.LType := ALink.ltype;
    TmpData.Exec := ALink.exec;
    TmpData.WorkDir := ALink.workdir;
    TmpData.Icon := ALink.icon;
    TmpData.IconIndex := ALink.iconindex;
    TmpData.Params := ALink.params;
    TmpData.DropFiles := ALink.dropfiles;
    TmpData.DropParams := ALink.dropparams;
    TmpData.Descr := ALink.descr;
    TmpData.Ques := ALink.ques;
    TmpData.Hide := ALink.hide;
    TmpData.Pr := ALink.pr;
    TmpData.WSt := ALink.wst;
    TmpData.FIsAdmin := ALink.IsAdmin;
    TmpData.AssignIcons;
    Invalidate;
  end
  else
    FreeData;
end;

//--Метод генерируется при клике мышью
procedure TFLButton.Click;
begin
  //--Если клик в данный момент возможен
  //--А невозможен он тогда, когда мы хотим перетащить кнопку с зажатым Ctrl
  //--Иначе при отпускании кнопки мыши генерировался бы клик
  if fCanClick then
    begin
      //--Устанавливаем ссылку на последнюю использованную кнопку <- текущую кнопку
      Father.fLastUsedButton := Self;
      //--Генерируем событие родительской панели OnButtonClick, передавая ссылку на текущую кнопку
      if Assigned(Father.fButtonClick) then Father.fButtonClick(Father, Self);
      inherited Click;
    end;
end;

//--Метод генерируется при нажатии кнопки мыши
procedure TFLButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  //--Если кнопка мыши - левая
  if button = mbLeft then begin
    //--Если зажат Ctrl
    if (ssCtrl in Shift) then begin
      //--Запрещаем генерацию клика по этой кнопке
      fCanClick := false;
      //--Начинаем перетаскивать кнопку
      BeginDrag(false);
      Father.fDragNow := true;
      //--Запоминаем номер страницы, на которой начали перетаскивать кнопку
      Father.fDraggedButtonPageNumber := Father.fCurrentDataIndex;
      //--Устанавливаем ссылку на последнюю использованную кнопку <- текущую кнопку
      Father.fLastUsedButton := Self;
      //--Перерисовываем (чтобы появилась рамка)
      FState := bsDown;
      Invalidate;
    end else begin
      //--Если Ctrl зажат не был, делаем кноку нажатой
      fPushed := true;
      //--Устанавливаем ссылку на последнюю использованную кнопку <- текущую кнопку
      Father.fLastUsedButton := Self;
    end;
  end;
  //--Генерируем событие родительской панели OnButtonMouseDown, передавая ссылку на текущую кнопку
  if Assigned(Father.fButtonMouseDown)
    then Father.fButtonMouseDown(Father, Button, Self);
end;

//--Метод генерируется при "отжатии" кнопки мыши
procedure TFLButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  //--Если кнопка мыши - левая
  if button = mbleft then
    begin
      //--Делаем кнопку отжатой
      fPushed := false;
    end;
  Father.FocusedButton := nil;
end;

//--Метод генерируется при движении мыши по кнопке
procedure TFLButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if (ssLeft in Shift) and (ssAlt in Shift) then begin
    fCanClick := False;
    ReleaseCapture;
    FlaunchMainForm.Perform(WM_SYSCOMMAND, $F012, 0);
    Self.MouseUp(TMouseButton.mbLeft, Shift, X, Y);
    fCanClick := True;
  end;
  //--Генерируем событие родительской панели OnButtonMouseMove, передавая текущую кнопку
  if Assigned(Father.fButtonMouseMove) then Father.fButtonMouseMove(Father, Self);
end;

//--Метод генерируется при перетягивании на кнопку другого объекта
procedure TFLButton.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
  //--Если перетягиваемый объект - не другая кнопка, то дропать нельзя
  if not (Source is TFLButton) then Exit;
  (Source as TFLButton).fCurPage := Father.fDraggedButtonPageNumber;
  //--Если перетягиваемый объект - другая активная кнопка, то дропать можно
  if ((Source as TFLButton).IsActive) and
    ((Father.fCurrentDataIndex <> Father.fDraggedButtonPageNumber) or (Source <> Self))
  then
    Accept := true;
end;

//--Метод генерируется при отпускании перетягиваемого объекта
procedure TFLButton.DragDrop(Source: TObject; X, Y: Integer);
var
  TempDataItem: TFLDataItem;
begin
  inherited DragDrop(Source, X, Y);
  {*--Меняем местами две ячейки памяти--*}
  {**} TempDataItem := Father.GetCurrentDataPage.fItems[fRowNumber, fColNumber];
  {**} Father.GetCurrentDataPage.fItems[fRowNumber, fColNumber] := Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber];
  {**} Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber] := TempDataItem;
  {*----------------------------------------------------*}
end;

//--Метод генерируется при прекращении перетягивания объекта
procedure TFLButton.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  inherited;
  Father.fDragNow := false;
  FState := bsUp;
  Invalidate;
  fCanClick := true;
end;

//--Метод генерируется при вызове контекстного меню
procedure TFLButton.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  inherited DoContextPopup(MousePos, Handled);
  Father.fLastUsedButton := Self;
end;

//--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
procedure TFLButton.Paint;
begin
  ControlState := ControlState - [csGlassPaint];
  inherited;
  //--Если кнопка активна, рисуем ее иконку
  if (IsActive and HasIcon) then
  begin
    if fPushed then
      Canvas.Draw(3, 3, Data.PushedIconBmp)
    else
      Canvas.Draw(2, 2, Data.IconBmp);
  end;
end;

procedure TFLButton.RemoveHighlight;
begin
  FState := bsUp;
  Invalidate;
end;

{*********************************}
{*****-- Класс TFLDataItem --*****}
{*********************************}

//--Конструктор
//--Входные параметры: ширина кнопки, высота кнопки
constructor TFLDataItem.Create(ButtonWidth, ButtonHeight: integer);
begin
  fHasIcon := false;
  FHeight := ButtonHeight;
  FWidth := ButtonWidth;
  fHide := hideafterlaunch;
  fQues := queryonlaunch;
  fWSt := WStateDef;
  FIsAdmin := rwar;
  fDropFiles := defdrop;
  fPr := PriorDef;
  IconBmp := TBitMap.Create;
  IconBmp.Width := ButtonWidth - 4;
  IconBmp.Height := ButtonHeight - 4;
  PushedIconBmp := TBitMap.Create;
  PushedIconBmp.Width := ButtonWidth - 7;
  PushedIconBmp.Height := ButtonHeight - 7;
end;

//--Деструктор
destructor TFLDataItem.Destroy;
begin
  if TFile.Exists(IconCache) then
    TFile.Delete(IconCache);
  IconBmp.Free;
  PushedIconBmp.Free;
end;

//--read для свойства Exec
function TFLDataItem.GetExec: string;
begin
  Result := fExec;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

//--read для свойства WorkDir
function TFLDataItem.GetWorkDir: string;
begin
  Result := fWorkDir;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
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

//--read для свойства Icon
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

//--read для свойства Params
function TFLDataItem.GetParams: string;
begin
  Result := fParams;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

//--read для свойства DropParams
function TFLDataItem.GetDropParams: string;
begin
  Result := fDropParams;
  if not Father.ExpandStrings then Exit;
  Result := ExpandEnvironmentVariables(Result);
end;

//--Функция генерирует иконки (обычную и "нажатую" для ячейки памяти)
procedure TFLDataItem.AssignIcons;
var
  TempIcon: TIcon;
  TempBmp: TBitMap;
  ShellOk: Boolean;

  procedure DrawShield(ABitmap: TBitmap);
  var
    Size:TSize;
    Position: TPoint;
  begin
    Size.Width := ABitmap.Width div 2;
    Size.Height := ABitmap.Height div 2;
    Position.X := ABitmap.Width - Size.Width;
    Position.Y := ABitmap.Height - Size.Height;

    DrawShieldIcon(ABitmap.Canvas, Position, Size);
  end;
begin
  TempBmp := TBitMap.Create;
  ShellOk := False;
  // Virtual shell items (AppsFolder, Control Panel applets, This PC, …)
  if LooksLikeShellGuidPath(GetIcon) then
    ShellOk := TryLoadShellItemImage(GetIcon, IconBmp.Height, TempBmp);

  if not ShellOk then
  begin
    TempIcon := TIcon.Create;
    try
      if not ObjectExists(GetIcon) then
        TempIcon.Handle := LoadIcon(HInstance, 'RBLANKICON')
      else
        TempIcon.Handle := GetFileIcon(GetIcon, fIconIndex, IconBmp.Height);
      if TempIcon.Handle = 0 then
        TempIcon.Handle := LoadIcon(HInstance, 'RBLANKICON');
      TempBmp.Assign(TempIcon);
    finally
      TempIcon.Free;
    end;
  end;

  if (TempBmp.Width = IconBmp.Width) and (TempBmp.Height = IconBmp.Height) then
    IconBmp.Assign(TempBmp)
  else
    SmoothResize(TempBmp, IconBmp);
  if (TempBmp.Width = PushedIconBmp.Width) and (TempBmp.Height = PushedIconBmp.Height) then
    PushedIconBmp.Assign(TempBmp)
  else
    SmoothResize(TempBmp, PushedIconBmp);

  if FIsAdmin then
  begin
    DrawShield(IconBmp);
    DrawShield(PushedIconBmp);
  end;

  if TFile.Exists(IconCache) then
    TFile.Delete(IconCache);
  IconCache := '%FL_CONFIG%' + TPath.DirectorySeparatorChar + IconCacheDir +
    TPath.DirectorySeparatorChar + ExtractFileNameNoExt(Exec) + '_' +
    TPath.GetGUIDFileName() + '.png';

  fHasIcon := true;
  TempBmp.Free;
end;

{**********************************}
{*****-- Класс TFLDataTable --*****}
{**********************************}

//--Конструктор
//--Входные параметры: номер страницы, кол-во колонок и рядов
constructor TFLDataTable.Create(PageNumber, ColsCount, RowsCount: integer);
begin
  fPageNumber := PageNumber;
  fColsCount := ColsCount;
  fRowsCount := RowsCount;
  //--Отводим память под ячейки данных
  SetLength(fItems, fRowsCount, fColsCount);
end;

//--Деструктор
destructor TFLDataTable.Destroy;
var
  i, j: integer;
begin
  //--Уничтожаем созданные ячейки
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then fItems[i][j].Destroy;
  //--Освобождаем ячейки данных
  SetLength(fItems, 0);
end;

//--Очищение всей страницы данных
procedure TFLDataTable.Clear;
var
  i, j: integer;
begin
  //--Уничтожаем созданные ячейки
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      if Assigned(fItems[i][j]) then
        begin
          fItems[i][j].Destroy;
          fItems[i][j] := nil;
        end;
end;

//--Возвращает ячейку по индексам
//--Входные параметры: номер ряда и колонки
function TFLDataTable.GetItem(RowNumber, ColNumber: integer): TFLDataItem;
begin
  Result := fItems[RowNumber][ColNumber];
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

//--Определяет, является ли ячейка активной
//--Входные параметры: номер ряда и колонки
function TFLDataTable.GetIsActive(RowNumber, ColNumber: integer): boolean;
begin
  //--Ячейка активна, если класс, ее описывающий, создан
  Result := Assigned(fItems[RowNumber][ColNumber]);
end;

{******************************}
{*****-- Класс TFLPanel --*****}
{******************************}

//--Определение актуального размера компонента (согласно количеству строк и колонок кнопок, а также их размера. write для ActualSize)
//--Позволяет подогнать форму под размер компонента
function TFLPanel.GetActualSize: TSize;
begin
  Result.Width := fPadding * (fColsCount + 1) + (fButtonWidth * fColsCount) + 2;
  Result.Height := fPadding * (fRowsCount + 1) + (fButtonHeight * fRowsCount) + 2;
end;

//--Метод возвращает указатель на страницу данных по номеру страницы
//--Входной параметр: номер страницы
function TFLPanel.GetDataPageByPageNumber(PageNumber: integer): TFLDataTable;
begin
  Result := GetCurrentDataPage;
  if PageNumber = 255 then
    Exit;
  Result := fDataCollection[PageNumber];
end;

//--Конструктор
//--Входные параметры: родительский компонент, кол-во страниц, кол-во колонок,
//--кол-во рядов, зазор между кнопками, шиирна кнопок, высота кнопок, цвет панели
constructor TFLPanel.Create(AOwner: TComponent; PagesCount: integer = 3;
  ColsCount: integer = 10; RowsCount: integer = 2; Padding: integer = 1;
  ButtonsWidth: integer = 32; ButtonsHeight: integer = 32);
var
  i, j: integer;
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  TabStop := True;
  BevelOuter := bvNone;
  fPagesCount := PagesCount;
  fColsCount := ColsCount;
  fRowsCount := RowsCount;
  fPadding := Padding;
  fButtonWidth := ButtonsWidth + 4;
  fButtonHeight := ButtonsHeight + 4;
  fFocusedButton := nil;
  fLastUsedButton := nil;
  fExpandStrings := true;
  {*--Инициализируем коллекцию данных--*}
  fDataCollection := TFLDataCollection.Create;
  {**} for i := 0 to fPagesCount - 1 do
  {**}   fDataCollection.Add(TFLDataTable.Create(i, fColsCount, fRowsCount));
  {**} fCurrentDataIndex := 0;
  {*-----------------------------------*}
  //--Отводим память под кнопки
  SetLength(fButtons, fRowsCount, fColsCount);
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      begin
        //--Создаем кнопку
        fButtons[i, j] := TFLButton.Create(Self, i, j);
        {*--Устанавливаем кнопку в нужную позицию--*}
        {**} fButtons[i, j].Left := fPadding * (j + 1) + (fButtonWidth * j) + 1;
        {**} fButtons[i, j].Top := fPadding * (i + 1) + (fButtonHeight * i) + 1;
        {*-----------------------------------------*}
      end;
  UpdateSize;
end;

procedure TFLPanel.CreateWnd;
begin
  inherited;
  // OLE drop for Start Menu / shell ID lists; WM_DROPFILES remains for classic HDROP
  fOleDropTarget := TFLOleDropTarget.Create(Self);
  if Failed(RegisterDragDrop(Handle, fOleDropTarget)) then
    fOleDropTarget := nil;
end;

procedure TFLPanel.DestroyWnd;
begin
  if fOleDropTarget <> nil then
  begin
    RevokeDragDrop(Handle);
    fOleDropTarget := nil;
  end;
  inherited;
end;

//--Деструктор
destructor TFLPanel.Destroy;
var
  i, j: integer;
begin
  {*--Уничтожаем все кнопки--*}
  {**} for i := 0 to fRowsCount - 1 do
  {**}   for j := 0 to fColsCount - 1 do
  {**}     fButtons[i, j].Free;
  {**} SetLength(fButtons, 0, 0);
  {*--Освобождаем коллекцию данных--*}
  {**} fDataCollection.Free;
  {*--------------------------------*}
  inherited Destroy;
end;

//--Инициализация ячейки данных
//--Входные параметры: номер страницы, номер строки, номер колонки
procedure TFLPanel.InitializeDataItem(PageNumber, RowNumber, ColNumber: integer);
begin
  if PageNumber = fCurrentDataIndex then
    GetCurrentDataPage.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight)
  else
    GetDataPageByPageNumber(PageNumber).fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight);
end;

//--Меняет местами две страницы данных
procedure TFLPanel.SwapData(PageNumber1, PageNumber2: integer);
begin
  if (PageNumber1 = PageNumber2) then
    Exit;

  if (PageNumber1 < 0) or (PageNumber1 >= fPagesCount) then
    Exit;
  if (PageNumber2 < 0) or (PageNumber2 >= fPagesCount) then
    Exit;

  // IMPORTANT:
  // fDataCollection is a TObjectList<TFLDataTable> (owns objects).
  // Using indexed assignment would free the previous item and can lead to AV.
  fDataCollection.Exchange(PageNumber1, PageNumber2);
  fDataCollection[PageNumber1].fPageNumber := PageNumber1;
  fDataCollection[PageNumber2].fPageNumber := PageNumber2;

  Repaint;
end;

procedure TFLPanel.UpdateSize;
begin
  Width := ActualSize.Width;
  Height := ActualSize.Height;
end;

//--Очищает страницу данных
procedure TFLPanel.ClearPage(PageNumber: integer);
begin
  GetDataPageByPageNumber(PageNumber).Clear;
  Repaint;
end;

//--Удаляет страницу данных
//--Возвращает номер страницы, которая должна стать активной после удаления
function TFLPanel.DeletePage(PageNumber: integer): integer;
begin
  Result := PageNumber;
  if PageNumber = fPagesCount - 1 then
    Result := PageNumber - 1;
  {*--Удаляем из памяти страницу данных--*}
  fDataCollection.Delete(PageNumber);
  {*----------------------------------------------------------------------------------------------*}
  Dec(fPagesCount);
  SetPageNumber(Result);
end;

//--Создает страницу данных
function TFLPanel.AddPage: integer;
begin
  Result := fPagesCount;
  {*-----------------------------------*}
  Result := fDataCollection.Add(TFLDataTable.Create(Result, fColsCount, fRowsCount));
  Inc(fPagesCount);
  SetPageNumber(Result);
end;

//--Перерисовка всех кнопок
procedure TFLPanel.FullRepaint;
var
  i, j: integer;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].Repaint;
end;

//--Возвращает ссылку на последнюю перетаскиваемую кнопку
function TFLPanel.GetLastDraggedButton: TFLButton;
begin
  //--Берем LastUsedButton с номером страницы, откуда начали перетаскивать
  //--Используем только для доступа к ячейке данных
  Result := LastUsedButton;
  if LastUsedButton = nil then Exit;
  LastUsedButton.fCurPage := fDraggedButtonPageNumber;
end;

//--Возвращает кнопку по индексам (текущая активная страница)
//--Входные параметры: номер ряда и колонки
function TFLPanel.GetCurButton(RowNumber, ColNumber: integer): TFLButton;
begin
  Result := fButtons[RowNumber][ColNumber];
end;

function TFLPanel.GetCurrentDataPage: TFLDataTable;
begin
  Result := fDataCollection[fCurrentDataIndex];
end;

//--Возвращает кнопку по индексам (произвольная страница)
//--Входные параметры: номер страницы, ряда и колонки
function TFLPanel.GetButton(PageNumber, RowNumber, ColNumber: integer): TFLButton;
begin
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

  UpdateSize;
end;

//--Установка контекстного меню для кнопок
//--Входной параметр: ссылка на меню
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

  UpdateSize;
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

  UpdateSize;
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

  UpdateSize;
end;

//--Установка номера текущей страницы
//--Входной параметр: номер страницы
procedure TFLPanel.SetPageNumber(PageNumber: Integer);
var
  i, j: integer;
begin
  // Even if the page number is the same, we still need to re-sync button
  // fCurPage values. Various routines iterate over Tabs using Buttons[...]
  // which mutates fCurPage for shared UI buttons.
  if fCurrentDataIndex = PageNumber then
  begin
    for i := 0 to fRowsCount - 1 do
      for j := 0 to fColsCount - 1 do
        fButtons[i, j].fCurPage := fCurrentDataIndex;
    Exit;
  end;
  //--Устанавливаем указатель на текущую страницу данных <- указатель на страницу с выбранным номером
  fCurrentDataIndex := PageNumber;
  if fCurrentDataIndex < 0 then fCurrentDataIndex := 0;
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

  UpdateSize;
end;

function TFLPanel.FindButtonForDrop(const AScreenPos: TPoint): TFLButton;
var
  TempCtrl: TControl;
  NewPos: TPoint;
  I: Integer;
  BestButton: TFLButton;
  BestDist: Integer;

  function ButtonAtScreenPos(const APos: TPoint): TFLButton;
  var
    C: TControl;
  begin
    Result := nil;
    C := ControlAtPos(ScreenToClient(APos), False);
    if C is TFLButton then
      Result := C as TFLButton;
  end;

  procedure ConsiderButton(AButton: TFLButton; ADist: Integer);
  begin
    if AButton = nil then
      Exit;
    if (BestButton = nil) or
       ((not AButton.IsActive) and BestButton.IsActive) or
       ((AButton.IsActive = BestButton.IsActive) and (ADist < BestDist)) then
    begin
      BestButton := AButton;
      BestDist := ADist;
    end;
  end;

begin
  TempCtrl := ControlAtPos(ScreenToClient(AScreenPos), False);
  if TempCtrl is TFLButton then
    Exit(TempCtrl as TFLButton);

  BestButton := nil;
  BestDist := MaxInt;
  // Search horizontally: prefer empty buttons, then nearest to cursor
  for I := AScreenPos.X - Padding - ButtonWidth to AScreenPos.X + Padding
    + ButtonWidth do
  begin
    NewPos := AScreenPos;
    NewPos.X := I;
    ConsiderButton(ButtonAtScreenPos(NewPos), Abs(I - AScreenPos.X));
  end;
  // Search vertically if no button found yet
  if BestButton = nil then
    for I := AScreenPos.Y - Padding - ButtonHeight to AScreenPos.Y + Padding
      + ButtonHeight do
    begin
      NewPos := AScreenPos;
      NewPos.Y := I;
      ConsiderButton(ButtonAtScreenPos(NewPos), Abs(I - AScreenPos.Y));
    end;
  Result := BestButton;
end;

procedure TFLPanel.NotifyDropFile(const AFileName: string;
  const AScreenPos: TPoint);
var
  Button: TFLButton;
begin
  if not Assigned(fDropFile) or (AFileName = '') then
    Exit;
  Button := FindButtonForDrop(AScreenPos);
  if Button <> nil then
    fDropFile(Self, Button, AFileName);
end;

//--Метод генерируется при перетаскивании файла на кнопку
procedure TFLPanel.WMDropFiles(var Msg: TWMDropFiles);
var
  Buf: array [0..MAX_PATH] of Char;
begin
  try
    if Assigned(fDropFile) then
    begin
      DragQueryFile(Msg.Drop, 0, Buf, SizeOf(Buf));
      NotifyDropFile(Buf, Mouse.CursorPos);
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TFLPanel.WMKillFocus(var Msg: TWMKillFocus);
begin
  FocusedButton := nil;
  inherited;
end;

//--Метод генерируется при нажатии кнопки на клавиатуре
//--Здесь происходит обработка нажатия клавиш со стрелками, для навигации фокуса по кнопкам
//--Чтобы работало, форме необходимо разрешить отлавливать нажатия:
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
  //--Если нету кнопки с фокусом, то начинаем с первой
  if not Assigned(fFocusedButton) then
  begin
    FocusedButton := fButtons[0, 0];
  end
  else
  begin
    //--Если нажата стрелка "вниз"
    if Key = vk_down then
      //--Отдаем фокус кнопке, находяшейся снизу (циклически)
      FocusedButton :=
        fButtons[(fFocusedButton.RowNumber + 1) mod fRowsCount][fFocusedButton.ColNumber];
    //--Если нажата стрелка "вверх"
    if Key = vk_up then
      begin
        d := fFocusedButton.RowNumber - 1;
        if d < 0 then d := fRowsCount - 1;
        //--Отдаем фокус кнопке, находяшейся сверху (циклически)
        FocusedButton := fButtons[d mod fRowsCount][fFocusedButton.ColNumber];
      end;
    //--Если нажата стрелка "влево"
    if Key = vk_left then
      begin
        d := fFocusedButton.ColNumber - 1;
        if d < 0 then
        d := ColsCount - 1;
        //--Отдаем фокус кнопке, находяшейся слева (циклически)
        FocusedButton := fButtons[fFocusedButton.RowNumber][d mod fColsCount];
      end;
    //--Если нажата стрелка "вправо"
    if Key = vk_right then
      //--Отдаем фокус кнопке, находяшейся справа (циклически)
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

{ THighlightRemover }

constructor THighlightRemover.Create(AButton: TFLButton);
begin
  FButton := AButton;
end;

destructor THighlightRemover.Destroy;
begin
  FButton.RemoveHighlight;
  inherited;
end;

end.
