function data=find_threshold(image,K)
[m,n]=size(image);
A=image(:);
%ѭ��������������
for x=1:m*n-1
  for y=1:m*n-x
      %ð������
      if A(y)<A(y+1)
          temp=A(y);
          A(y)=A(y+1);
          A(y+1)=temp;
      end   
  end
end

data=A(10*K,1);%���ص�10K�������
end

