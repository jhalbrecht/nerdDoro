'**************************************************************
'* jReadRTC                                                     *
'**************************************************************
CON
    _clkmode = xtal1 + pll16x
    _clkfreq = 80_000_000
    
  TX_PIN        = 22
  BAUD          = 19_200    

OBJ                                  'include 2 ViewPort objects:
  W5100  : "Brilldea_W5100_Indirect_Driver_Ver006"
  SNTP   : "SNTP Simple Network Time Protocol"
  RTC    : "s-35390A_GBSbuild_02_09_2011"
 ' vp    : "Conduit"                   'transfers data to/from PC
  vp    : "terminal"
 'qs    : "QuickSample"               'samples INA continuously in 1 cog- up to 20Msps
  i2c   : "basic_i2c_driver"
  LCD           : "FullDuplexSerial.spin"
 'vp  : "Parallax Serial Terminal" 
   STR           : "STREngine"  
 
VAR
  long dbstack[5],dbhere,dbdebug,dbpause,dbstptr
  long frame[400]                    'stores measurements of INA port
  long v1,v2                        'vars shared with ViewPort
  long reps ' jeffa using for repeat counter. just learning...
  
  byte shortDataBuffer[30]
  byte j[30]

PUB main
dbstptr:=-1
 vp.config(string("start:terminal::terminal:1"))
 'vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
 vp.debug(@dbstack,@dbhere)
 vp.share(@v1,@shortDataBuffer)          'share variable

' waitcnt(clkfreq + cnt)

  if (dbpause & 1)
    dbdebug:=38
  repeat while(dbdebug==38)
    dbhere:=38
  LCD.start(TX_PIN, TX_PIN, %1000, 19_200)
  if (dbpause & 1)
    dbdebug:=39
  repeat while(dbdebug==39)
    dbhere:=39
  waitcnt(clkfreq / 100 + cnt)                ' Pause for FullDuplexSerial.spin to initialize
  
    if (dbpause & 1)
      dbdebug:=41
    repeat while(dbdebug==41)
      dbhere:=41
    RTC.start                     'Initialize On board Real Time Clock
    'vp.Position(1, 1)

  if (dbpause & 1)
    dbdebug:=44
  repeat while(dbdebug==44)
    dbhere:=44
  repeat
      if (dbpause & 1)
        dbdebug:=45
      repeat while(dbdebug==45)
        dbhere:=45
      reps++
      if (dbpause & 1)
        dbdebug:=46
      repeat while(dbdebug==46)
        dbhere:=46
      RTC.Update
      if (dbpause & 1)
        dbdebug:=47
      repeat while(dbdebug==47)
        dbhere:=47
      vp.str(string(12,13))
      if (dbpause & 1)
        dbdebug:=48
      repeat while(dbdebug==48)
        dbhere:=48
      vp.str(string(12,13))
      if (dbpause & 1)
        dbdebug:=49
      repeat while(dbdebug==49)
        dbhere:=49
      vp.str(RTC.FmtDateTime)
      if (dbpause & 1)
        dbdebug:=50
      repeat while(dbdebug==50)
        dbhere:=50
      vp.str(string(12,13))
      
      'vp.str(rtc.GetYear)
      ' PUB numberToDecimal(number, length) '' 5 Stack Longs 
      '  2011-01-03T03:41:02
      
      
      if (dbpause & 1)
        dbdebug:=57
      repeat while(dbdebug==57)
        dbhere:=57
      vp.str(string(12,13," make it look like: 2011-01-03T03:41:02 ",12,13))
      
      ' 2011-01-03T03:41:02
      ' 01234567890123456789

      if (dbpause & 1)
        dbdebug:=62
      repeat while(dbdebug==62)
        dbhere:=62
      bytemove(@j[0], string("20"), 2)
      if (dbpause & 1)
        dbdebug:=63
      repeat while(dbdebug==63)
        dbhere:=63
      bytemove(@j[2], str.trimCharacters(str.numberToDecimal(rtc.GetYear, 2)), 2)
      if (dbpause & 1)
        dbdebug:=64
      repeat while(dbdebug==64)
        dbhere:=64
      bytemove(@j[4], string("-"), 1)
      if (dbpause & 1)
        dbdebug:=65
      repeat while(dbdebug==65)
        dbhere:=65
      bytemove(@j[5], str.trimCharacters(str.numberToDecimal(rtc.GetMonth, 2)), 2)
      if (dbpause & 1)
        dbdebug:=66
      repeat while(dbdebug==66)
        dbhere:=66
      bytemove(@j[7], string("-"), 1)
      if (dbpause & 1)
        dbdebug:=67
      repeat while(dbdebug==67)
        dbhere:=67
      bytemove(@j[8], str.trimCharacters(str.numberToDecimal(rtc.GetDay, 2)), 2)
      if (dbpause & 1)
        dbdebug:=68
      repeat while(dbdebug==68)
        dbhere:=68
      bytemove(@j[10], string("T"), 1)
      if (dbpause & 1)
        dbdebug:=69
      repeat while(dbdebug==69)
        dbhere:=69
      if rtc.IsPM
        if (dbpause & 1)
          dbdebug:=70
        repeat while(dbdebug==70)
          dbhere:=70
        bytemove(@j[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour + 12, 2)), 2)
      else
        if (dbpause & 1)
          dbdebug:=72
        repeat while(dbdebug==72)
          dbhere:=72
        bytemove(@j[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour, 2)), 2)
      if (dbpause & 1)
        dbdebug:=73
      repeat while(dbdebug==73)
        dbhere:=73
      bytemove(@j[13], string(":"), 1)
      if (dbpause & 1)
        dbdebug:=74
      repeat while(dbdebug==74)
        dbhere:=74
      bytemove(@j[14], str.trimCharacters(str.numberToDecimal(rtc.GetMinutes, 2)), 2)
      if (dbpause & 1)
        dbdebug:=75
      repeat while(dbdebug==75)
        dbhere:=75
      bytemove(@j[16], string(":"), 1)      
      if (dbpause & 1)
        dbdebug:=76
      repeat while(dbdebug==76)
        dbhere:=76
      bytemove(@j[17], str.trimCharacters(str.numberToDecimal(rtc.GetSeconds, 2)), 2)
      if (dbpause & 1)
        dbdebug:=77
      repeat while(dbdebug==77)
        dbhere:=77
      j[19] := 0
      if (dbpause & 1)
        dbdebug:=78
      repeat while(dbdebug==78)
        dbhere:=78
      vp.str(@j)      
      if (dbpause & 1)
        dbdebug:=79
      repeat while(dbdebug==79)
        dbhere:=79
      PauseMSec(500)
      if (dbpause & 1)
        dbdebug:=80
      repeat while(dbdebug==80)
        dbhere:=80
      vp.str(rtc.xmlDateTime)
      

PRI PauseMSec(Duration)
dbstack[++dbstptr]:=1
'***************************************
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  if (dbpause & 2)
    dbdebug:=91
  repeat while(dbdebug==91)
    dbhere:=91
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)


dbstack[dbstptr--]~
DAT
{{
012345678901234567890123456789
Tue Jul 12, 2011 07:18:00 AM'
Tue Jul 12 08:51:03 AM
Tue Jul 12 08:51 AM
}}
shortTOD  byte "NNN MMM DD"
shortTOD1 byte ", YYYY HH:MM:SS XM"
          byte 0

