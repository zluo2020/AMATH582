function [shadow_adapthisteq] = adaptiveHistEqual(X)
    shadow_lab = rgb2lab(X);
    
    max_luminosity = 100;
    L = shadow_lab(:,:,1)/max_luminosity;

    shadow_adapthisteq = shadow_lab;
    shadow_adapthisteq(:,:,1) = adapthisteq(L)*max_luminosity;
    shadow_adapthisteq = lab2rgb(shadow_adapthisteq);
    
    %figure
    %montage({X, shadow_imadjust,shadow_histeq,shadow_adapthisteq},'Size',[2 2])
    %title("Original Image and Enhanced Images using imadjust, histeq, and adapthisteq")

end
