using Revise
using SMLMData
using PlotlyJS

filepath="Y:\\Projects\\BaGoL\\21_11_02_DNAPAINT_EGFR\\activated_EGF\\Results\\Cell_05\\Label_01\\Data_2021-11-4-6-11-39"
filename="Data_2021-11-4-6-11-39_Results.mat"
smd=SMLMData.SMITEsmd(filepath,filename)

smld=SMLMData.SMLD2D(smd)

plot(scattergl(x=smld.x, y=smld.y, mode="markers",markersize = .1, linewidth=.1))


