{{

Spinneret Web Server; 'nerdDoro'     v0.7 

https://github.com/jhalbrecht/nerdDoro 

Author: Jeff Albrecht                  
 Began July 10, 2011                   

 Revision History:

 July 18, 2011
  v0.7
  Cleanup and move towards utility screen design.
  Removed javascript. Removed button updates. Removed js timer
  removed button color change routines.

  Added timer code for Pomedoro. Displays on LCD.
  Added SNTP to RTC update 

 July 15, 2011
  Stuffing actual dateTime and temperature into the xml.
 July 14, 2011
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
  BUFFER_SIZE       = 2048
  maxPacketSendSize = 2032
  listenPort = 80  

  TIME_PORT         = 123
  TIMEOUT_SECS      = 10
  udpntpsock        = 1

    'USA Standard Time Zone Abbreviations
  #-10, HST,AtST,PST,MST,CST,EST,AlST
              
    'USA Daylight Time Zone Abbreviations
  #-9, HDT,AtDT,PDT,MDT,CDT,EDT,AlDT

  Zone = PDT   
  
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
  
DAT

  timeIPaddr      byte       64, 147, 116, 229     
    
OBJ
  'DHCPClient    : "DHCP"
  W5100         : "Brilldea_W5100_Indirect_Driver_Ver006.spin"
  PlxST           : "Parallax Serial Terminal"
  STR           : "STREngine"
  RTC           : "s-35390A_GBSbuild_02_09_2011"
  ' LCD           : "FullDuplexSerial.spin"
  lcd           : "serial_lcd" 
'  vp            : "terminal"
  sht           : "Sensirion_full"
  fp            : "FloatString"
  f             : "Float32"
  timer         : "timer"
  SNTP          : "SNTP Simple Network Time Protocol"

VAR

  long  visitor, strpointer, ButtonSelection, rawTemp, tempC
  byte  MAC_Address[6]
  byte  data[bytebuffersize]
  byte  xmldatetime[19]

  byte  Buffer[BUFFER_SIZE]
  long  longHIGH,longLOW,MM_DD_YYYY,DW_HH_MM_SS 'Expected 4-contigous variables


PUB main | packetSize

  lcd.start(TX_PIN, 19_200, 4)
  
  sht.start(SHT_DATA, SHT_CLOCK)              ' start sensirion object
  waitcnt(clkfreq*3+cnt)
  sht.config(45 ,sht#off,sht#yes,sht#hires)   'configure SHT-11
  f.start 
 
 'vp.config(string("start:terminal::terminal:1"))
 'vp.share(@visitor,@strpointer)    

  PlxST.Start(115200)               '<-- Initialize Serial Communication to PC (debug)

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

'  PauseMSec(2000)                 '<-- Allow 2 seconds after programming to start the PlxST. 
  
  'Initialize Wiznet 5100 chip 
  Wiznet5100

  'Initialize PST screen
  PlxST.Home
  PlxST.Clear

  Dira[23]~~  'Set Auxiliary I/O's for output (debug) 
  Outa[23]~
  
  RTC.Update                    ' read the rtc
 
'  LCD.str(string(12))           ' cls
  lcd.cls
'  PauseMSec(250)
'  LCD.str(string(22))           ' Turn the display on, with cursor off and no blink
  lcd.cursor(0)
  PauseMSec(250)
'  lcd.backlight(1)
  LCD.str(string(17))           ' backlight on
  PauseMSec(250)
  lcd.gotoxy(0,0)
'  LCD.str(string(128))          ' Move cursor to line 0, position 0
  LCD.str(RTC.ShortFmtDateTime)
  LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))
  PauseMSec(250)
  lcd.backlight(1)
  lcd.str(string(216)) ' set second scale for lcd music 
  lcd.str(string(208)) ' set length for lcd music
  
  timer.start
  timer.run
  
{{
********************************************************************
*      Infinite loop of the server ; listen on the TCP socket      *
********************************************************************                                
}}

  repeat

    PlxST.Str(string("Waiting for a client to connect....", PlxST#NL))
    repeat
      updateLCD ' update LCD with date time and temperature.
      usrButton
      pomTime                                       
    while !W5100.SocketTCPestablished(0)
                                                                            
    PlxST.Str(string("connection established...", PlxST#NL))
    PlxST.str(string(" visitor "))
    PlxST.dec(visitor)
    PlxST.Char(13)

    'Initialize the buffers and bring the data over
    bytefill(@data, 0, bytebuffersize)    
    repeat
      packetSize := W5100.rxTCP(0, @data)
    while packetSize == 0  

    PlxST.Str(string("Packet from browser:", PlxST#NL))
    PlxST.Str(@data[0])

      if STR.findCharacters(@data[0], string("GET /button_action")) <> 0

          PlxST.str(string(" You got to the GET /button_action "))
          bytemove(@d1,@data[20],2)
          ButtonSelection := STR.decimalToNumber(@d1)
          'SetButtons
          defaultHtml

      elseif STR.findCharacters(@data[0], string("GET /xml")) <> 0
 
          PlxST.str(@data)
          PlxST.str(string(" You got to the GET /xml "))
          bytemove (@xmldt, doXmlDateTime, 19)
          bytemove (@xmltf, fp.FloatToFormat(fahrenheit(tempC), 5,2), 4)
          'xmlDateTime
          StringSend(0,@xml)
                                                                                        
      elseif STR.findCharacters(@data[0], string("GET /loadRTC")) <> 0
          PlxST.str(string("You got to the loadRTCfromNTP "))
          ntpToRtc
          defaultHtml      
                                                                                        
      elseif STR.findCharacters(@data[0], string("GET /toggleLED")) <> 0
          PlxST.str(string("You got to the toggleLED "))
          isLEDon := 1 - isLEDon         ' toggle Spinneret usr led
          dira[23]~~
          outa[23]:= isLEDon 
          defaultHtml      

      elseif STR.findCharacters(@data[0], string("GET /toggleLCDbl")) <> 0
          PlxST.str(string("You got to the toggle lcd backlight "))
          'isLCDon := 1 - isLCDon
          if isLCDon <> 0
            isLCDon := 0          
            LCD.str(string(17))
          else
            isLCDon := 1
            LCD.str(string(18))
            
          defaultHtml      
            
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
    StringSend(0, @vstor)
    StringSend(0, @tempf)
    StringSend(0, @tod)    
    StringSend(0, @btns)
    'StringSend(0, @html4)        
    'StringSend(0, @data[0])
    StringSend(0, @htmlfin)

PUB htmlEnd                  
    ' we don't support persistent connections, so disconnect here     
    W5100.SocketTCPdisconnect(0)
    PauseMSec(25)
    
    'Connection terminated
    W5100.SocketClose(0)
    PlxST.Str(string("Connection complete", PlxST#NL, PlxST#NL))

    'Once the connection is closed, need to open socket again
    OpenSocketAgain(0)

pub usrButton

    dira[23]~
    lcd.gotoxy(15, 2)
    if ina[23] == 1
      lcd.str(string("1"))
      timer.reset
      timer.run
      hasPomed := 0
    else
      lcd.str(string("0"))
    dira[23]~~

PUB pomTime

    if timer.rdReg(2) == 1 and (not hasPomed) ' read the minutes register.
      repeat 5
        LCD.str(string(220))
        lcd.backLight(0)
        PauseMSec(250)
        LCD.str(string(230))
        lcd.backLight(1)
        PauseMSec(250)
        hasPomed := 1
               
    
PUB updateLCD  ' display time and temperature

     RTC.Update
     'lcd.cls
     lcd.gotoxy(0, 0) 
     LCD.str(RTC.ShortFmtDateTime)                      ' print short dateTime
     rawTemp := f.FFloat(sht.readTemperature)
     tempC := celsius(rawTemp)
     lcd.gotoxy(0, 1)
     LCD.str(string("Tf In: "))                         ' print temperature in degrees fahrenheit
     LCD.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))
     lcd.gotoxy(0,2)
     lcd.str(string("Pomodoro timer"))
     lcd.gotoxy(0, 3)                                ' move to col 0 on line 3 timer display 
     lcd.str(timer.showTimer)
       
PUB doXmlDateTime
     
    ' 2011-01-03T03:41:02   want it in this format for .net xml reader
    ' 01234567890123456789  column numbers
     
    rtc.Update
    bytemove(@xmldatetime[0], string("20"), 2)
    bytemove(@xmldatetime[2], str.trimCharacters(str.numberToDecimal(rtc.GetYear, 2)), 2)
    bytemove(@xmldatetime[4], string("-"), 1)
    bytemove(@xmldatetime[5], str.trimCharacters(str.numberToDecimal(rtc.GetMonth, 2)), 2)
    bytemove(@xmldatetime[7], string("-"), 1)
    bytemove(@xmldatetime[8], str.trimCharacters(str.numberToDecimal(rtc.GetDay, 2)), 2)
    bytemove(@xmldatetime[10], string("T"), 1)
    if rtc.IsPM  & (rtc.GetHour <> 12)
      bytemove(@xmldatetime[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour + 12, 2)), 2)
    else
      bytemove(@xmldatetime[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour, 2)), 2)
    bytemove(@xmldatetime[13], string(":"), 1)
    bytemove(@xmldatetime[14], str.trimCharacters(str.numberToDecimal(rtc.GetMinutes, 2)), 2)
    bytemove(@xmldatetime[16], string(":"), 1)      
    bytemove(@xmldatetime[17], str.trimCharacters(str.numberToDecimal(rtc.GetSeconds, 2)), 2)
    xmldatetime[19] := 0
    return @xmldatetime

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

pub ntpToRtc

'                          Open UDP socket
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈
    'W5100.SocketOpen(socket,W5100#_UDPPROTO,TIME_PORT,0,@IP)
    W5100.SocketOpen(udpntpsock,W5100#_UDPPROTO,TIME_PORT,0,@IP)
    'check the status of the socket for connection and get internet time
    if ReadStatus(udpntpsock) == W5100#_SOCK_UDP
       PauseMSec(250)   '<-- Some Delay required here after socket connection
       if GetTime(udpntpsock,@Buffer)
'                        Decode 64-Bit time from server           
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈       
          SNTP.GetTransmitTimestamp(Zone,@Buffer,@LongHIGH,@LongLOW)

'               Display Reference/Sync TimeZone corrected Time           
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈       
          'DisplayHumanTime

'                         Set RTC to Internet Time          
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈
          RTC.SetDateTime(byte[@MM_DD_YYYY][3],   { <- Month
                        } byte[@MM_DD_YYYY][2],   { <- Day
                        } word[@MM_DD_YYYY][0]-2000,   { <- Year
                        } byte[@DW_HH_MM_SS][3],  { <- (day of week)
                        } byte[@DW_HH_MM_SS][2],  { <- Hour
                        } byte[@DW_HH_MM_SS][1],  { <- Minutes
                        } byte[@DW_HH_MM_SS][0])  { <- Seconds }

PUB GetTime(sockNum,BufferAddress)|i
    SNTP.CreateUDPtimeheader(BufferAddress,@timeIPaddr)
    W5100.txUDP(sockNum, BufferAddress) '<-- Send the UDP packet

    repeat 10*TIMEOUT_SECS
      i := W5100.rxUDP(sockNum,BufferAddress)  
      if i == 56
         W5100.SocketClose(sockNum)  '<-- At this point we are done, we have
                                    '     the time data and don't need to keep
                                    '     the connection active.
         return 1                   '<- Time Data is ready
      PauseMSec(100) '<- if 1000 = 1 sec ; 10 = 1/100th sec X 100 repeats above = 1 sec   
    return -1                       '<- Timed out without a response

PUB celsius(t)
    ' from SHT1x/SHT7x datasheet using value for 3.5V supply
    ' celsius = -39.7 + (0.01 * t)
'    return f.FAdd(-39.7, f.FMul(0.01, t))
    return f.FAdd(-39.875, f.FMul(0.01, t))   ' ~ 4.5vdc
'     return f.FAdd(-40.0, f.FMul(0.01, t))   ' 5vdc

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

isLCDon       byte 0
isLEDon       byte 0
hasPomed      byte 0

d1      byte  "  ",0

' main page
htmlstart
        byte  "HTTP/1.1 200 OK", CR, LF,0
'--------------------------------------------------------------------------------------        
htmlopt
        byte  "Connection: close",CR, LF
        byte  "Content-Type: text/html",CR,LF,CR,LF,0
'--------------------------------------------------------------------------------------
html1   byte  "<HTML>"
        byte  "<HEAD>"
        byte  "<TITLE>nerdDoro</TITLE>"
        byte  "</HEAD>"
        byte  0 
            
html2   byte  "<BODY style=background-color:grey; Onload='StartJava()'>"
        byte  "<noscript>NOTE: Your browser does not support JavaScript or support has been turned off. Sorry!</noscript>"
        byte  "<a href='/'>"  
        byte  "<img src='http://1.gravatar.com/avatar/3901ec164a8022fa0f7d34f9d41935d9' />"
        byte  "</a> Hi Mom!<br>"
        byte  0  

html3   byte  "<FONT FACE=ARIAL SIZE=4><BR>"
        byte  "A Parallax Spinneret propeller/Wiznet clock and environment sensing and reporting."
        byte  "<BR></FONT>"
        byte 0
btns    byte  "<ul>"     
lRTC    byte  "<li><form action='loadRTC' method='GET'>"
        byte  "<button type='submit' value='loadRTCfromNTP'>load rtc from ntp</button>"
        byte  "</form></li>"

tLED    byte  "<li><form action='toggleLED' method='GET'>"
        byte  "<button type='submit'>toggle led</button>"
        byte  "</form></li>"

tlcd    byte  "<li><form action='toggleLCDbl' method='GET'>"
        byte  "<button type='submit'>toggle lcd backlight</button>"
        byte  "</form></li>"
                        
tnt     byte  "<li><form action='xml' method='GET'>"
        byte  "<button type='submit' value='xml'>xml</button>" 
        byte  "</form></li>"
        byte  "</ul>"
        byte  0
        
vstor   byte  "<FONT FACE=ARIAL SIZE=4 COLOR=GREEN><BR>Page operations since last restart: "
num1    byte  "0000 <BR>" '<--- This is a place holder ; number is dynamically updated
        byte  "</FONT>"
        byte  "<FONT FACE=ARIAL SIZE=2<BR>"
        byte 0
        
tempf   byte  "<br>"
        byte  "It's "
tf      byte  "      "
        'byte  0        
        byte  "degrees farenheight when the page was loaded at: "
        byte  0
tod     byte  "                                                  <br><br>"
        byte  0 
htmlfin
        byte  "</FONT>"
        byte  "</BODY>"      
        byte  "</HTML>"
        byte  0
        
' XML page of temperature and time
xml     byte  "HTTP/1.1 200 OK", CR, LF
        byte  "Connection: close",CR, LF
        byte  "Content-Type: text/html",CR,LF,CR,LF
        byte  "<?xml version='1.0' encoding='UTF-8'?>"
        byte  "<nerdDoroData xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>",10
        byte  "<currentTemperature0>"
xmltf   byte  "    "
        byte  "</currentTemperature0>"
        byte  "<currentMeasuredTime>"
xmldt   byte  "                   "
        byte  "</currentMeasuredTime>"
        byte  "</nerdDoroData>",10
        byte  0

PRI StringSend(socket, _dataPtr)
  W5100.txTCP(socket, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain(socket)
  W5100.SocketOpen(socket, W5100#_TCPPROTO, listenPort, listenPort, @destIP[0])
  W5100.SocketTCPlisten(socket)

PRI ReadStatus(socket) | status
  PlxST.Str(string("Socket "))
  PlxST.Dec(socket)
  PlxST.STR(string(" Status Register: "))
  W5100.readIND((W5100#_S0_SR + (socket * $0100)), @status, 1)

  case status
    W5100#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    W5100#_SOCK_INIT   : PlxST.Str(string("$13 - socket initialized", PlxST#NL, PlxST#NL))
    W5100#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    W5100#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    W5100#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))

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