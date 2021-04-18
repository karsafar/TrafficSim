tic
crossCounts = [];
crossCountEast = [];
crossCountNorth = [];

countEast = 1;
countNorth = 1;

%% North arm crossing count
EastArmList = sim.horizArm.allCars;
east_s_in = EastArmList(1).s_in;

%% North arm crossing count
NorthArmList = sim.vertArm.allCars;
north_s_in = NorthArmList(1).s_in;
for iCar = 1:nCars(1)
    for i = 1:nIterations-1
        if EastArmList(iCar).History(1,i+1)>=east_s_in && ...
                EastArmList(iCar).History(1,i)<east_s_in
            crossCountEast(countEast,:) = [t_rng(i+1) EastArmList(iCar).History(1,i+1) 0];
            countEast = countEast+1;
        end
        if NorthArmList(iCar).History(1,i+1)>=north_s_in && ...
                NorthArmList(iCar).History(1,i)<north_s_in
            crossCountNorth(countNorth,:) = [t_rng(i+1) NorthArmList(iCar).History(1,i+1) 1];
            countNorth = countNorth+1;
        end
    end
end
crossCounts = [crossCountEast; crossCountNorth];
crossCounts = sortrows(crossCounts);
crossCount50Min = crossCounts(crossCounts(:,1)>600,3);

crossCountEast50Min = [];
if ~isempty(crossCountEast)
    crossCountEast = sortrows(crossCountEast);
    crossCountEast50Min = crossCountEast(crossCountEast(:,1)>600,3);
end

crossCountNorth50Min = [];
if ~isempty(crossCountNorth)
    crossCountNorth = sortrows(crossCountNorth);
    crossCountNorth50Min = crossCountNorth(crossCountNorth(:,1)>600,3);
end

eastCrosses = size(crossCountEast50Min,1);
northCrosses = size(crossCountNorth50Min,1);
turnTakinglengths = eastCrosses+northCrosses;

toc