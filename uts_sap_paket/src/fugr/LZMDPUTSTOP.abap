*&---------------------------------------------------------------------*
*& Include      LZMDPUTSTOP                    Function Group ZMDPUTS
*&---------------------------------------------------------------------*
FUNCTION-POOL zmdputs.

*----------------------------------------------------------------------*
*  Bu fonksiyon grubu UTS demo uygulamasinin 18 function module'unu
*  barindirir. Tum FM'ler ZCL_ZMDPUTS_MOCK global class'i uzerinden
*  mock data doner - gercek UTS servisi cagrilmaz.
*----------------------------------------------------------------------*

INCLUDE zmdputs_common_types.   " Ortak type/struct tanimlari
