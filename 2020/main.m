%% setup
clear;
s = 1000;
x = linspace(-10, 10, s);
a = +2.5;
b = -1.5;
c = +4;
y = a * x.^2 + x * b + c + randn(1, s)*10;
 
if ~isfile("assets/state.mat")
    mkdir("assets")
    save("assets/state.mat")
end
 
 
%% load from file to suppress random element
if isfile("assets/state.mat")
    load("assets/state.mat")
end
 
 
%% test
e = 1.0;
[a2, b2, c2] = kvadracoef(x, y);
 
 
%% plot
ff = figure;
p = [a2, b2, c2];
f = polyval(p,x);
plot(x,y,'o',x,f,'-');
legend('data','linear fit');
saveas(ff, 'figure.png');
 
 
%% answer
 
isok = abs(a - a2) < e & abs(b - b2) < e & abs(c - c2) < e;
 
if ~isok
    error("Wrong answer");
else
    disp('ok');
end