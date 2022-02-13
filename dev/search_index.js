var documenterSearchIndex = {"docs":
[{"location":"Library/#Library","page":"Library","title":"Library","text":"","category":"section"},{"location":"Library/","page":"Library","title":"Library","text":"","category":"page"},{"location":"Library/","page":"Library","title":"Library","text":"Modules = [SMLMData]","category":"page"},{"location":"Library/#SMLMData.SMLD","page":"Library","title":"SMLMData.SMLD","text":"SMLD\n\nSMLD is the highest level abstract type in SMLMData.    \n\n\n\n\n\n","category":"type"},{"location":"Library/#SMLMData.SMLD2D","page":"Library","title":"SMLMData.SMLD2D","text":"SMLD2D\n\nStructure containing 2D localization data\n\n# Fields\n- connectID: integer ID associating localizations\n- x: x position \n- y: y position\n- σ_x: standard error uncertainty in x\n- σ_y: standard error uncertainty in y\n- photons: total photons \n- σ_photons: standard error uncertainty in σ_photons\n- bg: fit fluorescence background (photons/pixel)\n- σ_bg: standard error uncertainty in bg\n- framenum: integer framenumber within a dataset\n- datasetnum: integer dataset number\n- datasize::Vector{Int}: size of image area\n- nframes: integer frames per dataset\n- ndatasets: number of dataasets\n- datafields: bookeeping - do not modify\n\n\n\n\n\n","category":"type"},{"location":"Library/#SMLMData.SMLD2D-Tuple{DataFrames.DataFrame}","page":"Library","title":"SMLMData.SMLD2D","text":"SMLD2D(data::DataFrames.DataFrame)\n\nConstructor to generate an smld from a data frame.\n\nDescription\n\nThis is a constructor for the SMLD2D struct which allows you to populate the structure with data defined in the dataframe data. The intention is that a .csv table can be organized with localizations on each row as [datasetnum, framenum, x, y, σ_x, σ_y], loaded using the CSV package, and  placed into a dataframe with the DataFrames package.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.SMLD2D-Tuple{Int64}","page":"Library","title":"SMLMData.SMLD2D","text":"SMLD2D(nlocalizations::Int)\n\nConstructor to generate an empty smld with a specific size.\n\nDescription\n\nThis is a constructor for the SMLD2D struct which allows you to populate the structure with undefined values for a predefined number of localizations.\n\n\n\n\n\n","category":"method"},{"location":"Library/#Base.getindex-Tuple{SMLMData.SMLD2D, Any}","page":"Library","title":"Base.getindex","text":"Base.getindex(smld::SMLMData.SMLD2D, ind)\n\nReturns the requested localization from smld.\n\n\n\n\n\n","category":"method"},{"location":"Library/#Base.length-Tuple{SMLMData.SMLD2D}","page":"Library","title":"Base.length","text":"Base.length(smld::SMLMData.SMLD2D)\n\nReturns the number of localizations in smld.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.addoffset!-Tuple{SMLMData.SMLD2D, Vector{Float64}}","page":"Library","title":"SMLMData.addoffset!","text":"addoffset!(smld::SMLD2D, offset::Vector{Float64})\n\nAdd an offset elementwise to each localization smld.y and smld.x.\n\nInputs\n\n-offset: Two element vector describing the offset. ([offsety; offsetx])\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.addoffset-Tuple{SMLMData.SMLD2D, Vector{Float64}}","page":"Library","title":"SMLMData.addoffset","text":"smld_offset = addoffset(smld::SMLD2D, offset::Vector{Float64})\n\nAdd an offset elementwise to each localization smld.y and smld.x.\n\nInputs\n\n-offset: Two element vector describing the offset. ([offsety; offsetx])\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.catsmld-Tuple{SMLMData.SMLD2D, SMLMData.SMLD2D}","page":"Library","title":"SMLMData.catsmld","text":"smld = catsmld(smld1::SMLD2D, smld2::SMLD2D)\n\nConcatenate smld1 and smld2.\n\nDescription\n\nThis method concatenates the datafields of smld1 and smld2 (as defined by smld1.datafields) into an output smld.  The non-data fields are taken from smld1 and copied into smld.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.circleim-Tuple{SMLMData.SMLD2D, Float64, String}","page":"Library","title":"SMLMData.circleim","text":"image = circleim(smld::SMLMData.SMLD2D, pxsize::Float64, filename::String;\n                 pxsize_out::Float64 = 0.005)\n\nGenerate and save a circle image.\n\nDescription\n\nThis method is a wrapper for makecircleim() which uses different inputs arguments and saves the image.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -pxsize: Pixel size of localizations in smld. (micrometers) -pxsize_out: Desired output pixel size. (micrometers)\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.circleim-Tuple{SMLMData.SMLD2D, Float64}","page":"Library","title":"SMLMData.circleim","text":"image = circleim(smld::SMLMData.SMLD2D, pxsize::Float64;\n                 pxsize_out::Float64 = 0.005)\n\nGenerate and save a circle image.\n\nDescription\n\nThis method is a wrapper for makecircleim() with modified inputs.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -pxsize: Pixel size of localizations in smld. (micrometers) -pxsize_out: Desired output pixel size. (micrometers)\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.contraststretch!-Tuple{Matrix{Float64}}","page":"Library","title":"SMLMData.contraststretch!","text":"contraststretch!(image::Matrix{Float64};\n                 minval::Float64 = 0.0, maxval::Float64 = 1.0)\n\nStretch the histogram of image to fill the range minval to maxval.\n\nInputs\n\n-image: Image to be contrast stretched. -minval: Minimum value of pixels in image once stretched. -maxval: Maximum value of pixels in image once stretched.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.contraststretch-Tuple{Matrix{Float64}}","page":"Library","title":"SMLMData.contraststretch","text":"outimage = contraststretch(image::Matrix{Float64};\n                        minval::Float64 = 0.0, maxval::Float64 = 1.0)\n\nStretch the histogram of image to fill the range minval to maxval.\n\nInputs\n\n-image: Image to be contrast stretched. -minval: Minimum value of pixels in image once stretched. -maxval: Maximum value of pixels in image once stretched.\n\nOutputs\n\n-outimage: Contrast stretched copy of input image.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.gaussim-Tuple{SMLMData.SMLD2D, Float64, String}","page":"Library","title":"SMLMData.gaussim","text":"image = gaussim(smld::SMLMData.SMLD2D, pxsize::Float64, filename::String;\n                pxsize_out::Float64 = 0.005,\n                prctileceiling::Float64 = 99.5, \n                nsigma::Float64 = 5.0)\n\nGenerate and save a user-friendly (i.e., scaled and thresholded) Gaussian image.\n\nDescription\n\nThis method is a wrapper for makegaussim() which generates a more user-friendly Gaussian image.  That is, this method calls makegaussim(), applies a percentile ceiling to the results, and then performs a contrast stretch so its pixels  occupy the range [0.0, 1.0].  This method of gaussim() saves the image in the  user-specified filename.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -pxsize: Pixel size of localizations in smld. (micrometers) -filename: String specifying the location of the output image. -pxsize_out: Desired output pixel size. (micrometers) -prctileceiling: Upper percentile used to threshold the pixel values of                    particularly bright pixels. -nsigma: Number of standard deviations from the localization coordinate at            which we truncate the Gaussian. (Default = 5.0)\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.gaussim-Tuple{SMLMData.SMLD2D, Float64}","page":"Library","title":"SMLMData.gaussim","text":"image = gaussim(smld::SMLMData.SMLD2D, pxsize::Float64;\n                pxsize_out::Float64 = 0.005,\n                prctileceiling::Float64 = 99.5, \n                nsigma::Float64 = 5.0)\n\nGenerate a user-friendly (i.e., scaled and thresholded) Gaussian image.\n\nDescription\n\nThis method is a wrapper for makegaussim() which generates a more user-friendly Gaussian image.  That is, this method calls makegaussim(), applies a percentile ceiling to the results, and then performs a contrast stretch so its pixels  occupy the range [0.0, 1.0].\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -pxsize: Pixel size of localizations in smld. (micrometers) -pxsize_out: Desired output pixel size. (micrometers) -prctileceiling: Upper percentile used to threshold the pixel values of                    particularly bright pixels. -nsigma: Number of standard deviations from the localization coordinate at            which we truncate the Gaussian. (Default = 5.0)\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.isolateconnected-Tuple{SMLMData.SMLD2D}","page":"Library","title":"SMLMData.isolateconnected","text":"smld_connected, keepbool = isolateconnected(smld::SMLMData.SMLD2D)\n\nPrepare individual SMLD2D structures for each precluster in smld.\n\nDescription\n\nConnected localizations in smld (based on their connectID field) are  reorganized into distinct SMLD2D structures, with each structure corresponding to a single connectID.\n\nInputs\n\n-smld: SMLD2D structure containing the localization data, with the field           connectID populated with a meaningful set of connection indices.\n\noutputs\n\n-smld_connected: Vector of SMLD2D structures with each structure containing                    localizations that share the same connectID. -keepbool: Vector of BitVector defining the smld indices sharing the same              connectID.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, BitVector}","page":"Library","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, keepbit::BitVector)\n\nIsolate the smld localizations specified by keepbit BitVector.\n\nDescription\n\nThis method grabs the localizations requested by the BitVector keepbit, which should have the same length as the number of localizations in smld.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, Int64}","page":"Library","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, subind::Int)\n\nIsolate the smld localizations specified by subind index.\n\nDescription\n\nThis method grabs the localization indexed by subind from smld and outputs a new SMLD2D structure containing only those localization.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, UnitRange}","page":"Library","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, subind::UnitRange)\n\nIsolate the smld localizations specified by subind indices.\n\nDescription\n\nThis method grabs the localizations indexed by subind from smld and outputs a new SMLD2D structure containing only those localization.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, Vector{Int64}}","page":"Library","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, subind::Vector{Int})\n\nIsolate the smld localizations specified by subind indices.\n\nDescription\n\nThis method grabs the localization indexed by subind from smld and outputs a new SMLD2D structure containing only those localization.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.makebinim","page":"Library","title":"SMLMData.makebinim","text":"image = makebinim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)\n\nMake a binary image of the localizations in smld.\n\nDescription\n\nThis function creates an image of the localizations in smld by placing a hot pixel at the coordinates of each localization.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} binary image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"Library/#SMLMData.makebinim-2","page":"Library","title":"SMLMData.makebinim","text":"image = makebinim(coords::Matrix{Float64}, \n                  datasize::Vector{Float64},\n                  mag::Float64 = 20.0)\n\nMake a binary image of the localizations in coords.\n\nDescription\n\nThis function creates an image of the localizations in coords by placing a hot pixel at the coordinates of each localization.\n\nInputs\n\n-coords: Localization coordinates. ([y x]) -datasize: Size of the data image. ([ysize xsize]) -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} binary image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"Library/#SMLMData.makecircleim","page":"Library","title":"SMLMData.makecircleim","text":"image = makecircleim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)\n\nMake a circle image of the localizations in smld.\n\nDescription\n\nThis function creates an image of the localizations in smld by adding a circle for each localization.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} circle image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"Library/#SMLMData.makecircleim-2","page":"Library","title":"SMLMData.makecircleim","text":"image = makecircleim(coords::Matrix{Float64},\n                     σ::Vector{Float64},\n                     datasize::Vector{Int},\n                     mag::Float64 = 20.0)\n\nMake a circle image of the localizations in coords.\n\nDescription\n\nThis function creates an image of the localizations in coords by adding a circle centered at the locations coords with radii σ.\n\nInputs\n\n-coords: Localization coordinates. ([y x]) -σ: Standard error of localizations in coords. (nlocx1) -datasize: Size of the data image. ([ysize xsize]) -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} histogram image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"Library/#SMLMData.makegaussim-Tuple{Matrix{Float64}, Matrix{Float64}, Vector{Int64}}","page":"Library","title":"SMLMData.makegaussim","text":"image = makegaussim(μ::Matrix{Float64},\n                    σ_μ::Matrix{Float64}, \n                    datasize::Vector{Int};\n                    mag::Float64 = 20.0, \n                    nsigma::Float64 = 5.0)\n\nMake a Gaussian image of the localizations in μ.\n\nDescription\n\nThis function creates an image of the localizations defined by μ and σ_μ in which Gaussians with standard deviations σ_μ are added at positions μ.\n\nInputs\n\n-μ: Positions of the Gaussians. (pixels)([y x]) -σ_μ: Standard errors of μ estimates. (pixels)([y x]) -datasize: Size of the region of data collection. (pixels)([y; x]) -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0) -nsigma: Number of standard deviations from the localization coordinate at            which we truncate the Gaussian. (Default = 5.0)\n\nOutputs\n\n-image: Matrix{Float64} Gaussian image in which each localization in smld           is plotted as a Gaussian.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.makegaussim-Tuple{SMLMData.SMLD2D}","page":"Library","title":"SMLMData.makegaussim","text":"image = makegaussim(smld::SMLMData.SMLD2D;\n                    mag::Float64 = 20.0, \n                    nsigma::Float64 = 5.0)\n\nMake a Gaussian image of the localizations in smld.\n\nDescription\n\nThis function creates an image of the localizations in smld by placing a Gaussian truncated to nsigma at the localization coordinates, where the  standard deviation is given by smld.σ_x and smld.σ_y.  The image is then normalized such that it sums to 1.0.  The background signal is not accounted for in this method.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0) -nsigma: Number of standard deviations from the localization coordinate at            which we truncate the Gaussian. (Default = 5.0)\n\nOutputs\n\n-image: Matrix{Float64} Gaussian image in which each localization in smld           is plotted as a Gaussian.\n\n\n\n\n\n","category":"method"},{"location":"Library/#SMLMData.makehistim","page":"Library","title":"SMLMData.makehistim","text":"image = makehistim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)\n\nMake a histogram image of the localizations in smld.\n\nDescription\n\nThis function creates an image of the localizations in smld by adding 1.0 to a pixel for each localization present within that pixel.  The final image is then scaled so that it sums to 1.0.\n\nInputs\n\n-smld: SMLMData.SMLD2D data structure containing localizations. -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} histogram image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"Library/#SMLMData.makehistim-2","page":"Library","title":"SMLMData.makehistim","text":"image = makehistim(coords::Matrix{Float64},\n                   datasize::Vector{Int},\n                   mag::Float64 = 20.0)\n\nMake a histogram image of the localizations in coords.\n\nDescription\n\nThis function creates an image of the localizations in coords by adding 1.0 to a pixel for each localization present within that pixel.  The final image is then scaled so that it sums to 1.0.\n\nInputs\n\n-coords: Localization coordinates. ([y x]) -datasize: Size of the data image. ([ysize xsize]) -mag: Approximate magnfication from data coordinates to SR coordinates.          (Default = 20.0)\n\nOutputs\n\n-image: Matrix{Float64} histogram image of localizations.\n\n\n\n\n\n","category":"function"},{"location":"#Overview","page":"Home","title":"Overview","text":"","category":"section"}]
}
