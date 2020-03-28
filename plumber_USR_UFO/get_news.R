
# 取得最新一則網址 ----------------------------------------------------------------
## https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/

library(rvest)
library(xml2)
library(magrittr)
newsList_UFO <- read_html("https://www.ntpu.edu.tw/college/e4/index.php?Page=1&Keyword=&class_id=4")
newsList_USR <- read_html("https://www.ntpu.edu.tw/college/e4/index.php?class_id=3")

removeTbody <- function(x){
  stringr::str_remove_all(x,"(/tbody)")
}
newsList_UFO %>%
  html_node(
    xpath="/html/body/table/tbody/tr[5]/td[3]/table/tbody/tr[4]/td/table[1]/tbody/tr[1]/td[2]/a" %>%
      removeTbody#"/html/body/table/tr[5]/td[3]/table/tr[4]/td/table[1]/tr[1]/td[2]/a"
  ) %>%
  html_attr("href") %>%
  file.path("https://www.ntpu.edu.tw/college/e4",.) ->
  url_lastestUFO

newsList_USR %>%
  html_node(
    xpath="/html/body/table/tbody/tr[5]/td[3]/table/tbody/tr[4]/td/table[1]/tbody/tr[1]/td[2]/a" %>%
      removeTbody 
  ) %>%
  html_attr("href") %>%
  file.path("https://www.ntpu.edu.tw/college/e4",.) ->
  url_lastestUSR


# 取得新聞內容 ------------------------------------------------------------------

url_lastestUFO %>% read_html() -> page_UFO
url_lastestUSR %>% read_html() -> page_USR

pageExtraction <- function(page_UFO){
  page_UFO %>%
    html_node(
      xpath="/html/body/table/tbody/tr[4]/td[3]/table[2]/tbody/tr[1]/td/font/strong" %>%
        removeTbody()
    ) %>%
    html_text -> title_UFO
  page_UFO %>%
    html_node(
      xpath="/html/body/table/tbody/tr[4]/td[3]/table[2]/tbody/tr[4]/td" %>%
        removeTbody()
    ) %>%
    html_text -> content_UFO
  page_UFO %>%
    html_nodes(
      css=".ch img"
    ) %>%
    purrr::map_chr(function(x) html_attr(x,"src")) -> photos_UFO  
  return(
    list(
      title=title_UFO,
      content=content_UFO,
      photos=photos_UFO
    )
  )
}

page_UFO %>%
  pageExtraction() -> pageList_UFO
page_USR %>%
  pageExtraction() -> pageList_USR


