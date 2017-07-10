tic
clear; clc ;close all;
C = 299792458;                                      % propagation speed
f0 = 9.6e9;                                         % carrier frequency��0.5GHz
lambda = C/f0;                                      % 0.0313�� 3cm
B = 0.66e9;                                          % �źŴ���660MHz
deltf = 3e6;                                       % ��ʱ��Ƶ�ʲ������<= c/(2Wr*cos(dep))
N = B/deltf;%=220

f = (-N/2:N/2)*deltf+f0;                       % ��ʱ��Ƶ��
f = f.';
omega = 2*pi*f;
M = length(f);%=221                                  % ��ʱ��Ƶ�ʲ�������

% Zc = 50;    %  Զ��ʱ�ĸ߶�
 Zc = 2.7;    %  ����ʱ�ĸ߶�
el = 20;  
Rc = Zc/sind(el);%=7.8943 ��Ŀ���������ĵ��б��
Rg = Zc/tand(el);%=7.4182 ��Ŀ���������ĵ�ĵؾ�
R0 = 1;          %����������ΰ뾶

N = 900;                                       % ��λ�����delttheta <=c/fmax/2/Wx ȡ0.1��
theta = (1:N)*(90/N);                          % aspect angle
% Target = [0 0 0 1;0.1 0.08 0 1;-0.1 0.12 0 1;0.08 -0.12 0 1;-0.12 -0.1 0 1];     %  0.1 0.1 0 1; 0.1 -0.15 0 1
% Target = [0 0 0 1;0.5 0.4 -0.2 1; -0.5 0.6 0.2 1;0.4 -0.6 0.2 1;-0.6  -0.5 -0.2  1;];
% Target = [0 0 0 1;0.7 0 0 1;-0.7 0 0 1;0 -0.7 0 1;0 0.7 0 1;0 0 -0.2 1; 0 0 0.2 1];
Pradar = [Rg*cosd(theta); Rg*sind(theta); Zc*ones(1,N)];  % �״����ʵ�ռ�λ������
Target = [0 0 0 1]; %ǰ3����Ŀ������꣬���һ���Ǻ���ɢ��ϵ��       
%% ������Ŀ��
% load('D:\Works\MATLAB\run\CSAR_L1\imag_platform');
% x = -R0:0.01:R0-0.01;
% y = -R0:0.01:R0-0.01;
% [X Y] = meshgrid(x,y);
% load('D:\Works\MATLAB\run\CSAR_L1\imag_platform.mat');
% [row,col,val] = find(imag_platform);
% Target = [x(col)' y(row)' zeros(1,length(row))' val];
%%  ====
sr = zeros(M,N);     % �ز�����
for k=1:size(Target,1)%TargetΪ1*4��������size��Target��1��ָTarget����������ȻΪ1 ��size��Target��2��ָTarget��������Ϊ4
                      %kѭ��ΪĿ��ĸ�����ÿ��һ��Ŀ��
    temp = Pradar - Target(k,1:3).'*ones(1,N);
    Rt = sqrt(sum(temp.^2));    
    phase = -4*pi/C*f*(Rt-Rc);                  % matrix of M*N
    sr = sr+Target(k,4)*exp(1i*phase);          % ������ʱ��ƥ���˲���Ľ����ź�Sm(��,��)
end
sr = sr.*(hamming(M,'periodic')*ones(1,N));              % �������԰����ƣ���Ƶ��Ӵ�����-21.7dB
% sr = sr.*(hanning(M)*ones(1,N));              % -18.7dB
% sr = sr.*(kaiser(M,pi)*ones(1,N));              % -30.3dB
% sr = sr.*(chebwin(M,100)*ones(1,N));           % -18.07dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.phdata = sr;                                  % input data
% data.R0 = rc(1:size(data.phdata,2));             % input data
data.R0 = Rc*ones(1,size(data.phdata,2));
data.Nfft = 2^nextpow2(10*length(f));        %��Ƶ�ʲ�������Mȡ���ϵ�2�������ݣ�����m=9�����data.Nfft=16               
data.deltaF = mean(diff(f));              %��Ƶ�ʼ��ȡ��ֵ����mean(diff([2,4,6,8,10]))=2
data.minF = min(f)*ones(1,size(data.phdata,2));    %1*N������ÿ��Ϊmin(f)
data.AntX = Pradar(1,:);                            % input data
data.AntY = Pradar(2,:);                            % input data
data.AntZ = Pradar(3,:);                            % input data
data.xtemp = (-R0 :0.005:R0-0.005);          %total 400 point
data.ytemp = -R0 :0.005:R0-0.005;
data.ztemp = 0;
% ���ɸ߶������ɢ����ʱȡ��������
% data.xtemp = 0; data.ytemp = 0; data.ztemp = -R0:0.05:R0;
[data.x_mat,data.y_mat,data.z_mat] = meshgrid(data.xtemp,data.ytemp,data.ztemp);
data = mybpbasic(data);
fxy =  data.im_final;
gxy = abs(fxy)/max(abs(fxy(:)));
toc

h = figure('Name','reconstructed target function');
colormap(1-gray(256))
image(data.xtemp,data.ytemp,256*gxy.^3);
ha = get(h,'CurrentAxes');
set(ha,'YDir','normal','fontsize',16);
axis equal;
axis tight;
xlabel('������x��m��','fontsize',16)
ylabel('��λ��y��m��','fontsize',16)

% gxz = reshape(fxy(1,:,:),[201 201]);
% gxz = gxz.';
% h = figure('Name','�����򡪸߶����ά��Ƭ');
% % image(data.xtemp,data.ytemp,20*log10(gxy)+60);
% colormap(1-gray(16))
% image(data.xtemp,data.ztemp,40*abs(gxz)/max(abs(gxz(:))));
% % image(40*abs(gxz)/max(abs(gxz(:))));
% ha = get(h,'CurrentAxes');
% set(ha,'YDir','normal','fontsize',16);
% axis equal;
% axis tight;
% xlabel('������x��m��','fontsize',16)
% ylabel('�߶���z��m��','fontsize',16)

% Ϊ��׼ȷ��ʾ����ɢ�������棬����������յĳ��������˶�ά��ֵ
xtemp1 = linspace(-R0 ,R0 ,4096);
ytemp1 = linspace(-R0 ,R0 ,4096);
[Xtemp,Ytemp] = meshgrid(xtemp1,ytemp1);
[X,Y] = meshgrid(data.xtemp,data.ytemp);
fxyi = interp2(X,Y,fxy,Xtemp,Ytemp,'spline');
gxyi = abs(fxyi)/max(abs(fxyi(:)));
dis=20*log10(gxyi);
maxdata=max(dis(:));
G=dis-maxdata;
G(G<-30)=-30;
h = figure('Name','reconstructed target function');
imagesc(xtemp1,ytemp1,G);
% colormap(1-gray(128))
% image(xtemp1 ,ytemp1 ,256*gxyi.^2);
ha = get(h,'CurrentAxes');
set(ha,'YDir','normal','fontsize',16);
axis equal;
axis tight;
xlabel('������x��m��','fontsize',16)
ylabel('��λ��y��m��','fontsize',16)
% 
[iy,ix] = find(gxyi == max(gxyi(:)));
% 
h = figure('Name','1D PSF filtered ');
plot(xtemp1,20*log10(gxyi(iy,:)),'b','linewidth',1.5);
% plot(data.xtemp,20*log10(abs(fxy(101,:))/max(abs(fxy(:)))),'.');
ha = get(h,'CurrentAxes');
set(ha,'YDir','normal','fontsize',16);
axis tight;
axis([-0.1 0.1 -30 0])
xlabel('������x��m��','fontsize',16)
ylabel('��һ�����ȣ�dB��','fontsize',16)

% [CC,I]=max(gxy(:));
% [iy,ix]=ind2sub([4096,4096],I);
% gx0 = 20*log10(gxy(:,ix));
% for n = 1:length(gx0)-1
%     if (gx0(n)<=-3)&&(gx0(n+1)>=-3), gl = n; end
%     if (gx0(n)>=-3)&&(gx0(n+1)<=-3), gh = n; end
% end
% rey = (gh-gl+1)*2/4096;
% xinterp = interp1(gx0(2049:end),xtemp1(2049:end),-3); % ��ֵ�ҵ�-3dB��λ��
% h = figure('Name','2D image z=-2m');
% image(xtemp1,ytemp1,20*log10(gxy)+50);
% ha = get(h,'CurrentAxes');
% set(ha,'YDir','normal','fontsize',16);
% axis equal;
% axis tight;
% xlabel('������x��m��','fontsize',20)
% ylabel('��λ��y��m��','fontsize',20)

% h = figure('Name','1D Psf');
% plot(xtemp1,20*log10(gxy(:,2049)),'linewidth',1.5);
% ha = get(h,'CurrentAxes');
% set(ha,'YDir','normal','fontsize',16);
% axis tight;
% xlabel('������x��m��','fontsize',20)
% ylabel('��һ�����ȣ�dB��','fontsize',20)

% gxy1 = gxy(:,2048);
% h = figure('Name','1D Psf along z direction');
% plot(data.ztemp,20*log10(gxy(:)),'LineWidth',1.5);
% ha = get(h,'CurrentAxes');
% set(ha,'YDir','normal','fontsize',16);
% axis tight;
% xlabel('�߶���z��m��','fontsize',20)
% ylabel('��һ�����ȣ�dB��','fontsize',20)
% gx0 = reshape(20*log10(gxy),1,[]);
% for n = 1:length(gx0)-1
%     if (gx0(n)<=-3)&&(gx0(n+1)>=-3), gl = n; end
%     if (gx0(n)>=-3)&&(gx0(n+1)<=-3), gh = n; end
% end
% rez = (gh-gl+1)*2/4096;
% zinterp = interp1(gx0(100:end),data.ztemp(100:end),-3);
% title('�߶����һά��Ŀ����ɢ����')

% h = figure('Name','2D image z=0m');
% image(data.xtemp,data.ytemp,20*log10(abs(fxy)/max(abs(fxy(:))))+40);
% ha = get(h,'CurrentAxes');
% set(ha,'YDir','normal','fontsize',16);
% axis equal;
% axis tight;
% xlabel('������x��m��','fontsize',20)
% ylabel('��λ��y��m��','fontsize',20)
%% ������άͼ��
gxy(gxy(:)<0.05) = nan;
data.x_mat(isnan(gxy))=[];
data.y_mat(isnan(gxy))=[];
data.z_mat(isnan(gxy))=[];
gxy(isnan(gxy))=[];
h = figure('Name','3D image');
colormap(1-gray);
scatter3(data.x_mat(:), data.y_mat(:), data.z_mat(:),gxy(:),'filled','p')
% scatter3(data.x_mat(:), data.y_mat(:), data.z_mat(:),20*log10(gxy(:))+40,'filled')
% scatter3(Target(:,1),Target(:,2),Target(:,3),'filled')
axis equal
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5])
xlabel('������x��m��','fontsize',16,'rotation',8)
ylabel('��λ��y��m��','fontsize',16,'rotation',-20)
zlabel('�߶���z��m��','fontsize',16)

