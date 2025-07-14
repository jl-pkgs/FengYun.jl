## 无法直接下载
pacman::p_load(
  Ipaper, data.table, dplyr, lubridate, 
  httr, xml2, jsonlite
)

url = "https://satellite.nsmc.org.cn/DataPortal/v1/data/selection/subfile?productID=FY4B-_AGRI--_N_DISK_1330E_L2-_QPE-_MULT_NOM_YYYYMMDDhhmmss_YYYYMMDDhhmmss_4000M_V0001.NC&txtBeginDate=2025-04-14&txtBeginTime=00%3A00%3A00&txtEndDate=2025-07-14&txtEndTime=23%3A59%3A59&east_CoordValue=180.0&west_CoordValue=-180.0&north_CoordValue=90.0&south_CoordValue=-90.0&cbAllArea=on&cbGHIArea=on&converStatus=&rdbIsEvery=&beginIndex=101&endIndex=200&where=&timeSelection=all&periodTime=&daynight=&filecount=11834&filesize=11628644027&source=0"
p = GET(url) %>% content()

l <- httr::parse_url(url)
sprintf("%s://%s", l$scheme, l$hostname)

## 需要先判断总共多少个
param = listk(
  productID        = "FY4B-_AGRI--_N_DISK_1330E_L2-_QPE-_MULT_NOM_YYYYMMDDhhmmss_YYYYMMDDhhmmss_4000M_V0001.NC",
  txtBeginDate     = "2025-04-14",
  txtBeginTime     = "00:00:00",
  txtEndDate       = "2025-07-14",
  txtEndTime       = "23:59:59",
  east_CoordValue  = "180.0",
  west_CoordValue  = "-180.0",
  north_CoordValue = "90.0",
  south_CoordValue = "-90.0",
  cbAllArea        = "on",
  cbGHIArea        = "on",
  converStatus     = "",
  rdbIsEvery       = "",
  beginIndex       = "001",
  endIndex         = "1000",
  where            = "",
  timeSelection    = "all",
  periodTime       = "",
  daynight         = "",
  # filecount        = "11834",
  # filesize         = "11628644027",
  source           = "0"
)
.param <- paste(names(param), unlist(param), sep = "=", collapse = "&")
.host = "https://satellite.nsmc.org.cn/DataPortal/v1/data/selection/subfile"
.url = sprintf("%s?%s", .host, .param)

p <- GET(.url) %>% content()
p$resource %>% length()
x = p$resource[[1]]
x$ARCHIVENAME
