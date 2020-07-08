hIdx = 0;
vIdx = 0;
for iCar = 1:30
    if abs(t_rng(1) - 0) < 0.01 && abs(sim.horizArm.allCars(iCar).History(1,1) + 236.3) < 0.1
        hIdx = iCar;
    end
    if abs(t_rng(1) - 0) < 0.01 && abs(sim.vertArm.allCars(iCar).History(1,1) + 221.5) < 0.1
       vIdx = iCar;     
    end
end
if hIdx > 0 && vIdx > 0
    sprintf('East car index is %d North car index is %d',hIdx,vIdx)
else
    disp('none found')
end