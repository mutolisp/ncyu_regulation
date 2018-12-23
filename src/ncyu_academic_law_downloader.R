# if you don't have rvest installed, 
# please install it via install.packages("rvest")
library(rvest)
library(curl)

prefix <- 'http://www.ncyu.edu.tw'
acaLawPage <- 'http://www.ncyu.edu.tw/academic/law_list.aspx?pages='

acaLawPage1 <- read_html('http://www.ncyu.edu.tw/academic/law_list.aspx?pages=0')
# get page counts
totalPages <- acaLawPage1 %>% html_nodes(xpath = '//span[@id="pagecount"]') %>%
  html_text() %>% as.numeric()

# get the url of attached files
pgs <- data.frame()
for ( i in 0:totalPages ) {
  htmlPage <- paste(acaLawPage, as.character(i), sep='')
  # get file title
  pageTitle <- htmlPage %>% read_html() %>%
    html_nodes(xpath = '//table[@class="index_bg02"]//td[@width="40%"]//a//span') %>%
    html_text() 
  # get date
  fileDate <- htmlPage %>% read_html() %>%
    html_nodes(xpath = '//table[@class="index_bg02"]//td[@width="15%"]') %>%
    html_text() 
  fileDate <- fileDate[grep('[0-9]', fileDate)]
  # get url
  fileURL <- htmlPage %>% read_html() %>%
    html_nodes(xpath = '//table[@class="index_bg02"]//td[@width="40%"]//a') %>%
    html_attr('href')
  fileURL <- paste(prefix, fileURL, sep='')
  
  currentPage <- cbind(fileDate, pageTitle, fileURL)
  pgs <- rbind(pgs, currentPage)
}

# because most of the filenames are non-ascii characters,
# we use URLencode to encode URL

for ( i in 1:dim(pgs)[1] ) {
  print(paste('Download', round(i/dim(pgs)[1],4)*100, '% :', as.character(pgs[i,2]), sep = ' '))
  curl::curl_download(URLencode(as.character(pgs[i,3])), 
                      paste('/tmp/ncyu_aca_affairs/', pgs[i,1], '_', pgs[i,2], '.pdf', sep = ''))
}

                    