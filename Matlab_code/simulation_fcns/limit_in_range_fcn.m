function [out] = limit_in_range_fcn(in, upperbound, lowerbound)
%This function simply limits the input in the definecd range
    if in > upperbound
        out=upperbound;
    elseif in < lowerbound
        out=lowerbound;
    else
        out=in;
    end
end

