     ?*===================================================================
     ?*Programa : CTRRINSERT
     ?*Funcion  : Inse34567 de registros
     ?*Autor    : YUBER DOMINGUEZ RAMOS - ANA MARIA AGUDELO ÁLVAREZ
     ?*Fecha    : Marzo de 2018
     ?*===================================================================
     H DFTACTGRP(*NO)

     D*---------------Definicion Variables Propias
     Dw_Archivo        S             10A
     Dapp              S              3A
     Dw_Com            S              1A   Inz('''')
     DConsulta         S             80A
     Dw_NumReg         S             16S 0 Inz(1)
     Dw_NumReg1        S             16S 0 Inz(1)
     DPNUMREG1         S             16A
     Dw_Insert         S           1021A
     Dw_TipDato        S             10A
     Dw_Caracteres     S           1021A
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
     Dw_VarCh          S              5S 0
     Dw_IntS1          S              5S 0
     Dw_BIntS          S              5S 0
     Dw_BinS           S              5S 0
     Dw_DoubS          S              5S 0
     Dw_FloS           S              5S 0
     Dw_RealS          S              5S 0
     Dw_Long           S              5S 0
     Dscript_Values    S           1021A


      *Estructura Cursor*
     DCampos           DS
     DPosDec                          2S 0
     Dw_Longitud                      5S 0
     DTipDato                         6A
     DDescrip                        20A

      *Definicion de Parametros de Entrada
     C     *Entry        PList
     C                   Parm                    w_Archivo
     C                   Parm                    PNUMREG1
      *Estructura Principal
      /Free
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

        ConsulCampos();
        If Script_Values <> *Blanks;
         LlenarArchivo();
        EndIf;
        w_Archivo = *Blanks;
        Script_Values = *Blanks;

       *Inlr = *On;
      /End-Free
     PConsulCampos...
     P                 B
      /FREE
       //Se obtienen los campos de la tabla

       Consulta =
       'Select WHFLDP, WHFLDB, WHFLDT, WHCHD1 From CTRFFCAMP +
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
          If Script_Values <> *Blanks;
           Script_Values =%Trim( %Trim(Script_Values) +
           ', CLOB(' + %Trim(w_Clob)+ ')');
          Else;
           Script_Values =
           %Trim('CLOB(' + %Trim(w_Clob) + ')');
          EndIf;
         EndIf;
         If w_BlobS <> *Zeros;
          w_Blob = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) +
           ', BLOB(' + w_Com + %Trim(w_Blob) + w_Com + ')');
          Else;
           Script_Values =
           %Trim('BLOB(' + w_Com + %Trim(w_Blob) + w_Com + ')');
          EndIf;
         EndIf;
        When TipDato = '3';
          w_DbClob = %Trim(%Subst(w_Caracteres:1:2));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ', DBCLOB(' + %Trim(w_DbClob) + ')');
         Else;
          Script_Values =
          %Trim('DBCLOB(' + %Trim(w_DbClob) + ')');
         EndIf;
        When TipDAto = '4';
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ', DEFAULT');
         Else;
          Script_Values = %Trim('DEFAULT');
         EndIf;
        When TipDato = '5';
          w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values)+
           ', ' + w_Com + %Trim(w_Binario) + w_Com);
          Else;
           Script_Values =
           %Trim(w_Com + %Trim(w_Binario) + w_Com);
          EndIf;
        When TipDato = '6';
        If PosDec <> *Zeros;
         If Script_Values <> *Blanks;
          Script_Values =%Trim( %Trim(Script_Values) + ', 1.0');
         Else;
          Script_Values = '1.0';
         EndIf;
        Else;
         w_DecFloat = %Trim(%Subst(w_Caracteres:1:w_Long));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
        ', DECFLOAT(' + w_Com + %Trim(w_DecFloat) + w_Com + ')');
         Else;
          Script_Values =
          %Trim('DECFLOAT('+ %Trim(w_DecFloat) + ')');
         EndIf;
        EndIf;
        When TipDato = '7';
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values)
          + ', DEFAULT');
         Else;
          Script_Values = %Trim('DEFAULT');
         EndIf;
        When TipDato = 'A';
         w_VarCh = %Scan('VARCHAR':Descrip);
         If (w_VarCh <> *Zeros) And (w_Long > 50);
          w_Long = 50;
         EndIf;
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ',' + w_Com + %Trim(w_Caracter) + w_Com);
         Else;
          Script_Values = %Trim(w_Com + %Trim(w_Caracter) + w_Com);
         EndIf;
        When TipDato = 'O';
         w_VarCh = %Scan('VARCHAR':Descrip);
         If (w_VarCh <> *Zeros) And (w_Long > 50);
          w_Long = 50;
         EndIf;
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ',' + w_Com + %Trim(w_Caracter) + w_Com);
         Else;
          Script_Values = %Trim(w_Com + %Trim(w_Caracter) + w_Com);
         EndIf;
        When TipDato = 'H';
         If w_Long > 100;
          w_Long= 100;
         EndIf;
         w_Caracter = %Trim(%Subst(w_Caracteres:1:w_Long));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ',' + w_Com + %Trim(w_Caracter) + w_Com);
         Else;
          Script_Values = %Trim(w_Com + %Trim(w_Caracter) + w_Com);
         EndIf;
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
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) +
           ', ' + %Trim(w_SmallInt));
          Else;
           Script_Values = %Trim(w_SmallInt);
          EndIf;
         EndIf;
         If (w_IntS <> *Zeros) Or (w_IntS1 <> *Zeros);
          w_Integer = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) +
           ', INTEGER(' + %Trim(w_Integer) + ')');
          Else;
           Script_Values = %Trim('INTEGER(' + %Trim(w_Integer) + ')');
          EndIf;
         EndIf;
         If w_BIntS <> *Zeros;
          w_BigInt = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) +
           ', BIGINT(' + %Trim(w_BigInt) + ')');
          Else;
           Script_Values = %Trim('BIGINT(' + %Trim(w_BigInt) + ')');
          EndIf;
         EndIf;
         If w_BinS <> *Zeros;
          App = %Subst(w_Archivo:1:3);
          If (App <> 'SEG') And (App <> 'CMS') And (App <> 'PRI')
          And (App <> 'PCC');
           w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
           If Script_Values <> *Blanks;
            Script_Values = %Trim(%Trim(Script_Values)+
            ', BINARY(' + %Trim(w_Binario) + ')');
           Else;
            Script_Values = %Trim(%Trim(w_Binario));
           EndIf;
          Else;
           w_Binario = %Trim(%Subst(w_Caracteres:1:w_Long));
           If Script_Values <> *Blanks;
            Script_Values = %Trim(%Trim(Script_Values) +
            ', ' + %Trim(w_Binario));
           Else;
            Script_Values =
            %Trim(%Trim(w_Binario));
           EndIf;
          EndIf;
         EndIf;
        When TipDato = 'F';
         w_DoubS = %Scan('DOUBLE':Descrip);
         w_FloS  = %Scan('FLO':Descrip);
         w_RealS = %Scan('REAL':Descrip);

         If w_DoubS <> *Zeros;
          w_Double = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) +
           ', DOUBLE(' + %Trim(w_Double) + ')');
          Else;
           Script_Values = %Trim('DOUBLE(' + %Trim(w_Double) + ')');
          EndIf;
         EndIf;
         If w_FloS <> *Zeros;
          If PosDec <> *Zeros;
           If Script_Values <> *Blanks;
            Script_Values =%Trim( %Trim(Script_Values) + ', 1.0');
           Else;
            Script_Values = '1.0';
           EndIf;
          Else;
           w_Float = %Trim(%Subst(w_Caracteres:1:w_Long));
           If Script_Values <> *Blanks;
            Script_Values = %Trim(%Trim(Script_Values) +
            ', ' + %Trim(w_Float));
           Else;
            Script_Values = %Trim(w_Float);
           EndIf;
          EndIf;
         EndIf;
         If w_RealS <> *Zeros;
          If PosDec <> *Zeros;
           If Script_Values <> *Blanks;
            Script_Values =%Trim( %Trim(Script_Values) + ', 1.0');
           Else;
            Script_Values = '1.0';
           EndIf;
          Else;
           w_Real = %Trim(%Subst(w_Caracteres:1:w_Long));
           If Script_Values <> *Blanks;
            Script_Values = %Trim(%Trim(Script_Values) + ',' + %Trim(w_Real));
           Else;
            Script_Values = %Trim(w_Real);
           EndIf;
          EndIf;
         EndIf;
        When TipDato = 'G';
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ', DEFAULT');
         Else;
          Script_Values = %Trim('DEFAULT');
         EndIf;
        When TipDato = 'L';
         w_Fecha = %Trim(%Char(%Date()));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) +
          ',' + w_Com + %Trim(w_Fecha) + w_Com);
         Else;
          Script_Values = %Trim(w_Com + %Trim(w_Fecha) + w_Com);
         EndIf;
        When TipDato = 'P';
          If PosDec <> *Zeros;
           If Script_Values <> *Blanks;
            Script_Values =%Trim( %Trim(Script_Values) + ', 1.0');
           Else;
            Script_Values = '1.0';
           EndIf;
          Else;
          w_Numerico = %Trim(%Subst(w_Caracteres:1:w_Long));
          If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) + ',' + %Trim(w_Numerico));
          Else;
           Script_Values = %Trim(w_Numerico);
          EndIf;
         EndIf;
        When TipDato = 'S';
          If PosDec <> *Zeros;
           If Script_Values <> *Blanks;
            Script_Values =%Trim( %Trim(Script_Values) + ', 1.0');
           Else;
            Script_Values = '1.0';
           EndIf;
          Else;
           w_Integer = %Trim(%Subst(w_Caracteres:1:w_Long));
            If Script_Values <> *Blanks;
           Script_Values = %Trim(%Trim(Script_Values) + ',' + %Trim(w_Integer));
            Else;
             Script_Values = %Trim(w_Integer);
            EndIf;
          EndIf;
        When TipDato = 'T';
         w_Hora = %Trim(%Char(%Time()));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) + ','
          + w_Com + %Trim(w_Hora)) + w_Com;
         Else;
          Script_Values = w_Com + %Trim(w_Hora) + w_Com;
         EndIf;
        When TipDato = 'Z';
         w_TimeSt = %Trim(%Char(%Timestamp()));
         If Script_Values <> *Blanks;
          Script_Values = %Trim(%Trim(Script_Values) + ',' +
          w_Com + %Trim(w_TimeSt)) + w_Com;
         Else;
          Script_Values = w_Com + %Trim(w_TimeSt) + w_Com;
         EndIf;
       EndSl;
      /End-Free
     PLlenarScript...
     P                 E

     PLlenarArchivo...
     P                 B
      /Free

       w_NumReg1 = %Dec(PNUMREG1:10:0);

       //Insertar los registros en el archivo
       DoW w_NumReg <= w_NumReg1;
        w_Insert=
        'Insert into ' + w_Archivo + ' Values (' + %Trim(Script_Values) + ')';
        Exec SQL Prepare Insert From :w_Insert;
        Exec SQL Execute Insert;
        w_NumReg = w_NumReg + 1;
       EndDo;
       w_NumReg = 1;

      /End-Free
     PLlenarArchivo...
     P                 E
