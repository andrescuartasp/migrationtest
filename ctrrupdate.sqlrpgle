     ?*===================================================================
     ?*Programa : CTRRUPDATE
     ?*Funcion  : Edición de registros
     ?*Autor    : 23456 DOMINGUEZ RAMOS - ANA MARIA AGUDELO ÁLVAREZ
     ?*Fecha    : Marzo de 2018
     ?*===================================================================
     H DFTACTGRP(*NO)

     D*---------------Definicion Variables Propias
     Dw_Archivo        S             10A
     Dw_Com            S              1A   Inz('''')
     Dapp              S              3A
     DConsulta         S            150A
     DValidacion       S            150A
     Dw_Update         S           1021A
     Dw_TipDato        S             10A
     Dw_Caracteres     S           1021A
     Dw_Caracteres1    S           1021A
     Dw_Binario        S            600A
     Dw_Clob           S            600A
     Dw_Blob           S            600A
     Dw_Dbclob         S            600A
     Dw_Caracter       S            600A
     Dw_DecFloat       S            600A
     Dw_SmallInt       S            600A
     Dw_Integer        S            600A
     Dw_BigInt         S            600A
     Dw_Float          S            600A
     Dw_Real           S            600A
     Dw_Double         S            600A
     Dw_Graphic        S            600A
     Dw_Fecha          S             20A
     Dw_Numerico       S            600A
     Dw_Hora           S             20A
     Dw_TimeSt         S             20A
     Dw_ClobS          S              5S 0
     Dw_BlobS          S              5S 0
     Dw_SIntS          S              5S 0
     Dw_IntS           S              5S 0
     Dw_IntS1          S              5S 0
     Dw_VarCh          S              5S 0
     Dw_BIntS          S              5S 0
     Dw_BinS           S              5S 0
     Dw_DoubS          S              5S 0
     Dw_FloS           S              5S 0
     Dw_RealS          S              5S 0
     Dw_Long           S              5S 0
     Dw_Coma           S              5S 0
     Dw_Cont           S              5S 0
     Dw_Ban            S              5S 0  Inz(0)
     DValida           S              5S 0
     Dscript_Values    S           1021A
     Dscript_Values1   S           1021A


      *Estructura Cursor*
     DCampos           DS
     DPosDec                          2S 0
     Dw_Longitud                      5S 0
     DTipDato                         6A
     DNomCampo                       20A
     DDescrip                        80A

      *Definicion de Parametros de Entrada
     C     *Entry        PList
     C                   Parm                    w_Archivo
      *Estructura Principal
      /Free

        ConsulCampos();
        LlenarArchivo();
        w_Archivo = *Blanks;
        Script_Values = *Blanks;

       *Inlr = *On;
      /End-Free
     PConsulCampos...
     P                 B
      /FREE
       //Se obtienen los campos de la tabla

       Consulta =
       'Select WHFLDP, WHFLDB, WHFLDT, WHFLDI, WHCHD1 From CTRFFCAMP +
        WHERE WHFILE = '+ w_Com + %Trim(w_Archivo) + w_Com;

       Exec SQL Declare CurCampos Cursor For QryCampos;
       Exec SQL Prepare QryCampos From :Consulta;

       Exec SQL Open CurCampos;
       Exec SQL Fetch CurCampos Into :Campos;

       Dow ('1');
        If sqlCode <> *Zeros;
         Leave;
        EndIf;
        w_Long = *Zeros;
        If w_Ban = *Zeros;
         Validacion =
         'Select Count(*) From ' + w_Archivo + ' Where ' +
         %Trim(NomCampo) + ' Like '+ w_Com + '%1%' + w_Com;
         Exec SQL Declare CurVal Cursor For QryVal;
         Exec SQL Prepare QryVal From :Validacion;

         Exec SQL Open CurVal;
         Exec SQL Fetch CurVal Into :Valida;
         w_Ban = 1;
         If Valida <> *Zeros;
        w_Caracteres =
       '0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000+
        0000000000000000000000000000000000000000000000000000000000000000000000';
         Else;
        w_Caracteres =
       '1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111+
        1111111111111111111111111111111111111111111111111111111111111111111111';
         EndIf;
         Exec SQL Close CurVal;
        EndIf;
        LlenarScript();
        Exec SQL Fetch CurCampos Into :Campos;
       EndDo;
       Exec SQL Close CurCampos;
      /END-FREE
     PConsulCampos...
     P                 E

     PLlenarScript...
     P                 B
      /Free
       If w_Longitud > 4;
        w_Long = w_Longitud - 3;
       Else;
        w_Long = w_Longitud;
       EndIf;

       //Se llenan los campos que se van a insertar en el registro del archivo
       Select;
        When TipDato = '1';
         w_ClobS = %Scan('CLOB':Descrip);
         w_BlobS = %Scan('BLOB':Descrip);

         If w_Clobs <> *Zeros;
          w_Clob = %Trim(%Subst(w_Caracteres:1:2));
           Script_Values =%Trim( %Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + ' CLOB(' + %Trim(w_Clob)+ ')');
         EndIf;
         If w_BlobS <> *Zeros;
          w_Blob = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + ' BLOB(' + w_Com + %Trim(w_Blob) + w_Com + ')');
         EndIf;
        When TipDato = '3';
          w_DbClob = %Trim(%Subst(w_Caracteres:1:2));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + ' DBCLOB(' + %Trim(w_DbClob) + ')');
        When TipDAto = '4';
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + ' DEFAULT');
        When TipDato = '5';
         w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Binario) + w_Com);
        When TipDato = '6';
         If PosDec <> *Zeros;
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + '2.0');
         Else;
          w_DecFloat = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + 'DECFLOAT(' + w_Com + %Trim(w_DecFloat) + w_Com + ')');
         EndIf;
        When TipDato = '7';
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = DEFAULT');
        When TipDato = 'A';
         w_VarCh = %Scan('VARCHAR':Descrip);
         If (w_VarCh <> *Zeros) And (w_Long > 50);
          w_Long = 50;
         EndIf;
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Caracter) + w_Com);
        When TipDato = 'O';
         w_VarCh = %Scan('VARCHAR':Descrip);
         If (w_VarCh <> *Zeros) And (w_Long > 50);
          w_Long = 50;
         EndIf;
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Caracter) + w_Com);
        When TipDato = 'H';
         w_VarCh = %Scan('VARCHAR':Descrip);
         If (w_VarCh <> *Zeros) And (w_Long > 50);
          w_Long = 50;
         EndIf;
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Caracter) + w_Com);
        When TipDato = 'B';
         w_SIntS = %Scan('SMALLINT':Descrip);
         w_IntS  = %Scan('INTEGER':Descrip);
         w_BIntS = %Scan('BIGINT':Descrip);
         If (w_SIntS = *Zeros) And (w_BIntS = *Zeros) And (w_IntS = *Zeros);
          w_IntS1 = %Scan('INT':Descrip);
         EndIf;
         w_BinS  = %Scan('BIN':Descrip);

         If w_SIntS <> *Zeros;
          w_SmallInt = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + %Trim(w_SmallInt));
         EndIf;
         If (w_IntS <> *Zeros) Or (w_IntS1 <> *Zeros);
          w_Integer = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + 'INTEGER(' + %Trim(w_Integer) + ')');
         EndIf;
         If w_BIntS <> *Zeros;
          w_BigInt = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + 'BIGINT(' + %Trim(w_BigInt) + ')');
         EndIf;
         If w_BinS <> *Zeros;
          App = %Subst(w_Archivo:1:3);
          If (App <> 'SEG') And (App <> 'CMS') And (App <> 'PRI')
          And (App <> 'PCC');
            w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
            Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
            ' = ' + 'BINARY(' + %Trim(w_Binario) + ')');
          Else;
            w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
            Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
            ' = ' + %Trim(w_Binario));
          EndIf;
         EndIf;
        When TipDato = 'F';
         w_DoubS = %Scan('DOUBLE':Descrip);
         w_FloS  = %Scan('FLO':Descrip);
         w_RealS = %Scan('REAL':Descrip);

         If w_DoubS <> *Zeros;
          w_Double = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + 'DOUBLE(' + %Trim(w_Double) + ')');
         EndIf;
         If w_FloS <> *Zeros;
          w_Float = %Trim(%Subst(w_Caracteres:1:w_Long));
           Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
           ' = ' + %Trim(w_Float));
         EndIf;
         If w_RealS <> *Zeros;
          If PosDec <> *Zeros;
            Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
            ' = 2.0');
          Else;
           w_Real = %Trim(%Subst(w_Caracteres:1:w_Long));
            Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
            ' = ' + %Trim(w_Real));
          EndIf;
         EndIf;
        When TipDato = 'G';
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + 'DEFAULT');
        When TipDato = 'L';
         w_Fecha = %Trim(%Char(%Date()));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Fecha) + w_Com);
        When TipDato = 'P';
         w_Numerico = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + %Trim(w_Numerico));
        When TipDato = 'S';
         w_Integer = %Trim(%Subst(w_Caracteres:1:w_Long));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + %Trim(w_Integer));
        When TipDato = 'T';
         w_Hora = %Trim(%Char(%Time()));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_Hora)) + w_Com;
        When TipDato = 'Z';
         w_TimeSt = %Trim(%Char(%Timestamp()));
          Script_Values = %Trim(%Trim(Script_Values) + ', '+ %Trim(Nomcampo) +
          ' = ' + w_Com + %Trim(w_TimeSt)) + w_Com;
       EndSl;
      /End-Free
     PLlenarScript...
     P                 E


     PLlenarArchivo...
     P                 B
      /Free

       w_Coma = %Scan(',':Script_Values:1) + 1;
       Script_Values1 = %Trim(%Subst(Script_Values:w_Coma:1000));

       //Modifica los registros en el archivo
        w_Update=
        'Update ' + %Trim(w_Archivo) + ' ' + 'Set ' + %Trim(Script_Values1);
        Exec SQL Prepare Update From :w_Update;
        Exec SQL Execute Update;

      /End-Free
     PLlenarArchivo...
     P                 E
