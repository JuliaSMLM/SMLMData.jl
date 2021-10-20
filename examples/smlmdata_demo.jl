# This script demonstrates usage of the SMLMData package.
using Revise
using SMLMData
using DataFrames
using CSV

## Create an empty smld structure.
smld_empty = SMLMData.SMLD2D()

## Create an empty smld structure with a specified numberr of localizations.
nlocalizations = 21
smld_init = SMLMData.SMLD2D(nlocalizations)

## Create an smld structure from a properly formatted csv file:
#  The csv file should be organized s.t. each row is a localization, with the
#  data organized as [datasetnum, framenum, x, y, x_se, y_se].
data = DataFrames.DataFrame(CSV.File("C:\\Users\\David\\Documents\\GitHub\\example_data.csv"))
smld = SMLMData.SMLD2D(data)

## Isolate a subregion of `smld`.
smld_sub = SMLMData.isolatesmld(smld, [1, 2, 3])
smld_sub = SMLMData.isolatesmld(smld, smld.connectID.==2)