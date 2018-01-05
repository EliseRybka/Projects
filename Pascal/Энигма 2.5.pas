program ss;
var
f,h,x : text;
k1,k2,k3, b, s : string;
i, c,j,e,t: byte;
il, bl, kl, nl: integer;
al: real;
l,q1,m1,q2,m2,q3,m3,a,o,n:integer;
r1: array [1..32] of integer;
r2: array [1..32] of integer;
r3: array [1..32] of integer;
p1: array [1..32] of integer;
p2: array [1..32] of integer;
p3: array [1..32] of integer;
begin
assign(h, 'Coded text.txt');
rewrite(h);

writeln('Enter wiring from keyboard? (Y/N)');
readln(b);


if b='Y' then
begin
writeln;
writeln('Wiring of rotor 1: ');
readln(s);
for i:= 1 to 32 do begin
a:=word(s[i]);
r1[i]:=a;
end;

writeln;
writeln('Wiring of rotor 2: ');
readln(s);
for i:= 1 to 32 do begin
a:=word(s[i]);
r2[i]:=a;
end;

writeln;
writeln('Wiring of rotor 3: ');
readln(s);
for i:= 1 to 32 do begin
a:=word(s[i]);
r3[i]:=a;
end;

writeln;
Writeln('Location of the notches: ');
readln(e);
readln(t);

end;

if b='N' then
begin
assign(x, 'Encryption key.txt');
rewrite(x);
writeln(x,'Wiring of rotor 1: ');
r1[1]:=random(32)+1072;
  For l:=2 to 32 do
         begin
           repeat
             m1:=0;
             r1[l]:=random(32)+1072;
             for q1:=1 to l-1 do  if r1[l]=r1[q1] then m1:=1;
           until m1=0;
         end;
 For l:=1 to 32 do
   begin
     Write (x,char(r1[l]));
 end;

writeln(x);
writeln(x);
writeln(x,'Wiring of rotor 2: ');
r2[1]:=random(32)+1072;
  For l:=2 to 32 do
         begin
           repeat
             m2:=0;
             r2[l]:=random(32)+1072;
             for q2:=1 to l-1 do  if r2[l]=r2[q2] then m2:=1;
           until m2=0;
         end;
 For l:=1 to 32 do
   begin
     Write (x,char(r2[l]));
 end;
 
writeln(x);
writeln(x);
writeln(x,'Wiring of rotor 3: ');
r3[1]:=random(32)+1072;
  For l:=2 to 32 do
         begin
           repeat
             m3:=0;
             r3[l]:=random(32)+1072;
             for q3:=1 to l-1 do  if r3[l]=r3[q3] then m3:=1;
           until m3=0;
         end;
 For l:=1 to 32 do
   begin
     Write (x,char(r3[l]));
 end;
 
writeln(x);
writeln(x);

Randomize;
e:=random(32);
t:=random(32);
Writeln(x,'Location of the notches: ',e,' ',t);

close(x);
end;


writeln;
writeln('Enter position of rotor 1: ');
readln(k1);
while not(c=word(k1[1])-1072) do begin
 a:=r1[32];
 for l:=32 downto 2 do
 r1[l]:=r1[l-1]+1;
 r1[1]:=a+1;
 for l:=1 to 32 do
 if r1[l]>1103 then r1[l]:=r1[l]-32;
 c:=c+1;
end;



writeln;
writeln('Enter position of rotor 2: ');
readln(k2);
while not(c=word(k2[1])-1072) do begin
 a:=r2[32];
 for l:=32 downto 2 do
 r2[l]:=r2[l-1]+1;
 r2[1]:=a+1;
 for l:=1 to 32 do
 if r2[l]>1103 then r2[l]:=r2[l]-32;
 c:=c+1;
end;


writeln;
writeln('Enter position of rotor 3: ');
readln(k3);
while not(c=word(k3[1])-1072) do begin
 a:=r3[32];
 for l:=32 downto 2 do
 r3[l]:=r3[l-1]+1;
 r3[1]:=a+1;
 for l:=1 to 32 do
 if r3[l]>1103 then r3[l]:=r3[l]-32;
 c:=c+1;
end;



writeln;
writeln('Keep source formatting? (Y/N)');
readln(b);

writeln;
writeln('Enter number');
readln(bl);

assign(f, 'Source text.txt');
reset(f);
  while not eof(f) do
  begin
  readln(f,s);
  n:= length(s);
    for i:= 1 to n do
    begin
a:=word(s[i]);
if (a>1039) and (a<1072) then a:=a+32;
if (a=1025)or (a=1105) then a:=1077;

if (a>1071) and (a<1104) then
begin
 If e>=32 then begin
 o:=r2[32];
 for l:=32 downto 2 do
 r2[l]:=r2[l-1]+1;
 r2[1]:=o+1;
 for l:=1 to 32 do
 if r2[l]>1103 then r2[l]:=r2[l]-32;
 e:=0;
 t:=t+1
 end;
 
 if t>=33 then  begin
 o:=r3[32];
 for l:=32 downto 2 do
 r3[l]:=r3[l-1]+1;
 r3[1]:=o+1;
 for l:=1 to 32 do
 if r3[l]>1103 then r3[l]:=r3[l]-32;
 t:=0;
 end;
 
 o:=r1[32];
 for l:=32 downto 2 do
 r1[l]:=r1[l-1]+1;
 r1[1]:=o+1;
 for l:=1 to 32 do
 if r1[l]>1103 then r1[l]:=r1[l]-32;
 
if kl = 8 then begin
          repeat
            bl := bl + 1;
          until (round((sqrt(bl) * 10)) mod 10) <> 0;
          nl := 1;
          kl := 0;
        end;
        
if bl >= (maxint/2) then bl:=3;
 
al := sqrt(bl);
kl := kl + 1;
nl := nl * 10;
al := (round(al * nl) mod 10);
for il:=1 to round(al) + 1 do e:=e+1;
 
j:=a-1071;
a:=r1[j];

j:=a-1071;
a:=r2[j];

j:=a-1071;
a:=r3[j];

if a=1072 then a:=1100
else if a=1100 then a:=1072
else if a=1087 then a:=1095
else if a=1095 then a:=1087
else if a=1079 then a:=1082
else if a=1082 then a:=1079
else if a=1093 then a:=1103
else if a=1103 then a:=1093
else if a=1083 then a:=1097
else if a=1097 then a:=1083
else if a=1074 then a:=1073
else if a=1073 then a:=1074
else if a=1090 then a:=1101
else if a=1101 then a:=1090
else if a=1088 then a:=1084
else if a=1084 then a:=1088
else if a=1078 then a:=1092
else if a=1092 then a:=1078
else if a=1091 then a:=1085
else if a=1085 then a:=1091
else if a=1077 then a:=1086
else if a=1086 then a:=1077
else if a=1098 then a:=1102
else if a=1102 then a:=1098
else if a=1099 then a:=1081
else if a=1081 then a:=1099
else if a=1089 then a:=1096
else if a=1096 then a:=1089
else if a=1075 then a:=1080
else if a=1080 then a:=1075
else if a=1076 then a:=1094
else if a=1094 then a:=1076;

For l:=1 to 32 do begin
  p3[r3[l]-1071]:=l+1071;
  p2[r2[l]-1071]:=l+1071;
  p1[r1[l]-1071]:=l+1071;
end;

j:=a-1071;
a:=p3[j];

j:=a-1071;
a:=p2[j];

j:=a-1071;
a:=p1[j];

write(h,char(a));

end;

if (not(((a>1039) and (a<1072)) or (a=1025) or ((a>1071) and (a<1104)) or (a=1105))) and (b='Ä') then
write(h,char(a));
    end;
    writeln(h);
  end;
close(f);
close(h);
end.
