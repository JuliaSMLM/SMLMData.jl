using Revise
using SMLMData
SD = SMLMData



# x=[1, 2, 3]

s = SD.SMLD2D()
s.x == Float64[]
# s = SD.SMLD2D(3)
# s = SD.SMLD2D(bg=[1,2,3])

# s = SD.SMLD3D()
# s = SD.SMLD3D(3)
# s = SD.SMLD3D(y=[1,2,3])






# mutable struct practice
#     x::Vector{Float64}
#     y::Vector{Float64}
# end


# function practice(;
#     x=zeros(Float64, 1), 
#     y=zeros(Float64, 1))

#     p=practice(x, y)


#     return p

# end



# s = practice(x=[1,2,3],y=[2,3,4])