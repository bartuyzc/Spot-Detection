clear;
clc;
close all;

% Dataset yolu seçilir
dataset_path = 'D:\Python Projects\image_processing\dataset';

file_list = dir(fullfile(dataset_path, '*.jpg'));

file_len = numel(file_list);

for i = 1:file_len
    
    file_name = file_list(i).name;
    file_path = fullfile(dataset_path, file_name);
    
    % RGB ve gri görüntüler elde ediliyor
    rgb_img = imread(file_path);
    gray_img = rgb2gray(rgb_img);

    % RGB ve gri görüntüleri bastır
%    figure 
%    subplot(1,2,1),imshow(rgb_img),title("rgb image"),impixelinfo
%    subplot(1,2,2),imshow(gray_img),title("gray image"),impixelinfo

    % RGB kanalları ayır
    r = rgb_img(:,:,1);
    g = rgb_img(:,:,2);
    b = rgb_img(:,:,3);

    % Kanalları bastır
%     figure
%     subplot(3,1,1),imshow(r),title("red channel"),impixelinfo
%     subplot(3,1,2),imshow(g),title("green channel"),impixelinfo
%     subplot(3,1,3),imshow(b),title("blue channel"),impixelinfo

    % x1 ve x2 değerlerini bulma
    x1 = r - 0.5 * g;

    % x2 görüntüsünü prewitt ile bulma kararı aldım
    blurred_gray_img = imgaussfilt(gray_img, 7);
    x2 = edge(blurred_gray_img, "Prewitt");

%     figure
%     subplot(1,2,1),imshow(x2),title("x2"),impixelinfo
%     subplot(1,2,2),imshow(x1),title("x1"),impixelinfo

    % x1 scale edip otsu eşikleme
    min_x1 = min(min(x1));
    max_x1 = max(max(x1));

    scaled_x1 = ((x1 - min_x1) / (max_x1 - min_x1));

    level = graythresh(scaled_x1);
    x1_otsu = imcomplement(imbinarize(scaled_x1, level));


    % y değerini bulma
    y = 0.5 * x1_otsu + 0.5 * x2;

    % Hole filling yötemini uygula
    hole_filled = imfill(y, "holes");
    spot_img = hole_filled - y;

    % Leke görüntüsüne median filter uygulayarak gürültüleri yok etme
    spot_img = medfilt2(spot_img);

    % Sonuçları bastır
%     figure
%     subplot(2,3,1),imshow(x1),title("x1"),impixelinfo
%     subplot(2,3,2),imshow(x1_otsu),title("x1 otsu"),impixelinfo
%     subplot(2,3,3),imshow(x2),title("x2"),impixelinfo
%     subplot(2,3,4),imshow(y),title("y"),impixelinfo
%     subplot(2,3,5),imshow(hole_filled),title("hole filled"),impixelinfo
%     subplot(2,3,6),imshow(spot_img),title("spot img"),impixelinfo

    % Homomorphic filtreleme mavi kanal için
    blue_ch = b;

    blue_ch = im2double(blue_ch);
    blue_ch = log(1 + blue_ch);

    M = 2*size(blue_ch,1) + 1;
    N = 2*size(blue_ch,1) + 1;

    sigma = 10;

    [X, Y] = meshgrid(1:N,1:M);
    centerX = ceil(N/2); 
    centerY = ceil(M/2); 
    gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
    H = exp(-gaussianNumerator./(2*sigma.^2));
    H = 1 - H; 

    H = fftshift(H);

    If = fft2(blue_ch, M, N);
    Iout = real(ifft2(H.*If));
    Iout = Iout(1:size(blue_ch,1),1:size(blue_ch,2));

    homomorphic_filt_img = exp(Iout) - 1;

    % Filtreden geçmiş mavi kanalı otsu eşikle
    lvl = graythresh(homomorphic_filt_img);
    spot_condition = imcomplement(imbinarize(homomorphic_filt_img, lvl));

%     figure 
%     subplot(1,3,1),imshow(b),title("blue channel"),impixelinfo
%     subplot(1,3,2),imshow(homomorphic_filt_img),title("homomorphic filtered image"),impixelinfo
%     subplot(1,3,3),imshow(spot_condition),title("spot condition image"),impixelinfo

    % Leke görüntüsü ve leke şartı görüntüsü noktasal çarpılır
    spots = spot_img .* spot_condition;

%     figure,imshow(spots),title("detected spots"),impixelinfo

    % Lekeleri kırmızıya boyama
    spots_temp = spots;

    m = size(spots_temp,1);
    n = size(spots_temp,2);

    out_img = rgb_img;

    for i=1:m
        for j=1:n
            if (spots_temp(i,j) > lvl)
                out_img(i,j,[1,2,3]) = [255,0,0];
            end
        end
    end

    figure
    subplot(1,2,1),imshow(rgb_img),title("input image")
    subplot(1,2,2),imshow(out_img),title("output image")
    pause(1); 
end

