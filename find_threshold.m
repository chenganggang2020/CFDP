function data=find_threshold(image,K)
[m,n]=size(image);
A=image(:);
%循环遍历所有数据
for x=1:m*n-1
  for y=1:m*n-x
      %冒泡排序
      if A(y)<A(y+1)
          temp=A(y);
          A(y)=A(y+1);
          A(y+1)=temp;
      end   
  end
end

data=A(10*K,1);%返回第10K大的数据
end

