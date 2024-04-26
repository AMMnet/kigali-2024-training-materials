#
rm(list=ls())

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


##### Enregistrez ce fichier dans le même dossier que le dossier Shapefiles

## ----packages, echo=TRUE------------------------------------------------------------------------------------------

packages= c("pacman",
            "tidyverse",
            "sf", # spatial data 
            "leaflet", # designing dynamic web maps
            "leaflet.extras",# extra functions for leaflet
            "maps", # additional helpful mapping packages
            "viridis", # color package
            "patchwork",
            "ggpubr")

 if (!require("pacman")){
    install.packages("pacman")
 }


pacman::p_load(packages, character.only = T)


 
homedir = "./"
output =file.path(homedir,"output")


## ----load.sfmap, echo=TRUE----------------------------------------------------------------------------------------

#loading spatial data
#quiet = to turn off the message about coordinates systems

GRL_data = st_read(file.path(homedir, "Data/Shapefiles/GRL/GRL_adm1.shp"),
                   quiet=TRUE )

p1= GRL_data |>  
  ggplot()+
  geom_sf(aes(fill=NAME_1))+
  guides(fill=guide_legend(size=4, nrow=2))+
  # theme_void(base_size = 25/.pt)+
  theme(plot.margin = unit(c(0,0,0,0), "in"),
        legend.text = element_text(size=25/.pt),
        legend.position = "bottom")

ggsave(plot = p1, filename = file.path(output,"plot_GRL1.png"),
       bg="white",
       width=5, height=3,units = "in",dpi = 150, scale=1.5)


## ----proj1--------------------------------------------------------------------------------------------------------

#examine coordinate system
st_crs(GRL_data) # WGS84


## ----pwgs---------------------------------------------------------------------------------------------------------
p1.1= p1+
  ggtitle("projection WGS 84")
ggsave(file.path(output, "map_wgs.png"),
       bg="white",width = 5, height = 4,units = "in",
       scale=1.2 )



## ----proj2--------------------------------------------------------------------------------------------------------
#other type of projection
#ESRI:53016 gall sterographic
#ESRI:54030 robinson
#EPSG:3857 pseudo mercato

# change CRS using st_transform to robinson
df_sf_robinson <- st_transform(GRL_data, crs="ESRI:54030")
st_crs(df_sf_robinson)



## ----proj3, fig.dpi=100-------------------------------------------------------------------------------------------

#|eval: true
#| layout: [[45,-5, 45]]

p2= df_sf_robinson |> 
  ggplot()+
  geom_sf(aes(fill=NAME_1))+
  ggtitle("projection Robinson")+
  guides(fill=guide_legend(size=3, nrow=2))+
  # theme_void(base_size = 30/.pt)+
  theme(plot.margin = unit(c(0,0,0,0), "in"),
        legend.text = element_text(size=25/.pt),
        legend.position = "bottom")

ggsave(file.path(output, "map_robinsons.png"),
       bg="white",width = 5, height = 4,units = "in", 
       scale =2 )

# p3= ggarrange(plotlist = list(p1.1,p2), common.legend = T,
#           legend = "bottom")
# 
# ggsave(plot = p3, file.path(homedir, "output/Projection_compare.png"),
#        width = 7, height = 4, bg = "white", dpi = 300, scale=1.2)


p1.1

p2


## ----compcrs, fig.dpi=100, fig.pos="center"-----------------------------------------------------------------------

#|layout: [[40,-5, 40],[40,-5, 40]]

robinson_centroid = st_centroid(df_sf_robinson$geometry) |>
  st_coordinates()
robinson_centroid = data.frame(X=robinson_centroid[,"X"],
                               Y=robinson_centroid[, "Y"])

wgs84_centroid= st_centroid(GRL_data$geometry ) |>
  st_coordinates() 
wgs84_centroid= data.frame(X= wgs84_centroid[,"X"],
                           Y=wgs84_centroid[,"Y"])


#projection of WGS (original projection)
#same as p1.1
p1.2 = ggplot()+
  geom_sf(data=GRL_data, aes(fill=NAME_1))+
 geom_point(data=wgs84_centroid, aes(y=Y, x=X), col="blue")+
  ggtitle("WGS84 projection")

#projection of Robinson,
#same as p2
p2.1 = ggplot()+
    geom_sf(data=df_sf_robinson, aes(fill=NAME_1))+
  geom_point(data=robinson_centroid, aes(x=X, y=Y),
             col="red")+
  ggtitle("Robinson projection")



#combining both centroid on robinson using map projected on wgs 
p3=ggplot()+
    geom_sf(data=GRL_data, aes(fill=NAME_1))+
    geom_point(data=robinson_centroid, aes(x=X, y=Y),
               col="red")+
  ggtitle("Projection de WGS84\navec les centroides en projection de Robinson")

#putting both centroid (robinson and WGS84) avec la carte en projection
p4= ggplot()+
  geom_sf(data=GRL_data, aes(fill=NAME_1))+
  geom_point(data=robinson_centroid, aes(y=Y, x=X),
             col="red")+
  geom_point(data=wgs84_centroid, aes(X,Y), 
             col="blue")+
  ggtitle("Projection des centroides en WGS (bleu)\n et en Robinson (rouge) avec la carte en Robinson")+
  coord_sf(crs = st_crs(df_sf_robinson))

p1.2
p2.1
p3
p4


## ----loadingCases-------------------------------------------------------------------------------------------------

cases <- read_csv(file.path(homedir, "Data/Greenland_cases.csv") )

head(cases)



## ----casmonth-----------------------------------------------------------------------------------------------------
#|eval: true
#|layout: [[45,-5, 45]]
cases |> 
  mutate(month = factor(month, levels = unique(month.abb))) |> 
  group_by(month,Admin1, X,Y) |> 
  summarise(nb_cas= sum(conf_u5)) -> cas_monthly
  
couleurs = RColorBrewer::brewer.pal(6, "Oranges")
# cases$Admin1 = factor(cases$Admin1, levels = c("Qeqqata","Kujalleq", "Northeast Greenland National Park", "Sermersooq","Qasuitsup"))


cas_monthly |> 
  ggplot()+
  geom_line(aes(month, nb_cas, group=Admin1,col=Admin1 ))+
  scale_x_discrete("Mois")+
  scale_y_continuous("Nombre de cas")+
  scale_color_discrete("Région")+
  ggtitle("Cas du paludisme au Groenland en 2018")+
  theme_bw()


# 
# Calculer le nombre de cas annuel du Groenland
# 
# Visualiser le resultat
# 
cases2018 <- cas_monthly |>
  #renommer la colonne des provinces comme dans le shapefile
  rename(NAME_1="Admin1") |>
  #colonnes selon lesquelles agréger les données
  group_by(NAME_1) |>
  #agrégation
  summarise(cas=sum(nb_cas))
# 

# 
cases2018$NAME_1 = factor(cases2018$NAME_1, levels = c("Qeqqata","Kujalleq", "Northeast Greenland National Park", "Sermersooq","Qasuitsup"))
# 
plt_casesAn = ggplot(cases2018)+
  geom_bar(aes(reorder(NAME_1, desc(cas) ), cas, fill=NAME_1), stat="identity")+
  scale_x_discrete("")+
  scale_y_continuous("Cas annuel", expand = c(0,0.1),
                     limits = c(0, 30000 ))+
  scale_fill_manual("Region", values= rev(couleurs) )+
  # scale_fill_viridis_d("Region", alpha = 0.5, option = "D")+
  theme_bw()+
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
# 
# ggsave(file.path(output,"Nb_casesAnnuelBar2018.png"),
#        width = 5, height = 3, bg = "white")

plt_casesAn+
  ggtitle("Nombre de cas par région")



## ----mapwithcases-------------------------------------------------------------------------------------------------

map.cases1 <- left_join(cases2018,GRL_data)

ggplot(map.cases1)+
  geom_sf(aes(geometry=geometry, fill = cas))



## ----namefix------------------------------------------------------------------------------------------------------

unique(GRL_data$NAME_1)
unique(cases2018$NAME_1)





## ----corrname-----------------------------------------------------------------------------------------------------
cases2018= cases2018 |> 
  mutate(NAME_1 = case_when(NAME_1=="Qasuitsup"~"Qaasuitsup",
                            TRUE~NAME_1))

map.cases <- left_join(cases2018,GRL_data)

ggplot(map.cases)+
  geom_sf(aes(geometry=geometry, fill = cas))



## à vous de coder maintenant----------------------------------------------------------------------------------------------------------------
## amélioration de la carte



## -----------------------------------------------------------------------------------------------------------------
map.cases_sf <- map.cases |> 
  st_as_sf()


leaflet(data = map.cases_sf)|>
  addPolygons()


# Améliorer la carte avec leaflet


