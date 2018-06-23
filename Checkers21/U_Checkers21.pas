unit U_Checkers21;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  extctrls, Grids,StdCtrls, shellAPI;

type

  TStatus=(Normal,Removed,King);
  TMoveStatus=(NoMove, CanMove,Canjump);


  TPiece= class(TShape)
   public
    playerid:char;
    loc:TPoint;
    status:TStatus; {Normal, King, Removed}
    {MoveStatus на каждую шашку зависит от каждого хода}
    movestatus:TMoveStatus;  {Nomove, CanMove, Canjump}
    constructor create(aowner:Twincontrol; newplayerid:char;
                       newsize:TPoint);    reintroduce;
  end;

  TMoverec = record
    index:integer;
    movefrom:TPoint;
    Moveto:TPoint;
    prevstatus:TStatus;
    jumpedpiece:integer;
    jumpedlocM:TPoint;
    jumpedstatus:TStatus;
  end;

  TForm1 = class(TForm)
    StaticText1: TStaticText;
    ResetBtn: TButton;
    Turnlbl: TLabel;
    MustJumpLbl: TLabel;
    Label1: TLabel;
    ScoreLbl1: TLabel;
    ScoreLbl2: TLabel;
    Panel1: TPanel;
    Memo1: TMemo;
    UndoLbl: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure UndoLblClick(Sender: TObject);
    procedure MustJumpLblClick(Sender: TObject);
  public
    panelsize:TPoint;
    offsetx,offsety:integer;
    boardcolor:TColor;
    piece:array of TPiece;
    Board:TStringgrid;

    WhoseTurn:char;    {Чей ход, 1-го или 2-го}
    Mustjump:boolean;  {Определяет должен ли игрок есть шашку}
    Gameover:boolean; {Определяет закончилась ли игра}
    piecestaken:array['1'..'2'] of integer; {Счет между игроками}

    Moves:array [1..100] of TMoverec;
    nbrmoves:integer;

    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
                           Rect: TRect; State: TGridDrawState); {Рисует доску}

    {Настроить шашку для перетаскивания}
    procedure pieceStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    {Перетаскивание шашки на доске}
    procedure boardDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure boardDragDrop(Sender, Source: TObject; X, Y: Integer);

    {Переменные и процедуры}
    procedure setpieceloc(n,c,r:integer);
    procedure movepiece(n,c,r:integer);
    function IsvalidLoc(loc:TPoint):boolean;
    function IsNormalMove(n:integer; loc1,loc2:TPoint):boolean;
    function Isjumpmove(n:integer; loc1,loc2:TPoint; var jumpedloc:TPoint):boolean;

    {Проверка, можно ли так ходить}
    function validmove(from,too:TPoint):boolean;

    procedure setpossiblemoves; {Проверка всех возможных ходов}
    procedure UndoMove;        {Ход назад}
  end;

var
  Form1: TForm1;

implementation
 {Включить в модуль файл визуального дизайна формы}
{$R *.DFM}

var
  {Параметры доски}
  boardsize:TPoint=(x:8;y:8);
  nbrpieces:integer=24;
  color1:TColor=clSilver;
  color2:TColor=clDkgray;
  piececolor:array['1'..'2'] of TColor=(clred, clblack);
  colorname:array['1'..'2'] of string=('Красные', 'Черные');
  FirstTurnPlayer:char ='2';

{************* FormActivate *********}
procedure TForm1.FormActivate(Sender: TObject);
var
  i:integer;
begin
  boardcolor:=clsilver;

  {Сделать доску - TStringgrid, то есть как таблицу }
  Board:=TStringGrid.create(self);
  with Board do
  begin
    colcount:=boardsize.x;
    rowcount:=boardsize.y;
    scrollbars:=ssnone;

    offsetx:=(self.width-(memo1.left+memo1.width)) div 10;
    offsety:=(statictext1.top) div 10;
    if offsetx>offsety then offsetx:=offsety;
    offsety:=offsetx;

    left:=memo1.left+memo1.width+offsetx; {Перемещение по ширине панели, чтобы начать}
    width:=boardsize.x*offsetx+3;
    top:=offsety;
    height:=boardsize.y*offsety+3;
    panelsize.x:=width div boardsize.x -1;
    panelsize.y:=height div boardsize.y -1;
    parent:=self;
    fixedcols:=0;
    fixedrows:=0;
    DefaultColwidth:=panelsize.x;
    DefaultRowheight:=panelsize.y;
    color:=clwhite;
    scrollbars:=ssnone;
    defaultdrawing:=false;
    OnDrawCell:=StringGridDrawCell;
    OnDragOver:=boardDragOver;
    OndragDrop:=boardDragDrop;
  end;
  setlength(piece,nbrpieces);
  for i:=0 to high(piece) div 2 do
  begin
    piece[i]:=TPiece.create(Board,'1',Point(panelsize.x-6,panelsize.y-6));
    piece[i].onstartdrag:=PiecestartDrag;
  end;
  for i:=nbrpieces div 2 to high(piece) do
  begin
    piece[i]:=TPiece.create(Board,'2',point(panelsize.x-6,panelsize.y-6));
    piece[i].onstartdrag:=PiecestartDrag;
  end;
  ResetBtnclick(sender);
end;

{**************** Tpiece.Create ****************}
constructor Tpiece.create(aowner:TWincontrol; newplayerid:char; newsize:TPoint);
begin
  inherited create(aowner);
  parent:=aowner;
  playerid:=newplayerid;
  loc:=point(0,0);
  shape:=stCircle;
  left:=0;
  top:=0;
  width:=newsize.x;
  height:=newsize.y;
  dragmode:=dmAutomatic;
  status:=Normal;
  visible:=true;
  brush.color:=piececolor[playerId];
end;



    {************* PieceStartDrag ***********}
    procedure TForm1.pieceStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    {Настроить шашку для перетаскивания - пока ничего}
    begin

    end;

    {***************** BoardDragOver ***************}
    procedure TForm1.boardDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
      {Сделать Accept:true если шашка может стоять здесь}
    var
      c,r:integer;
    begin
      accept:=false;

      if source is tpiece then
      with TPiece(source) do
      begin
        if playerid<>whoseturn then exit;
        Board.mousetocell(x,y,c,r);
        if validmove(loc,point(c,r)) then accept:=true
        else accept:=false;
      end;
    end;

    {************* BoardDragDrop************}
    procedure TForm1.boardDragDrop(Sender, Source: TObject; X, Y: Integer);
    {Двинуть шашку на текущее местоположение}
    var
      n,c,r:integer;
    begin
      if source is tpiece then
      with TPiece(source) do
      begin
        Board.mousetocell(x,y,c,r);
        n:=strtoint(Board.cells[loc.x,loc.y]);
        movepiece(n,c,r);
      end;
    end;

{**************** StringgridDrawCell **************}
procedure TForm1.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
{Рисовать квадратики доски}
begin

  with Sender as TStringGrid, canvas  do
  begin
    if (acol + arow) mod 2 =0
    then brush.color:=color1
    else brush.color:=color2;
    pen.color:=clBlack;
    FillRect(Rect);
  end;
end;

{**************** ResetBtnClick **********}
procedure TForm1.ResetBtnClick(Sender: TObject);
var i,c,r:integer;
begin
  {Очистить доску}
  with Board do
  for c:=0 to boardsize.x-1 do
  for r:= 0 to boardsize.y-1 do  cells[c,r]:='-1';
  {Восстановить шашки}
  for i:=0 to high(piece) do
  with piece[i] do
  begin
    {Вычислить столбцы и строки}
    r:=2*i div boardsize.x;
    c:=(((2*i)+(r+1) mod 2)) mod boardsize.x;
    if i>high(piece) div 2 then r:=r+boardsize.y div 2 -2; {Пропустите 2 ряда, чтобы поместить черные шашки внизу доски}
    setpieceloc(i,c,r);
    status:=normal;
    visible:=true;
    shape:=stCircle;
  end;
  piecestaken['1']:=0;
  piecestaken['2']:=0;
  WhoseTurn:=FirstTurnPlayer;
  Turnlbl.font.color:=piececolor[whoseturn];
  Turnlbl.caption:=colorname[whoseturn]+' moves';
  MustJumplbl.caption:='';
  setpossiblemoves;
  nbrmoves:=0;
end;

{********** IsValidLoc ************}
function Tform1.IsvalidLoc(loc:TPoint):boolean;
{Возвращает значение true, если переданное местоположение указывает на квадрат на доске}
begin
  with Board do
  if (loc.x>=0) and (loc.x<=boardsize.x-1)
  and (loc.y>=0) and (loc.y<=boardsize.y-1)
  then result:=true
  else result:=false;
end;


{************ IsNormalMove **********}
function  TForm1.IsNormalMove(n:integer; loc1,loc2:TPoint):boolean;
{Учитывая количество шашек, и «from» и «tо» местоположении, проверить, не
  является ли действительным ходом, если это так, вернуть true.
  Действительно, если позиции «from» и «tо» действительны, по диагонали смежны в
     направление, в котором этот кусок может перемещаться, а позиция «to» пуста
 }
 var
   piecenbr:integer;
 begin
  //memo1.lines.add(format('(%d,%d) --> (%d,%d)',[loc1.x, loc1.y,loc2.x,loc2.y]));
  result:=false;
  if (not Isvalidloc(loc1)) or (not Isvalidloc(loc2)) then exit;
  if (abs(loc1.x-loc2.x)<>1) and (abs(loc1.y-loc2.y)<>1) then exit;
  if Board.cells[loc2.x,loc2.y]<>'-1' then exit;
  piecenbr:=n;
  if piecenbr>=0 then
  with piece[piecenbr] do
  begin
    {Шашка движется вниз по доске}
    if (playerid='1') or (status=king) then
    begin
      if ((loc2.x=loc1.x-1) and (loc2.y=loc1.y+1))
       or ((loc2.x=loc1.x+1) and (loc2.y=loc1.y+1))
       then result:=true
    end;
    {Шашка движется вверх по доске}
    if (not result) and ((playerid = '2') or (status=king))then
    begin
      if   ((loc2.x=loc1.x-1) and (loc2.y=loc1.y-1))
        or ((loc2.x=loc1.x+1) and (loc2.y=loc1.y-1))
      then result:=true;
    end;
  end;
end;

{***************** IsJumpMove ************}
function TForm1.Isjumpmove(n:integer;loc1,loc2:TPoint; var jumpedloc:TPoint):boolean;
{При задании числа шашек и местоположении «от» и «до» проверьте, не
  является ли действительным прыжком, если это так, возвращать значение true и положение «jumped» шашки.
  Действителен, если действительны «от» и «до» местоположения, диагональ над одной ячейкой в
  направление, в котором эта шашка может перемещаться, местоположение пустое, а
  перепрыгнутая клетка содержит шашку оппонента}

var OK:boolean;
    piecenbr,piecenbr2:integer;
begin
  OK:=false;
  result:=false;
  if (not isvalidloc(loc1)) or (not isvalidloc(loc2)) then exit;
  if  Board.cells[loc2.x,loc2.y]<>'-1' then exit;
  piecenbr:=n;

  if piecenbr>=0 then
  with piece[piecenbr] do
  begin
    if (playerid='1') or (status=king) then
    begin
      with loc1 do if isvalidloc(point(x-1,y+1)) then
      begin
        piecenbr2:=strtoint(Board.cells[loc1.x-1,loc1.y+1]);
        {Если занятый противоположным цветом и следующий квадрат пуст, тогда можно прыгать}
        if (loc2.x=loc1.x-2) and (loc2.y=loc1.y+2)
           and (piecenbr2>=0) and (piece[piecenbr2].playerid<>playerid)
        then
        begin
          OK:=true;
          with loc1 do jumpedloc:=point(x-1,y+1)
        end;
      end;
      if not ok then   {Шашка движется вверх и направо}
      with loc1 do if isvalidloc(point(x+1,y+1)) then
      begin
        piecenbr2:=strtoint(Board.cells[loc1.x+1,loc1.y+1]);
        if (loc2.x=loc1.x+2) and (loc2.y=loc1.y+2)
          and (piecenbr2>=0) and (piece[piecenbr2].playerid<>playerid)
        then
        begin
          OK:=true;
          with loc1 do jumpedloc:=point(x+1,y+1)
        end;
      end;
    end;
    {Проверка возможности прыжка вниз и влево}
    if (not OK) and ((playerid = '2') or (status=king))then
    begin
      with loc1 do if isvalidloc(point(x-1,y-1)) then
      begin  {Шашка движется вниз и влево}
        piecenbr2:=strtoint(Board.cells[loc1.x-1,loc1.y-1]);
        if (loc2.x=loc1.x-2) and (loc2.y=loc1.y-2)
          and (piecenbr2>=0) and (piece[piecenbr2].playerid<>playerid)
        then
        begin
          OK:=true;
          with loc1 do jumpedloc:=point(x-1,y-1)
        end;
      end;
      if not OK then
      with loc1 do if isvalidloc(point(x+1,y-1)) then
      begin
        piecenbr2:=strtoint(Board.cells[loc1.x+1,loc1.y-1]);
        if (loc2.x=loc1.x+2) and (loc2.y=loc1.y-2)
          and (piecenbr2>=0) and (piece[piecenbr2].playerid<>playerid)
        then
        begin
          OK:=true;
          with loc1 do jumpedloc:=point(x+1,y-1)
        end;
      end;
    end;
  end;
  result:=OK;
end;

{************* SetpossibleMoves *********}
procedure TForm1.setpossiblemoves;
{Сканировать все перемещения и обновлять MoveStatus шашек}
var
  i:integer;
  moveloc:TPoint;
begin
  mustjump:=false;
  Gameover:=true;
  mustjumplbl.caption:='';
  for i:= 0 to nbrpieces-1 do
  with piece[i] do
  begin
    movestatus:=nomove;
    if playerid=whoseturn then
    begin  {Проверить 4 квадрата на которые можно передвинуться}
           {IsJumpMove проверит, что местоположение действительно, направление перемещения действительно и т. Д.}
      if   (Isjumpmove(i,loc,point(loc.x-2,loc.y+2),moveloc))
        or (Isjumpmove(i,loc,point(loc.x+2,loc.y+2), moveloc))
        or (Isjumpmove(i,loc,point(loc.x-2,loc.y-2),moveloc))
        or (Isjumpmove(i,loc,point(loc.x+2,loc.y-2), moveloc))
      then
      begin
           {Процедура высвечивания надписи "ЕШЬ", то есть обязан перепрыгнуть шашку опонента}
        movestatus:=Canjump;
        mustjump:=true;
        mustjumplbl.font.color:=piececolor[whoseturn];
        mustjumplbl.caption:='ЕШЬ!';
        gameover:=false;
      end;

      if movestatus=noMove then
      begin  {Проверка на нормальные движения вверх или вниз,
      IsNormalMove проверит, что направление действительно с учетом других вещей}
        if (IsNormalmove(i,loc,point(loc.x-1,loc.y+1)))
        or (IsNormalMove(i,loc,point(loc.x+1,loc.y+1)))
        or (IsNormalMove(i,loc,point(loc.x-1,loc.y-1)))
        or (IsNormalMove(i,loc,point(loc.x+1,loc.y-1)))
        then
        begin
          movestatus:=CanMove;
          gameover:=false;
        end;
      end;
    end;
  end;
end;

{**************** MovePiece *************}
 procedure TForm1.movepiece(n,c,r:integer);
 {Проверяем делается ли на самом деле перемещение шашки}
 var
   oldloc,jumpedloc:TPoint;
   piecenbr:integer;
   jumped:boolean;
 begin
   with piece[n] do
   begin
     oldloc:=loc;
     inc(nbrmoves);
     with Moves[nbrmoves] do
     begin
       index:=n;
       Movefrom:=oldloc;
       Moveto:=point(c,r);
     end;
     Board.cells[oldloc.x,oldloc.y]:='-1';
     jumped:=Isjumpmove(n,oldloc,point(c,r),jumpedloc);
     if jumped
     then with jumpedloc do
     begin {Перепрыгнул - убрать старые шашки}
       piecenbr:=strtoint(Board.cells[x,y]);
       with moves[nbrmoves] do
       begin
         jumpedlocM:=jumpedloc;
         jumpedpiece:=piecenbr;
         jumpedstatus:=piece[piecenbr].status;
       end;
       with piece[piecenbr] do
       begin
         status:=Removed;
         visible:=false; {Убрать с поля зрения}
         Board.cells[x,y]:='-1';
         loc:=point(-1,-1);
       end;
       inc(piecestaken[playerid]);

       scorelbl1.caption:=colorname['1'] + ': ' + inttostr(piecestaken['1']);
       scorelbl2.caption:=colorname['2'] + ': ' + inttostr(piecestaken['2']);
       if piecestaken[playerid]=12 then
       begin
         mustjumplbl.caption:='';
         showmessage('У нас есть победитель!!!' +#13
                  +'Поздравляем '+ colorname[playerid]);
         exit;
       end;
     end;

     setpieceloc(n,c,r);
     with oldloc do Board.cells[x,y]:='-1';
     if ((playerid='1') and (loc.y=boardsize.y-1))
        or ((playerid='2') and (loc.y=0))
     then
     begin
       status:=king;
       shape:=stRoundSquare;
     end;

     setpossiblemoves; {Проверка, есть ли еще одно условие "mustjump" перед изменением "whoseturn"}
     If gameover or
     (not jumped) or (jumped and (piece[n].movestatus<>canjump))
     then
     begin {Ходы недоступны или не многократный прыжок, поэтому изменяем "whoseturn"}
       case whoseturn of
         '1': whoseturn:='2';
         '2': whoseturn:='1';
       end;
       turnlbl.font.color:=piececolor[whoseturn];
       Turnlbl.caption:=colorname[whoseturn]+' ходят';
       setpossiblemoves;
       if gameover then
       begin

         showmessage('У нас есть победитель!!!' +#13
                  +'Поздравляем '+ colorname[playerid]);
         exit;
       end;
     end;
   end;
 end;

 procedure TForm1.MustJumpLblClick(Sender: TObject);
begin

end;

{**************** SetPieceLoc *************}
 procedure TForm1.setpieceloc(n,c,r:integer);
 {Устанавливаем местоположение шашки "n" ,столбец "c" и ряд "r"}
 var rect:TRect;
 begin
   with piece[n] do
   begin
     loc:=point(c,r);
     rect:=Board.cellrect(c,r);
     left:=rect.left+3;
     top:=rect.top+3;
     Board.cells[c,r]:=inttostr(n); {Расположить # в клетку}
   end;
 end;


 {*************** ValidMove **************}
 function TForm1.validmove(from,too:TPoint):boolean;
 {Возвращает true, если шашка в позиции «from» может переместиться или перейти к позиции «to»}
 var i:integer;
     moveloc:TPoint;
 begin
   result:=false;
   if isvalidloc(from) then i:=strtoint(Board.cells[from.x,from.y])
   else exit;
   if (IsNormalmove(i,from,too))
   then
   begin
     if (not mustjump) then result:=true;
     exit;
   end;
   if (Isjumpmove(i,from,too,moveloc))
   then result:=true;
 end;

procedure TForm1.undoMove;
begin
  if nbrmoves>0 then
  with moves[nbrmoves] do
  begin
    {Восстановить съеденную шашку (если была съедена)}
    if jumpedpiece>0 then
    begin
      with piece[jumpedpiece] do
      begin
        visible:=true;
        setpieceloc(jumpedpiece,jumpedlocM.x, jumpedlocM.y);
        status:= jumpedstatus;
        board.cells[jumpedlocM.x, jumpedlocM.y]:=inttostr(jumpedpiece);
      end;
      dec(piecestaken[piece[index].playerid]);
      scorelbl1.caption:=colorname['1'] + ': ' + inttostr(piecestaken['1']);
      scorelbl2.caption:=colorname['2'] + ': ' + inttostr(piecestaken['2']);
    end;
    {Возвращать шашку на место откуда она пришла}
    with piece[index] do
    begin
      setpieceloc(index,Movefrom.x, movefrom.y);
      status:=prevstatus;
      board.cells[Moveto.x, Moveto.y]:='-1';
      board.cells[Movefrom.x, Movefrom.y]:=inttostr(index);
      whoseturn:=playerid;
      Turnlbl.font.color:=piececolor[whoseturn];
      Turnlbl.caption:=colorname[whoseturn]+' ходят';
    end;
    dec(nbrmoves);
    setpossiblemoves;
  end;

end;

{************* FormKeyPress ***************}
procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if uppercase(key)='U' then undoMove;
end;


{*********** UndoLblClick ************8}
procedure TForm1.UndoLblClick(Sender: TObject);
begin
  Undomove;
end;


procedure TForm1.StaticText1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://vk.com/dkenzhebek',
                    nil, nil, SW_SHOWNORMAL) ;
end;




end.
