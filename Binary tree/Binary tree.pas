Program derevo;
Uses crt,dos,graph; {Podkcluchaem nebhodumue moduli dlia sozdania programi}
type
  valtype=char;
  tsign=(none,addition,substraction,multiplication,division,involution);
  pnode=^tnode;
  tnode=record
    l,r,next:pnode;
    val:valtype;
    sign:tsign; {esli sign zadan kak pole, to eto node - chislo, i hranitsia chislo v val}
  end;
Var s:string;
node:pnode;
spisok:array[1..7] of string;
kod,kodd:char;
n,p:byte;
i,j,k,Err:integer;
x:word;

function createvaluenode(val:valtype):pnode;
{Sozdat' node - operand. val - znachenue operanda}
var
  node:pnode;
begin
  new(node);
  node^.l:=nil;
  node^.r:=nil;
  node^.next:=nil;
  node^.sign:=none;
  node^.val:=val;
  createvaluenode:=node;
end;

function createsignnode(l,r:pnode;sign:char):pnode;
{Sozdat' node - znak. Parametru:
 l,r - levaui i pravui node
 Sign - Znak node v vide simvola  (*,/,+,-,^)}
var
  node:pnode;
begin
  new(node);
  node^.l:=l;
  node^.r:=r;
  node^.next:=nil;
  node^.val:=#0;
  case sign of
    '*': node^.sign:=multiplication;
    '/': node^.sign:=division;
    '+': node^.sign:=addition;
    '-': node^.sign:=substraction;
    '^': node^.sign:=involution;
  end;
  createsignnode:=node;
end;


function MakeTreeFromInfix(var s:string):pnode;
{Sozdaet derevo iz infiksnoe stroki "s"
 Vse node uporiadochenu v lineinuy sistemu pri pomochi svoistva next u kazdogo node
 Funkcia vozvrachaet ukazatel na koren dereva (korennoi node)}
var
  p,o,i,j:byte;
  valch:byte;
  s2,s3:string;
  node,ln,rn:pnode;
  root:pnode;
  function tostr(v:integer):string;
  var s:string; {Preobrazovat chislo v stroku}
  begin
    str(v,s);
    tostr:=s;
  end;
  function toval(s:string):word;
  var v,c:word; {Preobrazovat stroku v chislo}
  begin
    val(s,v,c);
    ToVal:=v;
  end;
  function nodebycount(root:pnode;number:word):pnode;
  var {Vichislit' poriadkovui nomer node}
    p:word;
    a:pnode;
  begin
    a:=root;
    for p:=1 to number-1 do a:=a^.next;
    nodebycount:=a;
  end;
begin
  s:='('+s+')';
  {Zamenim vse peremennue stroki na node}
  root:=nil;
  valch:=0;
  s2:='';
  for p:=1 to length(s) do
  begin
    if upcase(s[p]) in ['A'..'Z'] then
    begin
      inc(valch);
      if root=nil then
      begin
	root:=createvaluenode(s[p]);
	node:=root;
      end else
      begin
	node^.next:=createvaluenode(s[p]);
	node:=node^.next;
      end;
      s2:=s2+tostr(valch); {Zanesem nodu v stroku}
    end else if s[p]<>' ' then s2:=s2+s[p]; {Ubiraem probelu}
  end;
  s:=s2; {Sohraniaem stroku s node}
  s2:='';
  {Vudeliaem stroku v skobkah}
  for p:=1 to length(s) do if s[p]=')' then
  begin
    {Ischem nachalo vurazenia v skobkah}
    for o:=length(s2) downto 1 do if s2[o]='(' then break;
    {Analiziruem chlenu mnogochlena}
    s3:=copy(s2,o+1,255);
    s2:=copy(s2,1,o-1);
    {Nahodim vozvedenue v stepen}
    o:=1;
    repeat
      if s3[o] in ['^'] then
      begin
	inc(valch);
	i:=1;
	while(o>1+i)and(s3[o-1-i] in ['0'..'9']) do inc(i);
	ln:=nodebycount(root,toval(copy(s3,o-i,i))); {Node sleva ot '^'}
	j:=1;
	while(o+j<length(s3))and(s3[o+1+j] in ['0'..'9'])do inc(j);
	rn:=nodebycount(root,toval(copy(s3,o+1,j))); {Noda sprava ot '^'}
	node^.next:=createsignnode(ln,rn,s3[o]);
	node:=node^.next;
	dec(o,i);
	delete(s3,o,i+j+1);
	insert(tostr(valch),s3,o);
      end;
      inc(o);
    until o>length(s3);
    {Nahodim umnozenue i delenue}
    o:=1;
    repeat
      if s3[o] in ['*','/'] then
      begin
	inc(valch);
	i:=1;
	while(o>1+i)and(s3[o-1-i] in ['0'..'9']) do inc(i);
	ln:=nodebycount(root,toval(copy(s3,o-i,i))); {Node sleva ot '*' ili '/'}
	j:=1;
	while(o+j<length(s3))and(s3[o+1+j] in ['0'..'9'])do inc(j);
	rn:=nodebycount(root,toval(copy(s3,o+1,j))); {Noda sprava ot '*' ili '/'}
	node^.next:=createsignnode(ln,rn,s3[o]);
	node:=node^.next;
	dec(o,i);
	delete(s3,o,i+j+1);
	insert(tostr(valch),s3,o);
      end;
      inc(o);
    until o>length(s3);
    {Nahodim slozenue i vichitanue}
    o:=1;
    repeat
      if s3[o] in ['+','-'] then
      begin
	inc(valch);
	i:=1;
	while(o>1+i)and(s3[o-1-i] in ['0'..'9']) do inc(i);
	ln:=nodebycount(root,toval(copy(s3,o-i,i))); {Node sleva ot '+' ili '-'}
	j:=1;
	while(o+j<length(s3))and(s3[o+1+j] in ['0'..'9'])do inc(j);
	rn:=nodebycount(root,toval(copy(s3,o+1,j))); {Noda sprava ot '+' ili '-'}
	node^.next:=createsignnode(ln,rn,s3[o]);
	node:=node^.next;
	dec(o,i);
	delete(s3,o,i+j+1);
	insert(tostr(valch),s3,o);
      end;
      inc(o);
    until o>length(s3);
    s2:=s2+s3;
  end else s2:=s2+s[p];
  MakeTreeFromInfix:=nodebycount(root,valch);
end;


function makePostfix(node:pnode):string;
{Konvertacia v postfiksnuy stroku}
begin
  case node^.sign of
    multiplication: makepostfix:=makepostfix(node^.l)+makepostfix(node^.r)+'*';
    division: makepostfix:=makepostfix(node^.l)+makepostfix(node^.r)+'/';
    addition: makepostfix:=makepostfix(node^.l)+makepostfix(node^.r)+'+';
    substraction: makepostfix:=makepostfix(node^.l)+makepostfix(node^.r)+'-';
    involution: makepostfix:=makepostfix(node^.l)+makepostfix(node^.r)+'^';
    none: makepostfix:=node^.val;
  end;
end;

function makePrefix(node:pnode):string;
{Konvertaia v prefiksnuy}
begin
  case node^.sign of
    multiplication: makePrefix:='*'+makePrefix(node^.l)+makePrefix(node^.r);
    division: makePrefix:='/'+makePrefix(node^.l)+makePrefix(node^.r);
    addition: makePrefix:='+'+makePrefix(node^.l)+makePrefix(node^.r);
    substraction: makePrefix:='-'+makePrefix(node^.l)+makePrefix(node^.r);
    involution:  makePrefix:='^'+makePrefix(node^.l)+makePrefix(node^.r);
    none: makePrefix:=node^.val;
  end;
end;

function makeInfix(node:pnode):string;
{Konvertecia v infiksnuy stroku}
var s:string;
begin
  case node^.sign of
    involution:
    begin
      if(node^.l^.sign<>Addition)and(node^.l^.sign<>Substraction)then
	s:=makeInfix(node^.l) else s:='('+makeInfix(node^.l)+')';
      s:=s+'^';
      if(node^.r^.sign<>Addition)and(node^.r^.sign<>Substraction)then
	s:=s+makeInfix(node^.r) else s:=s+'('+makeInfix(node^.r)+')';
      makeInfix:=s;
    end;
    multiplication:
    begin
      if(node^.l^.sign<>Addition)and(node^.l^.sign<>Substraction)then
	s:=makeInfix(node^.l) else s:='('+makeInfix(node^.l)+')';
      s:=s+'*';
      if(node^.r^.sign<>Addition)and(node^.r^.sign<>Substraction)then
	s:=s+makeInfix(node^.r) else s:=s+'('+makeInfix(node^.r)+')';
      makeInfix:=s;
    end;
    division:
    begin
      if(node^.l^.sign<>Addition)and(node^.l^.sign<>Substraction)then
	s:=makeInfix(node^.l) else s:='('+makeInfix(node^.l)+')';
      s:=s+'/';
      if(node^.r^.sign<>Addition)and(node^.r^.sign<>Substraction)then
	s:=s+makeInfix(node^.r) else s:=s+'('+makeInfix(node^.r)+')';
      makeInfix:=s;
    end;
    addition: makeInfix:=makeInfix(node^.l)+'+'+makeInfix(node^.r);
    substraction: makeInfix:=makeInfix(node^.l)+'-'+makeInfix(node^.r);
    none: makeInfix:=node^.val;
  end;
end;

procedure DeleteTree(node:pnode);
{Udalenue dereva i ochistka pamiatu}
begin
if not(node=nil) then
begin
  if node^.sign<>none then
  begin
    deletetree(node^.l);
    deletetree(node^.r);
  end else
  begin
    dispose(node);
    node:=nil;
  end;
end else exit;
end;


Procedure Curs(size:word);
{Redaktirovanie razmera cursora}
Var Regs:registers;
Begin
   With regs do
    begin
     AH:=$01;
     CH:=Hi(size);
     CL:=Lo(size);
     Intr($10,regs)
    end;
end;


Procedure Vvod;
{Vvod ishodnogo matematicheskogo vurazenia}
Var a:boolean;
i:integer;
begin
Textbackground(0);
clrscr;
a:=true;
Repeat
Writeln('Vvedite ishodnoe matematicheskoe virazenue');
Readln(S);
If (not (upcase(s[1]) in ['A'..'Z','('])) or (not (s[ord(s[0])] in ['A'..'Z']+['a'..'z',')'])) then begin
writeln ('Vvedeno nekorrektnoe vurazenue');
a:=false; continue;
end else a:=true;
For i:=1 to length(s) do
if not (upcase(s[i]) in (['A'..'Z']+['+','-','*','/','^','(',')'])) then begin
writeln ('Vvedeno nekorrektnoe vurazenue');
a:=false; break; end;
if a=false then continue;
For i:=1 to length(s)-1 do
if (((upcase(s[i])) in ['A'..'Z']) and ((upcase(s[i+1])) in ['A'..'Z'])) or
(((upcase(s[i])) in ['+','-','*','/','^']) and ((upcase(s[i+1])) in ['+','-','*','/','^'])) then begin
writeln ('Vvedeno nekorrektnoe vurazenue');
a:=false; break; end;
until a=true;
end;

Procedure uzel(node:pnode;a,b:integer);
Var z:string;
{Risovanie uzla dereva}
 begin
  case node^.sign of
  multiplication: z:='*';
  division: z:='/';
  addition: z:='+';
  substraction: z:='-';
  involution: z:='^';
  none: z:=node^.val;
  end;
 setcolor(1);
 setfillstyle(1,1);
 circle(a,b,10);
 outtextXY(a,b-2,z);
 end;

Procedure Fon(node:pnode);
{Procedura vhoda v graficheskui rezim}
begin
i:=detect;
 initgraph(i,j,'');
 Err:=GraphResult;
 If Err<>grOK then  Writeln(GraphErrorMsg(Err))
 else
 begin
 setcolor(1);
 setfillstyle(1,3);
 floodfill(1,1,i);
 settextstyle(1,0,2);
 settextjustify(1,1);
 Outtextxy(round(getmaxx/2),10,'Binarnoe derevo');
 end;
settextstyle(1,0,1);
 Uzel(node,round(getmaxX/2),60);
end;

Procedure tree(node:pnode;x,y,l:integer);
{Procedura risovania dereva v graficheskom rezime}
begin
setcolor(1);
l := l div 2 +(l div 15);
if node^.l<>nil then begin line(x-10, y, x-l, y);  line(x-l, y, x - l, y +l-10); Uzel(node^.l,x-l,y+l);
tree(node^.l,x-l,y+l,l);
tree(node^.r,x+l,y+l,l);
end;
if node^.r<>nil then begin line(x+10, y, x+l, y); line(x+l, y, x +l, y +l-10); Uzel(node^.r,x+l,y+l);
tree(node^.l,x-l,y+l,l);
tree(node^.r,x+l,y+l,l);
end;

end;


Procedure  Zapis;
{Procedura zapisi obhodov dereva v fail}
Var
a:string;
F2:text;
begin

Assign(F2,'rezultat.txt');
Rewrite(F2);
if not(node=nil) then
begin
a:='Rezultat simmetrichnogo obhoda='+MakeInfix(node);
Writeln(F2,a);
a:='Rezultat priamogo obhoda='+MakePrefix(node);
Writeln(F2,a);
a:='Rezultat obratnogo obhoda='+MakePostfix(node);
Writeln(F2,a);
Write('Zapis proshla uspeshno');
end else begin write('Dvoichnoe derevo ne sozdano');  end;
readkey;
Close(F2);
end;


Procedure findd(n:byte);
{Procedura chtenua vibrannogo punkta v menu programmu}
Begin
 textMode(3);
 Window(1,1,80,25);
 TextBackGround(0);
 Textcolor(7);
 ClrScr;
 case n of
   1: begin Vvod; node:=maketreefrominfix(s); end;
   2: begin 
if node=nil then begin Writeln('Vurazenue ne vvedeno'); readkey; exit; end; 
Fon(node); tree(node,round(getmaxX/2),60,250); readkey; closegraph; end;
   3: begin 
if node=nil then begin Writeln('Vurazenue ne vvedeno'); readkey; exit; end; 
Writeln('Rezultat simmetrichnogo obhoda=',MakeInfix(node)); readkey; end;
   4: begin 
if node=nil then begin Writeln('Vurazenue ne vvedeno'); readkey; exit; end; 
Writeln('Rezultat priamogo obhoda=',MakePrefix(node)); readkey; end;
   5: begin 
if node=nil then begin Writeln('Vurazenue ne vvedeno'); readkey; exit; end; 
Writeln('Rezultat obratnogo obhoda=',MakePostfix(node)); readkey; end;
   6: begin Zapis end;
   7: begin exit end;
 end;
 Curs($0607);
 end;


Procedure oformenu;
{Procedura oformlenia menu}
Begin
clrscr;
Textbackground(7);
clrscr;
Textcolor(1);
Highvideo;
Writeln('    Osnovnoe menu:');
writeln;
Lowvideo;
Curs($2000);
Spisok[1]:='1. Vvod ishodnogo matematicheskogo vurazenia s klaviaturi i sozdanie dereva';
Spisok[2]:='2. Vivod dvoichnogo dereva na ekran';
Spisok[3]:='3. Simmetruchmiu obhod i vivod poluchennogo vurazenuia na ekran';
Spisok[4]:='4. Priamoi obhod i vivod poluchennogo vurazenuia na ekran';
Spisok[5]:='5. Obratnui obhod i vivod poluchennogo vurazenuia na ekran';
Spisok[6]:='6. Zapis rezultatov obhoda v fail';
Spisok[7]:='7. Exit';
p:=1;
i:=1;
Repeat
 if i=n Then
	  begin
	   TextBackGround(blue);
	   TextColor(LightGray);
	  end
	else
	  begin
	   TextBackGround(LightGray);
	   TextColor(blue);
	  end;

GotoXY(3,i+1);
Writeln(spisok[i]);
inc(i);
inc(p);
until p>7;
 kod:=Readkey;
 CASE kod of
 #13: begin  if n=7 then exit;  findd(n); oformenu; end;
 #0: begin  kodd:=Readkey; Case kodd of
			   #72: if n>1 then dec(n)
				       else n:=7;
			   #80: if n<7 then inc(n)
				       else n:=1;
			   end;
     oformenu;
     end
 else oformenu
  end;
  end;


{Telo osnovnoi programmi}
begin
n:=1;
oformenu;
Deletetree(node);
end.












