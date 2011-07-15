{{

Spinneret Web Server; 'nerdDoro'     v0.5 

https://github.com/jhalbrecht/nerdDoro 

Author: Jeff Albrecht                  
 Began July 10, 2011                   
 Revision History:
 
 July 12, 2011 1400
  modified s-35390A_GBSbuild_02_09_2011.spin to return ShortFmtDateTime for LCD 
  
 July 11, 2011 1414
  Added LCD, RTC and Sensirion support
  Button toggles usr led
  
 July 10, 2011 1700
  Commited to github. Added button for user LED
   
 July 10, 2011 1430 - jeffa
  Version 0.5  Begun based on Beau Schwabe Spinneret_Web_Server_DEMOv1.2

 Special recognition goes to ....
 Beau Schwabe
 Roy ELtham
 Timothy D. Swieter
 Kwabena W. Agyeman
 Jeff Martin
 Andy Lindsay
 Chip Gracey

}}

CON
  _clkfreq = 80_000_000
  _clkmode = xtal1 + pll16x

' jha for serial LCD
  TX_PIN        = 22
  BAUD          = 19_200
' jha Sensirion
  SHT_DATA      = 24 ' 29                                    ' SHT-11 data pin
  SHT_CLOCK     = 25 ' 28                                    ' SHT-11 clock pin
  bOffSet = 70

  CR          = 13
  LF          = 10
  'isOn  = 0
  
  bytebuffersize = 2048
  maxPacketSendSize = 2032
  listenPort = 80  

  'W5100 Interface
  W5100_DATA0 = 0
  W5100_DATA1 = 1
  W5100_DATA2 = 2
  W5100_DATA3 = 3
  W5100_DATA4 = 4
  W5100_DATA5 = 5
  W5100_DATA6 = 6
  W5100_DATA7 = 7
  W5100_ADDR0 = 8
  W5100_ADDR1 = 9
  W5100_WR    = 10
  W5100_RD    = 11
  W5100_CS    = 12
  W5100_INT   = 13
  W5100_RST   = 14
  W5100_SEN   = 15
    
OBJ
  'DHCPClient    : "DHCP"
  W5100         : "Brilldea_W5100_Indirect_Driver_Ver006.spin"
'  PST           : "Parallax Serial Terminal"
  STR           : "STREngine"
  RTC           : "s-35390A_GBSbuild_02_09_2011"
  LCD           : "FullDuplexSerial.spin"
  vp            : "terminal"
  sht           : "Sensirion_full"
  fp            : "FloatString"
  f             : "Float32"

VAR
  long dbstack[5],dbhere,dbdebug,dbpause,dbstptr

  long  visitor,strpointer,ButtonSelection, rawTemp, tempC
  byte  MAC_Address[6]
  byte  data[bytebuffersize]

PUB main | packetSize
dbstptr:=-1

  if (dbpause & 1)
    dbdebug:=93
  repeat while(dbdebug==93)
    dbhere:=93
  LCD.start(TX_PIN, TX_PIN, %1000, 19_200)
  if (dbpause & 1)
    dbdebug:=94
  repeat while(dbdebug==94)
    dbhere:=94
  waitcnt(clkfreq / 100 + cnt)                ' Pause for FullDuplexSerial.spin to initialize
  if (dbpause & 1)
    dbdebug:=95
  repeat while(dbdebug==95)
    dbhere:=95
  sht.start(SHT_DATA, SHT_CLOCK)                        ' start sensirion object
  if (dbpause & 1)
    dbdebug:=96
  repeat while(dbdebug==96)
    dbhere:=96
  waitcnt(clkfreq*3+cnt)
  if (dbpause & 1)
    dbdebug:=97
  repeat while(dbdebug==97)
    dbhere:=97
  sht.config(50 ,sht#off,sht#yes,sht#hires)              'configure SHT-11
  if (dbpause & 1)
    dbdebug:=98
  repeat while(dbdebug==98)
    dbhere:=98
  f.start 
 
 vp.config(string("start:terminal::terminal:1"))
 vp.debug(@dbstack,@dbhere)
 vp.share(@visitor,@strpointer)          'share variable

  'pst.Start(115200)               '<-- Initialize Serial Communication to PC (debug)

' Network Settings
  if (dbpause & 1)
    dbdebug:=106
  repeat while(dbdebug==106)
    dbhere:=106
  IP             := $96_08_09_0A  ' IP:10.9.8.150, LAN:spinneret.jeffa.org, WAN:jeffa.org:90
  if (dbpause & 1)
    dbdebug:=107
  repeat while(dbdebug==107)
    dbhere:=107
  SubnetMask     := $00_FF_FF_FF  ' enter as little-endian in hex 
  if (dbpause & 1)
    dbdebug:=108
  repeat while(dbdebug==108)
    dbhere:=108
  GatewayIP      := $FE_08_09_0A  
  if (dbpause & 1)
    dbdebug:=109
  repeat while(dbdebug==109)
    dbhere:=109
  DNS_Server     := $FE_08_09_0A  
  if (dbpause & 1)
    dbdebug:=110
  repeat while(dbdebug==110)
    dbhere:=110
  destIP         := $00_00_00_00  
  
  ' MAC Address
  if (dbpause & 1)
    dbdebug:=113
  repeat while(dbdebug==113)
    dbhere:=113
  MAC_Address[0] := $00
  if (dbpause & 1)
    dbdebug:=114
  repeat while(dbdebug==114)
    dbhere:=114
  MAC_Address[1] := $08
  if (dbpause & 1)
    dbdebug:=115
  repeat while(dbdebug==115)
    dbhere:=115
  MAC_Address[2] := $DC 
  if (dbpause & 1)
    dbdebug:=116
  repeat while(dbdebug==116)
    dbhere:=116
  MAC_Address[3] := $16 
  if (dbpause & 1)
    dbdebug:=117
  repeat while(dbdebug==117)
    dbhere:=117
  MAC_Address[4] := $EF 
  if (dbpause & 1)
    dbdebug:=118
  repeat while(dbdebug==118)
    dbhere:=118
  MAC_Address[5] := $81    

  if (dbpause & 1)
    dbdebug:=120
  repeat while(dbdebug==120)
    dbhere:=120
  PauseMSec(2000)                 '<-- Allow 2 seconds after programming to start the PST. 
  
  'Initialize Wiznet 5100 chip 
  if (dbpause & 1)
    dbdebug:=123
  repeat while(dbdebug==123)
    dbhere:=123
  Wiznet5100

  'Initialize PST screen
  'pst.Home
  'pst.Clear

'Set Auxiliary I/O's for output (debug) 
'  Dira[24..27]~~
'  Outa[24..27]~

  if (dbpause & 1)
    dbdebug:=133
  repeat while(dbdebug==133)
    dbhere:=133
  Dira[23]~~
  if (dbpause & 1)
    dbdebug:=134
  repeat while(dbdebug==134)
    dbhere:=134
  Outa[23]~
  
  if (dbpause & 1)
    dbdebug:=136
  repeat while(dbdebug==136)
    dbhere:=136
  RTC.Update
  if (dbpause & 1)
    dbdebug:=137
  repeat while(dbdebug==137)
    dbhere:=137
  LCD.str(string(17))           ' backlight on   
  if (dbpause & 1)
    dbdebug:=138
  repeat while(dbdebug==138)
    dbhere:=138
  LCD.str(string(12))           ' cls
  if (dbpause & 1)
    dbdebug:=139
  repeat while(dbdebug==139)
    dbhere:=139
  LCD.str(string(22))           ' Turn the display on, with cursor off and no blink
  if (dbpause & 1)
    dbdebug:=140
  repeat while(dbdebug==140)
    dbhere:=140
  LCD.str(string(128))          ' Move cursor to line 0, position 0
  if (dbpause & 1)
    dbdebug:=141
  repeat while(dbdebug==141)
    dbhere:=141
  LCD.str(RTC.ShortFmtDateTime)
  if (dbpause & 1)
    dbdebug:=142
  repeat while(dbdebug==142)
    dbhere:=142
  LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))
  'pst.str(RTC.FmtDateTime) 

 'Infinite loop of the server ; listen on the TCP socket 
  if (dbpause & 1)
    dbdebug:=146
  repeat while(dbdebug==146)
    dbhere:=146
  repeat

    'PST.Str(string("Waiting for a client to connect....", PST#NL))
    if (dbpause & 1)
      dbdebug:=149
    repeat while(dbdebug==149)
      dbhere:=149
    repeat
      if (dbpause & 1)
        dbdebug:=150
      repeat while(dbdebug==150)
        dbhere:=150
      updateLCD
    while !W5100.SocketTCPestablished(0)
                                                                            
    'pst.Str(string("connection established...", PST#NL))
    'pst.dec(visitor)
    'pst.Char(13)

    'Initialize the buffers and bring the data over
    if (dbpause & 1)
      dbdebug:=158
    repeat while(dbdebug==158)
      dbhere:=158
    bytefill(@data, 0, bytebuffersize)    
    if (dbpause & 1)
      dbdebug:=159
    repeat while(dbdebug==159)
      dbhere:=159
    repeat
      if (dbpause & 1)
        dbdebug:=160
      repeat while(dbdebug==160)
        dbhere:=160
      packetSize := W5100.rxTCP(0, @data)
    while packetSize == 0  

    'pst.Str(string("Packet from browser:", PST#NL))
    'pst.Str(@data[0])

'--------Parse Data Packet for Button Press-------
    if (dbpause & 1)
      dbdebug:=167
    repeat while(dbdebug==167)
      dbhere:=167
    strpointer := STR.findCharacters(@data[0], string("GET /button_action"))
    if (dbpause & 1)
      dbdebug:=168
    repeat while(dbdebug==168)
      dbhere:=168
    if strpointer<>0
       if (dbpause & 1)
         dbdebug:=169
       repeat while(dbdebug==169)
         dbhere:=169
       bytemove(@d1,@data[20],2)
       if (dbpause & 1)
         dbdebug:=170
       repeat while(dbdebug==170)
         dbhere:=170
       ButtonSelection := STR.decimalToNumber(@d1)
       if (dbpause & 1)
         dbdebug:=171
       repeat while(dbdebug==171)
         dbhere:=171
       SetButtons
       if (dbpause & 1)
         dbdebug:=172
       repeat while(dbdebug==172)
         dbhere:=172
       html
       if (dbpause & 1)
         dbdebug:=173
       repeat while(dbdebug==173)
         dbhere:=173
       htmlEnd

'--------Parse Data Packet for time and temperature request or Press-------
    if (dbpause & 1)
      dbdebug:=176
    repeat while(dbdebug==176)
      dbhere:=176
    strpointer := STR.findCharacters(@data[0], string("GET /tnt"))
    'pst.str(@data)
    if (dbpause & 1)
      dbdebug:=178
    repeat while(dbdebug==178)
      dbhere:=178
    if strpointer<>0
       ' bytemove (@tntT,string("66.6"), 4)
       if (dbpause & 1)
         dbdebug:=180
       repeat while(dbdebug==180)
         dbhere:=180
       bytemove (@tntT, fp.FloatToFormat(fahrenheit(tempC), 5,1), 4)                  ' jha update temperature
       if (dbpause & 1)
         dbdebug:=181
       repeat while(dbdebug==181)
         dbhere:=181
       bytemove (@tntD,string("2011-07-13T02:34:12"), 19)
       'pst.str(string(" You got to the GET /tnt "))
       if (dbpause & 1)
         dbdebug:=183
       repeat while(dbdebug==183)
         dbhere:=183
       html
       if (dbpause & 1)
         dbdebug:=184
       repeat while(dbdebug==184)
         dbhere:=184
       htmlEnd  

'--------Parse Data Packet for time and temperature request or Press-------
    if (dbpause & 1)
      dbdebug:=187
    repeat while(dbdebug==187)
      dbhere:=187
    strpointer := STR.findCharacters(@data[0], string("GET /tntxml"))
    'pst.str(@data)
    if (dbpause & 1)
      dbdebug:=189
    repeat while(dbdebug==189)
      dbhere:=189
    if strpointer<>0
       ' bytemove (@tntT,string("66.6"), 4)
       'bytemove (@tntT, fp.FloatToFormat(fahrenheit(tempC), 5,1), 4)                  ' jha update temperature
       'bytemove (@tntD,string("2011-07-13T02:34:12"), 19)
       'pst.str(string(" You got to the GET /tntxml "))
       if (dbpause & 1)
         dbdebug:=194
       repeat while(dbdebug==194)
         dbhere:=194
       StringSend(0,string("<?xml version='1.0' encoding='UTF-8'?>"))
       if (dbpause & 1)
         dbdebug:=195
       repeat while(dbdebug==195)
         dbhere:=195
       StringSend(0,string("<nerdDoroData xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>"))
       if (dbpause & 1)
         dbdebug:=196
       repeat while(dbdebug==196)
         dbhere:=196
       StringSend(0,string("<currentTemperature0>80.78432</currentTemperature0>"))
       if (dbpause & 1)
         dbdebug:=197
       repeat while(dbdebug==197)
         dbhere:=197
       StringSend(0,string("<currentMeasuredTime>2011-07-13T15:17:35</currentMeasuredTime>"))
       if (dbpause & 1)
         dbdebug:=198
       repeat while(dbdebug==198)
         dbhere:=198
       StringSend(0,string("</nerdDoroData>"))
       if (dbpause & 1)
         dbdebug:=199
       repeat while(dbdebug==199)
         dbhere:=199
       PauseMSec(5000)
       if (dbpause & 1)
         dbdebug:=200
       repeat while(dbdebug==200)
         dbhere:=200
       htmlEnd
       
  

PUB html
dbstack[++dbstptr]:=1
'--------Generate HTML data to send-------       
    if (dbpause & 2)
      dbdebug:=206
    repeat while(dbdebug==206)
      dbhere:=206
    StringSend(0, @htmlstart)
      'optional HTML header
    if (dbpause & 2)
      dbdebug:=208
    repeat while(dbdebug==208)
      dbhere:=208
    StringSend(0, @htmlopt)
      'HTML Header
    if (dbpause & 2)
      dbdebug:=210
    repeat while(dbdebug==210)
      dbhere:=210
    bytemove (@num1,STR.numberToDecimal(visitor++, 4),5)                        '<-- update visitor number in html code
    if (dbpause & 2)
      dbdebug:=211
    repeat while(dbdebug==211)
      dbhere:=211
    bytemove (@tf, fp.FloatToFormat(fahrenheit(tempC), 5,1),5)                  ' jha update temperature
    if (dbpause & 2)
      dbdebug:=212
    repeat while(dbdebug==212)
      dbhere:=212
    bytemove (@tod,RTC.FmtDateTime,25)                                          ' jha update tod                

    if (dbpause & 2)
      dbdebug:=214
    repeat while(dbdebug==214)
      dbhere:=214
    StringSend(0, @html1)
    if (dbpause & 2)
      dbdebug:=215
    repeat while(dbdebug==215)
      dbhere:=215
    StringSend(0, @html2)
    if (dbpause & 2)
      dbdebug:=216
    repeat while(dbdebug==216)
      dbhere:=216
    StringSend(0, @html3)
    if (dbpause & 2)
      dbdebug:=217
    repeat while(dbdebug==217)
      dbhere:=217
    StringSend(0, @tod)         ' jha
    if (dbpause & 2)
      dbdebug:=218
    repeat while(dbdebug==218)
      dbhere:=218
    StringSend(0, @html4)        
    if (dbpause & 2)
      dbdebug:=219
    repeat while(dbdebug==219)
      dbhere:=219
    StringSend(0, @data[0])
    if (dbpause & 2)
      dbdebug:=220
    repeat while(dbdebug==220)
      dbhere:=220
    StringSend(0, @htmlfin)

dbstack[dbstptr--]~
PUB htmlEnd                  
dbstack[++dbstptr]:=2
    ' we don't support persistent connections, so disconnect here     
    if (dbpause & 4)
      dbdebug:=224
    repeat while(dbdebug==224)
      dbhere:=224
    W5100.SocketTCPdisconnect(0)
    if (dbpause & 4)
      dbdebug:=225
    repeat while(dbdebug==225)
      dbhere:=225
    PauseMSec(25)
    
    'Connection terminated
    if (dbpause & 4)
      dbdebug:=228
    repeat while(dbdebug==228)
      dbhere:=228
    W5100.SocketClose(0)
    'pst.Str(string("Connection complete", PST#NL, PST#NL))

    'Once the connection is closed, need to open socket again
    if (dbpause & 4)
      dbdebug:=232
    repeat while(dbdebug==232)
      dbhere:=232
    OpenSocketAgain(0)

dbstack[dbstptr--]~
PUB updateLCD
dbstack[++dbstptr]:=3

'-------- jha Real Time Clock
     if (dbpause & 8)
       dbdebug:=237
     repeat while(dbdebug==237)
       dbhere:=237
     RTC.Update
     if (dbpause & 8)
       dbdebug:=238
     repeat while(dbdebug==238)
       dbhere:=238
     LCD.str(string(128))                               ' Move cursor to line 0, position 0
     if (dbpause & 8)
       dbdebug:=239
     repeat while(dbdebug==239)
       dbhere:=239
     LCD.str(RTC.ShortFmtDateTime)                      ' print short dateTime

'-------- jha Sensirion
     if (dbpause & 8)
       dbdebug:=242
     repeat while(dbdebug==242)
       dbhere:=242
     rawTemp := f.FFloat(sht.readTemperature)
     if (dbpause & 8)
       dbdebug:=243
     repeat while(dbdebug==243)
       dbhere:=243
     tempC := celsius(rawTemp)
     if (dbpause & 8)
       dbdebug:=244
     repeat while(dbdebug==244)
       dbhere:=244
     LCD.str(string(148))                               ' Move cursor to line 1, position 0 
     if (dbpause & 8)
       dbdebug:=245
     repeat while(dbdebug==245)
       dbhere:=245
     LCD.str(string("Tf In: "))                         ' print temperature in degrees fahrenheit
     if (dbpause & 8)
       dbdebug:=246
     repeat while(dbdebug==246)
       dbhere:=246
     LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))

dbstack[dbstptr--]~
PUB SetButtons                  'Toggle button state and dynamically change html code
dbstack[++dbstptr]:=4
    if (dbpause & 16)
      dbdebug:=249
    repeat while(dbdebug==249)
      dbhere:=249
    If ButtonSelection == 24
       if (dbpause & 16)
         dbdebug:=250
       repeat while(dbdebug==250)
         dbhere:=250
       P24 := 1 - P24
       if (dbpause & 16)
         dbdebug:=251
       repeat while(dbdebug==251)
         dbhere:=251
       outa[24]:= P24
       if (dbpause & 16)
         dbdebug:=252
       repeat while(dbdebug==252)
         dbhere:=252
       isLCDon := 1 - isLCDon
       if (dbpause & 16)
         dbdebug:=253
       repeat while(dbdebug==253)
         dbhere:=253
       if isLCDon <> 0
         if (dbpause & 16)
           dbdebug:=254
         repeat while(dbdebug==254)
           dbhere:=254
         LCD.str(string(17))
       else
         if (dbpause & 16)
           dbdebug:=256
         repeat while(dbdebug==256)
           dbhere:=256
         LCD.str(string(18))
         
    if (dbpause & 16)
      dbdebug:=258
    repeat while(dbdebug==258)
      dbhere:=258
    If ButtonSelection == 25
       if (dbpause & 16)
         dbdebug:=259
       repeat while(dbdebug==259)
         dbhere:=259
       P25 := 1 - P25
       if (dbpause & 16)
         dbdebug:=260
       repeat while(dbdebug==260)
         dbhere:=260
       outa[25]:= P25          
    if (dbpause & 16)
      dbdebug:=261
    repeat while(dbdebug==261)
      dbhere:=261
    If ButtonSelection == 26
       if (dbpause & 16)
         dbdebug:=262
       repeat while(dbdebug==262)
         dbhere:=262
       P26 := 1 - P26
       if (dbpause & 16)
         dbdebug:=263
       repeat while(dbdebug==263)
         dbhere:=263
       outa[26]:= P26          
    if (dbpause & 16)
      dbdebug:=264
    repeat while(dbdebug==264)
      dbhere:=264
    If ButtonSelection == 27
       if (dbpause & 16)
         dbdebug:=265
       repeat while(dbdebug==265)
         dbhere:=265
       P27 := 1 - P27
       if (dbpause & 16)
         dbdebug:=266
       repeat while(dbdebug==266)
         dbhere:=266
       outa[27]:= P27
    if (dbpause & 16)
      dbdebug:=267
    repeat while(dbdebug==267)
      dbhere:=267
    If ButtonSelection == 23  ' jha
       if (dbpause & 16)
         dbdebug:=268
       repeat while(dbdebug==268)
         dbhere:=268
       P23 := 1 - P23         ' toggle Spinneret usr led
       if (dbpause & 16)
         dbdebug:=269
       repeat while(dbdebug==269)
         dbhere:=269
       outa[23]:= P23        
             

    if (dbpause & 16)
      dbdebug:=272
    repeat while(dbdebug==272)
      dbhere:=272
    If P23 == 0                               ' jha
       if (dbpause & 16)
         dbdebug:=273
       repeat while(dbdebug==273)
         dbhere:=273
       bytemove(@buttons[86+bOffSet*4],@RED,5)
    Else
       if (dbpause & 16)
         dbdebug:=275
       repeat while(dbdebug==275)
         dbhere:=275
       bytemove(@buttons[86+70*4],@YELLOW,6)

    if (dbpause & 16)
      dbdebug:=277
    repeat while(dbdebug==277)
      dbhere:=277
    If P24 == 0
       if (dbpause & 16)
         dbdebug:=278
       repeat while(dbdebug==278)
         dbhere:=278
       bytemove(@buttons[86+70*0],@RED,5)
    Else
       if (dbpause & 16)
         dbdebug:=280
       repeat while(dbdebug==280)
         dbhere:=280
       bytemove(@buttons[86+70*0],@GREEN,5)       

    if (dbpause & 16)
      dbdebug:=282
    repeat while(dbdebug==282)
      dbhere:=282
    If P25 == 0
       if (dbpause & 16)
         dbdebug:=283
       repeat while(dbdebug==283)
         dbhere:=283
       bytemove(@buttons[86+70*1],@RED,5)
    Else
       if (dbpause & 16)
         dbdebug:=285
       repeat while(dbdebug==285)
         dbhere:=285
       bytemove(@buttons[86+70*1],@GREEN,5)

    if (dbpause & 16)
      dbdebug:=287
    repeat while(dbdebug==287)
      dbhere:=287
    If P26 == 0
       if (dbpause & 16)
         dbdebug:=288
       repeat while(dbdebug==288)
         dbhere:=288
       bytemove(@buttons[86+70*2],@RED,5)
    Else
       if (dbpause & 16)
         dbdebug:=290
       repeat while(dbdebug==290)
         dbhere:=290
       bytemove(@buttons[86+70*2],@GREEN,5)

    if (dbpause & 16)
      dbdebug:=292
    repeat while(dbdebug==292)
      dbhere:=292
    If P27 == 0
       if (dbpause & 16)
         dbdebug:=293
       repeat while(dbdebug==293)
         dbhere:=293
       bytemove(@buttons[86+70*3],@RED,5)
    Else
       if (dbpause & 16)
         dbdebug:=295
       repeat while(dbdebug==295)
         dbhere:=295
       bytemove(@buttons[86+70*3],@GREEN,5)

dbstack[dbstptr--]~
PUB Wiznet5100
dbstack[++dbstptr]:=5
  ' init the Wiznet 5100 chip
  if (dbpause & 32)
    dbdebug:=299
  repeat while(dbdebug==299)
    dbhere:=299
  W5100.StartINDIRECT(W5100_DATA0, W5100_ADDR0, W5100_ADDR1, W5100_CS, W5100_RD, W5100_WR, W5100_RST, W5100_SEN)
  ' setup the address information we got from DHCP
  if (dbpause & 32)
    dbdebug:=301
  repeat while(dbdebug==301)
    dbhere:=301
  W5100.InitAddresses(true, @MAC_Address[0], @GatewayIP[0], @SubnetMask[0], @IP[0])
  ' open a socket for TCP
  if (dbpause & 32)
    dbdebug:=303
  repeat while(dbdebug==303)
    dbhere:=303
  W5100.SocketOpen(0, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  'Wait a moment for the socket to get established
  if (dbpause & 32)
    dbdebug:=305
  repeat while(dbdebug==305)
    dbhere:=305
  PauseMSec(250)
  if (dbpause & 32)
    dbdebug:=306
  repeat while(dbdebug==306)
    dbhere:=306
  ReadStatus(0)
  if (dbpause & 32)
    dbdebug:=307
  repeat while(dbdebug==307)
    dbhere:=307
  W5100.SocketTCPlisten(0)
  'Wait a moment for the socket to listen
  if (dbpause & 32)
    dbdebug:=309
  repeat while(dbdebug==309)
    dbhere:=309
  PauseMSec(250)
  if (dbpause & 32)
    dbdebug:=310
  repeat while(dbdebug==310)
    dbhere:=310
  ReadStatus(0)

dbstack[dbstptr--]~
PUB celsius(t)
dbstack[++dbstptr]:=6
  ' from SHT1x/SHT7x datasheet using value for 3.5V supply
  ' celsius = -39.7 + (0.01 * t)
  dbstack[dbstptr--]~
  return f.FAdd(-39.7, f.FMul(0.01, t))

dbstack[dbstptr--]~
PUB fahrenheit(t)
dbstack[++dbstptr]:=7
  ' fahrenheit = (celsius * 1.8) + 32
  dbstack[dbstptr--]~
  return f.FAdd(f.FMul(t, 1.8), 32.0)  

dbstack[dbstptr--]~
DAT
'-----------------------------------------------
IP            long
                        byte  0,0,0,0
SubnetMask    long
                        byte  0,0,0,0
GatewayIP     long
                        byte  0,0,0,0
DNS_Server    long
                        byte  0,0,0,0
destIP        long
                        byte  0,0,0,0                                                           
'-----------------------------------------------
P23     byte  0 ' jha
P24     byte  0 
P25     byte  0
P26     byte  0
P27     byte  0
RED     byte  "RED  ",0
GREEN   byte  "GREEN",0
YELLOW   byte  "YELLOW",0
isLCDon byte 0

d1      byte  "  ",0

'-----------------------------------------------
'     Pseudo HTML code below ... some quirks, but relatively basic and straight forward
'
'     Note: browser recognizes single quotes instead of double quotes (makes code less messy) 
'
htmlstart
        byte  "HTTP/1.1 200 OK", CR, LF,0
'--------------------------------------------------------------------------------------        
htmlopt byte  "You have connected to PARELECTS Spinneret Web Server ... "
        byte  "Next meeting is January 4th, 2011",CR
        byte  "Connection: close",CR
        byte  "Content-Type: text/html", CR, LF,CR,LF,0
'--------------------------------------------------------------------------------------
html1   byte  "<HTML>"
        byte  "<HEAD>"
        byte  "<TITLE>nerdDoro</TITLE>"
        byte  "</HEAD>"

        byte  "<SCRIPT TYPE='text/javascript'>"
        byte  " Temp3 = 0",CR

        byte  " function StartJava() {"
        byte  " Graphics();",CR        
        byte  " Counter();",CR
        byte  " }"

        byte  " function Graphics() {"
        byte  "canvas=document.getElementById('canvas');",CR
        byte  "if(!canvas.getContext){return;}",CR
        byte  "ctx=canvas.getContext('2d');",CR
        byte  "ctx.fillStyle='rgb(200,0,0)';",CR
        byte  "ctx.fillRect(10,10,55,50);",CR
        byte  "ctx.fillStyle='rgba(0,0,200,0.5)';",CR
        byte  "ctx.fillRect(30,30,55,50) }",CR

        byte  " function Counter() {"
        byte  " Temp3 = Temp3 + 1;",CR
        byte  " document.frm1.seconds.value=Temp3;",CR
        byte  " timerID = setTimeout('Counter()',1000) }"
        byte  "</SCRIPT>"
        byte  0 
            
html2   byte  "<BODY style=background-color:grey; Onload='StartJava()'>"
        byte  "<noscript>NOTE: Your browser does not support JavaScript or support has been turned off. Sorry!</noscript>"

        byte  "<FONT FACE=ARIAL SIZE=3><BR>a little bit of JavaScript Graphics<BR></FONT>"
        byte  "<canvas id='canvas' width='100' height='100'>Sorry! - Browser does not support Graphics Canvas</canvas>"

'        byte  "<a href='http://www.rodaw.com'>"
        byte  "<a href='/'>"  
        byte  "<img src='http://1.gravatar.com/avatar/3901ec164a8022fa0f7d34f9d41935d9' />"
        byte  "</a> Hi Mom!"

        byte  "<FONT FACE=ARIAL SIZE=8><BR>nerdDoro Spinneret<BR></FONT>"

        byte  "<FONT FACE=ARIAL SIZE=4><BR>"                                       
        byte  "<FORM NAME='frm1'>"
        byte  "This connection elapsed Seconds ="
        byte  "<INPUT NAME='seconds' SIZE=4 VALUE=''>"
        byte  "</FORM>"
        byte  "</FONT>"
        byte  0

html3   byte  "<FONT FACE=ARIAL SIZE=4><BR>"
        byte  "A Parallax Spinneret propeller/Wiznet clock and environment sensing and reporting."
        byte  "<BR><BR></FONT>"

tnt     byte  "<form action='tnt' method='GET'>"

        byte  "<input type='hidden' id='measuredTime' name='measuredTime' value='"

tntD    byte  "2011-01-03T03:41:02' />"
        byte  "<input type='hidden' id='tf' name='tf' value='"
tntT    byte  "86.4'/>"

        byte  "<button type='submit' value='tnt'>tnt</button>"
        byte  "</form>"
        
        byte  "<FONT FACE=ARIAL SIZE=4 COLOR=RED><BR>You are visitor number: "
num1    byte  "0000 <BR>" '<--- This is a place holder ; number is dynamically updated
        byte  "</FONT>"
        byte  "<FONT FACE=ARIAL SIZE=2<BR>"
        byte  "Note: if the above number has been reset, "
        byte  "I've probably changed something in the code and testing something new :-)</FONT>"
        byte  "<FONT FACE=ARIAL SIZE=4><BR>"
        byte  "<FORM ACTION='name_action'METHOD='get'>"
        byte  "First name: <INPUT TYPE='text' NAME='fname' /><BR>"
        byte  "Last name: <INPUT TYPE='text' NAME='lname' /><BR>"
        byte  "<BUTTON TYPE='submit' VALUE='Submit'>Submit</BUTTON>"
        byte  "<BUTTON TYPE='reset' VALUE='Reset'>Reset</BUTTON>"
        byte  "</FORM></FONT>"
        byte  "<FONT FACE=ARIAL SIZE=2<BR><br>"                                         
        byte  "It's "
tf      byte  "      "
        'byte  0        
        byte  "degrees farenheight when the page was loaded at: "
        byte  0
tod     byte  "                                                  <br><br>"
        byte  0 
html4   byte  "P24 will toggle the back light on the LCD<br><BR>"
buttons
        byte  "<FORM ACTION='button_action'method='get'>"
    {86}byte  "<BUTTON TYPE='submit' NAME='P24'><FONT COLOR=RED  >P24</FONT></BUTTON>"
    {64}byte  "<BUTTON TYPE='submit' NAME='P25'><FONT COLOR=RED  >P25</FONT></BUTTON>"
    {64}byte  "<BUTTON TYPE='submit' NAME='P26'><FONT COLOR=RED  >P26</FONT></BUTTON>"
    {64}byte  "<BUTTON TYPE='submit' NAME='P27'><FONT COLOR=RED  >P27</FONT></BUTTON>"
   {foo}byte  "<BUTTON TYPE='submit' NAME='P23'><FONT COLOR=RED   >LED</FONT></BUTTON>"
'                                                           
        byte  "</FORM>"'          This area is dynamically updated in "PUB SetButtons"
        byte  "<FONT FACE=ARIAL SIZE=1<BR>"
        byte  "The buttons above are parsed in SPIN code and HTML is generated on the fly, "
        byte  "so the Spinneret Web server is totally aware of the button values.<BR>"
        byte  "</FONT>"
        byte  "<FONT FACE=ARIAL SIZE=2<BR><BR>Packet data from your browser: "
        byte  "(normally you don't see this in the browser, it's what the Spinneret Web Server "
        byte  "'Sees' and is only here for DEBUG)<BR><BR>"
        byte  0
htmlfin
        byte  "</FONT>"
        byte  "</BODY>"
        byte  "</HTML>"
        byte  0
 
PRI StringSend(socket, _dataPtr)
dbstptr:=-1
  if (dbpause & 1)
    dbdebug:=470
  repeat while(dbdebug==470)
    dbhere:=470
  W5100.txTCP(socket, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain(socket)
dbstack[++dbstptr]:=1
  if (dbpause & 2)
    dbdebug:=473
  repeat while(dbdebug==473)
    dbhere:=473
  W5100.SocketOpen(socket, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  if (dbpause & 2)
    dbdebug:=474
  repeat while(dbdebug==474)
    dbhere:=474
  W5100.SocketTCPlisten(socket)

dbstack[dbstptr--]~
PRI ReadStatus(socket) | status
dbstack[++dbstptr]:=2
  'pst.Str(string("Socket "))
  'pst.Dec(socket)
  'pst.STR(string(" Status Register: "))
  if (dbpause & 4)
    dbdebug:=480
  repeat while(dbdebug==480)
    dbhere:=480
  W5100.readIND((W5100#_S0_SR + (socket * $0100)), @status, 1)

{{
  if (dbpause & 4)
    dbdebug:=483
  repeat while(dbdebug==483)
    dbhere:=483
  case status
    W5100#_SOCK_CLOSED :if (dbpause & 4)
        dbdebug:=484
      repeat while(dbdebug==484)
        dbhere:=484
      PST.Str(string("$00 - socket closed", PST#NL, PST#NL))
    W5100#_SOCK_INIT   :if (dbpause & 4)
        dbdebug:=485
      repeat while(dbdebug==485)
        dbhere:=485
      PST.Str(string("$13 - socket initialized", PST#NL, PST#NL))
    W5100#_SOCK_LISTEN :if (dbpause & 4)
        dbdebug:=486
      repeat while(dbdebug==486)
        dbhere:=486
      PST.Str(string("$14 - socket listening", PST#NL, PST#NL))
    W5100#_SOCK_ESTAB  :if (dbpause & 4)
        dbdebug:=487
      repeat while(dbdebug==487)
        dbhere:=487
      PST.Str(string("$17 - socket established", PST#NL, PST#NL))    
    W5100#_SOCK_UDP    :if (dbpause & 4)
        dbdebug:=488
      repeat while(dbdebug==488)
        dbhere:=488
      PST.Str(string("$22 - socket UDP open", PST#NL, PST#NL))
}}
  dbstack[dbstptr--]~
  return status
  
dbstack[dbstptr--]~
PRI PauseMSec(Duration)
dbstack[++dbstptr]:=3
'***************************************
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  if (dbpause & 8)
    dbdebug:=500
  repeat while(dbdebug==500)
    dbhere:=500
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

if (dbpause & 8)
  dbdebug:=502
repeat while(dbdebug==502)
  dbhere:=502
CON
{{
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                     │                                                            
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and  │
│associated documentation files (the "Software"), to deal in the Software without restriction,      │
│including without limitation the rights to use, copy, modify, merge, publish, distribute,          │
│sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is      │
│furnished to do so, subject to the following conditions:                                           │
│                                                                                                   │
│The above copyright notice and this permission notice shall be included in all copies or           │
│ substantial portions of the Software.                                                             │
│                                                                                                   │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT  │
│NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND             │
│NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,       │
│DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,                   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE        │
│SOFTWARE.                                                                                          │     
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
}}  
dbstack[dbstptr--]~
