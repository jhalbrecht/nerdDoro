'' S-35390A RTC Driver  Version 1.0
'' Copyright (c) 2010 Roy ELtham
'' November 13, 2010
'' See end of file for terms of use

'' This uses the basic i2c driver available on the obex site
'' 
'' This is the RTC chip used on the Spinneret Web Server.
''

'' 07-12-2011 - jeffa added ShortFmtDateTime to PUB Returns similar to: "Tue Jul 12 08:51 AM"
'' 01-23-2011 - (Beau Schwabe added 'FmtDateTime') to PUB operations

CON
    _clkmode = xtal1 + pll16x
    _clkfreq = 80_000_000
    
    SCL       = 28           ' SCL pin of the s-35390A, SDA is assumed to be
                             ' one pin higher by the i2c driver
                             
    DeviceID  = %0110_0000   ' S-35390A device id
    
    ' S-35390A commands, These are combined with DeviceID to read or write the chip registers
    Command_Status1         = %0000_0000
    Command_Status2         = %0000_0010
    Command_DateTime        = %0000_0100
    Command_Time            = %0000_0110
    Command_Alarm1          = %0000_1000
    Command_Alarm2          = %0000_1010
    Command_ClockCorrection = %0000_1100
    Command_UserData        = %0000_1110
    
    ' these are combined with the DeviceID and commands to
    ' indicate reading or writing of the data
    Read  = 1
    Write = 0

  
OBJ
 i2c   : "basic_i2c_driver"

VAR
  long Status1, Status2
  long DateTime[7]        ' year(0 to 99), month, day, day of week (0 to 6), hour, minute, seconds
  long Mode24Hour         ' 0 = 12 hour mode, 1 = 24 hour mode
  long PM                 ' 0 = AM, 1 = PM
  long AlarmOccurred[2]   ' status of the 2 alarms, 0 = did not occur, 1 = did occur

  byte DataBuffer[30]

' if you have ViewPort you can uncomment this block of code to test the driver with it
{
OBJ
 vp    : "Conduit"                   'transfers data to/from PC

VAR
  long UserData
  
PUB main
  vp.config(string("var:Status1,Status2,t0,t1,t2,t3,t4,t5,t6,Mode24Hour,PM,Alarm1,Alarm2,UserData"))
  vp.config(string("start:dso"))
  vp.config(string("dso:view=[Status1],timescale=1s"))
  vp.share(@Status1,@UserData)    'share variable
 
  waitcnt(cnt+clkfreq)

  start
  
  Set24HourMode(0)
  SetDateTime(11,17,10,3,1,0,0)
  'SetAlarm(0,-1,0,57)
  'SetAlarm(1,-1,0,58)
  'SetUserData(35)
  
  repeat
    Update    
    UserData := GetUserData
    waitcnt(cnt+clkfreq/10)
}

PUB start

  i2c.Initialize(SCL)

  ' disable the alarms (int pins) 
  SetStatus2(%0000_0000)
  
  Update


PUB FmtDateTime|p,r
    Update                      ' Update RTC values
    p := string("MonTueWedThuFriSatSun")
    r := DateTime[3]            ' GetDayOfWeek
    bytemove(@DataBuffer,p+r*3,3)
    DataBuffer[3] := " "
    p := string("JanFebMarAprMayJunJulAugSepOctNovDec")
    r := DateTime[1]-1          ' GetMonth
    bytemove(@DataBuffer+4,p+r*3,3)
    DataBuffer[7] := " "
    r := DateTime[2]            ' GetDay
    DataBuffer[8] := (r/10)+48    
    DataBuffer[9] := r-((r/10)*10)+48
    DataBuffer[10] := ","

    DataBuffer[11] := " "
    DataBuffer[12] := "2"
    DataBuffer[13] := "0"
    r := DateTime[0]            ' GetYear
    DataBuffer[14] := (r/10)+48
    DataBuffer[15] := r-((r/10)*10)+48
    DataBuffer[16] := " "
    r := DateTime[4]            ' GetHour
    DataBuffer[17] := (r/10)+48    
    DataBuffer[18] := r-((r/10)*10)+48
    DataBuffer[19] := ":"
    r := DateTime[5]            ' GetMinutes
    DataBuffer[20] := (r/10)+48    
    DataBuffer[21] := r-((r/10)*10)+48
    DataBuffer[22] := ":"
    r := DateTime[6]            ' GetSeconds
    DataBuffer[23] := (r/10)+48    
    DataBuffer[24] := r-((r/10)*10)+48
    DataBuffer[25] := " "
    If Mode24Hour == 0
       If PM == 0
          DataBuffer[26]:="A"
       else
          DataBuffer[26]:="P"
       DataBuffer[27]:="M"
    else      
       DataBuffer[28]:=0         
    return @DataBuffer

PUB ShortFmtDateTime      ' jeffa 7/12/2011 Returns similar to: "Tue Jul 12 08:51 AM"

      FmtDateTime
      bytemove (@DataBuffer[10], @DataBuffer[16], 12)
      bytemove (@DataBuffer[16], @DataBuffer[19], 3)
      bytemove (@DataBuffer[19], 0, 1)
      return @DataBuffer

PUB GetYear
  return DateTime[0]
  
PUB GetMonth
  return DateTime[1]
  
PUB GetDay
  return DateTime[2]
  
PUB GetDayOfWeek
  return DateTime[3]
  
PUB GetHour
  return DateTime[4]
  
PUB GetMinutes
  return DateTime[5]
  
PUB GetSeconds
  return DateTime[6]
  
PUB Is24HourMode
  return Mode24Hour
  
PUB IsPM
  return PM


'' This functions tells you if the indicated alarm occurred since the last time you called
'' this function. These flags are potentially set by calls to GetStatus1, Update, SetTime, or SetDateTime.
'' The flag for the indicated alarm is cleared by this function so it can be triggered again later.
'' whichAlarm should be 0 or 1
PUB DidAlarmOccur(whichAlarm)

  ' clamp incoming value
  whichAlarm := 0 #> whichAlarm <# 1
  result := AlarmOccurred[whichAlarm]
  AlarmOccurred[whichAlarm] := 0


'' state should be 0 for 12 hour mode or 1 for 24 hour mode
PUB Set24HourMode(state)

  ' clamp incoming value
  Mode24Hour := 0 #> state <# 1

  ' read the current Status1 value
  Status1 := GetStatus1

  ' update the 12/14 bit based on state
  if Mode24Hour == 1
    Status1 |= %0100_0000       ' or in the bit
    ' fix up our stored hour
    if PM == 1 AND DateTime[4] < 12
      DateTime[4] += 12
  else
    Status1 &= %1011_1111       ' mask off the bit
    ' fix up our stored hour
    if PM == 1
      DateTime[4] -= 12
      ' in 12 hour mode change hour 0 to 12
      if DateTime[4] == 0
        DateTime[4] := 12

  SetStatus1(Status1)

    
'' The hour is expected in 24 hour mode, it will be converted into 12 hour mode if you have set that mode.
'' I did this to save having another parameter passed in for the AM/PM flag which would be ignored in
'' 24 hour mode.
'' dayOfWeek is a value from 0 to 6, you can set it to whatever you want for whatever day, and the clock will just 
'' increment it each day, wrapping at 6 back to 0. You probably want to use 0 to either Sunday or Monday.
'' It only matters if you set an alarm with a dayOfWeek enabled.
PUB SetDateTime(month, day, year, dayOfWeek, hour, minutes, seconds) | index
  DateTime[0] := ConvertToBCD(year)
  DateTime[1] := ConvertToBCD(month)
  DateTime[2] := ConvertToBCD(day)
  DateTime[3] := ConvertToBCD(dayOfWeek)
  
  ' adjust hour based on 12/24 hour mode
  if Mode24Hour == 0 AND hour > 11
    hour -= 12
    DateTime[4] := ConvertToBCD(hour) | %0100_0000
  else
    DateTime[4] := ConvertToBCD(hour)
    
  DateTime[5] := ConvertToBCD(minutes)
  DateTime[6] := ConvertToBCD(seconds)

  ' write out the full date and time to the chip
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_DateTime | Write)
  repeat index from 0 to 6 
    i2c.Write(SCL, DateTime[index] >< 8)
  i2c.Stop(SCL)

  ' reread the date & time to fix our stored values
  Update

'' The hour is expected in 24 hour mode, it will be converted into 12 hour mode if you have set that mode.
'' I did this to save having another parameter passed in for the AM/PM flag which would be ignored in
'' 24 hour mode.
PUB SetTime(hour, minutes, seconds) | index

  ' adjust hour based on 24/12 hour mode
  if Is24HourMode == 0 AND hour > 11
    hour -= 12
    DateTime[4] := ConvertToBCD(hour) | %0100_0000 ' or in the am/pm flag (high = pm)
  else
    DateTime[4] := ConvertToBCD(hour)
    
  DateTime[5] := ConvertToBCD(minutes)
  DateTime[6] := ConvertToBCD(seconds)

  ' write out the time to the chip
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_Time | Write)
  repeat index from 4 to 6 
    i2c.Write(SCL, DateTime[index] >< 8)
  i2c.Stop(SCL)
  
  ' reread the date & time to fix our stored values
  Update
  
'' Sets the indicated alarm. The hour value is expected to be in 24 hour mode (like SetTime)
'' if dayOfWeek, hour, or minute are negative values then the alarm will not use that portion
'' of the setting.  For example, SetAlarm(0, -1, 10, 30) will have the alarm go off every morning
'' at 10:30am, SetAlarm(0, -1, -1, 15) will have the alarm go off 15 minutes after every hour of
'' every day, SetAlarm(0, -1, -1, -1) will disable the alarm.  
'' dayOfWeek is a value from 0 to 6, and corresponds with whatever you set in SetDateTime. If, when you called
'' SetDateTime, you set dayOfWeek to be 0 for Sunday, then a value of 3 here would mean Wednesday.
PUB SetAlarm(alarmIndex, dayOfWeek, hour, minutes) | Alarm[3], index

  ' Clamp to valid range
  alarmIndex := 0 #> alarmIndex <# 1

  ' Set the indicated alarm into alarm mode  
  Status2 := GetStatus2
  if alarmIndex == 0
    Status2 := Status2 & %0001_1111  ' clear the alarm 1 state flags
    Status2 := %0010_0000 | Status2  ' set the alarm 1 state flags to be in alarm mode
  else
    Status2 := Status2 & %1111_0001  ' clear the alarm 2 state flags
    Status2 := %0000_0010 | Status2  ' set the alarm 2 state flags to be in alarm mode
  SetStatus2(Status2)

  ' setup what we are going to write to the alarm registers based on the input params
  '  
  if dayOfWeek > 0
    Alarm[0] := ConvertToBCD(dayOfWeek) | %1000_0000
  else
    Alarm[0] := 0

  if hour > 0
    if Is24HourMode == 0 AND hour > 11
      hour -= 12
      Alarm[1] := ConvertToBCD(hour) | %0100_0000 ' or in the am/pm flag (high = pm)
    else
      Alarm[1] := ConvertToBCD(hour) | %1000_0000
  else
    Alarm[1] := 0

  if minutes > 0
    Alarm[2] := ConvertToBCD(minutes) | %1000_0000
  else
    Alarm[2] := 0

  ' write out the cooked alarm info to the chip
  i2c.Start(SCL)
  if alarmIndex == 0
    i2c.Write(SCL, DeviceID | Command_Alarm1 | Write)
  else
    i2c.Write(SCL, DeviceID | Command_Alarm2 | Write)
  repeat index from 0 to 2 
    i2c.Write(SCL, Alarm[index] >< 8)
  i2c.Stop(SCL)

'' These 2 functions allow you to read and write a byte of data to the clock chip that is saved across
'' power cycling the Spinneret. It will be saved as long as the SuperCap keeps the RTC chip going (days).
PUB GetUserData : result
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_UserData | Read)
  result := i2c.Read(SCL, i2c#NAK)
  i2c.Stop(SCL)
  return result

PUB SetUserData(value)
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_UserData | Write)
  i2c.Write(SCL, value)
  i2c.Stop(SCL)


PUB GetStatus1 : result
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_Status1 | Read)
  result := i2c.Read(SCL, i2c#NAK)
  i2c.Stop(SCL)

  ' check to see if either alarm occurred
  ' we need to do this any time Status1 is read since reading it clears the alarm flags 
  if result & %0000_1000 <> 0
    AlarmOccurred[0] := 1
  if result & %0000_0100 <> 0
    AlarmOccurred[1] := 1

  ' Clear off the alarm flags and the reset bit (high bit).
  ' We clear the reset bit because we don't want to make it easy to accidentally reset the
  ' chip. Which could happen if we read Status1 and then use that value modified to write
  ' back to Status1.
  result &= %01110011
  
  return result

PUB SetStatus1(value)
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_Status1 | Write)
  i2c.Write(SCL, value)
  i2c.Stop(SCL)

PUB GetStatus2 : result

  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_Status2 | Read)
  result := i2c.Read(SCL, i2c#NAK)
  i2c.Stop(SCL)

  ' Clear off the low bit, this si the test bit and should always be zero.
  result &= %1111_1110
  
  return result

PUB SetStatus2(value)

  ' Clear off the low bit, this si the test bit and should always be zero.
  value &= %1111_1110
  
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_Status2 | Write)
  i2c.Write(SCL, value)
  i2c.Stop(SCL)


'' Read the full date and time from the chip. Also, updates our PM flag appropriately, and
'' updates the cached Status variables as well as the AlarmOccurred variable.
PUB Update | index, temp
  
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_DateTime | Read)
  
  ' read first 6 bytes
  repeat index from 0 to 5 
    temp := i2c.Read(SCL, i2c#ACK) >< 8

    ' the am/pm flag is valid in both 12 and 24 hour mode
    if index == 4 ' index 4 is the hour
      if temp & %0100_0000 ' check the am/pm flag bit
        PM := 1
        temp &= %1011_1111 ' mask off the am/pm flag bit
      else
        PM := 0            ' it's AM to clear the PM flag
        
    DateTime[index] := ConvertFromBCD(temp)
    
  ' read last byte   
  DateTime[6] := ConvertFromBCD(i2c.Read(SCL, i2c#NAK) >< 8)
  
  i2c.Stop(SCL)

  ' in 12 hour mode change hour 0 to 12
  if Mode24Hour == 0 AND DateTime[4] == 0
    DateTime[4] := 12

  ' update cached status variables by reading the chip status
  ' this will also update the Alarm1_Occurred and Alarm2_Occurred variables
  Status1 := GetStatus1
  Status2 := GetStatus2  

  
'' read the detailed information about clock correction in the S-35390A datasheet
'' before using these functions
PUB SetClockCorrection(value)
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_ClockCorrection | Write)
  i2c.Write(SCL, value)
  i2c.Stop(SCL)

PUB GetClockCorrection : result
  i2c.Start(SCL)
  i2c.Write(SCL, DeviceID | Command_ClockCorrection | Read)
  result := i2c.Read(SCL, i2c#NAK)
  i2c.Stop(SCL)
  return result


PRI ConvertToBCD(value) : result
  ' convert a long to Binary Coded Decimal
  result := ((value / 10) * 16) + (value // 10) 
  return result

PRI ConvertFromBCD(value) : result
  ' convert from Binary Coded Decimal to a long
  result := ((value / 16) * 10) + (value // 16) 
  return result
  
{{
                            TERMS OF USE: MIT License                                                           

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}