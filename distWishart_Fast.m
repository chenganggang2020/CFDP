function DldFast=distWishart_Fast(Cm,T)
%��A,B������������Wishart����
% Dld=log(det(Cm)/det(T))+trace(inv(MtrxSqrt(Cm))*T*inv(MtrxSqrt(Cm)))-3; 
%AB���Wishart����

%d = det(A) ���ط��� A ������ʽ
%b = trace(A) �Ǿ��� A �ĶԽ���Ԫ��֮��
%Y = inv(X) ���㷽�� X �� �����
warning('off');
Cmi=inv(Cm);
C_V_temp=Cmi.';
C_V=C_V_temp(:);
T_V=T(:);
DldFast=log(det(Cm)/det(T))+C_V.'*T_V-3; 
