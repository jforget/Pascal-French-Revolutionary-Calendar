{ -*- encoding: utf-8; indent-tabs-mode: nil -*- }
program calendrier(input,output);
{ Sur une idée originale de Fabre d'Églantine,
 voici une réalisation de Jean Forget,
un programme de conversion entre calendriers républicain & grégorien
Program to convert Gregorian dates into French Revolutionary dates or the other way.
Copyright (C) 1983, 1984, 2018 Jean Forget

Ce programme est distribué sous les mêmes termes que Perl 5.16.3 :
Licence publique GPL version 1 ou ultérieure et Licence Artistique Perl.

This program is distributed under the same terms as Perl 5.16.3:
GNU Public License version 1 or later and Perl Artistic License

Vous pouvez trouver le texte des licences en anglais dans le fichier LICENSE 
ou aux adresses http://www.perlfoundation.org/artistic_license_1_0
et http://www.gnu.org/licenses/gpl-1.0.html.

You can find the text of the licenses in the LICENSE file or at
http://www.perlfoundation.org/artistic_license_1_0
and http://www.gnu.org/licenses/gpl-1.0.html.

Voici le résumé de la GPL (en anglais) :

Here is the summary of GPL:

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., http://www.fsf.org/.
}

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
	alpha6=array[1..6] of char;
	alpha18=packed array[1..18] of char;
var
	action:integer;

procedure convalpha(n:integer;var ch:alpha6);
{ conversion d'un nombre entier à 6 chiffres en chaîne alphanumérique (ou 5 chiffres si négatif) }
var
	i:integer;
	negatif:boolean;
begin
for i:=1 to 6 do
	ch[i]:=' ';
i:=6;
if n<0
then	begin
	negatif:=true;
	n:=-n;
	end
else	negatif:=false;
repeat
	ch[i]:=chr(ord('0')+n mod 10);
	n:=n div 10;
	i:=i-1
until n=0;
if negatif
then	ch[i]:='-';
end;

function bissex(an:integer):integer;
{ rend 1 si l'année est bissextile, et 0 sinon. }
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
begin
case annee mod 4 of
	0:	begin
		equinoxe:=22;
		if (annee=2092) or (annee=2096)
		then	equinoxe:=21;
		if ((annee>=1800) and (annee<=1836))
			or ((annee>=1900) and (annee<=1964))
		then	equinoxe:=23;
		end;
	1:	begin
		if annee<=1993
		then	equinoxe:=23
		else	equinoxe:=22;
		if (annee<=1797) or ((annee>=1873) and (annee<=1897))
		then	equinoxe:=22;
		if (annee>=2101) and (annee<=2121)
		then	equinoxe:=23;
		end;
	2:	begin
		equinoxe:=23;
		if (annee<=1798) or ((annee>=2030) and (annee<=2098))
			or (annee>=2154)
		then	equinoxe:=22;
		end;
	3:	begin
		equinoxe:=23;
		if (annee=1803) or ((annee>=1903) and (annee<=1931))
		then	equinoxe:=24;
		if ((annee>=2059) and (annee<=2099)) or (annee>=2187)
		then	equinoxe:=22;
		end;
	end;
end;

function gregnum(date:tdate):integer;
{ donne le nombre de jours entre date et le 0 janvier de l'année }
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
{ donne en fonction de date l'écart avec le 0 vendémiaire. }
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
{ donne la date en fonction de l'année et du nombre de jours écoulés
depuis le 0 vendémiaire. }
begin
date.an:=annee;
date.mois:=(n-1) div 30 +1;
date.jour:=1+(n-1) mod 30
end;

procedure gregrep(dategreg:tdate;var daterep:tdate);
{ convertit dategreg en daterep. }
var
	numero,eq:integer;{ écart entre date ou équinoxe, et le 0 janvier }
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
siecle:=1+(date.an-1) div 100;
if (siecle>=18) and (siecle<=22)
then	case siecle of
                18: n := 4;
                19: n := 2;
                20: n := 0;
                21: n := 6;
                22: n := 4;
                end;
n:=n+ans+ans div 4;
joursem:=(n+gregnum(date)) mod 7;
end;

function verifrep(date:tdate):boolean;
var
	ver:boolean;
begin
ver:=(date.mois>=1) and (date.mois<=13) and (date.jour>=1) and (date.jour<=30);
ver := ver and ((date.mois <= 12) or (date.jour <= 6));
verifrep:=ver and (date.an >= 0) and (date.an <= 407);
end;

function verifgreg(date:tdate):boolean;
var
	ver:boolean;
begin
ver:=(date.mois>=1) and (date.mois<=12) and (date.jour>=1);
ver := ver and (date.an >= 1792) and (date.an <= 2199);
if  date.mois in [4,6,9,11]
then	verifgreg:=ver and (date.jour<=30)
else	if date.mois=2
	then	verifgreg:=ver and (date.jour<=28+bissex(date.an))
	else	verifgreg:=ver and (date.jour<=31);
end;

procedure affrep(date:tdate);
begin
write(date.jour:2);
case date.mois of
        1:write(' vendémiaire ');
	2:write(' brumaire ');
	3:write(' frimaire ');
        4:write(' nivôse ');
        5:write(' pluviôse ');
        6:write(' ventôse ');
	7:write(' germinal ');
        8:write(' floréal ');
	9:write(' prairial ');
	10:write(' messidor ');
	11:write(' thermidor ');
	12:write(' fructidor ');
	13:write(' sans-culottide ');
	end;
writeln(date.an:3);
end;

procedure affgreg(date:tdate);
begin
case joursem(date) of
	0:write('lundi ');
	1:write('mardi ');
	2:write('mercredi ');
	3:write('jeudi ');
	4:write('vendredi ');
	5:write('samedi ');
	6:write('dimanche ');
	end;
write(date.jour:2);
case date.mois of
	1:write(' janvier ');
        2:write(' février ');
	3:write(' mars ');
	4:write(' avril ');
	5:write(' mai ');
	6:write(' juin ');
	7:write(' juillet ');
        8:write(' août ');
	9:write(' septembre ');
	10:write(' octobre ');
	11:write(' novembre ');
        12:write(' décembre ');
	end;
writeln(date.an:4)
end;

function menu(demo:boolean):integer;
var
	n:integer;
begin
repeat
	writeln('0:fin');
        writeln('1:démonstration');
        writeln('2:conversion de républicain en grégorien');
        writeln('3:conversion de grégorien en républicain');
        writeln('4:affichage du calendrier pour une année entière');
	if demo
	then	n:=1
	else	read(n)
until (n>=0) and (n<=4);
menu:=n;
end;

procedure demonstration;
begin
writeln;
writeln('               DÉMONSTRATION');
writeln('{ Tout ce qui est entre accolades est un commentaire du programme');
writeln('de démonstration. Le menu s''affiche : }');
if menu(true)=20	then writeln;
writeln('{ Vous répondez : }');
writeln('	3');
writeln('{ On affiche alors }');
writeln('	Date (j m a) ?');
writeln('{ Vous répondez }');
writeln('	22 9 1983');
writeln('{ La date est correcte, il n''y a donc pas de message d''erreur');
writeln('Le programme répond alors }');
writeln('       jeudi 22 septembre 1983');
writeln('{ puis }');
writeln('	5 sans-culottide 191');
writeln('{ Les jours complémentaires s''appelaient en effet sans-culottides');
writeln('de nouveau, voici le menu : }');
if menu(true)=20 then writeln;
writeln('{ Vous répondez : }');
writeln('	4');
writeln('{ Le programme demande }');
writeln('       année ?');
writeln('{ Vous répondez par l''année de votre choix, puis,');
writeln('avant de presser retour-chariot, vous vous placez au');
writeln('début de la feuille suivante.');
writeln('Et revoilà le menu. À vous de jouer ! }');
writeln;
end;

procedure convrepgreg;
var
	daterep,dategreg:tdate;
begin
write('Date (j m a) ');
readln(daterep.jour,daterep.mois,daterep.an);
if verifrep(daterep)
then	begin
	repgreg(daterep,dategreg);
	affrep(daterep);
	affgreg(dategreg);
	end
else	writeln('La date est incorrecte');
end;

procedure convgregrep;
var
	dategreg,daterep:tdate;
begin
write('Date (j m a) ');
readln(dategreg.jour,dategreg.mois,dategreg.an);
if verifgreg(dategreg)
then	begin
	gregrep(dategreg,daterep);
	affgreg(dategreg);
	affrep(daterep);
	end
else	writeln('La date est incorrecte');
end;

procedure inittab(var tab:ttab);
{initialise le tableau qui donnera le calendrier. }
var
	n,l,c:integer;
	ch:alpha6;
begin
for l:=2 to diml-1 do
	for c:=2 to dimc-1 do tab[l,c]:=' ';
for c:=1 to dimc do
	begin
	tab[1,c]:='-';
	tab[ltitre-1,c]:='-';
	tab[lmois-1,c]:='-';
	tab[diml,c]:='-';
	end;
tab[2,1]:='|';
tab[3,1]:='|';
tab[2,dimc]:='|';
tab[3,dimc]:='|';
for n:=0 to 13 do
	begin
	c:=n*10+1;
	tab[5,c]:='|';
	tab[6,c]:='|';
	for l:=lmois to diml-1 do tab[l,c]:='|';
	end;
for n:=0 to 11 do
	for l:=lmois to diml-1 do
		begin
		tab[l,10*n+5]:='(';
		tab[l,10*n+9]:=')'
		end;
for l:=1 to 30 do
	begin
	convalpha(l,ch);
	for n:=0 to 11 do
		begin
		tab[l+lmois-1,10*n+3]:=ch[5];
		tab[l+lmois-1,10*n+4]:=ch[6];
		end;
	end;
end;

procedure affichage(tab:ttab);
var
	l,c:integer;
begin
for l:=1 to diml do
	begin
	writeln;
	for c:=1 to dimc do
		write(tab[l,c]);
	end;
end;

procedure remplmois(n,long:integer;nom:alpha18;
			var tab:ttab;var njour,sjour:integer);
{ remplit la colonne correspondant au n-ième mois. }
var
	l,c:integer;
	ch:alpha6;
begin
for c:=1 to 9 do
	begin
	tab[ltitre,10*n-9+c]:=nom[c];
	tab[ltitre+1,10*n-9+c]:=nom[c+9];
	end;
if n=13
then	l:=lmois+11
else	l:=lmois-1;
repeat
	convalpha(njour,ch);
	case sjour of
		0:ch[4]:='L';
		1:ch[4]:='M';
		2:ch[4]:='M';
		3:ch[4]:='J';
		4:ch[4]:='V';
		5:ch[4]:='S';
		6:ch[4]:='D';
		end;
	l:=l+1;
	tab[l,n*10-4]:=ch[4];
	tab[l,n*10-3]:=ch[5];
	tab[l,n*10-2]:=ch[6];
	if njour=long
	then	njour:=1
	else	njour:=njour+1;
	if sjour=6
	then	sjour:=0
	else	sjour:=sjour+1;
	if n=13
	then	begin
		tab[l,124]:=chr(ord('0')+l-lmois-11);
		tab[l,125]:='(';
		tab[l,129]:=')';
		end;
until (l=lmois+29) or ((n=13) and (njour=long));
end;

procedure calend;
{ construit le tableau de caracteres qui donnera le calendrier. }
var
	cal:ttab;
	i,annee,debut,fin,sem:integer;
	eq:tdate;
	ch:alpha6;
begin
write('année ? (n''oubliez pas de positionner le papier en début de page) ');
readln(annee);
debut:=equinoxe(annee);
fin:=equinoxe(annee+1);
inittab(cal);
eq.an:=annee;
eq.mois:=9;
eq.jour:=debut;
sem:=joursem(eq);
remplmois(1,30,'VENDEMIAI SEP-OCT ',cal,debut,sem);
remplmois(2,31,'BRUMAIRE  OCT-NOV ',cal,debut,sem);
remplmois(3,30,'FRIMAIRE  NOV-DEC ',cal,debut,sem);
remplmois(4,31,' NIVOSE	  DEC-JAN ',cal,debut,sem);
remplmois(5,31,'PLUVIOSE  JAN-FEV ',cal,debut,sem);
remplmois(6,28+bissex(annee+1),' VENTOSE  FEV-MAR ',cal,debut,sem);
remplmois(7,31,'GERMINAL  MAR-AVR ',cal,debut,sem);
remplmois(8,30,' FLOREAL  AVR-MAI ',cal,debut,sem);
remplmois(9,31,'PRAIRIAL  MAI-JUN ',cal,debut,sem);
remplmois(10,30,'MESSIDOR  JUN-JUL ',cal,debut,sem);
remplmois(11,31,'THERMIDOR JUL-AOU ',cal,debut,sem);
remplmois(12,31,'FRUCTIDOR AOU-SEP ',cal,debut,sem);
remplmois(13,fin,'SS-CULOTT   SEP   ',cal,debut,sem);
cal[3,65]:='-';
cal[3,66]:='-';
cal[3,67]:='-';
convalpha(annee,ch);
for i:=1 to 4 do
	cal[3,60+i]:=ch[2+i];
convalpha(annee+1,ch);
for i:=1 to 4 do
	cal[3,67+i]:=ch[2+i];
convalpha(annee-1791,ch);
for i:=1 to 3 do
	cal[2,64+i]:=ch[3+i];
affichage(cal);
for i:=1 to 30 do
	writeln;
end;

begin
repeat
	action:=menu(false);
	if action>0
	then	case action of
			1:demonstration;
			2:convrepgreg;
			3:convgregrep;
			4:calend;
			end;
until action=0
end.
