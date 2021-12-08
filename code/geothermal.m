%%
%Geothermal power plant
clc;
clear;
%Read from the excel given
T2 = xlsread('geothermal_data','sheet3','AG4:AG1333');

%For electric power generation, 
%The temps of resources should higher than 110 Celsius, otherwise, it will
%not be feasible, then calculate the K
K2 = [];
for i= 1:1330
    if T2(i) > 110
        K2(i) = T2(i)+273;
    end
end

%Assume that the mass flow rate of geothermal water is
m_dot = 440; %kg/s;

%The outside temperature is T = 25 C
K0 = 298;

% density of water at 25 Celsius
pho = 998;

%gravity constant
g = 9.81;
%Read from the excel given
%Depth of temperature
h = xlsread('geothermal_data','sheet3','AE4:AE1333');

%Energy needed of the pump:
W_pump = m_dot * g * h / 10^6;    %(MW)

%As fluid taken is geothermal liquid water, we can use the properties at
%saturated liquid state.
%Since the temperature are in the range of 110 to 180 C, the liquid would turns to saturated vapour 
%Assume that the relationship between enthaply and entropy against
%temperature is linear, then the gradient should be:
%Read from the table A-4
%take the saturated vapour enthaply and entropy respectively are:

%Enthaply gradient:
h110 = 2691.1;
h180 = 2777.2;
h1 = (2777.2 - 2691.1)/(180 - 110) * (T2 - 110) + 2691.1;%KJ/kg

%Entropy gradient:
s110 = 7.2382;
s180 = 6.5841;

s1 = 7.2382 - (7.2382-6.5841)/(180-110) * (T2 - 110); %KJ/kg*K

%From saturated water table at temperature T = 25 C, the saturated liquid
%enthalpy and entropy are:
h2 = 104.83; %KJ/kg
s2 = 0.3672; %KJ/kg*K

%The exergy of geothermal water entering the plant is
X_in = m_dot *(h1-h2-K0*(s1-s2))/1000; %(MW)

%Efficiency of turbine to generate electricity
n_turb = 0.6;
%Exergy destructed while transferring£º
X_des = 18.2; %MW (Assumed from the real geothermal power station in the U.S.)
%Power output
W_out = X_in * n_turb - W_pump - X_des;
%Efficiency of generator
n_gen = 0.9;
%Actual power output
W_real = W_out * n_gen;
%Power output in KWH
W_output = W_real * 1000 *3600;

%Energy generated for a year
E_gen = W_output * 24 * 365 /10^12; %(peta J) 

%number of positions
number = 0;
%Sum of energy generated
E_sum = 0;
for i = 1: length(E_gen)
    if E_gen(i) >= 1
        number = number +1;
        E_sum = E_sum +E_gen(i);
    end
end
%Average result of energy generated for a year
E_average = E_sum / number;

%Energy provided compared with Australia energy need annually
percent = E_average/6146 *100;