function [a, b, c] = kvadracoef(x, y)
    %KVADRACOEF Summary of this function goes here
    %   Detailed explanation goes here
    p = polyfit(x,y,2);
   
    a = p(1);
    b = p(2);
    c = p(3);
end
