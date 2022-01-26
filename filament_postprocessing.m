
clear all, close all, clc

% addpath('../image_improvement');

%% Load data
dataTipraw = importdata('./DATA/EPIENDO1/dataTip.dat');
dataTipSizeraw = importdata('./DATA/EPIENDO1/dataTipSize.dat');
 
fid = fopen('./DATA/EPIENDO1/dataparam.csv');
parameters = textscan(fid,'%s%s','delimiter',',');

parameters{1,:}
tablehight = size(parameters{1,1},1);
table = zeros(tablehight,1);

for i = 2:tablehight(1,1)
    table(i) = str2num(cell2mat(parameters{:,2}(i)));
end

%% Rescale to physical coordinates

p.dx = table(6);
p.dy = table(7);
p.dz = table(8);
p.Lx = table(9);
p.Ly = table(10);
p.Lz = table(11);

xtip = (dataTipraw(:,1) - 1)*p.dx - p.Lx/2;
ytip = (dataTipraw(:,2) - 1)*p.dy - p.Ly/2;
ztip = (dataTipraw(:,3) - 1)*p.dz - p.Lz/2;
gradx = dataTipraw(:,4);
grady = dataTipraw(:,5);
gradz = dataTipraw(:,6);
ttime = dataTipraw(:,7);

%% Run animation

figure;
for i = 1:1%(size(dataTipSizeraw,1)-1)
   sizel = dataTipSizeraw(i) + 1;
   sizeu = dataTipSizeraw(i+1);
   interval = sizel:sizeu;
   x = xtip(interval,:);
   y = ytip(interval,:);
   z = ztip(interval,:);
   scatter3(x,y,z,'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75])
   title('Filament 3D')
   grid on
%    daspect([1 1 1])
   axis([-p.Lx/2 p.Lx/2 -p.Ly/2 p.Ly/2 -p.Lz/2 p.Lz/2])
   pause(0.1)
end

%% Attempt 2

colors = rand(50,3);

figure;
for i = 1:(size(dataTipSizeraw,1)-1)
    sizel = dataTipSizeraw(i) + 1;
    sizeu = dataTipSizeraw(i+1);
    t = dataTipraw(i) + 1;
    interval = sizel:sizeu;
    x = xtip(interval,:);
    y = ytip(interval,:);
    z = ztip(interval,:);
    listsize = sizeu-sizel+1; % size of the list at a specific frame
    
    th = 3*p.dx; % Distance threshold
    
    v = [x y z]; % list of coordinates
    plist = v; % Create a partial list
    
    filcount = 1;
    
    while ~isempty(plist)
    
        [~,I] = min(plist(:,3)); % Starting point
        if isempty(I)
            [~,I] = max(plist(:,3));
        elseif isempty(I)
            [~,I] = min(plist(:,1));
        elseif isempty(I)
            [~,I] = max(plist(:,1));
        elseif isempty(I)
            [~,I] = min(plist(:,2));
        else
            [~,I] = max(plist(:,2));
        end

        qpt = v(I(1),:); % Query point
        filament = qpt; % Filament will contain the corrdinates of a singular filament
        plist(I,:) = []; % Delete the query point from the partial list

        idx = 0; % Initialize to an arbitrary value;
        while ~isempty(idx)
            [Idx,D] = rangesearch(plist,qpt,th,'Distance','euclidean','SortIndices',true);
            Idx = cell2mat(Idx);
            D = cell2mat(D);
            if ~isempty(Idx)
                idx = Idx(1);
                filament = [filament ; plist(idx,:)];
                qpt = plist(idx,:);
                plist(idx,:) = [];
%                 iidx = find(D<p.dx);
%                 plist([iidx idx],:) = [];
            else
                disp(['Filament ' num2str(filcount)])
                filcount = filcount + 1;
                break;
            end
        end

        x2 = filament(:,1);
        y2 = filament(:,2);
        z2 = filament(:,3);
        scatter3(x2,y2,z2,'MarkerEdgeColor','k',...
            'MarkerFaceColor',colors(filcount,:))
        title(['Filament 3D, t = ' num2str(t)])
        grid on
        %    daspect([1 1 1])
        hold on
        axis([-p.Lx/2 p.Lx/2 -p.Ly/2 p.Ly/2 -p.Lz/2 p.Lz/2])
    end
    
    pause(0.1)
    hold off
end
  
