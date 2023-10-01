cap pr drop A
pr def A
foreach var of varlist * {
label variable `var' "`=`var'[1]'"
replace `var' = ""   if   _n == 1
}
drop in 1/2 
end

import excel  "C:\Users\A.S.U.K.A\Desktop\AF_Actual.xlsx",sheet("sheet1") firstrow clear
A
g year = substr(D,1,4)
keep S y M
destring *, force replace
duplicates drop S y, force
save 1, replace

import excel "C:\Users\A.S.U.K.A\Desktop\AF_Forecast_1.xlsx", sheet("sheet1") firstrow clear
A
save 2

import excel "C:\Users\A.S.U.K.A\Desktop\AF_Forecast_2.xlsx", sheet("sheet1") firstrow clear
A
save 3

import excel "C:\Users\A.S.U.K.A\Desktop\AF_Forecast_3.xlsx", sheet("sheet1") firstrow clear
A
save 4

use 2, clear
append using 3 4
g year = substr(Fe,1,4)
keep S y Fn
destring *, force replace
drop if F == .
order S y 
sort S y
bys S y: egen MeanF = mean(F)
bys S y: egen SdF = sd(F)
drop F
duplicates drop 
merge 1:1 St y using 1, nogen keep(1 3)

* 分析师预测偏差度：FERRORnt=Abs[Mean(Fnt)-Mnt]/Abs(Mnt)
* 分析师预测分歧度：FDISPnt=Sd(Fnt)/Abs(Mnt)
g FERROR = abs(MeanF - Mnetpro)/abs(Mnetpro)
g FDISP  = SdF / abs(Mnetpro)
drop if Mnetpro == .
foreach i of var F*{
winsor `i', g(`i'_w) p(0.01)
}
su St y *_w