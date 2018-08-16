
# -=======================-
# ---- Nmiline v 1.1.0 ----
# -=======================-

# - Useful graph tool using NiGui.

# - Needs NiGui [GUI toolkit] (You can get it in nimble.)

# - URL : https://github.com/mzteruru52/NmiLine

# - URL [NiGui] : https://github.com/trustable-code/NiGui

# - FROSS(free and open-source software) [Licenced under the MIT licence. Please check "LICENCE" file]

# - Thank you for using ! ありがとう .:' \('v')/ ':.

# ---

import nigui,math

type
  Form* =enum
    Normal
    Line
    Scatter
  Theme* =enum
    Defalt
    Dark
    Cream
    Sky

var Wwh=[700,500]
# Wwh : Window's width and height (700:500)
var Dt:seq[array[2,seq[float]]]= @[]
# Dt : Base datas
var Cl:seq[Color]= @[rgb(200,200,200)]
# Cl : Color of lines
var Ty:seq[Form]= @[]
# Ty : Form of lines
var Dy:seq[array[2,string]]= @[]
# Dy : Other options of lines
var Mai:array[4,float]
# Mai : [The biggest number of X , The smallest number of X , ~biggest~ of Y , ~smallest~ of Y]
var Ra:bool=true
# Ra : true - Range of graph is divided automatically
var Bd:bool=true
# Bd : true - Border lines are visible
var bdg:tuple=(255,255,255)
# bdg : Background color
var bdc:tuple=(200,200,200)
# bdc : Color of border lines
var txtCol:tuple=(0,0,0)
# txtCol : Color of text
var bgAlp:int=200
# bgAlp : Transparency of outside area
var Tit=""
# Tit : title
var Toi=false
# Toi : true - numbers are converted in integer
var Txy:array[2,string]=["x","y"]
# Txy : [Xtext,Ytext]

# Config
proc nlConfig*(border:bool=Bd;bgColor:tuple=bdg;textColor:tuple=txtCol;bdColor:tuple=bdc,xText:string=Txy[0],yText:string=Txy[1],bgAlpha:int=bgAlp,title:string=Tit,toInt:bool=Toi)=
  bdg=bgColor
  bdc=bdColor
  txtCol=textColor
  Txy=[xText,yText]
  Bd=border
  bgAlp=bgAlpha
  Tit=title
  Toi=toInt

# Size of window
proc nlSize*(w,h:int)=
  Wwh = [w,h]

# Color Theme
proc nlTheme*(tm:Theme)=
  case tm:
    of Defalt:
      nlConfig(bgColor=(255,255,255),textColor=(0,0,0),bdColor=(200,200,200))
    of Dark:
      nlConfig(bgColor=(10,10,10),textColor=(250,250,250),bdColor=(60,60,60))
    of Cream:
      nlConfig(bgColor=(255,245,190),textColor=(70,62,0),bdColor=(220,200,150))
    of Sky:
      nlConfig(bgColor=(180,235,255),textColor=(0,20,50),bdColor=(250,250,250))

# Range of graph
proc nlRange*(xi,xa,yi,ya:float)=
  Ra = false
  Mai = [xi,xa,yi,ya]

# Return range of graph
proc nlGetRange*():seq=
  return @Mai

# Set data
proc nlSet*(x,y:array or seq; color:tuple=(50,50,50) ;form:Form=Normal ;point:string ="●" ;name:string="Graph "& $Dt.len)=
  if x.len!=y.len:
    echo "<<NmiLine Error>> : These datas' length were not same.\n  ->",x,"\n  ->",y,"\n"
  else:
    Dt.add([newSeq[float](x.len),newSeq[float](x.len)])
    Cl.add(rgb(uint8(color[0]),uint8(color[1]),uint8(color[2])))
    Ty.add(form)
    Dy.add([name,point])

    for I in [0,1]:
      for i in countup(0,x.len-1):
        Dt[Dt.len-1][I][i]=float([x,y][I][i])
      if Ra:
        if Dt.len==1:
          Mai[I*2]=Dt[Dt.len-1][I].min
          Mai[I*2+1]=Dt[Dt.len-1][I].max
        else:
          Mai[I*2]=min(Dt[Dt.len-1][I].min,Mai[I*2])
          Mai[I*2+1]=max(Dt[Dt.len-1][I].max,Mai[I*2+1])

var Ds:array[2,seq[float]]
# Ds : Borders' position and value

var pf:array[2,float]
# pf : [the difference between Mai[0] and Mai[1] , ~ between Mai[2] and Mai[3]]

# Internal processing
proc Cal()=
  Ds=[@[Mai[0]],@[Mai[2]]]
  pf=[0.0,0.0]
  for i in [0,1]:
    pf[i]=abs(Mai[i*2+1]-Mai[i*2])
    if Bd:
      var g=0
      while true:
        let n=[pf[i]/float(10^g),pf[i]*float(10^g)][int(pf[i]<1)]
        if 1<=n and n<10:
          g*=int(pf[i]<1)*2-1
          break
        g+=1
      var nf=round[float](Mai[i*2],g)
      while nf<Mai[i*2+1]:
        if nf>Mai[i*2]:Ds[i].add(nf)
        nf += pow(10.0,float(-g))
    Ds[i].add(Mai[i*2+1])

proc nlShow*()=
  if Dt.len==0:
    echo "<<NmiLine Error>> : There are no data."
    return
  Cal()

  # init
  app.init()

  # Window
  let W=newWindow("Nmiline v1.1.0")
  W.width=Wwh[0]
  W.height=Wwh[1]+40
  let gwh=50

  # LayoutContainer
  let Con=newLayoutContainer(Layout_Vertical)
  Con.setPosition(0,0)
  Con.width=Wwh[0]
  Con.height=Wwh[1]
  Con.widthMode=WidthMode_Static
  Con.heightMode=HeightMode_Static
  W.add(Con)

  # Control[canvas]
  let Cv=newControl()
  Con.add(Cv)
  Cv.setPosition(0,0)
  Cv.width=Wwh[0]
  Cv.height=Wwh[1]
  Cv.widthMode=WidthMode_Fill
  Cv.heightMode=HeightMode_Fill

  # Under menu
  let Cu=newLayoutContainer(Layout_Horizontal)
  Con.add(Cu)
  Cu.width=Wwh[0]-30
  Cu.height=35
  Cu.widthMode=WidthMode_Static
  Cu.heightMode=HeightMode_Static

  let pud=proc(d:float,r:int):int=
    int((1-(d-Mai[r*2])/pf[r])*float(Wwh[r]-gwh*4))+gwh*(2-r)
  Cv.onDraw=proc(e:DrawEvent)=
    let Ca=e.control.canvas

    # Guide
    Ca.areaColor=rgb(uint8(bdg[0]),uint8(bdg[1]),uint8(bdg[2]))
    Ca.fill()
    Ca.fontSize=15
    Cl[0]=rgb(uint8(bdc[0]),uint8(bdc[1]),uint8(bdc[2]))
    for i in countup(0,Dt.len-1):
      let e=Dt[i]
      for k in countup(int(Ty[i]==Scatter),int(Ty[i]!=Normal)):
        for I in countup(0,e[0].len-2+k):
          if k==0:
            Ca.lineColor=Cl[i+1]
            Ca.drawLine(Wwh[0]-pud(e[0][I],0),pud(e[1][I],1),Wwh[0]-pud(e[0][I+1],0),pud(e[1][I+1],1))
          else:
            Ca.textColor=Cl[i+1]
            Ca.drawText(Dy[i][1],Wwh[0]-pud(e[0][I],0)-8,pud(e[1][I],1)-9)

    Ca.areaColor = rgb(uint8(bdg[0]),uint8(bdg[1]),uint8(bdg[2]),uint8(bgAlp))
    let txtColb:Color=rgb(uint8(txtCol[0]),uint8(txtCol[1]),uint8(txtCol[2]))
    Ca.textColor=txtColb

    # Outside area
    Ca.drawRectArea(0,0,gwh*2,W.height)
    Ca.drawRectArea(Wwh[0]-gwh*2,0,W.width,W.height)
    Ca.drawRectArea(gwh*2,0,Wwh[0]-gwh*2,gwh)
    Ca.drawRectArea(gwh*2,Wwh[1]-gwh*3,Wwh[0]-gwh*4,W.height)

    # Xtext,Ytext and Name
    Ca.lineColor=Cl[0]
    Ca.fontSize=25
    Ca.drawText(Tit,Wwh[0] div 3,10)
    Ca.fontSize=15
    Ca.drawText(Txy[0],Wwh[0] div 2-gwh,Wwh[1]-gwh*3)
    Ca.drawText(Txy[1],gwh div 2,gwh-20)

    # Borders
    for i in [0,1]:
      for I in countup(0,Ds[i].len-1):
        let n=pud(Ds[i][I],i)
        let q:bool=(Mai[i*2]+pf[i]/10<Ds[i][I] and Ds[i][I]<Mai[i*2+1]-pf[i]/10) or I mod (Ds[i].len-1)==0
        let ic=[$round[float](Ds[i][I],8),$int(round[float](Ds[i][I],0))][int(Toi)]
        if i==0:
          Ca.drawLine(Wwh[0]-n,gwh,Wwh[0]-n,Wwh[1]-gwh*3)
          if q:Ca.drawText(ic,Wwh[0]-n-5,Wwh[1]-gwh*3+15)
        else:
          Ca.drawLine(gwh*2,n,Wwh[0]-gwh*2,n)
          if q:Ca.drawText(ic,gwh-10,n-5)

    # Plot
    for i in countup(0,Dt.len-1):
      Ca.lineColor=Cl[i+1]
      Ca.textColor=Cl[i+1]
      if Ty[i]!=Scatter:Ca.drawLine(20+(i div 2)*250,Wwh[1]-100+(i mod 2)*30,120+(i div 2)*250,Wwh[1]-100+(i mod 2)*30)
      if Ty[i]!=Normal:
        for k in [-1,0,1]:Ca.drawText(Dy[i][1],62+(i div 2)*250+k*40,Wwh[1]-109+(i mod 2)*30)
      Ca.textColor=txtColb
      Ca.drawText(": "&Dy[i][0],72+(i div 2)*250+50,Wwh[1]-109+(i mod 2)*30)
  # ---

  let Bt=newButton("[B] Border : ON")
  Bt.width=100

  let Bt2=newButton("[T] Type : float")
  Bt2.width=100

  # ReDrawing
  proc Redr()=
    Cal()
    Cv.forceRedraw

  # Border
  proc Bdv()=
    nlConfig(border= not Bd)
    Bt.text="[B] Border : "&["OFF","ON"][int(Bd)]
    Redr()

  # Type
  proc Tfi()=
    nlConfig(toInt= not Toi)
    Bt2.text="[T] Type : "&["float","int"][int(Toi)]
    Redr()

  # Controler
  proc Ctrlr(cn:proc)=
    # Window
    let Wcon=newWindow("Controler")
    Wcon.width=350
    Wcon.height=200
    Wcon.onkeyDown=proc(e:KeyboardEvent)=
      cn($e.key)
    # Base LayoutContainer
    let Albc=newLayoutContainer(Layout_Vertical)
    Albc.width=350
    Albc.height=200
    Albc.widthMode=WidthMode_Static
    Albc.heightMode=HeightMode_Static
    Wcon.add(Albc)

    # Other LayoutContainers and Controls
    var Abc:seq[LayoutContainer]= @[]
    var Bbc:seq[Button]= @[]
    var Cbc:seq[Control]= @[]
    for i in countup(0,6):
      if i<4:
        Abc.add(newLayoutContainer(Layout_Horizontal))
        Albc.add(Abc[i])
        if i mod 2==0:
          Cbc.add(newLabel())
          Cbc[Cbc.len-1].width=50
          Abc[i].add(Cbc[Cbc.len-1])
      Bbc.add(newbutton(["[W] Up","[A] Left","[D] Right","[S] Down","[Z] ZoomIn","[X] ZoomOut","[Space] Quit"][i]))
      Bbc[i].width=100
      Abc[i-int(i>1)-int(i>4)*(i-4)].add(Bbc[i])

    proc Ctc(n:int)=
      cn("Key_"& $["W","A","D","S","Z","X","Space"][n])

    # Input
    Bbc[0].onClick=proc(e:ClickEvent)=Ctc(0)
    Bbc[1].onClick=proc(e:ClickEvent)=Ctc(1)
    Bbc[2].onClick=proc(e:ClickEvent)=Ctc(2)
    Bbc[3].onClick=proc(e:ClickEvent)=Ctc(3)
    Bbc[4].onClick=proc(e:ClickEvent)=Ctc(4)
    Bbc[5].onClick=proc(e:ClickEvent)=Ctc(5)
    Bbc[6].onClick=proc(e:ClickEvent)=Ctc(6)

    Wcon.show()

  # Output
  proc Cont(e:string)=
    var Pm=[0.0,0.0,0.0,0.0]
    case e:
      of "Key_D":
        Pm[0] += pf[0]
        Pm[1] += pf[0]
      of "Key_A":
        Pm[0] -= pf[0]
        Pm[1] -= pf[0]
      of "Key_W":
        Pm[2] += pf[1]
        Pm[3] += pf[1]
      of "Key_S":
        Pm[2] -= pf[1]
        Pm[3] -= pf[1]
      of "Key_Z":
        Pm[0] += pf[0]
        Pm[1] -= pf[0]
        Pm[2] += pf[1]
        Pm[3] -= pf[1]
      of "Key_X":
        Pm[0] -= pf[0]
        Pm[1] += pf[0]
        Pm[2] -= pf[1]
        Pm[3] += pf[1]
      of "Key_B":
        Bdv()
        Redr()
        return
      of "Key_T":
        Tfi()
        Redr()
        return
      of "Key_C":
        Ctrlr(Cont)
        return
      of "Key_Space":
        app.quit()
    nlRange(Mai[0]+Pm[0]/16,Mai[1]+Pm[1]/16,Mai[2]+Pm[2]/16,Mai[3]+Pm[3]/16)
    Redr()

  # Key Input
  W.onkeyDown=proc(e:KeyboardEvent)=
    Cont($e.key)

  # Border button
  Cu.add(Bt)
  Bt.onClick=proc(e:ClickEvent)=
    Bdv()

  # Type button
  Cu.add(Bt2)
  Bt2.onClick=proc(e:ClickEvent)=
    Tfi()

  # Controler button
  let Btc=newButton("[C] Controler")
  Cu.add(Btc)
  Btc.onClick=proc(e:ClickEvent)=
    Ctrlr(Cont)

  # Quit Button
  let Bt3=newButton("[Space] Quit")
  Bt3.width=100
  Bt3.onClick=proc(e:ClickEvent)=app.quit()
  Cu.add(Bt3)

  # Finish! Σd(0v<..)
  W.show()
  app.run()
