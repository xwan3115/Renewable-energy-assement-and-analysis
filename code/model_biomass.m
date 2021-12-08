% MECH 5275
% Major project biomass model
% Author: Yuxin Zhu 
% SID: 460053646

clc
clear

% Choose Direct methonal fuel cell(DMFC) as the storage 

% Gibbs free energy for reactions and productions
g_ch3oh = -166360;
g_o2 = 0;
g_ch2o = -110000;
g_h2o = -228590;
g_reac = g_ch3oh + g_o2;
g_prod = g_ch2o + g_h2o;
dg = g_reac - g_prod;


% Enthalpy of reactions and productions
% liquid for methonal
h_ch3oh = -0;
h_o2 = 0;
h_ch2o = -115900;
h_h2o = -241820;
h_reac = h_ch3oh + h_o2;
h_prod = h_ch2o + h_h2o;
dh = h_reac - h_prod;

% Reversible effeciency
e_rev = dg/dh;
dq = dh-dg;

% Total residues annual
R_v = 517945;
R_meat = 9379960;
R_p = 216484;
R_s = 843000;
R_cs = 227800;
R_ncs = 674230;
R_T = R_v + R_meat + R_p + R_s + R_cs + R_ncs;

% Convert to methanol
% Biomass to methanol ratio
ratio_btm = 0.721;
rho_m = 792;
Mm_m = 32;
% Volume meter cube
V_m = 1 * ratio_btm;
% mass kg
m_m = V_m * rho_m;
% kmol
M_m = m_m/Mm_m;
% Energy per tonne in Gj
Q = M_m * dg/1000000;
% Energy in kwh
Q_kwh = Q * 278;

% Electricity from direct burning in kwh
Q_burn = 0.75*1000*R_T*2/3;
Q_fuel = Q_kwh *R_T*1/3;
% Total electricity produced
Q_T = Q_burn + Q_fuel;
Q_Tday = Q_T / 365;
Q_Tkwh = Q_Tday/24;