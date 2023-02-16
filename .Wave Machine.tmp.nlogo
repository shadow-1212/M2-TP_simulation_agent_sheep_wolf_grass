globals[rain sheep-need wolf-need]
;agent specification
breed [sheeps sheep]
breed [wolves wolf]
; agent attributes
turtles-own [energy]
patches-own [biomass]

;initialize simulation
to setup
  clear-all
  ;initialize patch
  ask patches [init-patch]
  reset-ticks
  ;initialize sheeps
  set-default-shape sheeps "sheep 2"; set default shape for sheeps
  create-sheeps nb-sheeps [init-sheep]
  set max-sheep-energy 10
  ;initialize wolves
  set-default-shape wolves "wolf 7"; set default shape for wolves
  create-wolves nb-wolves [init-wolf]
  set max-wolf-energy 20
end

to init-patch
  set biomass random max-biomass
  set pcolor compute-green biomass max-biomass
end

to-report compute-green [min-value max-value]
  report scale-color green min-value max-value 0
end


to go
  do-rain
  ask sheeps [sheep-move] ; ask sheeps to move
  ask sheeps [sheep-eat] ; ask sheeps to eat
  ask wolves [wolf-move] ; ask wolves to move
  ask wolves [wolf-eat] ; ask wolves to eat
  tick
end

to do-rain
  ifelse rain?[set rain random-float 0.1 ask patches [grow-patch]] [set rain 0.05]
end

to grow-patch
  if biomass < max-biomass [set biomass biomass + rain
   set pcolor compute-green biomass max-biomass
  ]
end

;for sheep
;sheep initialization
to init-sheep
  setxy random-xcor random-ycor
  set size 4
  set energy random max-sheep-energy
  set color white
  set label-color black
  set sheep-need 5
end

; sheep dynamics
; function to move each sheep
to sheep-move
  uphill biomass
  set energy energy - 1
  if energy <= 0 [die]
  report-energy
end

; function to ask sheep to eat
to sheep-eat
  if energy < max-sheep-energy [
    let need sheep-need
    ask patch-here[
      ifelse biomass >= need [
        set biomass biomass - need
      ]
      [
        set need biomass
        set biomass 0
      ]
    ]
    set energy energy + need
  ]
end

;return the actual value of sheep energy
to report-energy
  ifelse sheep-health? [set label floor energy] [set label ""]
  ask sheeps [
  ifelse energy > 8 [
    set color white
  ]
  [ ifelse energy > 3 [
      set color yellow
    ]
    [
      set color red
    ]
  ]
]
end

;for wolf
;wolf initilization
to init-wolf
  setxy random-xcor random-ycor
  set size 4
  set energy random max-wolf-energy
  set color gray
  set label-color white
  set wolf-need 10
end

; wolf dynamics
; function to move each wolf
to wolf-move
  ; get all sheeps inside the circle of vision of the wolf
  let candidates sheeps in-radius wolf-vision

  ;move the wolf to the closest sheep if he get more hungry
  ifelse energy < max-wolf-energy and any? candidates
  [move-to min-one-of candidates [energy] ]
  [left random 360 fd random wolf-vision]
  ; lose energy
  set energy energy  - 1
  if energy <= 0 [die]
end

; function to ask wolf to eat
to wolf-eat
  ; verify if the wolf is hungry and if there is a sheep nearby
  if energy < max-wolf-energy / 2 and any? sheeps-here[
    ; get the sheep with the minimum of energy
    let nearby-sheep min-one-of sheeps-here[energy]
    ; get the amount of energy
    let amount [energy] of nearby-sheep
    ; kill the sheep
    ask nearby-sheep [die]
    ; add the sheep energy to the wolf
    set energy energy + amount
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
789
16
1283
511
-1
-1
6.0
1
10
1
1
1
0
0
0
1
-40
40
-40
40
1
1
1
ticks
30.0

BUTTON
263
35
341
68
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
365
36
442
69
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
14
92
135
112
Biomass settings
11
0.0
0

TEXTBOX
16
157
106
175
Rain settings
11
0.0
0

TEXTBOX
22
324
143
342
Display settings
11
0.0
0

SLIDER
19
110
189
143
max-biomass
max-biomass
0
50
18.0
1
1
kg
HORIZONTAL

SWITCH
29
183
132
216
rain?
rain?
1
1
-1000

PLOT
23
353
223
503
patch histogram
biomass
nb patch
0.0
50.0
0.0
300.0
true
false
"" ""
PENS
"default" 1.0 1 -1184463 true "" "histogram[biomass] of patches"

INPUTBOX
17
244
147
304
max-sheep-energy
10.0
1
0
Number

SLIDER
154
245
326
278
nb-sheeps
nb-sheeps
0
100
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
18
224
168
242
Sheep settings
12
0.0
1

SWITCH
155
281
295
314
sheep-health?
sheep-health?
0
1
-1000

INPUTBOX
363
248
524
308
max-wolf-energy
20.0
1
0
Number

TEXTBOX
364
220
514
238
Wolf settings
12
0.0
1

SLIDER
531
249
703
282
nb-wolves
nb-wolves
0
100
9.0
1
1
NIL
HORIZONTAL

SWITCH
532
286
674
319
wolf-health?
wolf-health?
1
1
-1000

SLIDER
352
312
524
345
wolf-vision
wolf-vision
0
100
10.0
1
1
NIL
HORIZONTAL

BUTTON
469
35
566
68
One steo
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
262
357
397
402
Number of sheeps
count sheeps
17
1
11

MONITOR
263
405
395
450
Number of wolves
count wolves
17
1
11

PLOT
217
82
689
232
Population
number
ticks
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot count sheeps"
"pen-1" 1.0 0 -7500403 true "" "plot count wolves"

@#$#@#$#@
## WHAT IS IT?

This model simulates wave motion in a membrane. The four edges of the membrane are fixed to a frame. A green rectangular area represents a driver plate that moves up and down, exhibiting sinusoidal motion.

## HOW IT WORKS

The membrane is made up of lines of turtles. Each turtle acts as it were connected to its four neighboring turtles by springs. In this model, turtles move only up and down -- the force's direction IS only up and down. The greater the distance between a turtle and its neighbors, the stronger the force.

When the green turtles move up, they "pull up" the turtles which are their neighbors, which in turn pull up the turtles which are their neighbors, and so on. In that way, a wave moves along the membrane. When the wave reaches the edges of the membrane (the blue turtles), the wave is reflected back to the center of the membrane.

The amplitude of the green turtles is fixed regardless of the stiffness of the membrane. However, moving a stiff membrane requires a lot more force to move it the same amount as an unstiff membrane. So even as the stiffness of the membrane is increased, the wave height will remain the same because the amplitude is kept the same.

## HOW TO USE IT

Controls of membrane properties:

The FRICTION slider controls the amount of friction or attenuation in the membrane. The STIFFNESS slider controls the force exerted on a turtle by a unit deflection difference between the turtle and its four neighbors.

Controls of the driving force:

The DRIVER-FREQUENCY slider controls the frequency at which the green area of the membrane (the driving force) moves up and down. The DRIVER-AMPLITUDE slider controls the maximum height of the green area of the membrane.

The DRIVER-X and DRIVER-Y sliders control the position of the driver. The DRIVER-SIZE slider controls the size of the driver.

Controls for viewing:

The THREE-D? switch controls the view point of the projection.  OFF is for the top view (2-D looking down), and ON gives an isometric view, at an angle chosen with the VIEW-ANGLE slider.

## THINGS TO TRY

Click the SETUP button to set up the membrane. Click GO to make the selected area of the membrane (the green turtles) begin moving up and down.

Try different membranes. Soft membranes have smaller stiffness values and hard membranes have larger stiffness values.

Try different driving forces, or try changing the frequency or amplitude. It is very interesting to change the size and the position of the driving force to see symmetrical and asymmetrical wave motions.

Try to create a "standing wave," in which some points in the membrane do not move at all.

## EXTENDING THE MODEL

In this model, the movement of the turtles is only in the vertical direction, perpendicular to the membrane. Modify the model such that the movement is within the membrane plane, i.e. the x/y plane.

You can also try to add additional driving forces to make a multi-input membrane model. Another thing you can try is to apply different waveforms to the driving-force to see how the membrane reacts to different inputs. Try changing the overall shape of the driving force.

Try to build a solid model, that is, a model of waveforms within all three dimensions.

Instead of using amplitude to create the wave, change it to apply a fixed amount of force continuously.

## NETLOGO FEATURES

Note the use of the `turtles-on` reporter to find turtles on neighboring patches.

A key step in developing this model was to create an internal coordinate system. X, Y, and Z are just three turtles-own variables. You can imagine that turtles are situated in and move around in 3-space.  But to display the turtles in the view, which is two-dimensional, the turtle's three coordinates must be mapped into two.

In the 2-D view, the turtle's x and y coordinates are translated directly to NetLogo coordinates, and the z coordinate is indicated only by varying the color of the turtle using the `scale-color` primitive.

In the 3-D view, an isometric projection is used to translate x, y, and z (the turtle's real position) to xcor and ycor (its position in the view).  In this projection, a  point in the world may correspond to more than one point in the 3-dimensional coordinate system.  Thus in this projection we still vary the color of the turtle according to its z position, to help the eye discriminate.

In the 3-D version, it does not make sense for the turtles to "wrap" if they reach the top or bottom of the world nor does it make sense for them to remain at the top of the world, so turtles are hidden if their computed ycor exceeds the boundaries of the world.

## CREDITS AND REFERENCES

Thanks to Weiguo Yang for his help with this model.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Wave Machine model.  http://ccl.northwestern.edu/netlogo/models/WaveMachine.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1997 2001 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep 2
false
0
Polygon -7500403 true true 209 183 194 198 179 198 164 183 164 174 149 183 89 183 74 168 59 198 44 198 29 185 43 151 28 121 44 91 59 80 89 80 164 95 194 80 254 65 269 80 284 125 269 140 239 125 224 153 209 168
Rectangle -7500403 true true 180 195 195 225
Rectangle -7500403 true true 45 195 60 225
Rectangle -16777216 true false 180 225 195 240
Rectangle -16777216 true false 45 225 60 240
Polygon -7500403 true true 245 60 250 72 240 78 225 63 230 51
Polygon -7500403 true true 25 72 40 80 42 98 22 91
Line -16777216 false 270 137 251 122
Line -16777216 false 266 90 254 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf 7
false
0
Circle -16777216 true false 183 138 24
Circle -16777216 true false 93 138 24
Polygon -7500403 true true 30 105 30 150 90 195 120 270 120 300 180 300 180 270 210 195 270 150 270 105 210 75 90 75
Polygon -7500403 true true 255 105 285 60 255 0 210 45 195 75
Polygon -7500403 true true 45 105 15 60 45 0 90 45 105 75
Circle -16777216 true false 90 135 30
Circle -16777216 true false 180 135 30
Polygon -16777216 true false 120 300 150 255 180 300

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
