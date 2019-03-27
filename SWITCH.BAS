'
' Switch.Bas
'           by Paul Henson
'
' Indirect portation of similiar code written in Commodore Basic 7.0 and
' implemented on a Commodore 128 by Paul Henson and Chris Bouffard.
'

DECLARE SUB PlayAgain ()
DECLARE SUB GameOver (Who AS INTEGER)
DECLARE SUB NoMove (Who AS INTEGER)
DECLARE SUB Pause (Time AS INTEGER)
DECLARE SUB InitGrid ()
DECLARE SUB Initilize ()
DECLARE SUB RemovePointer (GridContents AS INTEGER)
DECLARE SUB RestorePointer (GridContents AS INTEGER)
DECLARE SUB UpdateBalance ()
DECLARE SUB WriteName (NameToWrite AS INTEGER)
DECLARE SUB ComputerMove (Legal AS INTEGER)
DECLARE SUB CheckCorners (Legal AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
DECLARE SUB CheckX (XStart AS INTEGER, Xstop AS INTEGER, Legal AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
DECLARE SUB CheckY (YStart AS INTEGER, YStop AS INTEGER, Legal AS INTEGER, ToMoveX AS INTEGER, ToMoveY AS INTEGER)
DECLARE SUB MakeBoard ()
DECLARE SUB PrepareGame ()
DECLARE SUB CheckLegalMove (MoveExists AS INTEGER)
DECLARE SUB CheckMoves ()
DECLARE SUB GetInput ()
DECLARE SUB ProcessInput (Test AS INTEGER, Count AS INTEGER, LegalMove AS INTEGER, NumFlipped AS INTEGER)
DECLARE SUB SwitchPlayers ()
DECLARE SUB UpdateScreen ()
DECLARE SUB MakePiece (Xlocation AS INTEGER, Ylocation AS INTEGER, Side AS INTEGER, DoFlip AS INTEGER)
DECLARE SUB ParseCommandLine ()
DECLARE SUB TitleScreen ()
DECLARE SUB Joystick ()
DECLARE SUB SelectMode ()

CONST False = 0, True = NOT False
CONST Null = 0
CONST NoFlip = False, DoFlip = True
CONST Normal = False, Testing = True
CONST NoCount = False, DoCount = True
CONST ForeG = 7, BackG = 1
CONST Empty = 0, Black = 1, White = 2
CONST AcrossIncrease = 28, DownIncrease = 24
CONST ArraySize = 44
CONST Computer = 3
CONST Person = 4
CONST Tied = 5

DIM SHARED Grid(1 TO 8, 1 TO 8) AS INTEGER
DIM SHARED CurrentPlayer AS INTEGER, OpposingPlayer AS INTEGER
DIM SHARED ModeSelected AS INTEGER
                                 
COMMON SHARED WhiteTotal AS INTEGER, BlackTotal AS INTEGER
COMMON SHARED XPosition AS INTEGER, YPosition AS INTEGER
COMMON SHARED WaitLength AS INTEGER
COMMON SHARED Demo AS INTEGER
COMMON SHARED ComputerPlaying AS INTEGER
COMMON SHARED ComputerColor AS INTEGER
COMMON SHARED UsingJoyStick AS INTEGER
COMMON SHARED Up AS INTEGER
COMMON SHARED Down AS INTEGER
COMMON SHARED Left AS INTEGER
COMMON SHARED Right AS INTEGER

  TitleScreen
  UsingJoyStick = False
  ParseCommandLine
  IF NOT ModeSelected THEN SelectMode
  Joystick

  Initilize
 
  DO
    UpdateScreen
    GetInput
    ProcessInput Normal, NoCount, Null, Null
    CheckMoves
  LOOP

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

SUB GetInput

CONST PauseTime = 800
  DIM Choice AS STRING
  DIM MoveFound AS INTEGER
                          
  DO
    RealX = ((XPosition - 1) * AcrossIncrease) + 7
    RealY = ((YPosition - 1) * DownIncrease) + 7
   
    IF ComputerPlaying OR Demo THEN
      IF CurrentPlayer = ComputerColor OR Demo THEN
        ComputerMove MoveFound
        IF MoveFound THEN
          CheckMoves
          UpdateScreen
        END IF
      END IF
    END IF


    Choice = INKEY$
    
      IF UsingJoyStick AND Choice <> CHR$(27) THEN
        DO
          IF STICK(0) < Left AND STICK(1) < Up THEN
            Choice = "7"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(0) > Right AND STICK(1) < Up THEN
            Choice = "9"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(0) < Left AND STICK(1) > Down THEN
            Choice = "1"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(0) > Right AND STICK(1) > Down THEN
            Choice = "3"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(0) < Left THEN
            Choice = "4"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(0) > Right THEN
            Choice = "6"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(1) < Up THEN
            Choice = "8"
            Pause PauseTime
            EXIT DO
          END IF
          IF STICK(1) > Down THEN
            Choice = "2"
            Pause PauseTime
            EXIT DO
          END IF
          IF STRIG(1) THEN Choice = " "
          IF STRIG(5) THEN Choice = CHR$(27)
          EXIT DO
        LOOP
      END IF
    IF LEN(Choice) = 2 THEN
    SELECT CASE ASC(MID$(Choice, 2, 1))
        CASE 72
          Choice = "8"
        CASE 75
          Choice = "4"
        CASE 77
          Choice = "6"
        CASE 80
          Choice = "2"
        CASE 71
          Choice = "7"
        CASE 73
          Choice = "9"
        CASE 79
          Choice = "1"
        CASE 81
          Choice = "3"
        CASE ELSE
      END SELECT
    END IF

    SELECT CASE Choice
       
        CASE "8"
          IF YPosition > 1 THEN
            RemovePointer Grid(XPosition, YPosition)
            YPosition = YPosition - 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
       
        CASE "6"
          IF XPosition < 8 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition + 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
       
        CASE "2"
          IF YPosition < 8 THEN
            RemovePointer Grid(XPosition, YPosition)
            YPosition = YPosition + 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
       
        CASE "4"
          IF XPosition > 1 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition - 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
      
        CASE "7"
          IF XPosition > 1 AND YPosition > 1 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition - 1
            YPosition = YPosition - 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
       
        CASE "9"
          IF XPosition < 8 AND YPosition > 1 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition + 1
            YPosition = YPosition - 1
            RestorePointer Grid(XPosition, YPosition)
          END IF
       
        CASE "1"
          IF XPosition > 1 AND YPosition < 8 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition - 1
            YPosition = YPosition + 1
            RestorePointer Grid(XPosition, YPosition)
          END IF

        CASE "3"
          IF XPosition < 8 AND YPosition < 8 THEN
            RemovePointer Grid(XPosition, YPosition)
            XPosition = XPosition + 1
            YPosition = YPosition + 1
            RestorePointer Grid(XPosition, YPosition)
          END IF

        CASE " "
          EXIT SUB

        CASE CHR$(27)
          COLOR 15
          LOCATE 6, 60
          PRINT "Return to ";
          LOCATE 7, 60
          PRINT "   DOS?";
          
          WHILE INKEY$ <> "" OR STRIG(1) OR STRIG(5): WEND
          DO
            Choice = INKEY$
            IF Choice = "Y" OR Choice = "y" OR STRIG(5) THEN
              SCREEN 0
              WIDTH 80
              CLS
              END
            END IF
          LOOP UNTIL Choice = "N" OR Choice = "n" OR STRIG(1)
          LOCATE 6, 60
          PRINT "          ";
          LOCATE 7, 60
          PRINT "          ";
          UpdateScreen
      
        CASE ELSE
     
      END SELECT

  LOOP
END SUB

SUB InitGrid
  CurrentPlayer = Black
  OpposingPlayer = White
  XPosition = 1
  YPosition = 1
  Grid(4, 4) = White
  Grid(5, 5) = White
  Grid(5, 4) = Black
  Grid(4, 5) = Black
END SUB

SUB Joystick
 DIM Choice AS STRING
  IF NOT UsingJoyStick AND STICK(0) > 0 AND STICK(1) > 0 THEN
  UsingJoyStick = True
  CLS
  LOCATE 7, 1
  PRINT "                       ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·"
  PRINT "                       º A joystick has been detected. º"
  PRINT "                       ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½"
  LOCATE 16, 1
  PRINT "                              Joystick Calibration"
  PRINT "                              ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
  PRINT ""
  PRINT "                      Position joystick to the Upper-Left."
  PRINT ""
  PRINT "                 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
  PRINT "                 ³ Press any key to continue or Esc to abort. ³"
  PRINT "                 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
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
END SUB

SUB ParseCommandLine
  DIM TempVar AS INTEGER
  DIM TempAlsoVar AS INTEGER
  SHARED ModeSelected AS INTEGER
  IF INSTR(COMMAND$, "/J") THEN
    UsingJoyStick = True
    Right = 75
    Left = 25
    Up = 25
    Down = 75
  END IF
  IF INSTR(COMMAND$, "/S") THEN
    TempVar = INSTR(COMMAND$, "/S")
    TempAlsoVar = INSTR(TempVar, COMMAND$, " ")
    IF NOT TempAlsoVar THEN TempAlsoVar = LEN(COMMAND$)
    WaitLength = VAL(MID$(COMMAND$, TempVar + 2, TempAlsoVar))
    IF WaitLength = 0 THEN WaitLength = 2000
  ELSE
    WaitLength = 2000
  END IF
  IF INSTR(COMMAND$, "/M") THEN
    ModeSelected = True
    TempVar = INSTR(COMMAND$, "/M")
    SELECT CASE MID$(COMMAND$, TempVar + 2, 1)
      CASE "1"
        ComputerPlaying = False
        Demo = False
      CASE "2"
        ComputerPlaying = True
        ComputerColor = White
        Demo = False
      CASE "3"
        ComputerPlaying = True
        ComputerColor = Black
        Demo = False
      CASE "4"
        Demo = True
      CASE ELSE
        ModeSelected = False
      END SELECT
  END IF
END SUB

SUB Pause (Time AS INTEGER)

DIM Temp AS INTEGER

FOR Temp = 1 TO Time
NEXT Temp

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

SUB ProcessInput (Test AS INTEGER, Count AS INTEGER, LegalMove AS INTEGER, NumFlipped AS INTEGER)
  DIM XIndex AS INTEGER, YIndex AS INTEGER
  DIM XCount AS INTEGER, YCount AS INTEGER

  LegalMove = False
  NumFlipped = 0
  IF Grid(XPosition, YPosition) <> Blank THEN EXIT SUB
  IF YPosition > 1 THEN             'Up
    IF Grid(XPosition, YPosition - 1) = OpposingPlayer THEN
      YCount = YPosition - 1
      DO WHILE YCount > 1
        YCount = YCount - 1
        IF Grid(XPosition, YCount) = Blank THEN EXIT DO
        IF Grid(XPosition, YCount) = CurrentPlayer THEN
          IF Test THEN
            LegalMove = True
            EXIT SUB
          END IF
          IF NOT Count THEN
            RemovePointer Grid(XPosition, YPosition)
            MakePiece XPosition, YPosition, CurrentPlayer, NoFlip
            Grid(XPosition, YPosition) = CurrentPlayer
          END IF
          FOR YIndex = (YPosition - 1) TO (YCount + 1) STEP -1
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

  IF (YPosition > 1 AND XPosition < 8) THEN     'UpRight
    IF Grid(XPosition + 1, YPosition - 1) = OpposingPlayer THEN
      XCount = XPosition + 1
      YCount = YPosition - 1
      DO WHILE (XCount < 8 AND YCount > 1)
        XCount = XCount + 1
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
            XIndex = XIndex + 1
            YIndex = YIndex - 1
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
  IF XPosition < 8 THEN 'Right
    IF Grid(XPosition + 1, YPosition) = OpposingPlayer THEN
      XCount = XPosition + 1
      DO WHILE XCount < 8
        XCount = XCount + 1
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
          FOR XIndex = (XPosition + 1) TO (XCount - 1)
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
  IF (YPosition < 8 AND XPosition < 8) THEN 'DownRight
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

IF LegalMove AND (NOT Count) THEN
  RestorePointer Grid(XPosition, YPosition)
  SwitchPlayers
END IF
        
END SUB

SUB SelectMode
DIM Choice AS STRING, Selection AS STRING
  CLS
  LOCATE 6, 1
  PRINT "                      ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸"
  PRINT "                      ³ How would you like to play today? ³"
  PRINT "                      ÔÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍ¾"
  PRINT "                           ³ 1. Human vs. Human     ³"
  PRINT "                           ³ 2. Human vs. Computer. ³"
  PRINT "                           ³ 3. Demo                ³"
  PRINT "                           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

  DO
    Choice = INKEY$
    IF Choice = "1" THEN ComputerPlaying = False
    IF Choice = "2" THEN
      ComputerPlaying = True
      CLS
      LOCATE 2, 1
      PRINT "               ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸"
      PRINT "               ³ So you want to pick on a poor dumb computer, eh? ³"
      PRINT "               ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾"
      LOCATE 9, 1
      PRINT "                              ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·"
      PRINT "                              º Do you wish to play º"
      PRINT "                              ÓÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄ½"
      PRINT "                                º (W)hite pieces? º"
      PRINT "                                º                 º"
      PRINT "                                º (B)lack pieces? º"
      PRINT "                                ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½"
      DO
        Selection = INKEY$
        IF Selection = "W" OR Selection = "w" THEN ComputerColor = Black
        IF Selection = "B" OR Selection = "b" THEN ComputerColor = White
      LOOP UNTIL Selection = "W" OR Selection = "w" OR Selection = "B" OR Selection = "b"
    END IF
    IF Choice = "3" THEN Demo = True
LOOP UNTIL Choice = "1" OR Choice = "2" OR Choice = "3"
 
END SUB

SUB SwitchPlayers
DIM Temp AS INTEGER
  Temp = CurrentPlayer
  CurrentPlayer = OpposingPlayer
  OpposingPlayer = Temp
END SUB

SUB TitleScreen
COLOR ForeG, BackG, 0
CLS
IF INKEY$ <> "" THEN EXIT SUB
PRINT "                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»";
PRINT "                         º  Switch --- Version 1.4  º";
PRINT "                         ÈÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍ¼";
PRINT "                              º   Paul Henson   º";
PRINT "                              ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½";
PRINT "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿";
PRINT "³                                Shareware                                 ³";
PRINT "³                                  ÄÄÄÄÄÄÄÄÄ                                   ³";
PRINT "³  There was much time and effort spent in programming Switch. If you use and  ³";
PRINT "³  enjoy Switch, a small donation of any amount would be greatly appreciated.  ³";
PRINT "³  If you do not send a donation, yet continue to use Switch, well, I dare say ³";
PRINT "³  that's a personal problem. Not much I can do about it, is there?            ³";
PRINT "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´";
PRINT "³      Copyright '88 by Paul Henson     ³                                      ³";
PRINT "³                                       ³ Send all donations, suggestions,     ³";
PRINT "³               ÛÛÛÛÛÛÛÛ                ³ criticism, fan mail, or whatever to: ³";
PRINT "³              ÛÛÛÛÛÛÛÛÛÛ               ³                                      ³";
PRINT "³             ÛÛÛÛÛÛÛÛÛÛÛÛ              ³                                      ³";
PRINT "³            ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ             ³           Paul Henson                ³";
PRINT "³             ÛÛÛÛÛÛÛÛÛÛÛÛ              ³           5331 Buffington Rd.        ³";
PRINT "³              ÛÛÛÛÛÛÛÛÛÛ               ³           El Monte, CA 91732         ³";
PRINT "³               ÛÛÛÛÛÛÛÛ                ³                                      ³";
PRINT "³                                       ³                                      ³";
PRINT "³         All Rights Reserved           ³                                      ³";
LOCATE 25, 1
PRINT "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ";
WHILE INKEY$ = "": WEND

END SUB

SUB UpdateScreen
  IF ComputerPlaying THEN
    IF ComputerColor = CurrentPlayer OR Demo THEN
      WriteName Computer
    ELSE
      WriteName CurrentPlayer
    END IF
  ELSE
    IF CurrentPlayer = Black THEN
      WriteName Black
    ELSE
      WriteName White
    END IF
  END IF
  
  UpdateBalance
END SUB

