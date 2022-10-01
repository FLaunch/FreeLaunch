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

unit FLData;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls;

type
  TData = class(TDataModule)
    Images: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Data: TData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
