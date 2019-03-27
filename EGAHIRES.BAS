DECLARE SUB RemovePalette ()
DECLARE SUB RestorePalette ()
'
' Switch.Bas
'           by Paul Henson
'
' Indirect portation of similiar code written in Commodore Basic 7.0 and
' implemented on a Commodore 128 by Paul Henson and Chris Bouffard.
' ----------------------------------------------------------------------
' Module EGAHIRES.BAS
'
' Code and definitions for EGA 640x350 16 color graphics


DECLARE SUB Pause (Time AS INTEGER)
DECLARE SUB InitGrid ()
DECLARE SUB MakePiece (Xlocation AS INTEGER, Ylocation AS INTEGER, Side AS INTEGER, DoFlip AS INTEGER)
DECLARE SUB RestorePointer (GridContents AS INTEGER)
DECLARE SUB MakeBoard ()


CONST False = 0, True = NOT False
CONST NoFlip = False, DoFlip = True
CONST Empty = 0, Black = 1, White = 2
CONST AcrossIncrease = 45, DownIncrease = 42
CONST ArraySize = 457
CONST GridForeGround = 3, GridBackGround = 1
CONST PointerForeGround = 5
CONST WhitePieceColor = 7, BlackPieceColor = 0
CONST XOffset = 4, YOffset = 5
CONST WholePiece = 1, Part1 = 2, Part2 = 3, Part3 = 4, Part4 = 5, Part5 = 6, Part6 = 7
CONST BalanceX = 497, BalanceY = 315
CONST LineUX = BalanceX - 60
CONST LineUY = BalanceY - 108
CONST LineLY = BalanceY - 105
CONST LineLX = BalanceX + 60
CONST WhiteBasketX = BalanceX + 40
CONST BlackBasketX = BalanceX - 80
CONST BasketY = BalanceY - 104
CONST Computer = 3
CONST Person = 4
CONST Tied = 5

DIM SHARED WhitePiece(ArraySize) AS INTEGER, BlackPiece(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart1(ArraySize) AS INTEGER, BlackPiecePart1(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart2(ArraySize) AS INTEGER, BlackPiecePart2(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart3(ArraySize) AS INTEGER, BlackPiecePart3(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart4(ArraySize) AS INTEGER, BlackPiecePart4(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart5(ArraySize) AS INTEGER, BlackPiecePart5(ArraySize) AS INTEGER
DIM SHARED WhitePiecePart6(ArraySize) AS INTEGER, BlackPiecePart6(ArraySize) AS INTEGER


DIM SHARED Pointer(ArraySize) AS INTEGER
DIM SHARED WhitePointer(ArraySize) AS INTEGER
DIM SHARED BlackPointer(ArraySize) AS INTEGER
DIM SHARED EmptyPointer(ArraySize) AS INTEGER

DIM SHARED WhiteBasket(781) AS INTEGER
DIM SHARED BlackBasket(781) AS INTEGER

COMMON SHARED WhiteTotal AS INTEGER, BlackTotal AS INTEGER
COMMON SHARED XPosition AS INTEGER, YPosition AS INTEGER
COMMON SHARED WaitLength AS INTEGER

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

SUB Initilize
CONST CircleSize = 17
CircleAspect = 1
CONST CircleX = 23
CONST CircleY = 20
CONST GetX = 1, GetXB = 44
CONST GetY = 1, GetYB = 38


  SCREEN 9
  CLS
  RemovePalette
 
  LINE (GetX - 1, GetY - 1)-(GetXB + 1, GetYB + 1), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), EmptyPointer(0)
 
  CIRCLE (CircleX, CircleY), CircleSize, WhitePieceColor, , , CircleAspect
  PAINT (CircleX, CircleY), WhitePieceColor, WhitePieceColor
  LINE (21, 4)-(25, 16), PointerForeGround, BF
  LINE (21, 37)-(25, 24), PointerForeGround, BF
  LINE (6, 18)-(18, 21), PointerForeGround, BF
  LINE (28, 18)-(40, 21), PointerForeGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePointer(0)
 
  CIRCLE (CircleX, CircleY), CircleSize, BlackPieceColor, , , CircleAspect
  PAINT (CircleX, CircleY), BlackPieceColor, BlackPieceColor
  LINE (21, 4)-(25, 16), PointerForeGround, BF
  LINE (21, 37)-(25, 24), PointerForeGround, BF
  LINE (6, 18)-(18, 21), PointerForeGround, BF
  LINE (28, 18)-(40, 21), PointerForeGround, BF
  BlackPointer(0) = 0
  GET (GetX, GetY)-(GetXB, GetYB), BlackPointer
 
  LINE (GetX, GetY)-(GetXB, GetYB), GridBackGround, BF
  CIRCLE (CircleX, CircleY), CircleSize, WhitePieceColor, , , CircleAspect
  PAINT (CircleX, CircleY), WhitePieceColor, WhitePieceColor
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiece(0)
  LINE (GetX, GetY + 2)-(GetXB, GetY + 3), GridBackGround, BF
  LINE (GetX, GetYB - 1)-(GetXB, GetYB - 2), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart1(0)
  LINE (GetX, GetY + 4)-(GetXB, GetY + 5), GridBackGround, BF
  LINE (GetX, GetYB - 3)-(GetXB, GetYB - 4), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart2(0)
  LINE (GetX, GetY + 6)-(GetXB, GetY + 7), GridBackGround, BF
  LINE (GetX, GetYB - 5)-(GetXB, GetYB - 6), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart3(0)
  LINE (GetX, GetY + 8)-(GetXB, GetY + 9), GridBackGround, BF
  LINE (GetX, GetYB - 7)-(GetXB, GetYB - 8), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart4(0)
  LINE (GetX, GetY + 10)-(GetXB, GetY + 11), GridBackGround, BF
  LINE (GetX, GetYB - 9)-(GetXB, GetYB - 10), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart5(0)
  LINE (GetX, GetY + 12)-(GetXB, GetY + 14), GridBackGround, BF
  LINE (GetX, GetYB - 10)-(GetXB, GetYB - 13), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), WhitePiecePart6(0)
 
  LINE (GetX, GetY)-(GetXB, GetYB), GridBackGround, BF
  CIRCLE (CircleX, CircleY), CircleSize, BlackPieceColor, , , CircleAspect
  PAINT (CircleX, CircleY), BlackPieceColor, BlackPieceColor
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiece(0)
  LINE (GetX, GetY + 2)-(GetXB, GetY + 3), GridBackGround, BF
  LINE (GetX, GetYB - 1)-(GetXB, GetYB - 2), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart1(0)
  LINE (GetX, GetY + 4)-(GetXB, GetY + 5), GridBackGround, BF
  LINE (GetX, GetYB - 3)-(GetXB, GetYB - 4), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart2(0)
  LINE (GetX, GetY + 6)-(GetXB, GetY + 7), GridBackGround, BF
  LINE (GetX, GetYB - 5)-(GetXB, GetYB - 6), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart3(0)
  LINE (GetX, GetY + 8)-(GetXB, GetY + 9), GridBackGround, BF
  LINE (GetX, GetYB - 7)-(GetXB, GetYB - 8), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart4(0)
  LINE (GetX, GetY + 10)-(GetXB, GetY + 11), GridBackGround, BF
  LINE (GetX, GetYB - 9)-(GetXB, GetYB - 10), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart5(0)
  LINE (GetX, GetY + 12)-(GetXB, GetY + 14), GridBackGround, BF
  LINE (GetX, GetYB - 10)-(GetXB, GetYB - 13), GridBackGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), BlackPiecePart6(0)
 
 
  LINE (GetX, GetY)-(GetXB, GetYB), GridBackGround, BF
  LINE (21, 4)-(25, 16), PointerForeGround, BF
  LINE (21, 37)-(25, 24), PointerForeGround, BF
  LINE (6, 18)-(18, 21), PointerForeGround, BF
  LINE (28, 18)-(40, 21), PointerForeGround, BF
  GET (GetX, GetY)-(GetXB, GetYB), Pointer(0)
  LINE (0, 0)-(100, 100), 0, BF
  CIRCLE (21, 61), 20, 8, , , .2
  PAINT (21, 61), 14, 8
  LINE (1, 61)-(21, 1), 7
  LINE (41, 61)-(21, 1), 7
  CIRCLE (21, 61), 5, 0, , , .2
  PAINT (21, 61), 0, 0
  GET (1, 1)-(41, 65), BlackBasket(0)
  CIRCLE (21, 61), 5, 15, , , .2
  PAINT (21, 61), 15, 15
  GET (1, 1)-(41, 65), WhiteBasket(0)
  CLS
  InitGrid
  MakeBoard
  RestorePalette
     
END SUB

SUB MakeBoard
CONST StartX = 3, StartY = 3
DIM Xloc AS INTEGER, Yloc AS INTEGER

  CLS
  RemovePalette
  LINE (0, 0)-(366, 342), GridBackGround, BF
  Xloc = StartX: Yloc = StartY
  DO
    DO
      LINE (Xloc, Yloc)-(Xloc + AcrossIncrease, Yloc + DownIncrease), GridForeGround, B
      Xloc = Xloc + AcrossIncrease
    LOOP UNTIL Xloc = (AcrossIncrease * 8) + StartX
    Yloc = Yloc + DownIncrease
    Xloc = StartX
  LOOP UNTIL Yloc = (DownIncrease * 8) + StartY
  MakePiece 4, 4, White, NoFlip
  MakePiece 5, 5, White, NoFlip
  MakePiece 5, 4, Black, NoFlip
  MakePiece 4, 5, Black, NoFlip
  CIRCLE (BalanceX, BalanceY), 35, 8, , , .2
  PAINT (BalanceX, BalanceY), 1, 8
  LINE (BalanceX - 4, BalanceY)-(BalanceX + 4, BalanceY - 100), 8, B
  LINE (BalanceX - 3, BalanceY + 1)-(BalanceX + 3, BalanceY - 100), 9, BF
  CIRCLE (BalanceX, BalanceY - 96), 8, 8, 0, 3, 2
  PAINT (BalanceX, BalanceY - 100), 9, 8
  LINE (LineUX, LineUY)-(LineUX, LineLY), 8
  LINE -(LineLX, LineLY), 8
  LINE -(LineLX, LineUY), 8
  LINE -(LineUX, LineUY), 8
  PAINT (LineUX + 1, LineUY + 1), 9, 8
  PUT (BlackBasketX, BasketY), BlackBasket, XOR
  PUT (WhiteBasketX, BasketY), WhiteBasket, XOR
  COLOR 8
  LOCATE 24, 49
  PRINT " Black ="; STR$(BlackTotal); " ";
  COLOR 15
  LOCATE 24, 68
  PRINT "White ="; STR$(WhiteTotal); " ";
  LINE (375, 6)-(638, 150), 1, B
  LINE (375, 30)-(638, 30), 1
  COLOR 15
  LOCATE 2, 49
  PRINT "Current Player:";
 
  RestorePointer (Empty)
  RestorePalette

END SUB

SUB MakePiece (Xlocation AS INTEGER, Ylocation AS INTEGER, Side AS INTEGER, DoFlip AS INTEGER)

DIM RealX AS INTEGER, RealY AS INTEGER
                    

  RealX = ((Xlocation - 1) * AcrossIncrease) + XOffset
  RealY = ((Ylocation - 1) * DownIncrease) + YOffset
  IF DoFlip THEN
    IF Side = Black THEN
      PUT (RealX, RealY), WhitePiecePart1, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart2, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart3, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart4, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart5, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart6, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart6, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart5, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart4, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart3, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart2, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart1, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiece, PSET
      WhiteTotal = WhiteTotal - 1
      BlackTotal = BlackTotal + 1
    ELSE
      PUT (RealX, RealY), BlackPiecePart1, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart2, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart3, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart4, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart5, PSET
      Pause WaitLength
      PUT (RealX, RealY), BlackPiecePart6, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart6, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart5, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart4, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart3, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart2, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiecePart1, PSET
      Pause WaitLength
      PUT (RealX, RealY), WhitePiece, PSET
      BlackTotal = BlackTotal - 1
      WhiteTotal = WhiteTotal + 1
    END IF
  ELSE
    IF Side = White THEN
      PUT (RealX, RealY), WhitePiece, PSET
      WhiteTotal = WhiteTotal + 1
    ELSE
      PUT (RealX, RealY), BlackPiece, PSET
      BlackTotal = BlackTotal + 1
    END IF
  END IF
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

SUB RemovePointer (GridContents AS INTEGER)

DIM RealX AS INTEGER, RealY AS INTEGER

RealX = ((XPosition - 1) * AcrossIncrease) + XOffset
RealY = ((YPosition - 1) * DownIncrease) + YOffset

SELECT CASE GridContents
  CASE White
    PUT (RealX, RealY), WhitePiece, PSET
  CASE Black
    PUT (RealX, RealY), BlackPiece, PSET
  CASE Empty
    PUT (RealX, RealY), EmptyPointer, PSET
END SELECT

END SUB





SUB RestorePalette
  DIM Index AS INTEGER

  PALETTE

END SUB

SUB RestorePointer (GridContents AS INTEGER)

DIM RealX AS INTEGER, RealY AS INTEGER

RealX = ((XPosition - 1) * AcrossIncrease) + XOffset
RealY = ((YPosition - 1) * DownIncrease) + YOffset

SELECT CASE GridContents
  CASE White
    PUT (RealX, RealY), WhitePointer, PSET
  CASE Black
    PUT (RealX, RealY), BlackPointer, PSET
  CASE Empty
    PUT (RealX, RealY), Pointer, PSET
END SELECT

END SUB

SUB UpdateBalance
  STATIC Difference AS INTEGER

  IF Difference = BlackTotal - WhiteTotal THEN
    EXIT SUB
  END IF

  PAINT (LineUX + 1, LineUY + 2 + Difference), 0, 8
  LINE (LineUX, LineUY + Difference)-(LineUX, LineLY + Difference), 0
  LINE -(LineLX, LineLY - Difference), 0
  LINE -(LineLX, LineUY - Difference), 0
  LINE -(LineUX, LineUY + Difference), 0
  PUT (BlackBasketX, BasketY + Difference), BlackBasket, XOR
  PUT (WhiteBasketX, BasketY - Difference), WhiteBasket, XOR


  Difference = BlackTotal - WhiteTotal
 
  LINE (LineUX, LineUY + Difference)-(LineUX, LineLY + Difference), 8
  LINE -(LineLX, LineLY - Difference), 8
  LINE -(LineLX, LineUY - Difference), 8
  LINE -(LineUX, LineUY + Difference), 8
  PAINT (LineUX + 1, LineUY + 2 + Difference), 9, 8
  PUT (BlackBasketX, BasketY + Difference), BlackBasket, XOR
  PUT (WhiteBasketX, BasketY - Difference), WhiteBasket, XOR

  COLOR 8
  IF BlackTotal > 9 THEN
    LOCATE 24, 48
  ELSE
    LOCATE 24, 49
  END IF
  PRINT " Black ="; STR$(BlackTotal); " ";
  COLOR 15
  LOCATE 24, 68
  PRINT "White ="; STR$(WhiteTotal); " ";
  
END SUB

SUB WriteName (NameToWrite AS INTEGER)
  LOCATE 2, 65
  PRINT "          ";
  IF NameToWrite = White THEN
    LOCATE 2, 65
    COLOR 15
    PRINT "White";
  ELSEIF NameToWrite = Black THEN
    LOCATE 2, 65
    COLOR 8
    PRINT "Black";
  ELSEIF NameToWrite = Computer THEN
    LOCATE 2, 65
    COLOR 1
    PRINT "Computer";
  END IF
END SUB

