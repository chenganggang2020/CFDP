function recell=crop_T(T,position)
%提取指定区域协方差的函数

%获取需要提取区域的边界，即范围
left=round(position(1));
top=round(position(2));
right=round(position(3)+position(1));
bottom=round(position(4)+position(2));
%获取协方差矩阵（原始数据）的数量，即通道数
len=length(T);
recell=cell(1,len);%结果元组申请空间
t=zeros(bottom-top+1,right-left+1);%缓存矩阵申请空间
%循环遍历各个通道，分别提取相应区域数据
for i=1:len
    tem=cell2mat(T(i));
    t(:,:)=tem(top:bottom,left:right);
    recell{1,i}=t;
end
end