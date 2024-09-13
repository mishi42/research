install2.r --error --skipmissing \
    # graphic handling ============================================================================
    dbplyr \
    ggh4x \
    ggquiver \
    ggExtra \
    # bayes ============================================================================
    tidybayes \
    rstan \
    rstanarm \
    bayesplot \
    # geo science https://couttsgeodata.netlify.app/post/2021-02-28-r_geoscience/ ============================
    # GEOmap \
    # geomapdata \
    terrainr \
    terrainmeshr \
    geotoolsR \
    georob \
    gstat \
    fossil \
    FossilSim \
    folio \
    chronosphere \
    ETAS \
    bayesainETAS \
    GRTo \
    SDAR \
    coreCT \
    rgdal \
    # spatial ============================================================================
    imager \ 
    NipponMap \
    spatialreg \
    car \
    CARBayes \
    CARBayesST \
    CARBayesdata \
    gstat \
    GWmodel \
    #osmdata \
    leaflet \
    splm \
    spdplyr \
    rmapshaper \
    ggspatial \
    ggcircular \
    ggmap \
    nngeo \
    terra \
    rnaturalearth \
    spTimer \
    celestial \
    gmGeostats \
    stplanr \
    tmap \
    raster \
    geodata \
    kokudosuuchi \
    countrycode \
    spBayes \
    leaflet \
    #directional ============================================================================
    bpnreg \
    Directional \
    CircStats \
    CircNNTSR \
    OmicCircos \
    plotrix \
    psych \
    season \
    spatstat \
    bReeze \
    MBA \
    geosphere \
    globe \
    mgcv \
    misc3d \
    moveHMM \
    NHMSAR \
    rgl \
    rstiefel \
    shape \
    skmeans \
    sm \
    sphereplot \
    SphericalCubature \
    CircComplexMod \
    CircSpatial \
    compositions \
    Compositional \
    lattice \
    scatterplot3d \
    circular \
    cylcop \
    bpDir \
    plot3D \
    movMF \
    BAMBI \
    sphunif \
    rotasym \ 
    DirStats \
    nprotreg \
    sdetorus \
    CircSpaceTime \
    RndomFields \
    rcosmo \
    isocir \
    RiemBase \
    OptCirClust \
    #climate ============================================================================
    weatherr \
    metR \
    meteoland \
    rmweather \
    climate \ 
    #echelon ============================================================================
    spData \
    spdep \
    tiff \ 
    jpmesh \
    zipangu \
    kuniezu \
    #TauP.R
    #document ============================================================================
    rticles \
    rmarkdown \
    knitr \
    DT \
    htmlwidgets \
    bookdown \
    tableone \
    knitr \
    sessioninfo \
    tinytex \
    latex2exp \
    distill \
    equatiomatic \
    kable \
    kableExtra \
    readxl \
    docxtractr \
    gapminder \
    ftExtra \
    reactable \
    minidown \
    rvest \
    RSelenium \
    stringr \
    polite \
    renv \
    targets \
    cronR \
    openxlsx \
    drat \
    OpenCL \
    DBI \
    spatialsample \
    ggthemes \
    Rtsne \
    gtsummary \
    corrplot \
    modelsummary \
    rBaysianOptimization \
    RODBC \
    skimr \
    progress \
    stringi \
    excel.link \
    XLConnect \
    patchwork \
    sen2r \
    languageserver


R -q -e 'devtools::install_github("keesmulder/circglmbayes")'

R -q -e 'devtools::install_github("ActiveMargins/stRatstat")'
R -q -e 'devtools::install_github("oscarperpinan/rasterVis")'
# RUN R -q -e 'install.packages("INLA",repos=c(getOption("repos"),INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)'
R -q -e "install.packages('spDataLarge',repos='https://nowosad.github.io/drat/', type='source')"

#uryu
R -q -e 'remotes::install_gitlab("uribo/jmastats")'
R -q -e 'remotes::install_github("uribo/kuniezu")'
R -q -e 'devtools::install_github("uribo/jpndistrict")'
R -q -e 'devtools::install_github("uribo/lab.note")'

#bayes
R -q -e 'remotes::install_github("stan-dev/cmdstanr"); cmdstanr::install_cmdstan()'
R -q -e 'tinytex::install_tinytex(force = TRUE);tinytex::tlmgr_install("ipaex")'
R -q -e 'remotes::install_github("rstudio/pins")'
R -q -e 'devtools::install_github("xrobin/pROC")'

# sitelite
#R -q -e 'devtools::install_github("e-sensing/sits", dependencies = TRUE)'
#R -q -e 'devtools::install_github("e-sensing/sitsdata")'

