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
            UpperLeftCorner := 'Ú';
            UpperRightCorner := '¿';
            LowerLeftCorner := 'À';
            LowerRightCorner := 'Ù';
            Across := 'Ä';
            Down := '³';
            AcrossDown := 'Â';
            AcrossUp := 'Á';
            VertRight := 'Ã';
            VertLeft := '´';
            Intersection := 'Å';
          end;

      2 : begin
            UpperLeftCorner := 'É';
            UpperRightCorner := '»';
            LowerLeftCorner := 'È';
            LowerRightCorner := '¼';
            Across := 'Í';
            Down := 'º';
            AcrossDown := 'Ë';
            AcrossUp := 'Ê';
            VertRight := 'Ì';
            VertLeft := '¹';
            Intersection := 'Î';
          end;

      3 : begin
            UpperLeftCorner := 'Õ';
            UpperRightCorner := '¸';
            LowerLeftCorner := 'Ô';
            LowerRightCorner := '¾';
            Across := 'Í';
            Down := '³';
            AcrossDown := 'Ñ';
            AcrossUp := 'Ï';
            VertRight := 'Æ';
            VertLeft := 'µ';
            Intersection := 'Ø';
          end;

      4 : begin
            UpperLeftCorner := 'Ö';
            UpperRightCorner := '·';
            LowerLeftCorner := 'Ó';
            LowerRightCorner := '½';
            Across := 'Ä';
            Down := 'º';
            AcrossDown := 'Ò';
            AcrossUp := 'Ð';
            VertRight := 'Ç';
            VertLeft := '¶';
            Intersection := '×';
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