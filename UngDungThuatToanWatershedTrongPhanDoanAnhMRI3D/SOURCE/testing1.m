
folder = 'MRI0003/phase2';
files = dir(fullfile(pwd,folder, '*.dcm'));
array3d = zeros(230, 320, length(files));
disp(length(files));
for x = 1 : length(files)
    slice = dicomread(fullfile(pwd, folder, files(x).name));
    array3d(:,:,x) = mat2gray(slice);  
    % mat2gray: covert ma tr?n A thành ?nh xám có c??ng ?? 0 và 1, 
    % trong ?ó: amin, amax là nh?ng giá tr? ???c p?c sang 0 và 1, 
    % vales < amin : 0 & ng??c l?i
end



% lam min anh

arraySmt = zeros(230, 320, length(files));

for i = 1 : length(files)
    Gmag = medfilt2(array3d(:,:,i), [5 5]);
    arraySmt(:,:, i) = Gmag;
end
arrayGmag = zeros(230, 320, length(files));
eGmag = zeros(230, 320, length(files));
for i = 1 : length(files)
    Gmag1 = arraySmt(:,:,i) - imfilter(arraySmt(:,:,i),fspecial('log',[3 3],0.5), 'replicate');
    eGmag(:,:, i) = Gmag1;
    sb = imfilter(arraySmt, fspecial('sobel'), 'replicate');
    sbSmt = imfilter(sb, ones(3)/9);
    gsSmt = imadd(eGmag, sbSmt);
    addSmt = imadd(arraySmt,gsSmt);
    descBr = 2 .* addSmt .^1;
    %gmag = imfilter(descBr, fspecial('sobel'), 'replicate');
    arrayGmag = descBr;
    %arrayGmag = gmag;
end

% gradient

arrayGra = zeros(230, 320, length(files));
arraygra = zeros(230, 320, length(files));
for i = 1 : length(files)
    Gmag2 = imgradient(arrayGmag(:,:,i));
    arraygra(:,:,i) = Gmag2;
    gmag2 = 2 .* arraygra .^ 0.9;
    arrayGra = gmag2;
end


%-----marker internal object ---------------------------------------------------------------------
    
    
se = strel('disk', 43);
Io = imopen(array3d, se);

    
Ie = imerode(array3d, se);
Iobr = imreconstruct(Ie, array3d);


%--------------------------------------------------------------------------
Ioc = imclose(Io,se); % dilation

%--------------------------------------------------------------------------
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr); 


for i = 1 : length(files)
    temp = wiener2(Iobrcbr(:, :, i), [3 3]);
    Iobrcbr(:,:, i) = temp;
end

%--------------------------------------------------------------------------
fgm = imregionalmax(Iobrcbr);


%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
se2 = strel(ones(3));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 150, 4); % remove all pixel 0
I3 = array3d;
%--------------------------------------------------------------------------
fgm = imregionalmax(fgm4);
I3(fgm4) = 255;


%--------------------------------------------------------------------------
%STEP 5: Mark the background objects.
sum1 = 0;
for i = 1 : length(files)
    sum1 = sum1 + graythresh(Iobrcbr(:, :, i)); 
end

avgGrayThresh = sum1/length(files);
bw = imbinarize(I3, avgGrayThresh);


%--------------------------------------------------------------------------

D = bwdist(bw);
%tmp = imhmin(D,4);
DL = watershed(D, 4); %kq
bgm = DL == 0;


gmag2 = imimposemin(arrayGmag, bgm | fgm4);

% step G
L2 = watershed(gmag2); % tra ve pixel phan vung, pixcel 0 la ridge line

f2 = arrayGmag;
f2(imdilate(L2 == 0, ones(3, 3)) | bgm | fgm4) = 255;

labels = imdilate(L2 == 0,ones(3,3)) + 2*bgm + 3*fgm4;

figure, imshow3D(arrayGra);
figure, imshow3D(gmag2);
figure, imshow3D(labels);




    

   
    
     

