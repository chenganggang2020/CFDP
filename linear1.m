%��ͼ����ֵ������0-1�ĺ���
function img =linear1(image)
img=double(image);
img=(img-min(min(img)))./(max(max(img))-min(min(img)));
end