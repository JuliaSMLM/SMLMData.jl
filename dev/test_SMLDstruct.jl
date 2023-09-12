using Revise
using SMLMData
SD = SMLMData



x=[1, 2, 3]

s = SD.SMLD2D(3)
s = SD.SMLD2D(3,bg=[1,2,3])
s = SD.SMLD2D(3, x=x)
s = SD.SMLD2D(3, y=[1,2])