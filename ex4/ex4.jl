using Images, ImageFiltering, FileIO, TestImages, FFTW, InvertedIndices
tmppath = "/tmp/ProAnalImg"

img_path = "./DSC_7636_QVZzTDV.JPG"
#img_path = "./vinicius.jpg"
orig = load(img_path) 

img = Gray.(orig)
save("$tmppath/gray.png", img)

dims = size(img)
println("Dimensões originais: $dims")
println("")

img_array = channelview(img)

# 1) Transformada de Fourier 2D
fft_result = fft(img_array)
fft_shifted = fftshift(fft_result)

function fft_view(fft_shifted)
    fft_log = log.(1 .+ abs.(fft_shifted))
    fft_normalized = fft_log ./ maximum(fft_log) # map(clamp01nan, fft_log) não funciona for some reason
    return fft_normalized
end

fft_normalized = fft_view(fft_shifted)

save("$tmppath/fft-shifted.png", Gray.(fft_normalized))
save("$tmppath/fft.png", Gray.(fft_view(fft_result)))

println("Dimensões 1: ", size(Gray.(fft_normalized)))
println("")

# 2) Transformada inversa
fft_unshifted = ifftshift(fft_shifted) 
img_reconstructed = real.(ifft(fft_unshifted))
save("$tmppath/reconstructed.png", Gray.(img_reconstructed))

diff = img_array - img_reconstructed
diff_normalized = (diff .- minimum(diff))
diff_normalized = diff_normalized ./ maximum(diff_normalized)
diff_image = Gray.(diff_normalized)
save("$tmppath/difference.png", diff_image)

max_intensity = maximum(diff_normalized)
min_intensity = minimum(diff_normalized)

println("Exercício 2")
println("Máximo de intensidade: ", max_intensity)
println("Mínimo de intensidade: ", min_intensity)
println("Amplitude total: ", max_intensity - min_intensity)

println("Dimensões 2: ", size(img_reconstructed))
println("Dimensões 2 (diff): ", size(diff_image))
println("")

# 3) Transformada inversa sem reverter shift
img_reconstructed3 = real.(ifft(fft_shifted))

save("$tmppath/reconstructed3.png", map(clamp01nan, Gray.(img_reconstructed3)))

function printinfo(imgnum, num)
    minnum = minimum(imgnum)
    maxnum = maximum(imgnum)

    println("Exercício $num")
    println("Dimensões $num: ", size(imgnum))
    println("Máximo de intensidade: ", maxnum)
    println("Mínimo de intensidade: ", minnum)
    println("Amplitude total: ", maxnum - minnum)
    println("")
end

printinfo(img_reconstructed3, 3)

# 4) Zere o valor do pixel central do espectro de Fourier. Faça a transformada inversa.
center_y = size(fft_shifted, 1) ÷ 2 + 1  # Índice central na dimensão Y
center_x = size(fft_shifted, 2) ÷ 2 + 1  # Índice central na dimensão X

fft4 = copy(fft_shifted)
fft4[center_y, center_x] = 0
save("$tmppath/fft4.png", Gray.(fft_view(fft4)))

function mkresultimg(fft)
    fft_unshifted = ifftshift(fft)
    resultimg = real.(ifft(fft_unshifted))
    return resultimg
end

img4 = mkresultimg(fft4)
save("$tmppath/reconstructed_4.png", map(clamp01nan, img4))

printinfo(img4, 4)

# 5)  Zere todas as linhas ímpares do espectro de Fourier. Faça a transformada inversa
fft5 = copy(fft_shifted)
fft5[1:2:end, :] .= 0
save("$tmppath/fft5.png", Gray.(fft_view(fft5)))

img5 = mkresultimg(fft5)
save("$tmppath/reconstructed_5.png", map(clamp01nan, img5))

printinfo(img5, 5)

# 6) Igual 5, mas de 5 em 5
fft6 = copy(fft_shifted)
fft6[1:5:end, :] .= 0
save("$tmppath/fft6.png", Gray.(fft_view(fft6)))

img6 = mkresultimg(fft6)
save("$tmppath/reconstructed_6.png", map(clamp01nan, img6))

printinfo(img6, 6)

# 7) Remover linhas ímpares
fft7 = fft_shifted[InvertedIndex(1:2:end), :] # ou dava pra ter pego os pares...
save("$tmppath/fft7.png", Gray.(fft_view(fft7)))

img7 = mkresultimg(fft7)
save("$tmppath/reconstructed_7.png", map(clamp01nan, img7))

printinfo(img7, 7)

# 8) Remover colunas ímpares
fft8 = fft_shifted[:, InvertedIndex(1:2:end)]
save("$tmppath/fft8.png", Gray.(fft_view(fft8)))

img8 = mkresultimg(fft8)
save("$tmppath/reconstructed_8.png", map(clamp01nan, img8))

printinfo(img8, 8)

# 9) Remove linhas e cols ímpares
fft9 = fft_shifted[InvertedIndex(1:2:end), InvertedIndex(1:2:end)]
save("$tmppath/fft9.png", Gray.(fft_view(fft9)))

img9 = mkresultimg(fft9)
save("$tmppath/reconstructed_9.png", map(clamp01nan, img9))

printinfo(img9, 9)

# 10) Igual o 4, mas com 15% ao redor do pixel central
fft10 = copy(fft_shifted)
quinze = size(fft10, 2) * 0.15
startx = Int(floor(center_x - (quinze/2)))
endx = Int(ceil(center_x + (quinze/2)))
fft10[center_y, startx:endx] .= 0
save("$tmppath/fft10.png", Gray.(fft_view(fft10)))

img10 = mkresultimg(fft10)
save("$tmppath/reconstructed_10.png", map(clamp01nan, img10))

printinfo(img10, 10)

# 11) Igual 10 mas vertical tbm
fft11 = copy(fft_shifted)
quinze = size(fft11, 2) * 0.15
quinzey = size(fft11, 1) * 0.15
startx = Int(floor(center_x - (quinze/2)))
endx = Int(ceil(center_x + (quinze/2)))
starty = Int(floor(center_y - (quinzey/2)))
endy = Int(ceil(center_y + (quinzey/2)))
fft11[center_y, startx:endx] .= 0
fft11[starty:endy, center_x] .= 0
save("$tmppath/fft11.png", Gray.(fft_view(fft11)))

img11 = mkresultimg(fft11)
save("$tmppath/reconstructed_11.png", map(clamp01nan, img11))

printinfo(img11, 11)

# 12) Igual o 10, mas colocando linhas e colunas novas ao invés de tirar
fft12 = zeros(eltype(fft_shifted), size(fft_shifted).*2 .+ 1)
m, n = Int.(size(fft_shifted))
fft12[2:2:2m, 2:2:2n] = fft_shifted

save("$tmppath/fft12.png", Gray.(fft_view(fft12)))

img12 = mkresultimg(fft12)
save("$tmppath/reconstructed_12.png", map(clamp01nan, img12))

printinfo(img12, 12)

# 13) Igual o 12, mas colocando uns ao invés de zeros
fft13 = ones(eltype(fft_shifted), size(fft_shifted).*2 .+ 1)
m, n = Int.(size(fft_shifted))
fft13[2:2:2m, 2:2:2n] = fft_shifted

save("$tmppath/fft13.png", Gray.(fft_view(fft13)))

img13 = mkresultimg(fft13)
save("$tmppath/reconstructed_13.png", map(clamp01nan, img13))

printinfo(img13, 13)


# Abrir imagens
run(`xdg-open $tmppath/gray.png`)