%%
nBF = 0;
h_arm = sim.horizArm;
h_cars = h_arm.allCars';
for ii = 1:nCars(1)
    %count number of backoffs
    car_i = h_cars(ii);
    temp = diff(car_i.bbStore(2,:));
    temp1 = temp(temp > 0);
    nBF = nBF + numel(temp1);
end
for jj = 1:nCars(2)
    %count number of backoffs
    car_j = sim.vertArm.allCars(jj);
    temp = diff(car_j.bbStore(2,:));
    temp1 = temp(temp > 0);
    nBF = nBF + numel(temp1);
end
nBF/2