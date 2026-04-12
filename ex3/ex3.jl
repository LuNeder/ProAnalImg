using Images, ImageFiltering, FileIO, ImageInTerminal, TestImages, Plots, StatsBase
gr(size = (1072, 3584)) # resolução para a plot
tmppath = "/tmp/ProAnalImg"

img_path = "./DSC_7636_QVZzTDV.JPG"
orig = load(img_path) 


# 1) Gera a Imagem
size = 512 # Tamanho da imagem

img = ones(Float64, size, size) # Criar imagem base

sqr = div(size, 2) # Tamaho de cada quadrado

# Quadrado superior esquerdo (preto)
img[1:sqr, 1:sqr] .= 0.0
# Quadrado inferior direito (preto)
img[sqr+1:end, sqr+1:end] .= 0.0

#img = Gray.(orig) # Imagem Portugal

# Salvar a imagem
save("$tmppath/quadrados.png", img)


# 2) Passa-baixa 15x15
function kernelones(dim)
    kernel =  fill(1/(dim^2), dim, dim)
    return kernel
end
kernel2 = kernelones(15)

doisa = map(clamp01nan, imfilter(img, kernel2, Fill(0))) #2a
doisb = map(clamp01nan, imfilter(img, kernel2, "reflect")) #2b
doisc = map(clamp01nan, imfilter(img, kernel2, "replicate")) #2c
doisd = map(clamp01nan, imfilter(img, kernel2, "circular")) #2d

if doisc == doisb
    println("2c = 2b")
end
if doisd == doisa
    println("2d = 2a")
end

save("$tmppath/doisA.png", doisa)
save("$tmppath/doisB.png", doisb)
save("$tmppath/doisC.png", doisc)
save("$tmppath/doisD.png", doisd)


# 3) Kerneis tamanhos distintos
cinco = map(clamp01nan, imfilter(img, kernelones(5)))
quinze = map(clamp01nan, imfilter(img, kernelones(15)))
trinta = map(clamp01nan, imfilter(img, kernelones(33)))
save("$tmppath/cinco.png", cinco)
save("$tmppath/quinze.png", quinze)
save("$tmppath/trinta.png", trinta)


# 4) Kerneis Gaussianos
function kernelgauss(dim, σ)
    kernel =  Kernel.gaussian((σ, σ), (dim, dim))
    return kernel
end

for dim in [5, 15, 33]
    for sigma in [1, 10, 20]
        quatro = map(clamp01nan, imfilter(img, kernelgauss(dim, sigma)))
        save("$tmppath/gauss-$dim-$sigma.png", quatro)
    end
end


# 5) Kernel passa-alta, detectar bordas
function kernelalta(dim)
    half = floor(Int, dim/2)
    kernel = [            -1 .* ones(Int, half, dim)
              -1 .* ones(Int, 1, half) (8) -1 .* ones(Int, 1, half)
                          -1 .* ones(Int, half, dim)               ]
    return kernel
end

edging = map(clamp01nan, imfilter(img, kernelalta(3)))
save("$tmppath/alta.png", edging)

altasum = map(clamp01nan, img + edging)
save("$tmppath/altaSUM.png", altasum)

run(`xdg-open $tmppath/quadrados.png`)