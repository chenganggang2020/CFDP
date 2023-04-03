%将图像数值拉伸至0-1的函数
function img =linear1(image)
img=double(image);
img=(img-min(min(img)))./(max(max(img))-min(min(img)));
end