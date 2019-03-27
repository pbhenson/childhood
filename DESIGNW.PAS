program DesignWindow;

uses Crt, IO, QkWndws;

type
  DesWindRec = record
                 UserWindow : WindRec;
                 WndName    : string[25];
                 WndType    : byte;
               end;

var
   DesWindow : DesWindRec;
   TitleWindow : WindRec;
   InputWindow, DirectionsWindow, StatusWindow : SWindRec;


const
  NWind = 0;
  SWind = 1;
  RWind = 2;
  SRWind = 3;

  procedure InitUserWindow;
    begin
      with DesWindow.UserWindow do
        begin
          with attribs do
            begin
              BrdFgAttr := Cyan;
              BrdBgAttr := Blue;
              TxtFgAttr := LightGray;
              TxtBgAttr := Black;
            end;
          BorderWanted := SidSingleLine;
          TitlesWanted := [];
          TitleNames[Upleft] := '';
          TitleNames[UpCenter] := '';
          TitleNames[UpRight] :=  '';
          TitleNames[DownLeft] := '';
          TitleNames[DownCenter] := '';
          TitleNames[DownRight] := '';
          with Location do
            begin
              Ux := 9;
              Uy := 7;
              Lx := 68;
              Ly := 15;
            end;
        end;
  end;


procedure InitWindows;
  begin
    with TitleWindow do
      begin
        with Attribs do
          begin
            BrdFgAttr := Blue;
            BrdBgAttr := Cyan;
            TxtFgAttr := White;
            TxtBgAttr := Black;
          end;
        BorderWanted := AllDoubleLine;
        TitlesWanted := [TUpCenter, TDownRight];
        TitleNames[UpCenter] := 'The Window Designer';
        TitleNames[DownRight] := 'By Paul Henson';
        with Location do
          begin
            Ux := 5;
            Uy := 5;
            Lx := 75;
            Ly := 20;
          end;
      end;
      with DirectionsWindow do
        begin
          with Attribs do
            begin
              BrdBgAttr := 6;
              BrdFgAttr := 3;
              TxtBgAttr := 0;
              TxtFgAttr := 7;
            end;
          BorderWanted := TopSingleLine;
          with Location do
            begin
              Ux := 2;
              Uy := 2;
              Lx := 10;
              Ly := 10;
            end;
        end;
        InitUserWindow;
       with InputWindow do
         begin
           with Attribs do
             begin
               BrdFgAttr := LightCyan;
               BrdBgAttr := Blue;
               TxtFgAttr := White;
               TxtBgAttr := Black;
             end;
           BorderWanted := AllDoubleLine;
           with Location do
             begin
               Ux := 20;
               Uy := 10;
               Lx := 60;
               Ly := 13;
             end;
         end;
       with StatusWindow do
         begin
           with Attribs do
             begin
               BrdFgAttr := Magenta;
               BrdBgAttr := Black;
               TxtFgAttr := Cyan;
               TxtBgAttr := Black;
             end;
           BorderWanted := SidSingleLine;
           with Location do
             begin
               Ux := 20;
               Uy := 5;
               Lx := 60;
               Ly := 20;
             end;
         end;

     end;


procedure TitleScreen;
  begin
    clrscr;
    MkWindow(TitleWindow);
    writeln('CreateWindow! By Paul Henson');
    Pause;
  end;

procedure SaveWindow;
  var
    DesWinFil : file of DesWindrec;
    TxtWinFil : text;
    WinFilNam : string[12];

  procedure SaveDesignWindow;
    begin
      clrscr;
      repeat
        write('Enter filename: ');
        WinFilNam := GetFileName(NoExtension, savefile);
        if WinFilNam = ' ' then writeln('Invalid filename');
      until WinFilNam <> ' ';
      WinFilNam := WinFilNam + '.DW';
      clrscr;
      writeln('About to save ', WinFilNam);
      write('Confirmed? ');
      if GetYesNo then
        begin
          if exist(WinFilNam) then
            begin
              clrscr;
              writeln('File ''', WinFilNam, ''' already exists.');
              write('Over-write? ');
              if not getyesno then exit;
            end;
          assign(DesWinFil, WinFilNam);
          rewrite(DesWinFil);
          write(DesWinFil, DesWindow);
          close(DesWinFil);
        end;
    end;
  procedure SaveConstantWindow;
    var
      ch : char;
      Prev : Boolean;
    begin
      Prev := False;
      ClrScr;
      repeat
        write('Enter Filename:');
        WinFilNam := GetFileName(NoExtension, savefile);
      until WinFilNam <> ' ';
      WinFilNam := WinFilNam + '.INC';
      assign(TxtWinFil, WinFilNam);
      if exist(WinFilNam) then
        begin
          clrscr;
          writeln('File ''', WinFilNam, ''' already exists.');
          write('(O)verwrite or (A)ppend? ');
          repeat
            ch := upcase(readkey);
          until ch in ['O', 'A'];
          if ch = 'A' then append(TxtWinFil)
            else rewrite(TxtWinFil);
        end
      else rewrite(TxtWinFil);
      with DesWindow do
        begin
          writeln(TxtWinFil, 'Const');
          write(TxtWinFil, '  ', WndName, ' : ');
          case WndType of
            NWind : write(TxtWinFil, 'WindRec ');
            SWind : write(TxtWinFil, 'WindRecS ');
            RWind : write(TxtWinFil, 'RWindRec ');
            SRWind: write(TxtWinFil, 'RWindRecS ');
          end;
          writeln(TxtWinFil, '= (');
          with UserWindow.Attribs do
            begin
              writeln(TxtWinFil, '                       Attribs   : (');
              writeln(TxtWinFil, '                                    BrdFgAttr : ', ColorStr(BrdFgAttr), ';');
              writeln(TxtWinFil, '                                    BrdBgAttr : ', ColorStr(BrdBgAttr), ';');
              writeln(TxtWinFil, '                                    TxtFgAttr : ', ColorStr(TxtFgAttr), ';');
              writeln(TxtWinFil, '                                    TxtBgAttr : ', ColorStr(TxtBgAttr));
              writeln(TxtWinFil, '                                   );');
            end;
          writeln(TxtWinFil, '                    BorderWanted : ', BorderStr(UserWindow.BorderWanted), ';');
          with UserWindow.Borders do
            begin
              writeln(TxtWinFil, '                       Borders   : (');
              writeln(TxtWinFil, '                                    UpLeftCorn    : ''', UpLeftCorn, ''';');
              writeln(TxtWinFil, '                                    UpRightCorn   : ''', UpRightCorn, ''';');
              writeln(TxtWinFil, '                                    DnLeftCorn    : ''', DnLeftCorn, ''';');
              writeln(TxtWinFil, '                                    DnRightCorn   : ''', DnRightCorn, ''';');
              writeln(TxtWinFil, '                                    HorizBar      : ''', HorizBar, ''';');
              writeln(TxtWinFil, '                                    VertBar       : ''', VertBar, ''';');
              writeln(TxtWinFil, '                                    LeftTitleBar  : ''', LeftTitleBar, '''; ');
              writeln(TxtWinFil, '                                    RightTitleBar : ''', RightTitleBar, ''';');
              writeln(TxtWinFil, '                                    BrdAttr       : 0');
              writeln(TxtWinFil, '                                   );');
            end;
          if (WndType = NWind) or (WndType = RWind) then
            begin
              write(TxtWinFil, '                    TitlesWanted : [');
              with UserWindow do
                begin
                  if UpLeft in TitlesWanted then
                    begin
                      write(TxtWinFil, 'UpLeft');
                      Prev := True;
                    end;
                  if UpCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'UpCenter');
                      Prev := True;
                    end;
                  if UpRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'UpRight');
                      Prev := True;
                    end;
                  if DownLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownLeft');
                      Prev := True;
                    end;
                  if DownCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownCenter');
                      Prev := True;
                    end;
                  if DownRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownRight');
                      Prev := True;
                    end;
                 if TUpLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpLeft');
                      Prev := True;
                    end;
                  if TUpCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpCenter');
                      Prev := True;
                    end;
                  if TUpRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpRight');
                      Prev := True;
                    end;
                  if TDownLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownLeft');
                      Prev := True;
                    end;
                  if TDownCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownCenter');
                      Prev := True;
                    end;
                  if TDownRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownRight');
                    end;
               end;
             with UserWindow do
               begin
                 writeln(TxtWinFil, '];');
                 writeln(TxtWinFil, '                      TitleNames : (');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[Upleft]), ''',');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[UpCenter]), ''',');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[UpRight]), ''',');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[DownLeft]), ''',');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[DownCenter]), ''',');
                 writeln(TxtWinFil, '                                    ''', FixQuotes(TitleNames[DownRight]), '''');
                 writeln(TxtWinFil, '                                   );');
               end;
           end;
         with UserWindow.Location do
           begin
             writeln(TxtWinFil, '                        Location : (');
             writeln(TxtWinFil, '                                    Ux : ', Ux, ';');
             writeln(TxtWinFil, '                                    Uy : ', Uy, ';');
             writeln(TxtWinFil, '                                    Lx : ', Lx, ';');
             writeln(TxtWinFil, '                                    Ly : ', Ly);
             writeln(TxtWinFil, '                                   )');
           end;
         end;
         writeln(TxtWinFil, '                      );');
     close(TxtWinFil);
   end;


  procedure SaveInitWindow;
    var
      ch : char;
      Prev : Boolean;
    begin
      Prev := False;
      ClrScr;
      repeat
        write('Enter Filename:');
        WinFilNam := GetFileName(NoExtension, savefile);
      until WinFilNam <> '';
      WinFilNam := WinFilNam + '.INC';
      assign(TxtWinFil, WinFilNam);
      if exist(WinFilNam) then
        begin
          clrscr;
          writeln('File ''', WinFilNam, ''' already exists.');
          write('(O)verwrite or (A)ppend? ');
          repeat
            ch := upcase(readkey);
          until ch in ['O', 'A'];
          if ch = 'A' then append(TxtWinFil)
            else rewrite(TxtWinFil);
        end
      else rewrite(TxtWinFil);
      with DesWindow do
        begin
          writeln(TxtWinFil, '  procedure Init', WndName, ';');
          writeln(TxtWinFil, '    begin');
          writeln(TxtWinFil, '      with ', WndName, ' do');
          writeln(TxtWinFil, '        begin');
          with UserWindow.Attribs do
            begin
              writeln(TxtWinFil, '          with attribs do');
              writeln(TxtWinFil, '            begin');
              writeln(TxtWinFil, '              BrdFgAttr := ', ColorStr(BrdFgAttr), ';');
              writeln(TxtWinFil, '              BrdBgAttr := ', ColorStr(BrdBgAttr), ';');
              writeln(TxtWinFil, '              TxtFgAttr := ', ColorStr(TxtFgAttr), ';');
              writeln(TxtWinFil, '              TxtBgAttr := ', ColorStr(TxtBgAttr), ';');
             end;
          writeln(TxtWinFil, '            end;');
          with UserWindow do
            writeln(TxtWinFil, '          BorderWanted := ', BorderStr(BorderWanted), ';');
          if UserWindow.BorderWanted = UserBorder then
            begin
              with UserWindow.Borders do
                begin
                  writeln(TxtWinFil, '          with Borders do');
                  writeln(TxtWinFil, '            begin');
                  writeln(TxtWinFil, '              UpLeftCorn := ''', UpLeftCorn, ''';');
                  writeln(TxtWinFil, '              UpRightCorn := ''', UpRightCorn, ''';');
                  writeln(TxtWinFil, '              DnLeftCorn := ''', DnLeftCorn, ''';');
                  writeln(TxtWinFil, '              DnRightCorn := ''', DnRightCorn, ''';');
                  writeln(TxtWinFil, '              HorizBar := ''', HorizBar, ''';');
                  writeln(TxtWinFil, '              VertBar := ''', VertBar, ''';');
                  writeln(TxtWinFil, '              LeftTitleBar := ''', LeftTitleBar, ''';');
                  writeln(TxtWinFil, '              RightTitleBar := ''', RightTitleBar, ''';');
                 writeln(TxtWinFil, '            end;');
                end;
            end;
          if (WndType = NWind) or (WndType = RWind) then
            begin
              write(TxtWinFil, '          TitlesWanted := [');
              with UserWindow do
                begin
                  if UpLeft in TitlesWanted then
                    begin
                      write(TxtWinFil, 'UpLeft');
                      Prev := True;
                    end;
                  if UpCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'UpCenter');
                      Prev := True;
                    end;
                  if UpRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'UpRight');
                      Prev := True;
                    end;
                  if DownLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownLeft');
                      Prev := True;
                    end;
                  if DownCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownCenter');
                      Prev := True;
                    end;
                  if DownRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'DownRight');
                      Prev := True;
                    end;
                 if TUpLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpLeft');
                      Prev := True;
                    end;
                  if TUpCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpCenter');
                      Prev := True;
                    end;
                  if TUpRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TUpRight');
                      Prev := True;
                    end;
                  if TDownLeft in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownLeft');
                      Prev := True;
                    end;
                  if TDownCenter in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownCenter');
                      Prev := True;
                    end;
                  if TDownRight in TitlesWanted then
                    begin
                      if Prev then write(TxtWinFil, ', ');
                      write(TxtWinFil, 'TDownRight');
                    end;
                  writeln(TxtWinFil, '];');
                  writeln(TxtWinFil, '          TitleNames[Upleft] := ''', FixQuotes(TitleNames[Upleft]), ''';');
                  writeln(TxtWinFil, '          TitleNames[UpCenter] := ''', FixQuotes(TitleNames[UpCenter]), ''';');
                  writeln(TxtWinFil, '          TitleNames[UpRight] :=  ''', FixQuotes(TitleNames[UpRight]), ''';');
                  writeln(TxtWinFil, '          TitleNames[DownLeft] := ''', FixQuotes(TitleNames[DownLeft]), ''';');
                  writeln(TxtWinFil, '          TitleNames[DownCenter] := ''', FixQuotes(TitleNames[DownCenter]), ''';');
                  writeln(TxtWinFil, '          TitleNames[DownRight] := ''', FixQuotes(TitleNames[DownRight]), ''';');
                end;
            end;
          writeln(TxtWinFil, '          with Location do');
          writeln(TxtWinFil, '            begin');
          with UserWindow.Location do
            begin
              writeln(TxtWinFIl, '              Ux := ', Ux, ';');
              writeln(TxtWinFil, '              Uy := ', Uy, ';');
              writeln(TxtWinFil, '              Lx := ', Lx, ';');
              writeln(TxtWinFil, '              Ly := ', Ly, ';');
            end;
          writeln(TxtWinFil, '            end;');
          writeln(TxtWinFIl, '        end;');
          writeln(TxtWinFil, '  end;');
    end;
    close(TxtWinFil);
  end;
  begin
    MkSWindow(InputWindow);
    writeln('Choose Format:');
    writeln;
    writeln('  1. Design Window');
    writeln('  2. Typed Constant');
    writeln('  3. Init Procedure');
    writeln('  4. Cancel Save');
    case getchar('1','4') of
      '1' : SaveDesignWindow;
      '2' : SaveConstantWindow;
      '3' : SaveInitWindow;
    end;
  end;


procedure CreateWindow;
  const
    Upper = True;
    Lower = False;
  var
    Ch : Char;
    FuncKey, Done, Axis : Boolean;

  procedure BrdBgPlus;
    begin
      with DesWindow.UserWindow.Attribs do
          if BrdBgAttr < LightGray then BrdBgAttr := Succ(BrdBgAttr);
    end;
  procedure BrdBgMinus;
    begin
      with DesWindow.UserWindow.Attribs do
          if BrdBgAttr > Black then BrdBgAttr := Pred(BrdBgAttr);
    end;
  procedure BrdFgPlus;
    begin
      with DesWindow.UserWindow.Attribs do
        if BrdFgAttr < White then BrdFgAttr := Succ(BrdFgAttr);
    end;
  procedure BrdFgMinus;
    begin
      with DesWindow.UserWindow.Attribs do
        if BrdFgAttr > Black then BrdFgAttr := Pred(BrdFgAttr);
    end;
  procedure TxtBgPlus;
    begin
      with DesWindow.UserWindow.Attribs do
        if TxtBgAttr < LightGray then TxtBgAttr := Succ(TxtBgAttr);
    end;
  procedure TxtBgMinus;
    begin
      with DesWindow.UserWindow.Attribs do
        if TxtBgAttr > Black then TxtBgAttr := Pred(TxtBgAttr);
    end;
  procedure TxtFgPlus;
    begin
      with DesWindow.UserWindow.Attribs do
        if TxtFgAttr < White then TxtFgAttr := Succ(TxtFgAttr);
    end;
  procedure TxtFgMinus;
    begin
      with DesWindow.UserWindow.Attribs do
        if TxtFgAttr > Black then TxtFgAttr := Pred(TxtFgAttr);
    end;
  procedure BorderPlus;
    begin
      with DesWindow.UserWindow do
        if BorderWanted < GraphType4 then BorderWanted := Succ(BorderWanted);
    end;
  procedure BorderMinus;
    begin
      with DesWindow.UserWindow do
        if BorderWanted > NoBorder then BorderWanted := Pred(BorderWanted);
    end;
  procedure UpLeftC;
    begin
      with DesWindow.UserWindow do
        if UpLeft in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [UpLeft];
            TitleNames[Upleft] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TUpLeft];
            TitleNames[UpLeft] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for UpperLeft: ');
            TitleNames[UpLeft] := GetString(80);
            if TitleNames[UpLeft] <> '' then TitlesWanted := TitlesWanted + [UpLeft];
          end;
    end;
  procedure UpCenterC;
    begin
      with DesWindow.UserWindow do
        if UpCenter in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [UpCenter];
            TitleNames[UpCenter] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TUpCenter];
            TitleNames[UpCenter] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for UpperCenter: ');
            TitleNames[UpCenter] := GetString(80);
            if TitleNames[UpCenter] <> '' then TitlesWanted := TitlesWanted + [UpCenter];
          end;
    end;
  procedure UpRightC;
    begin
      with DesWindow.UserWindow do
        if UpRight in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [UpRight];
            TitleNames[UpRight] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TUpRight];
            TitleNames[UpRight] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for UpperRight: ');
            TitleNames[UpRight] := GetString(80);
            if TitleNames[UpRight] <> '' then TitlesWanted := TitlesWanted + [UpRight];
          end;
    end;
  procedure DownLeftC;
    begin
      with DesWindow.UserWindow do
        if DownLeft in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [DownLeft];
            TitleNames[DownLeft] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TDownLeft];
            TitleNames[DownLeft] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for DownLeft: ');
            TitleNames[DownLeft] := GetString(80);
            if TitleNames[DownLeft] <> '' then TitlesWanted := TitlesWanted + [DownLeft];
          end;
    end;
  procedure DownCenterC;
    begin
      with DesWindow.UserWindow do
        if DownCenter in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [DownCenter];
            TitleNames[DownCenter] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TDownCenter];
            TitleNames[DownCenter] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for DownCenter: ');
            TitleNames[DownCenter] := GetString(80);
            if TitleNames[DownCenter] <> '' then TitlesWanted := TitlesWanted + [DownCenter];
          end;
    end;
  procedure DownRightC;
    begin
      with DesWindow.UserWindow do
        if DownRight in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [DownRight];
            TitleNames[DownRight] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [TDownRight];
            TitleNames[DownRight] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for DownRight: ');
            TitleNames[DownRight] := GetString(80);
            if TitleNames[DownRight] <> '' then TitlesWanted := TitlesWanted + [DownRight];
          end;
    end;



  procedure TUpLeftC;
    begin
      with DesWindow.UserWindow do
        if TUpLeft in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TUpLeft];
            TitleNames[Upleft] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [Upleft];
            TitleNames[UpLeft] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TUpperLeft: ');
            TitleNames[UpLeft] := GetString(80);
            if TitleNames[UpLeft] <> '' then TitlesWanted := TitlesWanted + [TUpLeft];
          end;
    end;
  procedure TUpCenterC;
    begin
      with DesWindow.UserWindow do
        if TUpCenter in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TUpCenter];
            TitleNames[UpCenter] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [UpCenter];
            TitleNames[UpCenter] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TUpperCenter: ');
            TitleNames[UpCenter] := GetString(80);
            if TitleNames[UpCenter] <> '' then TitlesWanted := TitlesWanted + [TUpCenter];
          end;
    end;
  procedure TUpRightC;
    begin
      with DesWindow.UserWindow do
        if TUpRight in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TUpRight];
            TitleNames[UpRight] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [UpRight];
            TitleNames[UpRight] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TUpperRight: ');
            TitleNames[UpRight] := GetString(80);
            if TitleNames[UpRight] <> '' then TitlesWanted := TitlesWanted + [TUpRight];
          end;
    end;
  procedure TDownLeftC;
    begin
      with DesWindow.UserWindow do
        if TDownLeft in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TDownLeft];
            TitleNames[DownLeft] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [DownLeft];
            TitleNames[DownLeft] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TDownLeft: ');
            TitleNames[DownLeft] := GetString(80);
            if TitleNames[DownLeft] <> '' then TitlesWanted := TitlesWanted + [TDownLeft];
          end;
    end;
  procedure TDownCenterC;
    begin
      with DesWindow.UserWindow do
        if TDownCenter in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TDownCenter];
            TitleNames[DownCenter] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [DownCenter];
            TitleNames[DownCenter] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TDownCenter: ');
            TitleNames[DownCenter] := GetString(80);
            if TitleNames[DownCenter] <> '' then TitlesWanted := TitlesWanted + [TDownCenter];
          end;
    end;
  procedure TDownRightC;
    begin
      with DesWindow.UserWindow do
        if TDownRight in TitlesWanted then
          begin
            TitlesWanted := TitlesWanted - [TDownRight];
            TitleNames[DownRight] := '';
          end
        else
          begin
            TitlesWanted := TitlesWanted - [DownRight];
            TitleNames[DownRight] := '';
            MkSWindow(InputWindow);
            writeln('Enter title for TDownRight: ');
            TitleNames[DownRight] := GetString(80);
            if TitleNames[DownRight] <> '' then TitlesWanted := TitlesWanted + [TDownRight];
          end;
    end;
  procedure XPlus;
    begin
      with DesWindow.UserWindow.Location do
        case Axis of
          Upper : if Ux < 79 then Ux := Succ(Ux);
          Lower : if Lx < 79 then Lx := Succ(Lx);
        end;
    end;
  procedure XMinus;
    begin
      with DesWindow.UserWindow.Location do
        case Axis of
          Upper : if Ux > 2 then Ux := Pred(Ux);
          Lower : if Lx > 2 then Lx := Pred(Lx);
        end;
    end;
  procedure YPlus;
    begin
      with DesWindow.UserWindow.Location do
        case Axis of
          Upper : if Uy < 24 then Uy := Succ(Uy);
          Lower : if Ly < 24 then Ly := Succ(Ly);
        end;
    end;
  procedure YMinus;
    begin
      with DesWindow.UserWindow.Location do
        case Axis of
          Upper : if Uy > 2 then Uy := Pred(Uy);
          Lower : if Ly > 2 then Ly := Pred(Ly);
        end;
    end;
  procedure SwitchAxis;
    begin
      Axis := not(Axis);
    end;
  procedure HelpScreen;
    begin
      MkSWindow(DirectionsWindow);
    end;
  procedure StatusScreen;
    begin
      MkSWindow(StatusWindow);
      writeln('Current Status:');
      writeln('--------------------------------');
      writeln('Window Name:   ', DesWindow.WndName);
      write('Window Type:   ');
        case DesWindow.WndType of
          NWind : writeln('Normal Window');
          SWind : writeln('Small Window');
          RWind : writeln('Removable Window');
          SRWind: writeln('Small Removable Window');
        end;
      with DesWindow.UserWindow do
        begin
          with Attribs do
            begin
              write('Border Type:   ');
                case BorderWanted of
                  UserBorder    : writeln('User Border');
                  NoBorder      : writeln('None');
                  AllSingleLine : writeln('Single Line');
                  AllDoubleLine : writeln('Double Line');
                  TopSingleLine : writeln('Top Single Line');
                  SidSingleLine : writeln('Side Single Line');
                  GraphType1    : writeln('Graph Type 1');
                  GraphType2    : writeln('Graph Type 2');
                  GraphType3    : writeln('Graph Type 3');
                  GraphType4    : writeln('Graph Type 4');
                end;

              write('Border Colors: ');
              textcolor(BrdFgAttr); textbackground(brdbgattr);
              writeln(ColorStr(BrdFgAttr), ' on ', ColorStr(BrdBgAttr));
              textcolor(StatusWindow.Attribs.TxtFgAttr);
              textbackground(StatusWindow.Attribs.TxtBgAttr);
              write('Text Colors:   ');
              textcolor(TxtFgAttr); textbackground(txtbgattr);
              writeln(ColorStr(TxtFgAttr), ' on ', ColorStr(TxtBgAttr));
              textcolor(StatusWindow.Attribs.TxtFgAttr);
              textbackground(StatusWindow.Attribs.TxtBgAttr);
            end;
          with Location do
            begin
              writeln('Location:');
              writeln('         Upper-X: ', Ux);
              writeln('         Upper-Y: ', Uy);
              writeln('         Lower-X: ', Lx);
              writeln('         Lower-Y: ', Ly);
            end;
        end;
     Pause;
      end;
  procedure ChangeWndName;
    var
      TempStr : string[25];
    begin
      TempStr := '';
      MkSWindow(InputWindow);
      writeln('Enter new window name:');
      TempStr := GetParsedString(25, ' ');
      if TempStr <> ' ' then DesWindow.Wndname := TempStr;
    end;

  procedure LoadWindow;
    var
      DesWinFil : file of DesWindrec;
      WinFilNam : string[12];
    begin
      mkSwindow(InputWindow);
      writeln('Enter filename to load:');
      WinFilNam := Getfilename(false, loadfile);
      if WinFilNam <> ' ' then
        begin
          WinFilNam := WinFilNam + '.DW';
          if exist(WinFilNam) then
            begin
              assign(DesWinFil, WinFilNam);
              reset(DesWinFil);
              {$I-} read(DesWinFil, DesWindow); {$I+}
              if IOResult <> 0 then write('ERROR');
             end
          else
            writeln('File not found.');
        end;
    end;

  procedure EnterText;
  const
    uparrow = #72;
    leftarrow = #75;
    rightarrow = #77;
    downarrow = #80;

  procedure SetXY(X, Y : integer);
    begin
      gotoxy(x,y);
    end;
  procedure HandleFuncKey(ch : char);
  begin
    case ch of
      uparrow : setxy(wherex,wherey-1);
      leftarrow : setxy(wherex-1, wherey);
      rightarrow : setxy(wherex+1,wherey);
      downarrow : setxy(wherex, wherey+1);
    end;
  end; { of proc handlefunckey }

  procedure handlekey (ch :char);
  const
    bs = #8;
    cr = #13;
    sp = #32;
  begin
    case ch of
      BS : write(bs, sp, bs);
      CR : writeln;
      ' '..'z' : write(ch);
    end;
  end; { of proc handlekey }


  begin
    repeat
      ch := readkey;
      if ch = #0
        then handlefunckey(readkey)
        else handlekey(ch);
    until ch = #27;
  end;


  procedure ChangeWndType;
    var
      ch : char;
    begin
      mkSwindow(inputwindow);
      writeln('(N)ormal Window');
      writeln('(R)emovable Window');
      writeln('(S)mall Window');
      writeln('Small Removable (W)indow');
      repeat
        ch := upcase(readkey);
      until ch in ['N','R','S','W'];
      case ch of
        'N' : DesWindow.Wndtype := NWind;
        'R' : DesWindow.Wndtype := RWind;
        'S' : DesWindow.Wndtype := SWind;
        'W' : DesWindow.Wndtype := SRWind;
      end;
    end;

  procedure Process(ch : char);
    const
      F1 = #59;
      F2 = #60;
      F3 = #61;
      F4 = #62;
      F5 = #63;
      F6 = #64;
      F7 = #65;
      F8 = #66;
      F9 = #67;
      F10 = #68;
      SF1 = #84;
      SF2 = #85;
      SF3 = #86;
      SF4 = #87;
      SF5 = #88;
      SF6 = #89;
      AltF1 = #104;
      AltF2 = #105;
      AltF3 = #106;
      AltF4 = #107;
      AltF5 = #108;
      AltF6 = #109;
      AltF7 = #110;
      AltF8 = #111;
      AltF9 = #112;
      AltF10 = #113;
      AltL = #38;
      AltS = #31;
      AltE = #18;
      LeftArrow = #75;
      RightArrow = #77;
      UpArrow = #72;
      DownArrow = #80;
      Ins = #82;

    begin
          case Ch of
            F1 : HelpScreen;

            SF1 : ChangeWndName;

            F2 : StatusScreen;

            SF2 : ChangeWndType;

            F3 : BrdBgPlus;

            F4 : BrdBgMinus;

            SF3 : BrdFgPlus;

            SF4 : BrdFgMinus;

            F5 : TxtBgPlus;

            F6 : TxtBgMinus;

            SF5 : TxtFgPlus;

            SF6 : TxtFgMinus;

            F7 : BorderPlus;

            F8 : BorderMinus;

            AltF1 : UpleftC;

            AltF2 : UpCenterC;

            AltF3 : UpRightC;

            AltF4 : DownLeftC;

            AltF5 : DownCenterC;

            AltF6 : DownRightC;

            AltF7 : TUpleftC;

            AltF8 : TUpCenterC;

            AltF9 : TUpRightC;

            AltF10 : TDownLeftC;

            AltL : LoadWindow;

            AltS : SaveWindow;

            AltE : EnterText;

            F9 : TDownCenterC;

            F10 : TDownRightC;

            LeftArrow : XMinus;

            RightArrow : XPlus;

            UpArrow : YMinus;

            DownArrow : YPlus;

            Ins : SwitchAxis;
         end;
    end;

procedure Menu;
  begin
  end;

  begin
    clrscr;
    Done := False;
    Axis := True;
    DesWindow.WndType := NWind;
    DesWindow.WndName := 'NewWind';
    repeat
      TextBackGround(Black);
      window(1,1,80,25);
      clrscr;
      MkWindow(DesWindow.UserWindow);
      writeln('Text Attributes');
      ch := Readkey;
      if upcase(ch) = 'Q' then
        Done := True
      else if ch = '/' then
        Menu
      else if ch = #0 then
             begin
               funckey := true;
               ch := readkey;
               Process(ch);
             end;
    until Done;
  end;





begin
  textmode(c80);
  InitWindows;
  TitleScreen;
  repeat
    Window(1,1,80,25);
    clrscr;
    CreateWindow;
    MkSWindow(InputWindow);
    write('Save Window? ');
    if GetYesNo then SaveWindow;
    MkSWindow(InputWindow);
    write('Create Another? ');
    InitUserWindow;
  until GetYesNo = False;
end.

