function recell=crop_T(T,position)
%��ȡָ������Э����ĺ���

%��ȡ��Ҫ��ȡ����ı߽磬����Χ
left=round(position(1));
top=round(position(2));
right=round(position(3)+position(1));
bottom=round(position(4)+position(2));
%��ȡЭ�������ԭʼ���ݣ�����������ͨ����
len=length(T);
recell=cell(1,len);%���Ԫ������ռ�
t=zeros(bottom-top+1,right-left+1);%�����������ռ�
%ѭ����������ͨ�����ֱ���ȡ��Ӧ��������
for i=1:len
    tem=cell2mat(T(i));
    t(:,:)=tem(top:bottom,left:right);
    recell{1,i}=t;
end
end