function result=kmean(data ,k,threshold,type)%kmean�㷨��ͨ�����������ı����жϴ���Э�������ݻ���RGB����
%����������2������Э��������
global times processbar
times=10;%����ѭ������
    if nargin==2
            result=kmean1(data,k);
            %������4������RGB����
    elseif nargin==4
        result=kmean2(data ,k,threshold,type);
    end
end
function result=kmean1(data,k)
global times processbar
%kָҪ������ĸ�����dataΪ����Э�������
T11=cell2mat(data(1));
T12=cell2mat(data(2));
T13=cell2mat(data(3));
T22=cell2mat(data(4));
T23=cell2mat(data(5));
T33=cell2mat(data(6));
T21=conj(T12);  T31=conj(T13);  T32=conj(T23);   
[M,N]=size(T11);
result=zeros(M,N);%��ȡ���ݵĳߴ�
tdata=zeros(M,N);%���뻺����󣬲�������
C=cell(M,N);%����Ԫ��洢����Э������
Mean=cell(1,k);%����ռ�洢������ľ�ֵ����
tdis=zeros(k,1);%�������ռ�洢���������ÿ����͸�������ľ���
errorplace=[];%����һ���������λ�õľ���
%����ÿ�����Э������
for m=1:M
    for n=1:N
        Tem=[ T11(m,n) T12(m,n) T13(m,n);
            T21(m,n) T22(m,n) T23(m,n);
            T31(m,n) T32(m,n) T33(m,n)];
        C{m,n}=Tem;
    end
end
%����ֵ���󸳳�ֵ������㸳��ֵ��
for i=1:k
    Mean{1,i}=C{floor(i/k*m),round(N/2)};
end
flag=true;%��Ϊѭ���Ƿ�����ı�־
t=0;
while(flag==true&&t<=times)%tΪѭ������
        waitbar(t/times,processbar,['���ڼ���,�����' ,num2str(100*t/times) ,'%']);
    TMean=cell(1,k);
    %ѭ�������ͨ��
    for m=1:M
        for n=1:N
            for i=1:k
                %��ȡwishart����
              tdis(i,1)=distance(C{m,n},Mean{1,i},'wishartcov');
            end
            [~,index]=min(tdis);%���Ҿ�����С��һ���������
            %������Ÿ�ֵ����ǰ���ݵ�����λ��
            tdata(m,n)=index;
        end
    end
    %���¼��������ֵ�ĳ����ľ�ֵ
    errorplace=[];
    for i=1:k
        SMean=0;len=0;%�ÿ�����
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
function result=kmean2(data ,k,threshold,type)%kָҪ������ĸ�����thresholdΪĿ������ط����о�ֵ֮������ֵ�����жϴﵽ�ȶ�����ֵ
global times processbar
[m,n,bands]=size(data);%ͼ����������
result=zeros(m,n,bands);
data1=zeros(m,n,bands);%��־����洢�������ض�Ӧ�ĸ�����
data=double(data);
Min=min(min(min(data)));%������Сֵ
Max=max(max(max(data)));%�������ֵ
%����ͼ�񲨶����ñ�����������Ӧ���ڴ�ռ䷽�����
dis=zeros(bands,k);%������Ծ����ֵ�Ĳ�ֵ
Mean=zeros(bands,k);%����ľ�ֵ
TMean=zeros(bands,k);%�����ֵ����ʱ����
SMean=zeros(1,k);
for i=1:k%ѭ������
    for band=1:bands%ѭ������
    Mean(band,i)=i/k*(Max-Min)+Min;%ȡ��Ӧ
    SMean(1,i)=Mean(band,i);
    end
end
flag=0;t=0;%����ѭ�����������������������ĸ���
while(flag~=k&&t<times)%�������������˳�ѭ��
    waitbar(t/times,processbar,['���ڼ���,�����' ,num2str(100*t/times) ,'%']);
    sdis=zeros(k,1);%��ֵ�ľ���ֵ֮��
    STMean=zeros(1,k);
    for i=1:m
        for j=1:n
            for s=1:k%�Ծ����������ѭ��
                 sdis(s,1)=0;
                for band=1:bands%�Բ���������ѭ��
                    dis(band,s)=distance(data(i,j,band),Mean(band,s),type);%����ÿ�����ضԸ�������ľ���
                    sdis(s,1)=sdis(s,1)+dis(band,s);
                end
                 [~,index]=min(sdis);%������С��һ��
                for band=1:bands%�Բ��ν���ѭ��
                data1(i,j,band)=index;%��ÿ�����ε����ݵı�־����ָ����ֵ
                end
            end
        end
    end
    flag=0;
    for i=1:k%ѭ���ж����þ����ֵ�Ƿ�����Ҫ��
        for band=1:bands%ѭ������
            tdata=data(:,:,band);%��ȡָ����������
            tdata1=data1(:,:,band);%��ȡָ�����α�־��������
            TMean(band,i)=mean(tdata(find(tdata1==i)));%���ұ�־�����е���ָ��ֵ���������ݲ����Ӧԭ���ݵľ�ֵ
            STMean(1,i)=STMean(1,i)+TMean(band,i);
        end
    end
    STMean(isnan(STMean))=0;
    for i=1:k
        if abs(STMean(1,i)-SMean(1,i))<=threshold%�жϵ�ǰ�����ֵ�Ƿ��֮ǰ��ֵ�Ƿ�����С����ֵ
            flag=flag+1;%��¼���������ľ���ĸ���
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


