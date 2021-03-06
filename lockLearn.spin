CON

  _clkfreq = 80_000_000
  _clkmode = xtal1 + pll16x

  CR          = 13
  LF          = 10  

obj

  PlxST         : "Parallax Serial Terminal"
  STR           : "STREngine"
    
var

  byte    RtcLockID
  byte    ShtLockID
  byte  pstLockID              
   
  long gedStack[256] 'Stack space for gitErDone cog
  long gitErDoneID
   


pub jTest

  PlxST.Start(115200)               '<-- Initialize Serial Communication to PC (debug)
  pausemsec(2000)
  PlxST.Home
  PlxST.Clear
   
  if (RtcLockID := locknew) == -1
    plxst.str(string("Error, locknew failed no locks available",cr,lf))
  else
    plxst.str(string("locknew success",cr,lf)) 

  if gitErDoneID := cognew(gitErDone, @gedStack)
    plxst.str(string(cr,lf,"gitErDone start succeeded.",cr,lf))
  else
    plxst.str(string(cr,lf,"gitErDone start failed.",cr,lf))    



  repeat
    plxst.str(string("start of jTest repeat loop",cr,lf))
    
    repeat until not lockset(RtcLockID)
    
    plxst.str(string("start loop",cr,lf))
    pausemsec(1500)
    plxst.str(string("end of jTest repeat loop",cr,lf))

pub gitErDone

  lockset(RtcLockID) 
  'repeat 5
    plxst.str(string("Begin gitErDone cog pause",cr,lf))
    pausemsec(7000)
   ' plxst.str(string("End of gitErDone pause",cr,lf))
    
  plxst.str(string("gitErDone cog pause done.",cr,lf))  
  lockclr(RtcLockID)
    
  
PRI PauseMSec(Duration)

''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none                                                                  
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

 