
# examples

import nmiline

# = nlSize =
nlSize(700,500)
# window size (x,y :int) {defalt : (700,500)}


# = nlConfig =
nlConfig(title="Graph",border=true,xText="X-text",yText="Y-Text")
# title : title of your graph (string)
# border: true->display border lines in your graph , false->remove border lines {defalt : true}
nlConfig(bgColor=(255,255,255),bgAlpha=200,textColor=(0,0,0),bdColor=(200,200,200))
# bgColor   : background color
# bgAlpha   : Transparency of background
# textColor : text and title color
# bdColor   : border lines color


# = nlTheme =
# nlTheme(Defalt)
# {If you are troublesome that set colors of your graph,you can set theme color of graph.}
# Defalt : Defalt color [omitable] (bgColor=(255,255,255),textColor=(0,0,0),bdColor=(200,200,200))
# Dark   : Dark color (bgColor=(10,10,10),textColor=(250,250,250),bdColor=(60,60,60))
# Cream  : Creamy color (bgColor=(255,245,190),textColor=(70,62,0),bdColor=(220,200,150))
# Sky    : Color like the sky (bgColor=(180,235,255),textColor=(0,20,50),bdColor=(250,250,250))


# = nlRange =
nlRange(3.0,6.0,-1.0,8.0)
# Scope of the graph (minX,maxX,minY,maxY :float)
# If you omit it,scope is determined automatically.


# = nlSet =
nlSet(x=[2.0,3.0,4.0,5.0,6.0,7.0],y=[0.1,1.2,3.1,4.7,5.5,6.0],color=(255,0,0),form=Normal,point="●")
# {Set datas.}
# x and y must be same type and length.
# color : Line's(or points') color
# form  : A form {defalt : Normal}
#         Normal : Line graph (No points)
#         Line   : Line graph
#         Scatter: Scatter plot
# point : Points' shape (string)
# name  : Data's name


# = nlShow =
nlShow()
# Display your graph.
