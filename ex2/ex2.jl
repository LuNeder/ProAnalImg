using Images, FileIO, ImageInTerminal, TestImages, Plots, StatsBase
gr(size = (1072, 3584)) # resolução para a plot

# Abre a imagem
img_path = "./DSC_7636_QVZzTDV.JPG"
#img_path = "./test-gradient.png"
#img_path = "./test-gradient2.jpg"
orig = load(img_path) # testimage("mandrill")

# Transforma em grayscale
img = Gray.(orig)

# Visualiza a imagem
tmppath = "/tmp/ProAnalImg"
save("$tmppath/gray.png", img)
#run(`xdg-open $tmppath/gray.png`)

# Dimensões
dims = size(img)
println("Dimensões: $dims")

# Maior e menor intensidade
chan = channelview(img)
max = maximum(chan)
min = minimum(chan)
println("Max e min intensidade normalizada: Max: $max, Min: $min")


# Histograma
function histograma(img, norm::Bool = true, title::String = "Histograma da Imagem")
    histdata = vec(channelview(img))

    if !norm
        # 1) Não normalizado
        return plot(
            histdata,
            bins=256,
            seriestype = :barhist,
            xlabel = "Intensidade",
            ylabel = "Frequência",
            title = "$title",
            legend = false,
            xlims = (0, 1),
            margin = 2Plots.cm,
            #fmt=:svg
        )
    end
            
    # 2) Normalizado
    return plot(
        histdata,
        normalize=:probability,
        bins=256,
        seriestype = :barhist,
        xlabel = "Intensidade",
        ylabel = "Frequência (Normalizada)",
        title = "$title (Normalizado)",
        legend = false,
        xlims = (0, 1),
        margin = 3Plots.cm,
        #fmt=:svg
    )
end


# 3) Trans linear pra deixar escura
imgescura = img .- (min-0.01)
# imgescura = map(clamp01nan, img .- 0.3 )
save("$tmppath/escura.png", imgescura)
#run(`xdg-open $tmppath/escura.png`)

# 4) T.L. contraste reduzido
imgconred = img * 0.5
save("$tmppath/conred.png", imgconred)

# 5) Equalizar item 4
imgeq = adjust_histogram(imgconred, Equalization())
save("$tmppath/eq.png", imgeq)

# 6) Nova imagem, com primeiro e segundo plano
img6_path = "./DSC_8153_QWJSZ3p.JPG"
orig6 = load(img6_path)
img6 = Gray.(orig6)
save("$tmppath/gray6.png", img6)

# 7) Mascara binária primeiro plano do item 6
cutoff = 0.55
masked6 = copy(img6)
masked6[masked6 .< cutoff] .= 0.0
save("$tmppath/masked6.png", masked6)
mask = copy(masked6)
mask[mask .!= 0.0] .= 1.0
save("$tmppath/mask.png", mask)

# Histogramas de todas questões
p = plot(
    histograma(img, false), 
    histograma(img), 
    histograma(imgescura, true, "Escura"),
    histograma(imgconred, true, "Contraste Reduzido"),
    histograma(imgeq, true, "Equalizada"),
    histograma(img6, true, "Imagem 6"),
    histograma(masked6[masked6 .> 0.0], true, "Mascarada 6"),
    layout = (7, 1), 
    #fmt = :svg
)
graphpath = "$tmppath/grafico.png"
savefig(p, graphpath)
run(`xdg-open $graphpath`)