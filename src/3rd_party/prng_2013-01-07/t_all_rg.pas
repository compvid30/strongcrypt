{Simple test for all (c)PRNG, we 2008-2013}

program t_all_rg;

{$i STD.INC}

{$ifdef BIT16}
  {$N+}
{$endif}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifdef WINCRT}
uses wincrt;
{$endif}

uses
  {$ifdef WINCRT}
    wincrt,
  {$endif}
  {$ifndef nocrypt}
    aesr,
    salsar,
  {$endif}
  isaac,
  kiss123, mt19937, taus113, taus88, tt800, xor4096;
begin
  writeln('T_ALL_RG - C(PRNG) selftest results     (c) 2013 W.Ehrhardt');
{$ifndef nocrypt}
  writeln('    aesr: ',    aesr_selftest);
  writeln('  salsar: ',  salsar_selftest);
{$else}
  writeln('*** aesr/salsar not tested.');
{$endif}
  writeln('   isaac: ',   isaac_selftest);
  writeln(' kiss123: ', kiss123_selftest);
  writeln(' mt19937: ', mt19937_selftest);
  writeln(' taus113: ', taus113_selftest);
  writeln('  taus88: ',  taus88_selftest);
  writeln('   tt800: ',   tt800_selftest);
  writeln(' xor4096: ', xor4096_selftest);
end.
