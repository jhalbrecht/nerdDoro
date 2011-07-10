{{
*******************************************
* Spinneret Web Server nerdDoro     v0.5  *
* Author: Jeff Albrecht                   *
* Special recognition goes to ....        *
*                                         *
* Beau Schwabe                            *
* Roy ELtham                              *
* Timothy D. Swieter                      *
* Kwabena W. Agyeman                      *
* Jeff Martin                             *
* Andy Lindsay                            *
* Chip Gracey                             *
*                                         *
* ... For providing the necessary drivers *
* to allow me to quickly put something    *
* together for our Saturday Robotics club *   
* get together known as the 'PARELECTS'   *
                                          *
* Copyright (c) 2011 Parallax             *
* See end of file for terms of use.       *
*******************************************

Revision History:
                  Version 0.5   - (07-10-2011) jeffa Begun based on Beau Schwabe Spinneret_Web_Server_DEMOv1.2

}}
CON
  _clkfreq = 80_000_000
  _clkmode = xtal1 + pll16x

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
  'listenPort = 5555


{{
Notes:

1) Run this program.
   Make sure you are using a valid local IP address on network.
    -In this example I used 192.168.0.45
   And make sure you have a MAC address other than 00:00:00:00:00:00
    -I used the numbers printed on the underside of the Spinneret 

2) Set Static IP on router to the same IP as in step #1

3) Set Port forwarding on router so that it reflects the IP and the listenPort

   Note: Some ISP's won't allow forwarding of port 80 ,such as my case.

4) On the local network you can simply use the IP address in step #1 to see
   the Spinneret

5) To 'see' the Spinneret over the web, you will need to determine your assigned
   DHCP IP address or your static IP address.  either way you can use something
   like ...  http://www.whatsmyip.us/

   The number here for example in my case is 24.253.241.231 ... Since I port
   forwarded to 5555, I would access the Spinneret from the web with...

   http://24.253.241.231:5555/


}}    
OBJ
  DHCPClient    : "DHCP"
  W5100         : "Brilldea_W5100_Indirect_Driver_Ver006.spin"
  PST           : "Parallax Serial Terminal"
  STR           : "STREngine"

VAR
  long  visitor,strpointer,ButtonSelection
  byte MAC_Address[6]
  byte data[bytebuffersize]

  

PUB main | packetSize
  PST.Start(115200)               '<-- Initialize Serial Communication to PC (debug)
  ' Network Settings
{  IP             := $2D_00_A8_C0  '<-- IP Address in HEX  little-endian (192.168.0.45)
  SubnetMask     := $00_FF_FF_FF  '<-- SubnetMask in HEX  little-endian (255.255.255.0)  
  GatewayIP      := $01_00_A8_C0  '<-- GatewayIP in HEX  little-endian (192.168.0.1)
  DNS_Server     := $01_00_A8_C0  '<-- DNS_Server in HEX  little-endian (192.168.0.1)
  destIP         := $00_00_00_00  '<-- destIP in HEX  little-endian (0.0.0.0)
 }
  IP             := $96_08_09_0A  ' IP:10.9.8.150, LAN:spinneret.jeffa.org, WAN:jeffa.org:90
  SubnetMask     := $00_FF_FF_FF    
  GatewayIP      := $FE_08_09_0A  
  DNS_Server     := $FE_08_09_0A  
  destIP         := $00_00_00_00  
  
  ' MAC Address
  MAC_Address[0] := $00
  MAC_Address[1] := $08
  MAC_Address[2] := $DC 
  MAC_Address[3] := $16 
  MAC_Address[4] := $EF 
  MAC_Address[5] := $81    

  PauseMSec(2000)                 '<-- Allow 2 seconds after programming to start the PST. 
  
  'Initialize Wiznet 5100 chip 
  Wiznet5100

  'Initialize PST screen
  PST.Home
  PST.Clear

  'Set Auxiliary I/O's for output (debug) 
  Dira[24..27]~~
  Outa[24..27]~

  'Infinite loop of the server ; listen on the TCP socket 
  repeat

    PST.Str(string("Waiting for a client to connect....", PST#NL))
    repeat while !W5100.SocketTCPestablished(0)

    PST.Str(string("connection established...", PST#NL))
    PST.dec(visitor)
    PST.Char(13)

    'Initialize the buffers and bring the data over
    bytefill(@data, 0, bytebuffersize)    
    repeat
      packetSize := W5100.rxTCP(0, @data)
    while packetSize == 0  

    PST.Str(string("Packet from browser:", PST#NL))
    PST.Str(@data[0])


'--------Parse Data Packet for Button Press-------
    strpointer := STR.findCharacters(@data[0], string("GET /button_action"))
    if strpointer<>0
       bytemove(@d1,@data[20],2)
       ButtonSelection := STR.decimalToNumber(@d1)
       SetButtons

'--------Generate HTML data to send-------       
    StringSend(0, @htmlstart)
      'optional HTML header
    StringSend(0, @htmlopt)
      'HTML Header
    bytemove (@num1,STR.numberToDecimal(visitor++, 4),5) '<-- update visitor number in html code                 
    StringSend(0, @html1)
    StringSend(0, @html2)
    StringSend(0, @html3)
    StringSend(0, @html4)        
    StringSend(0, @data[0])
    StringSend(0, @htmlfin)
                  
    ' we don't support persistent connections, so disconnect here     
    W5100.SocketTCPdisconnect(0)
    PauseMSec(25)
    
    'Connection terminated
    W5100.SocketClose(0)
    PST.Str(string("Connection complete", PST#NL, PST#NL))

    'Once the connection is closed, need to open socket again
    OpenSocketAgain(0)

PUB SetButtons                  'Toggle button state and dynamically change html code
    If ButtonSelection == 24
       P24 := 1 - P24
       outa[24]:= P24
    If ButtonSelection == 25
       P25 := 1 - P25
       outa[25]:= P25          
    If ButtonSelection == 26
       P26 := 1 - P26
       outa[26]:= P26          
    If ButtonSelection == 27
       P27 := 1 - P27
       outa[27]:= P27          

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
P24     byte  0
P25     byte  0
P26     byte  0
P27     byte  0
RED     byte  "RED  ",0
GREEN   byte  "GREEN",0
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
        byte  "<TITLE>nerdDoro Web Server</TITLE>"
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
            
html2   byte  "<BODY Onload='StartJava()'>"
        byte  "<noscript>NOTE: Your browser does not support JavaScript or support has been turned off. Sorry!</noscript>"

        byte  "<FONT FACE=ARIAL SIZE=3><BR>a little bit of JavaScript Graphics<BR></FONT>"
        byte  "<canvas id='canvas' width='100' height='100'>Sorry! - Browser does not support Graphics Canvas</canvas>"

        byte  "<FONT FACE=ARIAL SIZE=8><BR>Welcome to the nerdDoro Spinneret<BR></FONT>"

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
  W5100.txTCP(socket, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain(socket)
  W5100.SocketOpen(socket, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  W5100.SocketTCPlisten(socket)

PRI ReadStatus(socket) | status
  PST.Str(string("Socket "))
  PST.Dec(socket)
  PST.STR(string(" Status Register: "))
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