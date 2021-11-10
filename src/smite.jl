# Tools for working with smite SMD structures

mutable struct SMITEsmd 
    filepath::String
    filename::String
    varname::String
end

function SMITEsmd(filepath::String,filename::String)
    return SMITEsmd(filepath,filename,"SMD")
end

function SMLD2D(smd::SMITEsmd)

    # load matlab file 
    p = joinpath(smd.filepath,smd.filename)
    file = matopen(p)
    s=read(file,smd.varname) # note that this does NOT introduce a variable ``varname`` into scope
    close(file)
    n=size(s["FrameNum"],1)

    smld = SMLD2D(n)
    display(s)
    display(Int.(s["ConnectID"]))
    smld.connectID=Int.(s["ConnectID"])[:]
    smld.x=s["X"][:]
    smld.y=s["Y"][:]
    smld.σ_x=s["X_SE"][:]
    smld.σ_y=s["Y_SE"][:]
    smld.photons=s["Photons"][:]
    smld.σ_photons=s["Photons_SE"][:]
    smld.bg=s["Bg"][:]
    smld.σ_bg=s["Bg_SE"][:]
    smld.framenum=Int.(s["FrameNum"])[:]
    smld.datasetnum=Int.(s["DatasetNum"])[:]
    #smld.datasize=s[]
    smld.nframes=Int(s["NFrames"])
    smld.ndatasets=Int(s["NDatasets"])
    #smld.datafields=s[]
    return smld
end


