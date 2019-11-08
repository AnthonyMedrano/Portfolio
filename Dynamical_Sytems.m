%% initialize variables
close all;
clc;
clear all;

ti = 0.00;
tf = 100;
dt = 0.1; % time step for interpolation

omega1=16;      % size of the domain
omega2=16i;
R=1;            % effective radius of the swimmer
U=1;            % self-propelled speed
sigma=R^2*U;    % strength of dipole
mu=0.5;         % translational mobility coefficient
dis=2*R;        % excluded area
f0=1;

% rotational mobility coefficient
nu1=0;          % jeffery orbit     
nu2=1;

N = 10;    % number of swimmers

% modula of Weierstrass Elliptic function
q=exp(pi*1i*omega2/omega1);
tol=1e-16;
eta1=WeierstrassEta(omega1,omega2,tol);
e1=WeierstrassP(omega1,omega1,omega2,eta1,q);
e2=WeierstrassP(omega2,omega1,omega2,eta1,q);
e3=WeierstrassP(-(omega1+omega2),omega1,omega2,eta1,q);
g2=-4*(e1*e2+e3*e2+e1*e3);
g3=4*e1*e2*e3;

v=N*pi*R^2/(omega1*abs(omega2)*4);  % area fraction covered by swimmers

zd=zeros(N,1);

rng('shuffle'); % shuffling random number generator
n=1;
% homogenous distribution of swimmers in space
while n<=N
    zd(n)=-omega1+2*omega1*rand-omega2+2*omega2*rand;
    diff=abs(zd(n)-zd);
    diff(n)=[];
    if (any(diff<dis)==0)
        n=n+1;
    end
end

alpha=2*pi*rand(N,1);   % uniform orientation distribution of swimmers

x0 = [zd; alpha];
odeopts = odeset('Events',@(t,x) EventFunction(t, x, omega1, omega2) ,'RelTol', 1e-8, 'AbsTol', 1e-8, 'Stats', 'on');
tn=[];
zn=[];
an=[];

%% solve ODE's

tic
while ti~=tf
    sol = ode45(@(t,x) odeDipolePolar(t, x, sigma, f0, dis, N, U, mu, nu1, nu2, omega1, omega2, g2, g3), [ti tf], x0, odeopts);
    tout=ti:dt:sol.x(end);
    solsav=deval(sol,tout);
    ztemp=sol.y(1:N,end);
    atemp=sol.y(N+1:2*N,end);
    ti=sol.x(end)

    index1=find(real(ztemp)<-omega1);
    if isempty(index1)==0
        ztemp(index1)=ztemp(index1)+2*omega1;
    end
    index2=find(real(ztemp)>omega1);
    if isempty(index2)==0
        ztemp(index2)=ztemp(index2)-2*omega1;
    end
    index3=find(imag(ztemp)<-imag(omega2));
    if isempty(index3)==0
        ztemp(index3)=ztemp(index3)+2*omega2;
    end
    index4=find(imag(ztemp)>imag(omega2));
    if isempty(index4)==0
        ztemp(index4)=ztemp(index4)-2*omega2;
    end
    
    tn=[tn tout(1:end-1)];
    zn=[zn solsav(1:N,1:end-1)];
    an=[an solsav(N+1:2*N,1:end-1)];
        
    x0=[ztemp;atemp];
end
timespent=toc
tn=[tn, tf];
zn=[zn, solsav(1:N,end)];
an=[an, solsav(N+1:2*N,end)];

clear sol;
clear solsav;
clear ztemp;
clear atemp;
timespent=toc;
save('Event_N100_L=32_nu1=0_nu2=1_T100.mat');

%% animation
window = [-omega1 omega1 -imag(omega2) imag(omega2)]; 
skip1=10;
el=1;

tstart=1;
tend=length(tn);
figure(1);
axis(window);

for i=tstart:skip1:tend
    clf;
    hold on;
    px=cos(an(:,i));
    py=sin(an(:,i));
    xd=real(zn(:,i));
    yd=imag(zn(:,i));

    headx = xd+px*el;
    heady = yd+py*el;
    tailx = xd+px*el*0.9;
    taily = yd+py*el*0.9;

    dx = pi/100;

    for j = 1:length(xd)
        angle = atan(py(j)/px(j));
        if py(j) > 1 && px(j) < 1
            angle = angle + pi/2;
        elseif py(j) < 1 && px(j) < 1
            angle = angle + pi/2;
        end
        x1 = cos(angle:dx:angle+pi)+xd(j);
        y1 = sin(angle:dx:angle+pi)+yd(j);
        x2 = cos(angle+pi:dx:angle+2*pi)+xd(j);
        y2 = sin(angle+pi:dx:angle+2*pi)+yd(j);
        fill(x1,y1,['r','b'])
    end
    
    myarrow([tailx,taily],[headx,heady],'Length',10,'BaseAngle',90,'TipAngle',2.5);

    axis equal;
    axis(window);
    set(gcf,'color','w');
    box on;

    set(gca,'XTick',-omega1:omega1/2:omega1);
    set(gca,'YTick',-imag(omega2):imag(omega2)/2:imag(omega2));
    
    drawnow;
end