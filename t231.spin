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
  'LCD.str(string("Hi world, how hot?"))

  if (dbpause & 1)
    dbdebug:=42
  repeat while(dbdebug==42)
    dbhere:=42
  waitcnt(clkfreq + cnt)    
    'RTC.start                     'Initialize On board Real Time Clock
    'vp.Position(1, 1)
    if (dbpause & 1)
      dbdebug:=45
    repeat while(dbdebug==45)
      dbhere:=45
    repeat
      if (dbpause & 1)
        dbdebug:=46
      repeat while(dbdebug==46)
        dbhere:=46
      reps++
      if (dbpause & 1)
        dbdebug:=47
      repeat while(dbdebug==47)
        dbhere:=47
      RTC.Update
      if (dbpause & 1)
        dbdebug:=48
      repeat while(dbdebug==48)
        dbhere:=48
      vp.str(string(12,13))
      if (dbpause & 1)
        dbdebug:=49
      repeat while(dbdebug==49)
        dbhere:=49
      vp.str(string(12,13))
      if (dbpause & 1)
        dbdebug:=50
      repeat while(dbdebug==50)
        dbhere:=50
      vp.str(RTC.FmtDateTime)
      if (dbpause & 1)
        dbdebug:=51
      repeat while(dbdebug==51)
        dbhere:=51
      vp.str(string(12,13))
      
      if (dbpause & 1)
        dbdebug:=53
      repeat while(dbdebug==53)
        dbhere:=53
      bytemove (@j,rtc.FmtDateTime,30)


      'ShortDataBuffer := str(rtc.FmtDateTime)
      ' vp.str(@FmtDateTime)
      'vp.str(@shortDataBuffer)
      if (dbpause & 1)
        dbdebug:=59
      repeat while(dbdebug==59)
        dbhere:=59
      vp.str(string(12,13," j ",12,13))
      if (dbpause & 1)
        dbdebug:=60
      repeat while(dbdebug==60)
        dbhere:=60
      vp.str(@j)
      
      if (dbpause & 1)
        dbdebug:=62
      repeat while(dbdebug==62)
        dbhere:=62
      bytemove (@shortTOD,rtc.FmtDateTime,30)
      if (dbpause & 1)
        dbdebug:=63
      repeat while(dbdebug==63)
        dbhere:=63
      bytemove (@shortTOD[10],@shortTOD[16],12)
      if (dbpause & 1)
        dbdebug:=64
      repeat while(dbdebug==64)
        dbhere:=64
      bytemove (@shortTOD[16],@shortTOD[19],3)
      if (dbpause & 1)
        dbdebug:=65
      repeat while(dbdebug==65)
        dbhere:=65
      bytemove (@shortTOD[19], 0, 1)
      if (dbpause & 1)
        dbdebug:=66
      repeat while(dbdebug==66)
        dbhere:=66
      vp.str(string(12,13,"shortTOD",12,13))
      'vp.str(RTC.ShortFmtDateTime)
      if (dbpause & 1)
        dbdebug:=68
      repeat while(dbdebug==68)
        dbhere:=68
      vp.str(@shortTOD)
      ' vp.str(@shortTOD)      
    
      if (dbpause & 1)
        dbdebug:=71
      repeat while(dbdebug==71)
        dbhere:=71
      LCD.str(RTC.FmtDateTime)
      if (dbpause & 1)
        dbdebug:=72
      repeat while(dbdebug==72)
        dbhere:=72
      vp.str(string(12,13))
      if (dbpause & 1)
        dbdebug:=73
      repeat while(dbdebug==73)
        dbhere:=73
      waitcnt(clkfreq + cnt)

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
      


PUB jeffit(jTimes) '   jeffit(2)
dbstptr:=-1
  if (dbpause & 1)
    dbdebug:=89
  repeat while(dbdebug==89)
    dbhere:=89
  repeat jTimes ' jTimes
   if (dbpause & 1)
     dbdebug:=90
   repeat while(dbdebug==90)
     dbhere:=90
   vp.str(string(" Someday I hope this will loop",12,13))     
   
   {{
           
      if (dbpause & 1)
        dbdebug:=94
      repeat while(dbdebug==94)
        dbhere:=94
      shortDataBuffer[0] := "j"
      if (dbpause & 1)
        dbdebug:=95
      repeat while(dbdebug==95)
        dbhere:=95
      shortDataBuffer[1] := "e"
      if (dbpause & 1)
        dbdebug:=96
      repeat while(dbdebug==96)
        dbhere:=96
      shortDataBuffer[2] := "f"
      if (dbpause & 1)
        dbdebug:=97
      repeat while(dbdebug==97)
        dbhere:=97
      shortDataBuffer[3] := "f" 
      if (dbpause & 1)
        dbdebug:=98
      repeat while(dbdebug==98)
        dbhere:=98
      shortDataBuffer[4] := "a"
      if (dbpause & 1)
        dbdebug:=99
      repeat while(dbdebug==99)
        dbhere:=99
      shortDataBuffer[5] := "2"
      if (dbpause & 1)
        dbdebug:=100
      repeat while(dbdebug==100)
        dbhere:=100
      shortDataBuffer[6] := "5"
      if (dbpause & 1)
        dbdebug:=101
      repeat while(dbdebug==101)
        dbhere:=101
      shortDataBuffer[7] := "4"
      if (dbpause & 1)
        dbdebug:=102
      repeat while(dbdebug==102)
        dbhere:=102
      shortDataBuffer[8] := 0
      }}
dbstack[dbstptr--]~
