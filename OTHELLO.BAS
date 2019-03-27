DIM grid(8, 8)
op = 1
sm = 2
grid(4, 4) = 2
grid(5, 4) = 1
grid(4, 5) = 1
grid(5, 5) = 2
  SCREEN 1
  PAINT (10, 10), 1
  DIM shape#(100)
  CIRCLE (20, 20), 6, 2
  PAINT (20, 25), 2
  DIM pointer#(100)
  GET (14, 14)-(26, 26), pointer#
  GET (14, 14)-(26, 26), shape#




GOSUB initilize

strt:

IF op = 1 THEN LOCATE 1, 29: PRINT "White"; :  ELSE LOCATE 29, 1: PRINT "Black";
LOCATE 3, 29: PRINT "Your Turn.";
LOCATE 18, 29: PRINT "Balance";
LOCATE 20, 29: PRINT "Black="; bt; " ";
LOCATE 21, 29: PRINT "White="; wt; " ";
GOSUB getinput
GOSUB domove
IF NOT lm THEN LOCATE 5, 29: PRINT "No Move": tmp = op: op = sm: sm = tmp: GOSUB checkmove: IF NOT lm THEN LOCATE 29, 5: PRINT "Game Over": END
GOTO strt






getinput:
DEFSTR Q
  q = INKEY$: IF q = "" THEN GOTO getinput
  IF q = "8" AND yy > 1 THEN sy = y: sx = x: yy = yy - 1: y = y - 24: GOTO leave
  IF q = "6" AND xx < 8 THEN sx = x: sy = y: xx = xx + 1: x = x + 28: GOTO leave
  IF q = "2" AND yy < 8 THEN sy = y: sx = x: yy = yy + 1: y = y + 24: GOTO leave
  IF q = "4" AND xx > 1 THEN sx = x: sy = y: xx = xx - 1: x = x - 28: GOTO leave
  IF q = " " THEN bf = -1: RETURN
leave:
  LOCATE 24, 30: PRINT xx; yy;



domove:
  IF NOT test THEN lm = -1
  IF NOT bf THEN RETURN
  bf = 0
  IF grid(xx, yy) <> 0 THEN RETURN
  legal = 0
  IF yy > 1 THEN IF grid(xx, yy - 1) = op THEN GOSUB UP
  'IF (yy > 1 AND xx < 8) THEN IF grid(xx + 1, yy - 1) = UP THEN GOSUB upright
  IF xx < 8 THEN IF grid(xx + 1, yy) = op THEN GOSUB right
  'IF (yy < 8 AND xx < 8) THEN IF grid(xx + 1, yy + 1) = op THEN GOSUB downright
  IF yy < 8 THEN IF grid(xx, yy + 1) = op THEN GOSUB down
  'IF (yy < 8 AND xx > 1) THEN IF grid(xx - 1, yy + 1) = op THEN GOSUB downleft
  IF xx > 1 THEN IF grid(xx - 1, yy) = op THEN GOSUB left
  'IF (yy > 1 AND xx > 1) THEN IF grid(xx - 1, yy - 1) = op THEN GOSUB upleft
  IF NOT legal THEN RETURN
  IF NOT test THEN tmp = op: op = sm: sm = tmp
  IF NOT test THEN GOSUB checkmove
  RETURN

UP:
  count = yy - 1
  DO WHILE count > 1
  count = count - 1
  IF grid(xx, count) = 0 THEN RETURN
  IF grid(xx, count) = sm THEN GOTO upspace
  LOOP
  RETURN
upspace:
  IF test THEN legal = -1: RETURN
  cl = sm: lx = xx: ly = yy: flip = 0: GOSUB makepiece: grid(xx, yy) = sm
  flip = -1
  FOR index = yy - 1 TO count + 1 STEP -1
  grid(xx, index) = sm
  lx = xx: ly = index: GOSUB makepiece
  NEXT
  legal = -1
  RETURN
down:
  count = yy + 1
  DO WHILE count < 8
  count = count + 1
  IF grid(xx, count) = 0 THEN RETURN
  IF grid(xx, count) = sm THEN GOTO downspace
  LOOP
  RETURN
downspace:
  IF test THEN legal = -1: RETURN
  IF NOT legal THEN lx = xx: ly = yy: flip = 0: cl = sm: GOSUB makepiece: grid(xx, yy) = sm
  flip = -1
  FOR index = yy + 1 TO count - 1
  grid(xx, index) = sm
  lx = xx: ly = index: GOSUB makepiece
  NEXT
  legal = -1
  RETURN

right:
  count = xx + 1
  DO WHILE count < 8
  count = count + 1
  IF grid(count, yy) = 0 THEN RETURN
  IF grid(count, yy) = sm THEN GOTO rightspace
  LOOP
  RETURN
rightspace:
  IF test THEN legal = -1: RETURN
  IF NOT legal THEN cl = sm: lx = xx: ly = yy: flip = 0: GOSUB makepiece: grid(xx, yy) = sm
  flip = -1
  FOR index = xx + 1 TO count - 1
  grid(index, yy) = sm
  lx = index: ly = yy: GOSUB makepiece
  NEXT
  legal = -1
  RETURN

left:
  count = xx - 1
  DO WHILE count > 1
  count = count - 1
  IF grid(count, yy) = 0 THEN RETURN
  IF grid(count, yy) = sm THEN GOTO leftspace
  LOOP
  RETURN
leftspace:
  IF test THEN legal = -1: RETURN
  IF NOT legal THEN cl = sm: lx = xx: ly = yy: flip = 0: GOSUB makepiece: grid(xx, yy) = sm
  flip = -1
  FOR index = xx - 1 TO count + 1 STEP -1
  grid(index, yy) = sm
  lx = index: ly = yy: GOSUB makepiece
  NEXT
  legal = -1
  RETURN



makepiece:
  rx = 9: rx = rx + ((lx - 1) * 28)
  ry = 8: ry = ry + ((ly - 1) * 24)
  IF flip THEN GOTO flipmake
  IF cl = 1 THEN bt = bt + 1:  ELSE wt = wt + 1
  PUT (rx, ry), shape#
  RETURN
flipmake:
  PUT (rx, ry), shape#
  IF sm = 1 THEN bt = bt + 1: wt = wt - 1:  ELSE bt = bt - 1: wt = wt + 1
  grid(lx, ly) = sm
  RETURN





checkmove:
  lm = 0: legal = 0
  test = -1
  sx = xx: yy = sy
  xx = 0: yy = 1
star:
  xx = xx + 1
  GOSUB domove
  IF legal THEN GOTO done
  IF xx = 8 THEN xx = 0: yy = yy + 1
  IF yy < 9 THEN GOTO star
  xx = sx: yy = sy
  RETURN
done:
  lm = -1: test = 0
  RETURN

initilize:
  sx = 1
  sy = 1
  l = 28
  w = 24
start:
  LINE (sx, sy)-(sx + l, sy + w), 2, B
  sx = sx + l: IF sx <> 225 THEN GOTO start
  sy = sy + w: sx = 1: IF sy <> 193 THEN GOTO start
  flip = 0: lx = 4: ly = 4: cl = 2: GOSUB makepiece
  lx = 5: ly = 5: GOSUB makepiece
  lx = 5: ly = 4: cl = 1: GOSUB makepiece
  lx = 4: ly = 5: GOSUB makepiece
RETURN

