library(gwzinbr)
library(DataExplorer)
library(tidyverse)
library(leaflet)
list.files()
getwd()

files = list.files(pattern = "csv")

numb = 0 

for (file in files){
  file |> print()
  temp1 = read.csv(file,fileEncoding = "shift-jis")
  if(numb == 0){temp = temp1} else {temp = bind_rows(temp,temp1)}
  numb = numb + 1
}

rm(temp1)
gc()


temp |> dim()

temp |> plot_histogram()

temp |> head()

temp = temp |> 
  mutate(
    ymd_ev = ymd(発生日時..年*10000 + 発生日時..月 * 100 + 発生日時..日),
    hm_ev = paste0(発生日時..時,":",発生日時..分) |>  hm(),
    #lon = 地点.経度.東経./10000000,
    #lat = 地点.緯度.北緯./10000000,
    lon = 
      as.numeric(substr(地点.経度.東経.,1,3)) +
      as.numeric(substr(地点.経度.東経.,4,5))/60 + 
      as.numeric(substr(地点.経度.東経.,6,11))/3600000,
    
    lat = 
      as.numeric(substr(地点.緯度.北緯.,1,2)) +
      as.numeric(substr(地点.緯度.北緯.,3,4))/60 + 
      as.numeric(substr(地点.緯度.北緯.,5,10))/3600000,
    
    time_circ = (hour(hm_ev)*60 + minute(hm_ev))/(24*60),
    time_ang = hour(hm_ev)*15 + minute(hm_ev)*1/4 ,
    time_rad = time_ang/180*pi,
    cos_time = time_rad |> cos(),
    sin_time = time_rad |> sin(),
    lon_round = lon%/%0.1*0.1,
    lat_round = lat%/%0.1*0.1,
    #lon_round = lon%/%1*1,
    #lat_round = lat%/%1*1,
    yyyymm = year(ymd_ev) * 100 + month(ymd_ev),
    lon_round2 = lon%/%0.05*0.05,
    lat_round2 = lat%/%0.05*0.05,
  )

temp |> saveRDS("bun_jiko.rds")
