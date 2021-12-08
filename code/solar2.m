clear;
clc;
 
%%%%%%%%%%%%%%%%% define the three solar farms location at Woomera %%%%%%%%%
 
latitude = [27.56,31.16,30.71];   % latitude degree
longitude = [135.45,136.81,134.58]; % longitude degree
station_no = length(latitude);
 
% find latitude and longitude of boundaries
left = 112.025005;   % left longitude in degrees
right = 153.971146;  % right longitude
top = 10.0281243;    % top latitude
bottom = 43.9750009; % bottom latitude
div = 0.0499954;     % division for both degrees
%% Extract data at three stations 
    %%%%%%% load every individual files %%%%%%%%%%
    myDir = uigetdir; %gets directory
    myFiles = dir(fullfile(myDir,'*.txt')); %gets all txt files in struct
    station_DNI = zeros(3,length(myFiles));
for k = 1:length(myFiles)
      baseFileName = myFiles(k).name;
      fullFileName = fullfile(myDir, baseFileName);
      fprintf(1, 'Now reading %s\n', fullFileName);
      data = dlmread(fullFileName,' ',6,0);   %or readtable
      
      [rows,cols]=size(data);
               % convert -999 to zero
                for i = 1:rows
                    for j = 1:cols
                        if data(i,j) == -999
                            data(i,j) = 0;
 
                        end
                    end
 
                end
      
      
      for s = 1:station_no
 
            % convert to the grid point in txt file, first find the 4 closet point
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
                station_DNI(s,k)=star;       
                
      end
 
 
end
    
    
% Transfer 1st station data into a matrix with format (24 hours, 365 days)
% data = load('station_DNI.mat');
% station_DNI = cell2mat(struct2cell(data));
% fake = station_DNI(:,1:8736);
 station_DNI = station_DNI(:,1:8736);
 
station1data = zeros(24,364);
DNI1 = station_DNI(1,:);
 
for j=1:364
    
    for i=1:24
        station1data(i,j)= DNI1((j-1)*24+i);
    end
end
station1DNI = sum(station1data);
 
% Transfer 2nd station data into a matrix with format (24 hours, 365 days)
station2data = zeros(24,364);
DNI2 = station_DNI(2,:);
 
for j=1:364
    
    for i=1:24
        station2data(i,j)= DNI2((j-1)*24+i);
    end
end
station2DNI = sum(station2data);
 
% Transfer 3rd station data into a matrix with format (24 hours, 365 days)
station3data = zeros(24,364);
DNI3 = station_DNI(3,:);
 
for j=1:364
    
    for i=1:24
        station3data(i,j)= DNI3((j-1)*24+i);
    end
end
station3DNI = sum(station3data);
 
 
 
 
   
 
 
%% calculate the acutal electrical power for different stations
% set up the question parameters
 
phi_receiver = 0.536;   % receiver effiency
phi_collector = 0.798;  % collector efficiency
phi_thermal = 0.33;     % plant thermal efficiency
 
% calculate for the first plant
% daily solar irradiance onto the receiver W/m2
G1 = station1DNI*0.95;      % cosi=0.95 for polar axis solar collector
% the total electrical power output
no_collector=2000;
Area = 12*40*no_collector; 
P1 = G1*Area*phi_receiver*phi_collector*phi_thermal*10^-6; % convert power to MW
 
 
% calculate for the 2nd plant
% daily solar irradiance onto the receiver W/m2
G2 = station2DNI*0.95;      % cosi=0.95 for polar axis solar collector
% the total electrical power output
no_collector=2000;
Area = 12*40*no_collector; 
P2 = G2*Area*phi_receiver*phi_collector*phi_thermal*10^-6; % convert power to MW
 
 
% calculate for the 3rd plant
% daily solar irradiance onto the receiver W/m2
G3 = station3DNI*0.95;      % cosi=0.95 for polar axis solar collector
% the total electrical power output
no_collector=2000;
Area = 12*40*no_collector; 
P3 = G3*Area*phi_receiver*phi_collector*phi_thermal*10^-6; % convert power to MW
 
 
%% year sum files
 
 
% %write out a file to sum up all year DNI data
% year_DNI=dlmread('yearsum.txt',',');
