%超像素分割函数，SLIC(data,pixelSize),data是协方差矩阵，pixelSize是指超像素的长和宽
function  Resultcell=SLIC(data,pixelSize)
global processbar 
TIMES=10;%循环次数
T11=cell2mat(data(1));
T12=cell2mat(data(2));
T13=cell2mat(data(3));
T22=cell2mat(data(4));
T23=cell2mat(data(5));
T33=cell2mat(data(6));
T21=conj(T12);  T31=conj(T13);  T32=conj(T23);
[M,N]=size(T11);
C=cell(M,N);
re=zeros(M,N,3);
T3mat = cat(3,T11,real(T12),imag(T12),real(T13),imag(T13),T22,real(T23),imag(T23),T33);     %g构造三维数组
Pauli_RGB = fPolRGBshow(T3mat,3); % 将极化数据表示为Pauli-RGB伪彩色图像
%获取协方差矩阵
for m=1:M
    for n=1:N
        Tem=[ T11(m,n) T12(m,n) T13(m,n);
            T21(m,n) T22(m,n) T23(m,n);
            T31(m,n) T32(m,n) T33(m,n)];
        C{m,n}=Tem;
    end
end
%要向下取整，向上取整会出现一系列问题
m=floor(M/pixelSize);%计算列方向超像素个数，向下取整
n=floor(N/pixelSize);%计算行方向超像素个数，向下取整
dataflag=-1*ones(M,N);%设置一个矩阵来标记原始数据中哪些是超像素中心,初始化标记为-1,数值为超像素中心序号
P=cell(m,n);%设置一个矩阵来标记超像素中心位置
datadis=1./zeros(M,N);%初始化距离无穷大
Mean=cell(m,n);%设置一个均值矩阵来存放超像素中心的协方差阵来作为整个超像素的协方差
TMean=cell(m,n);%临时均值矩阵来参与运算


waitbar(0.05,processbar,'正在计算,已完成5%,时间可能会稍长，请稍等..');
%% %初始化超像素中心,将超像素中心移到3*3梯度最小处
for i=1:m
    for j=1:n
        x=ceil((i-1)*pixelSize+0.5*pixelSize);
        y=ceil((j-1)*pixelSize+0.5*pixelSize);
        Graddata=1./zeros(M,N);
        for p=-1:1
            for q=-1:1
                if x+p<2||x+p>M-1||y+q<2||y+q>N-1
                    Graddata(x+p,y+q)=inf;
                else
                    Graddata(x+p,y+q)=distWishart_Fast(C{x+p-1,y+q-1},C{x+p+1,y+q-1})+2*distWishart_Fast(C{x+p-1,y+q},C{x+p+1,y+q}) +distWishart_Fast(C{x+p-1,y+q+1},C{x+p+1,y+q+1})+distWishart_Fast(C{x+p-1,y+q-1},C{x+p-1,y+q+1})+2*distWishart_Fast(C{x+p,y+q-1},C{x+p,y+q+1}) +distWishart_Fast(C{x+p+1,y+q-1},C{x+p+1,y+q+1});
                end
            end
        end
        %设置一个梯度矩阵
        T=[Graddata(x-1,y-1) Graddata(x-1,y) Graddata(x-1,y+1)
            Graddata(x,y-1) Graddata(x,y) Graddata(x,y+1)
            Graddata(x+1,y-1) Graddata(x+1,y) Graddata(x+1,y+1)];
        [dx,dy]=find(T==min(min(T)));%将超像素中心移到梯度最小处
        dataflag(x+dx-2,y+dy-2)=(i-1)*n+j;%给超像素中心赋值序号（第几个超像素中心）
        P{i,j}={x+dx-2,y+dy-2};%存储每个超像素中心的坐标位置
    end
end
for i=1:m
    for j=1:n
        Mean{i,j}=C{P{i,j}{1},P{i,j}{2}};%存储超像素中心协方差作为均值
    end
end
% count=0;
times=0;s=round(pixelSize/2);
%% %迭代更新超像素中心
while(times<=TIMES)%count<m*n&&
    %     thresold=0.01;残差阈值
    waitbar(0.2+0.3*times/TIMES,processbar,['正在计算,已完成' ,num2str(20+30*times/TIMES) ,'%']);
    for i=1:m
        for j=1:n
            x=P{i,j}{1};
            y=P{i,j}{2};
            %限制边界
            top=max(x-s,1);
            left=max(y-s,1);
            bottom=min(x+s,M);
            right=min(y+s,N);
            %循环扫描邻域2s*2s数据点
            for p=top:bottom
                for q=left:right
                    tdis=distWishart_Fast(C{p,q},Mean{i,j});%求取各个数据点到超像素中心的距离
                    if datadis(p,q)>tdis%求取最小距离的超像素中心
                        datadis(p,q)=tdis;
                        dataflag(p,q)=dataflag(x,y);%标记超像素标签
                    end
                end
            end
        end
    end
    %%    %对超像素中心进行循环，扫描计算矩阵均值
    %     count=0;
    for i=1:m
        for j=1:n
            Sum=0;%初始化临时变量
            x=P{i,j}{1};
            y=P{i,j}{2};
            %限制边界
            top=max(x-s,1);
            left=max(y-s,1);
            bottom=min(x+s,M);
            right=min(y+s,N);
            %循环扫描邻域2s*2s数据点
            temmat=[];
            for p=top:bottom
                for q=left:right
                    temmat=[temmat;p,q,dataflag(p,q)];
                end
            end
            LEN=length(find(temmat(:,3)==(i-1)*n+j));%求扫描区域内属于该超像素的个数
            if LEN==0%没有属于当前超像素中心的像素
                tx=floor((mode(temmat(:,3))-1)/n)+1;
                ty=mod(mode(temmat(:,3))-1,n)+1;
                TMean{i,j}=Mean{tx,ty};%将该超像素划归到周围最多的超像素类内
            else
                for len=1:LEN
                    Sum=Sum+C{temmat(len,1),temmat(len,2)};%将相同类别的数据协方差求和
                    re(temmat(len,1),temmat(len,2),:)=Pauli_RGB(P{i,j}{1},P{i,j}{2},:);%给相同类别的数据赋值超像素中心像素点的像素
                end
                TMean{i,j}=Sum/LEN;%求相同类别的协方差均值
            end
            %             if abs(sum(sum(Mean{i,j}-TMean{i,j})))<thresold%计算残差，确定循环是否进行
            %                 count=count+1;
            %             end
        end
    end
    Mean=TMean;
    times=times+1;
    
end
Resultcell={re,Mean,dataflag};
end