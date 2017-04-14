R Notebook
================
Derek Slone-Zhen
Wednesday, 12th April, 2017

Setup
=====

Favourite Libraries
-------------------

We'll load up some of my standard R packages for later use.

``` r
library (pacman)
p_load (magrittr)
p_load (ggplot2)
p_load (data.table)
```

Language Engines for knitr
--------------------------

``` r
is.windows <- .Platform$OS.type == "windows"
has.postgres <- !is.windows

if (is.windows) {
  knitr::opts_chunk$set(engine.path = list(
    bash = 'C:/Users/Derek Slone-Zhen/.babun/cygwin/bin/bash.exe',
    perl = "C:/Strawberry/perl/bin/perl.exe"
  ))
}
```

And a windows cmd processor
---------------------------

Welcome to an RNotebooks
========================

RNotebooks allow the use of multiple, interwoven languages.

We'll demonstrate the getting, ingestion, and analysis of a Fuel data set.

Fetch 'n' Sniff
---------------

Fetch : I can do this in `R`, but the command prompt is my home. Less friction for me here.

``` bash
wget -c 'https://data.nsw.gov.au/data/dataset/a97a46fc-2bdd-4b90-ac7f-0cb1e8d7ac3b/resource/5ad2ad7d-ccb9-4bc3-819b-131852925ede/download/Service-Station-and-Price-History-March-2017.xlsx'
```

    ## --2017-04-14 20:08:23--  https://data.nsw.gov.au/data/dataset/a97a46fc-2bdd-4b90-ac7f-0cb1e8d7ac3b/resource/5ad2ad7d-ccb9-4bc3-819b-131852925ede/download/Service-Station-and-Price-History-March-2017.xlsx
    ## Resolving data.nsw.gov.au (data.nsw.gov.au)... 52.65.146.152, 52.62.57.173
    ## Connecting to data.nsw.gov.au (data.nsw.gov.au)|52.65.146.152|:443... connected.
    ## HTTP request sent, awaiting response... 200 OK
    ## 
    ##     The file is already fully retrieved; nothing to do.

I'll take a quick look at the file, sometimes it's really a CSV file with an Excel extension.

``` bash
hexdump -C Service-Station-and-Price-History-March-2017.xlsx | head -n20
```

    ## 00000000  50 4b 03 04 14 00 06 00  08 00 00 00 21 00 df e8  |PK..........!...|
    ## 00000010  df 53 82 01 00 00 a3 05  00 00 13 00 08 02 5b 43  |.S............[C|
    ## 00000020  6f 6e 74 65 6e 74 5f 54  79 70 65 73 5d 2e 78 6d  |ontent_Types].xm|
    ## 00000030  6c 20 a2 04 02 28 a0 00  02 00 00 00 00 00 00 00  |l ...(..........|
    ## 00000040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
    ## *
    ## 00000230  00 00 00 00 00 00 00 00  00 ac 54 cb 6e c2 30 10  |..........T.n.0.|
    ## 00000240  bc 57 ea 3f 44 be 56 89  a1 87 aa aa 08 1c fa 38  |.W.?D.V........8|
    ## 00000250  b6 48 a5 1f 60 ec 0d b1  70 6c d7 36 94 fc 7d 37  |.H..`...pl.6..}7|
    ## 00000260  e6 59 94 12 21 b8 c4 71  bc 3b 33 de ec ce 60 b4  |.Y..!..q.;3...`.|
    ## 00000270  aa 54 b2 04 e7 a5 d1 39  e9 67 3d 92 80 e6 46 48  |.T.....9.g=...FH|
    ## 00000280  3d cb c9 d7 e4 2d 7d 24  89 0f 4c 0b a6 8c 86 9c  |=....-}$..L.....|
    ## 00000290  d4 e0 c9 68 78 7b 33 98  d4 16 7c 82 d9 da e7 a4  |...hx{3...|.....|
    ## 000002a0  0c c1 3e 51 ea 79 09 15  f3 99 b1 a0 f1 a4 30 ae  |..>Q.y........0.|
    ## 000002b0  62 01 b7 6e 46 2d e3 73  36 03 7a df eb 3d 50 6e  |b..nF-.s6.z..=Pn|
    ## 000002c0  74 00 1d d2 d0 60 90 e1  e0 05 0a b6 50 21 79 5d  |t....`......P!y]|
    ## 000002d0  e1 e7 b5 12 07 ca 93 e4  79 1d d8 70 e5 84 59 ab  |........y..p..Y.|
    ## 000002e0  24 67 01 95 d2 a5 16 47  2c e9 86 21 c3 cc 18 e3  |$g.....G,..!....|
    ## 000002f0  4b 69 fd 1d ca 20 b4 95  a1 39 f9 9f 60 93 f7 81  |Ki... ...9..`...|
    ## 00000300  a5 71 52 40 32 66 2e bc  b3 0a 65 d0 95 a2 3f c6  |.qR@2f....e...?.|

OK, looks like a real Excel file. The `PK` at the beginning is the give-away of a zipped file, which is what Excels newer file formats are. (Zipped XML files + some othe assets.)

`readxl`
--------

No external dependancies with this library, and installes with C / C++ native libraries for reading both old and new Excel file formats. Thanks [Hadley](http://hadley.nz/)!

``` r
p_load(readxl)
DATA <- read_excel("Service-Station-and-Price-History-March-2017.xlsx")
p_load(data.table)
DATA <- data.table(DATA)
```

and take a peek:

``` r
DATA[1:(if (interactive()) 1000 else 10),]
```

    ##        ServiceStationName                                   Address
    ##  1:     7-Eleven Kirrawee    542 Princes Highway, Kirrawee NSW 2232
    ##  2:     7-Eleven Kirrawee    542 Princes Highway, Kirrawee NSW 2232
    ##  3:     7-Eleven Kirrawee    542 Princes Highway, Kirrawee NSW 2232
    ##  4:   7-Eleven Kings Park      363 Vardys Road, Kings Park NSW 2148
    ##  5:    7-Eleven Blacktown     175 Richmond Road, Blacktown NSW 2148
    ##  6:   7-Eleven Kings Park      363 Vardys Road, Kings Park NSW 2148
    ##  7:    7-Eleven Blacktown       62 Walters Road, Blacktown NSW 2148
    ##  8: 7-Eleven Arndell Park 180 Reservoir Road, Arndell Park NSW 2148
    ##  9:    7-Eleven Blacktown     175 Richmond Road, Blacktown NSW 2148
    ## 10:    7-Eleven Blacktown       62 Walters Road, Blacktown NSW 2148
    ##           Suburb Postcode    Brand FuelCode    PriceUpdatedDate Price
    ##  1:     Kirrawee     2232 7-Eleven      U91 2017-03-01 00:52:43 131.9
    ##  2:     Kirrawee     2232 7-Eleven      E10 2017-03-01 00:52:43 129.9
    ##  3:     Kirrawee     2232 7-Eleven      P98 2017-03-01 00:52:43 147.9
    ##  4:   Kings Park     2148 7-Eleven      P98 2017-03-01 01:08:43 145.7
    ##  5:    Blacktown     2148 7-Eleven      U91 2017-03-01 01:08:43 129.7
    ##  6:   Kings Park     2148 7-Eleven      P95 2017-03-01 01:08:43 140.7
    ##  7:    Blacktown     2148 7-Eleven      P98 2017-03-01 01:08:43 145.7
    ##  8: Arndell Park     2148 7-Eleven      E10 2017-03-01 01:08:43 127.7
    ##  9:    Blacktown     2148 7-Eleven      P98 2017-03-01 01:08:43 145.7
    ## 10:    Blacktown     2148 7-Eleven      U91 2017-03-01 01:08:43 129.7

Sniffing Deeply
---------------

Not the most friendly. Lets try some extra packages:

``` r
p_load(DT)
datatable(DATA[Suburb %in% c('Chatswood', 'Lane Cove', 'Artarmon', 'Lane Cove West')], filter="top")
```

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-3537d49c91c5983e16d9">{"x":{"filter":"top","filterHTML":"<tr>\n  <td><\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"number\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n    <div style=\"display: none; position: absolute; width: 200px;\">\n      <div data-min=\"2064\" data-max=\"2067\"><\/div>\n      <span style=\"float: left;\"><\/span>\n      <span style=\"float: right;\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"character\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"time\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n    <div style=\"display: none; position: absolute; width: 200px;\">\n      <div data-min=\"1488352949000\" data-max=\"1490988900000\" data-scale=\"4\"><\/div>\n      <span style=\"float: left;\"><\/span>\n      <span style=\"float: right;\"><\/span>\n    <\/div>\n  <\/td>\n  <td data-type=\"number\" style=\"vertical-align: top;\">\n    <div class=\"form-group has-feedback\" style=\"margin-bottom: auto;\">\n      <input type=\"search\" placeholder=\"All\" class=\"form-control\" style=\"width: 100%;\"/>\n      <span class=\"glyphicon glyphicon-remove-circle form-control-feedback\"><\/span>\n    <\/div>\n    <div style=\"display: none; position: absolute; width: 200px;\">\n      <div data-min=\"65.9\" data-max=\"158.9\" data-scale=\"1\"><\/div>\n      <span style=\"float: left;\"><\/span>\n      <span style=\"float: right;\"><\/span>\n    <\/div>\n  <\/td>\n<\/tr>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207","208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224","225","226","227","228","229","230","231","232","233","234","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360"],["BP Lane Cove","BP Lane Cove","BP Lane Cove","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","BP Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","7-Eleven Lane Cove","7-Eleven Artarmon","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","BP Lane Cove","BP Lane Cove","BP Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Lane Cove","7-Eleven Artarmon","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","BP Lane Cove","BP Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","7-Eleven Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","Caltex Chatswood","7-Eleven Artarmon","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","BP Lane Cove","BP Lane Cove","BP Lane Cove","BP Lane Cove","BP Connect Artarmon","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","7-Eleven Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","BP Connect Artarmon","BP Lane Cove","BP Lane Cove","BP Lane Cove","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","Caltex Lane Cove","Caltex Chatswood","Caltex Lane Cove","Caltex Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","7-Eleven Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Metro Lane Cove","Metro Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","Caltex Lane Cove","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Caltex Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Caltex Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Lane Cove","Metro Lane Cove","Metro Lane Cove","Metro Lane Cove","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Caltex Chatswood","Caltex Chatswood","Caltex Chatswood","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","7-Eleven Artarmon","Caltex Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","BP Connect Artarmon","BP Connect Artarmon","BP Connect Artarmon","Caltex Lane Cove","Caltex Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Chatswood","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Lane Cove","Coles Express Chatswood"],["62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","62-70 Epping Rd, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","62-70 Epping Rd, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","203 Burns Bay Road, Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","203 Burns Bay Road, Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","477 Pacific Highway, Artarmon NSW 2064","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","422 Pacific Hwy, Artarmon NSW 2064","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","62-70 Epping Rd, Lane Cove NSW 2066","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","203 Burns Bay Road, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","Burns Bay Road, Lane Cove NSW 2066","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","250 Burns Bay Road, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","250 Burns Bay Road, Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","Burns Bay Road, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","533,Mowbray Rd, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","572 Pacific Hwy, Chatswood NSW 2067","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","477 Pacific Highway, Artarmon NSW 2064","572 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","378 Pacific Hwy (Cnr Allison Ave), Lane Cove NSW 2066","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","422 Pacific Hwy, Artarmon NSW 2064","Burns Bay Road, Lane Cove NSW 2066","572 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","877-879 Pacific Hwy, Chatswood NSW 2067","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","250 Burns Bay Road, Lane Cove NSW 2066","877-879 Pacific Hwy, Chatswood NSW 2067"],["Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Chatswood","Chatswood","Chatswood","Lane Cove","Chatswood","Chatswood","Chatswood","Lane Cove","Artarmon","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Lane Cove","Artarmon","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Lane Cove","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Chatswood","Artarmon","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Artarmon","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Chatswood","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Chatswood","Chatswood","Chatswood","Lane Cove","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Lane Cove","Chatswood","Chatswood","Lane Cove","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Artarmon","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Lane Cove","Chatswood","Artarmon","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Artarmon","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Artarmon","Artarmon","Artarmon","Artarmon","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Artarmon","Artarmon","Artarmon","Lane Cove","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Chatswood","Lane Cove","Lane Cove","Lane Cove","Chatswood"],[2066,2066,2066,2064,2064,2064,2064,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2064,2064,2064,2067,2067,2067,2064,2064,2064,2064,2064,2064,2066,2067,2067,2067,2066,2067,2067,2067,2066,2064,2066,2066,2066,2066,2066,2066,2066,2066,2064,2064,2064,2066,2064,2066,2066,2066,2067,2067,2067,2067,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2066,2067,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2067,2066,2066,2066,2067,2067,2067,2067,2066,2066,2066,2067,2064,2067,2067,2067,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2064,2064,2064,2067,2067,2067,2066,2066,2066,2064,2064,2064,2064,2066,2066,2066,2066,2066,2066,2066,2064,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2067,2067,2067,2067,2066,2066,2066,2064,2064,2064,2064,2064,2066,2066,2066,2064,2064,2064,2064,2066,2067,2066,2066,2067,2067,2067,2067,2066,2066,2066,2066,2066,2066,2066,2066,2066,2067,2067,2067,2067,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2066,2064,2064,2064,2067,2067,2067,2067,2066,2067,2067,2067,2066,2067,2066,2066,2066,2066,2064,2064,2064,2066,2067,2067,2066,2067,2067,2066,2066,2066,2066,2067,2067,2067,2067,2067,2067,2067,2067,2067,2067,2067,2067,2066,2066,2066,2067,2067,2067,2067,2066,2066,2066,2067,2067,2067,2067,2067,2067,2067,2064,2064,2064,2064,2064,2064,2064,2064,2066,2066,2066,2066,2066,2067,2064,2064,2064,2064,2067,2067,2067,2064,2064,2064,2064,2067,2067,2067,2067,2067,2064,2064,2064,2064,2067,2067,2067,2067,2066,2066,2066,2064,2064,2064,2066,2067,2067,2067,2067,2067,2067,2066,2066,2066,2067],["BP","BP","BP","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Metro Fuel","Metro Fuel","Metro Fuel","Metro Fuel","Metro Fuel","Metro Fuel","Caltex","Caltex","Caltex","BP","BP","BP","Caltex","Caltex","Caltex","BP","BP","BP","BP","BP","BP","BP","Caltex","Caltex","Caltex","BP","Caltex","Caltex","Caltex","7-Eleven","7-Eleven","Metro Fuel","Metro Fuel","Metro Fuel","BP","BP","BP","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Metro Fuel","Metro Fuel","Metro Fuel","BP","BP","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","7-Eleven","7-Eleven","7-Eleven","Caltex","7-Eleven","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","BP","BP","BP","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Metro Fuel","Metro Fuel","Metro Fuel","BP","BP","BP","BP","BP","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","7-Eleven","7-Eleven","7-Eleven","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","7-Eleven","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","7-Eleven","7-Eleven","7-Eleven","7-Eleven","BP","BP","BP","BP","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Caltex","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","7-Eleven","7-Eleven","7-Eleven","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Metro Fuel","Metro Fuel","Caltex","Caltex","Caltex","Caltex","BP","BP","BP","Coles Express","Coles Express","Coles Express","Coles Express","Caltex","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","BP","BP","BP","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Caltex","Metro Fuel","Metro Fuel","Metro Fuel","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Caltex","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Caltex","Caltex","Caltex","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","BP","BP","BP","BP","Caltex","Caltex","Caltex","7-Eleven","7-Eleven","7-Eleven","7-Eleven","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","BP","BP","BP","BP","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","BP","BP","BP","Caltex","Caltex","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express","Coles Express"],["P98","P95","U91","P95","P98","E10","U91","P98","E10","U91","U91","P98","E10","P95","P98","U91","E10","E10","P98","U91","E10","U91","E10","P98","E10","E10","P95","E10","P98","P95","E10","P98","P98","E10","P95","P98","E10","P95","P95","E10","P98","LPG","P98","P95","E10","LPG","E10","P98","P95","LPG","LPG","P98","U91","E10","P95","P98","U91","U91","P98","U91","E10","P98","E10","P95","P95","E10","P98","P98","P95","U91","E10","E10","U91","P95","P98","P98","P98","P98","E10","E10","P98","U91","P95","P95","U91","P95","P98","P98","E10","U91","LPG","LPG","P95","P98","U91","E10","P98","P95","E10","U91","E10","P98","P95","U91","E10","P98","PDL","PDL","P95","P98","E10","P95","U91","P98","E10","P98","P95","U91","E10","E10","P95","U91","P98","P95","P98","E10","P95","E10","P98","E10","P95","P98","P98","E10","P95","U91","E10","U91","P98","LPG","P95","U91","P98","E10","U91","P95","E10","P98","P95","U91","P98","E10","E10","U91","P95","P98","U91","E10","P98","P98","E10","P95","E10","P98","P95","U91","E10","U91","P95","P98","PDL","P98","U91","P95","E10","P98","E10","P95","U91","PDL","PDL","PDL","E10","P95","P98","U91","P95","P98","E10","E10","P95","P98","U91","P98","P95","E10","E10","U91","P95","P98","P95","P98","U91","E10","PDL","PDL","PDL","PDL","P95","E10","P98","U91","P98","P95","U91","P98","P95","E10","P98","E10","U91","P98","U91","E10","P95","P98","E10","P95","E10","P98","P95","U91","P95","U91","P98","E10","P98","U91","E10","P95","DL","E10","U91","P98","P95","E10","E10","P98","P95","P98","U91","E10","P95","PDL","P95","E10","P98","U91","DL","DL","DL","P98","P95","E10","P95","P98","PDL","E10","PDL","PDL","P95","P98","PDL","U91","E10","U91","P95","P98","E10","DL","U91","P95","E10","LPG","P98","E10","P98","P95","P98","E10","P95","P95","U91","P98","E10","E10","P98","P95","P95","P98","E10","U91","P98","P95","E10","P98","P95","U91","E10","P98","U91","E10","P95","P98","P95","E10","DL","DL","DL","P98","P95","LPG","E10","P95","P98","E10","P98","U91","P95","E10","PDL","P98","E10","U91","P95","E10","PDL","P98","P95","E10","P95","U91","P98","E10","P95","P98","E10","P95","P98","PDL","PDL","P95","E10","P98","U91","P98","U91","P98","P95","P98"],["2017-03-01T07:22:29Z","2017-03-01T07:22:29Z","2017-03-01T07:22:29Z","2017-03-01T08:38:40Z","2017-03-01T08:38:40Z","2017-03-01T08:38:40Z","2017-03-01T08:38:40Z","2017-03-01T08:58:31Z","2017-03-01T08:58:31Z","2017-03-01T08:58:31Z","2017-03-01T16:46:57Z","2017-03-01T16:46:57Z","2017-03-01T16:46:57Z","2017-03-01T16:46:57Z","2017-03-01T16:58:55Z","2017-03-01T16:58:55Z","2017-03-01T16:58:55Z","2017-03-01T17:28:41Z","2017-03-01T17:28:41Z","2017-03-01T17:28:41Z","2017-03-01T17:52:08Z","2017-03-01T17:55:21Z","2017-03-01T17:55:21Z","2017-03-01T17:55:21Z","2017-03-01T17:55:59Z","2017-03-01T17:58:00Z","2017-03-02T10:58:04Z","2017-03-02T10:58:04Z","2017-03-02T10:58:04Z","2017-03-02T15:43:47Z","2017-03-02T15:43:47Z","2017-03-02T15:43:47Z","2017-03-03T12:27:11Z","2017-03-03T12:27:11Z","2017-03-03T12:27:11Z","2017-03-03T16:22:50Z","2017-03-03T16:22:50Z","2017-03-03T16:22:50Z","2017-03-04T13:34:54Z","2017-03-04T13:34:54Z","2017-03-04T13:34:54Z","2017-03-05T06:55:57Z","2017-03-05T12:01:03Z","2017-03-05T12:01:03Z","2017-03-05T12:01:03Z","2017-03-06T13:02:42Z","2017-03-06T13:56:27Z","2017-03-06T13:56:27Z","2017-03-06T13:56:27Z","2017-03-06T16:11:27Z","2017-03-06T16:11:27Z","2017-03-06T18:57:54Z","2017-03-06T18:57:54Z","2017-03-06T18:57:54Z","2017-03-07T06:30:58Z","2017-03-07T06:30:58Z","2017-03-07T06:30:58Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:24:41Z","2017-03-07T08:39:59Z","2017-03-07T08:39:59Z","2017-03-07T08:39:59Z","2017-03-07T09:01:59Z","2017-03-07T09:01:59Z","2017-03-07T09:01:59Z","2017-03-07T09:01:59Z","2017-03-07T09:59:29Z","2017-03-07T09:59:29Z","2017-03-07T10:23:27Z","2017-03-07T10:23:27Z","2017-03-07T10:56:44Z","2017-03-07T11:28:43Z","2017-03-08T08:25:00Z","2017-03-08T08:25:00Z","2017-03-08T08:26:00Z","2017-03-08T08:26:00Z","2017-03-08T08:26:00Z","2017-03-08T08:26:00Z","2017-03-08T08:26:00Z","2017-03-08T13:44:00Z","2017-03-08T13:44:00Z","2017-03-08T13:44:00Z","2017-03-08T20:17:17Z","2017-03-08T20:17:17Z","2017-03-08T20:17:17Z","2017-03-09T08:32:32Z","2017-03-09T08:32:43Z","2017-03-09T09:09:07Z","2017-03-09T09:09:07Z","2017-03-09T09:09:07Z","2017-03-09T09:09:07Z","2017-03-10T13:00:34Z","2017-03-10T13:00:34Z","2017-03-10T13:00:34Z","2017-03-10T13:03:25Z","2017-03-10T13:03:25Z","2017-03-10T13:03:25Z","2017-03-10T13:03:25Z","2017-03-10T16:22:44Z","2017-03-10T16:22:44Z","2017-03-10T16:22:44Z","2017-03-10T17:26:43Z","2017-03-10T17:52:51Z","2017-03-10T19:28:46Z","2017-03-10T19:28:46Z","2017-03-10T19:28:46Z","2017-03-10T21:37:02Z","2017-03-10T21:37:02Z","2017-03-10T21:37:02Z","2017-03-10T21:37:02Z","2017-03-10T21:58:49Z","2017-03-10T21:58:49Z","2017-03-10T21:58:49Z","2017-03-10T21:58:49Z","2017-03-10T22:28:50Z","2017-03-10T22:28:50Z","2017-03-10T22:28:50Z","2017-03-10T22:28:50Z","2017-03-11T11:11:20Z","2017-03-11T11:11:20Z","2017-03-11T11:11:20Z","2017-03-12T09:56:27Z","2017-03-12T09:56:27Z","2017-03-12T09:56:27Z","2017-03-12T11:37:34Z","2017-03-12T11:37:34Z","2017-03-12T11:37:34Z","2017-03-12T13:24:22Z","2017-03-12T13:24:22Z","2017-03-12T13:24:22Z","2017-03-12T13:24:22Z","2017-03-13T06:29:05Z","2017-03-13T06:29:05Z","2017-03-13T06:29:05Z","2017-03-13T08:46:53Z","2017-03-14T08:25:30Z","2017-03-14T08:25:30Z","2017-03-14T08:25:30Z","2017-03-14T10:38:32Z","2017-03-14T11:37:44Z","2017-03-14T11:37:44Z","2017-03-14T11:37:44Z","2017-03-14T11:37:44Z","2017-03-14T11:56:07Z","2017-03-14T11:56:07Z","2017-03-14T11:56:07Z","2017-03-14T11:56:07Z","2017-03-14T12:24:02Z","2017-03-14T12:24:02Z","2017-03-14T12:24:02Z","2017-03-14T12:24:02Z","2017-03-14T12:54:06Z","2017-03-14T12:54:06Z","2017-03-14T12:54:06Z","2017-03-14T14:56:04Z","2017-03-14T14:56:04Z","2017-03-14T14:56:04Z","2017-03-14T18:17:45Z","2017-03-14T18:17:45Z","2017-03-14T18:17:45Z","2017-03-14T18:17:45Z","2017-03-16T09:21:21Z","2017-03-16T09:21:21Z","2017-03-16T09:21:21Z","2017-03-16T09:21:21Z","2017-03-16T09:54:34Z","2017-03-16T09:54:36Z","2017-03-16T09:54:36Z","2017-03-16T09:54:36Z","2017-03-16T09:54:36Z","2017-03-16T10:26:34Z","2017-03-16T10:26:34Z","2017-03-16T10:26:34Z","2017-03-16T10:26:34Z","2017-03-16T11:48:13Z","2017-03-16T11:56:39Z","2017-03-16T12:25:34Z","2017-03-17T09:56:55Z","2017-03-17T09:56:55Z","2017-03-17T09:56:55Z","2017-03-19T10:56:37Z","2017-03-19T10:56:37Z","2017-03-19T10:56:37Z","2017-03-19T10:56:37Z","2017-03-19T11:04:05Z","2017-03-19T11:04:05Z","2017-03-19T11:04:05Z","2017-03-19T13:52:15Z","2017-03-19T13:52:15Z","2017-03-19T13:52:15Z","2017-03-19T13:52:15Z","2017-03-19T18:11:07Z","2017-03-20T07:45:39Z","2017-03-20T07:45:39Z","2017-03-20T07:45:39Z","2017-03-20T09:38:06Z","2017-03-20T09:38:06Z","2017-03-20T09:38:06Z","2017-03-20T09:38:06Z","2017-03-20T14:16:24Z","2017-03-20T14:56:52Z","2017-03-20T14:56:52Z","2017-03-20T15:26:52Z","2017-03-20T16:42:15Z","2017-03-20T16:42:15Z","2017-03-20T16:42:15Z","2017-03-20T16:42:15Z","2017-03-20T16:48:49Z","2017-03-20T16:48:49Z","2017-03-20T16:48:49Z","2017-03-20T16:54:16Z","2017-03-20T16:54:16Z","2017-03-20T16:54:16Z","2017-03-20T17:54:53Z","2017-03-20T17:54:53Z","2017-03-20T17:54:53Z","2017-03-21T07:58:30Z","2017-03-21T07:58:30Z","2017-03-21T07:58:30Z","2017-03-21T07:58:30Z","2017-03-21T08:20:13Z","2017-03-21T08:20:13Z","2017-03-21T08:20:13Z","2017-03-21T08:52:09Z","2017-03-21T08:52:09Z","2017-03-21T08:52:09Z","2017-03-21T08:52:09Z","2017-03-21T08:58:05Z","2017-03-21T08:58:05Z","2017-03-21T08:58:05Z","2017-03-21T08:58:05Z","2017-03-21T09:56:10Z","2017-03-21T09:56:10Z","2017-03-21T09:56:10Z","2017-03-21T09:56:10Z","2017-03-21T13:09:56Z","2017-03-21T13:09:56Z","2017-03-21T14:55:37Z","2017-03-21T14:55:37Z","2017-03-21T14:55:37Z","2017-03-21T14:55:37Z","2017-03-22T09:50:21Z","2017-03-22T09:50:21Z","2017-03-22T09:50:21Z","2017-03-22T09:56:10Z","2017-03-22T09:56:10Z","2017-03-22T09:56:10Z","2017-03-22T09:56:10Z","2017-03-22T14:24:22Z","2017-03-22T14:52:12Z","2017-03-22T14:52:12Z","2017-03-22T14:52:12Z","2017-03-23T07:30:52Z","2017-03-23T07:30:52Z","2017-03-23T07:30:52Z","2017-03-23T07:30:52Z","2017-03-23T07:33:25Z","2017-03-23T07:33:25Z","2017-03-23T10:35:21Z","2017-03-23T10:35:21Z","2017-03-23T10:35:21Z","2017-03-23T12:20:03Z","2017-03-23T12:52:24Z","2017-03-23T12:52:24Z","2017-03-23T12:52:24Z","2017-03-23T12:52:24Z","2017-03-23T12:52:24Z","2017-03-23T13:22:50Z","2017-03-23T20:04:33Z","2017-03-23T20:04:33Z","2017-03-23T20:04:41Z","2017-03-24T18:52:13Z","2017-03-24T18:52:13Z","2017-03-24T18:52:13Z","2017-03-25T10:40:05Z","2017-03-25T10:40:05Z","2017-03-25T10:40:05Z","2017-03-25T10:40:05Z","2017-03-25T10:40:05Z","2017-03-25T10:40:05Z","2017-03-25T14:52:34Z","2017-03-25T14:52:34Z","2017-03-25T14:52:34Z","2017-03-26T09:44:01Z","2017-03-26T09:44:01Z","2017-03-26T09:44:01Z","2017-03-26T09:57:12Z","2017-03-26T09:57:12Z","2017-03-26T09:57:12Z","2017-03-26T09:57:12Z","2017-03-27T08:43:01Z","2017-03-27T08:44:28Z","2017-03-27T08:44:28Z","2017-03-27T08:57:14Z","2017-03-27T08:57:14Z","2017-03-27T08:57:14Z","2017-03-27T08:57:14Z","2017-03-27T18:24:13Z","2017-03-27T18:24:13Z","2017-03-27T18:24:13Z","2017-03-28T00:36:22Z","2017-03-28T00:36:22Z","2017-03-28T00:36:22Z","2017-03-28T00:36:22Z","2017-03-28T06:54:20Z","2017-03-28T06:54:20Z","2017-03-28T06:54:20Z","2017-03-28T06:54:20Z","2017-03-28T09:36:29Z","2017-03-28T09:36:29Z","2017-03-28T09:36:29Z","2017-03-29T07:38:56Z","2017-03-29T07:38:56Z","2017-03-29T07:42:17Z","2017-03-29T09:44:45Z","2017-03-29T09:44:45Z","2017-03-29T09:44:45Z","2017-03-29T09:44:45Z","2017-03-29T10:52:50Z","2017-03-29T10:52:50Z","2017-03-29T10:52:50Z","2017-03-29T11:24:49Z","2017-03-29T11:24:49Z","2017-03-29T11:24:49Z","2017-03-29T11:24:49Z","2017-03-29T13:22:51Z","2017-03-29T14:50:12Z","2017-03-29T14:50:12Z","2017-03-29T14:50:12Z","2017-03-29T14:50:12Z","2017-03-30T11:56:50Z","2017-03-30T11:56:50Z","2017-03-30T11:56:50Z","2017-03-30T11:56:50Z","2017-03-30T15:11:00Z","2017-03-30T15:11:00Z","2017-03-30T15:11:00Z","2017-03-30T15:11:00Z","2017-03-30T15:24:02Z","2017-03-30T15:24:02Z","2017-03-30T15:24:02Z","2017-03-31T11:02:54Z","2017-03-31T11:02:54Z","2017-03-31T11:02:54Z","2017-03-31T12:14:00Z","2017-03-31T12:52:49Z","2017-03-31T16:50:02Z","2017-03-31T16:50:02Z","2017-03-31T16:50:02Z","2017-03-31T16:50:02Z","2017-03-31T16:51:02Z","2017-03-31T16:54:02Z","2017-03-31T16:54:02Z","2017-03-31T16:54:02Z","2017-03-31T19:34:59Z"],[147.9,140.9,129.9,140.9,145.9,127.9,129.9,145.9,127.9,129.9,130.9,149.9,128.9,142.9,158.9,139.9,137.9,128.9,149.9,130.9,129.9,129.9,126.9,146.5,129.9,126.9,149.4,135.4,156.4,149.9,135.9,158.9,155.9,134.9,148.9,156.9,133.9,147.9,142.9,128.9,151.9,72.9,154.9,147.9,133.9,70.9,128.9,149.9,142.9,70.9,70.9,144.8,126.9,123.9,137.9,144.9,126.9,126.9,142.9,126.9,124.9,142.9,124.9,137.9,151.4,133.4,158.4,156.4,149.4,132.9,131.4,125.9,127.9,139.9,146.9,149.9,146.9,154.7,129.7,129.3,154.3,130.8,147.7,147.3,132.9,149.9,155.9,139.9,119.9,124.8,65.9,68.9,146.9,153.9,130.4,128.9,151.7,144.7,126.7,129.4,127.9,152.9,145.9,124.9,122.9,140.9,134.9,129.9,141.9,148.9,127.9,138.9,126.9,145.9,124.9,146.9,139.9,127.9,125.9,124.9,138.9,126.9,145.9,140.9,149.9,126.9,140.9,126.9,147.9,122.9,140.9,147.9,140.9,122.9,135.9,124.9,115.9,117.8,136.7,70.9,135.9,124.9,142.9,122.9,125.9,137.9,123.9,144.9,138.9,126.9,145.9,124.9,123.9,125.9,137.9,144.9,122.9,120.9,138.9,143.9,122.9,136.9,122.9,143.9,136.9,124.9,120.9,122.9,134.9,141.9,127.9,143.9,124.9,136.9,122.9,141.9,120.9,134.9,122.9,129.9,127.9,129.9,119.9,133.9,140.9,127.4,143.9,150.9,125.9,120.7,138.7,145.7,121.9,137.9,132.9,119.9,119.9,117.9,128.9,135.9,128.9,133.9,117.9,115.9,132.9,134.7,129.9,132.9,142.5,124.5,149.5,126,150.9,144.9,127.9,144.7,137.7,119.7,133.9,115.9,117.9,146.8,123.3,121.8,139.8,142.9,117.9,135.9,116.9,137.9,130.9,118.9,134.9,122.9,141.9,120.9,137.9,118.9,116.9,130.9,128.5,114.9,117.9,136.9,129.9,115.9,117.9,144.9,135.9,142.9,119.4,117.9,135.9,132.3,131.9,117.9,138.9,121.9,133.9,133.9,133.9,144.9,138.9,115.9,129.9,138.9,131.6,115.9,133.9,132.3,129.9,136.9,131.6,115.8,112.9,115.9,128.9,135.9,114.9,133.9,119.4,135.9,117.9,79.9,142.9,113.9,134.9,127.9,141.9,116.9,134.9,135.4,118.9,142.4,117.4,115.9,140.9,133.9,134.5,141.5,116.5,118,133.9,126.9,112.9,132.9,127.9,116.9,114.9,130.9,114.9,112.9,125.9,139.9,132.9,114.9,131.9,131.9,131.9,137.9,128.9,70.9,114.9,125.9,132.9,111.9,129.9,113.9,124.9,111.9,133.4,140.9,115.9,117.4,133.9,113.9,133.9,136.9,127.9,114.9,132.9,116.4,139.9,112.9,130.9,137.9,111.9,125.9,134.9,131.4,132.7,131.9,113.9,138.9,115.4,139.9,120.9,143.9,137.9,138.9]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>ServiceStationName<\/th>\n      <th>Address<\/th>\n      <th>Suburb<\/th>\n      <th>Postcode<\/th>\n      <th>Brand<\/th>\n      <th>FuelCode<\/th>\n      <th>PriceUpdatedDate<\/th>\n      <th>Price<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[4,8]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"orderCellsTop":true}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->
Summarising Data
----------------

``` r
summary(DATA)
```

    ##  ServiceStationName   Address             Suburb             Postcode   
    ##  Length:51316       Length:51316       Length:51316       Min.   :1579  
    ##  Class :character   Class :character   Class :character   1st Qu.:2145  
    ##  Mode  :character   Mode  :character   Mode  :character   Median :2216  
    ##                                                           Mean   :2319  
    ##                                                           3rd Qu.:2529  
    ##                                                           Max.   :2880  
    ##     Brand             FuelCode         PriceUpdatedDate             
    ##  Length:51316       Length:51316       Min.   :2017-03-01 00:52:44  
    ##  Class :character   Class :character   1st Qu.:2017-03-08 11:58:09  
    ##  Mode  :character   Mode  :character   Median :2017-03-16 15:41:32  
    ##                                        Mean   :2017-03-16 09:52:01  
    ##                                        3rd Qu.:2017-03-23 14:01:21  
    ##                                        Max.   :2017-03-31 23:25:54  
    ##      Price      
    ##  Min.   : 60.0  
    ##  1st Qu.:119.4  
    ##  Median :128.4  
    ##  Mean   :128.4  
    ##  3rd Qu.:136.9  
    ##  Max.   :980.0

That's a lot of charaters that we're not getting summaries on. Lets convert all characters to factors, and the postcodes too.

``` r
for (j in which(sapply(DATA,is.character))) {
  set(DATA, j=j, value=factor(DATA[[j]], ordered = FALSE))
}

# Ask me why...
DATA <- DATA[,Postcode := factor(as.character(Postcode), ordered = FALSE)]
```

and try again:

``` r
summary(DATA, maxsum = 8)
```

    ##              ServiceStationName
    ##  Metro Fuel Young     :  328   
    ##  Metro Fuel Haberfield:  296   
    ##  Caltex Merrylands    :  281   
    ##  Caltex Seven Hills   :  273   
    ##  Caltex Moorebank     :  261   
    ##  Caltex Heathcote     :  246   
    ##  Caltex Ermington     :  215   
    ##  (Other)              :49416   
    ##                                                   Address     
    ##  186 Nasmyth St, Young NSW 2594                       :  328  
    ##  165 Parramatta Rd, Haberfield NSW 2045               :  296  
    ##  560-562 Victoria Rd Cnr Lawson St, Ermington NSW 2115:  215  
    ##  775 Princes Hwy, Tempe NSW 2044                      :  207  
    ##  78 Great Western Hwy Cnr Ross St, Glenbrook NSW 2773 :  192  
    ##  531 Princes Highway, Tempe NSW 2216                  :  185  
    ##  105 Station Rd Cnr Powers St, Seven Hills NSW 2147   :  179  
    ##  (Other)                                              :49714  
    ##          Suburb         Postcode                   Brand      
    ##  Seven Hills:  557   2170   : 1287   Caltex           :13993  
    ##  Blacktown  :  531   2148   :  876   7-Eleven         : 9471  
    ##  Merrylands :  505   2147   :  666   Caltex Woolworths: 6558  
    ##  Goulburn   :  488   2541   :  664   BP               : 5017  
    ##  Haberfield :  429   2580   :  649   Coles Express    : 4828  
    ##  Moorebank  :  421   2560   :  640   Metro Fuel       : 3610  
    ##  Northmead  :  401   2770   :  640   Independent      : 2145  
    ##  (Other)    :47984   (Other):45894   (Other)          : 5694  
    ##     FuelCode     PriceUpdatedDate                  Price      
    ##  E10    :12982   Min.   :2017-03-01 00:52:44   Min.   : 60.0  
    ##  P98    :12452   1st Qu.:2017-03-08 11:58:09   1st Qu.:119.4  
    ##  U91    :11876   Median :2017-03-16 15:41:32   Median :128.4  
    ##  P95    : 9999   Mean   :2017-03-16 09:52:01   Mean   :128.4  
    ##  PDL    : 1925   3rd Qu.:2017-03-23 14:01:21   3rd Qu.:136.9  
    ##  DL     : 1466   Max.   :2017-03-31 23:25:54   Max.   :980.0  
    ##  LPG    :  455                                                
    ##  (Other):  161

Lets focus in on our top four fuels.

``` r
DATA[,.N,by=FuelCode][order(-N)] %>%
  head(n=4) ->
  top4

DATA4 <- DATA[FuelCode %in% top4$FuelCode]
```

Visualising Data
----------------

``` r
p_load(ggplot2)
ggplot(data=DATA4) +
  scale_y_continuous(limits=c(75,200)) +
  geom_violin(aes(y=Price, x=Brand)) +
  facet_grid(FuelCode ~ ., scales='free_y') +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
```

    ## Warning: Removed 3 rows containing non-finite values (stat_ydensity).

![](RNotebooks_files/figure-markdown_github/unnamed-chunk-13-1.png)

``` r
g <- ggplot(data=DATA4[FuelCode == "U91"]) +
  geom_point(aes(y=Price, x=PriceUpdatedDate, colour=Brand), alpha=0.6, position='jitter') +
  scale_y_continuous(limits = c(75,175))
g
```

![](RNotebooks_files/figure-markdown_github/unnamed-chunk-14-1.png)

But what are those *really* cheap petrol prices...

Let's get a more interactive visualisation.

``` r
p_load(plotly)
g <- ggplot(data=DATA4[FuelCode == "U91"]) +
  geom_violin(aes(y=Price, x=Brand), colour="red", fill='red', alpha=0.25) +
  geom_boxplot(aes(y=Price, x=Brand), fill='transparent') +
  scale_y_continuous(limits = c(75,175)) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
```

``` r
print(g)
```

![](RNotebooks_files/figure-markdown_github/unnamed-chunk-16-1.png)

``` r
# Only in the RNotebook
ggplotly(g)
```

Copying Data To SQL Server
==========================

Save as CSV (or better!)
------------------------

``` r
write.csv(DATA, 'Service-Station-and-Price-History-March-2017.csv', row.names = FALSE)
```

A couple of quick file tests - do I have a nice CSV I can upload?

Short of writing significant chunks of code, `BCP` is the only way to upload data quickly into SQL Server, and it's *very* picky over its file formats; \* doesn't tollerate quotes very well \* can tollearate 'embeded' field separators (i.e. the quotes don't help) \* can't tollerate embedded row separators (i.e. a new line within a quoted string)

``` bash
< Service-Station-and-Price-History-March-2017.csv \
  tr -d -c ',\n' | 
  awk -e '1 {print length($0)}' | 
  sort | 
  uniq -c |
  sort -r -n
```

    ##   50907 8
    ##     408 9
    ##       1 7
    ##       1 10

``` r
ncol(DATA)
```

    ## [1] 8

``` bash
awk -F, -e 'NF != 9 {print}' Service-Station-and-Price-History-March-2017.csv | head
```

    ## "ServiceStationName","Address","Suburb","Postcode","Brand","FuelCode","PriceUpdatedDate","Price"
    ## "Fast and Ezy","104-106 Elizabeth Drive,, Liverpool NSW 2170","Liverpool","2170","Independent","E10",2017-03-01 09:20:00,125.9
    ## "Fast and Ezy","104-106 Elizabeth Drive,, Liverpool NSW 2170","Liverpool","2170","Independent","P98",2017-03-01 09:20:00,142.9
    ## "Fast and Ezy","104-106 Elizabeth Drive,, Liverpool NSW 2170","Liverpool","2170","Independent","U91",2017-03-01 09:20:00,127.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","P95",2017-03-01 13:51:34,137.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","E10",2017-03-01 13:51:34,123.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","U91",2017-03-01 13:51:34,125.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","DL",2017-03-01 13:51:34,122.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","PDL",2017-03-01 13:51:34,122.9
    ## "Metro Kurri Kurri","1-3, Victoria Street, Kurri Kurri NSW 2327","Kurri Kurri","2327","Metro Fuel","E10",2017-03-01 13:51:53,122.9

Blah! Commas in the addresses (and quotes that BCP won't like either).

Re-export using [ASCII Delimiters](https://ronaldduncan.wordpress.com/2009/10/31/text-file-formats-ascii-delimited-text-not-csv-or-tab-delimited-text/) 0x1F (Unit Separator) and 0x1E (Record Separator), and supress the quotes.

``` r
write.table(
  DATA, 
  'Service-Station-and-Price-History-March-2017.1F1E', 
  row.names = FALSE,
  quote = FALSE,
  sep = "\x1F",
  eol = "\x1E")
```

And re-test:

``` bash
< Service-Station-and-Price-History-March-2017.1F1E \
  tr -d -c $'\x1E\x1F' | 
  tr $'\x1E' '\n' |
  awk -e '1 {print length($0)}' | 
  sort | 
  uniq -c
```

    ##   51317 7

Upload the 1E1F
---------------

And load up the odbc driver and connection to local Microsoft SQL Server Database.

``` r
p_load(DBI)
p_load(odbc)
# drv <- dbDriver("ODBC")
con_template <- 'driver={SQL Server Native Client 11.0};Server=%s;Database=%s;Trusted_Connection=yes'
# db <- dbConnect(drv, connection = sprintf(con_template, server=".", database= "test")) 

db <- DBI::dbConnect(odbc::odbc(),.connection_string = sprintf(con_template, server=".", database= "test"))
```

``` r
p_load(DBI)
p_load(RPostgreSQL)
db <- dbConnect(PostgreSQL(), dbname="test")
```

Check that the DB is good

``` r
isPostgresqlIdCurrent(db)
```

    ## [1] TRUE

Drop the table if it already exists

``` sql
DROP TABLE IF EXISTS "Service-Station-and-Price-History-March-2017";
-- And return a result set to keep the RNotebook happy
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Service-Station-and-Price-History-March-2017';
```

Use R to sketch out the body of an SQL `CREATE TABLE`.

``` r
sprintf("%-20s %s not null,",
        colnames(DATA), 
        DATA %>%
          lapply(class) %>%
          sapply(head,1) %>%
          sapply(switch, 
               character = 'varchar(255)',
               POSIXct = 'datetime2(0)',
               numeric = 'numeric(4,1)')
  ) %>%
  paste0(collapse="\n") %>%
  cat
```

    ## ServiceStationName   NULL not null,
    ## Address              NULL not null,
    ## Suburb               NULL not null,
    ## Postcode             NULL not null,
    ## Brand                NULL not null,
    ## FuelCode             NULL not null,
    ## PriceUpdatedDate     datetime2(0) not null,
    ## Price                numeric(4,1) not null,

``` sql
CREATE TABLE "Service-Station-and-Price-History-March-2017"
(
    ServiceStationName      varchar(255) not null,
    Address                   varchar(255) not null,
    Suburb                  varchar(255) not null,
    Postcode                  char(4) not null,
    Brand                   varchar(255) not null,
    FuelCode                  char(3) not null,
    PriceUpdatedDate          datetime2(0) not null,
    Price                   numeric(4,1) not null
);
-- And return a result set to keep the RNotebook happy
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Service-Station-and-Price-History-March-2017';
```

``` sql
CREATE TABLE "Service-Station-and-Price-History-March-2017"
(
    ServiceStationName      varchar(255) not null,
    Address                   varchar(255) not null,
    Suburb                  varchar(255) not null,
    Postcode                  char(4) not null,
    Brand                   varchar(255) not null,
    FuelCode                  char(3) not null,
    PriceUpdatedDate          timestamp not null,
    Price                   numeric(4,1) not null
);
-- And return a result set to keep the RNotebook happy
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Service-Station-and-Price-History-March-2017';
```

| table\_catalog | table\_schema | table\_name                                  | table\_type | self\_referencing\_column\_name | reference\_generation | user\_defined\_type\_catalog | user\_defined\_type\_schema | user\_defined\_type\_name | is\_insertable\_into | is\_typed | commit\_action |
|:---------------|:--------------|:---------------------------------------------|:------------|:--------------------------------|:----------------------|:-----------------------------|:----------------------------|:--------------------------|:---------------------|:----------|:---------------|
| test           | public        | Service-Station-and-Price-History-March-2017 | BASE TABLE  | NA                              | NA                    | NA                           | NA                          | NA                        | YES                  | NO        | NA             |

### Upload for SQL Server

I can never remember the syntax for `bcp` fully, so lets get a copy here for reference.

``` bash
bcp
```

Now I can craft the `bcp` for upload.

``` bash
bcp \
  "dbo.[Service-Station-and-Price-History-March-2017]" \
  in \
  'Service-Station-and-Price-History-March-2017.1F1E' \
  -T -S . -d test \
  -c -t $'\x1F' -r $'\x1E' -C UTF-8 \
  -F 2 \
  -h TABLOCK -b 100000 \
  -e errors
```

Print out (the start of) any errors

``` bash
head errors
```

### Upload for Postgres

``` bash
< 'Service-Station-and-Price-History-March-2017.1F1E' \
  bbe -b ':/\x1E/' -e 'D 1;s/\\/\\\\/;s/\r/\\r/;s/\n/\\n/;s/\x1E/\n/' |
  psql test -c "COPY \"Service-Station-and-Price-History-March-2017\"
      FROM STDIN WITH DELIMITER AS E'\x1F'"
    
```

    ## COPY 51316

Querying from Database
======================

Now we can query from the database

``` r
fuel <- 'U91'
```

``` sql
SELECT ServiceStationName, Suburb, Brand, PriceUpdatedDate, Price
FROM "Service-Station-and-Price-History-March-2017"
WHERE FuelCode = ?fuel
ORDER BY Price ASC
```

``` r
DBDATA <- if (is.windows || has.postgres) data.table(DBDATA) else DATA
DBDATA[1:10]
```

    ##            servicestationname     suburb             brand
    ##  1:   Caltex Woolworths Cooma      Cooma Caltex Woolworths
    ##  2:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  3:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  4:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  5:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  6:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  7:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  8:      Metro Fuel Peakhurst  Peakhurst        Metro Fuel
    ##  9:     Metro Fuel Haberfield Haberfield        Metro Fuel
    ## 10: Metro Petroleum Islington  ISLINGTON        Metro Fuel
    ##        priceupdateddate price
    ##  1: 2017-03-21 08:45:48  91.0
    ##  2: 2017-03-29 22:05:34  98.9
    ##  3: 2017-03-31 22:04:11  98.9
    ##  4: 2017-03-26 22:05:40  99.9
    ##  5: 2017-03-25 22:04:08 100.9
    ##  6: 2017-03-24 22:09:48 100.9
    ##  7: 2017-03-23 22:11:41 101.7
    ##  8: 2017-03-22 22:13:53 102.4
    ##  9: 2017-03-29 22:02:00 103.7
    ## 10: 2017-03-31 19:41:50 103.7

Save data and read it back in many Languages
============================================

``` r
p_load(feather)
write_feather(DBDATA,"Service-Station-and-Price-History-March-2017.feather")
Sys.setenv(file_in="Service-Station-and-Price-History-March-2017")
```

``` python
import os
import pandas
import feather

file_in = os.environ["file_in"] + ".feather"
df = feather.read_dataframe(file_in)
print(df.head(10))
```

    ##           servicestationname      suburb              brand  \
    ## 0    Caltex Woolworths Cooma       Cooma  Caltex Woolworths   
    ## 1       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 2       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 3       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 4       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 5       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 6       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 7       Metro Fuel Peakhurst   Peakhurst         Metro Fuel   
    ## 8      Metro Fuel Haberfield  Haberfield         Metro Fuel   
    ## 9  Metro Petroleum Islington   ISLINGTON         Metro Fuel   
    ## 
    ##          priceupdateddate  price  
    ## 0 1970-01-18 05:54:06.348   91.0  
    ## 1 1970-01-18 06:06:25.534   98.9  
    ## 2 1970-01-18 06:09:18.251   98.9  
    ## 3 1970-01-18 06:02:06.340   99.9  
    ## 4 1970-01-18 06:00:39.848  100.9  
    ## 5 1970-01-18 05:59:13.788  100.9  
    ## 6 1970-01-18 05:57:47.501  101.7  
    ## 7 1970-01-18 05:56:21.233  102.4  
    ## 8 1970-01-18 06:06:25.320  103.7  
    ## 9 1970-01-18 06:09:09.710  103.7

``` python
import os
import pandas as pd

file_in = os.environ["file_in"] + ".csv"
df = pd.read_csv(file_in)
print(df.head(10))
```

    ##       ServiceStationName                                    Address  \
    ## 0      7-Eleven Kirrawee     542 Princes Highway, Kirrawee NSW 2232   
    ## 1      7-Eleven Kirrawee     542 Princes Highway, Kirrawee NSW 2232   
    ## 2      7-Eleven Kirrawee     542 Princes Highway, Kirrawee NSW 2232   
    ## 3    7-Eleven Kings Park       363 Vardys Road, Kings Park NSW 2148   
    ## 4     7-Eleven Blacktown      175 Richmond Road, Blacktown NSW 2148   
    ## 5    7-Eleven Kings Park       363 Vardys Road, Kings Park NSW 2148   
    ## 6     7-Eleven Blacktown        62 Walters Road, Blacktown NSW 2148   
    ## 7  7-Eleven Arndell Park  180 Reservoir Road, Arndell Park NSW 2148   
    ## 8     7-Eleven Blacktown      175 Richmond Road, Blacktown NSW 2148   
    ## 9     7-Eleven Blacktown        62 Walters Road, Blacktown NSW 2148   
    ## 
    ##          Suburb  Postcode     Brand FuelCode     PriceUpdatedDate  Price  
    ## 0      Kirrawee      2232  7-Eleven      U91  2017-03-01 00:52:43  131.9  
    ## 1      Kirrawee      2232  7-Eleven      E10  2017-03-01 00:52:43  129.9  
    ## 2      Kirrawee      2232  7-Eleven      P98  2017-03-01 00:52:43  147.9  
    ## 3    Kings Park      2148  7-Eleven      P98  2017-03-01 01:08:43  145.7  
    ## 4     Blacktown      2148  7-Eleven      U91  2017-03-01 01:08:43  129.7  
    ## 5    Kings Park      2148  7-Eleven      P95  2017-03-01 01:08:43  140.7  
    ## 6     Blacktown      2148  7-Eleven      P98  2017-03-01 01:08:43  145.7  
    ## 7  Arndell Park      2148  7-Eleven      E10  2017-03-01 01:08:43  127.7  
    ## 8     Blacktown      2148  7-Eleven      P98  2017-03-01 01:08:43  145.7  
    ## 9     Blacktown      2148  7-Eleven      U91  2017-03-01 01:08:43  129.7

``` perl
use Parse::CSV;
use Data::Dumper;
 
my $objects = Parse::CSV->new(
    file => $ENV{file_in} . '.csv',
    names      => 1,
);

my $max_rows = 3;
while ( my $row = $objects->fetch ) {
  print Dumper($row);
  if (--$max_rows <= 0) { last; }
}
```

    ## $VAR1 = {
    ##           'Address' => '542 Princes Highway, Kirrawee NSW 2232',
    ##           'PriceUpdatedDate' => '2017-03-01 00:52:43',
    ##           'Brand' => '7-Eleven',
    ##           'ServiceStationName' => '7-Eleven Kirrawee',
    ##           'Price' => '131.9',
    ##           'Postcode' => '2232',
    ##           'FuelCode' => 'U91',
    ##           'Suburb' => 'Kirrawee'
    ##         };
    ## $VAR1 = {
    ##           'PriceUpdatedDate' => '2017-03-01 00:52:43',
    ##           'Address' => '542 Princes Highway, Kirrawee NSW 2232',
    ##           'Price' => '129.9',
    ##           'ServiceStationName' => '7-Eleven Kirrawee',
    ##           'Brand' => '7-Eleven',
    ##           'Postcode' => '2232',
    ##           'Suburb' => 'Kirrawee',
    ##           'FuelCode' => 'E10'
    ##         };
    ## $VAR1 = {
    ##           'Brand' => '7-Eleven',
    ##           'ServiceStationName' => '7-Eleven Kirrawee',
    ##           'Price' => '147.9',
    ##           'PriceUpdatedDate' => '2017-03-01 00:52:43',
    ##           'Address' => '542 Princes Highway, Kirrawee NSW 2232',
    ##           'FuelCode' => 'P98',
    ##           'Suburb' => 'Kirrawee',
    ##           'Postcode' => '2232'
    ##         };

``` ruby
require 'csv'
require 'pp'
file_in = ENV["file_in"] + ".csv"
customers = CSV.read(file_in)
pp(customers[1..3])
```

    ## [["7-Eleven Kirrawee",
    ##   "542 Princes Highway, Kirrawee NSW 2232",
    ##   "Kirrawee",
    ##   "2232",
    ##   "7-Eleven",
    ##   "U91",
    ##   "2017-03-01 00:52:43",
    ##   "131.9"],
    ##  ["7-Eleven Kirrawee",
    ##   "542 Princes Highway, Kirrawee NSW 2232",
    ##   "Kirrawee",
    ##   "2232",
    ##   "7-Eleven",
    ##   "E10",
    ##   "2017-03-01 00:52:43",
    ##   "129.9"],
    ##  ["7-Eleven Kirrawee",
    ##   "542 Princes Highway, Kirrawee NSW 2232",
    ##   "Kirrawee",
    ##   "2232",
    ##   "7-Eleven",
    ##   "P98",
    ##   "2017-03-01 00:52:43",
    ##   "147.9"]]

Sillyness digression - what else can we do here?
================================================

LaTeX fragments!
----------------

$$
x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
$$

Which, of course, also means we can use set algebra notation:

$$ Query = { p | p\_{FuelCode} = }

$$

Tidy up after ourselves
=======================

``` r
if (!interactive()) {
  invisible({
    dbDisconnect(db)
  })
}
```

Sneaky Stuff
============

I've a local bash script
------------------------

The RNotebook mechanisms use a different strategy for executing code blocks (at lease bash one): namely that they write the text of the block to a temp file and then invoke the file along as:

`bash` *`file_name`*

Whereas the `knitr` engine invokes bash as `bash -c` *`code_block`*.

``` r
@rem bash.bat - a Windows batch file for invoking bash from RNotebooks
@echo off
SET BASH_PATH=C:\Users\Derek Slone-Zhen\.babun\cygwin\bin
PATH=%BASH_PATH%;%PATH%
"%BASH_PATH%\bash.exe" < "%~1"
```

Bulid Info & Version Control
============================

sessionInfo
-----------

``` r
sessionInfo()
```

    ## Warning in readLines("/etc/os-release"): incomplete final line found on '/
    ## etc/os-release'

    ## R version 3.3.3 (2017-03-06)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Linux Mint LMDE
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_AU.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_AU.UTF-8        LC_COLLATE=en_AU.UTF-8    
    ##  [5] LC_MONETARY=en_AU.UTF-8    LC_MESSAGES=en_AU.UTF-8   
    ##  [7] LC_PAPER=en_AU.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_AU.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] feather_0.3.1     RPostgreSQL_0.4-1 DBI_0.5          
    ##  [4] plotly_4.5.6      DT_0.2            readxl_0.1.1     
    ##  [7] data.table_1.9.6  ggplot2_2.2.1     magrittr_1.5     
    ## [10] pacman_0.4.1     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.6       plyr_1.8.4        highr_0.6        
    ##  [4] base64enc_0.1-3   tools_3.3.3       digest_0.6.12    
    ##  [7] jsonlite_1.4      evaluate_0.10     tibble_1.2       
    ## [10] gtable_0.2.0      viridisLite_0.2.0 yaml_2.1.14      
    ## [13] stringr_1.2.0     dplyr_0.5.0       httr_1.2.1       
    ## [16] knitr_1.15.1      hms_0.3           htmlwidgets_0.7  
    ## [19] rprojroot_1.2     grid_3.3.3        R6_2.1.3         
    ## [22] rmarkdown_1.4     reshape2_1.4.1    purrr_0.2.2      
    ## [25] tidyr_0.6.1       backports_1.0.5   scales_0.4.1     
    ## [28] htmltools_0.3.5   assertthat_0.1    colorspace_1.2-6 
    ## [31] labeling_0.3      stringi_1.1.5     lazyeval_0.2.0   
    ## [34] munsell_0.4.3     chron_2.3-47

Version Control
---------------

This code ensure that when we `knit` the document, all changes get committed to `git` and the SHA1 checksum of that commit is embedded in the document for reproducability.

``` bash
git add -A .
git commit -m "Knitting..."
git rev-parse HEAD
```

    ## [master c59a64d] Knitting...
    ##  2 files changed, 819 insertions(+), 801 deletions(-)
    ##  rewrite RNotebooks.md (73%)
    ## c59a64d31a0914816c9880e37c4ff7ab0bc356f6
