  PGM        &APPLIB

    /*-- PARAMETER - LIBRARY TO CONTAIN LOG SYSTEM:  --------------------*/
       DCL        &APPLIB      *CHAR    10
    /*--*TEST COMMIT */
       CRTDTAARA  &APPLIB/CBX902D       *DEC    10   VALUE( 0 )
       MONMSG     MSGID(CPF0000)

       CRTJRNRCV  &APPLIB/CBXJRN0001    THRESHOLD( 1000000 )
       MONMSG     MSGID(CPF0000)

       CRTJRN     &APPLIB/CBXJRN        +
                       &APPLIB/CBXJRN0001    +
                       MNGRCV( *SYSTEM )     +
                       RCVSIZOPT( *MAXOPT2 )
       MONMSG     MSGID(CPF0000)

       CRTPF      &APPLIB/CBX902FF                 +
                       SRCFILE( &APPLIB/SEGSRC )       +
                       SIZE( 2000000 )
       MONMSG     MSGID(CPF0000)

       CRTPF      &APPLIB/CBXDTAF                  +
                       SRCFILE( &APPLIB/SEGSRC )
       MONMSG     MSGID(CPF0000)


       STRJRNPF   &APPLIB/CBX902F                  +
                       &APPLIB/CBXJRN                   +
                       IMAGES( *BOTH )                  +
                       OMTJRNE( *OPNCLO )
    /* MONMSG     MSGID(CPF0000)    */


  ENDPGM
