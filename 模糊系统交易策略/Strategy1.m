

[p0,dir0,nouse]=xlsread('hk00005.xls');



[N M]=size(p0);
for k=1:N
    
     dir{k}=dir0{k+1}; 
end;
i=1;
for k=1:N
   
        [d1 d2]=size(dir{i});
        if dir{i}(1:d2-2)=='2019-09-18'
            n2=i;
        end;
        if dir{i}(1:d2-2)=='2016-01-04'
            n1=i;
        end;
        i=i+1;
    end;
   

if n1<1
    n1=1;
end;

for k=n1-245:n2
    p(k)=p0(k);
end;

ns=0;pm=0;pv=0;p4=0;
for k=n1+1:n2
    r(k)=log(p(k)/p(k-1));
    if abs(r(k))<0.1
        ns=ns+1;
        pm=pm+abs(r(k));
        pv=pv+r(k)*r(k);
        p4=p4+r(k)^4;
    end;
end;
pm=pm/ns;
pv=pv/ns;
p4=p4/ns;

lmd=0.95;
c=0.01;
for k=n1:n1+3
    aa(:,:,k)=[0;0];
end;
P=[10 0;0 10];
for k=n1+3:n2-1
    if abs(r(k+1))<0.1
    pa=0;
    for i=1:3
        pa=pa+p(k-i+1)/3;
    end;
    x3=log(p(k)/pa);
    y1=meb(x3,0,c,2*c);
    y2=meb(x3,c,2*c,3*c);
    y3=meb(x3,2*c,3*c,3*c);
    y4=meb(x3,-2*c,-c,0);
    y5=meb(x3,-3*c,-2*c,-c);
    y6=meb(x3,-3*c,-3*c,-2*c);
    y7=meb(x3,-c,0,c);
    y=y1+y2+y3+y7;
    ed1=0;
    if y~=0
        ed1=(0.1*y1+0.2*y2+0.4*y3)/y;
    end;
    y=y4+y5+y6+y7;
    ed2=0;
    if y~=0
        ed2=(0.1*y4+0.2*y5+0.4*y6)/y;
    end;
    x=[ed1;ed2];
    
%    x=[abs(x13)+x13;abs(x13)-x13];
     %此部分为aa(:,:,k)的参数估计方法，策略确实有效，为了保障个人策略专利，此处设置为黑盒子，待真正入职后分享
    end;
    if abs(r(k+1))>=0.1
        aa(:,:,k)=aa(:,:,k-1);
    end;
end;

for k=n1:n2-1
    aaup(k)=aa(1,1,k);
    aadn(k)=aa(2,1,k);
    az(k)=0;
end;
for k=n1+3:n2-1
    a1t=0;
    a2t=0;
    for i=1:3
        a1t=a1t+aaup(k-i+1)/3;
        a2t=a2t+aadn(k-i+1)/3;
    end;
    aaup(k)=a1t;
    aadn(k)=a2t;
end;
for k=n1+3:n2-1        
    if aaup(k)>0
        aaupp(k)=aaup(k);
        aaupn(k)=0;
    end;
    if aaup(k)<=0
        aaupp(k)=0;
        aaupn(k)=aaup(k);
    end;
    if aadn(k)>0
        aadnp(k)=aadn(k);
        aadnn(k)=0;
    end;
    if aadn(k)<=0
        aadnp(k)=0;
        aadnn(k)=aadn(k);
    end;
end;

%n1=N-490-n0-246*0+9-9;
if n1<1
    n1=1;
end;
ho=0;nb=0;ns=0;
for k=n1+3:n2-1
    if aadnp(k)>0 & aaupn(k)==0 & ho==0
%    if aadnp(k)>=aadnp(k-1) & aadnp(k-1)>=aadnp(k-2) & aadnp(k-2)>0 & aaupn(k)==0 & aaupn(k-1)==0 & aaupn(k-2)==0 & ho==0
        nb=nb+1;
        buy(nb)=k-n1+2;
        ho=1;
    end;
    if aadnp(k)==0 & ho==1
        ns=ns+1;
        sel(ns)=k-n1+2;
        ho=0;
    end;
end;

if nb>ns
    sel(nb)=n2-n1+1;
end;
rall=1;
for i=1:nb
    rall=rall*(1+(p(sel(i)+n1-1)-p(buy(i)+n1-1))/p(buy(i)+n1-1));
end;
rall=(rall-1)*1000;
rall=round(rall)*0.1;
rhod=1000*(p(n2)-p(n1))/p(n1);
rhod=round(rhod)*0.1;

for i=1:nb
    rt=100*(p(sel(i)+n1-1)-p(buy(i)+n1-1))/p(buy(i)+n1-1);
    bsp{i,:}=[num2str(i) ' Buy: ' num2str(p(buy(i)+n1-1)) '; ' dir{buy(i)+n1-1} ' Sell: ' num2str(p(sel(i)+n1-1)) '; ' dir{sel(i)+n1-1} ' Return: '  num2str(rt)];
end;
bsp
clear bsp;


pmax=max(p(n1:n2));
pmin=min(p(n1:n2));


subplot(211);plot(p(n1:n2));hold on;
for i=1:nb
    line([buy(i) buy(i)],[pmin pmax],'Color','g');
end;
for i=1:nb
    line([sel(i) sel(i)],[pmin pmax],'Color','r');
    line([buy(i) sel(i)],[pmin pmin],'Color','g');
    line([buy(i) sel(i)],[pmax pmax],'Color','g');
end;
ylim([pmin-(pmax-pmin)/20 pmax+(pmax-pmin)/20]);
xlim([0 n2-n1+5]);
text(-30,pmin-(pmax-pmin)/6,[dir{n1}],'Fontsize',12);
text(n2-n1-40,pmin-(pmax-pmin)/6,[dir{n2}],'Fontsize',12);
hold off;
title(['HK00005' ' daily closing p(t), ' dir{n1} ' to ' dir{n2} ', green=buy, red=sell, return= ' num2str(rall) '%, buy&hold= ' num2str(rhod) '%'],'Fontsize',12);
subplot(212);
plot(aadnp(n1:n2-1),'Color','g','LineWidth',1.5);hold on;plot(aadnn(n1:n2-1),'Color','y','LineWidth',1.5);
plot(aaupp(n1:n2-1),'Color','y','LineWidth',1.5);plot(aaupn(n1:n2-1),'Color','r','LineWidth',1.5);
plot(az(n1:n2-1),'LineWidth',1.5);hold off;
title(['3-day moving average of -a6(t) and a7(t); green=big buyer, red=big seller, yellow=trend follower'],'Fontsize',12); 
ylim([-0.1 0.1]);
xlim([0 n2-n1+5]);
text(-30,-0.125,[dir{n1}],'Fontsize',12);
text(n2-n1-40,-0.125,[dir{n2}],'Fontsize',12);

%xlswrite('hknamesave',f1,'sheet1','A1');
%xlswrite('hknamesave',f2,'sheet1','B1');