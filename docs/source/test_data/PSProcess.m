function out = PSProcess(S1,S2,procStruct)

    %PSProcess computes local birefringence of the 
    %Stokes vectors S1 and S2, corresponding to the Stokes vectors measured 
    %for an input polarization state modulated between states orthogonal on the
    %Poincaree sphere, using spectral binning.
    %The third dimension, if present, is for spectral binning.
    %
    %PSProcess computes the local retardance matrix for each bin, then finds
    %the necessary alignment between the various spectral bins independently
    %for each A-line.
    %
    %
    % :param S1: measured Stokes vector for the first input polarization state
    % :param S2: measured Stokes vector for the second input polarization state
    % the only two mandatory arguments are
    %
    % :arg fwx: width of filtering in lateral dimension
    % :arg dz: axial spacing over which to compute the local retardance
    %
    %
    %
    fwx = procStruct.fwx;
    dz = procStruct.dz;
    rcorr = [];
    %
    % because the local retardation is converted to degrees of rotation per
    % depth in the tissue, the axial scaling of the tomogram is required.
    %
if isfield(procStruct,'dzres')
    dzres = procStruct.dzres;
else
    dzres = 100*180/pi;
end
    %

if isfield(procStruct,'dopTh')
    dopTh = procStruct.dopTh;
else
    dopTh = [0.6,1];
end

% padd Stokes vectors on both sides
prepad = floor(ceil(1.5*fwx)/2)+floor(fwx/2);
postpad = ceil(ceil(1.5*fwx)/2)+ceil(fwx/2);

S1 = cat(2,S1(:,end-prepad+1:end,:,:),S1,S1(:,1:postpad,:,:));
S2 = cat(2,S2(:,end-prepad+1:end,:,:),S2,S2(:,1:postpad,:,:));

% % stokesFiltering 
[S1, S2, dop, QUVf1, QUVf2] = stokesFiltering(S1,S2, procStruct);

out.If = squeeze(mean(S1(:,prepad+1:end-postpad,:,1)+S2(:,prepad+1:end-postpad,:,1),3));
S1 = S1(:,:,:,2:4)./QUVf1;
S2 = S2(:,:,:,2:4)./QUVf2;

% force the two Stokes vectors to be orthogonal, which is equivalent to the
% lsq solution

% construct orthonormal tripod for these data points
na = S1 + S2;
nb = S1 - S2;
S1 = na./sqrt(sum(na.^2,4));
S2 = nb./sqrt(sum(nb.^2,4));

% local birefringence analysis
S1plus = circshift(S1,-dz);
S1minus = circshift(S1,dz); 
S2plus = circshift(S2,-dz);
S2minus = circshift(S2,dz);   

% simple cross product of difference vectors to find PA
PA = cross(S1minus-S1plus,S2minus-S2plus,4);
PA = PA./max(sqrt(sum(PA.^2,4)),1e-9);

temp = dot(S1plus,PA,4).^2;
retSinW = real(acos((dot(S1plus,S1minus,4)-temp)./(1-temp)))/2/dz;
pm = sign((1-dot(S1plus,S1minus,4)).*(dot(S1plus-S1minus,S2plus+S2minus,4)));
PA = PA.*pm;

rpamean = mean(PA.*retSinW,3);
rmean = sqrt(dot(rpamean,rpamean,4));
out.stdpa = 1-rmean(:,prepad+1:end-postpad)./mean(abs(retSinW(:,prepad+1:end-postpad,:)),3);    
out.rmean = rmean(:,prepad+1:end-postpad)*100/4.8*180/pi;

% implementation of estimation of relative rotations between the
% different subwindows

Wcorr = PA.*retSinW;
dim = size(PA);
mask = (dop>dopTh(1)).*(dop<=dopTh(2));
mid = ceil(size(retSinW,3)/2);
PA = PA.*repmat(mask,[1,1,dim(3),3]);

ref = PA(:,:,mid,:);
C = zeros([3,3,dim(2)]);

h = ones(1,fwx)/3;
for wind = [(1:mid-1),(mid+1:dim(3))]
    C(1,1,:) = conv(sum(PA(:,:,wind,1).*ref(:,:,1),1),h,'same');
    C(2,1,:) = conv(sum(PA(:,:,wind,1).*ref(:,:,2),1),h,'same');
    C(3,1,:) = conv(sum(PA(:,:,wind,1).*ref(:,:,3),1),h,'same');

    C(1,2,:) = conv(sum(PA(:,:,wind,2).*ref(:,:,1),1),h,'same');
    C(2,2,:) = conv(sum(PA(:,:,wind,2).*ref(:,:,2),1),h,'same');
    C(3,2,:) = conv(sum(PA(:,:,wind,2).*ref(:,:,3),1),h,'same');

    C(1,3,:) = conv(sum(PA(:,:,wind,3).*ref(:,:,1),1),h,'same');
    C(2,3,:) = conv(sum(PA(:,:,wind,3).*ref(:,:,2),1),h,'same');
    C(3,3,:) = conv(sum(PA(:,:,wind,3).*ref(:,:,3),1),h,'same');

    R = reshape(euclideanRotation(reshape(C,[9,size(C,3)])),[3,3,size(C,3)]);

    temp1 = Wcorr(:,:,wind,1).*repmat(shiftdim(R(1,1,:),1),[dim(1),1]) + Wcorr(:,:,wind,2).*repmat(shiftdim(R(1,2,:),1),[dim(1),1]) + Wcorr(:,:,wind,3).*repmat(shiftdim(R(1,3,:),1),[dim(1),1]);
    temp2 = Wcorr(:,:,wind,1).*repmat(shiftdim(R(2,1,:),1),[dim(1),1]) + Wcorr(:,:,wind,2).*repmat(shiftdim(R(2,2,:),1),[dim(1),1]) + Wcorr(:,:,wind,3).*repmat(shiftdim(R(2,3,:),1),[dim(1),1]);
    temp3 = Wcorr(:,:,wind,1).*repmat(shiftdim(R(3,1,:),1),[dim(1),1]) + Wcorr(:,:,wind,2).*repmat(shiftdim(R(3,2,:),1),[dim(1),1]) + Wcorr(:,:,wind,3).*repmat(shiftdim(R(3,3,:),1),[dim(1),1]);

    Wcorr(:,:,wind,1) = temp1;
    Wcorr(:,:,wind,2) = temp2;
    Wcorr(:,:,wind,3) = temp3;
    rcorr(:,:,wind) = decomposeRot(reshape(R,[9,size(C,3)]));
end

rpamean = mean(Wcorr,3);
rmeancorr = sqrt(dot(rpamean,rpamean,4));

out.ret = rmeancorr(:,prepad+1:end-postpad)*100/dzres*180/pi;
out.PA = rpamean(:,prepad+1:end-postpad,:,:)./repmat(rmeancorr(:,prepad+1:end-postpad),[1,1,1,3]);

% out.I = squeeze(II(:,prepad+1:end-postpad,:));
% out.If = squeeze(mean(I1(:,prepad+1:end-postpad,:)+I1(:,prepad+1:end-postpad,:),3));
out.retBins = squeeze(retSinW(:,prepad+1:end-postpad,:))*100/dzres*180/pi;
out.PABins = squeeze(PA(:,prepad+1:end-postpad,:,:));
out.dop = dop(:,prepad+1:end-postpad,:);
out.rcorr = rcorr(:,prepad+1:end-postpad,:);


