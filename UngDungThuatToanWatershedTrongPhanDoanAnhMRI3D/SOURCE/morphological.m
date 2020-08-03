se90 = strel('line', 3, 90);
se0 = strel('line', 3, 10);

%BWsdil = zeros(230, 320, length(files));

BWsdil = imdilate(fgm4, [se90 se0]);
figure(1), imshow3D(fgm4);
figure(2), imshow3D(BWsdil);

Bwdfill = imfill(BWsdil, 'holes');

%figure, imshow3D(Bwdfill);

Bwnobord = imclearborder(Bwdfill, 8);
figure(3), imshow3D(Bwnobord);

seD = strel('diamond', 1);
Bwfinal = imerode(Bwnobord, seD);
Bwfinal = imerode(Bwfinal, seD);

figure(4), imshow3D(Bwfinal), title('Final image');

Bwoutline = bwperim(Bwfinal);
Segout = array3d;
Segout(Bwoutline) = 0;
figure(5), imshow3D(Segout), title('Final image');
