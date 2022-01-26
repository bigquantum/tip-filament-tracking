
clear all, close all, clc

%% Load data

n = 1;

dataRaw = importdata('./results/dataA1/dataContour.dat');
% dataRaw = importdata(['dataContour_1']);

% Rescale to physical coordinates
p.Lx = 7.0;
p.Ly = 7.0;
p.Nx = 512;
p.Ny = 512;
p.dx = p.Lx/(p.Nx-1.0);
p.dy = p.Ly/(p.Ny-1.0);

maxCluster = 10; % Ensure that this number is big enough
colorArray = rand(maxCluster,3);
% 0.973619074114230   0.053977943509693   0.407163431920764

%%

IDX = []; k = []; kp = 0;
firstIter = 1;
clusterCell = cell(maxCluster,4);

for s = 1:maxCluster
    clusterCell{s,3} = s;
    clusterCell{s,4} = s;
end

i = 1;

figure;
while i < size(dataRaw,1)
    t1 = dataRaw(i,3);
    t2 = t1;
    j = i;
    while (t1 == t2) && (i <= size(dataRaw,1))
        t2 = dataRaw(i,3);
        i = i + 1;
    end
    i = i - 1;
    interval = j:(i-1);
    x = dataRaw(interval,1)*p.dx - p.Lx/2;
    y = dataRaw(interval,2)*p.dy - p.Ly/2;
    time = dataRaw(interval(1),3);
    
    if size(x,1)>maxCluster
        % Obtain current clusters
        [~,V_temp,D_temp] = spectralcluster([x y],maxCluster);
        k = size(find(D_temp<1e-14),1);
        IDX = kmeans(V_temp(:,1:k),k);
        % Special case for the first iteration
        if firstIter == 1
           for s = 1:k
               ind = find(IDX==s); 
               xn = x(ind);
               yn = y(ind);
               clusterCell{s,2} = [xn yn];
               scatter(xn,yn,'MarkerEdgeColor',colorArray(s,:),...
                'MarkerFaceColor',colorArray(s,:))  
               hold on
           end
           firstIter = 0;
        else

            % Continue building current cluster
            for s = 1:k
               % Current iteration cluster
               ind = find(IDX==s); 
               xn = x(ind);
               yn = y(ind);
               xyn = [xn yn];
               clusterCell{s,2} = xyn;
            end
            
            Darray = zeros(kp,1);
            for s = 1:k
                cn = clusterCell{s,2};
                for q = 1:kp
                   cp = clusterCell{q,1};
                   Darray(q) = min(pdist2(cn,cp,'cityblock','Smallest',1));
                end
                [M,labelp] = min(Darray);
                if (M < 0.2) && (k == kp)
                    colorp = clusterCell{labelp,3};
                    clusterCell{s,4} = colorp;
                end

            end

            for s = 1:k
                colorNum = clusterCell{s,4};
                xy = clusterCell{s,2};
                scatter(xy(:,1),xy(:,2),'MarkerEdgeColor',colorArray(colorNum,:),...
                'MarkerFaceColor',colorArray(colorNum,:))  
                hold on
            end
            
        end
        
        grid on
        title(['Contour tracking, t = ' num2str(time) ' ms'],'FontSize',20,'interpreter','latex')
        axis([-p.Lx/2 p.Lx/2 -p.Ly/2 p.Ly/2])
        set(gcf,'color','w');
        hold off
        pause(0.1)
        
    end
 
    kp = k;
    
    for s = 1:k
        clusterCell{s,1} = clusterCell{s,2};
        clusterCell{s,3} = clusterCell{s,4};
    end
    
    cc = cell2mat(clusterCell(:,3));
    if size(cc,1) > size(unique(cc),1)
        for s = 1:maxCluster
            clusterCell{s,3} = s;
        end
    end
    
end

