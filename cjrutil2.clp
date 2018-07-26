/*********************************************************************/
/* ESTE PROGRAMA ES EL PROCESADOR DEL MANDATO DEL MISMO NOMBRE.      */
/* ESTE MANDATO DEVUELVE EL ESTADO ACTUAL DE UN TRABAJO.             */
/*-------------------------------------------------------------------*/
/* PARÁMETROS DE ENTRADA:                                            */
/* - JOB CHAR(26): NOMBRE CALIFICADO DEL TRABAJO (SIN SLASES)        */
/* PARÁMETRO DE SALIDA:                                              */
/* - STS CHAR(10):    DEVUELVE EL ESTADO. LOS VALORES POSIBLES SON:  */
/*                    *ERROR  SE HA PRODUCIDO UN ERROR DURANTE LA    */
/*                            EJECUCIÓN O EL TRABAJO CONSULTADO NO   */
/*                            SE HA ENCONTRADO.                      */
/*                    *JOBQ   EL TRABAJO AÚN NO SE HA INICIADO, ESTÁ */
/*                            ESPERANDO EN LA COLA DE TRABAJOS.      */
/*                    *OUTQ   EL TRABAJO YA HA FINALIZADO Y TIENE    */
/*                            LISTADOS PENDIENTES EN EL SPOOL.       */
/*                    *ACTIVE EL TRABAJO ESTÁ ACTIVO. ESTO INCLUYE   */
/*                            LOS TRABAJOS RETENIDOS, DESCONECTADOS, */
/*                            ETC.                                   */
/* - PILA CHAR(1702): DEVUELVE LA PILA DE PROGRAMAS DEL TRABAJO.     */
/*                    ES UNA LISTA QUE SE COMPONE DE LO SIGUIENTE:   */
/*                     - BIN(2)   NÚMERO DE ELEMENTOS DE LA LISTA    */
/*                     - CHAR(10) NOMBRE DEL PROGRAMA                */
/*                     - CHAR(10) BIBLIOTECA                         */
/*                       LOS DOS ÚLTIMOS ELEMENTOS SE REPITEN TANTAS */
/*                       VECES COMO SE INDIQUE EN BIN(2)             */
/*-------------------------------------------------------------------*/
/* NOTA: DEBE ESPECIFICARSE EL NOMBRE COMPLETO DE TRABAJO, NO SIRVE  */
/*       PARA LOCALIZAR UN TRABAJO SIN ESPECIFICAR EL USUARIO O EL   */
/*       NÚMERO DE TRABAJO.                                          */
/*-------------------------------------------------------------------*/
/* IMPORTANTE: ESTE PROGRAMA DEBE COMPILARLO UN USUARIO CON AUTORI-  */
/*             ZACIÓN *JOBCTL UTILIZANDO EL COMANDO:                 */
/*             CRTCLPGM PGM(BIBL/RTVJOBSTS) USRPRF(*OWNER)           */
/*                      LOG(*NO) AUT(*USE)                           */
/*********************************************************************/
             PGM        PARM(&JOB &STS &PILA)

             DCL        VAR(&JOB)  TYPE(*CHAR) LEN(26)
             DCL        VAR(&STS)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&PILA) TYPE(*CHAR) LEN(1702)

             DCL        VAR(&OUT)  TYPE(*CHAR) LEN(60)
             DCL        VAR(&LNG)  TYPE(*CHAR) LEN(4)
             DCL        VAR(&ERR)  TYPE(*CHAR) LEN(116)
             DCL        VAR(&INT)  TYPE(*CHAR) LEN(56)
             DCL        VAR(&STK)  TYPE(*CHAR) LEN(9999)

             DCL        VAR(&TOT)  TYPE(*DEC)  LEN(5 0)  VALUE(0)
             DCL        VAR(&OFF)  TYPE(*DEC)  LEN(5 0)  VALUE(0)
             DCL        VAR(&POS)  TYPE(*DEC)  LEN(5 0)  VALUE(0)
             DCL        VAR(&IND)  TYPE(*DEC)  LEN(5 0)  VALUE(1)
             DCL        VAR(&PGM)  TYPE(*CHAR) LEN(20)
             /* RECUPERAR EL ESTADO DEL TRABAJO */
             CHGVAR     VAR(&OUT)  VALUE(' ')
             CHGVAR     %BIN(&LNG) VALUE(60)
             CHGVAR     VAR(&ERR)  VALUE(X'0000011600000000')

             CALL       PGM(QWCRJBST) PARM(&OUT &LNG &JOB 'JOBS0300' +
                          &ERR)

             CHGVAR     VAR(&STS) VALUE(%SST(&OUT  9 10))
             MONMSG     MSGID(MCH3601) /* PARÁMETRO NO RECIBIDO */
              /* SI NO RECIBIÓ EL PARÁMETRO PILA O EL TRABAJO NO ESTÁ */
              /* ACTIVO, FINALIZAR LA EJECUCIÓN                       */
              CHGVAR     VAR(&PILA) VALUE(' ')
              MONMSG     MSGID(MCH3601) EXEC(GOTO CMDLBL(FIN))
              CHGVAR     %SST(&PILA 1 2) VALUE(X'0000')

              IF         COND(%SST(&OUT 9 10) *NE '*ACTIVE   ') +
                           THEN(GOTO CMDLBL(FIN))
             /* RECUPERAR LA PILA DE LLAMADAS */
              CHGVAR     VAR(&STK)  VALUE(' ')
              CHGVAR     %BIN(&LNG) VALUE(9999)
              CHGVAR     VAR(&ERR)  VALUE(X'0000011600000000')
              CHGVAR     VAR(%SST(&INT  1 10)) VALUE('*INT      ')
              CHGVAR     VAR(%SST(&INT 11 10)) VALUE('          ')
              CHGVAR     VAR(%SST(&INT 21  6)) VALUE('      ')
              CHGVAR     VAR(%SST(&INT 27 16)) VALUE(%SST(&OUT 19 16))
              CHGVAR     VAR(%SST(&INT 43  2)) VALUE(X'0000')
              CHGVAR     VAR(%SST(&INT 45  4)) VALUE(X'00000002')
             CHGVAR     VAR(%SST(&INT 49 8)) VALUE(X'0000000000000000')

              CALL       PGM(QWVRCSTK) PARM(&STK &LNG 'CSTK0100' &INT +
                           'JIDF0100' &ERR)
              /* CONSTRUIR LA LISTA DE PARES PROGRAMA BIBLIOTECA */
              CHGVAR     VAR(&OFF) VALUE(%BIN(&STK 13 4) + 1)
              CHGVAR     VAR(&TOT) VALUE(%BIN(&STK 17 4))

  BUCLE:      CHGVAR     VAR(&POS) VALUE(&OFF + 24)
              CHGVAR     VAR(&PGM) VALUE(%SST(&STK &POS 20))
              CHGVAR     VAR(&POS) VALUE(((&IND - 1) * 20) + 3)
              CHGVAR     VAR(%SST(&PILA &POS 20)) VALUE(&PGM)
              CHGVAR     VAR(&OFF) VALUE(&OFF + %BIN(&STK &OFF 4))

              IF         COND(&IND *LT &TOT *AND &IND *LT 85) THEN(DO)
                         CHGVAR     VAR(&IND) VALUE(&IND + 1)
                         GOTO       CMDLBL(BUCLE)
                         ENDDO

              CHGVAR     %BIN(&PILA 1 2) VALUE(&IND)

 FIN:        ENDPGM
