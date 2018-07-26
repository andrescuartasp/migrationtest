      *---------------------Definicion Comandos de Compilaion
      * ACTGRP(*CALLER) USRPRF(*OWNER) AUT(*ALL)

      /If Defined(*CrtBndRpg)
     H DftActGrp (*No) ActGrp(*Caller)
      /EndIf

      *---------------------Directorio de Enlace para Uso de Api
     H BndDir('QC2LE')
     H DatEdit(*YMD) DatFmt(*Iso) TimFmt(*HMS) Aut(*All) AlwNull(*UsrCtl)
     H Option(*SrcStmt : *NoDebugIO) fixnbr(*Zoned)

      *---------------------Defincion de Variables
     D*ParNombreDTAQ    S             10A
     D*ParLibreriaDTAQ  S             10A
     D@WhFile          S             10

     DAmbDtaCtrl       ds            20    dtaara
     D Ambiente                       1    Overlay(AmbDtaCtrl:1)
     D Filler                        19    Overlay(AmbDtaCtrl:*Next)

     DVecApp           S              3    Dim(9) Ctdata
     DwInc             S              2S 0
     DwPos             S              2S 0
     DwArchivo         S             10
     DwLibreria        S             10
     DwLib             S              5

      *---------------------Defincion de Estructuras
     D                 Ds
     DMdtoCl                       1000A
     DLonCmd                         15P 5 Inz(1000)
     D ColaDatos       Ds
     D ParNombreDtaQR                10A
     D ParLibreriaR                  10A
     D ParLongitudR                   5P 0  Inz(30546)
     D ParDatosR                  30546A
     D ParEsperaR                     5P 0  Inz(-1)

      *---------------------Defincion de Procedimientos
     DQrcvDtaq         Pr                  ExtPgm('QRCVDTAQ')
     DParNombreDtaQR                 10A
     DParLibreriaR                   10A
     DParLongitudR                    5P 0
     DParDatosR                   30546A
     DParEsperaR                      5P 0
     DRunClStm         Pr                  ExtPgm('QCMDEXC')
     DMdtoCl                       1000A   Const
     DLonCmd                         15P 5 Const
     DObtieneListaCamposArchivo...
     D                 Pr
     C*--------------------------Programa Principal
      /Free
        In AmbDtaCtrl;
        If Ambiente = 'D';
         wLib = 'LIBPR';
        ElSe;
         wLib = 'LIBPA';
        EndIf;

        For wInc =  1 To 9;

          For wPos = 1 To 50;
           wArchivo = VecApp(Winc)+'FFAUT'+%Editc(wPos:'X');
           wLibreria= VecApp(Winc)+%Trim(wLib);
           ObtieneListaCamposArchivo();
          EndFor;

        EndFor;
       *InLr = '1';
      /End-Free
     C*-------------------------Fin Programa Principal

     C*-------------------------Procedimiento
     PObtieneListaCamposArchivo...
     P                 B
      /Free
        Clear @WhFile;
        //Valida que el archivo Exista en CTRFFCAMPO, sino crea adiciona
        Exec Sql SELECT WHFILE INTO :@WhFile FROM CTRFFCAMP  WHERE
                 WHFILE = :wArchivo AND WHLIB = :wLibreria
                 FETCH FIRST 1 ROW ONLY;
        If SqlCode <> 0;
         MdtoCl = 'DSPFFD  FILE(' + %Trim(wLibreria)  + '/' +
                   wArchivo         + ')' +
                  ' OUTPUT(*OUTFILE) OUTFILE(CTRFFCAMP) OUTMBR(*FIRST *ADD)';
         Monitor;
           RunClStm(MdtoCl:LonCmd);
         On-Error;
         EndMon;
        EndIf;
      /End-Free
     PObtieneListaCamposArchivo...
     P                 E
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
