pacman::p_load(
  Ipaper, data.table, dplyr, lubridate,
  httr, stringr
)

header <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
set_config(
  add_headers(
    `User-Agent` = header
  )
)

cal_hours <- function(date_end, date_beg) {
  dhour <- difftime(date_end, date_beg, units = "hours")
  round(as.numeric(dhour), digits = 2)
}

# url_root = "https://data.nsmc.org.cn/DataPortal/v1/data/selection/file/subcount"
# url <- "https://data.nsmc.org.cn/DataPortal/v1/data/selection/subfile?productID=FY4B-_AGRI--_N_DISK_1330E_L2-_QPE-_MULT_NOM_YYYYMMDDhhmmss_YYYYMMDDhhmmss_4000M_V0001.NC&txtBeginDate=2022-06-01&txtBeginTime=00%3A00%3A00&txtEndDate=2022-07-01&txtEndTime=23%3A59%3A59&east_CoordValue=180.0&west_CoordValue=-180.0&north_CoordValue=90.0&south_CoordValue=-90.0&cbAllArea=on&cbGHIArea=on&converStatus=&rdbIsEvery=&beginIndex=1&endIndex=10&where=&timeSelection=all&periodTime=&daynight=&filecount=4026&filesize=4430481664&source=0"

query_filelist <- function(i) {
  date_beg <- dates[i]
  date_end <- dates[i + 1] - dhours(1)
  str_beg <- format(date_beg, "%Y-%m-%d")
  str_end <- format(date_end, "%Y-%m-%d")

  params <- list(
    productID = "FY4B-_AGRI--_N_DISK_1330E_L2-_QPE-_MULT_NOM_YYYYMMDDhhmmss_YYYYMMDDhhmmss_4000M_V0001.NC",
    txtBeginDate = str_beg,
    txtBeginTime = "00:00:00",
    txtEndDate = str_end,
    txtEndTime = "23:59:59",
    east_CoordValue = "180.0",
    west_CoordValue = "-180.0",
    north_CoordValue = "90.0",
    south_CoordValue = "-90.0",
    cbAllArea = "on",
    cbGHIArea = "on",
    converStatus = "",
    rdbIsEvery = "",
    where = "",
    timeSelection = "all",
    periodTime = "",
    daynight = ""
  )

  url_root <- "https://data.nsmc.org.cn/DataPortal/v1/data/selection/subfile"
  p <- GET(url_root, query = params) %>% content()
  # l <- p$resource[[1]]
  info <- map(p$resource, \(l) {
    data.table(date_beg = l$DATABEGINDATE, date_end = l$DATAENDDATE, file = l$ARCHIVENAME)
  }) %>%
    rbindlist() %>%
    arrange(date_beg, date_end)
  mutate(info, dhour = cal_hours(date_end, date_beg), .after = date_end)
}
