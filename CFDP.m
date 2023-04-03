%CFDP(Mean,dataflag,dc,K)
%�ܶȾ��ຯ����Mean�Ǹ����Э�����ֵԪ�飬dataflagΪ����õĸ��������
%dc�ضϾ���,����ֵ�ǽ�������ͼ������Ľ����K������ȷ���������ĵĲ���
function Re=CFDP(Mean,dataflag,dc,K)
global processbar
[M,N]=size(dataflag);%��ȡԭʼ���ݳߴ�
Re=zeros(M,N,3);%Ϊ���ս���������ռ�
[m,n]=size(Mean);%��ȡ�����ؾ������ľ�ֵ����ĳߴ�
local_density=zeros(m,n);%�������ռ�洢�����㡮�ֲ��ܶȡ��ľ���
dis=zeros(m,n);%�������ռ�洢������'����'�ľ���
discell=cell(m,n);%����Ԫ��ռ�洢����֮��wishart����ľ���
re=zeros(m,n);%�������ռ�洢������󣬲�������

waitbar(0.6,processbar,'���ڼ���,�����60%,ʱ����ܻ��Գ������Ե�..');

%% %ѭ�����������ص㣬�����֮�����
for i=1:m
    for j=1:n
        for p=1:m
            for q=1:n
                discell{i,j}{p,q}=distWishart_Fast(Mean{i,j},Mean{p,q});
            end
        end
    end
end
waitbar(0.7,processbar,'���ڼ���,�����70%');


%% %ѭ�������ص������ֲ��ܶ�
for i=1:m
    for j=1:n
        for p=1:m
            for q=1:n
                %��Dij<dc,����������С�ڽضϾ��룬ȡ1������ȡ0
                if discell{i,j}{p,q}<dc
               local_density(i,j)=local_density(i,j)+ 1;
               %��ȡֵȫ���ۼӣ����ü���ǰ��ľֲ��ܶ�
                end
            end
        end
    end
end

waitbar(0.8,processbar,'���ڼ���,�����80%');

%% %���������������롯
Max=max(max(local_density));%�ҵ��ֲ��ܶ�������ܶ�ֵ
%ѭ��ÿ�������ص�
for i=1:m
    for j=1:n
        %����Ǿֲ��ܶ����㣬��ȡ���֮��������Ϊ�������룬�����ھֲ��ܶȴ��ڵ�ǰ��ĳ����ص����ҵ�������С�ģ���Ϊ��������
        if(local_density(i,j)==Max)
            dis(i,j)=max(max(cell2mat(discell{i,j})));
        else
            [x,y]=find(local_density>local_density(i,j));%�������оֲ��ܶ�ֵ���ڵ�ǰ��ĵ�����
            LEN=length(x);%��ֲ��ܶȴ��ڵ�ǰ�������
            %����С����ֵ����Ϊ��ı��������롯
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
waitbar(0.9,processbar,'���ڼ���,�����90%');

%% %ѡ�������ģ�ֻ�б��������롯�;ֲ��ܶȶ���Ĳ���ѡ����������
%���Һ�����ֵ�����־������ĵĺ���
thresholddis=find_threshold(dis,K);%����һ���ضϱ�����������ȡ���ʵľ�������
% thresholddensity=find_threshold(local_density);%����һ���ضϾֲ��ܶ�����ȡ���ʵľ�������
%�ҵ�����Ҫ��ĵ��λ��
[x,y]=find(dis>=thresholddis);
n1=length(x);
density=zeros(n1,1);
for i=1:n1
    density(i)=local_density(i);
end
copy_density=sort(density,'descend');
X=[x(find(density>=copy_density(K))),y(find(density>=copy_density(K)))];


%% ���ݾ������Ľ�ʣ������
lenx=length(X);
for i=1:m
    for j=1:n
        mindis=discell{i,j}{X(1,1),X(1,2)};
        for len=1:lenx
            if discell{i,j}{X(len,1),X(len,2)}<mindis
                mindis=discell{i,j}{X(len,1),X(len,2)};%�����ĸ��������ĵľ���С���ͻ���Ϊ�ĸ���
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