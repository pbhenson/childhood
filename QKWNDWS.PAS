Unit QkWndws;

interface

uses crt;

type
  bt = byte;
  IntType = integer;
  Str80Type = string[80];

  TitleTypes = (UpLeft,   UpCenter,    UpRight,
                 DownLeft, DownCenter,  DownRight,
                 TUpLeft,  TUpCenter,   TUpRight,
                 TDownLeft,TDownCenter, TDownRight);

  TitleSetType = set of TitleTypes;

  TitleNamesType = array [UpLeft..DownRight] of String[80];
  LocationRec = record
                  Ux, Uy, Lx, Ly : Inttype;
                end;
  BorderRec = record
                UpLeftCorn,
                UpRightCorn,
                DnLeftCorn,
                DnRightCorn,
                HorizBar,
                VertBar,
                LeftTitleBar,
                RightTitleBar : Char;
                BrdAttr : Byte;
              end;

  ScreenRec = array[1..4000] of char;

  Attributes = record
                 BrdFgAttr,
                 BrdBgAttr,
                 TxtFgAttr,
                 TxtBgAttr : IntType;
               end;


  StorRec = record
              buffer : ScreenRec;
              OldWindMin, OldWindMax : Word;
              OldTextAttr : byte;
              OldX, OldY : integer;
              Status : byte;
            end;


  WindRec = Record
              Attribs        : Attributes;
              BorderWanted   : IntType;
              Borders        : BorderRec;
              TitlesWanted   : TitleSetType;
              TitleNames     : TitleNamesType;
              Location       : LocationRec;
            end;

  SWindRec = Record
               Attribs        : Attributes;
               BorderWanted   : IntType;
               Borders        : BorderRec;
               Location       : LocationRec;
             end;

  RWindRec = record
               Attribs        : attributes;
               BorderWanted   : IntType;
               Borders        : BorderRec;
               TitlesWanted   : TitleSetType;
               TitleNames     : TitleNamesType;
               Location       : LocationRec;
               Storage        : StorRec;
             end;

  SRWindRec = Record
                Attribs        : Attributes;
                BorderWanted   : IntType;
                Borders        : BorderRec;
                Location       : LocationRec;
                Storage        : StorRec;
              end;






const
  UserBorder    = -1;
  NoBorder      =  0;
  AllSingleLine =  1;
  AllDoubleLine =  2;
  TopSingleLine =  3;
  SidSingleLine =  4;
  GraphType1    =  5;
  GraphType2    =  6;
  GraphType3    =  7;
  GraphType4    =  8;

  NoTitle       =  0;
  TopLeft       =  1;
  TopCenter     =  2;
  TopRight      =  3;
  BottomLeft    =  4;
  BottomCenter  =  5;
  BottomRight   =  6;
  FTopLeft      =  7;
  FTopCenter    =  8;
  FTopRight     =  9;
  FBottomLeft   = 10;
  FBottomCenter = 11;
  FBottomRight  = 12;


procedure MkWindow(var ThisWindow : WindRec);
procedure MkSWindow(var ThisSWindow : SWindRec);
procedure MkRWindow(var ThisRWindow : RWindRec);
procedure MkSRWindow(var ThisSRWindow : SRWindRec);
procedure RmWindow(var ThisRWindow : RWindRec);
procedure RmSWindow(var ThisSRWindow : SRWindRec);


implementation

var
  ScreenPtr : ^screenrec;
  VideoMode : byte absolute $0040:$0049;
  VideoPage : byte absolute $0040:$0062;

function scrmem(x,y : integer) : integer;
  begin
    case videomode of
      BW80, C80, Mono : scrmem := (y-1)*160 + x*2 -1;
      BW40, C40       : scrmem := (y-1)*80 + x*2 -1;
    end;
  end;

function Valid(Location : LocationRec) : boolean;
var
  temp : boolean;
 begin
    with Location do
      begin
        Temp := (ux>1) and (ux<80) and (lx>1) and (lx<80);
        Temp := temp and (uy>1) and (uy<25) and (ly>1) and (ly<25);
        Valid := temp and (ux<lx) and (uy<ly);
      end;
 end;

procedure CngMem(addr : integer; ch : char; attr : integer);
begin
  screenptr^[addr] := ch;
  screenptr^[addr+1] := chr(attr);
end;


procedure AssignBorder(BorderType: IntType; var Borders : BorderRec);
  begin
    with Borders do
      case BorderType of
        NoBorder      : begin
                          UpLeftCorn    := #0;
                          UpRightCorn   := #0;
                          DnLeftCorn    := #0;
                          DnRightCorn   := #0;
                          HorizBar      := #0;
                          VertBar       := #0;
                          LeftTitleBar  := #0;
                          RightTitleBar := #0;
                        end; {NoBorder}
        AllSingleLine : begin
                          UpLeftCorn    := #218;
                          UpRightCorn   := #191;
                          DnLeftCorn    := #192;
                          DnRightCorn   := #217;
                          HorizBar      := #196;
                          VertBar       := #179;
                          LeftTitleBar  := #180;
                          RightTitleBar := #195;
                        end; {AllSingleLine}
        AllDoubleLine : begin
                          UpLeftCorn    := #201;
                          UpRightCorn   := #187;
                          DnLeftCorn    := #200;
                          DnRightCorn   := #188;
                          HorizBar      := #205;
                          VertBar       := #186;
                          LeftTitleBar  := #181;
                          RightTitleBar := #198;
                        end; {AllDoubleLine}
        TopSingleLine : begin
                          UpLeftCorn    := #214;
                          UpRightCorn   := #183;
                          DnLeftCorn    := #211;
                          DnRightCorn   := #189;
                          HorizBar      := #196;
                          VertBar       := #186;
                          LeftTitleBar  := #180;
                          RightTitleBar := #195;
                        end; {TopSingleLine}
        SidSingleLine : begin
                          UpLeftCorn    := #213;
                          UpRightCorn   := #184;
                          DnLeftCorn    := #212;
                          DnRightCorn   := #190;
                          HorizBar      := #205;
                          VertBar       := #179;
                          LeftTitleBar  := #181;
                          RightTitleBar := #198;
                        end; {SidSingleLine}
        GraphType1    : begin
                          UpLeftCorn    := #176;
                          UpRightCorn   := #176;
                          DnLeftCorn    := #176;
                          DnRightCorn   := #176;
                          HorizBar      := #176;
                          VertBar       := #176;
                          LeftTitleBar  := #176;
                          RightTitleBar := #176;
                        end; {GraphChar1}
        GraphType2    : begin
                          UpLeftCorn    := #177;
                          UpRightCorn   := #177;
                          DnLeftCorn    := #177;
                          DnRightCorn   := #177;
                          HorizBar      := #177;
                          VertBar       := #177;
                          LeftTitleBar  := #177;
                          RightTitleBar := #177;
                        end; {GraphType2}
        GraphType3    : begin
                          UpLeftCorn    := #178;
                          UpRightCorn   := #178;
                          DnLeftCorn    := #178;
                          DnRightCorn   := #178;
                          HorizBar      := #178;
                          VertBar       := #178;
                          LeftTitleBar  := #178;
                          RightTitleBar := #178;
                        end; {GraphType3}
        GraphType4    : begin
                          UpLeftCorn    := #219;
                          UpRightCorn   := #219;
                          DnLeftCorn    := #219;
                          DnRightCorn   := #219;
                          HorizBar      := #219;
                          VertBar       := #219;
                          LeftTitleBar  := #219;
                          RightTitleBar := #219;
                       end; {GraphType4}
       end; {case}
end;
procedure DrawBorders(Borders : BorderRec; Location : LocationRec);
  var
    Count : IntType;
begin
    with Borders do
      with Location do
      begin
        cngmem(scrmem(ux-1,uy-1), UpLeftCorn, brdattr);
        cngmem(scrmem(lx+1, uy-1), UpRightCorn, brdattr);
        cngmem(scrmem(ux-1, ly+1), DnLeftCorn, brdattr);
        cngmem(scrmem(lx+1, ly+1), DnRightCorn, brdattr);
        for count := uy to ly do
          begin
            cngmem(scrmem(ux-1, count), VertBar, brdattr);
          end;
        for count := uy to ly do
          begin
            cngmem(scrmem(lx+1, count), VertBar, brdattr);
          end;
        for count := ux to lx do
          begin
            cngmem(scrmem(count, uy-1), HorizBar, brdattr);
          end;
        for count := ux to lx do
          begin
            cngmem(scrmem(count, ly+1), HorizBar, brdattr);
          end;
         end;
    end;


procedure DrawTitles(Location : LocationRec; TitlesWanted : TitleSetType; TitleNames : TitleNamesTYpe; Borders : BorderRec);
  var
    name : Str80Type;
    Count, LeftSide, RightSide : integer;
  begin
    with Location do
      with Borders do
        begin
     {This is Upper Left}
          If (UpLeft in TitlesWanted) then
            begin
              name := Titlenames[UpLeft];
              for count := 0 to (length(name)-1) do
                begin
                  cngmem(scrmem(ux+count, uy-1), name[count+1], brdattr);
                end;
              name := '';
            end; {UpLeftInBordersWanted}
       {Upper Right}
          If (UpRight in TitlesWanted) then
            begin
              name := Titlenames[upright];
              for count := ((lx-length(name))+1) to lx do
                begin
                  cngmem(scrmem(count, uy-1), name[count-(lx-length(name))], brdattr);
                end;
              name := '';
            end; {UpperRight}

{Upper Center}
        If (UpCenter in TitlesWanted) then
          begin
            name := titlenames[upcenter];
            leftside := ux+(((lx-ux)div 2)-length(Name))+((length(Name)+length(Name)+1)div 2)-(length(Name)div 2);
            rightside := ux+(((lx-ux)div 2)-length(Name))+((length(Name)+length(Name)+1)div 2)+(length(Name)div 2);
            if (not(odd(length(Name)))) then rightside := rightside -1;
            for count := leftside to rightside do
              begin
                cngmem(scrmem(count, uy-1), Name[count-(leftside-1)], brdattr);
              end;
            name := '';
          end; {UpCent}

{Down Left}
        If (DownLeft in TitlesWanted) then
          begin
            name := titlenames[downleft];
            for count := 0 to (length(Name)-1) do
              begin
                cngmem(scrmem(ux+count, ly+1), Name[count+1], brdattr);
              end;
            name := '';
          end; {DownLeft}

{Down Right}
        If (DownRight in TitlesWanted) then
          begin
            name := titlenames[downright];
            for count := ((lx-length(Name))+1) to lx do
              begin
                cngmem(scrmem(count, ly+1), Name[count-(lx-length(Name))], brdattr);
              end;
            name := '';
          end; {DownRight}

{Down Center}
        If (DownCenter in TitlesWanted) then
          begin
            name := titlenames[downcenter];
            leftside := ux+(((lx-ux)div 2)-length(Name))+((length(Name)+length(Name)+1)div 2)-(length(Name)div 2);
            rightside := ux+(((lx-ux)div 2)-length(Name))+((length(Name)+length(Name)+1)div 2)+(length(Name)div 2);
            if (not(odd(length(name)))) then rightside := rightside -1;
            for count := leftside to rightside do
              begin
                cngmem(scrmem(count, ly+1), name[count-(leftside-1)], brdattr);
              end;
            name := '';
          end; {DownCenter}

{Upper Left Titled}
        If (TUpLeft in TitlesWanted) then
          begin
            name := titlenames[upleft];
            cngmem(scrmem(ux, uy-1), LeftTitleBar, brdattr);
            cngmem(scrmem(ux+1, uy-1), chr(32), brdattr);
            for count := 2 to (length(name)+1) do
              begin
                cngmem(scrmem(ux+count, uy-1), name[count+1-2], brdattr);
              end;
            cngmem(scrmem(ux+length(name)+1+1, uy-1), chr(32), brdattr);
            cngmem(scrmem(ux+length(name)+1+2, uy-1), RightTitleBar, brdattr);
            name := '';
          end; {TUpLeft}


{Upper Right Titled}
        If (TUpRight in TitlesWanted) then
          begin
            name := titlenames[upright];
            cngmem(scrmem(((lx-length(name))+1)-4, uy-1), LeftTitleBar, brdattr);
            cngmem(scrmem(((lx-length(name))+1)-3, uy-1), chr(32), brdattr);
            for count :=  ((lx-length(name))+1)-2 to lx-2 do
              begin
                cngmem(scrmem(count, uy-1), name[(count+2)-(lx-length(name))], brdattr);
              end;
            cngmem(scrmem(lx-2+1, uy-1), chr(32), brdattr);
            cngmem(scrmem(lx-2+2, uy-1), RightTitleBar, brdattr);
            name := '';
          end; {TUpRight}

{Upper Center Titled}
        If (TUpCenter in TitlesWanted) then
          begin
            name := titlenames[upcenter];
            leftside := ux+(((lx-ux)div 2)-length(name))+((length(name)+length(name)+1)div 2)-(length(name)div 2);
            rightside := ux+(((lx-ux)div 2)-length(name))+((length(name)+length(name)+1)div 2)+(length(name)div 2);
            if (not(odd(length(name)))) then rightside := rightside -1;
            cngmem(scrmem(leftside-2, uy-1), LeftTitleBar, brdattr);
            cngmem(scrmem(leftside-1, uy-1), chr(32), brdattr);
            for count := leftside to rightside do
              begin
                cngmem(scrmem(count, uy-1), name[count-(leftside-1)], brdattr);
              end;
            cngmem(scrmem(rightside+1, uy-1), chr(32), brdattr);
            cngmem(scrmem(rightside+2, uy-1), RightTitleBar, brdattr);
            name := '';
          end; {TUpCenter}

{Lower Left Titled}
        If (TDownLeft in TitlesWanted) then
          begin
            name := titlenames[downleft];
            cngmem(scrmem(ux, ly+1), LeftTitleBar, brdattr);
            cngmem(scrmem(ux+1, ly+1), chr(32), brdattr);
            for count := 2 to (length(name)+1) do
              begin
                cngmem(scrmem(ux+count, ly+1), name[count+1-2], brdattr);
              end;
            cngmem(scrmem(ux+length(name)+1+1, ly+1), chr(32), brdattr);
            cngmem(scrmem(ux+length(name)+1+2, ly+1), RightTitleBar, brdattr);
            name := '';
          end; {TDownLeft}

{Lower Right Titled}
        If (TDownRight in TitlesWanted) then
          begin
            name := titlenames[downright];
            cngmem(scrmem(((lx-length(name))+1)-4, ly+1), LeftTitleBar, brdattr);
            cngmem(scrmem(((lx-length(name))+1)-3, ly+1), chr(32), brdattr);
            for count :=  ((lx-length(name))+1)-2 to lx-2 do
              begin
                cngmem(scrmem(count, ly+1), name[(count+2)-(lx-length(name))], brdattr);
              end;
            cngmem(scrmem(lx-2+1, ly+1), chr(32), brdattr);
            cngmem(scrmem(lx-2+2, ly+1), RightTitleBar, brdattr);
            name := '';
          end; {TDownRight}

{Lower Center Titled}
        If (TDownCenter in TitlesWanted) then
          begin
            name := titlenames[downcenter];
            leftside := ux+(((lx-ux)div 2)-length(name))+((length(name)+length(name)+1)div 2)-(length(name)div 2);
            rightside := ux+(((lx-ux)div 2)-length(name))+((length(name)+length(name)+1)div 2)+(length(name)div 2);
            if (not(odd(length(name)))) then rightside := rightside -1;
            cngmem(scrmem(leftside-2, ly+1), LeftTitleBar, brdattr);
            cngmem(scrmem(leftside-1, ly+1), chr(32), brdattr);
            for count := leftside to rightside do
              begin
                cngmem(scrmem(count, ly+1), name[count-(leftside-1)], brdattr);
               end;
           cngmem(scrmem(rightside+1, ly+1), chr(32), brdattr);
           cngmem(scrmem(rightside+2, ly+1), RightTitleBar, brdattr);
            name := '';
          end; {TDownCenter}
        end;
      end;




procedure SaveCurrentScreen(var Storage : StorRec);
  begin
    with Storage do
      begin
        move(Screenptr^, Buffer, 4000);
        OldWindMin := WindMin;
        OldWindMax := WindMax;
        OldTextAttr := TextAttr;
        OldX := WhereX;
        OldY := WhereY;
      end;
    end;

procedure RmWindow(var ThisRWindow : RWindRec);
begin
  with ThisRWindow.storage do
    begin
      if status <> 172 then
        begin
          writeln('ERROR! Non-defined window record passed to RmWindow!!');
          halt(1);
        end;
      move(Buffer, screenptr^, 4000);
      WindMin := OldWindMin;
      WindMax := OldWindMax;
      TextAttr := OldTextAttr;
      GotoXy(OldX, OldY);
    end;
end;

procedure RmSWindow(var ThisSRWindow : SRWindRec);
begin
  with ThisSRWindow.storage do
    begin
      if status <> 172 then
        begin
          writeln('ERROR! Non-defined window record passed to RmWindow!!');
          halt(1);
        end;
      move(Buffer, screenptr^, 4000);
      WindMin := OldWindMin;
      WindMax := OldWindMax;
      TextAttr := OldTextAttr;
      GotoXy(OldX, OldY);
    end;
end;



procedure MkRWindow(var ThisRWindow : RWindRec);
  begin
    with thisRWindow do
      begin
        storage.Status := 172;
        Borders.BrdAttr := Attribs.BrdFgattr + (Attribs.brdbgattr *16);
        SaveCurrentScreen(Storage);
        if valid(Location) then
          begin
            if BorderWanted <> NoBorder then
              begin
                AssignBorder(BorderWanted, Borders);
                DrawBorders(Borders, Location);
              end;
            DrawTitles(Location, TitlesWanted, TitleNames, borders);
          end;
        with Location do
          window(Ux, Uy, Lx, Ly);
        TextColor(Attribs.txtfgattr);
        textbackground(Attribs.txtbgattr);
        clrscr;
      end;
  end;



procedure MkWindow(var ThisWindow : WindRec);
  begin
    with ThisWindow do
      begin
        Borders.BrdAttr := Attribs.BrdFgattr + (Attribs.brdbgattr *16);
        if valid(Location) then
          begin
            if BorderWanted <> NoBorder then
              begin
                AssignBorder(BorderWanted, Borders);
                DrawBorders(Borders, Location);
              end;
            DrawTitles(Location, TitlesWanted, TitleNames, borders);
          end;
        with Location do
          window(Ux, Uy, Lx, Ly);
        TextColor(Attribs.txtfgattr);
        textbackground(Attribs.txtbgattr);
        clrscr;
      end;
  end;


procedure MkSRWindow(var ThisSRWindow : SRWindRec);
  begin
    with ThisSRWindow do
      begin
        storage.Status := 172;
        Borders.BrdAttr := Attribs.BrdFgattr + (Attribs.brdbgattr *16);
        SaveCurrentScreen(Storage);
        if valid(Location) then
          begin
            if BorderWanted <> NoBorder then
              begin
                AssignBorder(BorderWanted, Borders);
                DrawBorders(Borders, Location);
              end;
          end;
        with Location do
          window(Ux, Uy, Lx, Ly);
        TextColor(Attribs.txtfgattr);
        textbackground(Attribs.txtbgattr);
        clrscr;
      end;
  end;

procedure MkSWindow(var ThisSWindow : SWindRec);
  begin
    with ThisSWindow do
      begin
        Borders.BrdAttr := Attribs.BrdFgattr + (Attribs.brdbgattr *16);
        if valid(Location) then
          begin
            if BorderWanted <> NoBorder then
              begin
                AssignBorder(BorderWanted, Borders);
                DrawBorders(Borders, Location);
              end;
          end;
        with Location do
          window(Ux, Uy, Lx, Ly);
        TextColor(Attribs.txtfgattr);
        textbackground(Attribs.txtbgattr);
        clrscr;
      end;
  end;


begin
  case VideoMode of
    BW40, BW80, CO40, CO80 : ScreenPtr := ptr($B800, 0000);
    Mono                   : ScreenPtr := ptr($B000, 0000);
    else begin
           textmode(CO80);
           ScreenPtr := ptr($B800,0000);
         end;
  end;

end.