library(sp)
library(gstat)
library(sf)
library(mapview)
library(tidyverse)
library(leaflet)

bun_jiko = readRDS("./work/bun_jiko.rds")


bun_jiko |> 
  count(.by = 都道府県コード) |> 
  arrange(n |> desc())

bun_jiko |> dim()

tky2023 = bun_jiko |> 
  filter(
    year(ymd_ev) == 2023
  ) |> 
  filter(
    都道府県コード %in% c(30,43,44,45)
  )

# tokyo
set.seed(123)
tky2023.grid = tky2023 |> 
  group_by(lon_round2,lat_round2) |> 
  summarise(cnt = n()) |> 
  filter(lat_round2 >= 35,lon_round2 <= 140) |> 
  mutate(
    lat_round2 = lat_round2 |> round(2),
    lon_round2 = lon_round2 |> round(2),
    rand = runif(n(),0,1),
    is_train = if_else(rand <= 0.7,1,0),
  ) 

tky2023.grid |> dim()

tky2023.grid |> 
  ggplot() + aes(x = lon_round2,y = lat_round2,fill = cnt,label = cnt) + 
  geom_tile() + 
  geom_text(color = "white") + 
  scale_fill_viridis_c() + 
  coord_equal()

tky2023.grid$lat_round2 |> max()
tky2023.grid$lon_round2 |> min()


tky.mx = expand.grid(
  lon_round2 = seq(138.9,139.9,by = 0.05),
  lat_round2 = seq(35.5,35.8,by = 0.05)
  ) |> 
  mutate(
    lon_round2 = lon_round2 |> round(2),
    lat_round2 = lat_round2 |> round(2),
  )


#temp |> 
#  ggplot() + aes(x = lon_round2,y = lat_round2,fill = rand,label = rand) + 
#  geom_tile() + 
#  geom_text(color = "white") + 
#  scale_fill_viridis_c() + 
#  coord_equal()


library(tidylog)
tky.mx |> dim()
bun.tky


bun.tky = tky.mx |> 
  left_join(
    tky2023.grid,
    by = c("lon_round2","lat_round2")
  ) |> 
  arrange(lon_round2,lat_round2) |> 
  mutate(
    #rand = runif(n(),0,1),
    #is_train = if_else(rand <= 0.7,1,0),
    is_train = is_train |> replace_na(0),
    cnt = cnt |> replace_na(0)
    )

bun.tky$cnt

bun.tky |> 
  filter(
    is.na(is_train) == F
  ) |> dim()

tky2023.grid |> dim()
tky2023.grid |> summary()


bun.tky |> 
  ggplot() + aes(x = lon_round2,y = lat_round2,fill = cnt,label = cnt) + 
  geom_tile() + 
  geom_text(color = "white") + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  facet_grid(is_train~.)


train <- bun.tky |> 
  filter(is_train == 1) |> 
  st_as_sf(coords = c("lon_round2", "lat_round2"), crs = 4326)

test <- bun.tky |> 
  filter(is_train == 0) |> 
  st_as_sf(coords = c("lon_round2", "lat_round2"), crs = 4326)


vc <- train |> 
  variogram(log(cnt) ~ 1,data = _, cloud = TRUE)
vc |> plot()


v <- train |> variogram(log(cnt) ~ 1,data = _)
v |> plot()

show.vgms(par.strip.text = list(cex = 0.75))


vinitial <- vgm(psill = 4, 
                model = "Exp",
                range = 20, nugget = 0)
v |> plot(vinitial, cutoff = 1000, cex = 1.5)


fv <- fit.variogram(object = v,
                    model = vgm(psill = 4, model = "Exp",
                                range = 20, nugget = 0))
v |> plot(fv, cex = 1.5)

library(ggplot2)
library(viridis)

k <- train |> 
  gstat(formula = log(cnt) ~ 1, data = _, model = fv)


?gstat

pred.train <- k |> predict(train)

pred.train.df = pred.train |> 
  st_drop_geometry()

temp = pred.train |> 
  st_coordinates()

pred.train.df = pred.train.df |> 
  mutate(
    lon_round2 = temp[,1],
    lat_round2 = temp[,2],
    var1.pred = var1.pred |> exp() |> round(),
    type = "pred",
    is_train = 1
    )


train.org = bun.tky |> 
  filter(is_train == 1) |> 
  mutate(
    cnt = cnt |> replace_na(0),
    type = "true"
  )

train.chk = bind_rows(
  pred.train.df,
  train.org
) |> 
  mutate(
    var1.pred = coalesce(var1.pred,cnt,0)
  )

train.chk |> 
  ggplot() + aes(x = lon_round2,y = lat_round2, fill = var1.pred,label = var1.pred) + 
  geom_tile() +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(color = "white") + 
  facet_grid(type~.)

  
pred.test <- k |> predict(test)

pred.test.df = pred.test |> 
  st_drop_geometry()

temp = pred.test |> 
  st_coordinates()

pred.test.df = pred.test.df |> 
  mutate(
    lon_round2 = temp[,1],
    lat_round2 = temp[,2],
    var1.pred = var1.pred |> exp() |> round(),
    type = "pred",
    is_train = 0
  )

test.org = bun.tky |> 
  filter(is_train == 0) |> 
  mutate(
    cnt = cnt |> replace_na(0),
    type = "true"
  )

test.chk = bind_rows(
  pred.test.df,
  test.org
) |> 
  mutate(
    var1.pred = coalesce(var1.pred,cnt,0)
  )

test.chk

test.chk |> 
  ggplot() + aes(x = lon_round2,y = lat_round2, fill = var1.pred,label = var1.pred) + 
  geom_tile() +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(color = "white") + 
  facet_grid(type~.)

test.acc = pred.test.df |> 
  left_join(
    test.org,
    by = c("lon_round2","lat_round2")
  ) |> 
  mutate(
    resid = ((cnt - var1.pred)/var1.pred) |> round(2)
  )



test.acc |> 
  ggplot() + aes(x = lon_round2,y = lat_round2, fill = resid,label = resid) + 
  geom_tile() +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(color = "white")

all.chk = 
  bind_rows(
    train.chk,
    test.chk
  )


library(sf)



all.chk |> 
  ggplot() + aes(x = lon_round2,y = lat_round2, fill = var1.pred,label = var1.pred) + 
  #annotation_map_tile(zoomin = 0) +
  geom_tile() +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(color = "white") + 
  facet_grid(type~is_train)

#all.chk.sf = all.chk |> 
#  st_as_sf(coords = c("lon_round2", "lat_round2"), crs = 4326)

#all.chk.sf |> 
#  ggplot() + 
#  annotation_map_tile(zoomin = 0)


#all.chk.sf

all.chk |> 
  select(lon_round2,lat_round2) |> 
  summary()


map <- openmap(c(lat = 35.4, lon = 138.80), 
               c(lat = 35.9, lon = 140) , type = "osm")

mapLatLon <- map |> openproj()
g <- mapLatLon |> autoplot()

osm_plot = g + 
  geom_tile(data = all.chk,
            aes(x = lon_round2,y = lat_round2, fill = var1.pred),alpha = 0.5) +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(
    data = all.chk,
    aes(x = lon_round2,y = lat_round2,label = var1.pred),
    color = "white") + 
  facet_grid(type~is_train)

g + 
  geom_tile(data = all.chk,
            aes(x = lon_round2,y = lat_round2, fill = var1.pred),alpha = 0.5) +
  scale_fill_viridis_c() + 
  coord_equal() +
  geom_text(
    data = all.chk,
    aes(x = lon_round2,y = lat_round2,label = var1.pred),
    color = "white") + 
  facet_grid(type~.)


  



