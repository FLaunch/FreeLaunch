program FLExecutor;

{$R *.res}

uses
  System.SysUtils, Winapi.Windows, FLFunctions, FLLanguage, System.Classes;

var
  WinHandle: HWND;
  ErrorCode: Integer;
  LinkStrings: TStringList;
  Link: TLink;

begin
  try
    InitEnvironment;
    if ParamCount = 0 then
    begin
      if not CreateProcess(fl_dir + 'FLaunch.exe', '', fl_dir, SW_NORMAL,
        NORMAL_PRIORITY_CLASS, ErrorCode)
      then
        RaiseLastOSError(ErrorCode);
    end
    else
    begin
      WinHandle := StrToIntDef(ParamStr(2), 0);
      Language.Load(ParamStr(3));

      LinkStrings := TStringList.Create;
      try
        LinkStrings.Delimiter := ';';
        LinkStrings.QuoteChar := '''';
        LinkStrings.DelimitedText := ParamStr(1);
        Link := StringsToLink(LinkStrings);
      finally
        LinkStrings.Free;
      end;

      ThreadLaunch(Link, WinHandle, ParamStr(4));
    end;
  except
    on E: Exception do
      WarningMessage(WinHandle, StringReplace(e.Message, '%1',
        ExtractFileName(Link.exec), [rfReplaceAll]));
  end;
end.
