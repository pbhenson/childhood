Unit Grid;

interface

uses crt;

procedure MakeGrid(Ux, Uy, Lx, Ly, GridType, GridForeColor, GridBackColor : byte);

implementation


procedure MakeGrid;
  var
    UpperLeftCorner,
    UpperRightCorner,
    LowerLeftCorner,
    LowerRightCorner,
    Across,
    Down,
    AcrossDown,
    AcrossUp,
    VertRight,
    VertLeft,
    Intersection : char;
    Count, CountMore, Row : byte;

  begin
    textcolor(GridForeColor);
    textbackground(GridBackColor);
    case GridType of
      1 : begin
            UpperLeftCorner := '�';
            UpperRightCorner := '�';
            LowerLeftCorner := '�';
            LowerRightCorner := '�';
            Across := '�';
            Down := '�';
            AcrossDown := '�';
            AcrossUp := '�';
            VertRight := '�';
            VertLeft := '�';
            Intersection := '�';
          end;

      2 : begin
            UpperLeftCorner := '�';
            UpperRightCorner := '�';
            LowerLeftCorner := '�';
            LowerRightCorner := '�';
            Across := '�';
            Down := '�';
            AcrossDown := '�';
            AcrossUp := '�';
            VertRight := '�';
            VertLeft := '�';
            Intersection := '�';
          end;

      3 : begin
            UpperLeftCorner := '�';
            UpperRightCorner := '�';
            LowerLeftCorner := '�';
            LowerRightCorner := '�';
            Across := '�';
            Down := '�';
            AcrossDown := '�';
            AcrossUp := '�';
            VertRight := '�';
            VertLeft := '�';
            Intersection := '�';
          end;

      4 : begin
            UpperLeftCorner := '�';
            UpperRightCorner := '�';
            LowerLeftCorner := '�';
            LowerRightCorner := '�';
            Across := '�';
            Down := '�';
            AcrossDown := '�';
            AcrossUp := '�';
            VertRight := '�';
            VertLeft := '�';
            Intersection := '�';
          end;
       else
         exit;
     end;
     begin
       gotoxy(Ux, Uy);
       write(UpperLeftCorner);
       for Count := 1 to (Lx - 2 - Ux -1) div 2 do
         write(Across, AcrossDown);
       write(Across, UpperRightCorner);
       Row := Uy + 1;
       gotoxy(Ux, Row);
       for Count := 1 to ((Ly -2 - Uy - 1) div 2)+1 do
         begin
           gotoxy(Ux, Row);
           write(Down);
           for CountMore := 1 to (Lx - 2 - Ux -1) div 2 do
             write(' ', Down);
           write(' ', Down);
           Row := Succ(Row);
           gotoxy(Ux, Row);
           write(VertRight);
           for CountMore := 1 to (Lx - 2 - Ux -1) div 2 do
             write(Across, Intersection);
           write(Across, VertLeft);
           Row := Succ(Row);
         end;
         gotoxy(Ux, Row);
         write(Down);
         for CountMore := 1 to (Lx - 2 - Ux -1) div 2 do
           write(' ', Down);
         write(' ', Down);

       gotoxy(Ux, Ly);
       write(LowerleftCorner);
       for Count := 1 to (Lx - 2 - Ux -1) div 2 do
         write(Across, AcrossUp);
       write(Across, LowerRightCorner);
     end;

  end;

end.