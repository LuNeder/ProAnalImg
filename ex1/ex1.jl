using Images, FileIO, ImageInTerminal, TestImages, Plots

# 1) Abre a imagem
img_path = "./DSC_7636_QVZzTDV.JPG"
#img_path = "./test-gradient.png"
#img_path = "./test-gradient2.jpg"
orig = load(img_path) # testimage("mandrill")

# 2) Transforma em grayscale
img = Gray.(orig)

# 1) Visualiza a imagem
tmppath = "/tmp/ProAnalImg/out.png"
save(tmppath, img)
run(`xdg-open $tmppath`)

# 3) Dimensões
dims = size(img)
println("Dimensões: $dims")

# 4) Maior e menor intensidade
chan = channelview(img)
max = maximum(chan)
min = minimum(chan)
println("Normalizada: Max: $max, Min: $min") # Escala normalizada (default da Images.jl)

# 4) Tenta inferir resolução da grayscale a partir do tipo dos pixels
resbits = sizeof(eltype(chan)) * 8 # Só funciona por ser 1 único canal (grayscale)
println("Res escala de cinza: $resbits bits") 
maxnn = max * (2^resbits) - 1
minnn = min * (2^resbits) - 1
println("Intensidades: Max: $maxnn, Min: $minnn")

# 5) Linha e perfil de intensidade
linha = Int(round(size(img, 1) * 0.75)) # 3/4 da imagem
println("Linha $linha")

# 5) Monta o "f(x)" da intensidade
vec = zeros((dims[2]))
for i in 1:dims[2]
    vec[i] = img[linha,i]
end
# Possível melhoria: vec[:] = img[linha,:]

# 5) Plot do gráfico
p = plot(vec,
    xlabel = "Coluna (px)",
    ylabel = "Intensidade (normalizada)",
    title = "Perfil de intensidade — linha $linha",
    legend = false)
graphpath = "/tmp/ProAnalImg/grafico.png"
savefig(p, graphpath)
run(`xdg-open $graphpath`)