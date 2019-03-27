DECLARE FUNCTION Upcase$ (work$)
INITILIZE:
	  SCREEN 1
	  COLOR 1, 0
	  WIDTH 40
	  CLS
	  DIM DART#(2)
	  Force = 1
	  Angle = 60
	  Gravity = 1
	  GOSUB DRAWDART
	  GOSUB DRAWSCR
MAIN:
     I$ = Upcase$(INKEY$)

     IF I$ = "G" THEN GOSUB CGRAV
     IF I$ = "W" THEN GOSUB CWIND
     IF I$ = "F" THEN GOSUB CFORCE
     IF I$ = "A" THEN GOSUB CANGLE
     IF I$ = "T" THEN GOSUB THROWDRT
     IF I$ = "Q" THEN END
     LOCATE 23, 5
     PRINT "GRAVITY="; Gravity;
     LOCATE 24, 5
     PRINT "  ANGLE="; Angle;
     LOCATE 23, 25
     PRINT "FORCE="; Force;
     LOCATE 24, 25
     PRINT "SCORE="; S;

GOTO MAIN
DRAWSCR:
	LINE (5, 5)-(315, 170), 3, B
	LINE (180, 5)-(180, 170), 3
	LINE (6, 145)-(179, 169), 1, BF
	LINE (27, 100)-(30, 160), 3, BF
	CIRCLE (30, 85), 16, 1, , , 2.5
	CIRCLE (30, 85), 15, 1, , , 2.5
	CIRCLE (30, 85), 14, 1, , , 2.5
	CIRCLE (30, 85), 13, 1, , , 2.5
	CIRCLE (30, 85), 12, 2, , , 2.5
	CIRCLE (30, 85), 11, 2, , , 2.5
	CIRCLE (30, 85), 10, 2, , , 2.5
	CIRCLE (30, 85), 9, 2, , , 2.5
	CIRCLE (30, 85), 8, 3, , , 2.5
	CIRCLE (30, 85), 7, 3, , , 2.5
	CIRCLE (30, 85), 6, 3, , , 2.5
	CIRCLE (30, 85), 5, 3, , , 2.5
	CIRCLE (30, 85), 4, 1, , , 2.5
	CIRCLE (30, 85), 3, 1, , , 2.5
	CIRCLE (30, 85), 2, 1, , , 2.5
	CIRCLE (30, 85), 1, 2, , , 2.5
	CIRCLE (30, 85), 0, 3, , , 2.5
	CIRCLE (247, 83), 70, 1, , , 1.1
	CIRCLE (247, 83), 57, 1, , , 1.1
	CIRCLE (247, 83), 45, 1, , , 1.1
	CIRCLE (247, 83), 32, 1, , , 1.1
	CIRCLE (247, 83), 17, 1, , , 1.1
	CIRCLE (247, 83), 5, 1, , , 1.1
	PAINT (247, 18), 1, 1
	PAINT (247, 28), 2, 1
	PAINT (247, 43), 3, 1
	PAINT (247, 53), 1, 1
	PAINT (247, 73), 2, 1
	PAINT (247, 83), 3, 1
	LINE (240, 154)-(254, 170), 3, BF
	LINE (5, 170)-(315, 199), 3, B
	CIRCLE (100, 35), 16, 3
	PAINT (100, 35), 3, 3
	CIRCLE (130, 35), 16, 3
	PAINT (130, 35), 3, 3
	CIRCLE (114, 28), 16, 3
	PAINT (114, 21), 3, 3
	CIRCLE (114, 41), 16, 3
	PAINT (114, 45), 3, 3
	LOCATE 23, 5
	PRINT "GRAVITY="; Gravity;
	LOCATE 24, 5
	PRINT "  ANGLE="; Angle;
	LOCATE 23, 25
	PRINT "FORCE="; Force;
	LOCATE 24, 25
	PRINT "SCORE="; S;
	RETURN
DRAWDART:
	 LINE (51, 50)-(57, 50), 1
	 LINE (55, 49)-(60, 49), 1
	 LINE (55, 51)-(60, 51), 1
	 GET (50, 48)-(61, 52), DART#
	 CLS
	 RETURN
CGRAV:
      Gravity = Gravity + 1
      RETURN
CWIND:
      RETURN
CFORCE:
       Force = Force + 1
       RETURN
CANGLE:
       Angle = Angle - 1
       RETURN
THROWDRT:
	 TARGETPIXEL = 125 - (Angle - 5)
	 IF TARGETPIXEL = 85 THEN PIXELRATIO = 1: GOTO STARTFOR
	 PIXELRATIO = INT(169 / (85 - TARGETPIXEL))
STARTFOR:
	 PIXELCOUNT = 0
	 DOWN = 85
	 FOR OVER = 169 TO 30 STEP -1

	 PIXELCOUNT = PIXELCOUNT + 1

	 IF PIXELCOUNT = PIXELRATIO THEN
	 PIXELCOUNT = 0
	 IF DOWN < TARGETPIXEL THEN DOWN = DOWN + 1
	 IF DOWN > TARGETPIXEL THEN DOWN = DOWN - 1
	 IF Force = 0 THEN
	 TARGETPIXEL = TARGETPIXEL + Gravity
	 ELSE TARGETPIXEL = INT(TARGETPIXEL + (Gravity / Force))
	 END IF
	 IF TARGETPIXEL = 85 THEN TARGETPIXEL = 86
	 PIXELRATIO = INT(169 / (85 - TARGETPIXEL))
	 IF Force > 0 THEN Force = INT(Force - ((Gravity / Force) / 1.5))
	 END IF

	 PUT (OVER, DOWN), DART#, PSET
	 NEXT
RETURN

FUNCTION Upcase$ (work$)
  FOR index% = 1 TO LEN(work$)
    SELECT CASE MID$(work$, index%, 1)
      CASE "a"
	MID$(work$, index%, 1) = "A"
      CASE ELSE
    END SELECT
  NEXT index%
  Upcase$ = work$
END FUNCTION

