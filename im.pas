{ intermod program     by j0e Stevens }

const
   max_no_of_freqs        = 100;
   format_list            = ' ####.####  #########        ####.####  #########';
   format_list_short      = ' ####.####  #########';

   title_2f_result        = '  Freq A     Freq B     A B diff   IM prod    Recv Freq  Difference';
   format_2f_result       = ' ####.####  ####.####  ####.####  ####.####  ####.####  ####.###';
   format_2f_comment      = ' #########  #########                        #########          ';

   title_3f_result        = '  Freq A     Freq B     Freq C     IM prod    Recv Freq  Difference';
   format_3f_result       = ' ####.####  ####.####  ####.####  ####.####  ####.####  ####.###';
   format_3f_comment      = ' #########  #########  #########             #########';

   title_harmonic_result  = '  Freq A     Harmonic  Recv Freq  Difference';
   format_harmonic_result = ' ####.####  ####.####  ####.####  #.####';
   format_harmonic_comment= ' #########             #########';

   format_summary         = '####.####  ###########  ###  ###         ####.####  @@@@@@@@###  ###  ###';
   format_comment         = '########';

var
   tx_file, rx_file, output_file : text;

   tx_freq, rx_freq : array[1..max_no_of_freqs] of real;

   tx_comment, rx_comment : array[1..max_no_of_freqs] of string[9];

   a_index, b_index, c_index, d_index, no_rx_freqs, no_tx_freqs,
   times_a, times_b, title  : integer;

   result_tf_2, result_rf_2,
   result_tf_3, result_rf_3,
   result_tf_5, result_rf_5 : array[1..max_no_of_freqs] of integer;

   print_2_3_decision, print_2_5_decision, print_3_3_decision,
   print_details, print_title : boolean;

   tally, a, df, max_apart : real;

   answer : char;
{=============================================================================}

procedure list_a_line_of_tx_rx_frequencies;
begin
  if rx_freq[a_index] = 0. then
    writeln (output_file,
      tx_freq[a_index]:9:4,
      tx_comment[a_index]:11
      )
  else
    writeln (output_file,
      tx_freq[a_index]:9:4,
      tx_comment[a_index]:11,
      rx_freq[a_index]:17:4,
      rx_comment[a_index]:11
      );
end;


{=============================================================================}
procedure two_freq;
begin {1}
title := 0;
for a_index :=  1 to no_tx_freqs do
  begin  {2}
    for b_index := 1 to no_tx_freqs do
      begin  {3}
        if (  ( tx_comment[a_index] = tx_comment[b_index] )
         or   ( a_index = b_index )      { dont compare a frequency to itself }
          )
        then
       else
         begin  {4}

     { calculate the intermod product }
         a := abs((times_a * tx_freq [a_index]) - (times_b * tx_freq [b_index]));

     { then compare it to the list of receive frequencies }
             for c_index := 1 to no_rx_freqs do
               begin  {5}
                 tally:=tally+1;

                 if (abs(a-rx_freq[c_index]) > df)   { df specified by user }
     { dont compare if the comments are the same }
                   or (tx_comment[b_index] = rx_comment[c_index])
                   or (tx_comment[a_index] = rx_comment[c_index])
                   or (abs(tx_freq[a_index]) - abs(rx_freq[c_index]) < 0.001)
                   or (abs(tx_freq[b_index]) - abs(rx_freq[c_index]) < 0.001)
                 then
                 else
                  begin {6}
                   if title = 0 then
                   writeln(output_file,title_2f_result);
                   title := 1;
                   writeln(output_file,
                                tx_freq[a_index]:9:4,
                                tx_freq[b_index]:11:4,
                                abs(tx_freq[a_index]-tx_freq[b_index]):11:4,
                                a:11:4,
                                rx_freq[c_index]:11:4,
                                abs(a-rx_freq[c_index]):11:4);
                   writeln(output_file,
                           tx_comment[a_index]:9,
                           tx_comment[b_index]:11,
                           rx_comment[c_index]:33);
                   writeln(output_file,'');
                  end; {6}
               end;  {5}
          end; {4}
      end;  {3}
    end; {2}
    if title = 0 then writeln(output_file,'-none');
end; {1}

{=============================================================================}
procedure harmonics;
begin {1}
title := 0;
for a_index :=  1 to no_tx_freqs do
  begin  {2}
     { calculate the harmonic }
         a := (tx_freq [a_index]) * times_a;

     { then compare it to the list of receive frequencies }
             for c_index := 1 to no_rx_freqs do
               begin  {5}

                 tally:=tally+1;
                 if (abs(a-rx_freq[c_index]) < df)   { df specified by user }
                 then
                  begin {6}
                   if title = 0 then
                   writeln(output_file,title_harmonic_result);
                   title := 1;
                   writeln(output_file,
                                tx_freq[a_index]:9:4,
                                a:11:4,
                                rx_freq[c_index]:11:4,
                                abs(a-rx_freq[c_index]):6:4);
                   writeln(output_file,
                           tx_comment[a_index]:9,
                           rx_comment[c_index]:24);
                   writeln(output_file,'');
                  end; {6}
               end;  {5}
    end; {2}
    if title = 0 then writeln(output_file,'-none');
end; {1}

{=============================================================================}

procedure three_freq;
begin {1}
title := 0;
for a_index :=  1 to no_tx_freqs-1 do
  begin  {2}
    for b_index := a_index+1 to no_tx_freqs do
      begin  {3}
        if (
              ( tx_comment[a_index] = tx_comment[b_index] )
         or   ( a_index = b_index )      { dont compare a frequency to itself }
                         { don't do frequencies more than 50 MHz apart }
         or   ( abs(tx_freq[a_index] - tx_freq[b_index]) > max_apart )
          )
        then
       else
         begin  {4}

          for c_index := 1 to no_tx_freqs do

         if (
              ( tx_comment[a_index] = tx_comment[c_index] )
           or ( tx_comment[b_index] = tx_comment[c_index] )
           or ( a_index = c_index )
           or ( b_index = c_index )
                        { don't do frequencies more than 50 MHz apart }
           or   ( abs(tx_freq[a_index] - tx_freq[b_index]) > max_apart )
            )
         then
         else
           begin {5}
     { calculate the intermod product }
         a := abs((1 * tx_freq [a_index]) +
                  (1 * tx_freq [b_index]) -
                  (1 * tx_freq [c_index]));

     { then compare it to the list of receive frequencies }
             for d_index := 1 to no_rx_freqs do
               begin  {6}
                 tally:=tally+1;

                 if (abs(a-rx_freq[d_index]) > df)   { df specified by user }

     { dont compare if the comments are the same }
                   or (tx_comment[a_index] = rx_comment[d_index])
                   or (tx_comment[b_index] = rx_comment[d_index])
                   or (tx_comment[c_index] = rx_comment[d_index])

     { dont compare if the Frequencies are the same }
                   or (abs(tx_freq[a_index]) - abs(rx_freq[d_index]) < 0.001)
                   or (abs(tx_freq[b_index]) - abs(rx_freq[d_index]) < 0.001)
                   or (abs(tx_freq[c_index]) - abs(rx_freq[d_index]) < 0.001)

                 then
                 else
                  begin {7}
                   if title = 0 then
                   writeln(output_file,title_3f_result);
                   title := 1;
                   writeln(output_file,
                                tx_freq[a_index]:9:4,
                                tx_freq[b_index]:11:4,
                                tx_freq[c_index]:11:4,
                                a:11:4,
                                rx_freq[d_index]:11:4,
                                abs(a-rx_freq[d_index]):11:4);
                   writeln(output_file,
                           tx_comment[a_index]:9,
                           tx_comment[b_index]:11,
                           tx_comment[c_index]:11,
                           rx_comment[d_index]:11);
                   writeln(output_file,'');
                  end; {7}
               end;  {6}
             end;  {5}
          end; {4}
      end;  {3}
    end; {2}
    if title = 0 then writeln(output_file,'-none');
end; {1}
{=============================================================================}



begin {1}       { begin main program }
   { writeln('All output from this version will go to a file named ',output_file);}
{ set matrices to zero }
          begin
             for a_index := 1 to max_no_of_freqs do
                  begin
                      tx_freq[a_index] := 0;
                      rx_freq[a_index] := 0;
                      tx_comment[a_index] := '';
                      rx_comment[a_index] := '';
                  end;
             end;

{ set all decisions to false }
             print_2_3_decision := false;
             print_2_5_decision := false;
             print_3_3_decision := false;
             print_details      := false;
             print_title        := false;


{ fill transmit frequency matrices }
          assign(tx_file, 'tfreqs');
          {$I-}
          reset(tx_file);
          {$I+}
          if IOresult <> 0 then
            begin
              writeln(' Cannot find input file "tfreqs"');
              halt;
            end
          else
            begin
              a_index := 1;
              while (not eof(tx_file)) do begin
                   read(tx_file, tx_freq[a_index], tx_comment[a_index]);
                   a_index := a_index + 1;
              end;
              close(tx_file);
              no_tx_freqs := a_index - 2;
            end;

{ fill receive frequency matrices }
          assign(rx_file, 'rfreqs');
          {$I-}
          reset(rx_file);
          {$I+}
          a_index := 1;
          if IOresult <> 0 then
            begin
              writeln(' Cannot find input file RFREQS');
              halt;
            end
          else
            begin
              while (not eof(rx_file)) do begin
                   read(rx_file, rx_freq[a_index], rx_comment[a_index]);
                   a_index := a_index + 1;
              end;
              close(rx_file);
              no_rx_freqs := a_index - 2;
            end;

{  setup where the output goes  }

  if paramstr(1) = '' then
      assign (output_file, 'con:')
    else
      begin
        assign (output_file, paramstr(1));
        rewrite (output_file);
      end;


{ get operating variables }
     df := 0;
     max_apart := 0;
     write  ('Enter max difference MHz for a hit to count [.049] - '); readln(df);
     if df = 0 then df := 0.049;
     write  ('Enter max apart in MHz for a comparison [50] - '); readln(max_apart);
     if max_apart = 0 then max_apart := 50;
{    write  ('Do you want detailed results?  (Y/N) '); readln(answer);
       if upcase(answer) = 'Y' then
         begin
     write  ('      of 2 signal, 3rd order?  (Y/N) '); readln(answer);
         if upcase(answer) = 'Y' then print_2_3_decision := true;
     write  ('      of 2 signal, 5th order?  (Y/N) '); readln(answer);
         if upcase(answer) = 'Y' then print_2_5_decision := true;
     write  ('      of 3 signal, 3rd order?  (Y/N) '); readln(answer);
         if upcase(answer) = 'Y' then print_3_3_decision := true;
         end;
}
{ print report heading }
     writeln(output_file,'=========================================================');
     writeln(output_file,' Intermod Study      program (c) 1996 Aksala Electronics ');

     writeln(output_file,'   Difference for hit = ',df:5:3,' MHz');

     writeln(output_file,'   Frequencies more than ',max_apart:3,' MHz apart not compared.');

     writeln(output_file,'');
     writeln(output_file,'  This is the list of frequencies for the study:');
     writeln(output_file,'');
          begin
               for a_index := 1 to no_tx_freqs do
               list_a_line_of_tx_rx_frequencies
          end;
     writeln(output_file,'');
     writeln(output_file,'  Transmitters  ',no_tx_freqs, '          Receivers   ',no_rx_freqs);
     writeln(output_file,'');
     writeln(output_file,'==========================================================');
     writeln(output_file,'');



writeln(output_file,'');
writeln(output_file,'===== Two Frequency, third-order tests:');
writeln(output_file,'');
times_a := 1;
times_b := 2;
tally   := 0;
two_freq;
{writeln(output_file,form('  Loops: ###,###.',tally));}


writeln(output_file,'');
writeln(output_file,'===== Two Frequency, fifth-order tests:');
writeln(output_file,'');
times_a := 2;
times_b := 3;
tally   := 0;
two_freq;
{writeln(output_file,form('  Loops: ###,###.',tally));}

writeln(output_file,'');
writeln(output_file,'===== Three Frequency, third-order tests:');
writeln(output_file,'');
tally   := 0;
three_freq;
if title = 0 then
  writeln(output_file,'-none');
{writeln(output_file,form('  Loops: ###,###,###.',tally));}

writeln(output_file,'');
writeln(output_file,'===== Second Harmonic Tests:');
writeln(output_file,'');
times_a := 2;
tally   := 0;
harmonics;
{writeln(output_file,form('  Loops: ###,###,###.',tally));}

writeln(output_file,'');
writeln(output_file,'===== Third Harmonic Tests:');
writeln(output_file,'');
times_a := 3;
tally   := 0;
harmonics;
{writeln(output_file,form('  Loops: ###,###,###.',tally));}

writeln(output_file,'');
writeln(output_file,'===== Fourth Harmonic Tests:');
writeln(output_file,'');
times_a := 4;
tally   := 0;
harmonics;
{writeln(output_file,form('  Loops: ###,###,###.',tally));}

writeln(output_file,'');
writeln(output_file,'===== Fifth Harmonic Tests:');
writeln(output_file,'');
times_a := 5;
tally   := 0;
harmonics;
{writeln(output_file,form('  Loops: ###,###,###.',tally));}

close(output_file);
end.  {1}

