; BİL362 GÜZ20 PROJE - GRUP NO: 5 - PROJE NO: 2
; BUSE NUR DÜZGÜN 
; ECEM DENİZ BABAOĞLAN 

;STARTING DATE: 01.01.2020
;GİRİLEBİLECEK MAX SAYI 1000. MAX FINAL DATE: 27.09.2022, SALI


YENISAYI:
LCALL CONFIGURE_LCD
MOV R3,#0 ; SAYI EN ANLAMLI KISIM
MOV R4,#0 ; SAYI EN ANLAMSIZ KISIM
;MOV R6,#20 ; YILLAR 2020,2021,2022 OLABİLİR. R7 YILIN ILK IKI BASAMAGI 
;MOV R7,#20 ; YILIN SON 2 BASAMAGI.

LCALL GET_NUM
; ALINAN SAYILARIN NE OLDUGU GOZUKSUN DIYE GET_NUM SUBROUTINEINDE
; LCALL SEND_DATA KOMUTU KULLANILMISTIR. INPUT KISA BIR SURE EKRANDA GOZUKUR
; DAHA SONRA CONFIGURE_LCD KOMUTU ILE INPUT SAYILARI SILINIR VE EKRANA TARIH BASTIRILIR.
LCALL CONFIGURE_LCD

LCALL YEAR
LCALL AY

LCALL BASTIR_GUN
LCALL BASTIR_AY
LCALL PRINT_YEAR

LCALL DAY_NAME

; KOD 1 KEZ DEGIL SUREKLI CALISMAK UZERE TASARLANDI.
; EGER KODUN SUREKLI CALISMASI ISTENMIYORSA 'YENISAYI' LABELI KALDIRILMALI VE 
; 'LJMP YENISAYI' YERINE 'LJMP $' YAZILMALIDIR.

LJMP YENISAYI


; ===================== SUBROUTINELER ========================

; ================= GET NUMBER ===============================

GET_NUM:
; GİRİLEN SAYI 0967 OLSUN. 09 = R3, 43 = R4 SEKLINDE SAKLANACAK (SOL ALTTAKİ CHARTTA ASCII VERSIYONLARI GÖZÜKÜR).
; SAYININ ILK IKI BASAMAGINI (R3) AL
LCALL KEYBOARD
LCALL SEND_DATA
CLR C
SUBB A,#30H
MOV B,#10
MUL AB
MOV R3,A
LCALL KEYBOARD
LCALL SEND_DATA
CLR C
SUBB A,#30H
ADD A,R3
MOV R3,A ; R3'TE SAYININ EN ANLAMLI KISMI VAR. BURAYA BAKARAK SENE HESABI YAPACAGIZ.

; SAYININ SON IKI BASAMAGINI (R4) AL
LCALL KEYBOARD
LCALL SEND_DATA
CLR C
SUBB A,#30H
MOV B,#10
MUL AB
MOV R4,A
LCALL KEYBOARD
LCALL SEND_DATA
CLR C
SUBB A,#30H
ADD A,R4
MOV R4,A ; R4'TE SAYININ EN ANLAMSIZ KISMI VAR.
RET

;  ======================= DAY & MONTH ==============================

AY: ;;Hangi ayın hangi günü olduğunu hesaplayan subroutine
MOV A,R7 ;; Year subroutineinde hesaplanan yılın son 2 basamağı A registerına konarak ilgili karsilastirmalar yapilir.
CJNE A,#20,DIGER_SENELER 
;SENENİN SON İKİ BASAMAĞI 20 İLE KARŞILAŞTIRILIR
;20 İSE S2020 TABLOSUNA DEĞİLSE DİGER SENELERİN OLDUGU S2021 TABLOSUNA GİDER

SENE_2020:
MOV DPTR,#s2020
MOV 32H,R3
MOV 33H,R4
LJMP DEVAM

DIGER_SENELER:
MOV DPTR,#s2021
MOV 32H,R3
MOV 33H,R4
CJNE A,#21,KONTROL
;;AY VE GÜN KONTROLÜ İÇİN YAPILACAK ÇIKARMALARDA KULLANILMAK ÜZERE R3 VE R4 TE BULUNAN KEYPADDEN ALINAN SAYILARI 32H VE 33H''A ATAR
;;EĞER YIL 2021 İSE SAYIDAN 366 ÇIKARTIR
;;EĞER YIL 2022 İSE SAYIDAN 731 ÇIKARTIR
;BU ÇIKARMALARIN AMACI ELDE SADECE BULUNULAN SENEYE AİT GÜN SAYISI KALMASIDIR.

MOV 30H,A

MOV A,33H
CLR C
SUBB A,#66
JNC POZITIF0; CARRY 1'SE KAGIT UZERINDE 4 İŞLEM YAPAR GİBİ BİR ÜST BASAMAKTAN ELDE ALIR. BİR ÜST BASAMAK 3. BASAMAK OLDUĞU İÇİN 100 EKLER
MOV A,33H
ADD A,#100
DEC 32H
SUBB A,#66

POZITIF0:
MOV 33H,A 
MOV A,32H
SUBB A,#3
DA A
MOV 32H,A
MOV A,30H
LJMP DEVAM

KONTROL:
MOV 30H,A

MOV A,33H
CLR C
SUBB A,#31
JNC POZITIF
MOV A,33H
ADD A,#100
DEC 32H
SUBB A,#31
POZITIF:
MOV 33H,A
MOV A,32H
SUBB A,#7
DA A
MOV 32H,A
MOV A,30H

DEVAM:
INC 33H; 1 ocak 2020 referans alındığı için sayıyı 1 arttırır
MOV 39H,#12 
MOV R0,#20H

AY_GUNLERI:;;HANGİ YILDA OLDUĞUNA GÖRE AYIN GÜNLERİNİ TABLODAN ÇEKEREK 20H,2BH ARALARINA KAYDEDER
MOV A,#0
MOVC A,@A+DPTR
MOV @R0,A
INC DPTR
INC R0
DJNZ 39H,AY_GUNLERI

MOV R2,#0

TB_OCAK: ; sayıdan 31 çıkarır, eğer negatifse ocak ayı değilse tb_subata giderek subat ayı kontrolu yapar
;Her ay kontrolüne başlamadan önce, o ay kontrolüne girerken elde bulunan sayı r5'te saklanıyor. 
;Çıkarmalar sonucunda eğer o ay olduğuna karar verilirse r5'te bulunan sayı ayın kaçıncı günü olduğunu ifade ediyor.
MOV A,33H
MOV R5,A
CLR C
SUBB A,20H
MOV 33H,A

JNC TB_SUBAT
MOV A,R5
ADD A,#100
SUBB A,20H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC OCAK
MOV 32H,A
MOV A,33H
LJMP TB_SUBAT

;;TB BAŞLIKLI LABELLARDA ÇIKARMA SONUCUNDA SAYININ YALNIZCA 0'DAN KÜÇÜK OLUP OLMADIĞI KONTROL EDİLİYOR.
;AYIN SON GÜNÜ İSE, ÖRNEĞİN 31 OCAK, TB ALTINDAKİ ALGORİTMAYA GÖRE ŞUBAT AYININ 0.GÜNÜ VARSAYIYOR VE ŞUBAT AYI LABELINA GİRİYOR.
;;BUNU 31 OCAK OLARAK YAZDIRABİLMEK İÇİN ŞUBAT LABELININ ALTINDA SAYININ 0 OLUP OLMADIĞI KONTROL EDİLEREK 0 OLMAMASI DURUMUNDA NORMAL LABELLARI ALTINDA 
;O AN ELDE BULUNAN SAYI İLE GÜN VE AY ATAMASI YAPILIYOR. 
;SAYI EĞER SIFIR İSE, BULUNULAN LABELIN BİR ÖNCEKİ AYININ SON GÜNÜ, GÜN SAYISI OLARAK. BİR ÖNCEKİ AY DA KAÇINCI AY OLDUĞU OLARAK ALINIYOR
;BKZ SATIRLAR 213-222


OCAK:
MOV A,R5
JNZ NORMAL
MOV 38H,2BH
MOV R2,#12
LJMP SON
NORMAL:
MOV R2,#01;KAÇINCI AY OLDUĞU R2'DE SAKLANIYOR
MOV 38H,R5; AYIN KAÇINCI GÜNÜ OLDUĞUNA KARAR VERİLMİŞSE SON ATAMA 38H'A YAPILIYOR
LJMP SON

TB_SUBAT:
MOV A,33H
MOV R5,A
CLR C
SUBB A,21H
MOV 33H,A
JNC TB_MART
MOV A,R5
ADD A,#100
SUBB A,21H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC SUBAT
MOV 32H,A
MOV A,33H
LJMP TB_MART

SUBAT:
MOV A,R5
JNZ NORMAL1
MOV 38H,20H
MOV R2,#01
LJMP SON
NORMAL1:
MOV R2,#02
MOV 38H,R5
LJMP SON

TB_MART:
MOV A,33H
MOV R5,A
CLR C
SUBB A,22H
MOV 33H,A
JNC TB_NISAN
MOV A,R5
ADD A,#100
SUBB A,22H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC MART
MOV 32H,A
MOV A,33H
LJMP TB_NISAN

MART:
MOV A,R5
JNZ NORMAL2
MOV 38H,21H
MOV R2,#02
LJMP SON
NORMAL2:
MOV R2,#03
MOV 38H,R5
LJMP SON

TB_NISAN:
MOV A,33H
MOV R5,A
CLR C
SUBB A,23H
MOV 33H,A
JNC TB_MAYIS
MOV A,R5
ADD A,#100
SUBB A,23H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC NISAN


MOV 32H,A
MOV A,33H
LJMP TB_MAYIS

NISAN:
MOV A,R5
JNZ NORMAL3
MOV 38H,22H
MOV R2,#03
LJMP SON
NORMAL3:
MOV R2,#04
MOV 38H,R5
LJMP SON

TB_MAYIS:
MOV A,33H
MOV R5,A
CLR C
SUBB A,24H
MOV 33H,A
JNC TB_HAZIRAN
MOV A,R5
ADD A,#100
SUBB A,24H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1

JC MAYIS

MOV 32H,A
MOV A,33H
LJMP TB_HAZIRAN

MAYIS:
MOV A,R5
JNZ NORMAL4
MOV 38H,23H
MOV R2,#04
LJMP SON
NORMAL4:
MOV R2,#05
MOV 38H,R5
LJMP SON

TB_HAZIRAN:
MOV A,33H
MOV R5,A
CLR C
SUBB A,25H
MOV 33H,A
JNC TB_TEMMUZ
MOV A,R5
ADD A,#100
SUBB A,25H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC HAZIRAN
MOV 32H,A
MOV A,33H
LJMP TB_TEMMUZ

HAZIRAN:
MOV A,R5
JNZ NORMAL5
MOV 38H,24H
MOV R2,#05
LJMP SON
NORMAL5:
MOV R2,#06
MOV 38H,R5
LJMP SON

TB_TEMMUZ:
MOV A,33H
MOV R5,A
CLR C
SUBB A,26H
MOV 33H,A
JNC TB_AGUSTOS
MOV A,R5
ADD A,#100
SUBB A,26H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC TEMMUZ
MOV 32H,A
MOV A,33H
LJMP TB_AGUSTOS

TEMMUZ:
MOV A,R5
JNZ NORMAL6
MOV 38H,25H
MOV R2,#06
LJMP SON
NORMAL6:
MOV R2,#07
MOV 38H,R5
LJMP SON

TB_AGUSTOS:
MOV A,33H
MOV R5,A
CLR C
SUBB A,27H
MOV 33H,A
JNC TB_EYLUL
MOV A,R5
ADD A,#100
SUBB A,27H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC AGUSTOS
MOV 32H,A
MOV A,33H
LJMP TB_EYLUL

AGUSTOS:
MOV A,R5
JNZ NORMAL7
MOV 38H,26H
MOV R2,#07
LJMP SON
NORMAL7:
MOV R2,#08
MOV 38H,R5
LJMP SON

TB_EYLUL:
MOV A,33H
MOV R5,A
CLR C
SUBB A,28H
MOV 33H,A
JNC TB_EKIM
MOV A,R5
ADD A,#100
SUBB A,28H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC EYLUL
MOV 32H,A
MOV A,33H
LJMP TB_EKIM
EYLUL:
MOV A,R5
JNZ NORMAL8
MOV 38H,27H
MOV R2,#08
LJMP SON
NORMAL8:
MOV R2,#09
MOV 38H,R5
LJMP SON

TB_EKIM:
MOV A,33H
MOV R5,A
CLR C
SUBB A,29H
MOV 33H,A
JNC TB_KASIM
MOV A,R5
ADD A,#100
SUBB A,29H
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC EKIM
MOV 32H,A
MOV A,33H
LJMP TB_KASIM

EKIM:
MOV A,R5
JNZ NORMAL9
MOV 38H,28H
MOV R2,#09
LJMP SON
NORMAL9:
MOV R2,#10
MOV 38H,R5
LJMP SON

TB_KASIM:
MOV A,33H
MOV R5,A
CLR C
SUBB A,2AH
MOV 33H,A
;Hangi sene olduğuna karar verilip gerekli çıkarmalar yapıldığı için, eğer kasım kontrollerinde c=1 olursa direk aralık ayı kabul ediliyor.
JNC ARALIK
MOV A,R5
ADD A,#100
SUBB A,2AH
MOV 33H,A
CLR C
MOV A,32H
SUBB A,#1
JC KASIM
MOV 32H,A
MOV A,33H
LJMP ARALIK

KASIM:
MOV A,R5
JNZ NORMAL10
MOV 38H,29H
MOV R2,#10
LJMP SON
NORMAL10:
MOV R2,#11
MOV 38H,R5
LJMP SON

ARALIK:
MOV A,R5
JNZ NORMAL11
MOV 38H,2AH
MOV R2,#11
LJMP SON
NORMAL11:
MOV R2,#12
MOV 38H,33H
LJMP SON

SON:
RET

; ==================== GUNU YAZDIR ============================

BASTIR_GUN: ;; Ayın kaçıncı günü olduğunu 38H'tan alarak lcdye yazdıran subroutine
MOV A,38H
MOV B,#10

DIV AB
ADD A,#30H
LCALL SEND_DATA
MOV A,B
ADD A,#30H
LCALL SEND_DATA
MOV A,#'.'
LCALL SEND_DATA
RET

; ==================== AYI YAZDIR ============================

BASTIR_AY: ;; Yılın kaçıncı ayı olduğunu R2den alarak lcdye yazdıran subroutine
MOV A,R2
MOV B,#10

DIV AB
ADD A,#30H
LCALL SEND_DATA
MOV A,B
ADD A,#30H
LCALL SEND_DATA
MOV A,#'.'
LCALL SEND_DATA
RET

;  ======================= DAY NAME ==============================

DAY_NAME:
; 01.01.2020 CARSAMBA İSE
; CARSAMBA    0
; PERSEMBE    1
; CUMA        2
; CUMARTESİ   3
; PAZAR       4
; PAZARTESİ   5
; SALI        6   OLUR. MOD7'DEN KALANA GÖRE HAFTANIN HANGİ GÜNÜ OLDUĞU BELİRLENİR.

; SAYI: R3R4
CONTINUE:
MOV A,R4
CJNE A,#7,CHECK_NAME
; R4=7 -> CIKARMA YAP
LJMP SUBTRACT

CHECK_NAME:
; C=0 İSE R4>7 , CIKARMA YAP
; C=1 İSE R4<7, R3TEN ELDE ALABİLİR MİSİN KONTROL ET
JNC SUBTRACT
; R3=0 İSE ELDE YOK DEMEKTIR, BİTİR VE KALANA BAK
MOV A,R3
JZ END_NAME
; R3 SIFIR DEĞİL, ELDE ALINABİLİR, R3U 1 AZALT
DEC R3 
; ELDE ALIP 7 CIKARMAK --> R4 = R4 + 100 - 7 = R4 + 93
; DİREKT R4E 93 EKLEMEK DAHA PRATİK
MOV A,R4
ADD A,#93
MOV R4,A
LJMP CONTINUE

SUBTRACT:
SUBB A,#7
MOV R4,A
LJMP CONTINUE

END_NAME:
MOV A,#0C0H   ;CURSOR ALT SATIRA GECSIN
ACALL SEND_COMMAND
MOV A,R4
CJNE A,#6,OTHER
MOV A,#'S'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'l'
LCALL SEND_DATA
MOV A,#'i'
LCALL SEND_DATA
LJMP EXIT
OTHER:
CJNE A,#5,OTHER2
MOV A,#'P'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'z'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'r'
LCALL SEND_DATA
MOV A,#'t'
LCALL SEND_DATA
MOV A,#'e'
LCALL SEND_DATA
MOV A,#'s'
LCALL SEND_DATA
MOV A,#'i'
LCALL SEND_DATA
LJMP EXIT
OTHER2:
CJNE A,#4,OTHER3
MOV A,#'P'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'z'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'r'
LCALL SEND_DATA
LJMP EXIT
OTHER3:
CJNE A,#3,OTHER4
MOV A,#'C'
LCALL SEND_DATA
MOV A,#'u'
LCALL SEND_DATA
MOV A,#'m'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'r'
LCALL SEND_DATA
MOV A,#'t'
LCALL SEND_DATA
MOV A,#'e'
LCALL SEND_DATA
MOV A,#'s'
LCALL SEND_DATA
MOV A,#'i'
LCALL SEND_DATA
LJMP EXIT
OTHER4:
CJNE A,#2,OTHER5
MOV A,#'C'
LCALL SEND_DATA
MOV A,#'u'
LCALL SEND_DATA
MOV A,#'m'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
LJMP EXIT
OTHER5:
CJNE A,#1,OTHER6
MOV A,#'P'
LCALL SEND_DATA
MOV A,#'e'
LCALL SEND_DATA
MOV A,#'r'
LCALL SEND_DATA
MOV A,#'s'
LCALL SEND_DATA
MOV A,#'e'
LCALL SEND_DATA
MOV A,#'m'
LCALL SEND_DATA
MOV A,#'b'
LCALL SEND_DATA
MOV A,#'e'
LCALL SEND_DATA
LJMP EXIT
OTHER6:
MOV A,#'C'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'r'
LCALL SEND_DATA
MOV A,#'s'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA
MOV A,#'m'
LCALL SEND_DATA
MOV A,#'b'
LCALL SEND_DATA
MOV A,#'a'
LCALL SEND_DATA

EXIT:
RET

; ======================= YEAR =================================

YEAR:
MOV R6,#20 ; YILLAR 2020,2021,2022 OLABİLİR. R7 YILIN ILK IKI BASAMAGI 
MOV R7,#20 ; YILIN SON 2 BASAMAGI.
;GIRILEN SAYI=0967
; 2 YIL = 0730 GUN OLDUGUNA GORE R3TEKİ SAYI 07DEN BUYUK/ESITSE YIL 2022 OLUR 
MOV A,R3
JZ YEAR_20  ; SAYININ İLK 2 BASAMAĞI SIFIR İSE YIL 2020DİR.
CJNE A,#3,YEAR_CHECK1
; SAYI 365TEN KUCUKSE YIL: 2020 
MOV A,R4
CJNE A,#65,YEAR_CHECK2
; SAYI=365 -> YIL:2021
INC_YEAR:
MOV R7,#21
LJMP END_YEAR

YEAR_CHECK2:
; 399>SAYI>365 İSE C=0, YIL:2021
JNC INC_YEAR
;C=1, YIL:2020
LJMP YEAR_20

YEAR_CHECK1:
; SAYININ İLK 2 BASAMAGI 3'E ESIT DEGIL DIYE BURAYA GELDI
; C=0 İSE YIL:2021/2022, C=1 İSE YIL:2020
JNC MORE
LJMP YEAR_20

MORE:
;MOV A,R3
CJNE A,#7,CHECK_MORE1
MOV A,R4
CJNE A,#30,CHECK_MORE2
;SAYI=730 İSE -> YIL:2022
INC_YEAR2:
MOV R7,#22
LJMP END_YEAR

CHECK_MORE2:
; 1000>SAYI>730 İSE C=0, YIL:2022
JNC INC_YEAR2
;C=0, YIL:2021
LJMP INC_YEAR

CHECK_MORE1:
; SAYININ İLK İKİ BASAMAĞI 7'YE ESIT DEGIL DIYE BURAYA GELDI
; C=1 İSE R3<7 VE YIL:2021, C=0 İSE R3>7 VE YIL:2022
JNC INC_YEAR2
LJMP INC_YEAR

YEAR_20:
; INITIALLY, YIL=2020 OLDUGUNDAN MAIN KODA DONULMELI
LJMP END_YEAR

END_YEAR:
RET

; ======================= YEAR LCD =================================

PRINT_YEAR:
; 2 BASAMAKLI SAYI BASTIRMA:
; ÖNCE YILIN İLK 2 BASAMAĞI
MOV A,R6
MOV B,#10
DIV AB
ADD A,#30H
LCALL SEND_DATA ;BINLER BASAMAGI
MOV A,B
ADD A,#30H
LCALL SEND_DATA ;YUZLER BASAMAGI
; YILIN SON IKI BASAMAĞI
MOV A,R7
MOV B,#10
DIV AB
ADD A,#30H
LCALL SEND_DATA ;ONLAR BASAMAGI
MOV A,B
ADD A,#30H
LCALL SEND_DATA ;BINLER BASAMAGI

RET