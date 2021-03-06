{{

Spinneret Web Server; 'nerdDoro'     v1.1 

https://github.com/jhalbrecht/nerdDoro 

Author: Jeff Albrecht                  
 Began July 10, 2011                   

 Revision History:

   February 14, 2013
    v1.1 Modified XML
        Changed from NerdDoroData to SummaryTemperatureData to allow compatibility
        with @HomeAmation win8 wp8 client applications.
        Upper case for first letter of Element names.

        Added no cache header to xml

  July 31, 2011 between 7pm and midnight!
    v1.0 more cleanup and commenting. Final submission to Spinneret design contest.

  July 28, 2011
   v0.9
   migrate nerdDoro project to the Chris Cantrell version of the indrect server

 July 21, 2011
  v0.8
  Moved all timer, lcd and pomodoro indicators from the
  client connect loop to it's own cog, gitErDone

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

CON               'Constants to be located here
                       
  '***************************************
  ' Firmware Version
  '***************************************

  FWmajor       = 0
  FWminor       = 2

  TX_PIN        = 22                                    ' jha for serial LCD   
  BAUD          = 19_200
  
  SHT_DATA      = 26 ' 24 ' 29                          ' SHT-11 data pin
  SHT_CLOCK     = 27 ' 25 ' 28                          ' SHT-11 clock pin

  MMx           = 24 '0                                 ' Memsic
  MMy           = 25 '1  
  
  bOffSet       = 70
  
  CR            = 13
  LF            = 10

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

DAT

  TxtFWdate   byte "February 14, 2013",0
  
CON

  _clkmode = xtal1 + pll16x     'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000          'An external clock of 5MHz. is used (80MHz. operation)

  '***************************************
  ' System Definitions     
  '***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3V DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0V DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

  '***************************************
  ' I/O Definitions of Spinneret Web Server Module
  '***************************************

  '~~~~Propeller Based I/O~~~~
  'W5100 Module Interface
  _WIZ_data0    = 0             'SPI Mode = MISO, Indirect Mode = data bit 0.
  _WIZ_miso     = 0
  _WIZ_data1    = 1             'SPI Mode = MOSI, Indirect Mode = data bit 1.
  _WIZ_mosi     = 1
  _WIZ_data2    = 2             'SPI Mode SPI Slave Select, Indirect Mode = data bit 2
  _WIZ_scs      = 2             
  _WIZ_data3    = 3             'SPI Mode = SCLK, Indirect Mode = data bit 3.
  _WIZ_sclk     = 3
  _WIZ_data4    = 4             'SPI Mode unused, Indirect Mode = data bit 4 
  _WIZ_data5    = 5             'SPI Mode unused, Indirect Mode = data bit 5 
  _WIZ_data6    = 6             'SPI Mode unused, Indirect Mode = data bit 6 
  _WIZ_data7    = 7             'SPI Mode unused, Indirect Mode = data bit 7 
  _WIZ_addr0    = 8             'SPI Mode unused, Indirect Mode = address bit 0 
  _WIZ_addr1    = 9             'SPI Mode unused, Indirect Mode = address bit 1 
  _WIZ_wr       = 10            'SPI Mode unused, Indirect Mode = /write 
  _WIZ_rd       = 11            'SPI Mode unused, Indirect Mode = /read 
  _WIZ_cs       = 12            'SPI Mode unused, Indirect Mode = /chip select 
  _WIZ_int      = 13            'W5100 /interrupt
  _WIZ_rst      = 14            'W5100 chip reset
  _WIZ_sen      = 15            'W5100 low = indirect mode, high = SPI mode, floating will = high.

  _DAT0         = 16
  _DAT1         = 17
  _DAT2         = 18
  _DAT3         = 19
  _CMD          = 20
  _SD_CLK       = 21
  
  _SIO          = 22            

  _LED          = 26            'UI - combo LED and buttuon
  
  _AUX0         = 24            'MOBO Interface
  _AUX1         = 25
  _AUX2         = 26
  _AUX3         = 27

  'I2C Interface
  _I2C_scl      = 28            'Output for the I2C serial clock
  _I2C_sda      = 29            'Input/output for the I2C serial data  

  'Serial/Programming Interface (via Prop Plug Header)
  _SERIAL_tx    = 30            'Output for sending misc. serial communications via a Prop Plug
  _SERIAL_rx    = 31            'Input for receiving misc. serial communications via a Prop Plug

  '***************************************
  ' I2C Definitions
  '***************************************
  _EEPROM0_address = $A0        'Slave address of EEPROM

  '***************************************
  ' Debugging Definitions
  '***************************************
  
  '***************************************
  ' Misc Definitions
  '***************************************
  
  _bytebuffersize = 2048

VAR               'Variables to be located here

  'Configuration variables for the W5100
  byte  MAC[6]                  '6 element array contianing MAC or source hardware address ex. "02:00:00:01:23:45"
  byte  Gateway[4]              '4 element array containing gateway address ex. "192.168.0.1"
  byte  Subnet[4]               '4 element array contianing subnet mask ex. "255.255.255.0"
  byte  IP[4]                   '4 element array containing IP address ex. "192.168.0.13"

  'verify variables for the W5100
  byte  vMAC[6]                 '6 element array contianing MAC or source hardware address ex. "02:00:00:01:23:45"
  byte  vGateway[4]             '4 element array containing gateway address ex. "192.168.0.1"
  byte  vSubnet[4]              '4 element array contianing subnet mask ex. "255.255.255.0"
  byte  vIP[4]                  '4 element array containing IP address ex. "192.168.0.13"

  long  localSocket             '1 element for the socket number

  'Variables to info for where to return the data to
  byte  destIP[4]               '4 element array containing IP address ex. "192.168.0.16"
  long  destSocket              '1 element for the socket number

  'Misc variables
  byte  data[_bytebuffersize]
  long  stack[50]

  long  PageCount

  long  visitor, strpointer, ButtonSelection, rawTemp, tempC
  'long  xmlRawTemp, xmlTempC ' enhance by using locks rather than duplicating variables                            
  
  'byte  MAC_Address[6]
  'byte  data[bytebuffersize]
  byte  xmldatetime[19]

  byte  Buffer[BUFFER_SIZE]
  long  longHIGH,longLOW,MM_DD_YYYY,DW_HH_MM_SS 'Expected 4-contigous variables

  long lcdUpdateStack[128] 'Stack space for gitErDone cog
  long lcdUpdateID

  byte    RtcLockID   ' lock semaphores for RTC   
  byte    ShtLockID   '  and Sensirion  
  
OBJ               'Object declaration to be located here

  'Choose which driver to use by commenting/uncommenting the driver.  Only one can be chosen.
  ETHERNET      : "Brilldea_W5100_Indirect_Driver_Ver006.spin" 
  'ETHERNET      : "W5100_Indirect_Driver.spin" ' Driver as named in the repository
  'W5100         : "Brilldea_W5100_Indirect_Driver_Ver006.spin"
  PlxST         : "Parallax Serial Terminal"
  STR           : "STREngine"
  RTC           : "s-35390A_GBSbuild_02_09_2011"
  LCD           : "FullDuplexSerial.spin"
  sht           : "Sensirion_full"
  fp            : "FloatString"
  f             : "Float32"
  timer         : "timer"
  SNTP          : "SNTP Simple Network Time Protocol"
  MM2125        : "Memsic2125_v1.2"  

DAT

   timeIPaddr      byte       64, 147, 116, 229  ' SNTP server nist1-la.ustiming.org
'   timeIPaddr      byte       74, 120, 8, 2  ' one of pool.ntp.org
'    timeIPaddr      byte       192, 5, 41, 40  ' tick.usno.navy.mil
        


PUB main | temp0, temp1, temp2, readSize 

  'Start the terminal application
  'The terminal operates at 115,200 BAUD on the USB/COM Port the Prop Plug is attached to

  PlxST.Start(115_200)
  PauseMSec(2_000)              'A small delay to allow time to switch to the terminal application after loading the device  

  'Start the W5100 driver
  ETHERNET.StartINDIRECT(_WIZ_data0, _WIZ_addr0, _WIZ_addr1, _WIZ_cs, _WIZ_rd, _WIZ_wr,  _WIZ_rst, _WIZ_sen)

  ' Initialize the variables

  'MAC ID to be assigned to W5100
  MAC[0] := $00
  MAC[1] := $08
  MAC[2] := $DC
  MAC[3] := $16
  MAC[4] := $F1
  MAC[5] := $B2

  'Subnet address to be assigned to W5100
  Subnet[0] := 255
  Subnet[1] := 255
  Subnet[2] := 255
  Subnet[3] := 0

  'IP address to be assigned to W5100
  IP[0] := 192 ' 10
  IP[1] := 168 ' 9
  IP[2] := 1   ' 8
  IP[3] := 205 ' 150  

  'Gateway address of the system network
  Gateway[0] := 192 ' 10
  Gateway[1] := 168 ' 9
  Gateway[2] := 1 '8
  Gateway[3] := 1 '254

  'Local socket
  localSocket := 80 

  'Destination IP address - can be left zeros, the TCO demo echoes to computer that sent the packet
  destIP[0] := 0
  destIP[1] := 0
  destIP[2] := 0
  destIP[3] := 0

  destSocket := 80
    
{
          Begin
}

  'Clear the terminal screen
  PlxST.Home
  PlxST.Clear

  LCD.start(TX_PIN, TX_PIN, %1000, 19_200)
  pausemsec(100)

  f.start

  sht.start(SHT_DATA, SHT_CLOCK)              ' start sensirion object
  waitcnt(clkfreq*3+cnt)
  sht.config(50 ,sht#off,sht#yes,sht#hires)   'configure SHT-11

{
  obtain lock semaphores for Sensirion and RTC
}

  if (ShtLockID := locknew) == -1
    plxst.str(string("Error, locknew failed for ShtLockID, no locks available",cr,lf))
  else
    plxst.str(string("ShtLockID locknew success",cr,lf))

  if (RtcLockID := locknew) == -1
    plxst.str(string("Error, locknew failed for RtcLockID, no locks available",cr,lf))
  else
    plxst.str(string("RtcLockID locknew success",cr,lf))     

  timer.start                                  ' put the timer in a cog
  timer.run

  MM2125.start(MMx, MMy)      'Initialize Mx2125
  waitcnt(clkfreq/10 + cnt)   'wait for things to settle 
  MM2125.setlevel             'assume at startup that the memsic2125 is level
                              'Note: This line is important for determining a deg  
  dira[MMx]~
  dira[MMy]~    
   
{
    Start the lcd update routine in it's own cog.
}

  if lcdUpdateID := cognew(lcdUpdate, @lcdUpdateStack)
    plxst.str(string(cr,lf,"lcdUpdate cog start succeeded.",cr,lf))
  else
    plxst.str(string(cr,lf,"lcdUpdate cog start failed.",cr,lf))  
 
  'Draw the title bar
  PlxST.Str(string("    Prop/W5100 Web Page Serving Test ", PlxST#NL, PlxST#NL))

  'Set the W5100 addresses
  PlxST.Str(string("Initialize all addresses...  ", PlxST#NL))  
  SetVerifyMAC(@MAC[0])
  SetVerifyGateway(@Gateway[0])
  SetVerifySubnet(@Subnet[0])
  SetVerifyIP(@IP[0])

  'Addresses should now be set and displayed in the terminal window.
  'Next initialize Socket 0 for being the TCP server

  PlxST.Str(string("Initialize socket 0, port "))
  PlxST.dec(localSocket)
  PlxST.Str(string(PlxST#NL))

  'Testing Socket 0's status register and display information
  PlxST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readIND(ETHERNET#_S0_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_INIT   : PlxST.Str(string("$13 - socket initalized", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    ETHERNET#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))

  'Try opening a socket using a ASM method
  PlxST.Str(string("Attempting to open TCP on socket 0, port "))
  PlxST.dec(localSocket)
  PlxST.Str(string("...", PlxST#NL))
  
  ETHERNET.SocketOpen(0, ETHERNET#_TCPPROTO, localSocket, destSocket, @destIP[0])

  'Wait a moment for the socket to get established
  PauseMSec(500)

  'Testing Socket 0's status register and display information
  PlxST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readIND(ETHERNET#_S0_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_INIT   : PlxST.Str(string("$13 - socket initalized/opened", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    ETHERNET#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))

  'Try setting up a listen on the TCP socket
  PlxST.Str(string("Setting TCP on socket 0, port "))
  PlxST.dec(localSocket)
  PlxST.Str(string(" to listening", PlxST#NL))

  ETHERNET.SocketTCPlisten(0)

  'Wait a moment for the socket to listen
  PauseMSec(500)

  'Testing Socket 0's status register and display information
  PlxST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readIND(ETHERNET#_S0_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_INIT   : PlxST.Str(string("$13 - socket initalized", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    ETHERNET#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))

  PageCount := 0

{
      Infinite loop of the server
}
      
  repeat

    ' Assumption: one socket is enough.
    '
    ' This demo only uses one of the four sockets maintained by the W5100. It does not
    ' handle simultaneous browsers or simultaneous connections from the same browser.
    ' The alternative is to implement a multi-socket state machine (see Mike G's code).
    '
    ' For many applications the simplifying assumption here is acceptable and
    ' saves resources.

    'Waiting for a client to connect
    PlxST.Str(string("Waiting for a client to connect.", PlxST#NL))
    'Testing Socket 0's status register and looking for a client to connect to our server

    'wizzard
    
    repeat while !ETHERNET.SocketTCPestablished(0)   
    PlxST.Str(string("Connection established.", PlxST#NL))

    ' Wait for data from the TCP stream
    bytefill(@data, 0, _bytebuffersize)
    PlxST.Str(string("Waiting for TCP data.", PlxST#NL)) 
    repeat
      ETHERNET.readIND(ETHERNET#_S0_SR, @temp0, 1)
      if(!ETHERNET.SocketTCPestablished(0))
        ' If the client has gone then break out of the loop. Ideally we should
        ' continue at the top of the main loop. For simplicity we'll just continue
        ' on as if nothing went wrong.
        quit
      readSize := ETHERNET.rxTCP(0, @data)     
      if(readSize>0)
        quit

    ' Assumption: all of the request comes in as one chunk of data that fits in the buffer.
    '
    ' The sender might send the request in chunks e.g. a-line-at-a-time that must be
    ' reassembled into one buffer. Be careful: the data buffer must be as large as the
    ' W500's configured read buffer. A large request could be larger than this buffer.
    ' In reality, nearly all requests from browsers are small and arrive all at once.
    '
    ' For many applications the simplifying assumption here is acceptable and
    ' saves resources.

    PlxST.Str(string("Read "))
    PlxST.dec(readSize)
    PlxST.Str(string(" bytes from TCP",PlxST#NL))

    PlxST.str(@data)       

    ' There are several HTTP methods. This demo only handles GETs (starts with a "G")

      if STR.findCharacters(@data[0], string("GET /button_action")) <> 0

          PlxST.str(string("You got to the GET /button_action ",cr,lf))
          'bytemove(@d1,@data[20],2)
          'ButtonSelection := STR.decimalToNumber(@d1)
          'SetButtons
          defaultHtml

      elseif STR.findCharacters(@data[0], string("GET /xml")) <> 0
 
          'PlxST.str(@data)
          PlxST.str(string("You got to the GET /xml ",cr,lf))
          repeat until not lockset(ShtLockID)           ' don't read Sensirion while LCDupdate is
          lockset(ShtLockID)
          rawTemp := f.FFloat(sht.readTemperature)
          tempC := celsius(rawTemp)
          stringSend(0,@xml0)
          stringSend(0,fp.FloatToFormat(fahrenheit(tempC), 5,2))
          lockclr(ShtLockID)
          stringSend(0,@xml1)
          repeat until not lockset(RtcLockID)           ' don't read RTC while LCDupdate is
          lockset(RtcLockID)          
          stringSend(0,doXmlDateTime)
          lockclr(RtcLockID)
          stringSend(0,@xml2)                    
{
        Load the RTC from a SNTP server
}
      elseif STR.findCharacters(@data[0], string("GET /loadRTC")) <> 0
          PlxST.str(string("You got to the loadRTCfromNTP ",cr,lf))
          ntpToRtc
          defaultHtml
{
        Toggle usr led. Also resets pomodoro timer
}                
                                                                                        
      elseif STR.findCharacters(@data[0], string("GET /toggleLED")) <> 0
          PlxST.str(string("You got to the toggleLED ",cr,lf))
          isLEDon := 1 - isLEDon         ' toggle Spinneret usr led
          dira[23]~~
          outa[23]:= isLEDon 
          defaultHtml
{
        toggle LCD backlight. Could use a lock semaphore here. 
}
      elseif STR.findCharacters(@data[0], string("GET /toggleLCDbl")) <> 0 
          PlxST.str(string("You got to the toggle lcd backlight ",cr,lf))
          isLCDon := 1 - isLCDon
          if isLCDon <> 0
            'isLCDon := 0          
            LCD.str(string(17))
            lcd.tx(17)
            plxst.str(string(cr,lf," toggle backlight on ",cr,lf))
          else
            plxst.str(string(cr,lf," toggle backlight off ",cr,lf))          
            'isLCDon := 1
            LCD.str(string(18))
            
          defaultHtml      
            
      else
          defaultHtml
          'PlxST.str(@data) 
       
    PauseMSec(5)

    'End the connection
    ETHERNET.SocketTCPdisconnect(0)

    PauseMSec(10)

    'Connection terminated
    ETHERNET.SocketClose(0)
    PlxST.Str(string("Connection complete.", PlxST#NL, PlxST#NL))

    'Once the connection is closed, need to open socket again
    OpenSocketAgain
    
  return 'end of main

pub defaultHtml

  '         *** Generate HTML data to send-------
  
  StringSend(0, @htmlstart)  'optional HTML header 
  StringSend(0, @htmlopt)
  bytemove (@num1,STR.numberToDecimal(visitor++, 4),5)                          '<-- update visitor number in html code
  repeat until not lockset(ShtLockID)                                           ' don't read Sensirion while LCDupdate is
  lockset(ShtLockID)
  bytemove (@tf, fp.FloatToFormat(fahrenheit(tempC), 5,1),5)                    ' jha update temperature
  lockclr(ShtLockID)
  repeat until not lockset(RtcLockID)                                           ' don't read RTC while LCDupdate is
  lockset(RtcLockID)  
  bytemove (@tod,RTC.FmtDateTime,25)                                            ' jha update tod
  lockclr(RtcLockID)                    
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

pub wizzard |  temp0, temp1, temp2, readSize 

  pausemsec(100)
  'Testing Socket 0's status register and display information
  PlxST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readIND(ETHERNET#_S0_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_INIT   : PlxST.Str(string("$13 - socket initalized", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    ETHERNET#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))  
   
pub lcdUpdate | X
{{
In this cog we update the LCD with tod, timer and temperature data
}}
  
  hasPomed := 0                 ' keep track if the Pomodoro time has been reached.
  dira[SHT_DATA]~
  dira[SHT_CLOCK]~~

  lcd.tx(12)                    ' cls then pause 5ms per lcd documentation
  pausemsec(5)
  lcd.tx(22)                    ' Turn the display on, with cursor off and no blink
  lcd.tx(17)                    ' turn on backlight
  
  repeat
{
      Check for a forward tilt. User wants LCD backlight on.
}
    if MM2125.MxTilt > 10
     
      isLCDon := 1 - isLCDon
      if isLCDon <> 0
        lcd.tx(17)
        pausemsec(750)
        plxst.str(string("tilt toggle backlight on ",cr,lf))
      else
        plxst.str(string("tilt toggle backlight off ",cr,lf))          
        LCD.tx(18)
        pausemsec(750)
{
        Check for a left hand tilt. User wants to reset timer.
}        
    if MM2125.MyTilt > 10
      '.tx(9)
      timer.reset
      timer.run
      plxst.str(string("Tilt, timer reset ",cr,lf))
      pausemsec(750)
{
        Update the LCD. Use lock semaphores to relieve contention with Main
}
    lcd.str(string(128))                                ' Move cursor to line 0, position 0 
    repeat until not lockset(RtcLockID)                 ' manage potential contention for RTC access
    lockset(RtcLockID)
    RTC.Update
    lcd.str(RTC.ShortFmtDateTime)                       ' print short dateTime
    lockclr(RtcLockID)

    lcd.str(string(148))                                ' Move cursor to line 1, position 0
    lcd.str(string("Tf In: ")) 
    repeat until not lockset(ShtLockID)                 ' manage contention for Sensirion access
    lockset(ShtLockID)
    rawTemp := f.FFloat(sht.readTemperature)
    tempC := celsius(rawTemp)
    lcd.str(fp.FloatToFormat(fahrenheit(tempC), 5,1))    ' print temperature in degrees fahrenheit
    lockclr(ShtLockID)
    lcd.str(string(168))                                ' Move cursor to line 2, position 0
    lcd.str(string("Pomodoro timer"))
    lcd.str(string(188))                                ' Move cursor to line 3, position 0  
    lcd.str(timer.showTimer)
    pomTime
    'pausemsec(750)

PUB pomTime
{{
    Check to see if we have reached the pomodoro time period
    Display as flashing LCD. I have a C version of the LCD otherwise
    I would play an audible alarm as well. 
}}
    if (timer.rdReg(2) == 1) and (timer.rdReg(1) < 10) '(hasPomed == 0) ' read the minutes register.
      repeat 6
        plxst.str(string(cr,lf,"it's pomTime",cr,lf))
        lcd.tx(17)
        PauseMSec(250)
        lcd.tx(18)
        PauseMSec(250)
     hasPomed := 1
             
PUB doXmlDateTime
{{
      Create a dateTime for inclusion in the XML for .net compatibility.
}}
     
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

pub ntpToRtc
{{
      A utility to set the Spinneret RTC with an SNTP source.
}}
    PlxST.str(String("Update RTC from SNTP"))

'                          Open UDP socket
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈
    ETHERNET.SocketOpen(udpntpsock,ETHERNET#_UDPPROTO,TIME_PORT,0,@IP)
    'check the status of the socket for connection and get internet time
    if ReadStatus(udpntpsock) == ETHERNET#_SOCK_UDP
       PauseMSec(250)   '<-- Some Delay required here after socket connection
       if GetTime(udpntpsock,@Buffer)
'                        Decode 64-Bit time from server           
'≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈       
          SNTP.GetTransmitTimestamp(Zone,@Buffer,@LongHIGH,@LongLOW)

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
    ETHERNET.txUDP(sockNum, BufferAddress) '<-- Send the UDP packet

    repeat 10*TIMEOUT_SECS
      i := ETHERNET.rxUDP(sockNum,BufferAddress)  
      if i == 56
         ETHERNET.SocketClose(sockNum)  '<-- At this point we are done, we have
                                    '     the time data and don't need to keep
                                    '     the connection active.
         return 1                   '<- Time Data is ready
      PauseMSec(100) '<- if 1000 = 1 sec ; 10 = 1/100th sec X 100 repeats above = 1 sec   
    return -1                       '<- Timed out without a response

PUB celsius(t)
    ' from SHT1x/SHT7x datasheet using value for 3.5V supply
    ' celsius = -39.7 + (0.01 * t)
'    return f.FAdd(-39.7, f.FMul(0.01, t))
    'return f.FAdd(-39.875, f.FMul(0.01, t))   ' ~ 4.5vdc
     return f.FAdd(-40.0, f.FMul(0.01, t))   ' 5vdc

PUB fahrenheit(t)
    ' fahrenheit = (celsius * 1.8) + 32
    return f.FAdd(f.FMul(t, 1.8), 32.0)  

PRI ReadStatus(socket) | status
  PlxST.Str(string("Socket "))
  PlxST.Dec(socket)
  PlxST.STR(string(" Status Register: "))
  ETHERNET.readIND((ETHERNET#_S0_SR + (socket * $0100)), @status, 1)

  case status
    ETHERNET#_SOCK_CLOSED : PlxST.Str(string("$00 - socket closed", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_INIT   : PlxST.Str(string("$13 - socket initialized", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_LISTEN : PlxST.Str(string("$14 - socket listening", PlxST#NL, PlxST#NL))
    ETHERNET#_SOCK_ESTAB  : PlxST.Str(string("$17 - socket established", PlxST#NL, PlxST#NL))    
    ETHERNET#_SOCK_UDP    : PlxST.Str(string("$22 - socket UDP open", PlxST#NL, PlxST#NL))

  return status
  
PRI SetVerifyMAC(_firstOctet)

  'Set the MAC ID and display it in the terminal
  ETHERNET.WriteMACaddress(true, _firstOctet)

  
  PlxST.Str(string("  Set MAC ID........"))
  PlxST.hex(byte[_firstOctet + 0], 2)
  PlxST.Str(string(":"))
  PlxST.hex(byte[_firstOctet + 1], 2)
  PlxST.Str(string(":"))
  PlxST.hex(byte[_firstOctet + 2], 2)
  PlxST.Str(string(":"))
  PlxST.hex(byte[_firstOctet + 3], 2)
  PlxST.Str(string(":"))
  PlxST.hex(byte[_firstOctet + 4], 2)
  PlxST.Str(string(":"))
  PlxST.hex(byte[_firstOctet + 5], 2)
  PlxST.Str(string(PlxST#NL))

  'Wait a moment
  PauseMSec(500)
 
  ETHERNET.ReadMACAddress(@vMAC[0])
  
  PlxST.Str(string("  Verified MAC ID..."))
  PlxST.hex(vMAC[0], 2)
  PlxST.Str(string(":"))
  PlxST.hex(vMAC[1], 2)
  PlxST.Str(string(":"))
  PlxST.hex(vMAC[2], 2)
  PlxST.Str(string(":"))
  PlxST.hex(vMAC[3], 2)
  PlxST.Str(string(":"))
  PlxST.hex(vMAC[4], 2)
  PlxST.Str(string(":"))
  PlxST.hex(vMAC[5], 2)
  PlxST.Str(string(PlxST#NL))
  PlxST.Str(string(PlxST#NL))

  return 'end of SetVerifyMAC

PRI SetVerifyGateway(_firstOctet)

  'Set the Gatway address and display it in the terminal
  ETHERNET.WriteGatewayAddress(true, _firstOctet)

  PlxST.Str(string("  Set Gateway....."))
  PlxST.dec(byte[_firstOctet + 0])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 1])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 2])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 3])
  PlxST.Str(string(PlxST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadGatewayAddress(@vGATEWAY[0])
  
  PlxST.Str(string("  Verified Gateway.."))
  PlxST.dec(vGATEWAY[0])
  PlxST.Str(string("."))
  PlxST.dec(vGATEWAY[1])
  PlxST.Str(string("."))
  PlxST.dec(vGATEWAY[2])
  PlxST.Str(string("."))
  PlxST.dec(vGATEWAY[3])
  PlxST.Str(string(PlxST#NL))
  PlxST.Str(string(PlxST#NL))

  return 'end of SetVerifyGateway

PRI SetVerifySubnet(_firstOctet)

  'Set the Subnet address and display it in the terminal
  ETHERNET.WriteSubnetMask(true, _firstOctet)

  PlxST.Str(string("  Set Subnet......"))
  PlxST.dec(byte[_firstOctet + 0])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 1])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 2])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 3])
  PlxST.Str(string(PlxST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadSubnetMask(@vSUBNET[0])
  
  PlxST.Str(string("  Verified Subnet..."))
  PlxST.dec(vSUBNET[0])
  PlxST.Str(string("."))
  PlxST.dec(vSUBNET[1])
  PlxST.Str(string("."))
  PlxST.dec(vSUBNET[2])
  PlxST.Str(string("."))
  PlxST.dec(vSUBNET[3])
  PlxST.Str(string(PlxST#NL))
  PlxST.Str(string(PlxST#NL))

  return 'end of SetVerifySubnet

PRI SetVerifyIP(_firstOctet)

  'Set the IP address and display it in the terminal
  ETHERNET.WriteIPAddress(true, _firstOctet)

  PlxST.Str(string("  Set IP.........."))
  PlxST.dec(byte[_firstOctet + 0])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 1])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 2])
  PlxST.Str(string("."))
  PlxST.dec(byte[_firstOctet + 3])
  PlxST.Str(string(PlxST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadIPAddress(@vIP[0])
  
  PlxST.Str(string("  Verified IP......."))
  PlxST.dec(vIP[0])
  PlxST.Str(string("."))
  PlxST.dec(vIP[1])
  PlxST.Str(string("."))
  PlxST.dec(vIP[2])
  PlxST.Str(string("."))
  PlxST.dec(vIP[3])
  PlxST.Str(string(PlxST#NL))
  PlxST.Str(string(PlxST#NL))

  return 'end of SetVerifyIP

PRI StringSend(_socket, _dataPtr)

  ETHERNET.txTCP(0, _dataPtr, strsize(_dataPtr))

  return 'end of StringSend

PRI OpenSocketAgain

  ETHERNET.SocketOpen(0, ETHERNET#_TCPPROTO, localSocket, destSocket, @destIP[0])
  ETHERNET.SocketTCPlisten(0)

  return 'end of OpenSocketAgain
  
PRI PauseMSec(Duration)

''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

  return  'end of PauseMSec

DAT

isLCDon       byte 0
isLEDon       byte 0
hasPomed      byte 0

d1      byte  "  ",0
{{ 
                        main HTML page
}}
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

{{ 
                     XML page of temperature and time   
}}        

xml0    byte  "HTTP/1.1 200 OK", CR, LF
        byte  "Cache-Control: no-cache, must-revalidate", CR, LF
        byte  "Connection: close",CR, LF
        byte  "Content-Type: text/html",CR,LF,CR,LF
        byte  "<?xml version='1.0' encoding='UTF-8'?>"
        byte  "<SummaryTemperatureData xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>",10
        byte  "<DataLoggerDeviceName>JHA nerdDoro</DataLoggerDeviceName>"
        byte  "<CurrentTemperature0>"
        byte  0
xmltf   byte  "    "
xml1    byte  "</CurrentTemperature0>"
        byte  "<CurrentMeasuredTime>"
        byte  0
xmldt   byte  "                   "
xml2    byte  "</CurrentMeasuredTime>"
        byte  "</SummaryTemperatureData>",10
        byte  0


{{

xml0    byte  "HTTP/1.1 200 OK", CR, LF
        byte  "Connection: close",CR, LF
        byte  "Content-Type: text/html",CR,LF,CR,LF
        byte  "<?xml version='1.0' encoding='UTF-8'?>"
        byte  "<nerdDoroData xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>",10
        byte  "<currentTemperature0>"
        byte  0
xmltf   byte  "    "
xml1    byte  "</currentTemperature0>"
        byte  "<currentMeasuredTime>"
        byte  0
xmldt   byte  "                   "
xml2    byte  "</currentMeasuredTime>"
        byte  "</nerdDoroData>",10
        byte  0

}}

con
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}