source("./Project_FY4B/main_pkgs.R")

options(datatable.print.nrow = 21)
f_full <- "./filelist_full_202206-202412.txt"

dates <- seq(make_datetime(2022, 6), make_datetime(2025, 1), by = "month")
n <- length(dates) - 1
lst <- foreach(i = icount(n)) %do% {
  runningId(i)
  tryCatch({
    query_filelist(i)
  }, error = function(e) {
    message(sprintf("%s", e$message))
    NULL
  })
}
df <- rbindlist(lst)
fwrite(df, f_full)
