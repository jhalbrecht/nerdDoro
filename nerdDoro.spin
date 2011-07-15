{{

Spinneret Web Server; 'nerdDoro'     v0.5 

https://github.com/jhalbrecht/nerdDoro 

Author: Jeff Albrecht                  
 Began July 10, 2011                   
 Revision History:

 July 15, 2011
  Modified main loop logic for if/elseif/if
  added /xml to display a dummy xml of time and temperature 
 
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
  
  TX_PIN        = 22                                    ' jha for serial LCD   
  BAUD          = 19_200
  
  SHT_DATA      = 24 ' 29                               ' SHT-11 data pin
  SHT_CLOCK     = 25 ' 28                               ' SHT-11 clock pin
  
  bOffSet = 70
  
  CR          = 13
  LF          = 10

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
  PST           : "Parallax Serial Terminal"
  STR           : "STREngine"
  RTC           : "s-35390A_GBSbuild_02_09_2011"
  LCD           : "FullDuplexSerial.spin"
'  vp            : "terminal"
  sht           : "Sensirion_full"
  fp            : "FloatString"
  f             : "Float32"

VAR

  long  visitor, strpointer, ButtonSelection, rawTemp, tempC
  byte  MAC_Address[6]
  byte  data[bytebuffersize]

PUB main | packetSize

  LCD.start(TX_PIN, TX_PIN, %1000, 19_200)
  waitcnt(clkfreq / 100 + cnt)                ' Pause for FullDuplexSerial.spin to initialize
  sht.start(SHT_DATA, SHT_CLOCK)              ' start sensirion object
  waitcnt(clkfreq*3+cnt)
  sht.config(50 ,sht#off,sht#yes,sht#hires)   'configure SHT-11
  f.start 
 
 'vp.config(string("start:terminal::terminal:1"))
 'vp.share(@visitor,@strpointer)    

  pst.Start(115200)               '<-- Initialize Serial Communication to PC (debug)

' Network Settings
  IP             := $96_08_09_0A  ' IP:10.9.8.150, LAN:spinneret.jeffa.org, WAN:jeffa.org:90
  SubnetMask     := $00_FF_FF_FF  ' enter as little-endian in hex 
  GatewayIP      := $FE_08_09_0A  
  DNS_Server     := $FE_08_09_0A  
  destIP         := $00_00_00_00  
  
  ' MAC Address. See sticker on the bottom of the Spinneret
  MAC_Address[0] := $00
  MAC_Address[1] := $08
  MAC_Address[2] := $DC 
  MAC_Address[3] := $16
  MAC_Address[4] := $F1 
  MAC_Address[5] := $B2    

'  PauseMSec(2000)                 '<-- Allow 2 seconds after programming to start the PST. 
  
  'Initialize Wiznet 5100 chip 
  Wiznet5100

  'Initialize PST screen
  pst.Home
  pst.Clear

  Dira[23]~~  'Set Auxiliary I/O's for output (debug) 
  Outa[23]~
  
  RTC.Update                    ' read the rtc
  LCD.str(string(17))           ' backlight on
  PauseMSec(250) 
  LCD.str(string(12))           ' cls
  PauseMSec(250)
  LCD.str(string(22))           ' Turn the display on, with cursor off and no blink
  PauseMSec(250)
  LCD.str(string(128))          ' Move cursor to line 0, position 0
  LCD.str(RTC.ShortFmtDateTime)
  LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))

{{
********************************************************************
*      Infinite loop of the server ; listen on the TCP socket      *
********************************************************************                                
}}

  repeat

    PST.Str(string("Waiting for a client to connect....", PST#NL))
    repeat
      updateLCD ' update LCD with date time and temperature.                                         
    while !W5100.SocketTCPestablished(0)
                                                                            
    pst.Str(string("connection established...", PST#NL))
    pst.str(string(" visitor "))
    pst.dec(visitor)
    pst.Char(13)

    'Initialize the buffers and bring the data over
    bytefill(@data, 0, bytebuffersize)    
    repeat
      packetSize := W5100.rxTCP(0, @data)
    while packetSize == 0  

    pst.Str(string("Packet from browser:", PST#NL))
    pst.Str(@data[0])

'                               *** GET /button_action ***

    ' pst.str(@data)
      if STR.findCharacters(@data[0], string("GET /button_action")) <> 0
      
          bytemove(@d1,@data[20],2)
          ButtonSelection := STR.decimalToNumber(@d1)
          SetButtons
          defaultHtml

'                               *** GET /xml

      elseif STR.findCharacters(@data[0], string("GET /xml")) <> 0
 
          pst.str(@data)
          'bytemove (@tntT,string("66.6"), 4)
          'bytemove (@tntT, fp.FloatToFormat(fahrenheit(tempC), 5,1), 4)                  ' jha update temperature
          'bytemove (@tntD,string("2011-07-13T02:34:12"), 19)
           pst.str(string(" You got to the GET /xml "))
           StringSend(0,@xml)

      else
           defaultHtml

    htmlEnd

pub defaultHtml
'         *** Generate HTML data to send-------
             
          StringSend(0, @htmlstart)  'optional HTML header 
          StringSend(0, @htmlopt)
          bytemove (@num1,STR.numberToDecimal(visitor++, 4),5)                        '<-- update visitor number in html code
          bytemove (@tf, fp.FloatToFormat(fahrenheit(tempC), 5,1),5)                  ' jha update temperature
          bytemove (@tod,RTC.FmtDateTime,25)                                          ' jha update tod                
          StringSend(0, @html1)
          StringSend(0, @html2)
          StringSend(0, @html3)
          StringSend(0, @tod)       
          StringSend(0, @html4)        
          StringSend(0, @data[0])
          StringSend(0, @htmlfin)


PUB htmlEnd                  
    ' we don't support persistent connections, so disconnect here     
    W5100.SocketTCPdisconnect(0)
    PauseMSec(25)
    
    'Connection terminated
    W5100.SocketClose(0)
    pst.Str(string("Connection complete", PST#NL, PST#NL))

    'Once the connection is closed, need to open socket again
    OpenSocketAgain(0)

PUB updateLCD

'-------- jha Real Time Clock
     RTC.Update
     LCD.str(string(128))                               ' Move cursor to line 0, position 0
     LCD.str(RTC.ShortFmtDateTime)                      ' print short dateTime

'-------- jha Sensirion
     rawTemp := f.FFloat(sht.readTemperature)
     tempC := celsius(rawTemp)
     LCD.str(string(148))                               ' Move cursor to line 1, position 0 
     LCD.str(string("Tf In: "))                         ' print temperature in degrees fahrenheit
     LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))

'     return

PUB SetButtons                  'Toggle button state and dynamically change html code
    If ButtonSelection == 24    ' using button 24 to toggle backlight. 
       P24 := 1 - P24
       outa[24]:= P24
       isLCDon := 1 - isLCDon
       if isLCDon <> 0
         LCD.str(string(17))
       else
         LCD.str(string(18))
         
    If ButtonSelection == 25
       P25 := 1 - P25
       outa[25]:= P25          
    If ButtonSelection == 26
       P26 := 1 - P26
       outa[26]:= P26          
    If ButtonSelection == 27
       P27 := 1 - P27
       outa[27]:= P27
    If ButtonSelection == 23  ' jha
       P23 := 1 - P23         ' toggle Spinneret usr led
       outa[23]:= P23        
             

    If P23 == 0                               ' jha
       bytemove(@buttons[86+bOffSet*4],@RED,5)
    Else
       bytemove(@buttons[86+70*4],@YELLOW,6)

    If P24 == 0
       bytemove(@buttons[86+70*0],@RED,5)
    Else
       bytemove(@buttons[86+70*0],@GREEN,5)       

    If P25 == 0
       bytemove(@buttons[86+70*1],@RED,5)
    Else
       bytemove(@buttons[86+70*1],@GREEN,5)

    If P26 == 0
       bytemove(@buttons[86+70*2],@RED,5)
    Else
       bytemove(@buttons[86+70*2],@GREEN,5)

    If P27 == 0
       bytemove(@buttons[86+70*3],@RED,5)
    Else
       bytemove(@buttons[86+70*3],@GREEN,5)

PUB Wiznet5100
  ' init the Wiznet 5100 chip
  W5100.StartINDIRECT(W5100_DATA0, W5100_ADDR0, W5100_ADDR1, W5100_CS, W5100_RD, W5100_WR, W5100_RST, W5100_SEN)
  ' setup the address information we got from DHCP
  W5100.InitAddresses(true, @MAC_Address[0], @GatewayIP[0], @SubnetMask[0], @IP[0])
  ' open a socket for TCP
  W5100.SocketOpen(0, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  'Wait a moment for the socket to get established
  PauseMSec(250)
  ReadStatus(0)
  W5100.SocketTCPlisten(0)
  'Wait a moment for the socket to listen
  PauseMSec(250)
  ReadStatus(0)

PUB celsius(t)
  ' from SHT1x/SHT7x datasheet using value for 3.5V supply
  ' celsius = -39.7 + (0.01 * t)
  return f.FAdd(-39.7, f.FMul(0.01, t))

PUB fahrenheit(t)
  ' fahrenheit = (celsius * 1.8) + 32
  return f.FAdd(f.FMul(t, 1.8), 32.0)  

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
tnt     byte  "<form action='xml' method='GET'>"
        byte  "<input type='hidden' id='measuredTime' name='measuredTime' value='"
tntD    byte  "2011-01-03T03:41:02' />"
        byte  "<input type='hidden' id='tf' name='tf' value='"
tntT    byte  "86.4'/>"
        byte  "<button type='submit' value='xml'>xml</button>"
        byte  "</form>"
        byte  "<FONT FACE=ARIAL SIZE=4 COLOR=RED><BR>You are visitor number: "
num1    byte  "0000 <BR>" '<--- This is a place holder ; number is dynamically updated
        byte  "</FONT>"
        byte  "<FONT FACE=ARIAL SIZE=2<BR>"
        byte  "<br><br>"
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
        
' XML page of temperature and time
xml     byte  "<?xml version='1.0' encoding='UTF-8'?>"
        byte  "<nerdDoroData xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>"
        byte  "<currentTemperature0>"
xmltf   byte  "78.9"
        byte  "</currentTemperature0>"
        byte  "<currentMeasuredTime>"
xmltd   byte  "2011-07-13T15:17:35"
        byte  "</currentMeasuredTime>"
        byte  "</nerdDoroData>"
        byte  0

PRI StringSend(socket, _dataPtr)
  W5100.txTCP(socket, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain(socket)
  W5100.SocketOpen(socket, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  W5100.SocketTCPlisten(socket)

PRI ReadStatus(socket) | status
  pst.Str(string("Socket "))
  pst.Dec(socket)
  pst.STR(string(" Status Register: "))
  W5100.readIND((W5100#_S0_SR + (socket * $0100)), @status, 1)

  case status
    W5100#_SOCK_CLOSED : PST.Str(string("$00 - socket closed", PST#NL, PST#NL))
    W5100#_SOCK_INIT   : PST.Str(string("$13 - socket initialized", PST#NL, PST#NL))
    W5100#_SOCK_LISTEN : PST.Str(string("$14 - socket listening", PST#NL, PST#NL))
    W5100#_SOCK_ESTAB  : PST.Str(string("$17 - socket established", PST#NL, PST#NL))    
    W5100#_SOCK_UDP    : PST.Str(string("$22 - socket UDP open", PST#NL, PST#NL))

  return status
  
PRI PauseMSec(Duration)
'***************************************
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

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