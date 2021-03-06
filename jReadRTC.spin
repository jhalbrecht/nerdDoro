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
  long frame[400]                    'stores measurements of INA port
  long v1,v2                        'vars shared with ViewPort
  long reps ' jeffa using for repeat counter. just learning...
  
  byte shortDataBuffer[30]
  byte j[30]

PUB main
 vp.config(string("start:terminal::terminal:1"))
 'vp.register(qs.sampleINA(@frame,1))'sample INA into <frame> array
 vp.share(@v1,@shortDataBuffer)          'share variable

' waitcnt(clkfreq + cnt)

  LCD.start(TX_PIN, TX_PIN, %1000, 19_200)
  waitcnt(clkfreq / 100 + cnt)                ' Pause for FullDuplexSerial.spin to initialize
  
    RTC.start                     'Initialize On board Real Time Clock
    'vp.Position(1, 1)

  repeat
      reps++
      RTC.Update
      vp.str(string(12,13))
      vp.str(string("begin pomodoro "))
      vp.str(RTC.FmtDateTime)
      
      vp.str(string(12,13))
      PauseMSec(1000*60*60*25)
      ' PauseMSec(5000)
      vp.str(string("end pomodoro   "))
      vp.str(rtc.FmtDateTime)
      vp.str(string(12,13))
      




  {{   
      'vp.str(rtc.GetYear)
      ' PUB numberToDecimal(number, length) '' 5 Stack Longs 
      '  2011-01-03T03:41:02
      
      
      vp.str(string(12,13," make it look like: 2011-01-03T03:41:02 ",12,13))
      
      ' 2011-01-03T03:41:02
      ' 01234567890123456789

      bytemove(@j[0], string("20"), 2)
      bytemove(@j[2], str.trimCharacters(str.numberToDecimal(rtc.GetYear, 2)), 2)
      bytemove(@j[4], string("-"), 1)
      bytemove(@j[5], str.trimCharacters(str.numberToDecimal(rtc.GetMonth, 2)), 2)
      bytemove(@j[7], string("-"), 1)
      bytemove(@j[8], str.trimCharacters(str.numberToDecimal(rtc.GetDay, 2)), 2)
      bytemove(@j[10], string("T"), 1)
      if rtc.IsPM
        bytemove(@j[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour + 12, 2)), 2)
      else
        bytemove(@j[11], str.trimCharacters(str.numberToDecimal(rtc.GetHour, 2)), 2)
      bytemove(@j[13], string(":"), 1)
      bytemove(@j[14], str.trimCharacters(str.numberToDecimal(rtc.GetMinutes, 2)), 2)
      bytemove(@j[16], string(":"), 1)      
      bytemove(@j[17], str.trimCharacters(str.numberToDecimal(rtc.GetSeconds, 2)), 2)
      j[19] := 0
      vp.str(@j)      
      PauseMSec(500)
      vp.str(rtc.xmlDateTime)
      
    }}
PRI PauseMSec(Duration)
'***************************************
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)


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