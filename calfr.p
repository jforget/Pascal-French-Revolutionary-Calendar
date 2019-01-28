{ -*- encoding: utf-8; indent-tabs-mode: nil -*- }
program calendrier(input,output);
{ Sur une idée originale de Fabre d'Églantine,
 voici une réalisation de Jean Forget,
un programme de conversion entre calendriers républicain & grégorien
Program to convert Gregorian dates into French Revolutionary dates or the other way.
Copyright (C) 1983, 1984, 2018, 2019 Jean Forget

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
   Tdate   = record
                an   : integer;
                mois : integer;
                jour : integer;
             end;    
   ttab    = array[1..diml,1..dimc] of char;
   alpha6  = array[1..6] of char;
   alpha18 = packed array[1..18] of char;
   Tvnd1   = function(an : integer) : integer;
var
   action      : integer;
   c           : char;
   optionindex : Longint;
   theopts     : array [1..7] of TOption;
   mode_dial   : boolean;
   verbeux     : boolean;
   vnd1        : Tvnd1; { calcul du 1er vendémiaire }

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

{ rend 1 si l'année grégorienne est bissextile, et 0 sinon. }
function bissex(an:integer):integer;
begin
   if an mod 4 <> 0 then
      bissex := 0
   else if an mod 100 <> 0 then
      bissex := 1
   else if an mod 400 <> 0 then
      bissex := 0
   else
      bissex := 1
end;

{ Calcul du 1er Vendémiaire avec la règle des équinoxes
  (règle définie par Reingold et Dershowitz, mais calculée une bonne fois pour toutes au lieu d'être recalculée à chaque fois)
}
function equinoxe(annee : integer) : integer;
begin
case annee mod 4 of
   0: begin
         equinoxe := 21;
         if (annee >= 1792) and (annee <= 1796) then
            equinoxe := 22
         else if (annee >= 1800) and (annee <= 1836) then
            equinoxe := 23
         else if (annee >= 1840) and (annee <= 1896) then
            equinoxe := 22
         else if (annee >= 1900) and (annee <= 1964) then
            equinoxe := 23
         else if (annee >= 1968) and (annee <= 2088) then
            equinoxe := 22
         else if (annee >= 2100) and (annee <= 2196) then
            equinoxe := 22
         else if (annee >= 2200) and (annee <= 2212) then
            equinoxe := 23
         else if (annee >= 2216) and (annee <= 2296) then
            equinoxe := 22
         else if (annee >= 2300) and (annee <= 2336) then
            equinoxe := 23
         else if (annee >= 2340) and (annee <= 2456) then
            equinoxe := 22
         else if (annee >= 2500) and (annee <= 2580) then
            equinoxe := 22
         else if (annee >= 2600) and (annee <= 2696) then
            equinoxe := 22
         else if (annee >= 2700) and (annee <= 2704) then
            equinoxe := 23
         else if (annee >= 2708) and (annee <= 2820) then
            equinoxe := 22
         else if (annee >= 2900) and (annee <= 2948) then
            equinoxe := 22
         else if (annee >= 3000) and (annee <= 3072) then
            equinoxe := 22
         else if (annee >= 3100) and (annee <= 3176) then
            equinoxe := 22
         else if (annee = 3300) then
            equinoxe := 22
         else if (annee >= 3400) and (annee <= 3420) then
            equinoxe := 22
         else if (annee >= 3500) and (annee <= 3544) then
            equinoxe := 22
         else if (annee >= 3668) and (annee <= 3696) then
            equinoxe := 20
         else if (annee >= 3788) and (annee <= 3796) then
            equinoxe := 20
         else if (annee >= 3900) and (annee <= 3908) then
            equinoxe := 22
         else if (annee >= 4028) and (annee <= 4096) then
            equinoxe := 20
         else if (annee >= 4136) and (annee <= 4196) then
            equinoxe := 20
         else if (annee >= 4244) and (annee <= 4296) then
            equinoxe := 20
         else if (annee >= 4364) and (annee <= 4476) then
            equinoxe := 20
         else if (annee >= 4480) and (annee <= 4496) then
            equinoxe := 19
         else if (annee >= 4500) and (annee <= 4596) then
            equinoxe := 20
         else if (annee >= 4608) and (annee <= 4696) then
            equinoxe := 20
         else if (annee >= 4712) and (annee <= 4824) then
            equinoxe := 20
         else if (annee >= 4828) and (annee <= 4896) then
            equinoxe := 19
         else if (annee >= 4900) and (annee <= 4944) then
            equinoxe := 20
         else if (annee >= 4948) and (annee <= 4996) then
            equinoxe := 19
         else if (annee >= 5000) and (annee <= 5056) then
            equinoxe := 20
         else if (annee >= 5060) and (annee <= 5096) then
            equinoxe := 19
         else if (annee >= 5100) and (annee <= 5164) then
            equinoxe := 20
         else if (annee >= 5168) and (annee <= 5272) then
            equinoxe := 19
         else if (annee = 5276) then
            equinoxe := 18
         else if (annee = 5280) then
            equinoxe := 19
         else if (annee >= 5284) and (annee <= 5296) then
            equinoxe := 18
         else if (annee >= 5300) and (annee <= 5384) then
            equinoxe := 19
         else if (annee = 5388) then
            equinoxe := 18
         else if (annee = 5392) then
            equinoxe := 19
         else if (annee = 5396) then
            equinoxe := 18
         else if (annee >= 5400) and (annee <= 5628) then
            equinoxe := 19
         else if (annee = 5632) then
            equinoxe := 18
         else if (annee = 5636) then
            equinoxe := 19
         else if (annee >= 5640) and (annee <= 5696) then
            equinoxe := 18
         else if (annee >= 5700) and (annee <= 5724) then
            equinoxe := 19
         else if (annee = 5728) then
            equinoxe := 18
         else if (annee = 5732) then
            equinoxe := 19
         else if (annee >= 5736) and (annee <= 5796) then
            equinoxe := 18
         else if (annee >= 5800) and (annee <= 5852) then
            equinoxe := 19
         else if (annee >= 5856) and (annee <= 5896) then
            equinoxe := 18
         else if (annee >= 5900) and (annee <= 5948) then
            equinoxe := 19
         else if (annee >= 5952) and (annee <= 6060) then
            equinoxe := 18
         else if (annee >= 6064) and (annee <= 6096) then
            equinoxe := 17
         else if (annee >= 6100) and (annee <= 6172) then
            equinoxe := 18
         else if (annee >= 6176) and (annee <= 6196) then
            equinoxe := 17
         else if (annee >= 6200) and (annee <= 6292) then
            equinoxe := 18
         else if (annee = 6296) then
            equinoxe := 17
         else if (annee = 6300) then
            equinoxe := 19
         else if (annee >= 6304) and (annee <= 6416) then
            equinoxe := 18
         else if (annee >= 6420) and (annee <= 6496) then
            equinoxe := 17
         else if (annee >= 6500) and (annee <= 6520) then
            equinoxe := 18
         else if (annee = 6524) then
            equinoxe := 17
         else if (annee = 6528) then
            equinoxe := 18
         else if (annee >= 6532) and (annee <= 6596) then
            equinoxe := 17
         else if (annee >= 6600) and (annee <= 6632) then
            equinoxe := 18
         else if (annee >= 6636) and (annee <= 6696) then
            equinoxe := 17
         else if (annee >= 6700) and (annee <= 6728) then
            equinoxe := 18
         else if (annee = 6732) then
            equinoxe := 17
         else if (annee = 6736) then
            equinoxe := 18
         else if (annee >= 6740) and (annee <= 6840) then
            equinoxe := 17
         else if (annee = 6844) then
            equinoxe := 16
         else if (annee = 6848) then
            equinoxe := 17
         else if (annee >= 6852) and (annee <= 6896) then
            equinoxe := 16
         else if (annee >= 6900) and (annee <= 6964) then
            equinoxe := 17
         else if (annee >= 6968) and (annee <= 6996) then
            equinoxe := 16
         else if (annee >= 7000) and (annee <= 7080) then
            equinoxe := 17
         else if (annee >= 7084) and (annee <= 7096) then
            equinoxe := 16
         else if (annee >= 7100) and (annee <= 7196) then
            equinoxe := 17
         else if (annee = 7200) then
            equinoxe := 16
         else if (annee = 7204) then
            equinoxe := 17
         else if (annee >= 7208) and (annee <= 7288) then
            equinoxe := 16
         else if (annee >= 7292) and (annee <= 7296) then
            equinoxe := 15
         else if (annee >= 7300) and (annee <= 7396) then
            equinoxe := 16
         else if (annee = 7400) then
            equinoxe := 17
         else if (annee >= 7404) and (annee <= 7408) then
            equinoxe := 16
         else if (annee = 7412) then
            equinoxe := 17
         else if (annee >= 7416) and (annee <= 7496) then
            equinoxe := 16
         else if (annee >= 7500) and (annee <= 7504) then
            equinoxe := 17
         else if (annee = 7508) then
            equinoxe := 16
         else if (annee >= 7512) and (annee <= 7516) then
            equinoxe := 17
         else if (annee >= 7520) and (annee <= 7636) then
            equinoxe := 16
         else if (annee >= 7640) and (annee <= 7696) then
            equinoxe := 15
         else if (annee >= 7700) and (annee <= 7748) then
            equinoxe := 16
         else if (annee = 7752) then
            equinoxe := 15
         else if (annee = 7756) then
            equinoxe := 16
         else if (annee >= 7760) and (annee <= 7792) then
            equinoxe := 15
      end;
   1: begin
         equinoxe := 17;
         if (annee >= 1793) and (annee <= 1797) then
            equinoxe := 22
         else if (annee >= 1801) and (annee <= 1869) then
            equinoxe := 23
         else if (annee >= 1873) and (annee <= 1897) then
            equinoxe := 22
         else if (annee >= 1901) and (annee <= 1993) then
            equinoxe := 23
         else if (annee >= 1997) and (annee <= 2097) then
            equinoxe := 22
         else if (annee >= 2101) and (annee <= 2117) then
            equinoxe := 23
         else if (annee >= 2121) and (annee <= 2197) then
            equinoxe := 22
         else if (annee >= 2201) and (annee <= 2245) then
            equinoxe := 23
         else if (annee >= 2249) and (annee <= 2297) then
            equinoxe := 22
         else if (annee >= 2301) and (annee <= 2365) then
            equinoxe := 23
         else if (annee >= 2369) and (annee <= 2489) then
            equinoxe := 22
         else if (annee >= 2493) and (annee <= 2497) then
            equinoxe := 21
         else if (annee >= 2501) and (annee <= 2597) then
            equinoxe := 22
         else if (annee >= 2601) and (annee <= 2613) then
            equinoxe := 23
         else if (annee >= 2617) and (annee <= 2697) then
            equinoxe := 22
         else if (annee >= 2701) and (annee <= 2729) then
            equinoxe := 23
         else if (annee >= 2733) and (annee <= 2853) then
            equinoxe := 22
         else if (annee >= 2857) and (annee <= 2897) then
            equinoxe := 21
         else if (annee >= 2901) and (annee <= 2977) then
            equinoxe := 22
         else if (annee >= 2981) and (annee <= 2997) then
            equinoxe := 21
         else if (annee >= 3001) and (annee <= 3209) then
            equinoxe := 22
         else if (annee >= 3213) and (annee <= 3297) then
            equinoxe := 21
         else if (annee >= 3301) and (annee <= 3325) then
            equinoxe := 22
         else if (annee >= 3329) and (annee <= 3397) then
            equinoxe := 21
         else if (annee >= 3401) and (annee <= 3453) then
            equinoxe := 22
         else if (annee >= 3457) and (annee <= 3497) then
            equinoxe := 21
         else if (annee >= 3501) and (annee <= 3569) then
            equinoxe := 22
         else if (annee >= 3573) and (annee <= 3685) then
            equinoxe := 21
         else if (annee >= 3689) and (annee <= 3697) then
            equinoxe := 20
         else if (annee >= 3701) and (annee <= 3797) then
            equinoxe := 21
         else if (annee >= 3801) and (annee <= 3813) then
            equinoxe := 22
         else if (annee >= 3817) and (annee <= 3897) then
            equinoxe := 21
         else if (annee >= 3901) and (annee <= 3929) then
            equinoxe := 22
         else if (annee >= 3933) and (annee <= 4041) then
            equinoxe := 21
         else if (annee >= 4045) and (annee <= 4097) then
            equinoxe := 20
         else if (annee >= 4101) and (annee <= 4153) then
            equinoxe := 21
         else if (annee >= 4157) and (annee <= 4197) then
            equinoxe := 20
         else if (annee >= 4201) and (annee <= 4269) then
            equinoxe := 21
         else if (annee >= 4273) and (annee <= 4297) then
            equinoxe := 20
         else if (annee >= 4301) and (annee <= 4397) then
            equinoxe := 21
         else if (annee >= 4401) and (annee <= 4497) then
            equinoxe := 20
         else if (annee >= 4501) and (annee <= 4513) then
            equinoxe := 21
         else if (annee >= 4517) and (annee <= 4597) then
            equinoxe := 20
         else if (annee >= 4601) and (annee <= 4629) then
            equinoxe := 21
         else if (annee >= 4633) and (annee <= 4697) then
            equinoxe := 20
         else if (annee >= 4701) and (annee <= 4729) then
            equinoxe := 21
         else if (annee >= 4733) and (annee <= 4849) then
            equinoxe := 20
         else if (annee >= 4853) and (annee <= 4897) then
            equinoxe := 19
         else if (annee >= 4901) and (annee <= 4957) then
            equinoxe := 20
         else if (annee >= 4961) and (annee <= 4997) then
            equinoxe := 19
         else if (annee >= 5001) and (annee <= 5085) then
            equinoxe := 20
         else if (annee >= 5089) and (annee <= 5097) then
            equinoxe := 19
         else if (annee >= 5101) and (annee <= 5193) then
            equinoxe := 20
         else if (annee >= 5197) and (annee <= 5297) then
            equinoxe := 19
         else if (annee = 5301) then
            equinoxe := 20
         else if (annee = 5305) then
            equinoxe := 19
         else if (annee = 5309) then
            equinoxe := 20
         else if (annee >= 5313) and (annee <= 5397) then
            equinoxe := 19
         else if (annee >= 5401) and (annee <= 5413) then
            equinoxe := 20
         else if (annee = 5417) then
            equinoxe := 19
         else if (annee >= 5421) and (annee <= 5425) then
            equinoxe := 20
         else if (annee >= 5429) and (annee <= 5497) then
            equinoxe := 19
         else if (annee >= 5501) and (annee <= 5529) then
            equinoxe := 20
         else if (annee = 5533) then
            equinoxe := 19
         else if (annee = 5537) then
            equinoxe := 20
         else if (annee >= 5541) and (annee <= 5657) then
            equinoxe := 19
         else if (annee >= 5661) and (annee <= 5697) then
            equinoxe := 18
         else if (annee >= 5701) and (annee <= 5769) then
            equinoxe := 19
         else if (annee >= 5773) and (annee <= 5797) then
            equinoxe := 18
         else if (annee >= 5801) and (annee <= 5881) then
            equinoxe := 19
         else if (annee >= 5885) and (annee <= 5897) then
            equinoxe := 18
         else if (annee >= 5901) and (annee <= 5977) then
            equinoxe := 19
         else if (annee >= 5981) and (annee <= 6089) then
            equinoxe := 18
         else if (annee >= 6101) and (annee <= 6197) then
            equinoxe := 18
         else if (annee = 6201) then
            equinoxe := 19
         else if (annee >= 6205) and (annee <= 6209) then
            equinoxe := 18
         else if (annee = 6213) then
            equinoxe := 19
         else if (annee >= 6217) and (annee <= 6297) then
            equinoxe := 18
         else if (annee >= 6301) and (annee <= 6317) then
            equinoxe := 19
         else if (annee >= 6321) and (annee <= 6445) then
            equinoxe := 18
         else if (annee >= 6501) and (annee <= 6549) then
            equinoxe := 18
         else if (annee = 6557) then
            equinoxe := 18
         else if (annee >= 6601) and (annee <= 6641) then
            equinoxe := 18
         else if (annee >= 6701) and (annee <= 6765) then
            equinoxe := 18
         else if (annee = 6873) then
            equinoxe := 16
         else if (annee >= 6881) and (annee <= 6897) then
            equinoxe := 16
         else if (annee = 6985) then
            equinoxe := 16
         else if (annee >= 6993) and (annee <= 6997) then
            equinoxe := 16
         else if (annee >= 7101) and (annee <= 7113) then
            equinoxe := 18
         else if (annee = 7121) then
            equinoxe := 18
         else if (annee = 7229) then
            equinoxe := 16
         else if (annee >= 7237) and (annee <= 7297) then
            equinoxe := 16
         else if (annee >= 7305) and (annee <= 7309) then
            equinoxe := 16
         else if (annee >= 7317) and (annee <= 7397) then
            equinoxe := 16
         else if (annee = 7437) then
            equinoxe := 16
         else if (annee >= 7445) and (annee <= 7497) then
            equinoxe := 16
         else if (annee >= 7549) and (annee <= 7657) then
            equinoxe := 16
         else if (annee >= 7661) and (annee <= 7697) then
            equinoxe := 15
         else if (annee >= 7701) and (annee <= 7785) then
            equinoxe := 16
         else if (annee = 7789) then
            equinoxe := 15
      end;
   2: begin
         equinoxe := 22;
         if (annee >= 1802) and (annee <= 2026) then
            equinoxe := 23
         else if (annee >= 2102) and (annee <= 2150) then
            equinoxe := 23
         else if (annee >= 2202) and (annee <= 2274) then
            equinoxe := 23
         else if (annee >= 2302) and (annee <= 2398) then
            equinoxe := 23
         else if (annee >= 2502) and (annee <= 2522) then
            equinoxe := 23
         else if (annee >= 2602) and (annee <= 2646) then
            equinoxe := 23
         else if (annee >= 2702) and (annee <= 2758) then
            equinoxe := 23
         else if (annee >= 2894) and (annee <= 2898) then
            equinoxe := 21
         else if (annee >= 3002) and (annee <= 3010) then
            equinoxe := 23
         else if (annee >= 3102) and (annee <= 3114) then
            equinoxe := 23
         else if (annee >= 3246) and (annee <= 3298) then
            equinoxe := 21
         else if (annee >= 3362) and (annee <= 3398) then
            equinoxe := 21
         else if (annee >= 3486) and (annee <= 3498) then
            equinoxe := 21
         else if (annee = 3602) then
            equinoxe := 21
         else if (annee >= 3610) and (annee <= 3698) then
            equinoxe := 21
         else if (annee >= 3726) and (annee <= 3798) then
            equinoxe := 21
         else if (annee >= 3846) and (annee <= 3898) then
            equinoxe := 21
         else if (annee >= 3962) and (annee <= 4062) then
            equinoxe := 21
         else if (annee >= 4066) and (annee <= 4098) then
            equinoxe := 20
         else if (annee >= 4102) and (annee <= 4182) then
            equinoxe := 21
         else if (annee >= 4186) and (annee <= 4198) then
            equinoxe := 20
         else if (annee >= 4202) and (annee <= 4298) then
            equinoxe := 21
         else if (annee >= 4310) and (annee <= 4426) then
            equinoxe := 21
         else if (annee >= 4430) and (annee <= 4498) then
            equinoxe := 20
         else if (annee >= 4502) and (annee <= 4542) then
            equinoxe := 21
         else if (annee >= 4546) and (annee <= 4598) then
            equinoxe := 20
         else if (annee >= 4602) and (annee <= 4654) then
            equinoxe := 21
         else if (annee >= 4658) and (annee <= 4698) then
            equinoxe := 20
         else if (annee >= 4702) and (annee <= 4758) then
            equinoxe := 21
         else if (annee >= 4762) and (annee <= 4878) then
            equinoxe := 20
         else if (annee = 4882) then
            equinoxe := 19
         else if (annee = 4886) then
            equinoxe := 20
         else if (annee >= 4890) and (annee <= 4898) then
            equinoxe := 19
         else if (annee >= 4902) and (annee <= 4986) then
            equinoxe := 20
         else if (annee >= 4990) and (annee <= 4998) then
            equinoxe := 19
         else if (annee >= 5002) and (annee <= 5098) then
            equinoxe := 20
         else if (annee >= 5102) and (annee <= 5114) then
            equinoxe := 21
         else if (annee = 5118) then
            equinoxe := 20
         else if (annee = 5122) then
            equinoxe := 21
         else if (annee >= 5126) and (annee <= 5218) then
            equinoxe := 20
         else if (annee >= 5222) and (annee <= 5298) then
            equinoxe := 19
         else if (annee >= 5302) and (annee <= 5326) then
            equinoxe := 20
         else if (annee >= 5330) and (annee <= 5398) then
            equinoxe := 19
         else if (annee >= 5402) and (annee <= 5454) then
            equinoxe := 20
         else if (annee >= 5458) and (annee <= 5498) then
            equinoxe := 19
         else if (annee >= 5502) and (annee <= 5566) then
            equinoxe := 20
         else if (annee >= 5570) and (annee <= 5670) then
            equinoxe := 19
         else if (annee >= 5674) and (annee <= 5698) then
            equinoxe := 18
         else if (annee >= 5702) and (annee <= 5802) then
            equinoxe := 19
         else if (annee >= 5806) and (annee <= 5810) then
            equinoxe := 20
         else if (annee >= 5814) and (annee <= 5886) then
            equinoxe := 19
         else if (annee >= 5890) and (annee <= 5898) then
            equinoxe := 18
         else if (annee >= 5902) and (annee <= 5990) then
            equinoxe := 19
         else if (annee = 5994) then
            equinoxe := 18
         else if (annee = 5998) then
            equinoxe := 19
         else if (annee >= 6002) and (annee <= 6098) then
            equinoxe := 18
         else if (annee >= 6102) and (annee <= 6122) then
            equinoxe := 19
         else if (annee = 6126) then
            equinoxe := 18
         else if (annee = 6130) then
            equinoxe := 19
         else if (annee >= 6134) and (annee <= 6198) then
            equinoxe := 18
         else if (annee >= 6202) and (annee <= 6234) then
            equinoxe := 19
         else if (annee = 6238) then
            equinoxe := 18
         else if (annee = 6242) then
            equinoxe := 19
         else if (annee >= 6246) and (annee <= 6298) then
            equinoxe := 18
         else if (annee >= 6302) and (annee <= 6346) then
            equinoxe := 19
         else if (annee >= 6350) and (annee <= 6474) then
            equinoxe := 18
         else if (annee >= 6478) and (annee <= 6498) then
            equinoxe := 17
         else if (annee >= 6502) and (annee <= 6586) then
            equinoxe := 18
         else if (annee >= 6590) and (annee <= 6598) then
            equinoxe := 17
         else if (annee >= 6602) and (annee <= 6666) then
            equinoxe := 18
         else if (annee >= 6670) and (annee <= 6698) then
            equinoxe := 17
         else if (annee >= 6702) and (annee <= 6794) then
            equinoxe := 18
         else if (annee >= 6798) and (annee <= 6802) then
            equinoxe := 17
         else if (annee = 6806) then
            equinoxe := 18
         else if (annee >= 6810) and (annee <= 6902) then
            equinoxe := 17
         else if (annee >= 6906) and (annee <= 6910) then
            equinoxe := 18
         else if (annee >= 6914) and (annee <= 6998) then
            equinoxe := 17
         else if (annee >= 7002) and (annee <= 7022) then
            equinoxe := 18
         else if (annee >= 7026) and (annee <= 7098) then
            equinoxe := 17
         else if (annee >= 7102) and (annee <= 7134) then
            equinoxe := 18
         else if (annee >= 7138) and (annee <= 7254) then
            equinoxe := 17
         else if (annee = 7258) then
            equinoxe := 16
         else if (annee = 7262) then
            equinoxe := 17
         else if (annee >= 7266) and (annee <= 7298) then
            equinoxe := 16
         else if (annee >= 7302) and (annee <= 7342) then
            equinoxe := 17
         else if (annee >= 7346) and (annee <= 7398) then
            equinoxe := 16
         else if (annee >= 7402) and (annee <= 7462) then
            equinoxe := 17
         else if (annee >= 7466) and (annee <= 7498) then
            equinoxe := 16
         else if (annee >= 7502) and (annee <= 7574) then
            equinoxe := 17
         else if (annee = 7578) then
            equinoxe := 16
         else if (annee = 7582) then
            equinoxe := 17
         else if (annee >= 7586) and (annee <= 7686) then
            equinoxe := 16
         else if (annee >= 7690) and (annee <= 7694) then
            equinoxe := 15
         else if (annee >= 7698) and (annee <= 7790) then
            equinoxe := 16
      end;
   3: begin
         equinoxe := 22;
         if (annee >= 1795) and (annee <= 1799) then
            equinoxe := 23
         else if (annee = 1803) then
            equinoxe := 24
         else if (annee >= 1807) and (annee <= 1899) then
            equinoxe := 23
         else if (annee >= 1903) and (annee <= 1931) then
            equinoxe := 24
         else if (annee >= 1935) and (annee <= 2059) then
            equinoxe := 23
         else if (annee >= 2103) and (annee <= 2183) then
            equinoxe := 23
         else if (annee >= 2203) and (annee <= 2299) then
            equinoxe := 23
         else if (annee >= 2303) and (annee <= 2307) then
            equinoxe := 24
         else if (annee >= 2311) and (annee <= 2427) then
            equinoxe := 23
         else if (annee >= 2503) and (annee <= 2551) then
            equinoxe := 23
         else if (annee >= 2603) and (annee <= 2675) then
            equinoxe := 23
         else if (annee >= 2703) and (annee <= 2787) then
            equinoxe := 23
         else if (annee >= 2903) and (annee <= 2919) then
            equinoxe := 23
         else if (annee >= 3003) and (annee <= 3039) then
            equinoxe := 23
         else if (annee >= 3103) and (annee <= 3147) then
            equinoxe := 23
         else if (annee >= 3271) and (annee <= 3299) then
            equinoxe := 21
         else if (annee >= 3395) and (annee <= 3399) then
            equinoxe := 21
         else if (annee >= 3503) and (annee <= 3515) then
            equinoxe := 23
         else if (annee >= 3639) and (annee <= 3699) then
            equinoxe := 21
         else if (annee >= 3755) and (annee <= 3799) then
            equinoxe := 21
         else if (annee >= 3875) and (annee <= 3899) then
            equinoxe := 21
         else if (annee >= 3999) and (annee <= 4095) then
            equinoxe := 21
         else if (annee = 4099) then
            equinoxe := 20
         else if (annee >= 4107) and (annee <= 4199) then
            equinoxe := 21
         else if (annee >= 4223) and (annee <= 4299) then
            equinoxe := 21
         else if (annee >= 4343) and (annee <= 4447) then
            equinoxe := 21
         else if (annee >= 4451) and (annee <= 4499) then
            equinoxe := 20
         else if (annee >= 4503) and (annee <= 4567) then
            equinoxe := 21
         else if (annee >= 4571) and (annee <= 4599) then
            equinoxe := 20
         else if (annee >= 4603) and (annee <= 4691) then
            equinoxe := 21
         else if (annee >= 4695) and (annee <= 4699) then
            equinoxe := 20
         else if (annee >= 4703) and (annee <= 4795) then
            equinoxe := 21
         else if (annee >= 4799) and (annee <= 4899) then
            equinoxe := 20
         else if (annee >= 4903) and (annee <= 4911) then
            equinoxe := 21
         else if (annee >= 4915) and (annee <= 4999) then
            equinoxe := 20
         else if (annee >= 5003) and (annee <= 5015) then
            equinoxe := 21
         else if (annee >= 5019) and (annee <= 5099) then
            equinoxe := 20
         else if (annee >= 5103) and (annee <= 5139) then
            equinoxe := 21
         else if (annee >= 5143) and (annee <= 5243) then
            equinoxe := 20
         else if (annee = 5247) then
            equinoxe := 19
         else if (annee = 5251) then
            equinoxe := 20
         else if (annee >= 5255) and (annee <= 5299) then
            equinoxe := 19
         else if (annee >= 5303) and (annee <= 5355) then
            equinoxe := 20
         else if (annee = 5359) then
            equinoxe := 19
         else if (annee = 5363) then
            equinoxe := 20
         else if (annee >= 5367) and (annee <= 5399) then
            equinoxe := 19
         else if (annee >= 5403) and (annee <= 5483) then
            equinoxe := 20
         else if (annee >= 5487) and (annee <= 5499) then
            equinoxe := 19
         else if (annee >= 5503) and (annee <= 5595) then
            equinoxe := 20
         else if (annee >= 5599) and (annee <= 5691) then
            equinoxe := 19
         else if (annee >= 5695) and (annee <= 5699) then
            equinoxe := 18
         else if (annee >= 5703) and (annee <= 5799) then
            equinoxe := 19
         else if (annee >= 5803) and (annee <= 5823) then
            equinoxe := 20
         else if (annee >= 5827) and (annee <= 5899) then
            equinoxe := 19
         else if (annee >= 5903) and (annee <= 5907) then
            equinoxe := 20
         else if (annee = 5911) then
            equinoxe := 19
         else if (annee = 5915) then
            equinoxe := 20
         else if (annee >= 5919) and (annee <= 6019) then
            equinoxe := 19
         else if (annee = 6023) then
            equinoxe := 18
         else if (annee >= 6027) and (annee <= 6031) then
            equinoxe := 19
         else if (annee >= 6035) and (annee <= 6099) then
            equinoxe := 18
         else if (annee >= 6103) and (annee <= 6151) then
            equinoxe := 19
         else if (annee >= 6155) and (annee <= 6199) then
            equinoxe := 18
         else if (annee >= 6203) and (annee <= 6263) then
            equinoxe := 19
         else if (annee = 6267) then
            equinoxe := 18
         else if (annee = 6271) then
            equinoxe := 19
         else if (annee >= 6275) and (annee <= 6299) then
            equinoxe := 18
         else if (annee >= 6303) and (annee <= 6375) then
            equinoxe := 19
         else if (annee = 6379) then
            equinoxe := 18
         else if (annee = 6383) then
            equinoxe := 19
         else if (annee >= 6387) and (annee <= 6487) then
            equinoxe := 18
         else if (annee >= 6491) and (annee <= 6495) then
            equinoxe := 17
         else if (annee >= 6499) and (annee <= 6599) then
            equinoxe := 18
         else if (annee >= 6603) and (annee <= 6619) then
            equinoxe := 19
         else if (annee = 6623) then
            equinoxe := 18
         else if (annee = 6627) then
            equinoxe := 19
         else if (annee >= 6631) and (annee <= 6695) then
            equinoxe := 18
         else if (annee = 6699) then
            equinoxe := 17
         else if (annee >= 6703) and (annee <= 6811) then
            equinoxe := 18
         else if (annee = 6815) then
            equinoxe := 17
         else if (annee = 6819) then
            equinoxe := 18
         else if (annee >= 6823) and (annee <= 6899) then
            equinoxe := 17
         else if (annee >= 6903) and (annee <= 6939) then
            equinoxe := 18
         else if (annee >= 6943) and (annee <= 6999) then
            equinoxe := 17
         else if (annee >= 7003) and (annee <= 7051) then
            equinoxe := 18
         else if (annee >= 7055) and (annee <= 7099) then
            equinoxe := 17
         else if (annee >= 7103) and (annee <= 7163) then
            equinoxe := 18
         else if (annee >= 7167) and (annee <= 7279) then
            equinoxe := 17
         else if (annee >= 7283) and (annee <= 7299) then
            equinoxe := 16
         else if (annee >= 7303) and (annee <= 7371) then
            equinoxe := 17
         else if (annee >= 7375) and (annee <= 7399) then
            equinoxe := 16
         else if (annee >= 7403) and (annee <= 7475) then
            equinoxe := 17
         else if (annee = 7479) then
            equinoxe := 16
         else if (annee = 7483) then
            equinoxe := 17
         else if (annee >= 7487) and (annee <= 7499) then
            equinoxe := 16
         else if (annee >= 7503) and (annee <= 7615) then
            equinoxe := 17
         else if (annee >= 7619) and (annee <= 7699) then
            equinoxe := 16
         else if (annee >= 7703) and (annee <= 7719) then
            equinoxe := 17
         else if (annee = 7723) then
            equinoxe := 16
         else if (annee = 7727) then
            equinoxe := 17
         else if (annee >= 7731) and (annee <= 7791) then
            equinoxe := 16
      end;
   end;
end;

{ Nombre de "jours complémentaires 6" jusqu'à l'année demandée (année grégorienne)

À ne pas utiliser avant l'an XX, soit 1811, date prévue pour mettre en vigueur
la règle de Romme.
}
function nb_jc6(annee : integer) : integer;
begin
   annee  := annee - 1792;
   nb_jc6 :=   annee div    4
             - annee div  100
             + annee div  400
             - annee div 4000;
end; { nb_jc6 }

{ Nombre de "29 février" jusqu'à l'année demandée (année grégorienne)

Il s'agit de compter les "29 février" dans le calendrier grégorien *proleptique*,
c'est-à-dire un calendrier qui applique la règle bissextile depuis le début (an 1)
et qui coïncide avec le calendrier grégorien à partir de 1582.

La plage d'utilisation est à partir de l'année 1811 (an XX), date de la mise en vigueur
de la règle de Romme. Donc, calendrier proleptique ou calendrier réel, peu importe.
}
function nb_f29(annee : integer) : integer;
begin
   nb_f29 :=   annee div    4
             - annee div  100
             + annee div  400;
end; { nb_f29 }

{ Calcul du 1er Vendémiaire avec la règle arithmétique de Gilbert Romme }
function regle_Romme(annee : integer) : integer;
begin
   if annee < 1811 then
      regle_Romme := equinoxe(annee)
   else
      regle_Romme := 457 + nb_jc6(annee) - nb_f29(annee);
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

{ convertit dategreg dans le calendrier républicain. }
function greg_rep(dategreg : Tdate) : Tdate;
var
   numero, eq : integer;{ écart entre date ou équinoxe, et le 0 janvier }
   dateeq     : Tdate;
   daterep    : Tdate;
begin
   dateeq.an   := dategreg.an;
   dateeq.mois := 9;
   dateeq.jour := vnd1(dateeq.an);
   eq     := gregnum(dateeq);
   numero := gregnum(dategreg);
   if eq > numero then begin
      dateeq.an   := dateeq.an - 1;
      dateeq.jour := vnd1(dateeq.an);
      eq     := gregnum(dateeq);
      numero := numero + 365 + bissex(dateeq.an)
   end;
   numrep(numero - eq + 1, dateeq.an - 1791, daterep);
   greg_rep := daterep;
end;

procedure repgreg(daterep:tdate;var dategreg:tdate);
var
   dateeq            : Tdate;
   annee, numero, eq : integer;
begin
   numero      := repnum(daterep);
   dateeq.an   := daterep.an + 1791;
   dateeq.mois := 9;
   dateeq.jour := vnd1(dateeq.an);
   eq := gregnum(dateeq);
   numero := numero + eq - 1;
   if numero > 365 + bissex(dateeq.an) then begin
      annee  := daterep.an + 1792;
      numero := numero - 365 - bissex(dateeq.an);
   end
   else
      annee := daterep.an + 1791;
   numgreg(numero, annee, dategreg);
end;

{ calcule le jour de la semaine sous la forme d'un nombre de 0 (=lundi) à 6 (=dimanche) }
function joursem(date : Tdate) : integer;
begin
   joursem := (date.an + nb_f29(date.an-1) + gregnum(date) + 5) mod 7;
end;

{ Jour de la semaine, cette fois-ci en tant que chaîne de caractères }
function jour_semaine(date : Tdate) : string;
begin
  case joursem(date) of
    0 : jour_semaine := 'lundi';
    1 : jour_semaine := 'mardi';
    2 : jour_semaine := 'mercredi';
    3 : jour_semaine := 'jeudi';
    4 : jour_semaine := 'vendredi';
    5 : jour_semaine := 'samedi';
    6 : jour_semaine := 'dimanche';
  end; { case }
end; { jour_semaine }

{ Jour de la décade (au lieu de la semaine) }
function jour_decade(date : Tdate) : string;
begin
   case date.jour mod 10 of
      0 : jour_decade := 'Décadi'; { éh oui, c'est la différence entre le modulo
                                     mathématique et le modulo calendaire }
      1 : jour_decade := 'Primidi';
      2 : jour_decade := 'Duodi';
      3 : jour_decade := 'Tridi';
      4 : jour_decade := 'Quartidi';
      5 : jour_decade := 'Quintidi';
      6 : jour_decade := 'Sextidi';
      7 : jour_decade := 'Septidi';
      8 : jour_decade := 'Octidi';
      9 : jour_decade := 'Nonidi';
   end; { case }
end;

{ Fête du jour dans le calendrier républicain }
function fete_du_jour(date : Tdate) : string;
var
   ch : string;
begin
   case 30 * (date.mois -1) + date.jour of
          { Vendémiaire }
        1 : ch := 'du raisin';
        2 : ch := 'du safran';
        3 : ch := 'de la châtaigne';
        4 : ch := 'de la colchique';
        5 : ch := 'du cheval';
        6 : ch := 'de la balsamine';
        7 : ch := 'de la carotte';
        8 : ch := 'de l''amarante';
        9 : ch := 'du panais';
       10 : ch := 'de la cuve';
       11 : ch := 'de la pomme de terre';
       12 : ch := 'de l''immortelle';
       13 : ch := 'du potiron';
       14 : ch := 'du réséda';
       15 : ch := 'de l''âne';
       16 : ch := 'de la belle de nuit';
       17 : ch := 'de la citrouille';
       18 : ch := 'du sarrasin';
       19 : ch := 'du tournesol';
       20 : ch := 'du pressoir';
       21 : ch := 'du chanvre';
       22 : ch := 'de la pêche';
       23 : ch := 'du navet';
       24 : ch := 'de l''amaryllis';
       25 : ch := 'du bœuf';
       26 : ch := 'de l''aubergine';
       27 : ch := 'du piment';
       28 : ch := 'de la tomate';
       29 : ch := 'de l''orge';
       30 : ch := 'du tonneau';
          { Brumaire }
       31 : ch := 'de la pomme';
       32 : ch := 'du céleri';
       33 : ch := 'de la poire';
       34 : ch := 'de la betterave';
       35 : ch := 'de l''oie';
       36 : ch := 'de l''héliotrope';
       37 : ch := 'de la figue';
       38 : ch := 'de la scorsonère';
       39 : ch := 'de l''alisier';
       40 : ch := 'de la charrue';
       41 : ch := 'du salsifis';
       42 : ch := 'de la macre';
       43 : ch := 'du topinambour';
       44 : ch := 'de l''endive';
       45 : ch := 'du dindon';
       46 : ch := 'du chervis';
       47 : ch := 'du cresson';
       48 : ch := 'de la dentelaire';
       49 : ch := 'de la grenade';
       50 : ch := 'de la herse';
       51 : ch := 'de la bacchante';
       52 : ch := 'de l''azerole';
       53 : ch := 'de la garance';
       54 : ch := 'de l''orange';
       55 : ch := 'du faisan';
       56 : ch := 'de la pistache';
       57 : ch := 'du macjon';
       58 : ch := 'du coing';
       59 : ch := 'du cormier';
       60 : ch := 'du rouleau';
          { Frimaire }
       61 : ch := 'de la raiponce';
       62 : ch := 'du turneps';
       63 : ch := 'de la chicorée';
       64 : ch := 'de la nèfle';
       65 : ch := 'du cochon';
       66 : ch := 'de la mâche';
       67 : ch := 'du chou-fleur';
       68 : ch := 'du miel';
       69 : ch := 'du genièvre';
       70 : ch := 'de la pioche';
       71 : ch := 'de la cire';
       72 : ch := 'du raifort';
       73 : ch := 'du cèdre';
       74 : ch := 'du sapin';
       75 : ch := 'du chevreuil';
       76 : ch := 'de l''ajonc';
       77 : ch := 'du cyprès';
       78 : ch := 'du lierre';
       79 : ch := 'de la sabine';
       80 : ch := 'du hoyau';
       81 : ch := 'de l''érable-sucre';
       82 : ch := 'de la bruyère';
       83 : ch := 'du roseau';
       84 : ch := 'de l''oseille';
       85 : ch := 'du grillon';
       86 : ch := 'du pignon';
       87 : ch := 'du liège';
       88 : ch := 'de la truffe';
       89 : ch := 'de l''olive';
       90 : ch := 'de la pelle';
          { Nivôse }
       91 : ch := 'de la tourbe';
       92 : ch := 'de la houille';
       93 : ch := 'du bitume';
       94 : ch := 'du soufre';
       95 : ch := 'du chien';
       96 : ch := 'de la lave';
       97 : ch := 'de la terre végétale';
       98 : ch := 'du fumier';
       99 : ch := 'du salpêtre';
      100 : ch := 'du fléau';
      101 : ch := 'du granit';
      102 : ch := 'de l''argile';
      103 : ch := 'de l''ardoise';
      104 : ch := 'du grès';
      105 : ch := 'du lapin';
      106 : ch := 'du silex';
      107 : ch := 'de la marne';
      108 : ch := 'de la pierre à chaux';
      109 : ch := 'du marbre';
      110 : ch := 'du van';
      111 : ch := 'de la pierre à plâtre';
      112 : ch := 'du sel';
      113 : ch := 'du fer';
      114 : ch := 'du cuivre';
      115 : ch := 'du chat';
      116 : ch := 'de l''étain';
      117 : ch := 'du plomb';
      118 : ch := 'du zinc';
      119 : ch := 'du mercure';
      120 : ch := 'du crible';
          { Pluviôse }
      121 : ch := 'de la lauréole';
      122 : ch := 'de la mousse';
      123 : ch := 'du fragon';
      124 : ch := 'du perce-neige';
      125 : ch := 'du taureau';
      126 : ch := 'du laurier-thym';
      127 : ch := 'de l''amadouvier';
      128 : ch := 'du mézéréon';
      129 : ch := 'du peuplier';
      130 : ch := 'de la cognée';
      131 : ch := 'de l''ellébore';
      132 : ch := 'du brocoli';
      133 : ch := 'du laurier';
      134 : ch := 'de l''avelinier';
      135 : ch := 'de la vache';
      136 : ch := 'du buis';
      137 : ch := 'du lichen';
      138 : ch := 'de l''if';
      139 : ch := 'de la pulmonaire';
      140 : ch := 'de la serpette';
      141 : ch := 'du thlaspi';
      142 : ch := 'du thymelé';
      143 : ch := 'du chiendent';
      144 : ch := 'de la traînasse';
      145 : ch := 'du lièvre';
      146 : ch := 'de la guède';
      147 : ch := 'du noisetier';
      148 : ch := 'du cyclamen';
      149 : ch := 'de la chélidoine';
      150 : ch := 'du traîneau';
          { Ventôse }
      151 : ch := 'du tussilage';
      152 : ch := 'du cornouiller';
      153 : ch := 'du violier';
      154 : ch := 'du troène';
      155 : ch := 'du bouc';
      156 : ch := 'de l''asaret';
      157 : ch := 'de l''alaterne';
      158 : ch := 'de la violette';
      159 : ch := 'du marsault';
      160 : ch := 'de la bêche';
      161 : ch := 'du narcisse';
      162 : ch := 'de l''orme';
      163 : ch := 'de la fumeterre';
      164 : ch := 'du vélar';
      165 : ch := 'de la chèvre';
      166 : ch := 'de l''épinard';
      167 : ch := 'du doronic';
      168 : ch := 'du mouron';
      169 : ch := 'du cerfeuil';
      170 : ch := 'du cordeau';
      171 : ch := 'de la mandragore';
      172 : ch := 'du persil';
      173 : ch := 'du cochléaria';
      174 : ch := 'de la pâquerette';
      175 : ch := 'du thon';
      176 : ch := 'du pissenlit';
      177 : ch := 'de la sylvie';
      178 : ch := 'du capillaire';
      179 : ch := 'du frêne';
      180 : ch := 'du plantoir';
          { Germinal }
      181 : ch := 'de la primevère';
      182 : ch := 'du platane';
      183 : ch := 'de l''asperge';
      184 : ch := 'de la tulipe';
      185 : ch := 'de la poule';
      186 : ch := 'de la blette';
      187 : ch := 'du bouleau';
      188 : ch := 'de la jonquille';
      189 : ch := 'de l''aulne';
      190 : ch := 'du couvoir';
      191 : ch := 'de la pervenche';
      192 : ch := 'du charme';
      193 : ch := 'de la morille';
      194 : ch := 'du hêtre';
      195 : ch := 'de l''abeille';
      196 : ch := 'de la laitue';
      197 : ch := 'du mélèze';
      198 : ch := 'de la ciguë';
      199 : ch := 'du radis';
      200 : ch := 'de la ruche';
      201 : ch := 'du gainier';
      202 : ch := 'de la romaine';
      203 : ch := 'du marronnier';
      204 : ch := 'de la roquette';
      205 : ch := 'du pigeon';
      206 : ch := 'du lilas';
      207 : ch := 'de l''anémone';
      208 : ch := 'de la pensée';
      209 : ch := 'de la myrtille';
      210 : ch := 'du greffoir';
          { Floréal }
      211 : ch := 'de la rose';
      212 : ch := 'du chêne';
      213 : ch := 'de la fougère';
      214 : ch := 'de l''aubépine';
      215 : ch := 'du rossignol';
      216 : ch := 'de l''ancolie';
      217 : ch := 'du muguet';
      218 : ch := 'du champignon';
      219 : ch := 'de la jacinthe';
      220 : ch := 'du rateau';
      221 : ch := 'de la rhubarbe';
      222 : ch := 'du sainfoin';
      223 : ch := 'du bâton-d''or';
      224 : ch := 'du chamérisier';
      225 : ch := 'du ver à soie';
      226 : ch := 'de la consoude';
      227 : ch := 'de la pimprenelle';
      228 : ch := 'de la corbeille-d''or';
      229 : ch := 'de l''arroche';
      230 : ch := 'du sarcloir';
      231 : ch := 'du statice';
      232 : ch := 'de la fritillaire';
      233 : ch := 'de la bourrache';
      234 : ch := 'de la valériane';
      235 : ch := 'de la carpe';
      236 : ch := 'du fusain';
      237 : ch := 'de la civette';
      238 : ch := 'de la buglosse';
      239 : ch := 'du sénevé';
      240 : ch := 'de la houlette';
          { Prairial }
      241 : ch := 'de la luzerne';
      242 : ch := 'de l''hémérocalle';
      243 : ch := 'du trèfle';
      244 : ch := 'de l''angélique';
      245 : ch := 'du canard';
      246 : ch := 'de la mélisse';
      247 : ch := 'du fromental';
      248 : ch := 'du martagon';
      249 : ch := 'du serpolet';
      250 : ch := 'de la faux';
      251 : ch := 'de la fraise';
      252 : ch := 'de la bétoine';
      253 : ch := 'du pois';
      254 : ch := 'de l''acacia';
      255 : ch := 'de la caille';
      256 : ch := 'de l''œillet';
      257 : ch := 'du sureau';
      258 : ch := 'du pavot';
      259 : ch := 'du tilleul';
      260 : ch := 'de la fourche';
      261 : ch := 'du barbeau';
      262 : ch := 'de la camomille';
      263 : ch := 'du chèvrefeuille';
      264 : ch := 'du caille-lait';
      265 : ch := 'de la tanche';
      266 : ch := 'du jasmin';
      267 : ch := 'de la verveine';
      268 : ch := 'du thym';
      269 : ch := 'de la pivoine';
      270 : ch := 'du chariot';
          { Messidor }
      271 : ch := 'du seigle';
      272 : ch := 'de l''avoine';
      273 : ch := 'de l''oignon';
      274 : ch := 'de la véronique';
      275 : ch := 'du mulet';
      276 : ch := 'du romarin';
      277 : ch := 'du concombre';
      278 : ch := 'de l''échalotte';
      279 : ch := 'de l''absinthe';
      280 : ch := 'de la faucille';
      281 : ch := 'de la coriandre';
      282 : ch := 'de l''artichaut';
      283 : ch := 'de la giroflée';
      284 : ch := 'de la lavande';
      285 : ch := 'du chamois';
      286 : ch := 'du tabac';
      287 : ch := 'de la groseille';
      288 : ch := 'de la gesse';
      289 : ch := 'de la cerise';
      290 : ch := 'du parc';
      291 : ch := 'de la menthe';
      292 : ch := 'du cumin';
      293 : ch := 'du haricot';
      294 : ch := 'de l''orcanète';
      295 : ch := 'de la pintade';
      296 : ch := 'de la sauge';
      297 : ch := 'de l''ail';
      298 : ch := 'de la vesce';
      299 : ch := 'du blé';
      300 : ch := 'de la chalémie';
          { Thermidor }
      301 : ch := 'de l''épautre';
      302 : ch := 'du bouillon-blanc';
      303 : ch := 'du melon';
      304 : ch := 'de l''ivraie';
      305 : ch := 'du bélier';
      306 : ch := 'de la prèle';
      307 : ch := 'de l''armoise';
      308 : ch := 'du carthame';
      309 : ch := 'de la mûre';
      310 : ch := 'de l''arrosoir';
      311 : ch := 'du panis';
      312 : ch := 'du salicor';
      313 : ch := 'de l''abricot';
      314 : ch := 'du basilic';
      315 : ch := 'de la brebis';
      316 : ch := 'de la guimauve';
      317 : ch := 'du lin';
      318 : ch := 'de l''amande';
      319 : ch := 'de la gentiane';
      320 : ch := 'de l''écluse';
      321 : ch := 'de la carline';
      322 : ch := 'du câprier';
      323 : ch := 'de la lentille';
      324 : ch := 'de l''aunée';
      325 : ch := 'de la loutre';
      326 : ch := 'de la myrte';
      327 : ch := 'du colza';
      328 : ch := 'du lupin';
      329 : ch := 'du coton';
      330 : ch := 'du moulin';
          { Fructidor }
      331 : ch := 'de la prune';
      332 : ch := 'du millet';
      333 : ch := 'du lycoperdon';
      334 : ch := 'de l''escourgeon';
      335 : ch := 'du saumon';
      336 : ch := 'de la tubéreuse';
      337 : ch := 'du sucrion';
      338 : ch := 'de l''apocyn';
      339 : ch := 'de la réglisse';
      340 : ch := 'de l''échelle';
      341 : ch := 'de la pastèque';
      342 : ch := 'du fenouil';
      343 : ch := 'de l''épine-vinette';
      344 : ch := 'de la noix';
      345 : ch := 'de la truite';
      346 : ch := 'du citron';
      347 : ch := 'de la cardère';
      348 : ch := 'du nerprun';
      349 : ch := 'du tagette';
      350 : ch := 'de la hotte';
      351 : ch := 'de l''églantier';
      352 : ch := 'de la noisette';
      353 : ch := 'du houblon';
      354 : ch := 'du sorgho';
      355 : ch := 'de l''écrevisse';
      356 : ch := 'de la bagarade';
      357 : ch := 'de la verge-d''or';
      358 : ch := 'du maïs';
      359 : ch := 'du marron';
      360 : ch := 'du panier';
          { jour complémentaire }
      361 : ch := 'de la vertu';
      362 : ch := 'du génie';
      363 : ch := 'du travail';
      364 : ch := 'de l''opinion';
      365 : ch := 'des récompenses';
      366 : ch := 'de la révolution';
   end; { case }
   fete_du_jour := 'jour ' + ch;
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
  les jours complémentaires).
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
      date.jour := 0;

   if n >= 4 then
      date.mois := 10 * (ord(ch[n-3]) - ord('0')) + ord(ch[n-2]) - ord('0')
   else if n = 3 then
      date.mois := ord(ch[n-2]) - ord('0')
   else
      date.mois := 0;

   date.an   := 0;
   for i := 1 to n - 4 do
      date.an := 10 * date.an + ord(ch[i]) - ord('0');

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
   if date.mois < 1
      then begin
         ver    := false;
         erreur := 'mois zéro incorrect';
      end
   else if date.mois > 13
      then begin
         ver    := false;
         erreur := Dec2Numb(date.mois, 2, 10) + ' : mois incorrect, doit être ≤ 12 pour un mois normal, = 13 pour les jours complémentaires';
      end
   else if date.jour < 1
      then begin
         ver    := false;
         erreur := 'jour zéro incorrect';
      end
   else if (date.jour > 30) and (date.mois < 13)
      then begin
         ver    := false;
         erreur :=  Dec2Numb(date.jour, 2, 10) + ' : jour incorrect, doit être ≤ 30';
      end
   else if (date.jour > 6) and (date.mois = 13)
      then begin
         ver    := false;
         erreur := Dec2Numb(date.jour, 1, 10) + ' : jour complémentaire incorrect, doit être ≤ 6';
      end
   else if date.an < 1
      then begin
         ver    := false;
         erreur := 'impossible de traiter une date antérieure au début du calendrier républicain';
      end;
   verif_rep:=ver;
end;

{ Contrôle de cohérence des éléments de la date grégorienne. }
function verif_greg(date : Tdate; var erreur: string): boolean;
var
   ver : boolean;
begin
   ver    := true;
   erreur := '';
   if date.mois < 1
      then begin
         ver    := false;
         erreur := 'mois zéro incorrect';
      end
   else if date.mois > 12
      then begin
         ver    := false;
         erreur := Dec2Numb(date.mois, 2, 10) + ' : mois incorrect, doit être ≤ 12';
      end
   else if date.jour < 1
      then begin
         ver    := false;
         erreur := 'jour zéro incorrect';
      end
   else if (date.mois in [4, 6, 9, 11]) and (date.jour > 30)
      then begin
         ver    := false;
         erreur := Dec2Numb(date.jour, 2, 10) + ' : jour incorrect pour un mois à 30 jours';
      end
   else if (date.mois <> 2) and (date.jour > 31)
      then begin
         ver    := false;
         erreur := Dec2Numb(date.jour, 2, 10) + ' : jour incorrect pour un mois à 31 jours';
      end
   else if (date.mois = 2) and  (date.jour > 28 + bissex(date.an))
      then begin
         ver    := false;
         erreur := Dec2Numb(date.jour, 2, 10) + ' : jour incorrect pour février';
      end
   else if (10000 * date.an + 100 * date.mois + date.jour) < 17920922
      then begin
         ver    := false;
         erreur := 'impossible de traiter une date antérieure au 22 septembre 1792';
      end;
   verif_greg := ver;
end;

procedure aff_rep(date:tdate);
begin
   write(jour_decade(date), ' ', date.jour:2);
   case date.mois of
      1 : write(' Vendémiaire ');
      2 : write(' Brumaire ');
      3 : write(' Frimaire ');
      4 : write(' Nivôse ');
      5 : write(' Pluviôse ');
      6 : write(' Ventôse ');
      7 : write(' Germinal ');
      8 : write(' Floréal ');
      9 : write(' Prairial ');
     10 : write(' Messidor ');
     11 : write(' Thermidor ');
     12 : write(' Fructidor ');
     13 : write(' jour complémentaire ');
   end; 
   if date.an < 4000 then
      write(IntToRoman(date.an))
   else
      write(date.an:4);
   write(', ', fete_du_jour(date));
   writeln;
end;

procedure affgreg(date:tdate);
begin
write(jour_semaine(date), ' ', date.jour:2);
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
      writeln('5 : utilisation de la règle astronomique des équinoxes');
      writeln('6 : utilisation de la règle arithmétique de Romme');
   end;
   if demo
      then    n := 1
      else    read(n)
         until (n >= 0) and (n <= 6);
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
writeln('À partir de l''an XX (1811) vous avez le choix entre l''algorithme arithmétique ');
writeln('de Gilbert Romme ou l''algorithme astronomique basé sur l''équinoxe d''automne.');
writeln('Utilisez le paramètre "-e" ou "-a" pour choisir l''un ou l''autre. Par exemple, ');
writeln('pour obtenir les deux conversions possibles du premier janvier 2000, astronomique');
writeln('puis arithmétique, tapez :');
writeln('       calfr -e -g20000101 -a -g20000101');
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
writeln('       quintidi 5 jour complémentaire CXCI, jour des récompenses');
writeln('{ De nouveau, voici le menu : }');
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
         aff_rep(daterep);
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
         daterep := greg_rep(dategreg);
         affgreg(dategreg);
         aff_rep(daterep);
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
   debut := vnd1(annee);
   fin   := vnd1(annee+1);
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

   vnd1 := @regle_Romme;
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
   verbeux   := true;
   c := #0;
   repeat
      c := getlongopts('r:g:c:eal' , @theopts[1], optionindex);
      case c of
        #0 : begin
           case optionindex of
             1 : convrepgreg(decode_aaaammjj(optarg)) ;
             2 : convgregrep(decode_aaaammjj(optarg)) ;
             3 : calend(Numb2Dec(optarg, 10));
             4 : vnd1 := @equinoxe;
             5 : vnd1 := @regle_Romme;
             6 : verbeux := false;
           end;
        end;   
        'r': convrepgreg(decode_aaaammjj(optarg)) ;
        'g': convgregrep(decode_aaaammjj(optarg)) ;
        'c': calend(Numb2Dec(optarg, 10));
        'e': vnd1 := @equinoxe;
        'a': vnd1 := @regle_Romme;
        'l': verbeux := false;
        '?' , ':' : writeln('Erreur avec l''option : ', optopt);
      end ; { case }
   until c = endofoptions;
   if mode_dial then
      repeat
         action := menu(false, verbeux);
         if action > 0
            then case action of
              1    : demonstration;
              2    : convrepgreg(demande_date(verbeux));
              3    : convgregrep(demande_date(verbeux));
              4    : calend(demande_annee('année ? (n''oubliez pas de positionner le papier en début de page) ', verbeux));
              5    : begin
                        if verbeux then
                           writeln('Règle astronomique des équinoxes');
                        vnd1 := @equinoxe;
                     end;
              6    : begin
                        if verbeux then
                           writeln('Règle arithmétique de Romme');
                        vnd1 := @regle_Romme;
                     end;
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

=head2 Preliminary Note

The documentation  uses the  word I<décade> (the  first "e"  having an
acute  accent). This  French word  is  I<not> the  translation of  the
English  word  "decade"  (ten-year  period).  It  means  a  ten-I<day>
period.

For  your  information, the  French  word  for  a ten-year  period  is
I<décennie>.

=head2 Historical Description

The Revolutionary calendar was in  use in France from 24 November 1793
(4 Frimaire  II) to 31  December 1805 (10  Nivôse XIV). An  attempt to
apply  the  decimal rule  (the  basis of  the  metric  system) to  the
calendar. Therefore, the week  disappeared, replaced by the décade. In
addition, all months have exactly 3 decades, no more, no less.

At first,  the year was  beginning on the  equinox of autumn,  for two
reasons.  First, the  republic had  been established  on  22 September
1792, which  happened to be the  equinox, and second,  the equinox was
the symbol of equality, the day and the night lasting exactly 12 hours
each. It  was therefore  in tune with  the republic's  motto "Liberty,
Equality, Fraternity". But  it was not practical, so  Romme proposed a
leap year rule similar to the Gregorian calendar rule.

In his book I<The French Revolution>, the XIXth century writer Thomas
Carlyle proposes these translations for the month names:

=over 4

=item Vendémiaire -> Vintagearious

=item Brumaire -> Fogarious

=item Frimaire -> Frostarious

=item Nivôse -> Snowous

=item Pluviôse -> Rainous

=item Ventôse -> Windous

=item Germinal -> Buddal

=item Floréal -> Floweral

=item Prairial -> Meadowal

=item Messidor -> Reapidor

=item Thermidor -> Heatidor

=item Fructidor -> Fruitidor

=back

Each month has  a duration of 30 days. Since a  year lasts 365.25 days
(or so), five  additional days (or six on leap  years) are added after
Fructidor. These days  are called I<Sans-Culottides>.  For programming
purposes, they are  considered as a 13th month  (much shorter than the
12 others).

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
Revolutionary year. For example use  C<--calend=1792> for year  I, use
C<--calend=2017> for year CCXXVI.

=item equinox

Option without value. Use the equinox rule: the 1st Vendémiaire (first
day of the year) must coincide with the automn equinox.

=item arithm

Option without value. Use the  arithmetic rule: starting with year XX,
leap years in the French  Revolutionary calendar are determined with a
set of modulo rules similar to the Gregorian calendar.

Yet, before year XX, the equinox rule is in effect.

By default, the program uses Gilbert Romme's arithmetic rule.

=item laconique

Without this  option, if  no C<repub>, no  C<gregor> and  no C<calend>
parameters are given, the program  runs in dialog mode, prompting user
for input and  writing the result. With this  option, the program runs
in "Unix  pipeline mode",  taking values from  the standard  input and
writing the results  to the standard output.  The  difference with the
dialog mode is that the program does not prompt for input values.

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

Select the arithmetic (Romme) rule.

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

The equinox  rule has been generated  for 6 millenia to  coincide with
Reingold and Dershowitz's I<Calendar  Calculations>. But actually, the
algorithm used in I<Calendar Calculations> is reliable, I think, for a
few centuries, but not for several millenia. Only I do not know when I
should stop computing autumn equinoxes.

Even the arithmetic rule has limits. 6 millenia is a very long time in
human History.  There will be several  calendar reforms in the  next 6
millenia, just as there has been  several calendar reforms in the past
6 millenia, since the end of prehistory and the beginning of History.

Anyhow, if  you really  want to  examine the  very distant  future, be
aware that there will be a numeric rollover after Gregorian year 32767
(French Revolutionary year 30976). I see no real reason to fix a known
bug  that will  strike  in 28  millenia, long  after  other bugs  have
striken.

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

L<https://metacpan.org/pod/Date::Converter>

French Calendar for Android at
L<https://f-droid.org/packages/ca.rmen.android.frenchcalendar/>
or L<https://github.com/caarmen/FRCAndroidWidget>
and L<https://github.com/caarmen/french-revolutionary-calendar>

Thermidor for Android at L<https://github.com/jhbadger/Thermidor-Android>

A Ruby program at L<https://github.com/jhbadger/FrenchRevCal-ruby>

=head2 Books

Quid 2006, M and D Frémy, publ. Robert Laffont, page 341.

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

(C)  Jean Forget,  1983, 1984,  2018, 2019  all rights  reserved. This
program is  free software. You  can distribute, modify,  and otherwise
mangle this program under the same terms as perl 5.16.3.

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
