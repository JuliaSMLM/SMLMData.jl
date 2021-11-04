var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = SMLMData","category":"page"},{"location":"#SMLMData","page":"Home","title":"SMLMData","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for SMLMData.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [SMLMData]","category":"page"},{"location":"#SMLMData.SMLD2D-Tuple{DataFrames.DataFrame}","page":"Home","title":"SMLMData.SMLD2D","text":"SMLD2D(nlocalizations::Int)\n\nConstructor to generate an smld from a data frame.\n\nDescription\n\nThis is a constructor for the SMLD2D struct which allows you to populate the structure with data defined in the dataframe data. The intention is that a .csv table can be organized with localizations on each row as [datasetnum, framenum, x, y, σx, σy], loaded using the CSV package, and  placed into a dataframe with the DataFrames package.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.SMLD2D-Tuple{Int64}","page":"Home","title":"SMLMData.SMLD2D","text":"SMLD2D(nlocalizations::Int)\n\nConstructor to generate an empty smld with a specific size.\n\nDescription\n\nThis is a constructor for the SMLD2D struct which allows you to populate the structure with undefined values for a predefined number of localizations.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.addoffset!-Tuple{SMLMData.SMLD2D, Vector{Float64}}","page":"Home","title":"SMLMData.addoffset!","text":"addoffset!(smld::SMLD2D, offset::Vector{Float64})\n\nAdd an offset elementwise to each localization smld.y and smld.x.\n\nInputs\n\n-offset: Two element vector describing the offset. ([offsety; offsetx])\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.addoffset-Tuple{SMLMData.SMLD2D, Vector{Float64}}","page":"Home","title":"SMLMData.addoffset","text":"smld_offset = addoffset(smld::SMLD2D, offset::Vector{Float64})\n\nAdd an offset elementwise to each localization smld.y and smld.x.\n\nInputs\n\n-offset: Two element vector describing the offset. ([offsety; offsetx])\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.catsmld-Tuple{SMLMData.SMLD2D, SMLMData.SMLD2D}","page":"Home","title":"SMLMData.catsmld","text":"smld = catsmld(smld1::SMLD2D, smld2::SMLD2D)\n\nConcatenate smld1 and smld2.\n\nDescription\n\nThis method concatenates the datafields of smld1 and smld2 (as defined by smld1.datafields) into an output smld.  The non-data fields are taken from smld1 and copied into smld.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.isolateconnected-Tuple{SMLMData.SMLD2D}","page":"Home","title":"SMLMData.isolateconnected","text":"smld_connected, keepbool = isolateconnected(smld::SMLMData.SMLD2D)\n\nPrepare individual SMLD2D structures for each precluster in smld.\n\nDescription\n\nConnected localizations in smld (based on their connectID field) are  reorganized into distinct SMLD2D structures, with each structure corresponding to a single connectID.\n\nInputs\n\n-smld: SMLD2D structure containing the localization data, with the field           connectID populated with a meaningful set of connection indices.\n\noutputs\n\n-smld_connected: Vector of SMLD2D structures with each structure containing                    localizations that share the same connectID. -keepbool: Vector of BitVector defining the smld indices sharing the same              connectID.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, BitVector}","page":"Home","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, keepbit::BitVector)\n\nIsolate the smld localizations specified by keepbit BitVector.\n\nDescription\n\nThis method grabs the localizations requested by the BitVector keepbit, which should have the same length as the number of localizations in smld.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, UnitRange}","page":"Home","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, subind::UnitRange)\n\nIsolate the smld localizations specified by subind indices.\n\nDescription\n\nThis method grabs the localizations indexed by subind from smld and outputs a new SMLD2D structure containing only those localization.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.isolatesmld-Tuple{SMLMData.SMLD2D, Vector{Int64}}","page":"Home","title":"SMLMData.isolatesmld","text":"smld_sub = isolatesmld(smld::SMLD2D, subind::Vector{Int})\n\nIsolate the smld localizations specified by subind indices.\n\nDescription\n\nThis method grabs the localizations indexed by subind from smld and outputs a new SMLD2D structure containing only those localization.\n\n\n\n\n\n","category":"method"},{"location":"#SMLMData.length-Tuple{SMLMData.SMLD2D}","page":"Home","title":"SMLMData.length","text":"length(smld::SMLMData.SMLD2D)\n\nReturns the number of localizations in smld.\n\n\n\n\n\n","category":"method"}]
}
