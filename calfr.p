program calendrier(input,output);
{ sur une idee originale de Fabre d'Eglantine,
 voici une realisation de Jean Forget,
un programme de conversion entre calendriers republicaine & gregorien
 version 2.1 du 08/12/1983 }
const
	diml=38;
	dimc=131;
	ltitre=5;
	lmois=8;
type
	tdate=record
		an:integer;
		mois:integer;
		jour:integer;
		end;
	ttab=array[1..diml,1..dimc] of char;
var
	action:integer;

function bissex(an:integer):integer;
{ rend 1 si l'annee est bissextile, et 0 sinon. }
begin
if an mod 400 = 0
then	bissex:=1
else	if an mod 100 = 0
	then	bissex:=0
	else	if an mod 4 = 0
		then	bissex:=1
		else	bissex:=0
end;

function equinoxe(annee:integer):integer;
{ cette fonction est provisoire. Elle donne le numero en septembre
de l'equinoxe d'automne, qui est le 1er vendemiaire. }
var
	n:integer;
begin
repeat
	writeln;
	write('En',annee,', l''equinoxe est tombe le ? ');
	read(n);
until (n>=22-bissex(annee)) and (n<=24);
equinoxe:=n
end;

function gregnum(date:tdate):integer;
{ donne le nombre de jours entre date et le 0 janvier de l'annee }
begin
case date.mois of
	1:gregnum:=date.jour;
	2:gregnum:=date.jour+31;
	3:gregnum:=date.jour+59+bissex(date.an);
	4:gregnum:=date.jour+90+bissex(date.an);
	5:gregnum:=date.jour+120+bissex(date.an);
	6:gregnum:=date.jour+151+bissex(date.an);
	7:gregnum:=date.jour+181+bissex(date.an);
	8:gregnum:=date.jour+212+bissex(date.an);
	9:gregnum:=date.jour+243+bissex(date.an);
	10:gregnum:=date.jour+273+bissex(date.an);
	11:gregnum:=date.jour+304+bissex(date.an);
	12:gregnum:=date.jour+334+bissex(date.an);
	end;
end;

function repnum(date:tdate):integer;
{ donne en fonction de date l'ecart avec le 0 vendemiaire. }
begin
repnum:=date.jour+30*(date.mois-1)
end;

procedure numgreg(n,annee:integer;var date:tdate);
{ convertit le nombre de jours depuis le 0 janvier en date. }
begin
date.an:=annee;
date.jour:=1;
date.mois:=12;
while gregnum(date)>n do
	date.mois:=date.mois-1;
date.jour:=n-gregnum(date)+1
end;

procedure numrep(n,annee:integer;var date:tdate);
{ donne la date en fonction de l'annee et du nombre de jours ecoules
depuis le 0 vendemiaire. }
begin
date.an:=annee;
date.mois:=(n-1) div 30 +1;
date.jour:=1+(n-1) mod 30
end;

procedure gregrep(dategreg:tdate;var daterep:tdate);
{ convertit dategreg en daterep. }
var
	numero,eq:integer;{ ecart entre date ou equinoxe, et le 0 janvier }
	dateeq:tdate;
begin
numero:=gregnum(dategreg);
dateeq.mois:=9;
if numero>=265 { 21/09 bissextile, ou 22/09 normal }
then	dateeq.an:=dategreg.an
else	begin
	dateeq.an:=dategreg.an-1;
	numero:=numero+365+bissex(dateeq.an)
	end;
dateeq.jour:=equinoxe(dateeq.an);
eq:=gregnum(dateeq);
if eq>numero
then	begin
	dateeq.an:=dateeq.an-1;
	dateeq.jour:=equinoxe(dateeq.an);
	eq:=gregnum(dateeq);
	numero:=numero+365+bissex(dateeq.an)
	end;
numrep(numero-eq+1,dateeq.an-1791,daterep)
end;

procedure repgreg(daterep:tdate;var dategreg:tdate);
var
	dateeq:tdate;
	annee,numero,eq:integer;
begin
numero:=repnum(daterep);
dateeq.an:=daterep.an+1791;
dateeq.mois:=9;
dateeq.jour:=equinoxe(dateeq.an);
eq:=gregnum(dateeq);
numero:=numero+eq-1;
if numero>365+bissex(dateeq.an)
then	begin
	annee:=daterep.an+1792;
	numero:=numero-365-bissex(dateeq.an);
	end
else	annee:=daterep.an+1791;
numgreg(numero,annee,dategreg);
end;

function joursem(date:tdate):integer;
var
	n,ans,siecle:integer;
begin
ans:=(date.an-1) mod 100;
siecle:=(date.an-1) div 100;
if (siecle>=17) and (siecle<=21)
then	case siecle of
		18:n:=-2;
		19:n:=-1;
		20,21:n:=0;
		end;
n:=n+ans+ans div 4;
joursem:=(n+gregnum(date)) mod 7;
end;

function veraffrep(date:tdate;onaffiche:boolean):boolean;
var
	ver:boolean;
begin
ver:=(date.mois>=1) and (date.mois<=13) and (date.jour>=1) and (date.jour<=30);
ver:=ver and ((date.mois<=12) or (date.jour<=6));
if ver and onaffiche
then	begin
	write(date.jour);
	case date.mois of
		1:write(' vendemiaire ');
		2:write(' brumaire ');
		3:write(' frimaire ');
		4:write(' nivose ');
		5:write(' pluviose ');
		6:write(' ventose ');
		7:write(' germinal ');
		8:write(' floreal ');
		9:write(' prairial ');
		10:write(' messidor ');
		11:write(' thermidor ');
		12:write(' fructidor ');
		13:write(' sans-culottide ');
		end;
	writeln(date.an);
	end;
veraffrep:=ver;
end;

function veraffgreg(date:tdate;onaffiche:boolean):boolean;
var
	ver:boolean;
begin
ver:=(date.mois>=1) and (date.mois<=12) and (date.jour>=1);
if  date.mois in [4,6,9,11]
then	ver:=ver and (date.jour<=30)
else	if date.mois=2
	then	ver:=ver and (date.jour<=28+bissex(date.an))
	else	ver:=ver and (date.jour<=31);
if ver and onaffiche
then	begin
	write(joursem(date));
	write(date.jour);
	case date.mois of
		1:write(' janvier ');
		2:write(' fevrier ');
		3:write(' mars ');
		4:write(' avril ');
		5:write(' mai ');
		6:write(' juin ');
		7:write(' juillet ');
		8:write(' aout ');
		9:write(' septembre ');
		10:write(' octobre ');
		11:write(' novembre ');
		12:write(' decembre ');
		end;
	writeln(date.an)
	end;
veraffgreg:=ver;
end;

function menu(demo:boolean):integer;
var
	n:integer;
begin
repeat
	writeln('0:fin');
	writeln('1:demonstration');
	writeln('2:conversion de republicain en gregorien');
	writeln('3:conversion de gregorien en republicain');
	if demo
	then	n:=1
	else	read(n)
until (n>=0) and (n<=3);
menu:=n;
end;

procedure demonstration;
begin
writeln;
writeln('		DEMONSTRATION');
writeln('{ Tout ce qui est entre accolades est un commentaire du programme');
writeln('de demonstration. Le menu s''affiche : }');
if menu(true)=20	then writeln;
writeln('{ Vous repondez : }');
writeln('	3');
writeln('{ On affiche alors }');
writeln('	Date (j m a) ?');
writeln('{ Vous repondez }');
writeln('	22 9 1983');
writeln('{ La date est correcte, il n''y a donc pas de message d''erreur');
writeln(' Le programme demande }');
writeln('	En 1983 l''equinoxe est tombe le ?');
writeln('{ Vous repondez }');
writeln('	23');
writeln('{ En effet l''equinoxe d''automne en 1983 etait le 23 septembre.');
writeln('Comme cet exemple est tordu,le programme redemande }');
writeln('	En 1982 l''equinoxe est tombe le ?');
writeln('{ Mais en general, il n''a besoin que de connaitre un seul equinoxe');
writeln('Vous repondez donc }');
writeln('	17');
writeln('{ ce qui constitue une aberration,');
writeln('etant donne que l''equinoxe d''automne tombe toujours entre le 22');
writeln('et le 24 septembre, sauf certaines annees bissextiles ou il tombe');
writeln('le 21 septembre. Le programme redemande donc }');
writeln('	En 1982 l''equinoxe est tombe le ?');
writeln('{ Vous repondez sans vous tromper }');
writeln('	23');
writeln('{ Le programme repond alors }');
writeln('	22 septembre 1982');
writeln('{ puis }');
writeln('	5 sans-culottide 191');
writeln('{ Les jours complementaires s''appelaient en effet sans-culottides');
writeln('Et revoila le menu. A vous de jouer ! }');
writeln;
end;

procedure convrepgreg;
var
	daterep,dategreg:tdate;
begin
writeln('Date (j m a) ');
readln(daterep.jour,daterep.mois,daterep.an);
if veraffrep(daterep,false)
then	begin
	repgreg(daterep,dategreg);
	if veraffrep(daterep,true) and veraffgreg(dategreg,true)
	then	writeln;
	end
else	writeln('La date est incorrecte');
end;

procedure convgregrep;
var
	dategreg,daterep:tdate;
begin
writeln('Date (j m a) ');
readln(dategreg.jour,dategreg.mois,dategreg.an);
if veraffgreg(dategreg,false)
then	begin
	gregrep(dategreg,daterep);
	if veraffgreg(dategreg,true) and veraffrep(daterep,true)
	then	writeln;
	end
else	writeln('La date est incorrecte');
end;

procedure inittab(var tab:ttab);
{initialise le tableau qui donnera le calendrier. }
var
	n,l,c:integer;
begin
for l:=2 to diml-1 do
	for c:=2 to dimc-1 do tab[l,c]:=' '
for c:=1 to dimc do
	begin
	tab[1,c]:='-';
	tab[4,c]:='-';
	tab[7,c]:='-';
	tab[diml,c]:='-';
	end;
tab[2,1]:='|';
tab[3,1]:='|';
tab[2,dimc]:='|';
tab[3,dimc]:='|'
for n:=0 to 11 do
	begin
	c:=n*10+1;
	tab[5,c]:='|';
	tab[6,c]:='|';
	for l:=lmois to diml-1 do tab[l,c]:='|';
	end;
for c:=0 to 11 do
	for l:=lmois to diml-1 do
		begin
		tab[l,10*c+5]:='(';
		tab[l,10*c+9]:=')'
		end;
end;
procedure affichage;
var
	tab:ttab;
	l,c:integer;
begin
inittab(tab);
for l:=1 to diml do
	begin
	writeln;
	for c:=1 to dimc do
		write(tab(c));
	end;
end;
begin
repeat
	action:=menu(false);
	if action>0
	then	case action of
			1:demonstration;
			2:convrepgreg;
			3:convgregrep;
			4:affichage;
			end;
until action=0
end.
