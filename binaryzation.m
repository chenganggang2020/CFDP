function re=binaryzation(data)%��ֵ������
[m,n]=size(data);%��ȡĿ������ߴ�
%ͨ���ı��ʼֵ��Ŀ�긳ֵ���ı����ն�ֵ����ɫ
remat=data(:);
% re=ones(m,n);%���ó�ʼֵΪ1
re=zeros(m,n);%���ó�ʼֵΪ0
MODE=mode(remat);%����Ŀ�������ڵ�����
% re(find(data==MODE))=0;%����ռ��������Ŀ��ֵΪ0
re(find(data==MODE))=1;%����ռ��������Ŀ��ֵΪ1
end