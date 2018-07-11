     ?*===================================================================
     ?*Programa : CTRRDAING
     ?*Funcion  : Modifica435678e registros
     ?*Autor    : YUBER DOMINGUEZ RAMOS - ANA MARIA AGUDELO ÁLVAREZ
     ?*Fecha    : Febrero de 2018
     ?*===================================================================
     H DFTACTGRP(*NO)
      *---------------Definicion de Archivos
     FCTRDSDAINGCF   E             WorkStn
     F                                     IndDs(DsPantalla)
     D*---------------Definicion Variables Propias
     Dw_NomArch        S              8A
     Dw_Sec            S             10S 0 Inz(1)
     Dw_Archivo        S             10A
     Dw_Com            S              1A   Inz('''')
     Dw_Tabla          S             10A
     Dw_Val1           S             10A
     Dw_Val2           S             10A
     Dw_Val3           S              2S 0
     Dw_App            S              3A
     Dw_NumArch        S             10S 0 Inz(0)
     Dw_CantArchC      S             10A
     DwLibJobd         S             16A
     DNumArchivos      S            150A

     DVecApp           S              3    Dim(9) Ctdata
     DwInc             S              2S 0

      *Estructura Cursor*
     DCantidad         Ds
     Dw_CantArch                      3S 0

      *Estructura indicadores*
     DDsPantalla       Ds
     D F3Salir                         n   Overlay(DsPantalla:03)
     D F5Refrescar                     n   Overlay(DsPantalla:05)
     D F6Insertar                      n   Overlay(DsPantalla:06)
     D F7Editar                        n   Overlay(DsPantalla:07)
     D F8Eliminar                      n   Overlay(DsPantalla:08)

      *Programa para ejecutar comandos CL
     DRunClStm         Pr                  ExtPgm('QCMDEXC')
     DMdtoCl                       1000A   Const
     DLonCmd                         15P 5 Const
     D                 Ds
     DMdtoCl                       1000A
     DLonCmd                         15P 5 Inz(1000)
     D

      *Estructura dtaara control de ambientes
     DAmbDtaCtrl       ds            20    dtaara
     D Ambiente                       1    Overlay(AmbDtaCtrl:1)
     D Filler                        19    Overlay(AmbDtaCtrl:*Next)

      *Programa para sacar los campos de los archivos*
     DTiposDato        PR                  EXTPGM('CTRRCAMP')

      *Estructura Principal
      /Free
       // Se identifica el ambiente donde se ejecuta el programa
       In *Dtaara;

        Select;
          When Ambiente = 'D';
               wLibJobd = 'CTRLIBPR/CTRJOBD1';
          When Ambiente = 'Q' or  Ambiente = 'C';
               wLibJobd = 'CTRLIBPA/CTRJOBD';
        EndSl;

       F3Salir      = *Off;
       F5Refrescar  = *Off;
       F6Insertar   = *Off;
       F7Editar     = *Off;
       F8Eliminar   = *Off;

       DoW Not F3Salir;

        Write RSALIR;
        Exfmt RDATO1A;

        If F5Refrescar;
         F5Refrescar = *Off;
         PAPP     = *Blanks;
         PARCHIVO = *Blanks;
         PNUMREG  = *Zeros;
         PTODOS   = *Blanks;
        EndIf;

        For wInc =  1 To 9;
         w_App = VecApp(Winc);

         NumArchivos =
         'Select Count(*) From (Select Distinct(+
         WHFILE) From CTRFFCAMP Where WHFILE Like ' + w_Com + '%' +
         %Trim(w_App) + '%' + w_Com + ') As A';
         Exec SQL Declare NumArchivo Cursor For QryArch;
         Exec SQL Prepare QryArch From :NumArchivos;

         Exec SQL Open NumArchivo;
         Exec SQL Fetch NumArchivo Into :Cantidad;

         w_NumArch = w_NumArch + w_CantArch;
         Exec SQL Close NumArchivo;
        EndFor;

        If w_NumArch < 450;
         TiposDato();
        EndIf;


        If F6Insertar;
         F6Insertar   = *Off;
        If  (PTODOS = 'X' And PAPP <> *Blanks And PNUMREG <> *Zeros);
         w_NomArch = PAPP + 'FFAUT';

           DoW w_Sec <= 50;
            If w_Sec < 10;
             w_Archivo = %Trim(w_NomArch + '0' +  %Char(w_Sec));

             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRINSERT) PARM(' + w_Com + w_Archivo +
              w_Com + ' ' + w_Com + %Char(PNUMREG) + w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
            Else;
             w_Archivo = %Trim(w_NomArch + %Char(w_Sec));
             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRINSERT) PARM(' + w_Com + w_Archivo +
              w_Com + ' ' + w_Com + %Char(PNUMREG) + w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

             CallP RunClStm(MdtoCl:LonCmd);
             MdtoCl = 'DLYJOB DLY(1)';
             CallP(E)  RunClStm(MdtoCl:LonCmd);
             w_Archivo = *Blanks;
            EndIf;
            w_Sec = w_Sec + 1;
           EndDo;
           w_Sec = 1;
        Else;
          If (PARCHIVO <> *Blanks And PNUMREG <> *Zeros And PAPP <> *Blanks);
           Monitor;
            w_Val1 = %Trim(%Subst(PARCHIVO:4:5));
            w_Val2 = %Subst(PARCHIVO:9:2);
            w_Val3 = %Dec(w_Val2:2:0);

            If ((w_Val1 <> 'FFAUT') Or (w_Val3 > 50));
             Exfmt WNOEXISTE;
            Else;
             w_Archivo = PARCHIVO;

             Exec Sql
             Select Distinct(WHFILE) Into :w_Tabla
             From CTRFFCAMP
             Where WHFILE = :w_Archivo;

             If (SqlCode = *Zeros);
              MdtoCl =
              'SBMJOB CMD(CALL PGM(CTRRINSERT) PARM(' + w_Com + w_Archivo +
               w_Com + ' ' + w_Com + %Char(PNUMREG) + w_Com + ')) +
                JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
                LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
             Else;
              Exfmt WNOEXISTE;
             EndIf;

            EndIf;
           On-Error *All;
            Exfmt WNOEXISTE;
           EndMon;
          EndIf;
        EndIf;
        EndIf;

        If F7Editar;
         F7Editar = *Off;
        If  (PTODOS = 'X' And PAPP <> *Blanks);
         w_NomArch = PAPP + 'FFAUT';

           DoW w_Sec <= 50;
            If w_Sec < 10;
             w_Archivo = %Trim(w_NomArch + '0' +  %Char(w_Sec));

             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRUPDATE) PARM(' + w_Com + w_Archivo +
              w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
              w_Archivo = *Blanks;
            Else;
             w_Archivo = %Trim(w_NomArch + %Char(w_Sec));
             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRUPDATE) PARM(' + w_Com + w_Archivo +
              w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

             CallP RunClStm(MdtoCl:LonCmd);
             MdtoCl = 'DLYJOB DLY(1)';
             CallP(E)  RunClStm(MdtoCl:LonCmd);

             w_Archivo = *Blanks;
            EndIf;
            w_Sec = w_Sec + 1;
           EndDo;
           w_Sec = 1;

        Else;
          If (PARCHIVO <> *Blanks And PAPP <> *Blanks);
           Monitor;
            w_Val1 = %Trim(%Subst(PARCHIVO:4:5));
            w_Val2 = %Subst(PARCHIVO:9:2);
            w_Val3 = %Dec(w_Val2:2:0);

            If ((w_Val1 <> 'FFAUT') Or (w_Val3 > 50));
             Exfmt WNOEXISTE;
            Else;
             w_Archivo = PARCHIVO;

             Exec Sql
             Select Distinct(WHFILE) Into :w_Tabla
             From CTRFFCAMP
             Where WHFILE = :w_Archivo;

             If (SqlCode = *Zeros);
              MdtoCl =
              'SBMJOB CMD(CALL PGM(CTRRUPDATE) PARM(' + w_Com + w_Archivo +
               w_Com + ')) +
                JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
                LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
              PARCHIVO = *Blanks;
              PAPP     = *Blanks;
              PNUMREG  = *Zeros;
             Else;
              Exfmt WNOEXISTE;
             EndIf;

            EndIf;
           On-Error *All;
            Exfmt WNOEXISTE;
           EndMon;
          EndIf;
        EndIf;
        EndIf;

        If F8Eliminar;
         F8Eliminar = *Off;
        If  (PTODOS = 'X' And PAPP <> *Blanks);
         w_NomArch = PAPP + 'FFAUT';

           DoW w_Sec <= 50;
            If w_Sec < 10;
             w_Archivo = %Trim(w_NomArch + '0' +  %Char(w_Sec));

             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRDELETE) PARM(' + w_Com + w_Archivo +
              w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
              w_Archivo = *Blanks;
            Else;
             w_Archivo = %Trim(w_NomArch + %Char(w_Sec));
             MdtoCl =
             'SBMJOB CMD(CALL PGM(CTRRDELETE) PARM(' + w_Com + w_Archivo +
              w_Com + ')) +
               JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
               LOGCLPGM(*YES)';

             CallP RunClStm(MdtoCl:LonCmd);
             MdtoCl = 'DLYJOB DLY(1)';
             CallP(E)  RunClStm(MdtoCl:LonCmd);

             w_Archivo = *Blanks;
            EndIf;
            w_Sec = w_Sec + 1;
           EndDo;
           w_Sec = 1;

        Else;
          If (PARCHIVO <> *Blanks And PAPP <> *Blanks);
           Monitor;
            w_Val1 = %Trim(%Subst(PARCHIVO:4:5));
            w_Val2 = %Subst(PARCHIVO:9:2);
            w_Val3 = %Dec(w_Val2:2:0);

            If ((w_Val1 <> 'FFAUT') Or (w_Val3 > 50));
             Exfmt WNOEXISTE;
            Else;
             w_Archivo = PARCHIVO;

             Exec Sql
             Select Distinct(WHFILE) Into :w_Tabla
             From CTRFFCAMP
             Where WHFILE = :w_Archivo;

             If (SqlCode = *Zeros);
              MdtoCl =
              'SBMJOB CMD(CALL PGM(CTRRDELETE) PARM(' + w_Com + w_Archivo +
               w_Com + ')) +
                JOB(CTRRDAING) JOBD(' + wLibJobd + ') LOG(4 0 *SECLVL) +
                LOGCLPGM(*YES)';

              CallP RunClStm(MdtoCl:LonCmd);
              MdtoCl = 'DLYJOB DLY(1)';
              CallP(E)  RunClStm(MdtoCl:LonCmd);
              PARCHIVO = *Blanks;
              PAPP     = *Blanks;
              PNUMREG  = *Zeros;
             Else;
              Exfmt WNOEXISTE;
             EndIf;

            EndIf;
           On-Error *All;
            Exfmt WNOEXISTE;
           EndMon;
          EndIf;
        EndIf;
        EndIf;
         PAPP     = *Blanks;
         PARCHIVO = *Blanks;
         PTODOS   = *Blanks;
         PNUMREG  = *Zeros;
         w_Archivo = *Blanks;
         MdtoCl = 'DLYJOB DLY(1)';
         CallP(E)  RunClStm(MdtoCl:LonCmd);
       EndDo;

       *Inlr = *On;
      /End-Free

** CTDATA VecApp
SEG
CMS
PRI
PCC
WSE
STA
OPR
CTR
EDM
