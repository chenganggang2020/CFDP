%�����طָ����SLIC(data,pixelSize),data��Э�������pixelSize��ָ�����صĳ��Ϳ�
function  Resultcell=SLIC(data,pixelSize)
global processbar 
TIMES=10;%ѭ������
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
T3mat = cat(3,T11,real(T12),imag(T12),real(T13),imag(T13),T22,real(T23),imag(T23),T33);     %g������ά����
Pauli_RGB = fPolRGBshow(T3mat,3); % ���������ݱ�ʾΪPauli-RGBα��ɫͼ��
%��ȡЭ�������
for m=1:M
    for n=1:N
        Tem=[ T11(m,n) T12(m,n) T13(m,n);
            T21(m,n) T22(m,n) T23(m,n);
            T31(m,n) T32(m,n) T33(m,n)];
        C{m,n}=Tem;
    end
end
%Ҫ����ȡ��������ȡ�������һϵ������
m=floor(M/pixelSize);%�����з������ظ���������ȡ��
n=floor(N/pixelSize);%�����з������ظ���������ȡ��
dataflag=-1*ones(M,N);%����һ�����������ԭʼ��������Щ�ǳ���������,��ʼ�����Ϊ-1,��ֵΪ�������������
P=cell(m,n);%����һ����������ǳ���������λ��
datadis=1./zeros(M,N);%��ʼ�����������
Mean=cell(m,n);%����һ����ֵ��������ų��������ĵ�Э����������Ϊ���������ص�Э����
TMean=cell(m,n);%��ʱ��ֵ��������������


waitbar(0.05,processbar,'���ڼ���,�����5%,ʱ����ܻ��Գ������Ե�..');
%% %��ʼ������������,�������������Ƶ�3*3�ݶ���С��
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
        %����һ���ݶȾ���
        T=[Graddata(x-1,y-1) Graddata(x-1,y) Graddata(x-1,y+1)
            Graddata(x,y-1) Graddata(x,y) Graddata(x,y+1)
            Graddata(x+1,y-1) Graddata(x+1,y) Graddata(x+1,y+1)];
        [dx,dy]=find(T==min(min(T)));%�������������Ƶ��ݶ���С��
        dataflag(x+dx-2,y+dy-2)=(i-1)*n+j;%�����������ĸ�ֵ��ţ��ڼ������������ģ�
        P{i,j}={x+dx-2,y+dy-2};%�洢ÿ�����������ĵ�����λ��
    end
end
for i=1:m
    for j=1:n
        Mean{i,j}=C{P{i,j}{1},P{i,j}{2}};%�洢����������Э������Ϊ��ֵ
    end
end
% count=0;
times=0;s=round(pixelSize/2);
%% %�������³���������
while(times<=TIMES)%count<m*n&&
    %     thresold=0.01;�в���ֵ
    waitbar(0.2+0.3*times/TIMES,processbar,['���ڼ���,�����' ,num2str(20+30*times/TIMES) ,'%']);
    for i=1:m
        for j=1:n
            x=P{i,j}{1};
            y=P{i,j}{2};
            %���Ʊ߽�
            top=max(x-s,1);
            left=max(y-s,1);
            bottom=min(x+s,M);
            right=min(y+s,N);
            %ѭ��ɨ������2s*2s���ݵ�
            for p=top:bottom
                for q=left:right
                    tdis=distWishart_Fast(C{p,q},Mean{i,j});%��ȡ�������ݵ㵽���������ĵľ���
                    if datadis(p,q)>tdis%��ȡ��С����ĳ���������
                        datadis(p,q)=tdis;
                        dataflag(p,q)=dataflag(x,y);%��ǳ����ر�ǩ
                    end
                end
            end
        end
    end
    %%    %�Գ��������Ľ���ѭ����ɨ���������ֵ
    %     count=0;
    for i=1:m
        for j=1:n
            Sum=0;%��ʼ����ʱ����
            x=P{i,j}{1};
            y=P{i,j}{2};
            %���Ʊ߽�
            top=max(x-s,1);
            left=max(y-s,1);
            bottom=min(x+s,M);
            right=min(y+s,N);
            %ѭ��ɨ������2s*2s���ݵ�
            temmat=[];
            for p=top:bottom
                for q=left:right
                    temmat=[temmat;p,q,dataflag(p,q)];
                end
            end
            LEN=length(find(temmat(:,3)==(i-1)*n+j));%��ɨ�����������ڸó����صĸ���
            if LEN==0%û�����ڵ�ǰ���������ĵ�����
                tx=floor((mode(temmat(:,3))-1)/n)+1;
                ty=mod(mode(temmat(:,3))-1,n)+1;
                TMean{i,j}=Mean{tx,ty};%���ó����ػ��鵽��Χ���ĳ���������
            else
                for len=1:LEN
                    Sum=Sum+C{temmat(len,1),temmat(len,2)};%����ͬ��������Э�������
                    re(temmat(len,1),temmat(len,2),:)=Pauli_RGB(P{i,j}{1},P{i,j}{2},:);%����ͬ�������ݸ�ֵ�������������ص������
                end
                TMean{i,j}=Sum/LEN;%����ͬ����Э�����ֵ
            end
            %             if abs(sum(sum(Mean{i,j}-TMean{i,j})))<thresold%����вȷ��ѭ���Ƿ����
            %                 count=count+1;
            %             end
        end
    end
    Mean=TMean;
    times=times+1;
    
end
Resultcell={re,Mean,dataflag};
end