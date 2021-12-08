%% this sciprt calculate one day power variation
clear;
clc;
% open files for 24 hours
%% find the DNI for 2017.each month 
str1 = 'solar_dni_2017';
str2 = 'UT.txt';
month = [01 02 03 04 05 06 07 08 09 10 11 12];
date = [01:1:31];
hour = [00:1:23];
 
%set up the question parameters
phi_receiver = 0.536;   % receiver effiency
phi_collector = 0.798;  % collector efficiency
phi_thermal = 0.33;     % plant thermal efficiency
 
% find latitude and longitude of plants
left = 112.025005;   % left longitude in degrees
right = 153.971146;  % right longitude
top = 10.0281243;    % top latitude
bottom = 43.9750009; % bottom latitude
div = 0.0499954;     % division for both degrees
 
%%%%%%%%%%%%%%%%% define the three solar farms location at Woomera %%%%%%%%%
 
    latitude = [27.56,31.16,30.71];   % latitude degree
    longitude = [135.45,136.81,134.58]; % longitude degree
     station_no = length(latitude);
 
%% sum each day 24 hour power, and get 365 days power.
     % loop through the date
 % convert to the grid point in txt file, first find the 4 closet point
 a=sprintf('%02d',12);      % solar_dni_201703
DNI = zeros(3,length(date));
G = zeros(3,length(date));
P = zeros(3,length(date));
trydata = zeros(3,length(date));
 
    for dat = 1:length(date)
       number_date = date(dat);  
       b = sprintf('%02d',number_date);   % solar_dni_20170301
       
       % loop through hours
       for h = 1:24
           number_hour = hour(h);
           c = sprintf('%02d',number_hour);   % solar_dni_20170301_01
           filename=[str1,a,b,'_',c,str2];
           data = dlmread(filename,' ',6,0);
        
        disp([ str1,a,b,'_',c,str2 ' being processed  '])
        
        [rows,cols]=size(data);
               %Display progress
            disp([ str1,a,b,'_',c,str2 ' being processed  '])
               % convert -999 to zero
                for i = 1:rows
                    for j = 1:cols
                        if data(i,j) == -999
                            data(i,j) = 0;
 
                        end
                    end
 
                end
                
                for s = 1:station_no
                    row_no = (latitude(s)-top)/div;
                    col_no = (longitude(s)-left)/div;
                    x = col_no;
                    y = row_no;
 
                    x1 = fix(col_no);
                    x2 = fix(col_no)+1;
                    y1 = fix(row_no);
                    y2= fix(row_no)+1;
                
                    Q11=data(y1,x1); 
                    Q21=data(y1,x2); 
                    Q12=data(y2,x1); 
                    Q22=data(y2,x2);
                    star = ((y2-y)/(y2-y1)*((x2-x1)/(x2-x1)*Q11+(x1-x1)/(x2-x1)*Q21))+((y-y1)/(y2-y1)*((x2-x1)/(x2-x1)*Q12+(x1-x1)/(x2-x1)*Q22));
                    trydata(s,h) = star;
                end
                
       end
       for station = 1:3
           %% calculate the acutal electrical power for different stations
           DNI(station,dat) = sum(trydata(station,:),'all')/24;  % daily average DNI
            % total solar irradiance onto the receiver W/m2
            G(station,dat) = DNI(station,dat)*0.95;      % cosi=0.95 for polar axis solar collector
            % the total electrical power output
            no_collector=2500;
            Area = 20*40*no_collector; 
            P(station,dat) = G(station,dat)*Area*phi_receiver*phi_collector*phi_thermal*10^-6; % convert power to MW
       end
    end
   
    
total_power = sum(P);
day = 1:1:length(date);
figure
plot(day,total_power);
hold on
plot(day,P(1,:));
hold on
plot(day,P(2,:));
hold on
plot(day,P(3,:));
 
title('Monthly power variation across December');
legend('Total power','station1','station2','station3');
xlim([1,length(date)]);
ylabel('Power / MW');
xlabel('Days in December')
