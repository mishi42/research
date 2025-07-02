library(sp)
library(gstat)
library(sf)
library(mapview)
library(tidyverse)
library(leaflet)
library(spacetime)

bun_jiko |> 
  count(.by = 都道府県コード) |> 
  arrange(n |> desc())

bun_jiko |> dim()

tky2023 = bun_jiko |> 
  mutate(
    yyyy = year(ymd_ev),
    cnt = 1
  ) |> 
  filter(
    都道府県コード %in% c(30,43,44,45)
  ) |> 
  filter(
    yyyy %in% c(2020,2021,2022,2023,2024)
  )
  

#kanto.mx = tky2023 |> 
#  pivot_wider(
#    id_cols = c(lon_round2,lat_round2),
#    values_from = cnt,
#    names_from = yyyy,
#    values_fn = sum
#  )

yyyy.vec = c(2020,2021,2022,2023)

tky2023.grid

set.seed(123)
tky2023.grid = tky2023 |> 
  group_by(lon_round2,lat_round2,yyyy) |> 
  summarise(cnt = n()) |> 
  filter(lat_round2 >= 35,lon_round2 <= 140) |> 
  mutate(
    lat_round2 = lat_round2 |> round(2),
    lon_round2 = lon_round2 |> round(2),
    rand = runif(n(),0,1),
    is_train = if_else(rand <= 0.7,1,0),
    #is_train = if_else(rand <= 0.7,1,0),
  ) 

tky2023.grid |> dim()


tky2023.grid |> 
  ggplot() + aes(x = lon_round2,y = lat_round2,fill = cnt,label = cnt) + 
  geom_tile() + 
  geom_text(color = "white") + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  facet_wrap(~yyyy)

tky2023.grid$lat_round2 |> max()
tky2023.grid$lon_round2 |> min()


tky.mx = expand.grid(
  yyyy = seq(2020,2023,by = 1),
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


bun.tky = tky.mx |> 
  left_join(
    tky2023.grid,
    by = c("yyyy","lon_round2","lat_round2")
  ) |> 
  arrange(lon_round2,lat_round2) |> 
  mutate(
    rand = runif(n(),0,1),
    is_train = if_else(rand <= 0.7,1,0),
    is_train = is_train |> replace_na(0),
    cnt = cnt |> replace_na(0),
    #is_test2023 = if_else(yyyy == 2023,1,0)
  )

bun.tky

bun.tky |> 
  filter(
    is.na(is_train) == F
  ) |> dim()

tky2023.grid |> dim()
tky2023.grid |> summary()


bun.tky |> 
  ggplot() + aes(x = lon_round2,y = lat_round2,fill = cnt,label = cnt) + 
  geom_tile() + 
  geom_text(color = "white",size = 2) + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  facet_grid(is_train~yyyy)



train <- bun.tky |> 
  filter(is_train == 1) |> 
  pivot_wider(
    id_cols = c(lon_round2,lat_round2),
    names_from = yyyy,
    values_from = cnt,
  )

data(air)
air |> head()

air |> as.vector()

stations.train = train |> 
  select(lon_round2,lat_round2) |> 
  SpatialPoints()

?SpatialPoints

dates.train = c("2020-12-31","2021-12-31","2022-12-31","2023-12-31") |> 
  ymd()

temp = train |> select(-c(lon_round2:lat_round2)) |> 
  as.matrix()

cnt.ac.train = data.frame(cnt = as.vector(temp)) 

dat = STFDF(stations.train,dates.train,cnt.ac.train) |> 
  as("STSDF")

#dat |> proj4string()

dat |> stplot()

vv = variogram(cnt ~ .,data = dat,tlags = 1)

vv |> plot()

vv |> plot(map = F)

prodSumModel = vgmST("productSum",
      space = vgm(10000,"Exp",0.2,5),
      time = vgm(10000,"Exp",5,5),
      k = 0.1)


prodSumVgm = vv |> 
  fit.StVariogram(prodSumModel)

plot(vv,prodSumVgm)
plot(vv,prodSumVgm,map = F)


attr(separableVgm,"optim")$value


test <- bun.tky |> 
  filter(is_train == 1) |> 
  pivot_wider(
    id_cols = c(lon_round2,lat_round2),
    names_from = yyyy,
    values_from = cnt,
  )


stations.test = test |> 
  select(lon_round2,lat_round2) |> 
  SpatialPoints()


temp = test |> select(-c(lon_round2:lat_round2)) |> 
  as.matrix()

#cnt.ac.test = data.frame(cnt = as.vector(temp)) 

bun.tky

dates.test = c("2022-12-31","2023-12-31","2024-12-31","2025-12-31") |> ymd()

dat.test = STF(sp = stations.test, time = dates.test)

pred = krigeST(cnt ~ 1,data = dat,newdata = dat.test,
               prodSumVgm,computeVar = T)

pred |> stplot(type = "tile")
?stplot

pred.df = data.frame(
  pred = pred$var1.pred,
  pred.var = pred$var1.var
  #lon = pred@sp@coords[,"lon_round2"],
  #lat = pred@sp@coords[,"lat_round2"],
  #time = pred@time
)


test.df
pred.df |> dim()
coord.df = expand.grid(
  yyyymmdd = dates.test,
  pred@sp@coords
  #lon_round2 = pred@sp@coords[,"lon_round2"] |> unique(),
  #lat_round2 = pred@sp@coords[,"lat_round2"] |> unique()
)
coord.df |> dim()
pred@sp@coords[,"lon_round2"]

coord.df |> dim()

plot.pred = cbind(
  pred.df,
  coord.df
)

plot.pred |> 
  ggplot() + aes(x = lon_round2,y = lat_round2,fill = pred,values = pred) + 
  geom_tile() + 
  facet_wrap(~yyyymmdd)

