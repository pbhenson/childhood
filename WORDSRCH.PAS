program WordSearch;

{$M 49152,0,655360}
uses Crt, FastTTT5, Dos, KeyTTT5, WinTTT5, MenuTTT5, PullTTT5, ListTTT5, DirTTT5, Qkwndws, IO, Grid;

const
  RowMin = 1;
  RowMax = 12;
  ColumnMin = 1;
  ColumnMax = 39;
  MaxWords = 30;

const
  GridWanted     : byte = 0;
  GridForeC      : byte = 5;
  GridBackC      : byte = 0;
  HighForeC      : byte = 3;
  HighBackC      : byte = 1;
  OnHighForeC    : byte = 5;
  OnHighBackC    : byte = 0;
  NormForeC      : byte = 7;
  NormBackC      : byte = 0;
  CaseDesired    : boolean = false;

type
  CompassDirections = (North, South, East, West, NorthEast, NorthWest, SouthEast, SouthWest);
  WordRec = record
              Word : string[20];
              Xloc,
              Yloc : byte;
              WordDirection : CompassDirections;
              Found : boolean;
            end;

  WordArray = array[1..MaxWords] of WordRec;

  UnitRec = record
              Letter : char;
              HighLighted : boolean;
            end;

  GridArray = array[RowMin..RowMax, ColumnMin..ColumnMax] of UnitRec;


var
  Words : WordArray;
  TotalWords : byte;
  WordsLeft : byte;
  Letters : GridArray;
  MainMenu,
  OptionsMenu : Menu_Record;
  GridMenu : Pull_Array;
  GenericWindow : WindRec;
  GenericSRWindow : SRWindRec;
  Ready : boolean;


procedure CursorOff;
  inline($B8/$40/$00/ {mov ax, 0040}
         $8E/$C0/     {mov es, ax}
         $B4/$01/     {mov ah, 1}
         $26/              {es:}
         $8A/$0E/$60/$00/  {mov cl, byte ptr[0060]}
         $26/
         $8A/$2E/$61/$00/  {mov ch, byte ptr[00601]}
         $80/$CD/$20/      {or ch, 20}
         $CD/$10);         {int 10h}


procedure CursorOn;
  inline($B8/$40/$00/ {mov ax, 0040}
         $8E/$C0/     {mov es, ax}
         $B4/$01/     {mov ah, 1}
         $26/              {es:}
         $8A/$0E/$60/$00/  {mov cl, byte ptr[0060]}
         $26/
         $8A/$2E/$61/$00/  {mov ch, byte ptr[00601]}
         $80/$E5/$DF/      {and ch, DF}
         $CD/$10);         {int 10h}

{$F+}
procedure TopicHelp(var Ch: char; Choice : integer; var Ecode : integer);
  begin
    if ch = #187 then
      begin
        savescreen(4);
        clrscr;
        writeln('This COULD be Topic-Sensitive HELP!');
        delaykey(20000);
        sliderestorescreen(4, WinTTT5.Up);
        disposescreen(4);
      end;
  end;

procedure PullTopicHelp(var ChM : char; PickM, PickS : byte);
  begin
    if chm = #187 then
      begin
        savescreen(4);
        clrscr;
        writeln('This COULD be Topic-Sensitive HELP!');
        delaykey(20000);
        sliderestorescreen(4, WinTTT5.Up);
        disposescreen(4);
      end;
  end;
{$F-}


procedure DisplayHelpWindow;
  begin
    with GenericSRWindow do
      begin
        with attribs do
          begin
            BrdFgAttr := Blue;
            BrdBgAttr := Cyan;
            TxtFgAttr := LightGray;
            TxtBgAttr := Blue;
          end;
        BorderWanted := SidSingleLine;
        with Location do
          begin
            Ux := 15;
            Uy := 5;
            Lx := 65;
            Ly := 20;
          end;
      end;
    MkSRWindow(GenericSRWindow);
  end;

procedure DisplayWordNotesWindow;
  begin
    with GenericSRWindow do
      begin
        with attribs do
          begin
            BrdFgAttr := Cyan;
            BrdBgAttr := Blue;
            TxtFgAttr := LightGray;
            TxtBgAttr := Blue;
          end;
        BorderWanted := SidSingleLine;
        with Location do
          begin
            Ux := 28;
            Uy := 8;
            Lx := 51;
            Ly := 13;
          end;
      end;
    MkSRWindow(GenericSRWindow);
  end;

procedure TitleScreen;
  begin
    WriteAT(1,1,Blue,Green,'HA! WordSearch!');
  end;

procedure Initilize;
  procedure DefineMainMenu;
    begin
      Menu_Set(MainMenu);
      with MainMenu do
        begin
          Heading1 := 'WordSearch 1.0';
          Heading2 := 'Main Menu';
          Topic[1] := 'Make Puzzle';
          Topic[2] := 'Load Puzzle';
          Topic[3] := 'Change Options';
          Topic[4] := 'Quit';
          TotalPicks := 4;
          PicksPerLine := 1;
          AddPrefix := 3;
          TopLeftXY[1] := 0;
          TopLeftXY[2] := 0;
          BoxType := 5;
          Colors[1] := White;
          Colors[2] := Red;
          Colors[3] := LightGray;
          Colors[4] := Blue;
          Colors[5] := LightCyan;
          Margins := 5;
          AllowEsc := False;
          Hook := TopicHelp;
      end;
    end;

  procedure DefineOptionsMenu;
    begin
      Menu_Set(OptionsMenu);
      with OptionsMenu do
        begin
          Heading1 := 'WordSearch 1.0';
          Heading2 := 'Options Menu';
          Topic[1] := 'Alter Grid Type';
          Topic[2] := 'Define Colors';
          Topic[3] := 'Change Letter Case';
          Topic[4] := 'Save Changes';
          Topic[5] := 'Restore Defaults';
          Topic[6] := 'Return to Main';
          TotalPicks := 6;
          PicksPerLine := 1;
          AddPrefix := 3;
          TopLeftXY[1] := 45;
          TopLeftXY[2] := 2;
          BoxType := 5;
          Colors[1] := White;
          Colors[2] := Red;
          Colors[3] := LightGray;
          Colors[4] := Blue;
          Colors[5] := LightCyan;
          Margins := 5;
          AllowEsc := False;
          Hook := TopicHelp;
        end;
    end;
  procedure DefineGridMenu;
    begin
      fillchar(GridMenu, sizeof(GridMenu), #0);
      PTTT.Gap := 5;

      GridMenu[1] := '\File';
      GridMenu[2] := 'Load puzzle';
      GridMenu[3] := 'load Game  ';
      GridMenu[4] := 'Save puzzle';
      GridMenu[5] := 'saVe game  ';
      GridMenu[6] := 'Print      ';
      GridMenu[7] := 'Main menu  ';
      GridMenu[8] := 'Quit       ';

      GridMenu[9] := '\Options';

      GridMenu[10] := '\Hint';
      GridMenu[11] := 'First letter   ';
      GridMenu[12] := 'Direction      ';
      GridMenu[13] := 'Across location';
      GridMenu[14] := 'down Location  ';

      GridMenu[15] := '\Statistics';

      GridMenu[16] := '\\';
    end;

  var
    Row, Column : byte;
  begin
    Randomize;
    clrscr;
    Ready := False;
    DefineMainMenu;
    DefineOptionsMenu;
    DefineGridMenu;
    PTTT.Hook := PullTopicHelp;
    for Row := RowMin to RowMax do
      for Column := ColumnMin to ColumnMax do
        begin
          Letters[Row, Column].Letter := #1;
          Letters[Row, Column].HighLighted := False;
        end;
    for Row := 1 to MaxWords do
      begin
        Words[Row].Word := '';
        Words[Row].Found := False;
        Words[Row].Xloc := 255;
      end;
  end;

function FixString(ToFix : string) : string;
  var
    Index : byte;
  begin
    if ToFix = '' then
      begin
        FixString := ToFix;
        exit;
      end;
    if CaseDesired then
      begin
        Index := 1;
        repeat
          case ToFix[Index] of
            'a'..'z' : begin
                         ToFix[Index] := upcase(ToFix[Index]);
                         Index := Succ(Index);
                       end;
            'A'..'Z' : Index := Succ(Index);
          else
            delete(ToFix, Index, 1);
          end;
        until Index = (length(ToFix) + 1);
      end
    else
      begin
        Index := 1;
        repeat
          case ToFix[Index] of
            'a'..'z' : Index := Succ(Index);
            'A'..'Z' : begin
                         ToFix[Index] := chr(ord(ToFix[Index])+32);
                         Index := succ(Index);
                       end;
          else
            delete(ToFix, Index, 1);
          end;
        until Index = (length(ToFix)+1);
      end;
    FixString := ToFix;
  end;




procedure ChangeOptions;
  var
    GridMenu,
    MainColorMenu,
    SecondColorMenu : Menu_Record;
    Choice,
    Retcode : integer;
    Changed : boolean;

  procedure InitLocalMenus;
    begin
      Menu_Set(GridMenu);
      with GridMenu do
        begin
          Heading1 := '';
          Heading2 := '';
          Topic[1] := 'No Grid';
          Topic[2] := 'Single Bars';
          Topic[3] := 'Double Bars';
          Topic[4] := 'Mix Type 1';
          Topic[5] := 'Mix Type 2';
          TotalPicks := 5;
          PicksPerLine := 1;
          AddPrefix := 0;
          TopLeftXY[1] := 36;
          TopLeftXY[2] := 7;
          BoxType := 4;
          Colors[1] := White;
          Colors[2] := Red;
          Colors[3] := LightGray;
          Colors[4] := Black;
          Colors[5] := LightBlue;
          Margins := 0;
          AllowEsc := True;
      end;

      Menu_Set(MainColorMenu);
      with MainColorMenu do
        begin
          Heading1 := '';
          Heading2 := '';
          Topic[1] := 'Grid Foreground';
          Topic[2] := 'Grid Background';
          Topic[3] := 'High Foreground';
          Topic[4] := 'High Background';
          Topic[5] := 'Normal Foreground';
          Topic[6] := 'Normal Background';
          TotalPicks := 6;
          PicksPerLine := 1;
          AddPrefix := 0;
          TopLeftXY[1] := 30;
          TopLeftXY[2] := 8;
          BoxType := 4;
          Colors[1] := White;
          Colors[2] := Red;
          Colors[3] := LightGray;
          Colors[4] := Black;
          Colors[5] := LightBlue;
          Margins := 0;
          AllowEsc := True;
      end;

      Menu_Set(SecondColorMenu);
      with SecondColorMenu do
        begin
          Heading1 := '';
          Heading2 := '';
          Topic[1] := 'Black';
          Topic[2] := 'Blue';
          Topic[3] := 'Green';
          Topic[4] := 'Cyan';
          Topic[5] := 'Red';
          Topic[6] := 'Magenta';
          Topic[7] := 'Brown';
          Topic[8] := 'Light Gray';
          Topic[9] := 'Dark Gray';
          Topic[10] := 'Light Blue';
          Topic[11] := 'Light Green';
          Topic[12] := 'Light Cyan';
          Topic[13] := 'Light Red';
          Topic[14] := 'Light Magenta';
          Topic[15] := 'Yellow';
          Topic[16] := 'White';
          TotalPicks := 16;
          PicksPerLine := 1;
          AddPrefix := 0;
          TopLeftXY[1] := 14;
          TopLeftXY[2] := 8;
          BoxType := 4;
          Colors[1] := White;
          Colors[2] := Red;
          Colors[3] := LightGray;
          Colors[4] := Black;
          Colors[5] := LightBlue;
          Margins := 0;
          AllowEsc := True;
      end;

    end;

  procedure AlterGrid;
    var
      Choice, Retcode : integer;
    begin
     Choice := GridWanted + 1;
     DisplayMenu(GridMenu, true, Choice, Retcode);
     if (Retcode = 0) and (Choice-1 <> GridWanted) then
       begin
         GridWanted := Choice - 1;
         Changed := true;
       end;
    end;

  procedure DefineColors;
    var
      Choice, Retcode : integer;
      Choice2, Retcode2 : integer;
    begin
      Choice := 1;
      SaveScreen(6);
      DisplayMenu(MainColorMenu, false, Choice, Retcode);
      if Retcode <> 0 then
        begin
          RestoreScreen(6);
          DisposeScreen(6);
          exit;
        end;
      case Choice of
        1 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 16;
                  TopLeftXY[1] := 14;
                  TopLeftXY[2] := 8;
                end;
              Choice2 := GridForeC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, RetCode2);
              if (Retcode2 = 0) and (Choice2 <> GridForeC+1) then
                begin
                  GridForeC := Choice2 - 1;
                  Changed := true;
                end;
            end;
        2 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 8;
                  TopLeftXY[1] := 17;
                  TopLeftXY[2] := 10;
                end;
              Choice2 := GridBackC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, Retcode2);
              if (Retcode2 = 0) and (Choice2 <> GridBackC + 1) then
                begin
                  GridBackC := Choice2 - 1;
                  Changed := true;
                end;
            end;
        3 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 16;
                  TopLeftXY[1] := 14;
                  TopLeftXY[2] := 8;
                end;
              Choice2 := HighForeC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, Retcode2);
              if (Retcode2 = 0) and (Choice2 <> HighForeC + 1) then
                begin
                  HighForeC := Choice2 - 1;
                  Changed := true;
                end;
            end;
        4 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 8;
                  TopLeftXY[1] := 17;
                  TopLeftXY[2] := 12;
                end;
              Choice2 := HighBackC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, Retcode2);
              if (Retcode2 = 0) and (Choice2 <> HighBackC + 1) then
                begin
                  HighBackC := Choice2 - 1;
                  Changed := true;
                end;
            end;
        5 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 16;
                  TopLeftXY[1] := 14;
                  TopLeftXY[2] := 8;
                end;
              Choice2 := NormForeC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, Retcode2);
              if (Retcode2 = 0) and (Choice2 <> NormForeC + 1) then
                begin
                  NormForeC := Choice2 - 1;
                  Changed := true;
                end;
            end;
        6 : begin
              with SecondColorMenu do
                begin
                  TotalPicks := 8;
                  TopLeftXY[1] := 17;
                  TopLeftXY[2] := 14;
                end;
              Choice2 := NormBackC + 1;
              DisplayMenu(SecondColorMenu, true, Choice2, Retcode2);
              if (Retcode2 = 0) and (Choice2 <> NormBackC + 1) then
                begin
                  NormBackC := Choice2 - 1;
                  Changed := true;
                end;
            end;
      end;


      RestoreScreen(6);
      DisposeScreen(6);
    end;

  procedure PrepareScreen;
    var
      Row, Column : byte;
      ToHighLight1 : string[10];
      ToHighLight2 : string[14];
    begin
      clrscr;
      if CaseDesired then
        begin
          ToHighLight1 := 'WORDSEARCH';
          ToHighLight2 := 'BY PAUL HENSON';
        end
      else
        begin
          ToHighLight1 := 'wordsearch';
          ToHighLight2 := 'by paul henson';
        end;
      MakeGrid(1,1,80,25, GridWanted, GridForeC, GridBackC);
      for Row := RowMin to RowMax do
        for Column := ColumnMin to ColumnMax do
          begin
            if CaseDesired then
              WriteAT(Column*2, Row*2, NormForeC, NormBackC, chr(random(26)+65))
            else
              WriteAT(Column*2, Row*2, NormForeC, NormBackC, chr(random(26)+97));
          end;
      for Column := 6 to 15 do
        WriteAT(Column*2, 4, HighForeC, HighBackC, ToHighLight1[Column-5]);
      for Column := 4 to 17 do
        WriteAT(Column*2, 6, HighForeC, HighBackC, ToHighLight2[Column-3]);

    end;
  procedure SaveOptions;
    begin
    end;

  begin
    InitLocalMenus;
    Changed := true;
    repeat
      if Changed then
        PrepareScreen;
      Changed := false;
      Choice := 1;
      DisplayMenu(OptionsMenu, false, Choice, Retcode);
      case Choice of
        1 : AlterGrid;
        2 : DefineColors;
        3 : begin
              CaseDesired := not(CaseDesired);
              Changed := true;
            end;
        4 : SaveOptions;
        5 : begin
              GridWanted     := 0;
              GridForeC      := 5;
              GridBackC      := 0;
              HighForeC      := 3;
              HighBackC      := 1;
              OnHighForeC    := 5;
              OnHighBackC    := 0;
              NormForeC      := 7;
              NormBackC      := 0;
              CaseDesired    := false;
              Changed := True;
            end;
      end;
    until Choice = 6;
  end;

procedure MakePuzzle;
  procedure GetWords;
    var
      Index : byte;
    begin
      clrscr;
      writeln('Please enter up to ', MaxWords, ' words:');
      writeln;
      Index := 0;
      TotalWords := 0;
      CursorOn;
      repeat
        Index := Succ(Index);
        write('    ',Index,': ');
        Words[Index].Word := GetString(20);
        Words[Index].Word := FixString(Words[Index].Word);
        writeln;
        TotalWords := Succ(TotalWords);
      until (Index = MaxWords) or (Words[Index].Word='');
      if Words[Index].Word = '' then TotalWords := Pred(TotalWords);
      WordsLeft := TotalWords;
      CursorOff;
    end;

  function InsertWords : boolean;
    var
      ToGoX, ToGoY : byte;
      ToAttemptX, ToAttemptY : byte;
      ToGoDir : CompassDirections;
      WordIndex : byte;
      DoneWithWord : boolean;
    function AttemptInsert : boolean;
      var
        Count : byte;
        OtherX, OtherY : byte;
      begin
        with Words[WordIndex] do
          begin
            case ToGoDir of
              North     : if ToAttemptY < length(Word) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              South     : if (RowMax - ToAttemptY) < length(Word) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              West      : if (ColumnMax - ToAttemptX) < length(Word) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              East      : if ToAttemptX < length(Word) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              NorthWest : if (ToAttemptY < length(word)) or ( (ColumnMax - ToAttemptX) < length(Word)) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              NorthEast : if (ToAttemptY < length(Word)) or (ToAttemptX < length(word)) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
              SouthWest : if ( (RowMax-ToAttemptY) < length(word)) or ( (ColumnMax-ToAttemptX) < length(word)) then
                            begin
                              AttemptInsert := False;
                              exit
                            end;
              SouthEast : if ( (RowMax - ToAttemptY) < length(word)) or (ToAttemptX < length(word)) then
                            begin
                              AttemptInsert := False;
                              exit;
                            end;
            end;
            OtherX := ToAttemptX;
            OtherY := ToAttemptY;
            for Count := 1 to length(word) do
              begin
                if Letters[OtherY, OtherX].Letter <> #1 then
                  begin
                    AttemptInsert := False;
                    exit;
                  end;
                case ToGoDir of
                  North     : OtherY := Pred(OtherY);
                  South     : OtherY := Succ(OtherY);
                  West      : OtherX := Succ(OtherX);
                  East      : OtherX := Pred(OtherX);
                  NorthWest : begin
                                OtherY := Pred(OtherY);
                                OtherX := Succ(OtherX);
                              end;
                  NorthEast : begin
                                OtherY := Pred(OtherY);
                                OtherX := Pred(OtherX);
                              end;
                  SouthWest : begin
                                OtherY := Succ(OtherY);
                                OtherX := Succ(OtherX);
                              end;
                  SouthEast : begin
                                OtherY := Succ(OtherY);
                                OtherX := Pred(OtherX);
                              end;
                end;
              end;
          OtherX := ToAttemptX;
          OtherY := ToAttemptY;
          for Count := 1 to length(word) do
            begin
              Letters[OtherY, OtherX].Letter := Word[Count];
              case ToGoDir of
                North     : OtherY := Pred(OtherY);
                South     : OtherY := Succ(OtherY);
                West      : OtherX := Succ(OtherX);
                East      : OtherX := Pred(OtherX);
                NorthWest : begin
                              OtherY := Pred(OtherY);
                              OtherX := Succ(OtherX);
                            end;
                NorthEast : begin
                              OtherY := Pred(OtherY);
                              OtherX := Pred(OtherX);
                            end;
                SouthWest : begin
                              OtherY := Succ(OtherY);
                              OtherX := Succ(OtherX);
                            end;
                SouthEast : begin
                              OtherY := Succ(OtherY);
                              OtherX := Pred(OtherX);
                            end;
              end;
            end;
          WordDirection := ToGoDir;
          Xloc := ToAttemptX;
          Yloc := ToAttemptY;
          DoneWithWord := True;

     end;
     end;

    function PlaceWord : boolean;
      begin
        PlaceWord := True;
        if ToGoY < length(Words[WordIndex].Word) then
          begin
            ToGoY := ToGoY+(length(Words[WordIndex].Word)-ToGoY);
            ToAttemptY := ToGoY;
          end;
        if AttemptInsert then exit;
        repeat
          ToAttemptX := Succ(ToAttemptX);
          if AttemptInsert then exit;
        until ToAttemptX > 38;
        ToAttemptX := ToGoX;
        repeat
          ToAttemptX := Pred(ToAttemptX);
          if AttemptInsert then exit;
        until AttemptInsert or (ToAttemptX < 1);
        ToAttemptX := ToGoX;
        repeat
          ToAttemptY := Succ(ToAttemptY);
          if AttemptInsert then exit;
        until ToAttemptY > 11;
        ToAttemptY := ToGoY;
        repeat
          ToAttemptY := Pred(ToAttemptY);
          if AttemptInsert then exit;
        until ToAttemptY < 1;
        ToAttemptY := ToGoY;
        repeat
          ToAttemptX := Pred(ToAttemptX);
          ToAttemptY := Pred(ToAttemptY);
          if AttemptInsert then exit;
        until (ToAttemptX < 1) or (ToAttemptY < 1);
        ToAttemptX := ToGoX;
        ToAttemptY := ToGoY;
        repeat
          ToAttemptX := Succ(ToAttemptX);
          ToAttemptY := Pred(ToAttemptY);
          if AttemptInsert then exit;
        until (ToAttemptX > 38) or (ToAttemptY < 1);
        ToAttemptX := ToGoX;
        ToAttemptY := ToGoY;
        repeat
          ToAttemptX := Succ(ToAttemptX);
          ToAttemptY := Succ(ToAttemptY);
          if AttemptInsert then exit;
        until (ToAttemptX > 38) or (ToAttemptY > 11);
        ToAttemptX := ToGoX;
        ToAttemptY := ToGoY;
        repeat
          ToAttemptX := Pred(ToAttemptX);
          ToAttemptY := Pred(ToAttemptY);
          if AttemptInsert then exit;
        until (ToAttemptX < 1) or (ToAttemptY < 1);
        ToAttemptX := 0;
        ToAttemptY := 0;
        repeat
          ToAttemptY := Succ(ToAttemptY);
          repeat
            ToAttemptX := Succ(ToAttemptX);
            if AttemptInsert then exit;
          until (ToAttemptX > 38);
        until (ToAttemptY > 11);
        PlaceWord := False;
      end;
    var
      TriedNorth,
      TriedSouth,
      TriedWest,
      TriedEast,
      TriedNorthWest,
      TriedNorthEast,
      TriedSouthWest,
      TriedSouthEast : boolean;

    begin
      for WordIndex := 1 to TotalWords do
        with Words[WordIndex] do
          begin
            ToGoX := random(38);
            ToGoY := random(12);
            ToAttemptX := ToGoX;
            ToAttemptY := ToGoY;
            ToGoDir := CompassDirections(random(8));
            DoneWithWord := False;
            TriedNorth := False;
            TriedSouth := False;
            TriedWest := False;
            TriedEast := False;
            TriedNorthWest := False;
            TriedNorthEast := False;
            TriedSouthWest := False;
            TriedSouthEast := False;
            repeat
              case ToGoDir of
                North     : if not PlaceWord then TriedNorth := True;
                South     : if not PlaceWord then TriedSouth := True;
                West      : if not PlaceWord then TriedWest := True;
                East      : if not PlaceWord then TriedEast := True;
                NorthWest : if not PlaceWord then TriedNorthWest := True;
                NorthEast : if not PlaceWord then TriedNorthEast := True;
                SouthWest : if not PlaceWord then TriedSouthWest := True;
                SouthEast : if not PlaceWord then TriedSouthEast := True;
              end;
              if not DoneWithWord then
                if not TriedNorth then
                  ToGoDir := North
                else
                  if not TriedSouth then
                    ToGoDir := South
                  else
                    if not TriedWest then
                      ToGoDir := West
                    else
                      if not TriedEast then
                        ToGoDir := East
                      else
                        if not TriedNorthWest then
                          ToGoDir := NorthWest
                        else
                          if not TriedNorthEast then
                            ToGoDir := NorthEast
                          else
                            if not TriedSouthWest then
                              ToGoDir := SouthWest
                            else
                              if not TriedSouthEast then
                                ToGoDir := SouthEast
                              else
                                begin
                                  Error(', Unable to place word ,'+Word);
                                  DoneWithWord := True;
                                end;



            until DoneWithWord;
          end;

    end;

  procedure FixWordRecords;
    var
      Index,
      Count  : byte;
    begin
      Index := 0;
      repeat
        Index := Succ(Index);
        if Words[Index].Xloc = 255 then
          begin
            for Count := Index to TotalWords-1 do
              Words[Count] := Words[Count+1];
            TotalWords := Pred(TotalWords);
            WordsLeft := Pred(WordsLeft);
            Index := Pred(Index);
          end;
      until Index = TotalWords;
    end;


  procedure FillGridBlanks;
    var
      Row, Column : byte;
    begin
      for Row := RowMin to RowMax do
        for Column := ColumnMin to ColumnMax do
          if Letters[Row, Column].Letter = #1 then
            if CaseDesired then
              Letters[Row, Column].Letter := chr(random(26)+65)
            else
              Letters[Row, Column].Letter := chr(random(26)+97);
    end;

  var
    Ch : char;
  begin
    GetWords;
    if InsertWords then
      begin
        FixWordRecords;
        FillGridBlanks;
        Ready := True;
      end;
  end;

procedure LoadPuzzle;
  var
    FileName : string[12];
    Filevar : file;
    Path : string;
    RetCode : integer;
  begin
    clrscr;
    CursorOn;
    GetDir(0, Path);
    with DTTT do
      begin
        Colswide := 5;
        Rows := 8;
        AllowEsc := true;
        ShowDetails := false;
        DisplayInfo := false;
        AllowHelp := false;
        AllowToggle := false;
        AllowZoom := false;
        AllowCD := true;
        AllowInput := false;
      end;
    FileName := Display_Directory(Path+'\*.PUZ', RetCode);
    CursorOff;
    if (FileName <> #27) and (FileName <> '') then
      begin
        assign(filevar, filename);
        reset(filevar, 1);
        blockread(Filevar, Letters, sizeof(Letters));
        blockread(Filevar, Words, sizeof(Words));
        blockread(filevar, WordsLeft, sizeof(wordsleft));
        blockread(filevar, TotalWords, sizeof(TotalWords));
        close(filevar);
        Ready := True;
      end
  end;

procedure SavePuzzle;
  var
    FileName : string[12];
    Filevar : file;
  begin
    clrscr;
    CursorOn;
    FileName := GetFileName(NoExtension, SaveFile);
    CursorOff;
    FileName := FileName + '.PUZ';
    if exist(filename) then
      begin
        if Verified('File '''+Filename+''' already exists, ,Overwrite?') then
          begin
            assign(filevar, filename);
            rewrite(filevar, 1);
            blockwrite(Filevar, Letters, sizeof(Letters));
            blockwrite(Filevar, Words, sizeof(Words));
            blockwrite(filevar, WordsLeft, sizeof(wordsleft));
            blockwrite(filevar, TotalWords, sizeof(totalwords));
            close(filevar);
          end;
        end
    else
      begin
        assign(filevar, filename);
        {$I-} rewrite(filevar, 1); {$I+}
        if IOResult<>0 then
          begin
            Error('Error saving file., , Aborting save.');
            exit;
          end;
        blockwrite(Filevar, Letters, sizeof(Letters));
        blockwrite(Filevar, Words, sizeof(Words));
        blockwrite(filevar, WordsLeft, sizeof(wordsleft));
        blockwrite(filevar, TotalWords, sizeof(totalwords));
        close(filevar);
        end;
  end;



procedure PlayPuzzle;
  type
    Directions = (Up, Down, Left, Right, UpLeft, DownLeft, UpRight, DownRight, UnKnown);
  var
    Done,
    HighLighting,
    ReturntoMain : boolean;
    HighLightDir : Directions;
    HighLightX,
    HighLightY : byte;
    GridX,
    GridY : byte;
    Mistakes : byte;

  procedure FillGrid;
    var
      Row, Column : byte;
    begin
      for Row := RowMin to RowMax do
        for Column := ColumnMin to ColumnMax do
          begin
            gotoxy(Column*2, Row*2);
            if Letters[Row,Column].HighLighted then
              begin
                textcolor(HighForeC);
                textbackground(HighBackC)
              end
            else
              begin
                textcolor(NormForeC);
                textbackground(NormBackC);
              end;
            write(Letters[Row, Column].Letter);
          end;
    end;

  procedure ProcessKey(Ch : char);
    const
      Space = #32;
      Esc   = #27;
    var
      Index : byte;
    function Match(ThisWordRec : WordRec) : boolean;
      var
        Index : byte;
        EndX,
        EndY  : byte;
        TempBool : boolean;
      begin
        with ThisWordRec do
          begin
            if Word = '' then
              begin
                Match := False;
                exit;
              end;
            EndX := Xloc;
            EndY := Yloc;
            case WordDirection of
              North     : for Index := 1 to length(Word)-1 do
                            EndY := Pred(EndY);
              South     : for Index := 1 to length(Word)-1 do
                            EndY := Succ(EndY);
              East      : for Index := 1 to length(Word)-1 do
                            EndX := Pred(EndX);
              West      : for Index := 1 to length(Word)-1 do
                            EndX := Succ(EndX);
              NorthEast : for Index := 1 to length(Word)-1 do
                            begin
                              EndY := Pred(EndY);
                              EndX := Pred(EndX);
                            end;
              NorthWest : for Index := 1 to length(Word)-1 do
                            begin
                              EndY := Pred(EndY);
                              EndX := Succ(EndX);
                            end;
              SouthEast : for Index := 1 to length(Word)-1 do
                            begin
                              EndY := Succ(EndY);
                              EndX := Pred(EndX);
                            end;
              SouthWest : for Index := 1 to length(Word)-1 do
                            begin
                              EndY := Succ(EndY);
                              EndX := Succ(EndX);
                            end;
            end;
            TempBool := ( (GridX = Xloc) and (GridY = Yloc) and (HighLightX = EndX) and (HighLightY = EndY) );
            Match := ( (GridX = EndX) and (GridY = EndY) and (HighLightX = Xloc) and (HighLightY = Yloc) ) or TempBool;
          end;
        end;

    var
      Count : byte;
      Major, Minor : byte;
      WordList : array[1..MaxWords] of string[20];

    begin
      case Ch of
        Space : if not HighLighting then
                  begin
                    HighLighting := True;
                    HighLightX := GridX;
                    HighLightY := GridY;
                    HighLightDir := Unknown;
                  end
                else
                  begin
                    for Index := 1 to TotalWords do
                      if Match(Words[Index]) then
                        if Words[Index].Found then
                          begin
                            HighLighting := False;
                            gotoxy(HighLightX*2, HighLightY*2);
                            textcolor(HighForeC);
                            textbackground(HighBackC);
                            write(Letters[HighLightY, HighLightX].Letter);
                            DisplayWordNotesWindow;
                            writeln;
                            writeln(' You already found that word.');
                            pause;
                            RmSWindow(GenericSRWindow);
                            gotoxy(GridX*2, GridY*2);
                            textcolor(OnHighForeC);
                            textbackground(OnHighBackC);
                            write(Letters[GridY, GridX].Letter);
                            exit;
                          end
                        else
                          with Words[Index] do
                            begin
                              Found := True;
                              WordsLeft := Pred(WordsLeft);
                              HighLightX := Xloc;
                              HighLightY := Yloc;
                              for Count := 1 to length(Word) do
                                begin
                                  Letters[HighLightY, HighLightX].HighLighted := True;
                                  case WordDirection of
                                    North     : HighLightY := Pred(HighLightY);
                                    South     : HighLightY := Succ(HighLightY);
                                    East      : HighLightX := Pred(HighLightX);
                                    West      : HighLightX := Succ(HighLightX);
                                    NorthEast : begin
                                                  HighLightY := Pred(HighLightY);
                                                  HighLightX := Pred(HighLightX);
                                                end;
                                    NorthWest : begin
                                                  HighLightY := Pred(HighLightY);
                                                  HighLightX := Succ(HighLightX);
                                                end;
                                    SouthEast : begin
                                                  HighLightY := Succ(HighLightY);
                                                  HighLightX := Pred(HighLightX);
                                                end;
                                    SouthWest : begin
                                                  HighLightY := Succ(HighLightY);
                                                  HighLightX := Succ(HighLightX);
                                                end;
                                  end;
                                end;
                              DisplayWordNotesWindow;
                              if WordsLeft=0 then
                                begin
                                  writeln;
                                  writeln('  Congratulations!');
                                  writeln;
  writeln(' You have successfully found all ', TotalWords, ' words with only ', Mistakes, ' mistake.');
                                  halt;
                                end
                              else
                                begin
                                  writeln;
                                  writeln('  Good job!');
                                  writeln;
                                  writeln(' So far, you have found ', TotalWords-WordsLeft, ' out of ', TotalWords);
                                  Pause;
                                  RmSWindow(GenericSRWindow);
                                  FillGrid;
                                  gotoxy(GridX*2, GridY*2);
                                  textcolor(OnHighForeC);
                                  textbackground(OnHighBackC);
                                  write(Letters[GridY, GridX].Letter);
                                  HighLighting := False;
                                  exit;
                                end;
                              end
                       else
                         if Index = TotalWords then
                           begin
                             FillGrid;
                             DisplayWordNotesWindow;
                             writeln;
                             writeln('  That is not correct.');
                             writeln;
                             writeln(' You have ', WordsLeft, ' words left to find.');
                             Mistakes := Succ(Mistakes);
                             pause;
                             RmSWindow(GenericSRWindow);
                             gotoxy(GridX*2, GridY*2);
                               if Letters[GridY, GridX].HighLighted then
                                 begin
                                   textcolor(OnHighForeC);
                                   textbackground(OnHighBackC);
                                 end
                               else
                                 begin
                                  textcolor(HighForeC);
                                  textbackground(HighBackC);
                                end;
                             write(Letters[GridY, GridX].Letter);
                             HighLighting := False;
                           end;
                    end;
       Esc    : if Verified(', --- Return to DOS ---, , Are you sure?') then Halt;

       '/'    : begin
                  Major := 1;
                  Minor := 0;
                  Pull_Menu(GridMenu, Major, Minor);
                  CursorOff;
                  case Major of
                    1 : case Minor of
{                          1 : LoadPuzz;
                          2 : LoadGame;
}                          3 : SavePuzzle;
{                          4 : SaveGame;
                          5 : PrintPuzzle
}                         6 : ReturntoMain := true;
                          7 : halt(0);
                        end;
                    2 : begin
                          OptionsMenu.Topic[6] := 'Return to Puzzle';
                          ChangeOptions;
                          MakeGrid(1, 1, 80, 25, GridWanted, GridForeC, GridBackC);
                          FillGrid;
                        end;
                    3 : begin
                          Index := 1;
                          for Count := 1 to MaxWords do
                            if not(Words[Count].Found) then
                              begin
                                WordList[Index] := Words[Count].Word;
                                inc(Index);
                              end;
                          with LTTT do
                            begin
                              RightChar := ' ';
                              AllowToggle := false;
                            end;
                          Show_List(WordList,20,WordsLeft);
{                          case Minor of
                          1 : FirstLetHelp;
                          2 : DirectionHelp;
                          3 : AcrossHelp;
                          4 : DownHelp;}
                        end;
{                    4 : Statistics;
}                  end;
                end;

    end;
    end;



  procedure ProcessFuncKey(Ch : char);
    const
      UpArrow = #72;
      DownArrow = #80;
      RightArrow = #77;
      LeftArrow = #75;
      Home = #71;
      PgUp = #73;
      EndCode = #79;
      PgDn = #81;
      F1 = #59;
      AltC = #46;
    procedure ChangePosition(WaytoGo : Directions);
      begin
        case WaytoGo of
          Up : if not (GridY > RowMin) then exit;
          Down : if not (GridY < RowMax) then exit;
          Left : if not (GridX > ColumnMin) then exit;
          Right : if not (GridX < ColumnMax) then exit;
          UpLeft : if not ( (GridY > RowMin) and (GridX > ColumnMin) ) then exit;
          UpRight : if not ( (GridY > RowMin) and (GridX < ColumnMax) ) then exit;
          DownLeft : if not ( (GridY < RowMax) and (GridX > ColumnMin) ) then exit;
          DownRight : if not ( (GridY < RowMax) and (GridX < ColumnMax) ) then exit;
        end;
        if HighLighting then
          begin
            if HighLightDir = UnKnown then
              HighLightDir := WaytoGo;
            if HighLightDir = WaytoGo then
              begin
                case WaytoGo of
                  Up : GridY := Pred(GridY);
                  Down : GridY := Succ(GridY);
                  Left : GridX := Pred(GridX);
                  Right : GridX := Succ(GridX);
                  UpLeft : begin
                             GridY := Pred(GridY);
                             GridX := Pred(GridX);
                           end;
                  UpRight : begin
                              GridY := Pred(GridY);
                              GridX := Succ(GridX);
                            end;
                  DownLeft : begin
                               GridY := Succ(GridY);
                               GridX := Pred(GridX);
                             end;
                  DownRight : begin
                                GridY := Succ(GridY);
                                GridX := Succ(GridX);
                              end;
                end;
                textcolor(HighForeC);
                textbackground(HighBackC);
                gotoxy(GridX*2,GridY*2);
                write(Letters[GridY,GridX].Letter);
              end;
            end
          else
            begin
              gotoxy(GridX*2, GridY*2);
              if Letters[GridY, GridX].HighLighted then
                begin
                  textcolor(HighForeC);
                  textbackground(HighBackC);
                end
              else
                begin
                  textcolor(NormForeC);
                  textbackground(NormBackC);
                end;
              write(Letters[GridY, GridX].Letter);
              case WaytoGo of
                Up : GridY := Pred(GridY);
                Down : GridY := Succ(GridY);
                Left : GridX := Pred(GridX);
                Right : GridX := Succ(GridX);
                UpLeft : begin
                           GridY := Pred(GridY);
                           GridX := Pred(GridX);
                         end;
                UpRight : begin
                            GridY := Pred(GridY);
                            GridX := Succ(GridX);
                          end;
                DownLeft : begin
                             GridY := Succ(GridY);
                             GridX := Pred(GridX);
                           end;
                DownRight : begin
                              GridY := Succ(GridY);
                              GridX := Succ(GridX);
                            end;
              end;
              gotoxy(GridX*2, GridY*2);
              if Letters[GridY, GridX].HighLighted then
                begin
                  textcolor(OnHighForeC);
                  textbackground(OnHighBackC);
                end
              else
                begin
                  textcolor(HighForeC);
                  textbackground(HighBackC);
                end;
              write(Letters[GridY, GridX].Letter);
           end;
    end;

    var
      Index : byte;
      Count : byte;

    begin
      case Ch of
        UpArrow : ChangePosition(Up);
        DownArrow : ChangePosition(Down);
        LeftArrow : ChangePosition(Left);
        RightArrow : ChangePosition(Right);
        Home      : ChangePosition(UpLeft);
        PgUp      : ChangePosition(UpRight);
        PgDn      : ChangePosition(DownRight);
        EndCode     : ChangePosition(DownLeft);


        AltC : begin
                 DisplayHelpWindow;
                 writeln('------ Word ------ Xloc, Yloc, Dir, Found');
                 for Index := 1 to TotalWords do
                   with Words[Index] do
                     if Word <> '' then
                     begin
                       write(Word);
                       for Count := 1 to 20-(length(Word)) do
                         write(' ');
                       write(' ', Xloc, ',', Yloc, ',');
                       case WordDirection of
                         North : write ('N');
                         South : write('S');
                         West : write('W');
                         East : write('E');
                         NorthWest : write('NW');
                         NorthEast : write('NE');
                         SouthWest : write('SW');
                         SouthEast : write('SE');
                       end;
                       writeln(',', Found);
                     end;
                 writeln('TotalWords = ', TotalWords, ' -- WordsLeft = ', WordsLeft);
                 writeln('Mistakes = ', Mistakes);
                 Pause;
                 RmSWindow(GenericSRWindow);
               end;

       end;
  end;

var
  Choice : char;

  begin
    window(1,1,80,25);
    clrscr;
    MakeGrid(1, 1, 80, 25, GridWanted, GridForeC, GridBackC);
    FillGrid;
    Done := false;
    HighLighting := false;
    ReturntoMain := false;
    GridX := 19;
    GridY := 6;
    Mistakes := 0;
    gotoxy(GridX*2, GridY*2);
    textcolor(HighForeC);
    textbackground(HighBackC);
    write(Letters[GridY, GridX].Letter);
    repeat
      Choice := readkey;
      if Choice=#0 then
        ProcessFuncKey(readkey)
      else
        ProcessKey(Choice);
      if ReturntoMain then exit;
    until Done;
  end;


var
  Choice, Retcode : integer;
begin
  CursorOff;
  TitleScreen;
  Initilize;
  repeat
    clrscr;
    Choice := 1;
    FillScreen(1,1,80,25,White, Black, chr(177));
    DisplayMenu(MainMenu, false, Choice, Retcode);
      case Choice of
        1 : MakePuzzle;
        2 : LoadPuzzle;
        3 : ChangeOptions;
        4 : Halt;
      end;
    if Ready then
      PlayPuzzle;
    Initilize;
  until false;

end.