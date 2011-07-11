{{
Spinneret Web Server nerdDoro     v0.5 

https://github.com/jhalbrecht/nerdDoro 

Author: Jeff Albrecht                  
 Began July 10, 2011                   
 Revision History:
 July 10, 2011 1430 - jeffa
  Version 0.5  Begun based on Beau Schwabe Spinneret_Web_Server_DEMOv1.2
 July 10, 2011 1700
  commited to github. Added button for user LED 


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

  CR          = 13
  LF          = 10
  
  bytebuffersize = 2048
  maxPacketSendSize = 2032
  listenPort = 80
    
OBJ
  DHCPClient    : "DHCP"
  W5100         : "Brilldea_W5100_Indirect_Driver_Ver006.spin"
'  vp           : "Parallax Serial Terminal"
  STR           : "STREngine"
  RTC           : "s-35390A_GBSbuild_02_09_2011"
  LCD           : "FullDuplexSerial.spin"
  vp            : "terminal"  
  

VAR
  long dbstack[5],dbhere,dbdebug,dbpause,dbstptr
  long  visitor,strpointer,ButtonSelection
  byte MAC_Address[6]
  byte data[bytebuffersize]

PUB main | packetSize
dbstptr:=-1

 vp.config(string("start:terminal::terminal:1"))
 vp.debug(@dbstack,@dbhere)
 vp.share(@visitor,@ButtonSelection)          'share variable

  'vp.Start(115200)               '<-- Initialize Serial Communication to PC (debug)
  ' Network Settings

  if (dbpause & 1)
    dbdebug:=82
  repeat while(dbdebug==82)
    dbhere:=82
  IP             := $96_08_09_0A  ' IP:10.9.8.150, LAN:spinneret.jeffa.org, WAN:jeffa.org:90
  if (dbpause & 1)
    dbdebug:=83
  repeat while(dbdebug==83)
    dbhere:=83
  SubnetMask     := $00_FF_FF_FF  ' enter as little-endian in hex 
  if (dbpause & 1)
    dbdebug:=84
  repeat while(dbdebug==84)
    dbhere:=84
  GatewayIP      := $FE_08_09_0A  
  if (dbpause & 1)
    dbdebug:=85
  repeat while(dbdebug==85)
    dbhere:=85
  DNS_Server     := $FE_08_09_0A  
  if (dbpause & 1)
    dbdebug:=86
  repeat while(dbdebug==86)
    dbhere:=86
  destIP         := $00_00_00_00  
  
  ' MAC Address
  if (dbpause & 1)
    dbdebug:=89
  repeat while(dbdebug==89)
    dbhere:=89
  MAC_Address[0] := $00
  if (dbpause & 1)
    dbdebug:=90
  repeat while(dbdebug==90)
    dbhere:=90
  MAC_Address[1] := $08
  if (dbpause & 1)
    dbdebug:=91
  repeat while(dbdebug==91)
    dbhere:=91
  MAC_Address[2] := $DC 
  if (dbpause & 1)
    dbdebug:=92
  repeat while(dbdebug==92)
    dbhere:=92
  MAC_Address[3] := $16 
  if (dbpause & 1)
    dbdebug:=93
  repeat while(dbdebug==93)
    dbhere:=93
  MAC_Address[4] := $EF 
  if (dbpause & 1)
    dbdebug:=94
  repeat while(dbdebug==94)
    dbhere:=94
  MAC_Address[5] := $81    

  if (dbpause & 1)
    dbdebug:=96
  repeat while(dbdebug==96)
    dbhere:=96
  PauseMSec(2000)                 '<-- Allow 2 seconds after programming to start the vp. 
  
  'Initialize Wiznet 5100 chip 
  if (dbpause & 1)
    dbdebug:=99
  repeat while(dbdebug==99)
    dbhere:=99
  Wiznet5100

  'Initialize vp screen
  if (dbpause & 1)
    dbdebug:=102
  repeat while(dbdebug==102)
    dbhere:=102
  vp.Home
  if (dbpause & 1)
    dbdebug:=103
  repeat while(dbdebug==103)
    dbhere:=103
  vp.Clear

  'Set Auxiliary I/O's for output (debug) 
'  Dira[24..27]~~
'  Outa[24..27]~

  if (dbpause & 1)
    dbdebug:=109
  repeat while(dbdebug==109)
    dbhere:=109
  Dira[23..27]~~
  if (dbpause & 1)
    dbdebug:=110
  repeat while(dbdebug==110)
    dbhere:=110
  Outa[23..27]~

    if (dbpause & 1)
      dbdebug:=112
    repeat while(dbdebug==112)
      dbhere:=112
    vp.str(string("hi jeffa",12,13))
    if (dbpause & 1)
      dbdebug:=113
    repeat while(dbdebug==113)
      dbhere:=113
    RTC.Update
    if (dbpause & 1)
      dbdebug:=114
    repeat while(dbdebug==114)
      dbhere:=114
    LCD.str(RTC.FmtDateTime)
    if (dbpause & 1)
      dbdebug:=115
    repeat while(dbdebug==115)
      dbhere:=115
    vp.str(RTC.FmtDateTime)

 'Infinite loop of the server ; listen on the TCP socket 
  if (dbpause & 1)
    dbdebug:=118
  repeat while(dbdebug==118)
    dbhere:=118
  repeat

    if (dbpause & 1)
      dbdebug:=120
    repeat while(dbdebug==120)
      dbhere:=120
    vp.Str(string("Waiting for a client to connect....", vp#NL))
    if (dbpause & 1)
      dbdebug:=121
    repeat while(dbdebug==121)
      dbhere:=121
    repeat while !W5100.SocketTCPestablished(0)

    if (dbpause & 1)
      dbdebug:=123
    repeat while(dbdebug==123)
      dbhere:=123
    vp.Str(string("connection established...", vp#NL))
    if (dbpause & 1)
      dbdebug:=124
    repeat while(dbdebug==124)
      dbhere:=124
    vp.dec(visitor)
    if (dbpause & 1)
      dbdebug:=125
    repeat while(dbdebug==125)
      dbhere:=125
    vp.Char(13)

    'Initialize the buffers and bring the data over
    if (dbpause & 1)
      dbdebug:=128
    repeat while(dbdebug==128)
      dbhere:=128
    bytefill(@data, 0, bytebuffersize)    
    if (dbpause & 1)
      dbdebug:=129
    repeat while(dbdebug==129)
      dbhere:=129
    repeat
      if (dbpause & 1)
        dbdebug:=130
      repeat while(dbdebug==130)
        dbhere:=130
      packetSize := W5100.rxTCP(0, @data)
    while packetSize == 0  

    if (dbpause & 1)
      dbdebug:=133
    repeat while(dbdebug==133)
      dbhere:=133
    vp.Str(string("Packet from browser:", vp#NL))
    if (dbpause & 1)
      dbdebug:=134
    repeat while(dbdebug==134)
      dbhere:=134
    vp.Str(@data[0])

  ' jha
    ' RTC.Update
    ' LCD.str(RTC.FmtDateTime)

'--------Parse Data Packet for Button Press-------
    if (dbpause & 1)
      dbdebug:=141
    repeat while(dbdebug==141)
      dbhere:=141
    strpointer := STR.findCharacters(@data[0], string("GET /button_action"))
    if (dbpause & 1)
      dbdebug:=142
    repeat while(dbdebug==142)
      dbhere:=142
    if strpointer<>0
       if (dbpause & 1)
         dbdebug:=143
       repeat while(dbdebug==143)
         dbhere:=143
       bytemove(@d1,@data[20],2)
       if (dbpause & 1)
         dbdebug:=144
       repeat while(dbdebug==144)
         dbhere:=144
       ButtonSelection := STR.decimalToNumber(@d1)
       if (dbpause & 1)
         dbdebug:=145
       repeat while(dbdebug==145)
         dbhere:=145
       SetButtons

'--------Generate HTML data to send-------       
    if (dbpause & 1)
      dbdebug:=148
    repeat while(dbdebug==148)
      dbhere:=148
    StringSend(0, @htmlstart)
      'optional HTML header
    if (dbpause & 1)
      dbdebug:=150
    repeat while(dbdebug==150)
      dbhere:=150
    StringSend(0, @htmlopt)
      'HTML Header
    if (dbpause & 1)
      dbdebug:=152
    repeat while(dbdebug==152)
      dbhere:=152
    bytemove (@num1,STR.numberToDecimal(visitor++, 4),5) '<-- update visitor number in html code                 
    if (dbpause & 1)
      dbdebug:=153
    repeat while(dbdebug==153)
      dbhere:=153
    StringSend(0, @html1)
    if (dbpause & 1)
      dbdebug:=154
    repeat while(dbdebug==154)
      dbhere:=154
    StringSend(0, @html2)
    if (dbpause & 1)
      dbdebug:=155
    repeat while(dbdebug==155)
      dbhere:=155
    StringSend(0, @html3)
    if (dbpause & 1)
      dbdebug:=156
    repeat while(dbdebug==156)
      dbhere:=156
    StringSend(0, @html4)        
    if (dbpause & 1)
      dbdebug:=157
    repeat while(dbdebug==157)
      dbhere:=157
    StringSend(0, @data[0])
    if (dbpause & 1)
      dbdebug:=158
    repeat while(dbdebug==158)
      dbhere:=158
    StringSend(0, @htmlfin)
                  
    ' we don't support persistent connections, so disconnect here     
    if (dbpause & 1)
      dbdebug:=161
    repeat while(dbdebug==161)
      dbhere:=161
    W5100.SocketTCPdisconnect(0)
    if (dbpause & 1)
      dbdebug:=162
    repeat while(dbdebug==162)
      dbhere:=162
    PauseMSec(25)
    
    'Connection terminated
    if (dbpause & 1)
      dbdebug:=165
    repeat while(dbdebug==165)
      dbhere:=165
    W5100.SocketClose(0)
    if (dbpause & 1)
      dbdebug:=166
    repeat while(dbdebug==166)
      dbhere:=166
    vp.Str(string("Connection complete", vp#NL, vp#NL))

    'Once the connection is closed, need to open socket again
    if (dbpause & 1)
      dbdebug:=169
    repeat while(dbdebug==169)
      dbhere:=169
    OpenSocketAgain(0)

PUB SetButtons                  'Toggle button state and dynamically change html code
dbstack[++dbstptr]:=1
    if (dbpause & 2)
      dbdebug:=172
    repeat while(dbdebug==172)
      dbhere:=172
    If ButtonSelection == 24
       if (dbpause & 2)
         dbdebug:=173
       repeat while(dbdebug==173)
         dbhere:=173
       P24 := 1 - P24
       if (dbpause & 2)
         dbdebug:=174
       repeat while(dbdebug==174)
         dbhere:=174
       outa[24]:= P24
    if (dbpause & 2)
      dbdebug:=175
    repeat while(dbdebug==175)
      dbhere:=175
    If ButtonSelection == 25
       if (dbpause & 2)
         dbdebug:=176
       repeat while(dbdebug==176)
         dbhere:=176
       P25 := 1 - P25
       if (dbpause & 2)
         dbdebug:=177
       repeat while(dbdebug==177)
         dbhere:=177
       outa[25]:= P25          
    if (dbpause & 2)
      dbdebug:=178
    repeat while(dbdebug==178)
      dbhere:=178
    If ButtonSelection == 26
       if (dbpause & 2)
         dbdebug:=179
       repeat while(dbdebug==179)
         dbhere:=179
       P26 := 1 - P26
       if (dbpause & 2)
         dbdebug:=180
       repeat while(dbdebug==180)
         dbhere:=180
       outa[26]:= P26          
    if (dbpause & 2)
      dbdebug:=181
    repeat while(dbdebug==181)
      dbhere:=181
    If ButtonSelection == 27
       if (dbpause & 2)
         dbdebug:=182
       repeat while(dbdebug==182)
         dbhere:=182
       P27 := 1 - P27
       if (dbpause & 2)
         dbdebug:=183
       repeat while(dbdebug==183)
         dbhere:=183
       outa[27]:= P27
    if (dbpause & 2)
      dbdebug:=184
    repeat while(dbdebug==184)
      dbhere:=184
    If ButtonSelection == 23  ' jha
       if (dbpause & 2)
         dbdebug:=185
       repeat while(dbdebug==185)
         dbhere:=185
       P23 := 1 - P23
       if (dbpause & 2)
         dbdebug:=186
       repeat while(dbdebug==186)
         dbhere:=186
       outa[23]:= P23        
             

    if (dbpause & 2)
      dbdebug:=189
    repeat while(dbdebug==189)
      dbhere:=189
    If P23 == 0                               ' jha
       if (dbpause & 2)
         dbdebug:=190
       repeat while(dbdebug==190)
         dbhere:=190
       bytemove(@buttons[86+70*4],@RED,5)
    Else
       if (dbpause & 2)
         dbdebug:=192
       repeat while(dbdebug==192)
         dbhere:=192
       bytemove(@buttons[86+70*4],@YELLOW,6)

    if (dbpause & 2)
      dbdebug:=194
    repeat while(dbdebug==194)
      dbhere:=194
    If P24 == 0
       if (dbpause & 2)
         dbdebug:=195
       repeat while(dbdebug==195)
         dbhere:=195
       bytemove(@buttons[86+70*0],@RED,5)
    Else
       if (dbpause & 2)
         dbdebug:=197
       repeat while(dbdebug==197)
         dbhere:=197
       bytemove(@buttons[86+70*0],@GREEN,5)       

    if (dbpause & 2)
      dbdebug:=199
    repeat while(dbdebug==199)
      dbhere:=199
    If P25 == 0
       if (dbpause & 2)
         dbdebug:=200
       repeat while(dbdebug==200)
         dbhere:=200
       bytemove(@buttons[86+70*1],@RED,5)
    Else
       if (dbpause & 2)
         dbdebug:=202
       repeat while(dbdebug==202)
         dbhere:=202
       bytemove(@buttons[86+70*1],@GREEN,5)

    if (dbpause & 2)
      dbdebug:=204
    repeat while(dbdebug==204)
      dbhere:=204
    If P26 == 0
       if (dbpause & 2)
         dbdebug:=205
       repeat while(dbdebug==205)
         dbhere:=205
       bytemove(@buttons[86+70*2],@RED,5)
    Else
       if (dbpause & 2)
         dbdebug:=207
       repeat while(dbdebug==207)
         dbhere:=207
       bytemove(@buttons[86+70*2],@GREEN,5)

    if (dbpause & 2)
      dbdebug:=209
    repeat while(dbdebug==209)
      dbhere:=209
    If P27 == 0
       if (dbpause & 2)
         dbdebug:=210
       repeat while(dbdebug==210)
         dbhere:=210
       bytemove(@buttons[86+70*3],@RED,5)
    Else
       if (dbpause & 2)
         dbdebug:=212
       repeat while(dbdebug==212)
         dbhere:=212
       bytemove(@buttons[86+70*3],@GREEN,5)

dbstack[dbstptr--]~
PUB Wiznet5100
dbstack[++dbstptr]:=2
  ' init the Wiznet 5100 chip
  if (dbpause & 4)
    dbdebug:=216
  repeat while(dbdebug==216)
    dbhere:=216
  W5100.StartINDIRECT(W5100_DATA0, W5100_ADDR0, W5100_ADDR1, W5100_CS, W5100_RD, W5100_WR, W5100_RST, W5100_SEN)
  ' setup the address information we got from DHCP
  if (dbpause & 4)
    dbdebug:=218
  repeat while(dbdebug==218)
    dbhere:=218
  W5100.InitAddresses(true, @MAC_Address[0], @GatewayIP[0], @SubnetMask[0], @IP[0])
  ' open a socket for TCP
  if (dbpause & 4)
    dbdebug:=220
  repeat while(dbdebug==220)
    dbhere:=220
  W5100.SocketOpen(0, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  'Wait a moment for the socket to get established
  if (dbpause & 4)
    dbdebug:=222
  repeat while(dbdebug==222)
    dbhere:=222
  PauseMSec(250)
  if (dbpause & 4)
    dbdebug:=223
  repeat while(dbdebug==223)
    dbhere:=223
  ReadStatus(0)
  if (dbpause & 4)
    dbdebug:=224
  repeat while(dbdebug==224)
    dbhere:=224
  W5100.SocketTCPlisten(0)
  'Wait a moment for the socket to listen
  if (dbpause & 4)
    dbdebug:=226
  repeat while(dbdebug==226)
    dbhere:=226
  PauseMSec(250)
  if (dbpause & 4)
    dbdebug:=227
  repeat while(dbdebug==227)
    dbhere:=227
  ReadStatus(0)

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
        byte  "<FONT FACE=ARIAL SIZE=2<BR>"
        byte  0

html4   byte  "Let's wiggle a few Auxiliary I/O pins on the Spinneret Side of things... "
        byte  "Ohh but wait you can't see any of that  :-(<BR>"
        byte  "If Only I had a web-enabled video camera .... Hmmm<BR>"
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
    dbdebug:=359
  repeat while(dbdebug==359)
    dbhere:=359
  W5100.txTCP(socket, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain(socket)
dbstack[++dbstptr]:=1
  if (dbpause & 2)
    dbdebug:=362
  repeat while(dbdebug==362)
    dbhere:=362
  W5100.SocketOpen(socket, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  if (dbpause & 2)
    dbdebug:=363
  repeat while(dbdebug==363)
    dbhere:=363
  W5100.SocketTCPlisten(socket)

dbstack[dbstptr--]~
PRI ReadStatus(socket) | status
dbstack[++dbstptr]:=2
  if (dbpause & 4)
    dbdebug:=366
  repeat while(dbdebug==366)
    dbhere:=366
  vp.Str(string("Socket "))
  if (dbpause & 4)
    dbdebug:=367
  repeat while(dbdebug==367)
    dbhere:=367
  vp.Dec(socket)
  if (dbpause & 4)
    dbdebug:=368
  repeat while(dbdebug==368)
    dbhere:=368
  vp.STR(string(" Status Register: "))
  if (dbpause & 4)
    dbdebug:=369
  repeat while(dbdebug==369)
    dbhere:=369
  W5100.readIND((W5100#_S0_SR + (socket * $0100)), @status, 1)

  if (dbpause & 4)
    dbdebug:=371
  repeat while(dbdebug==371)
    dbhere:=371
  case status
    W5100#_SOCK_CLOSED :if (dbpause & 4)
        dbdebug:=372
      repeat while(dbdebug==372)
        dbhere:=372
      vp.Str(string("$00 - socket closed", vp#NL, vp#NL))
    W5100#_SOCK_INIT   :if (dbpause & 4)
        dbdebug:=373
      repeat while(dbdebug==373)
        dbhere:=373
      vp.Str(string("$13 - socket initialized", vp#NL, vp#NL))
    W5100#_SOCK_LISTEN :if (dbpause & 4)
        dbdebug:=374
      repeat while(dbdebug==374)
        dbhere:=374
      vp.Str(string("$14 - socket listening", vp#NL, vp#NL))
    W5100#_SOCK_ESTAB  :if (dbpause & 4)
        dbdebug:=375
      repeat while(dbdebug==375)
        dbhere:=375
      vp.Str(string("$17 - socket established", vp#NL, vp#NL))    
    W5100#_SOCK_UDP    :if (dbpause & 4)
        dbdebug:=376
      repeat while(dbdebug==376)
        dbhere:=376
      vp.Str(string("$22 - socket UDP open", vp#NL, vp#NL))

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
    dbdebug:=388
  repeat while(dbdebug==388)
    dbhere:=388
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

if (dbpause & 8)
  dbdebug:=390
repeat while(dbdebug==390)
  dbhere:=390
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
