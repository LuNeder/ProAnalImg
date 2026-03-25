using Images, FileIO, Plots, StatsBase

# Abre a imagem
img_path = "./DSC_7636_QVZzTDV.JPG"
orig = load(img_path)

# Transforma em grayscale
img = Gray.(orig)

# Visualiza a imagem
tmppath = "/tmp/ProAnalImg/out.png"
save(tmppath, img)
run(`xdg-open $tmppath`)

# Dimensões
dims = size(img)
println("Dimensões: $dims")

# Converte para float32 e achata em vetor 1D
dados = float32.(channelview(img))
vetor_dados = vec(dados)

# Calcula o histograma manualmente para normalização
counts, bins = histcounts(vetor_dados, 256)

# Normaliza as contagens para o intervalo [0, 1]
counts_normalized = counts / maximum(counts)

# Cria o histograma normalizado
p = plot(bins[1:end-1], counts_normalized, 
         seriestype = :bar,
         bar_width = step(bins),
         fillalpha = 0.6,
         color = :gray,
         xlabel = "Intensidade (0=preto, 1=branco)",
         ylabel = "Frequência Normalizada (0 a 1)",
         title = "Histograma Normalizado de Intensidade",
         legend = false,
         ylims = (0, 1))  # Garante que o eixo Y vá de 0 a 1

graphpath = "/tmp/ProAnalImg/grafico.png"
savefig(p, graphpath)
run(`xdg-open $graphpath`)
