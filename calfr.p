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

uses getopts, strutils;

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
   action      : integer;
   c           : char;
   optionindex : Longint;
   theopts     : array [1..7] of TOption;
   mode_dial   : boolean;
   verbeux     : boolean;

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
then    begin
        negatif:=true;
        n:=-n;
        end
else    negatif:=false;
repeat
        ch[i]:=chr(ord('0')+n mod 10);
        n:=n div 10;
        i:=i-1
until n=0;
if negatif
then    ch[i]:='-';
end;

function bissex(an:integer):integer;
{ rend 1 si l'année est bissextile, et 0 sinon. }
begin
if an mod 400 = 0
then    bissex:=1
else    if an mod 100 = 0
        then    bissex:=0
        else    if an mod 4 = 0
                then    bissex:=1
                else    bissex:=0
end;

function equinoxe(annee:integer):integer;
begin
case annee mod 4 of
        0:      begin
                equinoxe:=22;
                if (annee=2092) or (annee=2096)
                then    equinoxe:=21;
                if ((annee>=1800) and (annee<=1836))
                        or ((annee>=1900) and (annee<=1964))
                then    equinoxe:=23;
                end;
        1:      begin
                if annee<=1993
                then    equinoxe:=23
                else    equinoxe:=22;
                if (annee<=1797) or ((annee>=1873) and (annee<=1897))
                then    equinoxe:=22;
                if (annee>=2101) and (annee<=2121)
                then    equinoxe:=23;
                end;
        2:      begin
                equinoxe:=23;
                if (annee<=1798) or ((annee>=2030) and (annee<=2098))
                        or (annee>=2154)
                then    equinoxe:=22;
                end;
        3:      begin
                equinoxe:=23;
                if (annee=1803) or ((annee>=1903) and (annee<=1931))
                then    equinoxe:=24;
                if ((annee>=2059) and (annee<=2099)) or (annee>=2187)
                then    equinoxe:=22;
                end;
        end;
end;

function gregnum(date:tdate):integer;
{ donne le nombre de jours entre date et le 0 janvier de l'année }
begin
case date.mois of
         1: gregnum := date.jour;
         2: gregnum := date.jour +  31;
         3: gregnum := date.jour +  59 + bissex(date.an);
         4: gregnum := date.jour +  90 + bissex(date.an);
         5: gregnum := date.jour + 120 + bissex(date.an);
         6: gregnum := date.jour + 151 + bissex(date.an);
         7: gregnum := date.jour + 181 + bissex(date.an);
         8: gregnum := date.jour + 212 + bissex(date.an);
         9: gregnum := date.jour + 243 + bissex(date.an);
        10: gregnum := date.jour + 273 + bissex(date.an);
        11: gregnum := date.jour + 304 + bissex(date.an);
        12: gregnum := date.jour + 334 + bissex(date.an);
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
then    dateeq.an:=dategreg.an
else    begin
        dateeq.an:=dategreg.an-1;
        numero:=numero+365+bissex(dateeq.an)
        end;
dateeq.jour:=equinoxe(dateeq.an);
eq:=gregnum(dateeq);
if eq>numero
then    begin
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
then    begin
        annee:=daterep.an+1792;
        numero:=numero-365-bissex(dateeq.an);
        end
else    annee:=daterep.an+1791;
numgreg(numero,annee,dategreg);
end;

function joursem(date:tdate):integer;
var
        n,ans,siecle:integer;
begin
ans:=(date.an-1) mod 100;
siecle:=1+(date.an-1) div 100;
if (siecle>=18) and (siecle<=22)
then    case siecle of
                18: n := 4;
                19: n := 2;
                20: n := 0;
                21: n := 6;
                22: n := 4;
                end;
n:=n+ans+ans div 4;
joursem:=(n+gregnum(date)) mod 7;
end;

{ Fonction demandant une année à l'utilisateur }
function demande_annee(annonce : String; verbeux : boolean) : integer;
begin
   if verbeux then
      write(annonce);
   readln(demande_annee);
end; { demande_annee }

{ Fonction demandant une date à l'utilisateur }
function demande_date(verbeux : boolean) : Tdate;
var
   date : Tdate;
begin
   if verbeux then
      write('Date (j m a) ');
   readln(date.jour, date.mois, date.an);
   demande_date := date;
end; { demande_date }

{ Fonction décodant une chaîne de caractères et en extrayant l'année, le jour et le mois.

  Pas de contrôle de cohérence de la date. D'autant plus que cela sert aussi bien pour les
  dates grégoriennes (avec jusqu'à 31 jours par mois, mais seulement 12 mois) que pour les
  dates républicaines (jamais plus de 30 jours par mois, mais il existe un pseudo-mois 13,
  les jours complémentaires.
}
function decode_aaaammjj(ch: string): Tdate;
var
   date : Tdate;
   i, n : integer;
begin

   { recherche de la longueur utile de la chaîne }
   n := 1;
   while (ord(ch[n]) >= ord('0')) and (ord(ch[n]) <= ord('9')) do
      n := n + 1;
   n := n - 1; { pour pointer sur le dernier élément correct et non pas sur le premier élément incorrect }

   { extraction des nombres contenus dans la chaîne }
   if n >= 2 then
      date.jour := 10 * (ord(ch[n-1]) - ord('0')) + ord(ch[n]) - ord('0')
   else if n = 1 then
      date.jour := ord(ch[n]) - ord('0')
   else
      date.jour := 1;

   if n >= 4 then
      date.mois := 10 * (ord(ch[n-3]) - ord('0')) + ord(ch[n-2]) - ord('0')
   else if n = 3 then
      date.mois := ord(ch[n-2]) - ord('0')
   else
      date.mois := 1;

   date.an   := 0;
   for i := 1 to n - 4 do
      date.an := 10 * date.an + ord(ch[i]) - ord('0');
   if date.an = 0 then
      date.an := 1;

   decode_aaaammjj := date;
end; { decode_aaaammjj }

{ Contrôle de cohérence des éléments de la date républicaine.

  En faisant l'impasse sur le 6e jour complémentaire pour les années normales !
}
function verif_rep(date : Tdate; var erreur: string): boolean;
var
   ver : boolean;
begin
   ver    := true;
   erreur := '';
   if (date.mois < 1)
      then begin
         ver    := false;
         erreur := 'mois zéro incorrect';
      end
   else if (date.mois > 13)
      then begin
         ver    := false;
         erreur := 'mois 14 ou plus incorrect';
      end
   else if (date.jour < 1)
      then begin
         ver    := false;
         erreur := 'jour zéro incorrect';
      end
   else if ((date.jour > 30) and (date.mois < 13))
      then begin
         ver    := false;
         erreur := 'jour 31 ou plus incorrect';
      end
   else if ((date.jour > 6) and (date.mois = 13))
      then begin
         ver    := false;
         erreur := 'jour complémentaire 7 ou plus incorrect';
      end
   else if (date.an < 1) or (date.an > 407)
      then begin
         ver    := false;
         erreur := 'année en dehors de la plage autorisée';
      end;
   verif_rep:=ver;
end;

{ Contrôle de cohérence des éléments de la date républicaine.

  En faisant l'impasse sur les jours antérieurs au 22 septembre 1792.
}
function verif_greg(date : Tdate; var erreur: string): boolean;
var
   ver : boolean;
begin
   ver    := true;
   erreur := '';
   if (date.mois < 1)
      then begin
         ver    := false;
         erreur := 'mois zéro incorrect';
      end
   else if (date.mois > 12)
      then begin
         ver    := false;
         erreur := 'mois 13 ou plus incorrect';
      end
   else if (date.jour < 1)
      then begin
         ver    := false;
         erreur := 'jour zéro incorrect';
      end
   else if (date.an < 1792) or (date.an > 2199)
      then begin
         ver    := false;
         erreur := 'année en dehors de la plage autorisée';
      end
   else if (date.mois in [4, 6, 9, 11]) and (date.jour > 30)
      then begin
         ver    := false;
         erreur := 'jour incorrect pour un mois à 30 jours';
      end
   else if (date.mois <> 2) and (date.jour > 31)
      then begin
         ver    := false;
         erreur := 'jour incorrect pour un mois à 31 jours';
      end
   else if (date.mois = 2) and  (date.jour > 28 + bissex(date.an))
      then begin
         ver    := false;
         erreur := 'jour incorrect pour février';
      end;
   verif_greg := ver;
end;

procedure affrep(date:tdate);
begin
write(date.jour:2);
case date.mois of
         1: write(' vendémiaire ');
         2: write(' brumaire ');
         3: write(' frimaire ');
         4: write(' nivôse ');
         5: write(' pluviôse ');
         6: write(' ventôse ');
         7: write(' germinal ');
         8: write(' floréal ');
         9: write(' prairial ');
        10: write(' messidor ');
        11: write(' thermidor ');
        12: write(' fructidor ');
        13: write(' sans-culottide ');
        end;
writeln(date.an:3);
end;

procedure affgreg(date:tdate);
begin
case joursem(date) of
        0: write('lundi ');
        1: write('mardi ');
        2: write('mercredi ');
        3: write('jeudi ');
        4: write('vendredi ');
        5: write('samedi ');
        6: write('dimanche ');
        end;
write(date.jour:2);
case date.mois of
         1: write(' janvier ');
         2: write(' février ');
         3: write(' mars ');
         4: write(' avril ');
         5: write(' mai ');
         6: write(' juin ');
         7: write(' juillet ');
         8: write(' août ');
         9: write(' septembre ');
        10: write(' octobre ');
        11: write(' novembre ');
        12: write(' décembre ');
        end;
writeln(date.an:4)
end;

function menu(demo : boolean; verbeux : boolean) : integer;
var
   n : integer;
begin
repeat
   if verbeux then begin
      writeln('0 : fin');
      writeln('1 : démonstration');
      writeln('2 : conversion de républicain en grégorien');
      writeln('3 : conversion de grégorien en républicain');
      writeln('4 : affichage du calendrier pour une année entière');
   end;
   if demo
      then    n := 1
      else    read(n)
         until (n >= 0) and (n <= 4);
   menu := n;
end;

procedure demonstration;
begin
writeln;
writeln('               DÉMONSTRATION');
writeln;
writeln('               Mode Ligne de commande');
writeln('Vous pouvez spécifier les dates à convertir lors de l''appel en ligne');
writeln('de commande. Par exemple, pour convertir le 9 novembre 1799, tapez');
writeln('       calfr --greg=17991109');
writeln('ou plus brièvement :');
writeln('       calfr -g17991109');
writeln('Pour la conversion dans l''autre sens, avec l''exemple du 9 Thermidor an II :');
writeln('       calfr --rep=21109');
writeln('(Thermidor étant le 11e mois du calendrier républicain). Ou plus simplement :');
writeln('       calfr -r21109');
writeln;
writeln('               Mode Dialogue');
writeln('{ Tout ce qui est entre accolades est un commentaire du programme');
writeln('de démonstration. Le menu s''affiche : }');
if menu(true, true) = 20 then writeln;
writeln('{ Vous répondez : }');
writeln('       3');
writeln('{ On affiche alors }');
writeln('       Date (j m a) ?');
writeln('{ Vous répondez }');
writeln('       22 9 1983');
writeln('{ La date est correcte, il n''y a donc pas de message d''erreur');
writeln('Le programme répond alors }');
writeln('       jeudi 22 septembre 1983');
writeln('{ puis }');
writeln('       5 sans-culottide 191');
writeln('{ Les jours complémentaires s''appelaient en effet sans-culottides');
writeln('de nouveau, voici le menu : }');
if menu(true, true) = 20 then writeln;
writeln('{ Vous répondez : }');
writeln('       4');
writeln('{ Le programme demande }');
writeln('       année ?');
writeln('{ Vous répondez par l''année de votre choix, puis,');
writeln('avant de presser retour-chariot, vous vous placez au');
writeln('début de la feuille suivante. }');
writeln;
writeln('               Mode Laconique');
writeln('Le mode laconique est semblable au mode dialogue, sauf que le programme');
writeln('n''affiche pas le menu ni l''invite pour une date ou une année.');
writeln;
writeln('{ Et revoilà le menu. À vous de jouer ! }');
writeln;
end;

procedure convrepgreg(daterep : Tdate);
var
   dategreg : Tdate;
   erreur   : string;
begin
   mode_dial := false;
   if verif_rep(daterep, erreur)
      then begin
         repgreg(daterep, dategreg);
         affrep(daterep);
         affgreg(dategreg);
      end
      else begin
         writeln('La date est incorrecte');
         writeln(erreur);
      end
end;

procedure convgregrep(dategreg : Tdate);
var
   daterep : tdate;
   erreur  : string;
begin
   mode_dial := false;
   if verif_greg(dategreg, erreur)
      then begin
         gregrep(dategreg, daterep);
         affgreg(dategreg);
         affrep(daterep);
      end
      else begin
         writeln('La date est incorrecte');
         writeln(erreur);
      end
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
        tab[1,        c] := '-';
        tab[ltitre-1, c] := '-';
        tab[lmois-1,  c] := '-';
        tab[diml,     c] := '-';
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
then    l:=lmois+11
else    l:=lmois-1;
repeat
        convalpha(njour,ch);
        case sjour of
                0: ch[4] := 'L';
                1: ch[4] := 'M';
                2: ch[4] := 'M';
                3: ch[4] := 'J';
                4: ch[4] := 'V';
                5: ch[4] := 'S';
                6: ch[4] := 'D';
                end;
        l:=l+1;
        tab[l,n*10-4]:=ch[4];
        tab[l,n*10-3]:=ch[5];
        tab[l,n*10-2]:=ch[6];
        if njour=long
        then    njour:=1
        else    njour:=njour+1;
        if sjour=6
        then    sjour:=0
        else    sjour:=sjour+1;
        if n=13
        then    begin
                tab[l,124]:=chr(ord('0')+l-lmois-11);
                tab[l,125]:='(';
                tab[l,129]:=')';
                end;
until (l=lmois+29) or ((n=13) and (njour=long));
end;

procedure calend(annee : integer );
{ construit le tableau de caracteres qui donnera le calendrier. }
var
   cal                : ttab;
   i, debut, fin, sem : integer;
   eq                 : Tdate;
   ch                 : alpha6;
begin
   mode_dial := false;
   debut := equinoxe(annee);
   fin   := equinoxe(annee+1);
   inittab(cal);
   eq.an   := annee;
   eq.mois := 9;
   eq.jour := debut;
   sem := joursem(eq);
remplmois( 1, 30,  'VENDEMIAI SEP-OCT ', cal, debut, sem);
remplmois( 2, 31,  'BRUMAIRE  OCT-NOV ', cal, debut, sem);
remplmois( 3, 30,  'FRIMAIRE  NOV-DEC ', cal, debut, sem);
remplmois( 4, 31,  ' NIVOSE   DEC-JAN ', cal, debut, sem);
remplmois( 5, 31,  'PLUVIOSE  JAN-FEV ', cal, debut, sem);
remplmois( 6, 28 + bissex(annee + 1),
                   ' VENTOSE  FEV-MAR ', cal, debut, sem);
remplmois( 7, 31,  'GERMINAL  MAR-AVR ', cal, debut, sem);
remplmois( 8, 30,  ' FLOREAL  AVR-MAI ', cal, debut, sem);
remplmois( 9, 31,  'PRAIRIAL  MAI-JUN ', cal, debut, sem);
remplmois(10, 30,  'MESSIDOR  JUN-JUL ', cal, debut, sem);
remplmois(11, 31,  'THERMIDOR JUL-AOU ', cal, debut, sem);
remplmois(12, 31,  'FRUCTIDOR AOU-SEP ', cal, debut, sem);
remplmois(13, fin, 'SS-CULOTT   SEP   ', cal, debut, sem);
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

   { spécification des arguments de ligne de commande }
   with theopts[1] do
   begin
      name    := 'repub';
      has_arg := 1;
      flag    := nil;
      value   := #0;
   end ;
   with theopts[2] do
   begin
      name    := 'greg';
      has_arg := 1;
      flag    := nil;
      value   := #0;
   end ;
   with theopts[3] do
   begin
      name    := 'calend';
      has_arg := 1;
      flag    := nil;
      value   := #0;
   end ;
   with theopts[4] do
   begin
      name    := 'equinox';
      has_arg := 0;
      flag    := nil;
      value   := #0;
   end ;
   with theopts [5] do
   begin
      name    := 'arithm';
      has_arg := 0;
      flag    := nil;
      value   := #0;
   end ;
   with theopts [6] do
   begin
      name    := 'laconique';
      has_arg := 0;
      flag    := nil;
      value   := #0;
   end ;
   with theopts [7] do
   begin
      name    := '' ;
      has_arg := 0 ;
      flag    := nil ;
   end ;
 
   { analyse et traitement des arguments de ligne de commande }
   mode_dial := true;
   verbeux   := false;
   c := #0;
   repeat
      c := getlongopts('r:g:c:eal' , @theopts[1], optionindex);
      case c of
        #0 : begin
           case optionindex of
             1: convrepgreg(decode_aaaammjj(optarg)) ;
             2: convgregrep(decode_aaaammjj(optarg)) ;
             3: calend(Numb2Dec(optarg, 10));
             6: verbeux := false;
           end;
        end;   
        'r': convrepgreg(decode_aaaammjj(optarg)) ;
        'g': convgregrep(decode_aaaammjj(optarg)) ;
        'c': calend(Numb2Dec(optarg, 10));
        'e': writeln( 'Option e ' );
        'a': writeln( 'Option a ' );
        'l': verbeux := false;
        '?' , ':' : writeln('Erreur avec l''option : ', optopt);
      end ; { case }
   until c = endofoptions;
   if mode_dial then
      repeat
         action := menu(false, verbeux);
         if action > 0
            then case action of
              1 : demonstration;
              2 : convrepgreg(demande_date(verbeux));
              3 : convgregrep(demande_date(verbeux));
              4 : calend(demande_annee('année ? (n''oubliez pas de positionner le papier en début de page) ', verbeux));
            end;
      until action=0;
end.

=encoding utf8

=head1 NAME

calfr -- program to convert Gregorian dates to French Revolutionary or the other way.

=head1 USAGE

Converting 9th november 1799 to French Revolutionary

  calfr --greg=17991109
  calfr -g17991109

Converting 9th Thermidor II to Gregorian (Thermidor is the 11th month)

  calfr --rep=21109
  calfr --rep=00021109
  calfr -r21109

=head1 DESCRIPTION

This  program allows  the user  to  convert dates  from the  Gregorian
calendar to the French Revolutionary calendar or the other way.

=head1 OPTIONS AND PARAMETERS

A first  way to use  the program is  to enter the dates  with commmand
line  parameters.  Each C<repub>  date will  be converted  from French
Revolutionary  to Gregorian  and printed,  each C<greg>  date  will be
converted from  Gregorian to French Revolutionary and  printed. Or you
can  print the  calendar  for a  whole  year by  entering a  C<calend>
parameter.

Interspersed  with   these  parameters  are   options  C<equinox>  and
C<arithm>  to  select  which   algorithm  will  determine  the  French
Revolutionary leap years. Each option is in effect until overridden by
another option.

=head2 COMMAND-LINE OPTIONS AND PARAMETERS

=over 4

=item repub

Input  date given  in  the French  Revolutionary calendar  (calendrier
I<répub>licain).

Use a YYYYMMDD format, optionally stripping the leading zeros.

=item gregor

Input date given in the Gregorian calendar. Use a YYYYMMDD format.

=item calend

Print  the calendar  for  a whole  year.  The input  parameter is  the
Gregorian  date  corresponding  to   the  first  part  of  the  French
Revolutionary yer.  For example use  C<--calend=1792> for year  I, use
C<--calend=2017> for year CCXXVI.

=item equinox

Option without value. Use the equinox rule: the 1st Vendémiaire (first
day of the year) must coincide with the automn equinox.

=item arithm

Option without value. Use the  arithmetic rule: starting with year 20,
leap years in the French  Revolutionary calendar are determined with a
set of modulo rules similar to the Gregorian calendar.

Yet, before year 20, the equinox rule is in effect.

=back

=head2 DIALOG MODE PARAMETERS

If no C<repub>, C<greg> or C<calend> parameters are given, the program
use the  second way of getting the  input dates, by a  dialog with the
user.  The program asks  for a  numerical command,  and then  an input
parameter.

Numerical options are:

=over 4

=item 0

Quit the program

=item 1

Demo (in French)

=item 2

Translate a  French Revolutionary date  into Gregorian and  print both
values.  The date is entered in C<DD MM YYYY> format.

=item 3

Translate a  Gregorian date into  French Revolutionary and  print both
values.  The date is entered in C<DD MM YYYY> format.

=item 4

Asks  for a  Gregorian year  and print  the French  Revolutionary year
beginning in the corresponding September.

=item 5

Select the equinox rule.

=item 6

Select the arithmetic (Romme) rule. Not coded yet.

=back

=head2 UNIX PIPELINE MODE

Unix pipeline mode is similar  to dialog mode, except that the program
does not prompt  for an action or a date. The  user must remember what
must be entered next.

Unix  pipeline mode  is triggered  by the  C<--laconique> command-line
option.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

No known incompatibilities.

=head1 BUGS AND LIMITS

Bad  support of  UTF-8:  dates  may be  printed  as C<Vendémiaire>  or
C<Décadi>  on  a UTF-8-configured  console,  but  internally they  are
processed  by the program  as C<VendÂ©miaire>  and C<DÂ©cadi>.   For a
end-user it seems fine, but if  you want to dig within the program you
will not be able to do proper string processing.

The arithmetic rule is not coded yet.

The equinox rule has not been  compared with a reliable source such as
Reingold and Dershowitz's I<Calendar Calculations>.

=head1 AUTHOR

Jean Forget, JFORGET (à) cpan.org

=head1 SEE ALSO

=head2 Software

=head3 By me

L<DateTime::Calendar::FrenchRevolutionary> or L<https://github.com/jforget/DateTime-Calendar-FrenchRevolutionary>

L<Date::Convert::French_Rev> or L<https://github.com/jforget/Date-Convert-French_Rev>

L<https://www.gnu.org/software/apl/Bits_and_Pieces/calfr.apl.html> or L<https://github.com/jforget/apl-calendar-french>

L<https://www.hpcalc.org/details/7309> or L<https://github.com/jforget/hp48-hp50-French-Revolutionary-calendar>

L<https://github.com/jforget/hp41-calfr>

=head3 Only partly by me

L<https://github.com/jforget/emacs-lisp-cal-french>, a fork of F<calendar/cal-french.el> in Emacs

=head3 Not by me

CALENDRICA 3.0 -- Common Lisp, which can be download in the "Resources" section of
L<http://www.cambridge.org/us/academic/subjects/computer-science/computing-general-interest/calendrical-calculations-3rd-edition?format=PB&isbn=9780521702386>

French Calendar for Android at
L<https://f-droid.org/packages/ca.rmen.android.frenchcalendar/>
or L<https://github.com/caarmen/FRCAndroidWidget>
and L<https://github.com/caarmen/french-revolutionary-calendar>

Thermidor for Android at L<https://github.com/jhbadger/Thermidor-Android>

A Ruby program at L<https://github.com/jhbadger/FrenchRevCal-ruby>

=head2 Books

Quid 2001, M and D Frémy, publ. Robert Laffont

Agenda Républicain 197 (1988/89), publ. Syros Alternatives

Any French schoolbook about the French Revolution

The French Revolution, Thomas Carlyle, Oxford University Press

Calendrier Militaire, anonymous

Calendrical Calculations (Third Edition) by Nachum Dershowitz and
Edward M. Reingold, Cambridge University Press, see
L<http://www.calendarists.com>
or L<http://www.cambridge.org/us/academic/subjects/computer-science/computing-general-interest/calendrical-calculations-3rd-edition?format=PB&isbn=9780521702386>.

=head2 Internet

L<http://www.faqs.org/faqs/calendars/faq/part3/>

L<http://datetime.mongueurs.net/>

L<http://www.allhotelscalifornia.com/kokogiakcom/frc/default.asp>

L<https://en.wikipedia.org/wiki/French_Republican_Calendar>

L<http://prairial.free.fr/calendrier/calendrier.php?lien=sommairefr> (in French)

=head1 LICENSE AND COPYRIGHT

(C) Jean Forget,  1983, 1984, 2018 all rights  reserved.  This program
is  free software. You  can distribute,  modify, and  otherwise mangle
this program under the same terms as perl 5.16.3.

This program is  distributed under the same terms  as Perl 5.16.3: GNU
Public License version 1 or later and Perl Artistic License

You can find the text of the licenses in the F<LICENSE> file or at
L<http://www.perlfoundation.org/artistic_license_1_0> and
L<http://www.gnu.org/licenses/gpl-1.0.html>.

Here is the summary of GPL:

This program is  free software; you can redistribute  it and/or modify
it under the  terms of the GNU General Public  License as published by
the Free  Software Foundation; either  version 1, or (at  your option)
any later version.

This program  is distributed in the  hope that it will  be useful, but
WITHOUT   ANY  WARRANTY;   without  even   the  implied   warranty  of
MERCHANTABILITY  or FITNESS  FOR A  PARTICULAR PURPOSE.   See  the GNU
General Public License for more details.

You  should have received  a copy  of the  GNU General  Public License
along with this program; if not, see <http://www.gnu.org/licenses/> or
write to the Free Software Foundation, Inc., L<http://fsf.org>.


=cut
