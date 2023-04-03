function DldFast=distWishart_Fast(Cm,T)
%求A,B两矩阵间的修正Wishart距离
% Dld=log(det(Cm)/det(T))+trace(inv(MtrxSqrt(Cm))*T*inv(MtrxSqrt(Cm)))-3; 
%AB间的Wishart距离

%d = det(A) 返回方阵 A 的行列式
%b = trace(A) 是矩阵 A 的对角线元素之和
%Y = inv(X) 计算方阵 X 的 逆矩阵
warning('off');
Cmi=inv(Cm);
C_V_temp=Cmi.';
C_V=C_V_temp(:);
T_V=T(:);
DldFast=log(det(Cm)/det(T))+C_V.'*T_V-3; 
