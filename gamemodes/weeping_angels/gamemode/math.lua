--locals
local vector_meta = FindMetaTable("Vector")

--smallest possible positive float
GM.Epsilon = 1.175494e-38

--vector meta functions
function vector_meta:__le(alpha) return self.x <= alpha.x and self.y <= alpha.y and self.z <= alpha.z end
function vector_meta:__lt(alpha) return self.x < alpha.x and self.y < alpha.y and self.z < alpha.z end