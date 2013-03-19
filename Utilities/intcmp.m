% Compare whether integer 1 is equal to integer 2.
% Used in cleanUp.m; Refinement.m; motCompsMatchEval.m; llbehComposition;
%--------------------------------------------------------------------------
function result = intcmp(int1,int2)
    if(int1==int2)
        result = 1;
    else
        result = 0;
    end
end