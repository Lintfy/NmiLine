import nigui,sequtils,math,strutils
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
var Dt:seq[array[2,seq[float]]]= @[]
var Cl:seq[Color]= @[rgb(200,200,200)]
var Ty:seq[Form]= @[]
var Dy:seq[array[2,string]]= @[]
var Mai:array[4,float]
var Ra:bool=true
var Bd:bool=true
var bdg:tuple=(255,255,255)
var bdc:tuple=(200,200,200)
var txtCol:tuple=(0,0,0)
var bgAlp:int=200
var Tit=""
var Txy:array[2,string]=["x","y"]

proc nlConfig*(border:bool=true;bgColor:tuple=bdg;textColor:tuple=txtCol;bdColor:tuple=bdc,xText:string=Txy[0],yText:string=Txy[1],bgAlpha:int=bgAlp,title:string=Tit)=
  bdg=bgColor
  bdc=bdColor
  txtCol=textColor
  Txy=[xText,yText]
  Bd=border
  bgAlp=bgAlpha
  Tit=title

proc nlSize*(w,h:int)=
  Wwh = [w,h]

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
proc nlRange*(xi,xa,yi,ya:float)=
  Ra = false
  Mai = [xi,xa,yi,ya]

proc nlSet*(x,y:array or seq; color:tuple=(50,50,50) ;form:Form=Normal ;point:string ="●" ;title:string="Graph "& $Dt.len)=
  if x.len!=y.len:
    echo "<<NmiLines Error>> : These datas' length were not same.\n  ->",x,"\n  ->",y,"\n"
  else:
    Dt.add([newSeq[float](x.len),newSeq[float](x.len)])
    Cl.add(rgb(uint8(color[0]),uint8(color[1]),uint8(color[2])))
    Ty.add(form)
    Dy.add([title,point])

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

proc nlShow*()=
  if Dt.len==0:
    echo "<<NmiLines Error>> : Data was not set."
    return
  var Ds:array[2,seq[float]]=[@[Mai[0]],@[Mai[2]]]
  var pf:array[2,float]=[0.0,0.0]
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

  app.init()

  let W=newWindow("Nmiline v1.0")
  W.width=Wwh[0]
  W.height=Wwh[1]
  let gwh=50
  let Con=newLayoutContainer(Layout_Vertical)
  Con.setPosition(0,0)
  Con.width=Wwh[0]
  Con.height=Wwh[1]-30
  Con.widthMode=WidthMode_Static
  Con.heightMode=HeightMode_Static
  W.add(Con)

  let Cv=newControl()
  Con.add(Cv)
  Cv.width=Wwh[0]
  Cv.height=Wwh[1]
  Cv.widthMode=WidthMode_Fill
  Cv.heightMode=HeightMode_Fill

  let pud=proc(d:float,r:int):int=
    int((1-(d-Mai[r*2])/pf[r])*float(Wwh[r]-gwh*4))+gwh*(2-r)
  Cv.onDraw=proc(e:DrawEvent)=
    let Ca=e.control.canvas

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

    Ca.drawRectArea(0,0,gwh*2,W.height)
    Ca.drawRectArea(Wwh[0]-gwh*2,0,W.width,W.height)
    Ca.drawRectArea(gwh*2,0,Wwh[0]-gwh*2,gwh)
    Ca.drawRectArea(gwh*2,Wwh[1]-gwh*3,Wwh[0]-gwh*4,W.height)

    Ca.lineColor=Cl[0]
    Ca.fontSize=25
    Ca.drawText(Tit,Wwh[0] div 3,10)
    Ca.fontSize=15
    Ca.drawText(Txy[0],Wwh[0] div 2-gwh,Wwh[1]-gwh*3)
    Ca.drawText(Txy[1],gwh div 2,gwh-20)

    for i in [0,1]:
      for I in countup(0,Ds[i].len-1):
        let n=pud(Ds[i][I],i)
        let q:bool=(Mai[i*2]+pf[i]/10<Ds[i][I] and Ds[i][I]<Mai[i*2+1]-pf[i]/10) or I mod (Ds[i].len-1)==0
        if i==0:
          Ca.drawLine(Wwh[0]-n,gwh,Wwh[0]-n,Wwh[1]-gwh*3)
          if q:Ca.drawText($round[float](Ds[i][I],len($pf[1])),Wwh[0]-n-5,Wwh[1]-gwh*3+15)
        else:
          Ca.drawLine(gwh*2,n,Wwh[0]-gwh*2,n)
          if q:Ca.drawText($round[float](Ds[i][I],len($pf[0])),gwh-10,n-5)

    for i in countup(0,Dt.len-1):
      Ca.lineColor=Cl[i+1]
      Ca.textColor=Cl[i+1]
      if Ty[i]!=Scatter:Ca.drawLine(20+(i div 2)*250,Wwh[1]-100+(i mod 2)*30,120+(i div 2)*250,Wwh[1]-100+(i mod 2)*30)
      if Ty[i]!=Normal:
        for k in [-1,0,1]:Ca.drawText(Dy[i][1],62+(i div 2)*250+k*40,Wwh[1]-109+(i mod 2)*30)
      Ca.textColor=txtColb
      Ca.drawText(": "&Dy[i][0],72+(i div 2)*250+50,Wwh[1]-109+(i mod 2)*30)



  W.show()
  app.run()
