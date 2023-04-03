%CFDP(Mean,dataflag,dc,K)
%密度聚类函数，Mean是各类别协方差均值元组，dataflag为分类好的各点类别标记
%dc截断距离,返回值是将超像素图像聚类后的结果，K是用来确定聚类中心的参数
function Re=CFDP(Mean,dataflag,dc,K)
global processbar
[M,N]=size(dataflag);%获取原始数据尺寸
Re=zeros(M,N,3);%为最终结果申请矩阵空间
[m,n]=size(Mean);%获取超像素聚类结果的均值矩阵的尺寸
local_density=zeros(m,n);%申请矩阵空间存储表征点‘局部密度’的矩阵
dis=zeros(m,n);%申请矩阵空间存储表征点'距离'的矩阵
discell=cell(m,n);%申请元组空间存储各点之间wishart距离的矩阵
re=zeros(m,n);%申请矩阵空间存储缓存矩阵，参与运算

waitbar(0.6,processbar,'正在计算,已完成60%,时间可能会稍长，请稍等..');

%% %循环遍历超像素点，求各点之间距离
for i=1:m
    for j=1:n
        for p=1:m
            for q=1:n
                discell{i,j}{p,q}=distWishart_Fast(Mean{i,j},Mean{p,q});
            end
        end
    end
end
waitbar(0.7,processbar,'正在计算,已完成70%');


%% %循环超像素点求各点局部密度
for i=1:m
    for j=1:n
        for p=1:m
            for q=1:n
                %当Dij<dc,即两点间距离小于截断距离，取1，否则取0
                if discell{i,j}{p,q}<dc
               local_density(i,j)=local_density(i,j)+ 1;
               %将取值全部累加，所得即当前点的局部密度
                end
            end
        end
    end
end

waitbar(0.8,processbar,'正在计算,已完成80%');

%% %计算各点表征‘距离’
Max=max(max(local_density));%找到局部密度最大点的密度值
%循环每个超像素点
for i=1:m
    for j=1:n
        %如果是局部密度最大点，则取点点之间最大距离为表征距离，否则在局部密度大于当前点的超像素点离找到距离最小的，作为表征距离
        if(local_density(i,j)==Max)
            dis(i,j)=max(max(cell2mat(discell{i,j})));
        else
            [x,y]=find(local_density>local_density(i,j));%查找所有局部密度值大于当前点的点索引
            LEN=length(x);%求局部密度大于当前点的数量
            %求最小距离值，作为点的表征‘距离’
            minvalue=discell{i,j}{x(1),y(1)};
            for k=2:LEN
                if discell{i,j}{x(k),y(k)}<minvalue
                    minvalue=discell{i,j}{x(k),y(k)};
                end
            end
            dis(i,j)=minvalue;
        end
    end
end
waitbar(0.9,processbar,'正在计算,已完成90%');

%% %选聚类中心，只有表征‘距离’和局部密度都大的才能选作聚类中心
%查找合适阈值来区分聚类中心的函数
thresholddis=find_threshold(dis,K);%设置一个截断表征距离来截取合适的聚类中心
% thresholddensity=find_threshold(local_density);%设置一个截断局部密度来截取合适的聚类中心
%找到符合要求的点的位置
[x,y]=find(dis>=thresholddis);
n1=length(x);
density=zeros(n1,1);
for i=1:n1
    density(i)=local_density(i);
end
copy_density=sort(density,'descend');
X=[x(find(density>=copy_density(K))),y(find(density>=copy_density(K)))];


%% 根据聚类中心将剩余点聚类
lenx=length(X);
for i=1:m
    for j=1:n
        mindis=discell{i,j}{X(1,1),X(1,2)};
        for len=1:lenx
            if discell{i,j}{X(len,1),X(len,2)}<mindis
                mindis=discell{i,j}{X(len,1),X(len,2)};%距离哪个聚类中心的距离小，就划分为哪个类
                re(i,j)=len-1;
            end
        end
    end
end
 temp=zeros(M,N);
for i=1:m
    for j=1:n
        temp(find(dataflag==(i-1)*n+j))=re(i,j);
    end
end
Re=cat(3,temp,(lenx+temp)/2,lenx-temp);
end