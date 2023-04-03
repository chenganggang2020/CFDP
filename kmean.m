function result=kmean(data ,k,threshold,type)%kmean算法，通过参数数量改变来判断处理协方差数据还是RGB数据
%参数个数是2，处理协方差数据
global times processbar
times=10;%设置循环次数
    if nargin==2
            result=kmean1(data,k);
            %参数是4，处理RGB数据
    elseif nargin==4
        result=kmean2(data ,k,threshold,type);
    end
end
function result=kmean1(data,k)
global times processbar
%k指要分种类的个数，data为数据协方差矩阵
T11=cell2mat(data(1));
T12=cell2mat(data(2));
T13=cell2mat(data(3));
T22=cell2mat(data(4));
T23=cell2mat(data(5));
T33=cell2mat(data(6));
T21=conj(T12);  T31=conj(T13);  T32=conj(T23);   
[M,N]=size(T11);
result=zeros(M,N);%获取数据的尺寸
tdata=zeros(M,N);%申请缓存矩阵，参与运算
C=cell(M,N);%申请元组存储各点协方差阵
Mean=cell(1,k);%申请空间存储各聚类的均值矩阵
tdis=zeros(k,1);%申请矩阵空间存储计算过程中每个点和各个聚类的距离
errorplace=[];%设置一个保存出错位置的矩阵
%构建每个点的协方差阵
for m=1:M
    for n=1:N
        Tem=[ T11(m,n) T12(m,n) T13(m,n);
            T21(m,n) T22(m,n) T23(m,n);
            T31(m,n) T32(m,n) T33(m,n)];
        C{m,n}=Tem;
    end
end
%给均值矩阵赋初值，（随便赋的值）
for i=1:k
    Mean{1,i}=C{floor(i/k*m),round(N/2)};
end
flag=true;%作为循环是否继续的标志
t=0;
while(flag==true&&t<=times)%t为循环次数
        waitbar(t/times,processbar,['正在计算,已完成' ,num2str(100*t/times) ,'%']);
    TMean=cell(1,k);
    %循环各点各通道
    for m=1:M
        for n=1:N
            for i=1:k
                %求取wishart距离
              tdis(i,1)=distance(C{m,n},Mean{1,i},'wishartcov');
            end
            [~,index]=min(tdis);%查找距离最小的一个类别的序号
            %将此序号赋值给当前数据点所在位置
            tdata(m,n)=index;
        end
    end
    %重新计算所划分到某个类的均值
    errorplace=[];
    for i=1:k
        SMean=0;len=0;%置空数量
        for m=1:M
            for n=1:N
                if(tdata(m,n)==i)
                    SMean=SMean+C{m,n};
                    len=len+1;
                end
            end
        end
        if len==0
            errorplace=[errorplace,i];
        else
        TMean{1,i}=SMean/len;
        end
    end
    if isempty(errorplace)==0
        for i=1:length(errorplace)
            TMean{1,errorplace(i)}=[];
        end
    end
    Mean={};
    Mean=TMean;
    t=t+1;
    [~,k]=size(Mean);
end
disp(k)
result=cat(3,tdata,255-tdata*255/k,tdata);
end
function result=kmean2(data ,k,threshold,type)%k指要分种类的个数，threshold为目标聚类重分类中均值之间差的阈值，及判断达到稳定的阈值
global times processbar
[m,n,bands]=size(data);%图像数据行列
result=zeros(m,n,bands);
data1=zeros(m,n,bands);%标志矩阵存储数据像素对应哪个聚类
data=double(data);
Min=min(min(min(data)));%数据最小值
Max=max(max(max(data)));%数据最大值
%根据图像波段设置变量，申请相应的内存空间方便计算
dis=zeros(bands,k);%数据相对聚类均值的差值
Mean=zeros(bands,k);%聚类的均值
TMean=zeros(bands,k);%聚类均值的临时变量
SMean=zeros(1,k);
for i=1:k%循环聚类
    for band=1:bands%循环波段
    Mean(band,i)=i/k*(Max-Min)+Min;%取对应
    SMean(1,i)=Mean(band,i);
    end
end
flag=0;t=0;%设置循环条件，及聚类满足条件的个数
while(flag~=k&&t<times)%当满足条件则退出循环
    waitbar(t/times,processbar,['正在计算,已完成' ,num2str(100*t/times) ,'%']);
    sdis=zeros(k,1);%差值的绝对值之和
    STMean=zeros(1,k);
    for i=1:m
        for j=1:n
            for s=1:k%对聚类个数进行循环
                 sdis(s,1)=0;
                for band=1:bands%对波段数进行循环
                    dis(band,s)=distance(data(i,j,band),Mean(band,s),type);%计算每个像素对各个聚类的距离
                    sdis(s,1)=sdis(s,1)+dis(band,s);
                end
                 [~,index]=min(sdis);%查找最小的一个
                for band=1:bands%对波段进行循环
                data1(i,j,band)=index;%给每个波段的数据的标志矩阵赋指定的值
                end
            end
        end
    end
    flag=0;
    for i=1:k%循环判断所得聚类均值是否满足要求
        for band=1:bands%循环波段
            tdata=data(:,:,band);%获取指定波段数据
            tdata1=data1(:,:,band);%获取指定波段标志矩阵数据
            TMean(band,i)=mean(tdata(find(tdata1==i)));%查找标志矩阵中等于指定值的所有数据并求对应原数据的均值
            STMean(1,i)=STMean(1,i)+TMean(band,i);
        end
    end
    STMean(isnan(STMean))=0;
    for i=1:k
        if abs(STMean(1,i)-SMean(1,i))<=threshold%判断当前聚类均值是否和之前均值是否满足小于阈值
            flag=flag+1;%记录满足条件的聚类的个数
        end
    end
   TMean(isnan(TMean))=Mean(isnan(TMean));
            Mean=TMean;
            t=t+1;
end
tdata=zeros(m,n);
for band=1:bands
    for i=1:k
        tdata(data1(:,:,band)==i)=Mean(band,i);
    end
%     result(:,:,band)=255-band*tdata/bands;
end
result=cat(3,tdata,255-tdata*255/k,tdata);
end
function re=distance(x,y,type)
    switch type
        case 'wishart'
            re=distWishart_Fast(x,y);
        case 'ABS'
            re=abs(x-y);
        case'wishartcov'
            re=distWishart_Fast(x,y);
        case'Euclidean'
            re=(x-y)^2;
    end
end


