clc
close all
clear all
 % incoh_image Incoherent Imaging Example
imagefiles=dir('*.png');
currentfilename = imagefiles(2).name; %choosing image from folder
image = imread(currentfilename);
A=image(467:707,1205:1445,:);
A_R=A(:,:,1);A_G=A(:,:,2);A_B=A(:,:,3); % Separating the three color channels
B_R=A_R;B_G=A_G;B_B=A_B;
% A=A(1:250-1,1:250-1);
% figure(1)
% imshow(A)
%%
%  A=imread('USAF1951B250','png'); %read image file
 [M,N]=size(A_R); %get image sample size
 A_R=flipud(A_R); A_G=flipud(A_G);A_B=flipud(A_B);%reverse row order
 Ig_R=single(A_R);Ig_G=single(A_G);Ig_B=single(A_B); %integer to floating
 Ig_R=Ig_R/max(max(Ig_R));Ig_G=Ig_G/max(max(Ig_G));Ig_B=Ig_B/max(max(Ig_B)); %normalize ideal image

 L=0.3e-3; %image plane side length (m)
 du=L/M; %sample interval (m)
 u=-L/2:du:L/2-du; v=u;

 lambda_R=570e-9; lambda_G=540e-9;lambda_B=430e-9;%color wavelength peak
 k_R=2*pi/lambda_R;k_G=2*pi/lambda_G;k_B=2*pi/lambda_B;
 wxp=6*6.25e-3; %exit pupil radius
 zxp=125e-3; %exit pupil distance
 f0_R=wxp/(lambda_R*zxp);f0_G=wxp/(lambda_G*zxp);f0_B=wxp/(lambda_B*zxp); %coherent cutoff

 fu=-1/(2*du):1/L:1/(2*du)-(1/L); %freq coords
 fv=fu;
 [Fu,Fv]=meshgrid(fu,fv);
 H_R=circ(sqrt(Fu.^2+Fv.^2)/f0_R);H_G=circ(sqrt(Fu.^2+Fv.^2)/f0_G);H_B=circ(sqrt(Fu.^2+Fv.^2)/f0_B);% Diffraction-limited OTF
 OTF_R=ifft2(abs(fft2(fftshift(H_R))).^2);OTF_G=ifft2(abs(fft2(fftshift(H_G))).^2);OTF_B=ifft2(abs(fft2(fftshift(H_B))).^2);
 OTF_R=abs(OTF_R/OTF_R(1,1));OTF_G=abs(OTF_G/OTF_G(1,1));OTF_B=abs(OTF_B/OTF_B(1,1));
 
%  figure(2) %check OTF
%  surf(fu,fv,fftshift(OTF_G))
%  camlight left; lighting phong
%  colormap('gray')
%  shading interp
%  ylabel('fu (cyc/m)'); xlabel('fv (cyc/m)');
%  
 Cn2=[0;1.106423892e-09;3.870276556e-09;8.066036506e-09;1.673561774e-08;2.899464133e-08;3.020441049e-08;3.347325251e-08];
 fun=@(z,L)((L-z)/L).^(5/3);
 Int=integral(@(z)fun(z,37e-2),0,37e-2);% spherical wave contribution
 OTFF_le_R=zeros(M,N,length(Cn2));OTFF_le_G=zeros(M,N,length(Cn2));OTFF_le_B=zeros(M,N,length(Cn2));
 for p=1:length(Cn2)
 r_0_R=0.185*((4*pi^2)/(k_R^2*Int*Cn2(p)))^(3/5);
 r_0_G=0.185*((4*pi^2)/(k_G^2*Int*Cn2(p)))^(3/5); %seeing cell size (Fried Parameter) for each channel
 r_0_B=0.185*((4*pi^2)/(k_B^2*Int*Cn2(p)))^(3/5);
 H_le_R=exp(-1/2*6.88*(lambda_R*L*(Fu.^2+Fv.^2).^(1/2)/r_0_R).^(5/3));OTF_le_R=ifft2(abs(fft2(fftshift(H_le_R))).^2);
 H_le_G=exp(-1/2*6.88*(lambda_G*L*(Fu.^2+Fv.^2).^(1/2)/r_0_G).^(5/3));OTF_le_G=ifft2(abs(fft2(fftshift(H_le_G))).^2);% Long exposure OTF
 H_le_B=exp(-1/2*6.88*(lambda_B*L*(Fu.^2+Fv.^2).^(1/2)/r_0_B).^(5/3));OTF_le_B=ifft2(abs(fft2(fftshift(H_le_B))).^2);
 OTFF_le_R(:,:,p)=abs(OTF_le_R/OTF_le_R(1,1));
 OTFF_le_G(:,:,p)=abs(OTF_le_G/OTF_le_G(1,1));
 OTFF_le_B(:,:,p)=abs(OTF_le_B/OTF_le_B(1,1));
 
%  figure(3) %check OTF_le
%  surf(fu,fv,fftshift(OTFF_le_G(:,:,p)))
%  drawnow;
%  camlight left; lighting phong
%  colormap('gray')
%  shading interp
%  ylabel('fu (cyc/m)'); xlabel('fv (cyc/m)');
 end
 
 Gg_R=fft2(fftshift(Ig_R)); Gg_G=fft2(fftshift(Ig_G));Gg_B=fft2(fftshift(Ig_B));%convolution
 Gi_R=zeros(M,N,length(Cn2));Gi_G=zeros(M,N,length(Cn2));Gi_B=zeros(M,N,length(Cn2));
 Ii_R=zeros(M,N,length(Cn2));Ii_G=zeros(M,N,length(Cn2));Ii_B=zeros(M,N,length(Cn2));
 for p=1:length(Cn2)
 Gi_R(:,:,p)=Gg_R.*OTFF_le_R(:,:,p).*OTF_R;Gi_G(:,:,p)=Gg_G.*OTFF_le_G(:,:,p).*OTF_G;Gi_B(:,:,p)=Gg_B.*OTFF_le_B(:,:,p).*OTF_B;
 Ii_R(:,:,p)=ifftshift(ifft2(Gi_R(:,:,p)));Ii_G(:,:,p)=ifftshift(ifft2(Gi_G(:,:,p)));Ii_B(:,:,p)=ifftshift(ifft2(Gi_B(:,:,p)));
 %remove residual imag parts, values < 0
 Ii_R(:,:,p)=real(Ii_R(:,:,p)); mask=Ii_R(:,:,p)>=0; Ii_R(:,:,p)=mask.*Ii_R(:,:,p);
 Ii_G(:,:,p)=real(Ii_G(:,:,p)); mask=Ii_G(:,:,p)>=0; Ii_G(:,:,p)=mask.*Ii_G(:,:,p);
 Ii_B(:,:,p)=real(Ii_B(:,:,p)); mask=Ii_B(:,:,p)>=0; Ii_B(:,:,p)=mask.*Ii_B(:,:,p);
 
 cat1=cat(3,Ii_R(:,:,p),Ii_G(:,:,p));
 Ii_RGB=cat(3,cat1,Ii_B(:,:,p));
%  save(strcat('Ii_RGB-',num2str(p)),'Ii_RGB');

%  figure(4) %image result
 imagesc(u,v,nthroot(Ii_RGB,2));
 p
 drawnow;
 colormap('gray'); xlabel('u (m)'); ylabel('v (m)');
 axis square;
 axis xy;
 end
 
%  figure(4) %image result
%  imagesc(u,v,nthroot(Ii_RGB,2));
%  colormap('gray'); xlabel('u (m)'); ylabel('v (m)');
%  axis square;
%  axis xy;

%  figure(4) %horizontal image slice
%  vvalue=0.2e-4; %select row (y value)
%  vindex=round(vvalue/du+(M/2+1)); %convert row index
%  plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
%  xlabel('u (m)'); ylabel('Irradiance');