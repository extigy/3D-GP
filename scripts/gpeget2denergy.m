function [totalE,kinE,potE,interE] = gpeget2denergy(gridx,gridy,inpsi,inpot,g)
dx=gridx(2)-gridx(1);
[FX, FY] = derivative5(inpsi, 'x', 'y');
FX = FX/dx;
FY = FY/dx;
%[FX, FY] = gradient(inpsi,dx,dx);
dpsi = FX.*conj(FX)+FY.*conj(FY);
kin=0.5*dpsi;

pot=(inpot).*inpsi.*conj(inpsi);
inter=(g/2).*inpsi.*conj(inpsi).*inpsi.*conj(inpsi);

kinE=dx*dx*simpson(simpson(kin));
potE=dx*dx*simpson(simpson(pot));
interE=dx*dx*simpson(simpson(inter));
totalE=kinE+potE+interE;

end 