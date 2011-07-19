'' Timer Test
'' -- Jon Williams, Parallax
'' -- 06 APR 2006


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

  TX_PIN        = 22                                    ' jha for serial LCD   
  BAUD          = 19_200
  

OBJ

  lcd   : "serial_lcd"
  'LCD           : "FullDuplexSerial.spin" 
  timer : "timer"
    STR           : "STREngine" 

  
PUB main


if lcd.start(22, 19_200, 4)                            ' 4x20 Parallax LCD on A0, set to 19.2k
    lcd.cursor(0)                                       ' no cursor
    lcd.cls

    lcd.backlight(1)
                                   ' backlight on
    lcd.str(string("TIMER"))
    if timer.start                                      ' start timer cog
      timer.run
      repeat
        lcd.gotoxy(0, 1)                                ' move to col 0 on line 1
        lcd.str(timer.showTimer)

        if timer.rdReg(2) < 1  ' read the minutes register. 
          
          lcd.gotoxy(2,3)
          lcd.str(string(" less than 1 "))
        else
          
          lcd.gotoxy(2,3)
          lcd.str(string(" greater than 1 "))
        
    else
      lcd.cls
      lcd.str(string("No cog for Timer."))
      
  
PRI PauseMSec(Duration)
'***************************************
''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none                                                                  
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

  