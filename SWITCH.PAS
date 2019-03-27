program Switch;

uses crt, graph;

{
 Switch.Pas
           by Paul Henson

 Indirect portation of similiar code written in QuickBasic 4.0 by Paul Henson,
 which code was also an indirect portation of similiar code written in
 Commodore Basic 7.0 and implemented on a Commodore 128 by Paul Henson and
 Chris Bouffard.

 Original publication of 128 code: Never done.
 Original publication of QB 4.0 code: '88.

}

const
  Null = 0;
  NoFlip = False;
  DoFlip = True;
  Normal = False;
  Testing = True;
  NoCount = False;
  DoCount = True;
  ForeG = 7;
  BackG = 1;
  Tied = 5;
  AcrossIncrease = 45;
  DownIncrease = 42;
  ArraySize = 457;
  GridForeGround = Cyan;
  GridBackGround = Blue;
  PointerForeGround = Magenta;
  WhitePieceColor = White;
  BlackPieceColor = Black;
  XOffset = 4;
  YOffset = 5;
  BalanceX = 497;
  BalanceY = 315;
  LineUX = BalanceX - 60;
  LineUY = BalanceY - 108;
  LineLY = BalanceY - 105;
  LineLX = BalanceX + 60;
  WhiteBasketX = BalanceX + 40;
  BlackBasketX = BalanceX - 80;
  BasketY = BalanceY - 104;
  WaitLength = 100;

type
  PossibleColors = (BlackPlayer, WhitePlayer, Empty, Computer, Person);
  ImageType = array[1..918] of byte;
  PieceTypes = (NormalPiece, Part1, Part2, Part3, Part4, Part5, Part6);
  PointerTypes = (NormalPointer, WhitePointer, BlackPointer, EmptyPointer);
  BasketType = array[1..1566] of byte;

{ Global Variables }
var
  UsingJoystick,
  ComputerPlaying,
  Demo : boolean;
  ComputerColor : PossibleColors;
  CurrentPlayer,
  OpposingPlayer : PossibleColors;
  XPosition,
  YPosition : byte;
  Grid : array[1..8,1..8] of PossibleColors;
  BlackTotal, WhiteTotal : byte;
  WhitePiece,
  BlackPiece : array[NormalPiece..Part6] of ImageType;
  Pointers : array[NormalPointer..EmptyPointer] of ImageType;
  WhiteBasket,
  BlackBasket : BasketType;
  Difference : integer;
  NullLegalMove : boolean;
  NullNumFlipped : integer;



procedure TitleScreen;
  begin
    textcolor(ForeG);
    textbackground(BackG);
    clrscr;
    if keypressed then
      exit;
    writeln('                         ษออออออออออออออออออออออออออป');
    writeln('                         บ  Switch --- Version 1.4  บ');
    writeln('                         ศออออหอออออออออออออออออหอออผ');
    writeln('                              บ   Paul Henson   บ');
    writeln('                              ำฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฝ');
    write('ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ');
    write('ณ                                Shareware                                 ณ');
    write('ณ                                  ฤฤฤฤฤฤฤฤฤ                                   ณ');
    write('ณ  There was much time and effort spent in programming Switch. If you use and  ณ');
    write('ณ  enjoy Switch, a small donation of any amount would be greatly appreciated.  ณ');
    write('ณ  If you do not send a donation, yet continue to use Switch, well, I dare say ณ');
    write('ณ  that''s a personal problem. Not much I can do about it, is there?            ณ');
    write('รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด');
    write('ณ   Copyright ''88, ''89 by Paul Henson   ณ                                      ณ');
    write('ณ                                       ณ Send all donations, suggestions,     ณ');
    write('ณ               ÛÛÛÛÛÛÛÛ                ณ criticism, fan mail, or whatever to: ณ');
    write('ณ              ÛÛÛÛÛÛÛÛÛÛ               ณ                                      ณ');
    write('ณ             ÛÛÛÛÛÛÛÛÛÛÛÛ              ณ                                      ณ');
    write('ณ            ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ             ณ           Paul Henson                ณ');
    write('ณ             ÛÛÛÛÛÛÛÛÛÛÛÛ              ณ           5331 Buffington Rd.        ณ');
    write('ณ              ÛÛÛÛÛÛÛÛÛÛ               ณ           El Monte, CA 91732         ณ');
    write('ณ               ÛÛÛÛÛÛÛÛ                ณ                                      ณ');
    write('ณ                                       ณ                                      ณ');
    write('ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู');

    repeat
    until keypressed;
  end;

procedure SelectMode;
  var
    Choice,
    Selection : char;
  begin
    clrscr;
    gotoxy(1,6);
    writeln('                      ีอออออออออออออออออออออออออออออออออออธ');
    writeln('                      ณ How would you like to play today? ณ');
    writeln('                      ิออออัออออออออออออออออออออออออัอออออพ');
    writeln('                           ณ 1. Human vs. Human     ณ');
    writeln('                           ณ 2. Human vs. Computer  ณ');
    writeln('                           ณ 3. Demo                ณ');
    writeln('                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู');
    repeat
      Choice := readkey;
      if Choice = '1' then
        ComputerPlaying := False;
      if Choice = '2' then
        begin
          ComputerPlaying := True;
          clrscr;
          gotoxy(1,2);
          writeln('               ีออออออออออออออออออออออออออออออออออออออออออออออออออธ');
          writeln('               ณ So you want to pick on a poor dumb computer, eh? ณ');
          writeln('               ิออออออออออออออออออออออออออออออออออออออออออออออออออพ');
          gotoxy(1,9);
          writeln('                              ึฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท');
          writeln('                              บ Do you wish to play บ');
          writeln('                              ำฤาฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤาฤฝ');
          writeln('                                บ (W)hite pieces? บ');
          writeln('                                บ                 บ');
          writeln('                                บ (B)lack pieces? บ');
          writeln('                                ำฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฝ');
          repeat
            Selection := readkey;
            if (Selection = 'W') or (Selection = 'w') then
              ComputerColor := BlackPlayer;
            if (Selection = 'B') or (Selection = 'b') then
              ComputerColor := WhitePlayer;
          until (Selection = 'W') or (Selection = 'w') or (Selection = 'B') or (Selection = 'b');
        end;
      if Choice = '3' then
        Demo := True;
    until (Choice = '1') or (Choice = '2') or (Choice = '3');
  end;

procedure JoyStick;
  begin
{  if not UsingJoyStick and STICK(0) > 0 AND STICK(1) > 0 THEN
  UsingJoyStick = True
  CLS
  LOCATE 7, 1
  PRINT "                       ึฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤท"
  PRINT "                       บ A joystick has been detected. บ"
  PRINT "                       ำฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฝ"
  LOCATE 16, 1
  PRINT "                              Joystick Calibration"
  PRINT "                              ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ"
  PRINT ""
  PRINT "                      Position joystick to the Upper-Left."
  PRINT ""
  PRINT "                 ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ"
  PRINT "                 ณ Press any key to continue or Esc to abort. ณ"
  PRINT "                 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู"
  WHILE INKEY$ <> "" OR STRIG(1) OR STRIG(5): WEND
  DO
    Choice = INKEY$
    IF Choice = CHR$(27) THEN
      UsingJoyStick = False
      EXIT SUB
    END IF
  LOOP UNTIL Choice <> "" OR STRIG(1) OR STRIG(5)
  Left = STICK(0) + 20
  Up = STICK(1) + 20

  WHILE INKEY$ <> "" OR STRIG(1) OR STRIG(5): WEND
  LOCATE 19, 48
  PRINT "Lower-Right.";
  DO
    Choice = INKEY$
    IF Choice = CHR$(27) THEN
      UsingJoyStick = False
      EXIT SUB
    END IF
  LOOP UNTIL Choice <> "" OR STRIG(1) OR STRIG(5)
  Right = STICK(0) - 20
  Down = STICK(1) - 20

  END IF
END SUB}

  end;

procedure InitGrid;
  var
    X, Y : byte;
  begin
    for X := 1 to 8 do
      for Y := 1 to 8 do
        Grid[X, Y] := Empty;
    CurrentPlayer := BlackPlayer;
    OpposingPlayer := WhitePlayer;
    XPosition := 1;
    YPosition := 1;
    WhiteTotal := 0;
    BlackTotal := 0;
    Difference := 0;
    Grid[4, 4] := WhitePlayer;
    Grid[5, 5] := WhitePlayer;
    Grid[5, 4] := BlackPlayer;
    Grid[4, 5] := BlackPlayer;
  end;

procedure RestorePointer(GridContents : PossibleColors);
  var
    RealX,
    RealY : integer;
  begin
    RealX := ((XPosition - 1) * AcrossIncrease) + XOffset;
    RealY := ((YPosition - 1) * DownIncrease) + YOffset;
    case GridContents of
      WhitePlayer : putimage(RealX, RealY, Pointers[WhitePointer],NormalPut);
      BlackPlayer : putimage(RealX, RealY, Pointers[BlackPointer], NormalPut);
      Empty : putimage(RealX, RealY, Pointers[NormalPointer], NormalPut);
    end;
  end;


procedure MakePiece(Xlocation, Ylocation : byte; Side : PossibleColors; DoFlip : boolean);
  var
    RealX,
    RealY : integer;
    Count : PieceTypes;

  begin
    RealX := ((Xlocation - 1) * AcrossIncrease) + XOffset;
    RealY := ((Ylocation - 1) * DownIncrease) + YOffset;
    if DoFlip then
      begin
        if Side = BlackPlayer then
          begin
            for Count := Part1 to Part6 do
              begin
                putimage(RealX, RealY, WhitePiece[Count], NormalPut);
                delay(WaitLength);
              end;
            for Count := Part6 downto NormalPiece do
              begin
                putimage(RealX, RealY, BlackPiece[Count], NormalPut);
                delay(WaitLength);
              end;
            dec(WhiteTotal);
            inc(BlackTotal);
          end
        else
          begin
            for Count := Part1 to Part6 do
              begin
                putimage(RealX, RealY, BlackPiece[Count], NormalPut);
                delay(WaitLength);
              end;
            for Count := Part6 downto NormalPiece do
              begin
                putimage(RealX, RealY, WhitePiece[Count], NormalPut);
                delay(WaitLength);
              end;
            dec(BlackTotal);
            inc(WhiteTotal);
          end;
      end
    else
      begin
        if Side = WhitePlayer then
          begin
            putimage(RealX, RealY, WhitePiece[NormalPiece], NormalPut);
            inc(WhiteTotal);
          end
        else
          begin
            putimage(RealX, RealY, BlackPiece[NormalPiece], NormalPut);
            inc(BlackTotal);
          end;
  end;
  end;


procedure MakeBoard;
  const
    StartX = 3;
    StartY = 3;
  var
    Xloc,
    Yloc : integer;
  begin
{    RemovePalette}
    setfillstyle(SolidFill, GridBackGround);
    bar(0, 0, 366, 342);
    Xloc := StartX;
    Yloc := StartY;
    setcolor(GridForeGround);
    repeat
      repeat
        rectangle(Xloc, Yloc, Xloc + AcrossIncrease, Yloc + DownIncrease);
        Xloc := Xloc + AcrossIncrease;
      until Xloc = (AcrossIncrease * 8) + StartX;
      Yloc := Yloc + DownIncrease;
      Xloc := StartX;
    until Yloc = (DownIncrease * 8) + StartY;
    MakePiece(4, 4, WhitePlayer, NoFlip);
    MakePiece(5, 5, WhitePlayer, NoFlip);
    MakePiece(5, 4, BlackPlayer, NoFlip);
    MakePiece(4, 5, BlackPlayer, NoFlip);
    setcolor(8);
    ellipse(BalanceX, BalanceY, 0, 360, 35, 8);
    setcolor(1);
    floodfill(BalanceX, BalanceY, 8);
    setcolor(8);
    rectangle(BalanceX - 4, BalanceY, BalanceX + 4, BalanceY - 100);
    setfillstyle(SolidFill, 9);
    bar(BalanceX - 3, BalanceY + 1, BalanceX + 3, BalanceY - 100);
    setcolor(8);
    ellipse(BalanceX, BalanceY - 96, 30, 200, 4, 8);
    setcolor(9);
    floodfill(BalanceX, BalanceY - 100, 8);
    setcolor(8);
    line(LineUX, LineUY, LineUX, LineLY);
    line(LineUX, LineLY, LineLX, LineLY);
    line(LineLX, LineLY, LineLX, LineUY);
    line(LineLX, LineUY, LineUX, LineUY);
    setcolor(9);
    floodfill(LineUX + 1, LineUY + 1 ,8);
    putimage(BlackBasketX, BasketY, BlackBasket, XORPut);
    putimage(WhiteBasketX, BasketY, WhiteBasket, XORPut);
    setcolor(8);
    outtextxy(400, 330, ' Black ='+'100'); {BlackTotal}
    setcolor(15);
    outtextxy(500, 330, 'White ='+'100'); {WhiteTotal}
    setcolor(1);
    rectangle(375, 6, 638, 150);
    setcolor(1);
    line(375, 30, 638, 30);
    setcolor(15);
    outtextxy(385,15, 'Current Player:');

    RestorePointer(Empty);
{    RestorePalette}
  end;



procedure Initilize;
  const
    CircleSize = 17;
    CircleAspect = 1;
    CircleX = 23;
    CircleY = 20;
    GetX = 1;
    GetXB = 44;
    GetY = 1;
    GetYB = 38;
  var
    GraphDriver,
    GraphMode : integer;
    temp : string;

  begin
    GraphDriver := EGA;
    Graphmode := EGAHi;
    initgraph(GraphDriver, GraphMode, 'C:\tp\bgi');
{    RemovePalette}
  setfillstyle(SolidFill, GridBackGround);
  bar(GetX - 1, GetY - 1, GetXB + 1, GetYB + 1);
  getimage(GetX, GetY, GetXB, GetYB, Pointers[EmptyPointer]);

  setcolor(WhitePieceColor);
  ellipse(CircleX, CircleY, 0,360,CircleSize,CircleSize);
  setfillstyle(solidfill, WhitePieceColor);
  floodfill(CircleX, CircleY, WhitePieceColor);

  setfillstyle(SolidFill, PointerForeGround);
  bar(21, 4, 25, 16);
  bar(21, 37, 25, 24);
  bar(6, 18, 18, 21);
  bar(28, 18, 40, 21);
  getimage(GetX, GetY, GetXB, GetYB, Pointers[WhitePointer]);

  setcolor(BlackPieceColor);
  ellipse(CircleX, CircleY, 0,360,CircleSize,CircleSize);
  setfillstyle(solidfill, blackpiececolor);
  floodfill(CircleX, CircleY, BlackPieceColor);
  setfillstyle(Solidfill,PointerForeGround);
  bar(21, 4, 25, 16);
  bar(21, 37, 25, 24);
  bar(6, 18, 18, 21);
  bar(28, 18, 40, 21);
  getimage(GetX, GetY, GetXB, GetYB, Pointers[BlackPointer]);
  setfillstyle(SolidFill, GridBackGround);
  bar(GetX, GetY, GetXB, GetYB);
  setcolor(WhitePieceColor);
  ellipse(CircleX, CircleY, 0,360,CircleSize, CircleSize);
  setfillstyle(solidfill, WhitepIececolor);
  floodfill(CircleX, CircleY, WhitePieceColor);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[NormalPiece]);
  setfillstyle(solidfill,GridBackGround);
  bar(GetX, GetY + 2, GetXB, GetY + 3);
  bar(GetX, GetYB - 1, GetXB, GetYB - 2);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part1]);
  bar(GetX, GetY + 4, GetXB, GetY + 5);
  bar(GetX, GetYB - 3, GetXB, GetYB - 4);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part2]);
  bar(GetX, GetY + 6, GetXB, GetY + 7);
  bar(GetX, GetYB - 5, GetXB, GetYB - 6);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part3]);
  bar(GetX, GetY + 8, GetXB, GetY + 9);
  bar(GetX, GetYB - 7, GetXB, GetYB - 8);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part4]);
  bar(GetX, GetY + 10, GetXB, GetY + 11);
  bar(GetX, GetYB - 9, GetXB, GetYB - 10);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part5]);
  bar(GetX, GetY + 12, GetXB, GetY + 14);
  bar(GetX, GetYB - 10, GetXB, GetYB - 13);
  getimage(GetX, GetY, GetXB, GetYB, WhitePiece[Part6]);

  bar(GetX, GetY, GetXB, GetYB);
  setcolor(BlackPieceColor);
  ellipse(CircleX, CircleY, 0,360,CircleSize, CircleSize);
  setfillstyle(solidfill, Blackpiececolor);
  floodfill(CircleX, CircleY, BlackPieceColor);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[NormalPiece]);
  setfillstyle(solidfill,GridBackGround);
  bar(GetX, GetY + 2, GetXB, GetY + 3);
  bar(GetX, GetYB - 1, GetXB, GetYB - 2);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part1]);
  bar(GetX, GetY + 4, GetXB, GetY + 5);
  bar(GetX, GetYB - 3, GetXB, GetYB - 4);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part2]);
  bar(GetX, GetY + 6, GetXB, GetY + 7);
  bar(GetX, GetYB - 5, GetXB, GetYB - 6);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part3]);
  bar(GetX, GetY + 8, GetXB, GetY + 9);
  bar(GetX, GetYB - 7, GetXB, GetYB - 8);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part4]);
  bar(GetX, GetY + 10, GetXB, GetY + 11);
  bar(GetX, GetYB - 9, GetXB, GetYB - 10);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part5]);
  bar(GetX, GetY + 12, GetXB, GetY + 14);
  bar(GetX, GetYB - 10, GetXB, GetYB - 13);
  getimage(GetX, GetY, GetXB, GetYB, BlackPiece[Part6]);

  setfillstyle(solidfill, Gridbackground);
  bar(GetX, GetY, GetXB, GetYB);
  setfillstyle(solidfill, PointerForeGround);
  bar(21, 4, 25, 16);
  bar(21, 37, 25, 24);
  bar(6, 18, 18, 21);
  bar(28, 18, 40, 21);
  getimage(GetX, GetY, GetXB, GetYB, Pointers[NormalPointer]);

  setfillstyle(SolidFill, 0);
  bar(0, 0, 100, 100);
  setcolor(8);
  ellipse(21,61,0,360,20,4);
  setfillstyle(solidfill, 14);
  floodfill(21,61,8);
  setcolor(7);
  line(1, 61, 21, 1);
  line(41, 61, 21, 1);
  setcolor(0);
  ellipse(21,61,0,360,5,1);
  setfillstyle(solidfill, 0);
  floodfill(21, 61, 0);
  getimage(1, 1, 41, 65, BlackBasket);
  setcolor(15);
  ellipse(21,61,0,360,5,1);
  setfillstyle(solidfill, 15);
  floodfill(21, 61, 15);
  getimage(1, 1, 41, 65, WhiteBasket);


  InitGrid;
  MakeBoard;
{  RestorePalette
 }

  end;

procedure UpdateBalance;
  var
    Bar : array[1..4] of PointType;
  begin
    if Difference = (BlackTotal - WhiteTotal) then
      exit;

    setfillstyle(solidfill,0);
    floodfill(LineUX+1, LineUY+2+Difference, 8);
    setcolor(0);
    line(LineUX, LineUY+Difference, LineUX, LineLY+Difference);
    line(LineUX, LineLY+Difference, LineLX, LineLY - Difference);
    line(LineLX, LineLY -difference, LineLX, LineUY-Difference);
    line(LineLX, LineUY-Difference, LineUX, LineUY+Difference);
    putimage(BlackBasketX, BasketY+Difference, BlackBasket, XORPut);
    putimage(WhiteBasketX, BasketY-Difference, WhiteBasket, XORPut);

    Difference := BlackTotal - WhiteTotal;

    setcolor(8);
    line(LineUX, LineUY+Difference, LineUX, LineLY+Difference);
    line(LineUX, LineLY+Difference, LineLX, LineLY - Difference);
    line(LineLX, LineLY -difference, LineLX, LineUY-Difference);
    line(LineLX, LineUY-Difference, LineUX, LineUY+Difference);
    setfillstyle(solidfill,9);
    floodfill(LineUX+1, LineUY+2+Difference, 8);
    putimage(BlackBasketX, BasketY+Difference, BlackBasket, XORPut);
    putimage(WhiteBasketX, BasketY-Difference, WhiteBasket, XORPut);

    {  COLOR 8
      IF BlackTotal > 9 THEN
          LOCATE 24, 48
            ELSE
                LOCATE 24, 49
                  END IF
                    PRINT " Black ="; STR$(BlackTotal); " ";
                      COLOR 15
                        LOCATE 24, 68
                          PRINT "White ="; STR$(WhiteTotal); " ";}

  end;

procedure WriteName(NameToWrite : PossibleColors);
  begin
    case NameToWrite of
      WhitePlayer : begin
                      setcolor(15);
                      outtextxy(500,100, 'White');
                    end;
      BlackPlayer : begin
                      setcolor(8);
                      outtextxy(500,100, 'Black');
                    end;
      Computer    : begin
                      setcolor(1);
                      outtextxy(500,100, 'Computer');
                    end;
    end;
  end;



procedure UpdateScreen;
  begin
    if (ComputerPlaying and (ComputerColor = CurrentPlayer)) or Demo then
      WriteName(Computer)
    else
      if CurrentPlayer = BlackPlayer then
        WriteName(BlackPlayer)
      else
        WriteName(WhitePlayer);
    UpdateBalance;
  end;

procedure RemovePointer(GridContents : PossibleColors);
  var
    RealX, RealY : integer;
  begin
    RealX := ((XPosition - 1) * AcrossIncrease) + XOffset;
    RealY := ((YPosition - 1) * DownIncrease) + YOffset;
    case GridContents of
      WhitePlayer : putimage(RealX, RealY, WhitePiece[NormalPiece], NormalPut);
      BlackPlayer : putimage(RealX, RealY, BlackPiece[NormalPiece], NormalPut);
      Empty       : putimage(RealX, RealY, Pointers[EmptyPointer], NormalPut);
    end;
  end;


procedure GetInput;
  var
    Choice : char;
  begin
    repeat

      if (ComputerPlaying and (CurrentPlayer=ComputerColor)) or Demo then
        if {ComputerMove} false then
          begin
{            CheckMoves;
            UpdateScreen;}
          end;



    Choice := readkey;

    case Choice of
      '8' : if YPosition > 1 then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                dec(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '6' : if XPosition < 8 then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                inc(XPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '2' : if YPosition < 8 then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                inc(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '4' : if XPosition > 1 then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                dec(XPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;

      '7' : if (XPosition > 1) and (YPosition > 1) then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                dec(XPosition);
                dec(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '9' : if (XPosition < 8) and (YPosition > 1) then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                inc(XPosition);
                dec(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '1' : if (XPosition > 1) and (YPosition < 8) then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                dec(XPosition);
                inc(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;
      '3' : if (XPosition < 8) and (YPosition < 8) then
              begin
                RemovePointer(Grid[XPosition, YPosition]);
                inc(XPosition);
                inc(YPosition);
                RestorePointer(Grid[XPosition, YPosition]);
              end;

        ' ' : exit;

        #27 : halt(0);
     end;
    until false;
  end;

procedure SwitchPlayers;
  var
    Temp : PossibleColors;
  begin
    Temp := CurrentPlayer;
    CurrentPlayer := OpposingPlayer;
    OpposingPlayer := Temp;
  end;


procedure ProcessInput(Test, Count : Boolean; var LegalMove : boolean; var NumFlipped : integer);
  var
    XIndex,
    YIndex,
    XCount,
    YCount : byte;

  begin

  LegalMove := False;
  NumFlipped := 0;

  if Grid[XPosition, YPosition] <> Empty then
    exit;

  if YPosition > 2 then             {Up}
    if Grid[XPosition, YPosition - 1] = OpposingPlayer then
      begin
        YCount := YPosition - 1;
        repeat
          begin
            dec(YCount);
            if Grid[XPosition, YCount] = CurrentPlayer then
              begin
                if Test then
                  begin
                    LegalMove := true;
                    exit;
                  end;
                if (not Count) then
                  begin
                    RemovePointer(Grid[XPosition, YPosition]);
                    MakePiece(XPosition, YPosition, CurrentPlayer, NoFlip);
                    Grid[XPosition, YPosition] := CurrentPlayer;
                  end;
                for YIndex := (YPosition -1) downto (YCount + 1) do
                  begin
                    if (not Count) then
                      begin
                        Grid[XPosition, YIndex] := CurrentPlayer;
                        MakePiece(XPosition, YIndex, CurrentPlayer, DoFlip);
                      end;
                    inc(NumFlipped);
                  end;
                LegalMove := True;
              end;
          end;
        until (YCount = 1) or (Grid[XPosition, YCount] = Empty);
      end;


  if (YPosition > 2) and (XPosition < 7) then             {UpRight}
    if Grid[XPosition + 1, YPosition - 1] = OpposingPlayer then
      begin
        YCount := YPosition - 1;
        XCount := XPosition + 1;
        repeat
          begin
            inc(XCount);
            dec(YCount);
            if Grid[XCount, YCount] = CurrentPlayer then
              begin
                if Test then
                  begin
                    LegalMove := true;
                    exit;
                  end;
                if (not Count) then
                  begin
                    RemovePointer(Grid[XPosition, YPosition]);
                    MakePiece(XPosition, YPosition, CurrentPlayer, NoFlip);
                    Grid[XPosition, YPosition] := CurrentPlayer;
                  end;
                XIndex := XPosition;
                YIndex := YPosition;

                repeat
                  begin
                    inc(XIndex);
                    dec(YIndex);
                    if (not LegalMove) and (not Count) then
                      begin
                        Grid[XIndex, YIndex] := CurrentPlayer;
                        MakePiece(XIndex, YIndex, CurrentPlayer, DoFlip);
                      end;
                    inc(NumFlipped);
                  end;
                until (XIndex = XCount -1);
                LegalMove := True;
              end;
          end;
        until (YCount = 1) or (XCount = 8) or (Grid[XCount, YCount] = Empty);
      end;


  if XPosition < 7 then {Right}
    if Grid[XPosition + 1, YPosition] = OpposingPlayer then
      begin
        XCount := XPosition + 1;
        repeat
          begin
            inc(XCount);
            if Grid[XCount, YPosition] = CurrentPlayer then
              begin
               if Test then
                 begin
                   LegalMove := True;
                   exit;
                 end;
               if (not LegalMove) and (not Count) then
                 begin
                   RemovePointer(Grid[XPosition, YPosition]);
                   MakePiece(XPosition, YPosition, CurrentPlayer, NoFlip);
                   Grid[XPosition, YPosition] := CurrentPlayer;
                 end;
               for XIndex := (XPosition + 1) to (XCount - 1) do
                 begin
                   if (not Count) then
                     begin
                       Grid[XIndex, YPosition] := CurrentPlayer;
                       MakePiece(XIndex, YPosition, CurrentPlayer, DoFlip);
                     end;
                    inc(NumFlipped);
                 end;
               LegalMove = True
          end;
        until (XCount = 8) or (Grid[XCount, YPosition] = Empty);
      end;

  {IF (YPosition < 8 AND XPosition < 8) THEN 'DownRight
    IF Grid(XPosition + 1, YPosition + 1) = OpposingPlayer THEN
      XCount = XPosition + 1
      YCount = YPosition + 1
      DO WHILE XCount < 8 AND YCount < 8
        XCount = XCount + 1
        YCount = YCount + 1
        IF Grid(XCount, YCount) = Blank THEN EXIT DO
        IF Grid(XCount, YCount) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT LegalMove THEN
            IF NOT Count THEN
              RemovePointer Grid(XPosition, YPosition)
              MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
              Grid(XPosition, YPosition) = CurrentPlayer
            END IF
          END IF
          XIndex = XPosition
          YIndex = YPosition
          DO
            XIndex = XIndex + 1
            YIndex = YIndex + 1
            IF NOT Count THEN
              Grid(XIndex, YIndex) = CurrentPlayer
              MakePiece XIndex, YIndex, CurrentPlayer, DoFlip
            END IF
            NumFlipped = NumFlipped + 1
          LOOP UNTIL XIndex = XCount - 1
          LegalMove = True
          EXIT DO
        END IF
      LOOP
    END IF
  END IF
  IF YPosition < 8 THEN 'Down
    IF Grid(XPosition, YPosition + 1) = OpposingPlayer THEN
      YCount = YPosition + 1
      DO WHILE YCount < 8
        YCount = YCount + 1
        IF Grid(XPosition, YCount) = Blank THEN EXIT DO
        IF Grid(XPosition, YCount) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT LegalMove THEN
            IF NOT Count THEN
              RemovePointer Grid(XPosition, YPosition)
              MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
              Grid(XPosition, YPosition) = CurrentPlayer
            END IF
          END IF
          FOR YIndex = YPosition + 1 TO YCount - 1
            IF NOT Count THEN
              Grid(XPosition, YIndex) = CurrentPlayer
              MakePiece XPosition, YIndex, CurrentPlayer, DoFlip
            END IF
            NumFlipped = NumFlipped + 1
          NEXT
          LegalMove = True
          EXIT DO
        END IF
      LOOP
    END IF
  END IF
  IF (XPosition > 1 AND YPosition < 8) THEN 'DownLeft
    IF Grid(XPosition - 1, YPosition + 1) = OpposingPlayer THEN
      XCount = XPosition - 1
      YCount = YPosition + 1
      DO WHILE XCount > 1 AND YCount < 8
        XCount = XCount - 1
        YCount = YCount + 1
        IF Grid(XCount, YCount) = Blank THEN EXIT DO
        IF Grid(XCount, YCount) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT LegalMove THEN
            IF NOT Count THEN
              RemovePointer Grid(XPosition, YPosition)
              MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
              Grid(XPosition, YPosition) = CurrentPlayer
            END IF
          END IF
          XIndex = XPosition
          YIndex = YPosition
          DO
            XIndex = XIndex - 1
            YIndex = YIndex + 1
            IF NOT Count THEN
              Grid(XIndex, YIndex) = CurrentPlayer
              MakePiece XIndex, YIndex, CurrentPlayer, DoFlip
            END IF
            NumFlipped = NumFlipped + 1
          LOOP UNTIL XIndex = XCount + 1
          LegalMove = True
          EXIT DO
        END IF
      LOOP
    END IF
  END IF
  IF XPosition > 1 THEN 'Left
    IF Grid(XPosition - 1, YPosition) = OpposingPlayer THEN
      XCount = XPosition - 1
      DO WHILE XCount > 1
        XCount = XCount - 1
        IF Grid(XCount, YPosition) = Blank THEN EXIT DO
        IF Grid(XCount, YPosition) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT LegalMove THEN
            IF NOT Count THEN
              RemovePointer Grid(XPosition, YPosition)
              MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
              Grid(XPosition, YPosition) = CurrentPlayer
            END IF
          END IF
          FOR XIndex = XPosition - 1 TO XCount + 1 STEP -1
            IF NOT Count THEN
              Grid(XIndex, YPosition) = CurrentPlayer
              MakePiece XIndex, YPosition, CurrentPlayer, DoFlip
            END IF
            NumFlipped = NumFlipped + 1
          NEXT
          LegalMove = True
          EXIT DO
        END IF
      LOOP
    END IF
  END IF
  IF (XPosition > 1 AND YPosition > 1) THEN
    IF Grid(XPosition - 1, YPosition - 1) = OpposingPlayer THEN
      XCount = XPosition - 1
      YCount = YPosition - 1
      DO WHILE XCount > 1 AND YCount > 1
        XCount = XCount - 1
        YCount = YCount - 1
        IF Grid(XCount, YCount) = Blank THEN EXIT DO
        IF Grid(XCount, YCount) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT LegalMove THEN
            IF NOT Count THEN
              RemovePointer Grid(XPosition, YPosition)
              MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
              Grid(XPosition, YPosition) = CurrentPlayer
            END IF
          END IF
          XIndex = XPosition
          YIndex = YPosition
          DO
            XIndex = XIndex - 1
            YIndex = YIndex - 1
            IF NOT Count THEN
              Grid(XIndex, YIndex) = CurrentPlayer
              MakePiece XIndex, YIndex, CurrentPlayer, DoFlip
            END IF
            NumFlipped = NumFlipped + 1
          LOOP UNTIL XIndex = XCount + 1
          LegalMove = True
          EXIT DO
        END IF
      LOOP
    END IF
  END IF
}
    if LegalMove and (not Count) then
      begin
        RestorePointer(Grid[XPosition, YPosition]);
        SwitchPlayers;
      end;

  end;


begin
  TitleScreen;
  UsingJoystick := False;
  Demo := False;
  SelectMode;
{  Joystick;}

  Initilize;

  repeat
    UpdateScreen;
    GetInput;
    ProcessInput(Normal, NoCount, NullLegalMove, NullNumFlipped);
{    CheckMoves;}
  until false;

end.
{

SUB CheckCorners (MaxFlipped AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
DIM TotalFlipped AS INTEGER

  XPosition = 1
  YPosition = 1
  ProcessInput Normal, DoCount, Null, TotalFlipped
    IF TotalFlipped > MaxFlipped THEN
      MaxFlipped = TotalFlipped
      ToMoveX = XPosition
      ToMoveY = YPosition
    END IF
  XPosition = 8
  YPosition = 1
  ProcessInput Normal, DoCount, Null, TotalFlipped
    IF TotalFlipped > MaxFlipped THEN
      ToMoveX = XPosition
      ToMoveY = YPosition
      MaxFlipped = TotalFlipped
    END IF
  XPosition = 1
  YPosition = 8
  ProcessInput Normal, DoCount, Null, TotalFlipped
    IF TotalFlipped > MaxFlipped THEN
      ToMoveX = XPosition
      ToMoveY = YPosition
      MaxFlipped = TotalFlipped
    END IF
  XPosition = 8
  YPosition = 8
  ProcessInput Normal, DoCount, Null, TotalFlipped
    IF TotalFlipped > MaxFlipped THEN
      ToMoveX = XPosition
      ToMoveY = YPosition
      MaxFlipped = TotalFlipped
  END IF
END SUB

SUB CheckLegalMove (MoveExists AS INTEGER)
  DIM SaveX AS INTEGER, SaveY AS INTEGER

  IF BlackTotal + WhiteTotal = 64 THEN
    MoveExists = False
    EXIT SUB
  END IF

  SaveX = XPosition
  SaveY = YPosition
  XPosition = 0
  YPosition = 1
  DO
    XPosition = XPosition + 1
    ProcessInput Testing, NoCount, MoveExists, Null
    IF MoveExists THEN
      XPosition = SaveX
      YPosition = SaveY
      EXIT SUB
    END IF
    IF XPosition = 8 THEN
      XPosition = 0
      YPosition = YPosition + 1
    END IF
  LOOP UNTIL YPosition = 9
  XPosition = SaveX
  YPosition = SaveY
END SUB

SUB CheckMoves
  DIM MoveExists AS INTEGER

  CheckLegalMove MoveExists

  IF NOT MoveExists THEN
    SwitchPlayers
    CheckLegalMove MoveExists
    IF NOT MoveExists THEN
      UpdateBalance
      WriteName Empty
      IF WhiteTotal > BlackTotal THEN
        IF ComputerPlaying THEN
          IF ComputerColor = White THEN
            GameOver Computer
          ELSE
            GameOver Person
          END IF
        ELSE
          GameOver White
        END IF
      ELSEIF BlackTotal > WhiteTotal THEN
        IF ComputerPlaying THEN
          IF ComputerColor = Black THEN
            GameOver Computer
          ELSE
            GameOver Person
          END IF
        ELSE
          GameOver Black
        END IF
      ELSE
        IF ComputerPlaying THEN
          GameOver Tied
        END IF
      END IF
      WHILE INKEY$ <> "" OR STRIG(1) OR STRIG(5): WEND
      PlayAgain
      DO
        Choice$ = INKEY$
        SELECT CASE Choice$
          CASE "Y", "y"
            PrepareGame
            EXIT SUB
          CASE ELSE
        END SELECT
      LOOP UNTIL Choice$ = "N" OR Choice$ = "n"
        SCREEN 0
        CLS
        END
    ELSE
      IF ComputerPlaying THEN
        IF OpposingPlayer = ComputerColor THEN
          WriteName Empty
          NoMove Computer
        END IF
      ELSE
        WriteName Empty
        NoMove Person
     END IF
    END IF
  END IF
END SUB

SUB CheckX (XStart AS INTEGER, Xstop AS INTEGER, MaxFlipped AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
  DIM TotalFlipped AS INTEGER

  FOR XPosition = XStart TO Xstop
    ProcessInput Normal, DoCount, Null, TotalFlipped
      IF TotalFlipped > MaxFlipped THEN
        MaxFlipped = TotalFlipped
        ToMoveX = XPosition
        ToMoveY = YPosition
      END IF
  NEXT
        
END SUB

SUB CheckY (YStart AS INTEGER, YStop AS INTEGER, MaxFlipped AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
  DIM TotalFlipped AS INTEGER

  FOR YPosition = YStart TO YStop
    ProcessInput Normal, DoCount, Null, TotalFlipped
      IF TotalFlipped > MaxFlipped THEN
        MaxFlipped = TotalFlipped
        ToMoveX = XPosition
        ToMoveY = YPosition
      END IF
  NEXT
       

END SUB

SUB ComputerMove (Legal AS INTEGER)

DIM SaveX AS INTEGER, SaveY AS INTEGER
DIM ToMoveX AS INTEGER, ToMoveY AS INTEGER
DIM MaxFlipped AS INTEGER, TotalFlipped AS INTEGER

  SaveX = XPosition
  SaveY = YPosition
  RemovePointer Grid(XPosition, YPosition)

  CheckCorners MaxFlipped, ToMoveX, ToMoveY

  IF MaxFlipped > 0 THEN
    Legal = True
    XPosition = ToMoveX
    YPosition = ToMoveY
    RestorePointer Grid(XPosition, YPosition)
    ProcessInput Normal, NoCount, Null, Null
    EXIT SUB
  END IF


      YPosition = 1
      CheckX 2, 7, MaxFlipped, ToMoveX, ToMoveY
      YPosition = 8
      CheckX 2, 7, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 1
      CheckY 2, 7, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 8
      CheckY 2, 7, MaxFlipped, ToMoveX, ToMoveY
      IF MaxFlipped > 0 THEN
        XPosition = ToMoveX
        YPosition = ToMoveY
        Legal = True
        RestorePointer Grid(XPosition, YPosition)
        ProcessInput Normal, NoCount, Null, Null
        EXIT SUB
      END IF
   

      YPosition = 3
      CheckX 3, 6, MaxFlipped, ToMoveX, ToMoveY
      YPosition = 6
      CheckX 3, 6, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 3
      CheckY 4, 5, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 6
      CheckY 4, 5, MaxFlipped, ToMoveX, ToMoveY
      IF MaxFlipped > 0 THEN
        XPosition = ToMoveX
        YPosition = ToMoveY
        Legal = True
        RestorePointer Grid(XPosition, YPosition)
        ProcessInput Normal, NoCount, Null, Null
        EXIT SUB
      END IF

   
   
      YPosition = 2
      CheckX 2, 7, MaxFlipped, ToMoveX, ToMoveY
      YPosition = 7
      CheckX 2, 7, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 2
      CheckY 3, 6, MaxFlipped, ToMoveX, ToMoveY
      XPosition = 7
      CheckY 3, 6, MaxFlipped, ToMoveX, ToMoveY
      IF MaxFlipped > 0 THEN
        XPosition = ToMoveX
        YPosition = ToMoveY
        Legal = True
        RestorePointer Grid(XPosition, YPosition)
        ProcessInput Normal, NoCount, Null, Null
        EXIT SUB
      END IF
      
   

  LOCATE 5, 30
  PRINT "No move";
  WHILE INKEY$ = "": WEND
  SwitchPlayers
  UpdateScreen
  
END SUB


SUB PrepareGame
DIM XAxis AS INTEGER, YAxis AS INTEGER

  FOR XAxis = 1 TO 8
    FOR YAxis = 1 TO 8
      Grid(XAxis, YAxis) = Empty
    NEXT
  NEXT
  WhiteTotal = 0
  BlackTotal = 0
  UpdateBalance
  InitGrid
  MakeBoard


END SUB



SUB GameOver (Who AS INTEGER)

  COLOR 15
  LOCATE 5, 59
  PRINT "Game Over.";
  SELECT CASE Who
    CASE Computer
      LOCATE 7, 59
      PRINT "I won!";
    CASE Person
      LOCATE 7, 59
      PRINT "You won!";
    CASE Black
      LOCATE 7, 59
      PRINT "Black won!";
    CASE White
      LOCATE 7, 59
      PRINT "White won!";
  END SELECT

END SUB

SUB NoMove (Who AS INTEGER)
  COLOR 15
  SELECT CASE Who
    CASE Computer
      LOCATE 5, 51
      PRINT "I have no move and must";
      LOCATE 6, 51
      PRINT "forfeit my turn.";
    CASE Person
      LOCATE 5, 51
      PRINT "You have no move and must";
      LOCATE 6, 51
      PRINT "forfeit your turn.";
    CASE Black
      LOCATE 5, 51
      PRINT "Black has no move and must"
      LOCATE 6, 51
      PRINT "forfeit his turn.";
    CASE White
      LOCATE 5, 51
      PRINT "White has no move and must";
      LOCATE 6, 51
      PRINT "forfeit his turn.";
  END SELECT
  LOCATE 10, 58
  PRINT "Press any key.";
  WHILE INKEY$ = "": WEND
  LINE (376, 31)-(637, 149), 0, BF
END SUB



SUB PlayAgain
  COLOR 15
  LOCATE 10, 58
  PRINT "Play again?";
END SUB

SUB RemovePalette
  DIM Index AS INTEGER

  FOR Index = 1 TO 15
    PALETTE Index, 0
  NEXT

END SUB






SUB RestorePalette
  DIM Index AS INTEGER

  PALETTE

END SUB






