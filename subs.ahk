#SingleInstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Hotkey, x, goex
Hotkey, 1, syncplus
Hotkey, 2, syncminus
Hotkey, z, do_nothing

Hotkey, 3, ssminus
Hotkey, 4, ssplus

Hotkey, q, fontminus
Hotkey, w, fontplus
Hotkey, r, oup
Hotkey, e, odown
;Hotkey, t, toggle_transparency

Hotkey, a, tup
Hotkey, s, tdown

Hotkey, d, change_alignment
Hotkey, f, toggle_fade


Hotkey, p, toggle_pause
pause_start:=0

SysGet,s_width, 16
SysGet,s_widthv, 78

s_xx:=(s_widthv-s_width)
s_width:=s_widthv
s_xx:=s_xx/2

SysGet,s_height, 79
s_fontsize:=50
s_yy=100

; Read default settings from settings.ini

IniRead, s_fontsize, settings.ini,sub,fontsize,50
IniRead, s_yy, settings.ini,sub,from_bottom,100
IniRead, s_sub_second, settings.ini,sub,sub_second,965
IniRead, s_opacity, settings.ini,sub,opacity,190
IniRead, s_font, settings.ini,sub,font,Verdana
opacity_factor:=s_opacity/11
IniRead, s_valign, settings.ini,sub,valign,bottom
IniRead, s_outline, settings.ini,sub,ouline,3
s_outlinex2:=s_outline*2
IniRead, s_fading, settings.ini,sub,fading,1

;IniRead, s_transparency, settings.ini,sub,box_transparency,0

Gosub create_gui

subtitle("Pausing for you to find play button",4000)
subtitle("In 5",1000)
subtitle("In 4",1000)
subtitle("In 3",1000)
subtitle("In 2",1000)
subtitle("In 1",1000)
subtitle("Push 'Play' Now!",1000)

start:=A_TickCount
wait_till:=start
breaked_down:=0

Loop %1%, 1
	fn = %A_LoopFileLongPath%

f_srt:=RegExMatch(fn,"i)[.]srt$")
f_sub:=RegExMatch(fn,"i)[.]sub$")

break_out:=0

Loop, read, %fn%
{
	if (f_sub>0)	
	{
		if (A_Index = 1)
		{
			; get frame time
			RegExMatch(A_LoopReadLine, "[}]([^}]+)$",ar)
			ftime:=1/Round(ar1)*s_sub_second
		}
		if (A_Index > 1)
		{
			now:=A_TickCount
			RegExMatch(A_LoopReadLine, "{(.*?)}{(.*?)}([^�]+)$",ar)
			ta:=ar1*ftime
			tb:=ar2*ftime
			l:=tb-ta
			sub:=RegExReplace(ar3,"[|]","`n")
			wait_till:=ta+start
			wait_interruptable(wait_till)
			subtitle(sub,l)
		}
	}
	
	if (f_srt>0)
	{
		f := RegExMatch(A_LoopReadLine, "^\d+$")
		if (f>0)
		{
			nexti:=0
			sub := RegExReplace(sub, "^`n", "")
			sub := RegExReplace(sub, "`n$", "")
			subtitle(sub,l)
			continue
		}
		
		if (nexti = 2)
		{
			sub:=sub "`n" A_LoopReadLine
		}
		; matching : 00:01:06,367 --> 00:01:08,801
		f := RegExMatch(A_LoopReadLine, "^(\d\d):(\d\d):(\d\d),(\d\d\d) --[>] (\d\d):(\d\d):(\d\d),(\d\d\d)$",ar)
		if (f>0)
		{
			now:=A_TickCount
			ta:= Round(ar1)*3600000 + Round(ar2)*60000 + Round(ar3)*1000 + Round(ar4)
			tb:= Round(ar5)*3600000 + Round(ar6)*60000 + Round(ar7)*1000 + Round(ar8)
			l:=tb-ta
			nexti:=2
			wait_till:=start+ta
			wait_interruptable(wait_till)
			sub:=""
		}
	}
}

; Show last subtitle also..
if (f_srt>0)
{
	sub := RegExReplace(sub, "^`n", "")
	sub := RegExReplace(sub, "`n$", "")
	subtitle(sub,l)
}

subtitle("*** End of subtitles ***",2000)
Gui, Destroy
ExitApp

wait_interruptable(wait_till)
{
	global start,breaked_down
	while now<wait_till
	{
		Sleep 10
		now:=A_TickCount
		GetKeyState, z_key,z,P
		if (z_key="D")
		{			
			; Jump forward in time, so to speak
			start:=start-(wait_till-now)
			return 1
		}
		else
		{
			breaked_down:=0
		}
	}
	return 0
}

subtitle(sub,millisecs)
{
	global s_width,s_height,s_fontsize,s_yy,s_xx,opacity_factor,s_opacity,breaked_down,s_valign,last_sub,s_transparency,s_fading

	last_sub:=sub
	h:=s_fontsize*0.65
	Loop, parse, sub, `n
	{
		h:=h + s_fontsize+s_fontsize*0.65
	}
	;h:=h+s_fontsize*0.8
	Loop,6
	{
		GuiControl,, St%a_Index%, %sub%
	}
	
	if (s_valign="top")
		y:=s_height-s_yy
	else
		y:=s_height-h-s_yy
	

	;Progress,W%s_width% X%s_xx% Y%y% B H%h% ZH0 ZW0 FS%s_fontsize% CTffffff CW000000
	GetKeyState, z_key,z,P
	if (z_key = "D" and breaked_down>1)
	{
		millisecs:=100
	}
	if (millisecs>500 and s_fading)
	{
		;WinSet,Transparent,0, %A_ScriptName%
		WinSet, TransColor, 111111 0, %A_ScriptName%
		Gui 1: Show,Y%y% H%h% XCenter NA
		;Gui, Show,xp%s_xx%

		Loop 5{
			tp:=A_Index*opacity_factor
			;WinSet,Transparent,%tp%, %A_ScriptName%
			WinSet, TransColor, 111111 %tp%, %A_ScriptName%
			Sleep 25
		}
		;WinSet,Transparent,%s_opacity%, %A_ScriptName%
		WinSet, TransColor, 111111 %s_opacity%, %A_ScriptName%
		now:=A_TickCount
		millisecs:=millisecs-250
		wait_till:=now+millisecs
		sleep_broken:=wait_interruptable(wait_till)
		Loop 5{
			tp:=(6-A_Index)*opacity_factor
			;WinSet,Transparent,%tp%, %A_ScriptName%
			WinSet, TransColor, 111111 %tp%, %A_ScriptName%
			Sleep 25
		}
		if (sleep_broken)
		{
			breaked_down++
		}
		else
		{
			breaked_down:=0
		}
	}
	else
	{
		WinSet, TransColor, 111111 %s_opacity%
		;Gui, Show,Y%y%,NA
		Gui 1: Show,Y%y% H%h% XCenter NA
		Sleep %millisecs%
		GetKeyState, z_key,z,P
		if (z_key <> "D")
			breaked_down:=0
	}
	Gui, Hide
	;Gui, Destroy
	;Destroy
}

show_info(){
	global s_width,s_height,s_fontsize,s_yy,s_xx,s_sub_second,start
	Traytip,,fs=%s_fontsize% yy=%s_yy% sub=%s_sub_second% start=%start%
}

do_nothing:
Return

create_gui:
	Gui 1: +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui 1:Margin,0,0
	Gui 1: Color, 111111
	Gui 1: Font, s%s_fontsize% q2, %s_font%
	sub:="fooo`nbbaar"
	Gui 1: Add, Text, BackgroundTrans x%s_outlinex2% y%s_outlinex2% cFFFFFF vSt1 Center W%s_width%, %sub%
	Gui 1: Add, Text, BackgroundTrans xp+%s_outline% yp-%s_outline% vSt2 Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans xp-%s_outlinex2% yp+0 vSt3 Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans xp+0 yp+%s_outlinex2% vSt4 Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans xp+%s_outlinex2% yp+0 vSt5 Center W%s_width% c000000, %sub%
	;Gui 1: Add, Text, BackgroundTrans xp+2 yp+1 vSt7 Center W%s_width% c000000, %sub%
	Gui 1: Add, Text, BackgroundTrans x%s_outlinex2% y%s_outlinex2% cFFFFFF vSt6 Center W%s_width%, %sub%
Return

change_alignment:
if (s_valign="top")
{
	s_valign:="bottom"
	s_yy:=s_yy-(s_fontsize*3.7)
	subtitle("Alignment bottom",200)
}
else
{
	s_valign:="top"
	s_yy:=s_yy+(s_fontsize*3.7)
	subtitle("Alignment top",200)
}
return

toggle_fade:
s_fading:=Mod(s_fading+1,2)
;subtitle(last_sub,200)
Return

toggle_pause:
if (pause_start>0)
{
	pause_len:=A_tickcount-pause_start
	start:=start+pause_len
	pause_start:=0
	Pause, Off,1
	return
}
pause_start:=A_tickcount
Pause, On,1
return

tup:
s_yy:=s_yy+10
subtitle("* * * * * * * / \ * * * * * * *`n* * * * * * *  ||  * * * * * * *",50)
show_info()
return

tdown:
s_yy:=s_yy-10
subtitle("* * * * * * *  ||  * * * * * * *`n* * * * * * * \ / * * * * * * *",50)
show_info()
return

oup:
s_opacity+=10
if (s_opacity>=255)
	s_opacity:=255
opacity_factor:=s_opacity/11
subtitle(last_sub,150)
Return

odown:
s_opacity-=10
if (s_opacity<=0)
	s_opacity:=0
opacity_factor:=s_opacity/11
subtitle(last_sub,150)
Return

fontplus:
s_fontsize:=s_fontsize+1
Gui,Destroy
Gosub create_gui
subtitle("Bigger font-size",50)
show_info()
return

fontminus:
s_fontsize:=s_fontsize-1
Gui,Destroy
Gosub create_gui
subtitle("Smaller font-size",50)
show_info()
return

ssplus:
s_sub_second:=s_sub_second+2
show_info()
Sleep -1
return

ssminus:
s_sub_second:=s_sub_second-2
show_info()
Sleep -1
return

syncplus:
start:=start+250
show_info()
Sleep -1
return

syncminus:
start:=start-250
show_info()
Sleep -1
return

goex:
ExitApp
return