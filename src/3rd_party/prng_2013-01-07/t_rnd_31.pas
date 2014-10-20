{Simple test for ISAAC unit, we July 2005}

program t_rnd_31;

{$i STD.INC}

{$ifdef BIT16}
  {$N+}
{$endif}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT}
     wincrt,
  {$else}
    crt,
  {$endif}
  isaac,ministat;

const
  NMAX = MaxLongint;
label
  _break;
var
  mx,sx,x,xmin,xmax: double;
  n: longint;
  stat: TStatX;
  rng: isaac_ctx;
begin
  writeln('Test program for ISAAC unit, mean/sdev of prng_double    (c) 2005 W.Ehrhardt');
  writeln('ISAAC selftest: ', isaac_selftest);
  writeln('       Count           Mean     12*SDev**2');
  stat1_init(stat);
  isaac_init(rng,1);
  xmin := 1E50;
  xmax :=-1E50;
  for n:=1 to NMAX do begin
    x := isaac_double(rng);
    stat1_add(stat,x);
    if x<xmin then xmin := x;
    if x>xmax then xmax := x;
    if n and $3FFFF = 0 then begin
      stat1_result(stat,mx,sx);
      if stat.Error<>0 then begin
        writeln('Ministat error: ',stat.Error);
        halt;
      end;
      writeln(n:12, mx:15:12, 12*sqr(sx):15:12,xmin:12, xmax:15:12);
      if keypressed and (readkey=#27) then goto _break;
    end;
  end;
_break:
  stat1_result(stat,mx,sx);
  writeln(stat.Nn:12, mx:15:12, 12*sqr(sx):15:12,xmin:12, xmax:15:12);
end.
