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
  //--Цвет полупрозрачной рамки у кнопки с фокусом
  FocusColor = clRed;
  DraggedColor = clBlue;
  IconCacheDir = 'IconCache';

type

  {*--Описание этих классов находится ниже--*}
  {**} TFLPanel = class;
  {**} TFLDataItem = class;
  {*----------------------------------------*}

  //--Структура для передачи размера (ширина, высота). Используется для передачи оптимального размера компонента
  TSize = record
    Width, Height: integer;
  end;

  //--Класс кнопки на компоненте
  TFLButton = class(TCustomControl)
    private
      //--Если 255, то используется текущая страница, иначе этот номер страницы
      fCurPage: byte;
      //--Флаг, определяющий нажата ли в данный момент кнопка
      fPushed: boolean;
      //--Флаг, необходимый для предотвращения нажатия на кнопку при перетаскивании
      fCanClick: boolean;
      //--Цвет полупрозрачной рамки
      fFrameColor: TColor;
      //--Номер строки и колонки данной кнопки
      fRowNumber, fColNumber: byte;
      //--Возвращает ссылку на родительскую панель (read для свойства Father)
      function GetFather: TFLPanel;
      //--Метод рисует полупрозрачную рамку
      procedure DrawFrame;
      //--Устанавливает цвет полупрозрачной рамки (write для свойства FrameColor)
      procedure SetFrameColor(FrameColor: TColor);
      //--Возвращает данные (объект, рабочая папка и т.д.) для текущей кнопки текущей страницы (read для свойства Data)
      function GetDataItem: TFLDataItem;
      //--Является ли текущая кнопка текущей страницы активной (read для свойства IsActive)
      function GetIsActive: boolean;
      //--Установлена ли иконка на кнопке (read для свойства HasIcon)
      function GetHasIcon: boolean;
      //--Установлена ли иконка на кнопке (write для свойства HasIcon)
      procedure SetHasIcon(NewHasIcon: boolean);
      //--Метод генерируется при покидании курсора мыши кнопки
      procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
      //--Метод генерируется при получении кнопкой фокуса
      procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
      //--Метод генерируется при потере кнопкой фокуса
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
      //--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      //--Метод генерируется при перетаскивании файла на кнопку
      procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    protected

    public
      //--Конструктор
      constructor Create(AOwner: TComponent; RowNumber, ColNumber: byte);
      //--Деструктор
      destructor Destroy; override;
      //--Инициализация ячейки данных текущей кнопки текущей страницы
      function InitializeData: TFLDataItem;
      //--Освобождение ячейки данных текущей кнопки текущей страницы
      procedure FreeData;
      //--Ссылка на родительскую панель
      property Father: TFLPanel read GetFather;
      //--Цвет полупрозрачной рамки
      property FrameColor: TColor read fFrameColor write SetFrameColor;
      //--Номер строки и колонки данной кнопки
      property RowNumber: byte read fRowNumber;
      property ColNumber: byte read fColNumber;
      //--Ячейка данных (объект, рабочая папка и т.д.) текущей кнопки текущей страницы
      property Data: TFLDataItem read GetDataItem;
      //--Является ли кнопка активной (занятой чем-либо)
      property IsActive: boolean read GetIsActive;
      //--Установлена ли иконка на кнопке
      property HasIcon: boolean read GetHasIcon write SetHasIcon;
      //--Удаляет полупрозрачную рамку (очищает)
      procedure RemoveFrame;
      //--Метод генерируется при нажатии кнопки на клавиатуре
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
      //--Метод генерируется при "отжатии" кнопки на клавиатуре
      procedure KeyUp(var Key: Word; Shift: TShiftState); override;
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
    published

  end;

  //--Класс описывает ячейку памяти, содержащую информацию о кнопке
  TFLDataItem = class
    private
      //--Ссылка на родительскую панель
      fFather: TFLPanel;
      {*--Поля свойств--*}
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
      //--Цвет кнопок
      fPanelColor: TColor;
      //--Флаг, определяюший, установлена ли иконка
      fHasIcon: boolean;
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
    public
      //--Изображение иконки
      IconBmp: TBitMap;
      //--Изображение нажатой иконки
      PushedIconBmp: TBitMap;
      //--Конструктор
      constructor Create(ButtonWidth, ButtonHeight: byte; PanelColor: TColor);
      //--Деструктор
      destructor Destroy; override;
      //--Ссылка на родительскую панель
      property Father: TFLPanel read fFather write fFather;
      //--Функция генерирует иконки (обычную и "нажатую" для ячейки памяти)
      procedure AssignIcons;
      //--Тип кнопки (0 - исполняемый файл, 1 - файл, папка)
      property LType: byte read fLType write fLType;
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
      property Pr: byte read fPr write fPr;
      //--Состояние окна
      property WSt: byte read fWSt write fWSt;
      function GetIconCacheRaw: string;
  end;

  //--Класс описывает страницу данных (матрица данных для кнопок одной вкладки)
  TFLDataTable = class
    private
      //--Размеры таблицы (кол-во колонок и строк)
      fColsCount, fRowsCount: byte;
      //--Номер страницы
      fPageNumber: byte;
      //--Ячейки данных
      fItems: array of array of TFLDataItem;
      //--Возвращает ячейку по индексам (read для Items)
      function GetItem(RowNumber, ColNumber: byte): TFLDataItem;
      //--Определяет, является ли ячейка активной (read для IsActive)
      function GetIsActive(RowNumber, ColNumber: byte): boolean;
    public
      //--Конструктор
      constructor Create(PageNumber, ColsCount, RowsCount: byte);
      //--Деструктор
      destructor Destroy; override;
      //--Очищение всей страницы данных
      procedure Clear;
      //--Ячейка данных по ее индексам
      property Items[RowNumber, ColNumber: byte]: TFLDataItem read GetItem;
      //--Является ли ячейка активной
      property IsActive[RowNumber, ColNumber: byte]: boolean read GetIsActive;
  end;

  //--Указатель на коллекцию данных
  PFLDataCollection = ^TFLDataCollection;

  //--Коллекция данных - двусвязный список страниц данных ;)
  TFLDataCollection = packed record
    PrevNode: PFLDataCollection;
    Node: TFLDataTable;
    NextNode: PFLDataCollection;
  end;

  {*--Типы для создания событий--*}
  {**} TButtonClickEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseDownEvent = procedure(Sender: TObject; MouseButton: TMouseButton; Button: TFLButton) of object;
  {**} TButtonMouseMoveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TButtonMouseLeaveEvent = procedure(Sender: TObject; Button: TFLButton) of object;
  {**} TDropFileEvent = procedure(Sender: TObject; Button: TFLButton; FileName: string) of object;
  {*-----------------------------*}

  //--Главный класс. Описывает компонент - таблицу кнопок
  TFLPanel = class(TCustomControl)
    private
      //--Общий цвет панели и кнопок
      fPanelColor: TColor;
      //--Светлый и два темных цвета панели (тени)
      fLColor, fDColor1, fDColor2: TColor;
      //--Кол-во страниц, колонок и строк
      fPagesCount, fColsCount, fRowsCount: byte;
      //--Номер текущей страницы
      fPageNumber: byte;
      //--Ширина и высота кнопок
      fButtonWidth, fButtonHeight: byte;
      //--Зазор между кнопками
      fPadding: byte;
      //--Массив кнопок
      fButtons: array of array of TFLButton;
      //--Указатель на коллекцию данных
      fDataCollection: PFLDataCollection;
      //--Указатель на текущую страницу данных (активная страница)
      fCurrentData: PFLDataCollection;
      //--Заменять ли в строковых параметрах в ячейках данных переменные FL_*
      fExpandStrings: boolean;
      {*--Переменные FL_*--*}
      {**} fFL_DIR: string;
      {**} fFL_ROOT: string;
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
      //--Контекстное меню для кнопок
      fButtonsPopup: TPopupMenu;
      //--Номер страницы, на которой начали перетаскивать кнопку
      fDraggedButtonPageNumber: byte;
      //--Возвращает ссылку на последнюю перетаскиваемую кнопку (read для LastDraggedButton)
      function GetLastDraggedButton: TFLButton;
      //--Возвращает кнопку по индексам (текущая активная страница) (read для CurButtons)
      function GetCurButton(RowNumber, ColNumber: byte): TFLButton;
      //--Возвращает кнопку по индексам (произвольная страница) (read для Buttons)
      function GetButton(PageNumber, RowNumber, ColNumber: byte): TFLButton;
      //--Установка контекстного меню для кнопок (write для ButtonsPopup)
      procedure SetButtonsPopup(ButtonsPopup: TPopupMenu);
      //--Установка номера текущей страницы (write для PageNumber)
      procedure SetPageNumber(PageNumber: byte);
      //--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
      procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
      //--Определение актуального размера компонента (согласно количеству строк и колонок кнопок, а также их размера. write для ActualSize)
      function GetActualSize: TSize;
      //--Метод возвращает указатель на страницу данных по номеру страницы
      function GetDataPageByPageNumber(PageNumber: byte): PFLDataCollection;
      //--Метод возвращает указатель на последнюю страницу данных ("хвост")
      function GetLastDataPage: PFLDataCollection;
    protected

    public
      //--Конструктор
      constructor Create(AOwner: TComponent; PagesCount: byte = 3; ColsCount: byte = 10;
        RowsCount: byte = 2; Padding: byte = 1; ButtonsWidth: byte = 32; ButtonsHeight: byte = 32;
        Color: TColor = clBtnFace);
      //--Деструктор
      destructor Destroy; override;
      //--Инициализация ячейки данных
      procedure InitializeDataItem(PageNumber, RowNumber, ColNumber: byte);
      //--Меняет местами две страницы данных
      procedure SwapData(PageNumber1, PageNumber2: byte);
      //--Очищает страницу данных
      procedure ClearPage(PageNumber: byte);
      //--Удаляет страницу данных
      function DeletePage(PageNumber: byte): Byte;
      //--Создает страницу данных
      function AddPage: Byte;
      //--Перерисовка всех кнопок
      procedure FullRepaint;
      //--Установка переменной FL_*
      procedure SetFLVariable(VarName: string; VarVal: string);
      //--Заменять ли в строковых параметрах в ячейках данных переменные FL_*
      property ExpandStrings: boolean read fExpandStrings write fExpandStrings;
      //--Ссылка на кнопку с фокусом
      property FocusedButton: TFLButton read fFocusedButton;
      //--Ссылка на последнюю задействованную кнопку
      property LastUsedButton: TFLButton read fLastUsedButton;
      //--Кол-во страниц, колонок и строк
      property PagesCount: byte read fPagesCount;
      property ColsCount: byte read fColsCount;
      property RowsCount: byte read fRowsCount;
      //--Кнопка по ее индексам (текущая активная страница)
      property CurButtons[RowNumber, ColNumber: byte]: TFLButton read GetCurButton;
      //--Кнопка по ее индексам (произвольная страница)
      //--После доступа сразу НЕОБХОДИМО выполнить один из следующих свойств/методов:
      //--Data (GetDataItem)
      //--IsActive (GetIsActive)
      //--HasIcon (GetHasIcon)
      //--InitializeData
      //--Проще говоря, только доступ/операции с данными
      //--Например: Buttons[0, 0, 0].IsActive
      property Buttons[PageNumber, RowNumber, ColNumber: byte]: TFLButton read GetButton;
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
      property PageNumber: byte read fPageNumber write SetPageNumber;
      //--Актуальный размер компонента
      property ActualSize: TSize read GetActualSize;
      //--Контекстное меню для кнопок
      property ButtonsPopup: TPopupMenu read fButtonsPopup write SetButtonsPopup;
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
  IOUtils;

{*******************************}
{*****-- Класс TFLButton --*****}
{*******************************}

//--Конструктор класса
//--Входные параметры: родительский компонент, номер ряда, номер колонки
constructor TFLButton.Create(AOwner: TComponent; RowNumber, ColNumber: byte);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ParentBackground := false;
  Width := Father.fButtonWidth;
  Height := Father.fButtonHeight;
  //--Позволяем переключаться по Tab
  TabStop := true;
  Color := Father.fPanelColor;
  FrameColor := Father.fPanelColor;
  fRowNumber := RowNumber;
  fColNumber := ColNumber;
  fPushed := false;
  fCanClick := true;
  fCurPage := 255;
  //--Позволяем перетягивать файлы на кнопку
  DragAcceptFiles(Handle, True);
end;

//--Деструктор класса
destructor TFLButton.Destroy;
begin
  inherited Destroy;
end;

//--Инициализация ячейки данных текущей кнопки текущей страницы
function TFLButton.InitializeData: TFLDataItem;
begin
  if not Assigned(Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber]) then
    Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber] :=
      TFLDataItem.Create(Father.fButtonWidth, Father.fButtonHeight, Father.fPanelColor);

  Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber].Father := Father;
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.fItems[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--Освобождение ячейки данных текущей кнопки текущей страницы
procedure TFLButton.FreeData;
begin
  FreeAndNil(Father.fCurrentData.Node.fItems[fRowNumber, fColNumber]);
  Repaint;
end;

//--Возвращает ссылку на родительскую панель
function TFLButton.GetFather: TFLPanel;
begin
  Result := Parent as TFLPanel;
end;

//--Метод рисует полупрозрачную рамку
procedure TFLButton.DrawFrame;
var
  i,j: integer;
  DrawColor: TColor;
begin
  //--Если сейчас выполняется перетягивание этой кнопки, то рисуется рамка цвета DraggedColor
  if (IsActive) and (Father.fDragNow) and (Self = Father.fLastUsedButton) and (Father.fPageNumber = Father.fDraggedButtonPageNumber) then
    DrawColor := DraggedColor
  else
    if Focused then
      DrawColor := FocusColor
    else
      DrawColor := fFrameColor;

  //--Если кнопка нажата или цвет рамки совпадает с цветом панели, то рамка не рисуется
  if (fPushed) or (DrawColor = Father.fPanelColor) then Exit;

  for i := 0 to Width - 1 do
    for j := 0 to Height - 1 do
      begin
        Canvas.Pixels[i,j] := GetColorBetween(Canvas.Pixels[i,j], DrawColor, 18, 0, 100);
      end;
end;

//--Устанавливает цвет полупрозрачной рамки
//--Входной параметр: цвет рамки
procedure TFLButton.SetFrameColor(FrameColor: TColor);
begin
  fFrameColor := FrameColor;
  Repaint;
end;

//--Возвращает данные (объект, рабочая папка и т.д.) для текущей кнопки текущей страницы
function TFLButton.GetDataItem: TFLDataItem;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Данные ячейки [fRowNumber, fColNumber] (совпадающие с координатами кнопки)
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--Является ли текущая кнопка текущей страницы активной
function TFLButton.GetIsActive: boolean;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Является ли ячейка активной
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.IsActive[fRowNumber, fColNumber];
  fCurPage := 255;
end;

//--Установлена ли иконка на кнопке
function TFLButton.GetHasIcon: boolean;
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Ячейка данных с координатами [fRowNumber, fColNumber] -> Имеет ли иконку
  Result := Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber].fHasIcon;
  fCurPage := 255;
end;

//--Установлена ли иконка на кнопке
procedure TFLButton.SetHasIcon(NewHasIcon: boolean);
begin
  //--Родительская панель -> Текущая страница данных (или по индексу) -> Ячейка данных с координатами [fRowNumber, fColNumber] -> Имеет ли иконку
  Father.GetDataPageByPageNumber(fCurPage).Node.Items[fRowNumber, fColNumber].fHasIcon := NewHasIcon;
  fCurPage := 255;
end;

//--Метод генерируется при покидании курсора мыши кнопки
procedure TFLButton.WMMouseLeave(var Msg: TMessage);
begin
  //--Генерируем событие родительской панели OnButtonMouseLeave, передавая текущую кнопку
  if Assigned(Father.fButtonMouseLeave) then Father.fButtonMouseLeave(Father, Self);
end;

//--Метод генерируется при получении кнопкой фокуса
procedure TFLButton.WMSetFocus(var Msg: TWMSetFocus);
begin
  //--Устанавливаем ссылку на кнопку с фокусом <- текущую кнопку
  Father.fFocusedButton := Self;
  //--Иммитируем движение мыши по кнопке
  MouseMove([], 0, 0);
  Repaint;
end;

//--Метод генерируется при потере кнопкой фокуса
procedure TFLButton.WMKillFocus(var Msg: TWMKillFocus);
begin
  Father.fFocusedButton := nil;
  Repaint;
end;

//--Удаляет полупрозрачную рамку (очищает)
procedure TFLButton.RemoveFrame;
begin
  //--Устанавливаем цвет рамки <- цвет панели
  fFrameColor := Father.fPanelColor;
  Repaint;
end;

//--Метод генерируется при нажатии кнопки на клавиатуре
//--Обрабатываем нажатие здесь клавиши Enter
procedure TFLButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    MouseDown(mbLeft, [], 0, 0);
  inherited KeyDown(Key, Shift);
end;

//--Метод генерируется при "отжатии" кнопки на клавиатуре
//--См. описание к KeyDown
procedure TFLButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    begin
      MouseUp(mbLeft, [], 0, 0);
      Click;
    end;
  inherited KeyUp(Key, Shift);
end;

//--Метод генерируется при клике мышью
procedure TFLButton.Click;
begin
  //--Если клик в данный момент возможен
  //--А невозможен он тогда, когда мы хотим перетащить кнопку с зажатым Ctrl
  //--Иначе при отпускании кнопки мыши негерировался бы клик
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
procedure TFLButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //--Если кнопка мыши - левая
  if button = mbLeft then
    //--Если зажат Ctrl
    if ssCtrl in Shift then
      begin
        //--Запрещаем генерацию клика по этой кнопке
        fCanClick := false;
        //--Начинаем перетаскивать кнопку
        BeginDrag(false);
        Father.fDragNow := true;
        //--Запоминаем номер страницы, на которой начали перетаскивать кнопку
        Father.fDraggedButtonPageNumber := Father.fPageNumber;
        //--Устанавливаем ссылку на последнюю использованную кнопку <- текущую кнопку
        Father.fLastUsedButton := Self;
        //--Перерисовываем (чтобы появилась рамка)
        Repaint;
      end
    else
      begin
        //--Если Ctrl зажат не был, делаем кноку нажатой
        fPushed := true;
        //--Устанавливаем ссылку на последнюю использованную кнопку <- текущую кнопку
        Father.fLastUsedButton := Self;
        Repaint;
      end;
  //--Генерируем событие родительской панели OnButtonMouseDown, передавая ссылку на текущую кнопку
  if Assigned(Father.fButtonMouseDown) then Father.fButtonMouseDown(Father, Button, Self);
  inherited MouseDown(Button, Shift, X, Y);
end;

//--Метод генерируется при "отжатии" кнопки мыши
procedure TFLButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //--Если кнопка мыши - левая
  if button = mbleft then
    begin
      //--Делаем кнопку отжатой
      fPushed := false;
      Repaint;
    end;
  inherited MouseUp(Button, Shift, X, Y);
end;

//--Метод генерируется при движении мыши по кнопке
procedure TFLButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //--Генерируем событие родительской панели OnButtonMouseMove, передавая текущую кнопку
  if Assigned(Father.fButtonMouseMove) then Father.fButtonMouseMove(Father, Self);
  inherited MouseMove(Shift, X, Y);
end;

//--Метод генерируется при перетягивании на кнопку другого объекта
procedure TFLButton.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
  //--Если перетягиваемый объект - не другая кнопка, то дропать нельзя
  if not (Source is TFLButton) then Exit;
  (Source as TFLButton).fCurPage := Father.fDraggedButtonPageNumber;
  //--Если перетягиваемый объект - другая активная кнопка, то дропать можно
  if ((Source as TFLButton).IsActive) and ((Father.fPageNumber <> Father.fDraggedButtonPageNumber) or (Source <> Self)) then Accept := true;
end;

//--Метод генерируется при отпускании перетягиваемого объекта
procedure TFLButton.DragDrop(Source: TObject; X, Y: Integer);
var
  TempDataItem: TFLDataItem;
begin
  {*--Меняем местами две ячейки памяти--*}
  {**} TempDataItem := Father.fCurrentData.Node.fItems[fRowNumber, fColNumber];
  {**} Father.fCurrentData.Node.fItems[fRowNumber, fColNumber] := Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).Node.fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber];
  {**} Father.GetDataPageByPageNumber(Father.fDraggedButtonPageNumber).Node.fItems[(Source as TFLButton).fRowNumber, (Source as TFLButton).fColNumber] := TempDataItem;
  {*--Перерисовываем кнопку-источник и кнопку-приемник--*}
  {**} Repaint;
  {**} (Source as TFLButton).Repaint;
  {*----------------------------------------------------*}
  inherited DragDrop(Source, X, Y);
end;

//--Метод генерируется при прекращении перетягивания объекта
procedure TFLButton.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  Father.fDragNow := false;
  Repaint;
  fCanClick := true;
end;

//--Метод генерируется при вызове контекстного меню
procedure TFLButton.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  MouseDown(mbRight, [], 0, 0);
  Father.fLastUsedButton := Self;
  inherited DoContextPopup(MousePos, Handled);
end;

//--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
procedure TFLButton.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  //--Если кнопка нажата в данный момент
  if fPushed then
    begin
      {*--То рисуем тени для нажатой кнопки--*}
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
      //--Если кнопка активна, рисуем ее иконку
      if (IsActive and HasIcon) then
        Canvas.Draw(3, 3, Data.PushedIconBmp);
    end
  else
    begin
      {*--Иначе рисуем обычные тени--*}
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
      //--Если кнопка активна, рисуем ее иконку
      if (IsActive and HasIcon) then
        Canvas.Draw(2, 2, Data.IconBmp);
    end;
  //--Рисуем полупрозрачную рамку (если установлена)
  DrawFrame;
end;

//--Метод генерируется при перетаскивании файла на кнопку
procedure TFLButton.WMDropFiles(var Msg: TWMDropFiles);
var
  buf: array[0..MAX_PATH] of char;
begin
  if Assigned(Father.fDropFile) then
    begin
      DragQueryFile(Msg.Drop, 0, buf, SizeOf(buf));
      //--Генерируем событие родительской панели OnDropFile, передавая текущую кнопку и путь к файлу
      Father.fDropFile(Father, Self, buf);
      DragFinish(Msg.Drop);
    end;
end;

{*********************************}
{*****-- Класс TFLDataItem --*****}
{*********************************}

//--Конструктор
//--Входные параметры: ширина кнопки, высота кнопки
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
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read для свойства WorkDir
function TFLDataItem.GetWorkDir: string;
begin
  Result := fWorkDir;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read для свойства Icon
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

//--read для свойства Params
function TFLDataItem.GetParams: string;
begin
  Result := fParams;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--read для свойства DropParams
function TFLDataItem.GetDropParams: string;
begin
  Result := fDropParams;
  if not Father.ExpandStrings then Exit;
  Result := StringReplace(Result, '%FL_ROOT%', Father.fFL_ROOT, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '%FL_DIR%', Father.fFL_DIR, [rfReplaceAll, rfIgnoreCase]);
end;

//--Функция генерирует иконки (обычную и "нажатую" для ячейки памяти)
procedure TFLDataItem.AssignIcons;
var
  TempIcon: TIcon;
  TempBmp: TBitMap;
  icx,icy: integer;
begin
  TempIcon := TIcon.Create;
  // AbsolutePath fIcon

  //--Если объекта не существует
  if (not FileExists(GetIcon)) and (not DirectoryExists(GetIcon)) then
    //--Загружаем стандартную иконку "белый лист"
    TempIcon.Handle := LoadIcon(HInstance, 'RBLANKICON')
  else
    //--Иначе загружаем иконку из файла
    TempIcon.Handle := GetFileIcon(GetIcon, true, fIconIndex);
  if TempIcon.Handle = 0 then
    TempIcon.Handle := LoadIcon(hinstance, 'RBLANKICON');
  {*--Рисуем иконку на битмапе с заданным фоном, сохраняя альфа канал--*}
  {**} icx := GetSystemMetrics(SM_CXICON);
  {**} icy := GetSystemMetrics(SM_CYICON);
  {**} TempBmp := TBitMap.Create;
  {**} TempBmp.Width := icx;
  {**} TempBmp.Height := icy;
  {**} TempBmp.Canvas.Brush.Color := fPanelColor;
  {**} TempBmp.Canvas.FillRect(TempBmp.Canvas.ClipRect);
  {**} DrawIcon(TempBmp.Canvas.Handle, 0, 0, TempIcon.Handle);
  {*--Изменяем размер иконки, если это требуется--*}
  {**} if (icx = IconBmp.Width) and (icy = IconBmp.Height) then
  {**}   IconBmp.Assign(TempBmp)
  {**} else
  {**}   SmoothResize(TempBmp, IconBmp);
  {*--Таким же образом создаем "нажатую" кнопку--*}
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
{*****-- Класс TFLDataTable --*****}
{**********************************}

//--Конструктор
//--Входные параметры: номер страницы, кол-во колонок и рядов
constructor TFLDataTable.Create(PageNumber, ColsCount, RowsCount: byte);
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
  i, j: byte;
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
  i, j: byte;
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
function TFLDataTable.GetItem(RowNumber, ColNumber: byte): TFLDataItem;
begin
  Result := fItems[RowNumber][ColNumber];
end;

//--Определяет, является ли ячейка активной
//--Входные параметры: номер ряда и колонки
function TFLDataTable.GetIsActive(RowNumber, ColNumber: byte): boolean;
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
function TFLPanel.GetDataPageByPageNumber(PageNumber: byte): PFLDataCollection;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := fCurrentData;
  if PageNumber = 255 then Exit;
  Result := nil;
  {*--Пробегаемся по коллекции данных в поиске страницы с нужным номером--*}
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

//--Метод возвращает указатель на последнюю страницу данных ("хвост")
function TFLPanel.GetLastDataPage: PFLDataCollection;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := nil;
  {*--Пробегаемся по коллекции данных до конца--*}
  {**} DataCurrent := fDataCollection;
  {**} while DataCurrent.NextNode <> nil do
  {**}   begin
  {**}     DataNext := DataCurrent.NextNode;
  {**}     DataCurrent := DataNext;
  {**}   end;
  {*----------------------------------------------------------------------*}
  Result := DataCurrent;
end;

//--Конструктор
//--Входные параметры: родительский компонент, кол-во страниц, кол-во колонок, кол-во рядов, зазор между кнопками, шиирна кнопок, высота кнопок, цвет панели
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
  {*--Инициализируем коллекцию данных--*}
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
  //--Разрешено перетаскивание файлов в окно FreeLaunch, когда он запущен с правами Администратора
  if TOSVersion.Check(6) then
  begin
    ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ADD);
    ChangeWindowMessageFilter (WM_COPYDATA, MSGFLT_ADD);
    ChangeWindowMessageFilter ($0049, MSGFLT_ADD);
  end;
end;

//--Деструктор
destructor TFLPanel.Destroy;
var
  i, j: byte;
  DataCurrent, DataNext: PFLDataCollection;
begin
  {*--Уничтожаем все кнопки--*}
  {**} for i := 0 to fRowsCount - 1 do
  {**}   for j := 0 to fColsCount - 1 do
  {**}     fButtons[i, j].Free;
  {**} SetLength(fButtons, 0, 0);
  {*--Освобождаем коллекцию данных--*}
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

//--Инициализация ячейки данных
//--Входные параметры: номер страницы, номер строки, номер колонки
procedure TFLPanel.InitializeDataItem(PageNumber, RowNumber, ColNumber: byte);
begin
  if PageNumber = fPageNumber then
    fCurrentData.Node.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor)
  else
    GetDataPageByPageNumber(PageNumber).Node.fItems[RowNumber, ColNumber] := TFLDataItem.Create(fButtonWidth, fButtonHeight, fPanelColor);
end;

//--Меняет местами две страницы данных
procedure TFLPanel.SwapData(PageNumber1, PageNumber2: byte);
var
  Page1, Page2: PFLDataCollection;
  TempPageNumber: byte;
begin
  //--Ищем страницу данных 1
  Page1 := GetDataPageByPageNumber(PageNumber1);
  //--Ищем страницу данных 2
  Page2 := GetDataPageByPageNumber(PageNumber2);
  {*--Делаем обмен индексов--*}
  {**} TempPageNumber := Page1.Node.fPageNumber;
  {**} Page1.Node.fPageNumber := Page2.Node.fPageNumber;
  {**} Page2.Node.fPageNumber := TempPageNumber;
  {*-------------------------*}
  Repaint;
end;

//--Очищает страницу данных
procedure TFLPanel.ClearPage(PageNumber: byte);
begin
  GetDataPageByPageNumber(PageNumber).Node.Clear;
  Repaint;
end;

//--Удаляет страницу данных
//--Возвращает номер страницы, которая должна стать активной после удаления
function TFLPanel.DeletePage(PageNumber: Byte): Byte;
var
  DataCurrent, DataNext: PFLDataCollection;
begin
  Result := PageNumber;
  if PageNumber = fPagesCount - 1 then
    Result := PageNumber - 1;
  //--Ищем страницу данных удаляемой страницы
  DataCurrent := GetDataPageByPageNumber(PageNumber);
  //--Если существует предыдущая страница
  if DataCurrent.PrevNode <> nil then
    //--То связываем предыдущую со следующей
    DataCurrent.PrevNode.NextNode := DataCurrent.NextNode;
  //--Если существует следующая страница
  if DataCurrent.NextNode <> nil then
    //--То связываем следующую с предыдущей
    DataCurrent.NextNode.PrevNode := DataCurrent.PrevNode;
  if DataCurrent.PrevNode = nil then
    fDataCollection := DataCurrent.NextNode;
  {*--Удаляем из памяти страницу данных--*}
  {**} DataCurrent.Node.Destroy;
  {**} FreeMem(DataCurrent, SizeOf(DataCurrent));
  {*--Пробегаемся по коллекции данных и уменьшаем на 1 все номера страниц, большие чем удаленная--*}
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

//--Создает страницу данных
function TFLPanel.AddPage: Byte;
var
  DataNew, DataLast: PFLDataCollection;
begin
  Result := fPagesCount;
  //--Находим последнюю страницу данных ("хвост")
  //--(А может не париться и добавлять в начало списка?)
  DataLast := GetLastDataPage;
  //--Отводим память под новую страницу
  GetMem(DataNew, SizeOf(DataNew));
  {*--Связываем страницу с коллекцией--*}
  {**} DataLast.NextNode := DataNew;
  {**} DataNew.PrevNode := DataLast;
  {**} DataNew.NextNode := nil;
  {*-----------------------------------*}
  DataNew.Node := TFLDataTable.Create(Result, fColsCount, fRowsCount);
  Inc(fPagesCount);
  SetPageNumber(Result);
end;

//--Перерисовка всех кнопок
procedure TFLPanel.FullRepaint;
var
  i, j: byte;
begin
  for i := 0 to fRowsCount - 1 do
    for j := 0 to fColsCount - 1 do
      fButtons[i, j].Repaint;
end;

//--Установка переменной FL_*
//--Входные параметры: имя переменной, значение переменной
procedure TFLPanel.SetFLVariable(VarName: string; VarVal: string);
begin
  if VarName = 'FL_ROOT' then fFL_ROOT := VarVal;
  if VarName = 'FL_DIR' then fFL_DIR := VarVal;
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
function TFLPanel.GetCurButton(RowNumber, ColNumber: byte): TFLButton;
begin
  Result := fButtons[RowNumber][ColNumber];
end;

//--Возвращает кнопку по индексам (произвольная страница)
//--Входные параметры: номер страницы, ряда и колонки
function TFLPanel.GetButton(PageNumber, RowNumber, ColNumber: byte): TFLButton;
begin
  fButtons[RowNumber][ColNumber].fCurPage := PageNumber;
  Result := fButtons[RowNumber][ColNumber];
end;

//--Установка контекстного меню для кнопок
//--Входной параметр: ссылка на меню
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

//--Установка номера текущей страницы
//--Входной параметр: номер страницы
procedure TFLPanel.SetPageNumber(PageNumber: byte);
begin
  fPageNumber := PageNumber;
  //--Устанавливаем указатель на текущую страницу данных <- указатель на страницу с выбранным номером
  fCurrentData := GetDataPageByPageNumber(fPageNumber);
  Repaint;
end;

//--Метод генерируется при получении кнопкой сообщении о необходимости перерисовки
procedure TFLPanel.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  {*--Рисуем тени панели--*}
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

//--Метод генерируется при нажатии кнопки на клавиатуре
//--Чтобы работало, нужно связать:
//--
//--procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//--begin
//--  FLPanel.KeyDown(Key, Shift);
//--end;
//--
//--Здесь происходит обработка нажатия клавиш со стрелками, для навигации фокуса по кнопкам
//--В форме необходимо разрешить отлавливать нажатия:
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
  //--Если существует кнопка с фокусом
  if Assigned(fFocusedButton) then
    begin
      //--Если нажата стрелка "вниз"
      if Key = vk_down then
        //--Отдаем фокус кнопке, находяшейся снизу (циклически)
        fButtons[(fFocusedButton.RowNumber + 1) mod fRowsCount][fFocusedButton.ColNumber].SetFocus;
      //--Если нажата стрелка "вверх"
      if Key = vk_up then
        begin
          d := fFocusedButton.RowNumber - 1;
          if d < 0 then d := fRowsCount - 1;
          //--Отдаем фокус кнопке, находяшейся сверху (циклически)
          fButtons[d mod fRowsCount][fFocusedButton.ColNumber].SetFocus;
        end;
      //--Если нажата стрелка "влево"
      if Key = vk_left then
        begin
          d := fFocusedButton.ColNumber - 1;
          if d < 0 then
          d := ColsCount - 1;
          //--Отдаем фокус кнопке, находяшейся слева (циклически)
          fButtons[fFocusedButton.RowNumber][d mod fColsCount].SetFocus;
        end;
      //--Если нажата стрелка "вправо"
      if Key = vk_right then
        //--Отдаем фокус кнопке, находяшейся справа (циклически)
        fButtons[fFocusedButton.RowNumber][(fFocusedButton.ColNumber + 1) mod fColsCount].SetFocus;
    end;
  inherited KeyDown(Key, Shift);
end;

end.
