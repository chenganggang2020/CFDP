function re=binaryzation(data)%二值化函数
[m,n]=size(data);%获取目标区域尺寸
%通过改变初始值和目标赋值来改变最终二值化颜色
remat=data(:);
% re=ones(m,n);%设置初始值为1
re=zeros(m,n);%设置初始值为0
MODE=mode(remat);%查找目标区域内的众数
% re(find(data==MODE))=0;%设置占多数区域目标值为0
re(find(data==MODE))=1;%设置占多数区域目标值为1
end