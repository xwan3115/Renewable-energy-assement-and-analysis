clear
clc
 
S = dir('*.txt');
index = 1;
H = 41;
r = 20;
K = 3;
No = [90,55,77];
 
for i = [13,18,30]
    
    a = 0;
    % The file we need to read is the ith file
    N = S(i).name;
 
    fid = fopen(N);
    txt = textscan(fid,'%s','delimiter','\n,','Headerlines',1); 
    fclose(fid);
 
    raw_data = txt{1,1};
 
    no_data = length(raw_data);
 
    v =[];
    direction = [];
    windgust = [];
 
  for n = 1:no_data/20
        
        thisWind1 = str2num(char(raw_data(13+a)));
        
        if thisWind1 > 56.327
            thisWind1 = 56.327;
        end
        
        if ~(isempty(thisWind1))
            v = [v ,thisWind1];
        elseif (isempty(thisWind1))
            v = [v, v(end)];
        end
        a = a+20;
    end
    
    % Then we calculate the average cubic velocity to assese the potential
    % of the wind farm at this station
    % The first step is to find the shape and scale parameter
    % Velocity is m/s
    v = v./3.6;
    ave = mean(v);
    sta = std(v);
    k = 1.2785*(ave/sta)-0.5004;
    A = ave/gamma(1+1/k);
    
    % The cubic mean velocity is 
    % The function of F*v^3 is
    density = 1.2;
    fun_mean_cubic = @(v) v.^3.*(k*A^(-k)*v.^(k-1).*exp(-(v./A).^k));
 
    % Mean cubic velocity
    v_m_cubic(index) = (integral(fun_mean_cubic,0,inf))^(1/3);
 
    % The available wind power density
    ava_power_density(index) = 16/27*1/2*density*v_m_cubic(index)^3.*10^(-3);
    
    % Assume zero set up angle and U=28 and the postion angle is 0-360
    for nu = 1:length(v)
        
        if v(nu) == 0
            T_avg(nu) = 0;
            omega(nu) = 0;
            P_d(nu) = 0;
        else
        
            zeta = 0;
            v_nu = v(nu);
            speed_ratio = 5;
            U = speed_ratio*v_nu;
            p_angle = 5:10:355;
 
            % Find angle of attack
            constant = sqrt(1+U^2/v_nu^2+2*U/v_nu.*sind(p_angle));
            costha = (U/v_nu+sind(p_angle))./constant;
        
            for d = 1:length(p_angle)
                if p_angle(d) >90 && p_angle(d)<270
                    tha(d) = -acosd(costha(d));
                else
                    tha(d) = acosd(costha(d));
                end
                    alpha_2(d) = tha(d) + zeta;
            end
 
            % Find drag and lift coefficient
            cl_2 = 0.78*sind(2.*alpha_2)+0.65*sind(alpha_2);
            cd_2 = 0.42-0.34*cosd(2.*alpha_2);
 
            % Find lift and drag force
            Ap = K*H;
            W = constant.*v_nu;
            F_lift =1/2*density.*W.^2.*Ap.*cl_2;
            F_drag =1/2*density.*W.^2.*Ap.*cd_2;
 
            % Find lift and drag in direction of blade motion
            %F_cf = F_lift.*sind(tha);
            F_cb = F_drag.*cosd(tha);
 
            % Find torque on the blade
            torque = r.*( F_cb);
 
            % Calculate <T>(mean torque), P_d(power delivered)
            % omega(angular velocity)
            T_avg(nu) = mean(torque)*10^-3;
            omega(nu) = U/r;
            P_d(nu) = T_avg(nu)*omega(nu)*5;
            
        end
    end
            P_mean(index) = mean(P_d)*10^(-3)*No(index)*0.85;
            capa_factor(index) = P_mean(index)/(max(P_d)*10^(-3)*No(index)*0.85)*100;
            
            for day = 1:365
                power_day(day,index) = mean(P_d(1+day:48+day))*10^(-3)*No(index)*0.85;
            end
            
            march_21 = 31+28+21;
            power_mar(:,index) = P_d((march_21+1)*48+1:(march_21+2)*48)*10^(-3)*No(index)*0.85;
 
            June_21 = 31+28+31+30+31+21;
            power_june(:,index) = P_d(June_21*48+1 :(June_21+1)*48)*10^(-3)*No(index)*0.85;
            ah = 1;
 
            
            Aug_21 = 31+28+31+30+31+30+31+21;
            power_aug(:,index) = P_d(Aug_21*48+1 :(Aug_21+1)*48)*10^(-3)*No(index)*0.85;
            ah = 1;
 
            Dec_21 = 31+28+31+30+31+30+31+31+30+31+30+21;
            power_dec(:,index) = P_d(Dec_21*48+1 :(Dec_21+1)*48)*10^(-3)*No(index)*0.85;
 
            
            index = index + 1;
end
 
 
sum_of_power = power_day(:,1)+power_day(:,2)+power_day(:,3);
% Daily data over a year
hold on
day = 1:365;
plot(day,power_day(:,1)');
plot(day,power_day(:,2)');
plot(day,power_day(:,3)');
xlabel('Days in one year');
ylabel('Power output');
legend('Farm 1', 'Farm 2','Farm 3')
 
% Hour data over a day
% Site 1
figure(2)
subplot(2,2,1)
hour = 1:48;
plot(hour, power_mar(:,1));
subplot(2,2,2)
plot(hour, power_june(:,1));
subplot(2,2,3)
plot(hour, power_aug(:,1));
subplot(2,2,4)
plot(hour, power_dec(:,1));
 
% Site 2
figure(3)
subplot(2,2,1)
hour = 1:48;
plot(hour, power_mar(:,2));
subplot(2,2,2)
plot(hour, power_june(:,2));
subplot(2,2,3)
plot(hour, power_aug(:,2));
subplot(2,2,4)
plot(hour, power_dec(:,2));
 
% Site 2
figure(4)
subplot(2,2,1)
hour = 1:48;
plot(hour, power_mar(:,3));
subplot(2,2,2)
plot(hour, power_june(:,3));
subplot(2,2,3)
plot(hour, power_aug(:,3));
subplot(2,2,4)
plot(hour, power_dec(:,3));
 
power_sum_mar = power_mar(:,1)+power_mar(:,2)+power_mar(:,3);
power_sum_june = power_june(:,1)+power_june(:,2)+power_june(:,3);
power_sum_aug = power_aug(:,1)+power_aug(:,2)+power_aug(:,3);
power_sum_dec = power_dec(:,1)+power_dec(:,2)+power_dec(:,3);
 
 
E_1 = P_mean(1)*365*24*1000*25
E_2 = P_mean(2)*365*24*1000*25
E_3 = P_mean(3)*365*24*1000*25
 
% Construction cost, operating cost and maintenance cost
L_1 = (800*10^6+48000*P_mean(1)+1800*365*25*90)/E_1
L_2 = (160*10^6+48000*P_mean(2)+1800*365*25*55)/E_2
L_3 = (230*10^6+48000*P_mean(3)+1800*365*25*77)/E_3
mean = (L_1+L_2+L_3)/3;
