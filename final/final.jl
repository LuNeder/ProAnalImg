using Images, ImageFiltering, FileIO, TestImages, FFTW, InvertedIndices
tmppath = "/tmp/ProAnalImg"

# Imagem
img_path = "./DSC_7636_QVZzTDV.JPG"
orig = load(img_path) 

# Cinza
img = Gray.(orig)
save("$tmppath/gray.png", img)

dims = size(img)
println("Dimensões originais: $dims")

img_array = channelview(img)

# Transformada de Fourier 2D original (p/ comparação)

function fft_view(fft_shifted)
    fft_log = log.(1 .+ abs.(fft_shifted))
    fft_normalized = fft_log ./ maximum(fft_log)
    return fft_normalized
end

fft_shifted = fftshift(fft(img_array))

fft_normalized = fft_view(fft_shifted)

save("$tmppath/fft-original.png", Gray.(fft_normalized))

# Colocar ruído
    # Listras verticais
    # Correlação espacial
    # Sistemático
    # Homoscedástico
    # Não depende do nível do sinal

H, W = dims
x = range(0, W - 1, length=W)

freqs = [30, 80, 150]
amps  = [0.25, 0.15, 0.10] # Mais forte
#amps  = [0.1, 0.05, 0.03] 

noise = zeros(H, W)
for (f, a) in zip(freqs, amps)
    phase = 2π * rand()
    noise .+= a .* sin.(2π * f .* x ./ W .+ phase)'
end

noisy = clamp.(img .+ noise, 0, 1)

save("$tmppath/noisy.png", map(clamp01nan, noisy))

# FFT da ruidosa
fft_noisy = fftshift(fft(img_array))
save("$tmppath/fft-noisy.png", Gray.(fft_view(fft_noisy)))


# Remoção de ruído por filtro notch no espectro de Fourier
    # Domínio da frequência

fft10 = copy(fft_noisy)
quinze = size(fft10, 2) * 0.15

center_y = size(fft_noisy, 1) ÷ 2 + 1  # Índice central na dimensão Y
center_x = size(fft_noisy, 2) ÷ 2 + 1  # Índice central na dimensão X

function mkresultimg(fft)
    fft_unshifted = ifftshift(fft)
    resultimg = real.(abs.(ifft(fft_unshifted)))
    return resultimg
end

function fourier_vert_clean(middle_free, grossura)
    range_y = center_y
    if grossura != 1
        range_y = Int(floor(center_y - (grossura/2))):Int(ceil(center_y + (grossura/2)))
    end

    fft10[range_y, Int((center_x + (middle_free/2))):end] .= 0
    fft10[range_y, 1:Int((center_x - (middle_free/2)))] .= 0

    img10 = mkresultimg(fft10)

    return img10, fft10
end

img80, fft80 = fourier_vert_clean(80, 1)
save("$tmppath/fft80.png", Gray.(fft_view(fft80)))
save("$tmppath/reconstructed_final80.png", map(clamp01nan, img80))

img40, fft40 = fourier_vert_clean(40, 1)
save("$tmppath/fft40.png", Gray.(fft_view(fft40)))
save("$tmppath/reconstructed_final40.png", map(clamp01nan, img40))

img16, fft16 = fourier_vert_clean(10, 1)
save("$tmppath/fft16.png", Gray.(fft_view(fft16)))
save("$tmppath/reconstructed_final16.png", map(clamp01nan, img16))

# Abrir imagens
run(`xdg-open $tmppath/gray.png`)