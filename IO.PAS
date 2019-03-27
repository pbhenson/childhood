Unit IO;

interface

uses Crt, QkWndws;

const
  WithExtension = True;
  NoExtension   = False;
  LoadFile = True;
  SaveFile = False;

function GetYesNo : boolean;
function GetString(MaxLength : integer) : string;
function GetByte : byte;
function GetFileName(Extension, Operation : boolean) : string;
function ColorStr(Color : byte) : string;
procedure Pause;
function GetChar(Low, High : char) : char;
function exist(filename : string) : boolean;
function GetParsedString(MaxLength : integer; BadChars : string) : string;
function BorderStr(Border : integer) : string;
function FixQuotes(Str : string) : string;
function Verified(Message : string) : boolean;
procedure Error(Message : string);

implementation


  function GetYesNo : boolean;
    var
      ch : char;
        begin
          repeat
            ch := upcase(readkey);
          until ch in ['Y','N'];
          if ch = 'Y' then
            begin
              writeln('Yes');
              GetYesNo := true;
           end
         else
           begin
             writeln('No');
             GetYesNo := False;
           end;
      end;

  function GetString(MaxLength : integer) : string;
    const
      BS = #8;
      CR = #13;
      Space = #32;
      Tilde = '~';
      Null = #0;
      Esc = #27;
    var
      ch : char;
      Done : boolean;
      Str : string;
    begin
      Str := '';
      Done := False;
      repeat
        begin
          ch := readkey;
          case ch of
            Space..Tilde : begin
                         if Length(Str) < MaxLength then
                           begin
                             Str := Str + ch;
                             write(ch);
                           end;
                       end;
            CR      : Done := True;
            BS      : begin
                        if Length(Str) > 0 then
                          begin
                            delete(Str, Length(Str), 1);
                            write(BS, Space, BS);
                          end;
                      end;
            Esc     : begin
                        Str := '';
                        Done := True;
                      end;
            Null    : ch := readkey;
           end;
        end;
      until Done;
      GetString := Str;
    end;

  function GetFileName(Extension, Operation : boolean) : string;
    const
      BS = #8;
      CR = #13;
      Space = #32;
      Null = #0;
      Esc = #27;
    Const
      GetFileNameWindow : SRWindRec = (
                           Attribs   : (
                                        BrdFgAttr : Magenta;
                                        BrdBgAttr : Blue;
                                        TxtFgAttr : LightGray;
                                        TxtBgAttr : Black
                                       );
                        BorderWanted : SidSingleLine;
                           Borders   : (
                                        UpLeftCorn    : 'Õ';
                                        UpRightCorn   : '¸';
                                        DnLeftCorn    : 'Ô';
                                        DnRightCorn   : '¾';
                                        HorizBar      : 'Í';
                                        VertBar       : '³';
                                        LeftTitleBar  : 'µ';
                                        RightTitleBar : 'Æ';
                                        BrdAttr       : 0
                                       );
                            Location : (
                                        Ux : 24;
                                        Uy : 10;
                                        Lx : 54;
                                        Ly : 12
                                       )
                          );


    var
      Done : boolean;
      TempStr : string[13];
      Ch : char;
      Index : integer;
    begin
      MkSRWindow(GetFileNameWindow);
      if Operation then
        writeln('       --- Load File ---')
      else
        writeln('       --- Save File ---');
      writeln;
      write(' Enter filename: ');
      done := false;
      Index := 1;
      TempStr := '';
      repeat
        ch := upcase(readkey);
        case ch of
          'A'..'Z', '0'..'9' : case Index of
                                 1..8 :  begin
                                           write(ch);
                                           TempStr := TempStr + ch;
                                           Index := Succ(Index);
                                         end;
                                 9    :  if extension then
                                           begin
                                             write('.',ch);
                                             TempStr := TempStr + '.' + ch;
                                             Index := 11;
                                           end;
                               11..12 :  begin
                                           write(ch);
                                           TempStr := TempStr + ch;
                                           Index := Succ(Index);
                                         end;
                               end;
          BS                 : case Index of
                                 2..9, 12..13 : begin
                                                  Index := Pred(Index);
                                                  delete(TempStr, Index, 1);
                                                  write(BS, Space, BS);
                                                end;
                                 11           : begin
                                                  delete(TempStr, Index-2, 2);
                                                  Index := 9;
                                                  write(BS, BS, Space, Space, BS, BS);
                                                end;
                              end;
         CR                 : begin
                                if TempStr = '' then TempStr := ' ';
                                Done := True;
                              end;
         Esc                : begin
                                TempStr := ' ';
                                Done := True;
                              end;
         Null               : ch := readkey;

       end;
     until Done;
   GetFileName := TempStr;
   RmSWindow(GetFileNameWindow);
 end;

  function ColorStr(color : byte) : string;
    begin
      case Color of
        Black        : ColorStr := 'Black';
        Blue         : ColorStr := 'Blue';
        Green        : ColorStr := 'Green';
        Cyan         : ColorStr := 'Cyan';
        Red          : ColorStr := 'Red';
        Magenta      : ColorStr := 'Magenta';
        Brown        : ColorStr := 'Brown';
        LightGray    : ColorStr := 'LightGray';
        DarkGray     : ColorStr := 'DarkGray';
        LightBlue    : ColorStr := 'LightBlue';
        LightGreen   : ColorStr := 'LightGreen';
        LightCyan    : ColorStr := 'LightCyan';
        LightRed     : ColorStr := 'LightRed';
        LightMagenta : ColorStr := 'LightMagenta';
        Yellow       : ColorStr := 'Yellow';
        White        : ColorStr := 'White';
        else ColorStr := '';
      end;
    end;

  procedure Pause;
    var
      TempChar : char;
    begin
      repeat until keypressed;
      TempChar := readkey;
    end;

function GetChar(Low, High : char) : char;
  var
    TmpChar : Char;
  begin
    repeat
      TmpChar := ReadKey;
    until TmpChar in [low..high];
    GetChar := TmpChar;
  end;

function Exist(filename : string) : boolean;
  var
    ThisFile : file;
  begin
    assign(thisfile, filename);
    {$I-} reset(thisfile);
          close(thisfile); {$I+}
    Exist := IOResult = 0;
  end;

  function GetParsedString(MaxLength : integer; BadChars : string) : string;
    const
      BS = #8;
      CR = #13;
      Space = #32;
      Tilde = '~';
      Null = #0;
      Esc = #27;
    var
      ch : char;
      Str : string;
      Done : boolean;
    begin
      Done := False;
      Str := '';
      repeat
        begin
          ch := readkey;
          case ch of
            Space..Tilde : begin
                             if pos(ch, BadChars)<>0 then
                               else
                                 if Length(Str) < MaxLength then
                                   begin
                                     Str := Str + ch;
                                     write(ch);
                                   end;
                          end;
            CR      : begin
                        Done := True;
                        if Length(Str)=0 then Str := ' ';
                      end;
            BS      : begin
                        if Length(Str) > 0 then
                          begin
                            delete(Str, Length(Str), 1);
                            write(BS, Space, BS);
                          end;
                      end;
            Esc     : begin
                        Str := ' ';
                        Done := True;
                      end;
            Null    : ch := readkey;
           end;
        end;
      until Done;
      GetParsedString := Str;
    end;

  function BorderStr(Border : integer) : string;
    begin
      case border of
       -1 : BorderStr := 'UserBorder';
        0 : BorderStr := 'NoBorder';
        1 : BorderStr := 'AllSingleLine';
        2 : BorderStr := 'AllDoubleLine';
        3 : BorderStr := 'TopSingleLine';
        4 : BorderStr := 'SidSingleLine';
        5 : BorderStr := 'GraphType1';
        6 : BorderStr := 'GraphType2';
        7 : BorderStr := 'GraphType3';
        8 : BorderStr := 'GraphType4';
      end;
    end;

function FixQuotes(Str : string) : string;
  var
    Posit : byte;
    TempStr : string;
  begin
    Posit := 0;
    TempStr := '';
    repeat
      Posit := Pos('''', Str);
        if Posit > 0 then
          begin
            TempStr := TempStr + copy(Str, 1, Posit);
            TempStr := TempStr + '''';
            Delete(Str, 1, Posit);
          end
        else TempStr := TempStr + Str;
    until Posit = 0;
  FixQuotes := TempStr;
  end;

  function GetByte : byte;
    const
      Nul = #0;
      Esc = #27;
      CR = #13;
      BS = #8;
    var
      Ch : char;
      TempStr : string[3];
      TempInt : integer;
    begin
      TempStr := '';
      repeat
        Ch := readkey;
        case Ch of
          Nul      : Ch := Readkey;
          Esc      : begin
                       GetByte := 0;
                       exit;
                     end;
          '0'      : if (length(TempStr) > 0) and (length(TempStr) < 3) then
                       begin
                         TempStr := TempStr + '0';
                         write('0');
                       end;
          '1'..'9' : if length(TempStr)<3 then
                       begin
                         TempStr := TempStr + Ch;
                         write(Ch);
                       end;
          BS       : if length(TempStr)>0 then
                       begin
                         delete(TempStr, length(TempStr),1);
                         write(BS, ' ', BS);
                       end;
          CR       : begin
                       val(TempStr, TempInt, TempInt);
                       if TempInt<257 then
                         begin
                           GetByte := Byte(TempInt);
                           exit;
                         end
                       else
                         for TempInt := 1 to length(TempStr) do
                           write(BS,' ');
                         TempStr := '';
                    end;
      end;
    until false;
  end;

  function Verified(Message : string) : boolean;
    type
      LineArray = array[1..6] of string[28];
    var
      GenericSRWindow : SRWindRec;
      Lines : LineArray;
      Ch : char;
    procedure DisplayVerifyWindow;
      begin
        with GenericSRWindow do
          begin
            with attribs do
              begin
              BrdFgAttr := Magenta;
              BrdBgAttr := Black;
              TxtFgAttr := LightGray;
              TxtBgAttr := Blue;
            end;
          BorderWanted := SidSingleLine;
          with Location do
            begin
              Ux := 26;
              Uy := 7;
              Lx := 53;
              Ly := 12;
            end;
        end;
        MkSRWindow(GenericSRWindow);
      end;

    procedure FixandWriteLines;
      var
        Index : byte;
        CurrentLine : byte;
        Count : byte;
      begin
        for Index := 1 to 6 do
          Lines[Index] := '';
        CurrentLine := 1;
        repeat
          Index := pos(',', Message);
          if Index <> 0 then
            begin
              Lines[CurrentLine] := Lines[CurrentLine] + copy(Message, 1, Index-1);
              delete(Message, 1, Index);
              if pos(',', Message) = 1 then
                begin
                  Lines[CurrentLine] := Lines[CurrentLine] + ',';
                  delete(Message, 1, 1);
                  CurrentLine := Pred(CurrentLine);
                end;
              CurrentLine := Succ(CurrentLine);
            end;
        until (Index = 0) or (CurrentLine = 7);
        if CurrentLine=1 then
            Lines[CurrentLine] := Message
        else
          if CurrentLine < 6 then
            Lines[CurrentLine] := Message;
        for Index := 1 to 6 do
          if length(Lines[Index])<28 then
            begin
              CurrentLine := 28 - length(Lines[Index]);
              for Count := 1 to (CurrentLine div 2) do
                insert(' ', Lines[Index], 1);
            end;
        for Index := 1 to 6 do
          begin
            gotoxy(1, Index);
            write(Lines[Index]);
          end;
      end;
    begin
      DisplayVerifyWindow;
      FixAndWriteLines;
      repeat
        Ch := upcase(readkey);
      until Ch in ['Y', 'N'];
      Verified := (Ch = 'Y');
      RmSWindow(GenericSRWindow);
    end;

  procedure Error(Message : string);
    type
      LineArray = array[1..6] of string[28];
    var
      GenericSRWindow : SRWindRec;
      Lines : LineArray;
      Ch : char;
    procedure DisplayErrorWindow;
      begin
        with GenericSRWindow do
          begin
            with attribs do
              begin
              BrdFgAttr := Magenta;
              BrdBgAttr := Black;
              TxtFgAttr := LightGray;
              TxtBgAttr := Blue;
            end;
          BorderWanted := SidSingleLine;
          with Location do
            begin
              Ux := 26;
              Uy := 7;
              Lx := 53;
              Ly := 12;
            end;
        end;
        MkSRWindow(GenericSRWindow);
      end;

    procedure FixandWriteLines;
      var
        Index : byte;
        CurrentLine : byte;
        Count : byte;
      begin
        for Index := 1 to 6 do
          Lines[Index] := '';
        CurrentLine := 1;
        repeat
          Index := pos(',', Message);
          if Index <> 0 then
            begin
              Lines[CurrentLine] := Lines[CurrentLine] + copy(Message, 1, Index-1);
              delete(Message, 1, Index);
              if pos(',', Message) = 1 then
                begin
                  Lines[CurrentLine] := Lines[CurrentLine] + ',';
                  delete(Message, 1, 1);
                  CurrentLine := Pred(CurrentLine);
                end;
              CurrentLine := Succ(CurrentLine);
            end;
        until (Index = 0) or (CurrentLine = 7);
        if CurrentLine=1 then
            Lines[CurrentLine] := Message
        else
          if CurrentLine < 6 then
            Lines[CurrentLine] := Message;
          if CurrentLine < 5 then
            Lines[6] := '--- Press any key ---';
        for Index := 1 to 6 do
          if length(Lines[Index])<28 then
            begin
              CurrentLine := 28 - length(Lines[Index]);
              for Count := 1 to (CurrentLine div 2) do
                insert(' ', Lines[Index], 1);
            end;
        for Index := 1 to 6 do
          begin
            gotoxy(1, Index);
            write(Lines[Index]);
          end;
      end;
    begin
      DisplayErrorWindow;
      FixAndWriteLines;
      Pause;
    end;


end.