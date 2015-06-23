function [varargout] = gpeget2denergydecomp(gridx,inpsi)

psik=fftn(inpsi);
dx = gridx(2)-gridx(1);
% psik - condensate wavefunction in fourier space dimensions [mm,mm]
% dx - lattice spacing - assumes dx = dy and dimensions x = dimensions of y
% outputs: Ekinsq_c, Ekinsq_i or just Ekinsq_i
% where:
% Ekinsq_c: Compressible kinetic energy density dimensions [mm,mm]
% Ekinsq_i: Incompressible kinetic energy density dimensions [mm,mm]

gridDim = size(psik);
mm = gridDim(1);

%--------------------------------------------------------------------------
% A: Calculating Velocities
%--------------------------------------------------------------------------

dk = 2*pi/(dx*mm);

ki = [linspace(0,(mm/2-1)*dk,mm/2) linspace(-mm/2*dk,-dk,mm/2)];
kj = [linspace(0,(mm/2-1)*dk,mm/2) linspace(-mm/2*dk,-dk,mm/2)];

psi2 = ifftn(psik);
conjpsi2 = conj(psi2);
dens2 = psi2.*conjpsi2;

psiconjk = (fftn(conjpsi2));

kxpsi= zeros(mm,mm);
kxpsiconj = zeros(mm,mm);
kypsi = zeros(mm,mm);
kypsiconj = zeros(mm,mm);

for ii = 1:1:length(ki)
  for jj = 1:1:length(kj)
          kxpsi(ii,jj)=(1i*ki(ii))*psik(ii,jj);
          kxpsiconj(ii,jj)=(1i*ki(ii))*psiconjk(ii,jj);
          kypsi(ii,jj)=(1i*kj(jj))*psik(ii,jj);
          kypsiconj(ii,jj)=(1i*kj(jj))*psiconjk(ii,jj);         
  end
end

dxpsi=(ifftn(kxpsi));
dypsi=(ifftn(kypsi));
dxpsiconj=(ifftn(kxpsiconj));
dypsiconj=(ifftn(kypsiconj));

clear kxpsi; clear kypsi; %clear kzpsi;
clear kxpsiconj; clear kypsiconj; %clear kzpsiconj;
clear psik; clear conjpsik; 

velx = real(-0.5*1i*(conjpsi2(:,:).*dxpsi(:,:)-psi2(:,:).*dxpsiconj(:,:))./dens2(:,:));
vely = real(-0.5*1i*(conjpsi2(:,:).*dypsi(:,:)-psi2(:,:).*dypsiconj(:,:))./dens2(:,:));

clear conjpsi2; clear psi2; 

%--------------------------------------------------------------------------
% B: Calculating the incompressible and compressible components
%--------------------------------------------------------------------------

omegax = sqrt(dens2(:,:)).*(velx(:,:));
omegay = sqrt(dens2(:,:)).*(vely(:,:));

clear dens2; 

omegax_kx = (fftn(omegax));
omegay_ky = (fftn(omegay));

komegac_kx = zeros(mm,mm);
komegac_ky = zeros(mm,mm);

komegai_kx = zeros(mm,mm);
komegai_ky = zeros(mm,mm);

komegat_kx = zeros(mm,mm);
komegat_ky = zeros(mm,mm);

absk = zeros(mm,mm);

for ii = 1:1:length(ki)
  for jj = 1:1:length(kj)
      absk(ii,jj) = ki(ii)*ki(ii)+kj(jj)*kj(jj);
      komegac_ky(ii,jj) = (kj(jj)*ki(ii)*omegax_kx(ii,jj)+kj(jj)*kj(jj)*omegay_ky(ii,jj))/(absk(ii,jj));
      komegac_kx(ii,jj) = (ki(ii)*ki(ii)*omegax_kx(ii,jj)+ki(ii)*kj(jj)*omegay_ky(ii,jj))/(absk(ii,jj));
      komegai_ky(ii,jj) = omegay_ky(ii,jj) - komegac_ky(ii,jj);
      komegai_kx(ii,jj) = omegax_kx(ii,jj) - komegac_kx(ii,jj);
      %komegat_kx(ii,jj) = komegac_kx(ii,jj)+komegai_kx(ii,jj);
      %komegat_ky(ii,jj) = komegac_ky(ii,jj)+komegai_ky(ii,jj);
   end
end

komegac_ky(find(isnan(komegac_ky))) = 0;
komegac_kx(find(isnan(komegac_kx))) = 0;

komegai_ky(find(isnan(komegai_ky))) = 0;
komegai_kx(find(isnan(komegai_kx))) = 0;

%komegat_ky(find(isnan(komegat_ky))) = 0;
%komegat_kx(find(isnan(komegat_kx))) = 0;

omegac_x = real(ifftn(komegac_kx));
omegac_y = real(ifftn(komegac_ky));

omegai_x = real(ifftn(komegai_kx));
omegai_y = real(ifftn(komegai_ky));

%omegat_x = real(ifftn(komegat_kx));
%omegat_y = real(ifftn(komegat_ky));


Ekinsq_c = 0.5*((omegac_x.^2+omegac_y.^2));
Ekinsq_i = 0.5*((omegai_x.^2+omegai_y.^2));
Ekinsq_t = Ekinsq_c+Ekinsq_i;
%Ekinsq_t = 0.5*((omegat_x.^2+omegat_y.^2));
% stuff to output
if nargout == 3
 varargout = {Ekinsq_t,Ekinsq_c, Ekinsq_i};
elseif nargout == 2
 varargout = {Ekinsq_c, Ekinsq_i};
else
 varargout = {Ekinsq_i};
end
end