     ?*===================================================================
     ?*Programa : CTRRUPDATE
     ?*Funcion  : Edición de registros
     ?*Autor    : YUBER DOMINGUEZ RAMOS - ANA MARIA AGUDELO ÁLVAREZ
     ?*Fecha    : Marzo de 2018
     ?*===================================================================
     H DFTACTGRP(*NO)

     D*---------------Definicion Variables Propias
     Dw_Archivo        S             10A
     Dw_Delete         S           1021A

      *Definicion de Parametros de Entrada
     C     *Entry        PList
     C                   Parm                    w_Archivo
      *Estructura Principal
      /Free

       //Elimina los registros en el archivo
        w_Delete=
        'Delete ' + %Trim(w_Archivo);
        Exec SQL Prepare Delete From :w_Delete;
        Exec SQL Execute Delete;

       *Inlr = *On;
      /End-Free
