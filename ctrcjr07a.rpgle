      *----------------------------------------------------------------*
      *   AUTOR: CaRLOS Rojas  - 2018                                  *
      *----------------------------------------------------------------*
      * Crea archivo temporal de trabajo para el monitoreo de archivos *
      *----------------------------------------------------------------*
      ***************************************************************
       /Copy ctrlibpr/ctrSrc,CTRRCTRH01
        dcl-s  Tiempo    Zoned(4:0) inz(0);
        dcl-s  $source  Char(10);
        dcl-s  $ARC     Char(10);
        dcl-s  $pos     zoned(5) ;
        dcl-s  $long    zoned(5) ;
        dcl-s  $A       zoned(5) ;
        dcl-s  $B       zoned(5) ;
        dcl-s  $C       Char(10) ;
        dcl-s  $C1      Char(10) ;
        dcl-s  $D       Zoned(5) ;
        dcl-s  $E       zoned(5) ;
        dcl-s  $F       zoned(5) ;
        dcl-s  $G       zoned(5) ;
        dcl-s  REGLA    Char(10);
        dcl-s  NOVEDAD  Char(10);
               REGLA='*DHIS     ';
               $ARC ='SCIFFADHIS';
         // If NOVEDAD='TERMINA';
               $a=%len(%trim(REGLA))-1;
               $A=%len(%trim($ARC));
           $C=%subst(%trim(REGLA):2 :(%len(%trim(REGLA))-1));
           Regla=%subst(%trim(REGLA):2 :(%len(%trim(REGLA))-1));

           $C1=(%subst(%trim($ARC):(%len(%trim($ARC)) - %len(%trim($C))
             +1) :(%len(%trim($c)))));
           $C1=(%subst(%trim($ARC):(%len(%trim($ARC)) - %len(%trim(REGLA))
               ) :(%len(%trim(REGLA)))));
          //if %trim(REGLA)=
            if %trim(Regla)=
                 (%subst(%trim($ARC):(%len(%trim($ARC)) - %len(%trim(Regla))
               +1) :(%len(%trim(Regla)))));
               $B=1;
            endif;
           // Comienza   E.NOVEDAD, E.REGLA
               REGLA='SEG       ';
               $ARC ='SEGFFDEPR1';
         // If NOVEDAD='COMIENZA';
             if (%scan (%subst(%trim(REGLA):1:(%len(%trim(REGLA))-1))
               :(%trim($ARC))))=1;
                $B=1;
             Endif;
               $A=%scan (%subst(%trim(REGLA):1:(%len(%trim(REGLA))-1))
               :(%trim($ARC)));
               if $A=1;
                $B=1;
               endif;
        // endif;
               REGLA='STG*      ';
               $ARC ='SEGFFDEPR1';
               $A=0;
               $F=0;
         // If NOVEDAD='CONTIENE';
              IF (%scan (%subst(%trim(REGLA):1:(%len(%trim(REGLA))-1))
               :(%trim($ARC))))<>0;
                $B=1;
              Endif;
               $A=%scan (%subst(%trim(REGLA):1:(%len(%trim(REGLA))))
               :(%trim($ARC)));
               if $A<>0;
                $B=1;
               endif;
        // endif;
          //
               $A=%len(%trim($ARC));
               $B=%len(%trim(REGLA));
            // A=8
            // B=3
            // C=(A-B)+1
            // B=(%len(%trim($ARC)) - %len(%trim(REGLA))+ 1);
           //  D=:C :B
               $C=%subst(%trim($ARC):(%len(%trim($ARC)) - %len(%trim(REGLA))
               +1) :(%len(%trim(REGLA))));
           //                        + 1)
               $C=%subst(%trim($ARC):1 :$B);
               $B=$A-1;
               $G=%scan (%subst(%trim(REGLA):1:$F): %trim($ARC));
               $C=%subst(%trim(REGLA):1 :$B);
               $D=%scan (%subst(%trim(REGLA):1:$B): %trim($ARC));
               $A=%scan (%subst(%trim(REGLA):1:(%len(%trim(REGLA))))
               :(%trim($ARC)));
               if $A<>0;
                $B=1;
               endif;
        // endif;
               $A=%len(%trim(REGLA));
               $B=$A-1;
               $G=%scan (%subst(%trim(REGLA):1:$F): %trim($ARC));
               $C=%subst(%trim(REGLA):1 :$B);
               $D=%scan (%subst(%trim(REGLA):1:$B): %trim($ARC));
        // endif;
              // SAIM080111
              // SCIFFADHIS

                $ARC ='SAIM080111';
                $source = 'SCIFF      ';
                $long=%len($source);
                $long=%len(%trim($source));
            //  $source = 'AABC1ABD2AB3A';

                $ARC ='SAIM080111';
                $pos = %scan ($SOURCE: %trim($ARC));
           //   $pos = %scan ('IBM' : $source);
           //   $pos = %check ($SOURCE: %trim($ARC));
                $ARC ='SCIFFADHIS';
                $pos = %scan ($SOURCE: %trim($ARC));
                $pos = %scan (%subst($SOURCE:1:5): %trim($ARC));
                $pos = %scan (%subst($SOURCE:1:$long): %trim($ARC));
                $ARC ='SCIFDADHIS';
                $pos = %scan (%subst($SOURCE:1:5): %trim($ARC));
                $ARC ='SCIDDADHIS';
                $pos = %scan (%subst($SOURCE:1:5): %trim($ARC));
                $ARC ='SCIDFADHIS';
                $pos = %scan (%subst($SOURCE:1:5): %trim($ARC));
                $pos = %scan ($SOURCE: %trim($ARC));
           //   dsply $pos; //DSPLY      5

           //   $pos = %check ('ABCD' : %trim($source) :6);
           //   dsply $pos; //DSPLY      9

            //  $pos = %checkr ('ABCD' : %trim($source));
            //  dsply $pos; //DSPLY     12

           //   $pos = %checkr ('ABCD' : %trim($source) : 11);
           //      dsply $pos; //DSPLY      9

           *inlr = *on;
