clear all

/* 1. Preparing data from the Norwegian Patient Registry (NPR) */
use "Norwegian_Patient_Registry", clear
count

/* We only use inpatient stays (admissions) to define the outcomes */
gen admission = 0 
replace admission = 1 if behandlingsniva3 == 1 | aktivitetskategori3 == 1 | omsorgsniva == 1
count
keep if admission == 1
keep if fodtaar_dsf >= 1992
count
drop if inn_aar < 2008 | inn_aar > 2021  
count



gen outc_explisepsis = 0
foreach var of varlist /*diagunderl*/ tilstand_1_1{
        replace outc_explisepsis = 1 if (substr(`var', 1, 3) == "A021"  | ///
		substr(`var', 1, 4) == "A207"  | ///
		substr(`var', 1, 4) == "A217"  | ///
		substr(`var', 1, 4) == "A227"  | ///
		substr(`var', 1, 4) == "A241"  | ///
		substr(`var', 1, 4) == "A267"  | ///
		substr(`var', 1, 4) == "A282"  | ///
		substr(`var', 1, 4) == "A327"  | ///
		substr(`var', 1, 4) == "A394"  | ///
		substr(`var', 1, 3) == "A40"  | ///
		substr(`var', 1, 3) == "A41"  | ///
		substr(`var', 1, 4) == "A427"  | ///
		substr(`var', 1, 5) == "A5486"  | ///
		substr(`var', 1, 4) == "B007"  | ///
		substr(`var', 1, 4) == "B377"  | ///
		substr(`var', 1, 3) == "O85"  | ///
		substr(`var', 1, 3) == "P36"  | ///
		substr(`var', 1, 4) == "R572"  | ///
		substr(`var', 1, 4) == "R651")
}
label variable outc_explisepsis "outc_explisepsis"


gen imsepsis = 0
foreach var of varlist /*diagunderl*/ tilstand_1_1{
        replace imsepsis = 1 if (substr(`var', 1, 3) == "A00"  | ///				
		substr(`var', 1, 3) == "A01"  | ///
		substr(`var', 1, 3) == "A02"  | ///
		substr(`var', 1, 3) == "A03"  | ///
		substr(`var', 1, 3) == "A04"  | ///
		substr(`var', 1, 3) == "A05"  | ///
		substr(`var', 1, 3) == "A06"  | ///
		substr(`var', 1, 3) == "A07"  | ///
		substr(`var', 1, 3) == "A08"  | ///
		substr(`var', 1, 3) == "A09"  | ///
		substr(`var', 1, 3) == "A19"  | ///
		substr(`var', 1, 3) == "A20"  | ///
		substr(`var', 1, 3) == "A21"  | ///
		substr(`var', 1, 3) == "A22"  | ///
		substr(`var', 1, 3) == "A23"  | ///
		substr(`var', 1, 3) == "A24"  | ///
		substr(`var', 1, 3) == "A25"  | ///
		substr(`var', 1, 3) == "A26"  | ///
		substr(`var', 1, 3) == "A27"  | ///
		substr(`var', 1, 3) == "A28"  | ///
		substr(`var', 1, 3) == "A30"  | ///
		substr(`var', 1, 3) == "A31"  | ///
		substr(`var', 1, 3) == "A32"  | ///
		substr(`var', 1, 3) == "A36"  | ///
		substr(`var', 1, 3) == "A37"  | ///
		substr(`var', 1, 3) == "A38"  | ///
		substr(`var', 1, 3) == "A39"  | ///
		substr(`var', 1, 3) == "A42"  | ///
		substr(`var', 1, 3) == "A43"  | ///
		substr(`var', 1, 3) == "A44"  | ///
		substr(`var', 1, 3) == "A46"  | ///
		substr(`var', 1, 3) == "A48"  | ///
		substr(`var', 1, 3) == "A49"  | ///
		substr(`var', 1, 3) == "A54"  | ///
		substr(`var', 1, 3) == "A59"  | ///
		substr(`var', 1, 4) == "A690"  | ///
		substr(`var', 1, 4) == "A691"  | ///
		substr(`var', 1, 4) == "A699"  | ///
		substr(`var', 1, 3) == "A70"  | ///
		substr(`var', 1, 3) == "A74"  | ///
		substr(`var', 1, 3) == "A75"  | ///
		substr(`var', 1, 3) == "A77"  | ///
		substr(`var', 1, 3) == "A78"  | ///
		substr(`var', 1, 3) == "A79"  | ///
		substr(`var', 1, 3) == "A80"  | ///
		substr(`var', 1, 3) == "A81"  | ///
		substr(`var', 1, 3) == "A83"  | ///
		substr(`var', 1, 3) == "A84"  | ///
		substr(`var', 1, 3) == "A85"  | ///
		substr(`var', 1, 3) == "A86"  | ///
		substr(`var', 1, 3) == "A87"  | ///
		substr(`var', 1, 3) == "A88"  | ///
		substr(`var', 1, 3) == "A89"  | ///
		substr(`var', 1, 3) == "A90"  | ///
		substr(`var', 1, 3) == "A91"  | ///
		substr(`var', 1, 3) == "A92"  | ///
		substr(`var', 1, 3) == "A93"  | ///
		substr(`var', 1, 3) == "A94"  | ///
		substr(`var', 1, 3) == "A95"  | ///
		substr(`var', 1, 3) == "A96"  | ///
		substr(`var', 1, 3) == "A98"  | ///
		substr(`var', 1, 3) == "A99"  | ///
		substr(`var', 1, 3) == "B00"  | ///
		substr(`var', 1, 3) == "B01"  | ///
		substr(`var', 1, 3) == "B02"  | ///
		substr(`var', 1, 3) == "B03"  | ///
		substr(`var', 1, 3) == "B04"  | ///
		substr(`var', 1, 3) == "B05"  | ///
		substr(`var', 1, 3) == "B06"  | ///
		substr(`var', 1, 3) == "B08"  | ///
		substr(`var', 1, 3) == "B09"  | ///
		substr(`var', 1, 3) == "B10"  | ///
		substr(`var', 1, 3) == "B25"  | ///
		substr(`var', 1, 3) == "B26"  | ///
		substr(`var', 1, 3) == "B27"  | ///
		substr(`var', 1, 3) == "B33"  | ///
		substr(`var', 1, 3) == "B34"  | ///
		substr(`var', 1, 3) == "B37"  | ///
		substr(`var', 1, 3) == "B38"  | ///
		substr(`var', 1, 3) == "B39"  | ///
		substr(`var', 1, 3) == "B40"  | ///
		substr(`var', 1, 3) == "B41"  | ///
		substr(`var', 1, 3) == "B42"  | ///
		substr(`var', 1, 3) == "B43"  | ///
		substr(`var', 1, 3) == "B44"  | ///
		substr(`var', 1, 3) == "B45"  | ///
		substr(`var', 1, 3) == "B46"  | ///
		substr(`var', 1, 3) == "B48"  | ///
		substr(`var', 1, 3) == "B49"  | ///
		substr(`var', 1, 3) == "B50"  | ///
		substr(`var', 1, 3) == "B54"  | ///
		substr(`var', 1, 3) == "B55"  | ///
		substr(`var', 1, 3) == "B57"  | ///
		substr(`var', 1, 3) == "B58"  | ///
		substr(`var', 1, 3) == "B59"  | ///
		substr(`var', 1, 3) == "B60"  | ///
		substr(`var', 1, 3) == "B64"  | ///
		substr(`var', 1, 3) == "B67"  | ///
		substr(`var', 1, 3) == "B95"  | ///
		substr(`var', 1, 3) == "B96"  | ///
		substr(`var', 1, 3) == "B97"  | ///
		substr(`var', 1, 3) == "B99")
}
label variable imsepsis "imsepsis"


foreach var of varlist /*diagunderl*/ tilstand_1_1{
        replace imsepsis = 1 if (substr(`var', 1, 3) == "G00"  | ///
		substr(`var', 1, 3) == "G01"  | ///
		substr(`var', 1, 3) == "G02"  | ///
		substr(`var', 1, 3) == "G03"  | ///
		substr(`var', 1, 3) == "G04"  | ///
		substr(`var', 1, 3) == "G05"  | ///
		substr(`var', 1, 3) == "G06"  | ///
		substr(`var', 1, 3) == "G07"  | ///
		substr(`var', 1, 3) == "G08"  | ///
		substr(`var', 1, 5) == "H0501"  | ///
		substr(`var', 1, 5) == "H0502"  | ///
		substr(`var', 1, 5) == "H0503"  | ///
		substr(`var', 1, 4) == "H602"  | ///
		substr(`var', 1, 4) == "H700"  | ///
		substr(`var', 1, 3) == "I00"  | ///
		substr(`var', 1, 5) == "I2601"  | ///
		substr(`var', 1, 5) == "I2690"  | ///
		substr(`var', 1, 3) == "I33"  | ///
		substr(`var', 1, 3) == "I38"  | ///
		substr(`var', 1, 3) == "I39"  | ///
		substr(`var', 1, 4) == "I400"  | ///
		substr(`var', 1, 3) == "I76"  | ///
		substr(`var', 1, 3) == "I96"  | ///
		substr(`var', 1, 3) == "J01"  | ///
		substr(`var', 1, 3) == "J02"  | ///
		substr(`var', 1, 3) == "J03"  | ///
		substr(`var', 1, 3) == "J04"  | ///
		substr(`var', 1, 3) == "J05"  | ///
		substr(`var', 1, 3) == "J06"  | ///
		substr(`var', 1, 3) == "J09"  | ///
		substr(`var', 1, 3) == "J10"  | ///
		substr(`var', 1, 3) == "J11"  | ///
		substr(`var', 1, 3) == "J12"  | ///
		substr(`var', 1, 3) == "J13"  | ///
		substr(`var', 1, 3) == "J14"  | ///
		substr(`var', 1, 3) == "J15"  | ///
		substr(`var', 1, 3) == "J16"  | ///
		substr(`var', 1, 3) == "J17"  | ///
		substr(`var', 1, 3) == "J18"  | ///
		substr(`var', 1, 3) == "J20"  | ///
		substr(`var', 1, 3) == "J21"  | ///
		substr(`var', 1, 3) == "J22"  | ///
		substr(`var', 1, 3) == "J36"  | ///
		substr(`var', 1, 4) == "J390"  | ///
		substr(`var', 1, 4) == "J391"  | ///
		substr(`var', 1, 3) == "J85"  | ///
		substr(`var', 1, 3) == "J86"  | ///
		substr(`var', 1, 3) == "K35"  | ///
		substr(`var', 1, 3) == "K36"  | ///
		substr(`var', 1, 3) == "K37"  | ///
		substr(`var', 1, 3) == "K57"  | ///
		substr(`var', 1, 3) == "K61"  | ///
		substr(`var', 1, 4) == "K630"  | ///
		substr(`var', 1, 4) == "K631"  | ///
		substr(`var', 1, 3) == "K65"  | ///
		substr(`var', 1, 4) == "K750"  | ///
		substr(`var', 1, 4) == "K810"  | ///
		substr(`var', 1, 4) == "K812"  | ///
		substr(`var', 1, 4) == "K830"  | ///
		substr(`var', 1, 5) == "K9501"  | ///
		substr(`var', 1, 5) == "K9581"  | ///
		substr(`var', 1, 3) == "L02"  | ///
		substr(`var', 1, 3) == "L03"  | ///
		substr(`var', 1, 3) == "L04"  | ///
		substr(`var', 1, 3) == "L08"  | ///
		substr(`var', 1, 3) == "M00"  | ///
		substr(`var', 1, 3) == "M01"  | ///
		substr(`var', 1, 3) == "M86"  | ///
		substr(`var', 1, 3) == "N10"  | ///
		substr(`var', 1, 4) == "N151"  | ///
		substr(`var', 1, 3) == "N30"  | ///
		substr(`var', 1, 4) == "N390"  | ///
		substr(`var', 1, 4) == "N410"  | ///
		substr(`var', 1, 4) == "N412"  | ///
		substr(`var', 1, 4) == "N413"  | ///
		substr(`var', 1, 3) == "N45"  | ///
		substr(`var', 1, 3) == "N70"  | ///
		substr(`var', 1, 3) == "N71"  | ///
		substr(`var', 1, 3) == "N72"  | ///
		substr(`var', 1, 3) == "N73"  | ///
		substr(`var', 1, 3) == "N74"  | ///
		substr(`var', 1, 4) == "N980"  | ///
		substr(`var', 1, 4) == "O030"  | ///
		substr(`var', 1, 4) == "O035"  | ///
		substr(`var', 1, 5) == "O0388"  | ///
		substr(`var', 1, 4) == "O045"  | ///
		substr(`var', 1, 5) == "O0488"  | ///
		substr(`var', 1, 5) == "O0738"  | ///
		substr(`var', 1, 4) == "O080"  | ///
		substr(`var', 1, 5) == "O0883"  | ///
		substr(`var', 1, 3) == "O23"  | ///
		substr(`var', 1, 4) == "O753"  | ///
		substr(`var', 1, 3) == "O86"  | ///
		substr(`var', 1, 4) == "O883"  | ///
		substr(`var', 1, 3) == "O91"  | ///
		substr(`var', 1, 3) == "O98"  | ///
		substr(`var', 1, 5) == "R7881"  | ///
		substr(`var', 1, 4) == "T802"  | ///
		substr(`var', 1, 4) == "T814"  | ///
		substr(`var', 1, 4) == "T826"  | ///
		substr(`var', 1, 4) == "T827"  | ///
		substr(`var', 1, 4) == "T835"  | ///
		substr(`var', 1, 4) == "T836"  | ///
		substr(`var', 1, 4) == "T845"  | ///
		substr(`var', 1, 4) == "T846"  | ///
		substr(`var', 1, 4) == "T847"  | ///
		substr(`var', 1, 4) == "T857"  | ///
		substr(`var', 1, 4) == "T880"  | ///
		substr(`var', 1, 3) == "U04")
}

gen organdys = 0
foreach var of varlist /*diagunderl*/ tilstand_*{
        replace organdys = 1 if (substr(`var', 1, 3) == "D65"  | ///
		substr(`var', 1, 4) == "D695"  | ///
		substr(`var', 1, 4) == "E872"  | ///
		substr(`var', 1, 4) == "G934"  | ///
		substr(`var', 1, 3) == "I46"  | ///
		substr(`var', 1, 4) == "I959"  | ///
		substr(`var', 1, 3) == "J80"  | ///
		substr(`var', 1, 4) == "J952"  | ///
		substr(`var', 1, 4) == "J960"  | ///
		substr(`var', 1, 4) == "J962"  | ///
		substr(`var', 1, 3) == "J96"  | ///
		substr(`var', 1, 4) == "J969"  | ///
		substr(`var', 1, 4) == "K720"  | ///
		substr(`var', 1, 4) == "K729"  | ///
		substr(`var', 1, 3) == "N00"  | ///
		substr(`var', 1, 3) == "N17"  | ///
		substr(`var', 1, 5) == "R0902"  | ///
		substr(`var', 1, 4) == "R092"  | ///
		substr(`var', 1, 4) == "R400"  | ///
		substr(`var', 1, 4) == "R401"  | ///
		substr(`var', 1, 4) == "R402"  | ///
		substr(`var', 1, 5) == "R4020"  | ///
		substr(`var', 1, 5) == "R4182"  | ///
		substr(`var', 1, 3) == "R55"  | ///
		substr(`var', 1, 3) == "R57"  | ///
		substr(`var', 1, 4) == "M726"  | ///
		substr(`var', 1, 3) == "M00"  | ///
		substr(`var', 1, 4) == "M013"  | ///
		substr(`var', 1, 4) == "M860"  | ///
		substr(`var', 1, 4) == "M861"  | ///
		substr(`var', 1, 4) == "M862"  | ///
		substr(`var', 1, 4) == "M869"  | ///
		substr(`var', 1, 3) == "A40"  | ///
		substr(`var', 1, 3) == "A41"  | ///
		substr(`var', 1, 4) == "A483"  | ///
		substr(`var', 1, 4) == "R572"  | ///
		substr(`var', 1, 3) == "B95"  | ///
		substr(`var', 1, 3) == "B96"  | ///
		substr(`var', 1, 4) == "I330"  | ///
		substr(`var', 1, 4) == "I339"  | ///
		substr(`var', 1, 3) == "I38")
}
label variable organdys "organdys"


gen outc_sepsis = 0
replace outc_sepsis = 1 if (imsepsis == 1 & organdys == 1) | outc_explisepsis == 1
gen outc_implisittsepsis = 0
replace outc_implisittsepsis = 1 if (outc_sepsis == 1 & outc_explisepsis == 0)

keep if outc_sepsis == 1
count

save "Datafiler/npr_pre_infections3.dta", replace

/* 2. Preparing data from the Medical Birth Registry */
describe using "Norwegian_Medical_Birth_Registry"
use "Norwegian_Medical_Birth_Registry", clear
drop if faar < 1992 | faar > 2021  
count


/* Calculating gestational age */
gen svlen_dg = svlen_art_dg
replace svlen_dg = svlen_ul_dg if svlen_dg == .
replace svlen_dg = svlen_sm_dg if svlen_dg == .
count if svlen_dg == .

/* completed weeks */
gen svlen = int(svlen_dg/7)

/* now create categories etc. */
egen gact_infs = cut(svlen), at(23 28 32 34 37 39 42 45) label
label var gact_infs "Gestational age in categories for infections"
summarize gact_infs
tabstat svlen, by(gact_infs) stats(min max)

/* Marsal z-score calculations */

* Marsal z-score
* Males
gen bw_Marsal = ((-1.907345*10^-6)*svlen_dg^4) + ((1.140644*10^-3)* svlen_dg^3) ///
+ ((-1.336265*10^-1)* svlen_dg^2)  + ((1.976961*10^0)* svlen_dg) + (2.410053*10^2) if kjonn==1 
* Females
replace bw_Marsal = ((-2.761948*10^-6)* svlen_dg^4) + ((1.744841*10^-3)* svlen_dg^3) ///
+ ((-2.893626*10^-1)* svlen_dg^2)  + ((1.891197*10^1)* svlen_dg) + (-4.135122*10^2) if kjonn==2
* Unknown
replace bw_Marsal = ((-2.278843*10^-6)* svlen_dg^4) + ((1.402168*10^-3)* svlen_dg^3) ///
+ ((-2.008726*10^-1)* svlen_dg^2)  + ((9.284121*10^0)* svlen_dg) + (-4.125956*10^1) if kjonn==.
gen Marsal_pc = (vekt - bw_Marsal)*100/bw_Marsal  // percent deviation from expected
gen Marsal_zs = Marsal_pc/11  // number of standard deviations from expected, one sd is set to 11%
/*drop births with marsal score -6 og +4sd*/
gen sga_limit_6sd = bw_Marsal - (bw_Marsal*0.66)
gen lga_limit_4sd = bw_Marsal*1.44
* SGA 6 SD (minus > 6 sd)
gen sga_6sd = 0 if svlen_dg!=. & vekt!=.
replace sga_6sd =1 if (vekt < sga_limit_6sd) & svlen_dg!=. & vekt!=.
* LGA 4 SD (plus > 4 sd)
gen lga_4sd = 0 if svlen_dg!=. & vekt!=.
replace lga_4sd =1 if (vekt > lga_limit_4sd) & svlen_dg!=. & vekt!=.
* SD score
gen Marsal_SD = (vekt - bw_Marsal)/(bw_Marsal*0.11)


/* Excluding certain births (Flow-chart) */
gen pop_infs = 1
replace pop_infs = 0 if lopenr_barn == . |  inlist(dodkat, 7, 8, 9)
replace pop_infs = 0 if svlen_dg == .
replace pop_infs = 0 if svlen < 23 | svlen > 44
replace pop_infs = 0 if faar < 1987 & svlen < 26
replace pop_infs = 0 if inlist(dodkat, 7, 8, 9)
replace pop_infs = 0 if vekt == .
replace pop_infs = 0 if vekt < 300
replace pop_infs = 0 if vekt >= 6500
replace pop_infs = 0 if sga_6sd == 1
replace pop_infs = 0 if lga_4sd == 1
replace pop_infs = 0 if mors_alder > 55
count
local NN = r(N)
drop if pop_infs == 0
count

di `NN'- r(N)
drop pop_infs
count
save "Datafiler\mfr_pop_infs3.dta", replace



/* 3. Merging Medical Birth Registry with admissions from NPR */
use "Datafiler\mfr_pop_infs3.dta", clear

rename lopenr_barn_a lopenr


/* Merging death date and underlying cause of death */
merge 1:1 lopenr using "Norwegian_Cause_of_Death_Registry", keepusing(dmnd daar diagunderl alle_koder eushort)
drop if _merge == 2
drop _merge

destring dmnd daar, replace
gen deathdate = mdy(dmnd, 15, daar)
format deathdate %d
drop if daar < 2008

/* Merging emigration date */
merge 1:1 lopenr using "Emigration_dates"

drop if _merge == 2
drop _merge
gen emidate = mdy(emigrert_mnd, 15, emigrert_aar)
format emidate %d
drop if emigrert_aar < 2008


gen gact_cat = ""
replace gact_cat = "23-27 weeks" if inrange(svlen, 23, 27)
replace gact_cat = "28-31 weeks" if inrange(svlen, 28, 31)
replace gact_cat = "32-33 weeks" if inrange(svlen, 32, 33)
replace gact_cat = "34-36 weeks" if inrange(svlen, 34, 36)
replace gact_cat = "37-38 weeks" if inrange(svlen, 37, 38)
replace gact_cat = "39-41 weeks" if inrange(svlen, 39, 41)
replace gact_cat = "42-44 weeks" if inrange(svlen, 42, 44)
label variable gact_cat "Gestational age category"

/******************************************************************************
Ensure that missing values remain truly missing and are never assigned 0
******************************************************************************/

/* 1. Birth Month */
gen birth_month = fmnd

/* 2. Method for Defining Gestational Age */
gen gest_age_mnum = .
replace gest_age_mnum = 1 if !missing(svlen_ul_dg)
replace gest_age_mnum = 2 if missing(svlen_ul_dg) & !missing(svlen_sm_dg)
replace gest_age_mnum = 3 if missing(svlen_ul_dg) & missing(svlen_sm_dg) & !missing(svlen_art_dg)
tab gest_age_mnum
 
/* 3. Start of Labor */
gen fstart_g = .
replace fstart_g = 0 if fstart == 1  // Spontaneous
replace fstart_g = 1 if fstart == 2  // Induced
replace fstart_g = 1 if fstart == 3  // Induced
tab fstart_g

/* 4. Country of Birth */
gen country_of_birth = fodeland_kat_nor_gbd
replace country_of_birth = 1 if fodeland_kat_nor_gbd == 201
replace country_of_birth = 0 if inrange(fodeland_kat_nor_gbd, 202, 2.147e+09)
replace country_of_birth = 0 if inrange(fodeland_kat_nor_gbd, 1, 200)

/* 5. Parity */
gen paritet_g = .
replace paritet_g = 0 if paritet_mor == 0
replace paritet_g = 1 if paritet_mor > 0 & !missing(paritet_mor)


/***************************************************************************
   NEW: Assigning Variable Labels and Value Labels for Descriptive Table
***************************************************************************/
label define gest_age_label 1 "Ultrasound" 2 "LMP" 3 "ART"
label values gest_age_mnum gest_age_label
label var gest_age_mnum "Gestational Age Calc Method"

label define fstart_label 0 "Spontaneous" 1 "Induced/CS before labor"
label values fstart_g fstart_label
label var fstart_g "Onset of Labor"

label define parity_label 0 "Nulliparous (0)" 1 "Multiparous (1+)"
label values paritet_g parity_label
label var paritet_g "Parity"

label define cob_label 1 "Norway" 0 "Other"
label values country_of_birth cob_label
label var country_of_birth "Mother's Country of Birth"

label define sex_label 1 "Male" 2 "Female"
label values kjonn sex_label
label var kjonn "Sex"


/* === Frame for Time Contribution in Different Age Groups === */
/* Adjusting the age groups as per your request */
gen birthdate = mdy(fmnd, 15, faar)
gen t1_3to11 = floor(birthdate + 92)                   // 3 months after birth
gen t2_3to11 = floor(birthdate + 365.25)               // Up to 1 year
gen t1_1to5 = floor(birthdate + 365.25)                // 1 year
gen t2_1to5 = floor(birthdate + (6 * 365.25))          // Up to 6 years
gen t1_6to15 = floor(birthdate + (6 * 365.25))         // 6 years
gen t2_6to15 = floor(birthdate + (16 * 365.25))        // Up to 16 years

/* Defining time-period when persons contribute with time in age-groups */
foreach var of varlist t1* t2* {
    replace `var' = deathdate if !missing(deathdate) & deathdate < `var'
    replace `var' = emidate if !missing(emidate) & emidate < `var'
    replace `var' = mdy(01, 15, 2008) if `var' < mdy(01, 15, 2008)
    replace `var' = mdy(12, 15, 2021) if `var' > mdy(12, 15, 2021)
}

/* Generating time-contribution in age-groups */
gen prsndays_3to11 = t2_3to11 - t1_3to11
gen prsndays_1to5 = t2_1to5 - t1_1to5
gen prsndays_6to15 = t2_6to15 - t1_6to15

drop if prsndays_3to11 == 0 & prsndays_1to5 == 0 & prsndays_6to15 == 0
count


// This is the Analysis population. In the following, add admissions




merge 1:m lopenr using "Datafiler\npr_pre_infections3.dta"

drop if _merge == 2 // Drop rows if lopenr is only in the second dataset
drop _merge

/* Generating necessary variables */
gen id_str = "ID" + string(_n)
gen admdate = mdy(inn_mnd, 15, inn_aar)
format admdate %d

label variable inn_aar "Year of admission"
/* Ensure admdate and liggetid are numeric before creating disdate2 */
gen disdate2 = admdate + real(liggetid)
format disdate2 %d

*
/* Counting length of stay for infection admissions in the age groups */
foreach agegroup in 3to11 1to5 6to15 {
    gen inn_`agegroup' = admdate
    gen ut_`agegroup' = disdate2
    replace inn_`agegroup' = t1_`agegroup' if admdate < t1_`agegroup'
    replace ut_`agegroup' = t1_`agegroup' if disdate2 < t1_`agegroup'
    replace inn_`agegroup' = t2_`agegroup' if admdate > t2_`agegroup'
    replace ut_`agegroup' = t2_`agegroup' if disdate2 > t2_`agegroup'
    
    gen liggetid_`agegroup' = ut_`agegroup' - inn_`agegroup'
    egen sumliggetid_`agegroup' = total(liggetid_`agegroup'), by(lopenr)
}
*/


/* Subtract relevant infection stay length from total person days */
foreach agegroup in 3to11 1to5 6to15 {
    gen prsndays_`agegroup'_xlos = prsndays_`agegroup' - sumliggetid_`agegroup'
}

/* Converting to person-years */
foreach agegroup in 3to11 1to5 6to15 {
    gen prsnyrs_`agegroup'_xlos = prsndays_`agegroup'_xlos / 365.25
    replace prsnyrs_`agegroup'_xlos = . if prsnyrs_`agegroup'_xlos <= 0
}

/* Counting number of admissions within each age- and outcome group */
foreach var of varlist outc* {
    foreach agegroup in 3to11 1to5 6to15 {
        egen n_`agegroup'_`var' = total(`var' * (admdate >= t1_`agegroup') * (admdate < t2_`agegroup')), by(lopenr)
    }
}
count

/* Generating follow-up age category */
gen fu_age_cat = ""
gen age_at_admission_days = admdate - birthdate

replace fu_age_cat = "Under 3 months" if age_at_admission_days < 92
replace fu_age_cat = "3-11 months"   if inrange(age_at_admission_days, 92, 365)
replace fu_age_cat = "1-5 years"     if inrange(age_at_admission_days, 365, 1826)
replace fu_age_cat = "6-15 years"    if inrange(age_at_admission_days, 1826, 5840)
replace fu_age_cat = "16-29 years" if inrange(age_at_admission_days, 5840, 10584)   // 16*365 = 5840, 29*365 = 10585
replace fu_age_cat = "30-54 years" if inrange(age_at_admission_days, 10585, 19709) // 30*365 = 10950, 54*365 = 19710
replace fu_age_cat = "55+ years"   if inrange(age_at_admission_days, 19710, 99999)

/* Handle missing values */
replace fu_age_cat = "missing" if age_at_admission_days == .

label variable fu_age_cat "Follow-Up Age Category"



* 1) Create an indicator for 3 mo <= age_at_admission < 15 years
gen byte age_3mo_15 = (age_at_admission_days >= 92 & age_at_admission_days < 15*365.25)

/******************************************************************************
 (A) ALL ADMISSIONS IN 3 MO–15 YRS
******************************************************************************/
display "=== (A) ALL ADMISSIONS in [3 mo–15 yrs] ==="
count if age_3mo_15==1

* 2) Unique persons with ANY admission in that age range
bysort lopenr: gen byte tag_3mo15_any = 0
by lopenr: replace tag_3mo15_any = 1 if age_3mo_15==1 & tag_3mo15_any==0
display "Unique persons who had an admission at 3 mo–15 yrs:"
count if tag_3mo15_any==1


/******************************************************************************
 (B) SEPSIS (outc_sepsis == 1) IN 3 MO–15 YRS
******************************************************************************/
display ""
display "=== (B) SEPSIS (outc_sepsis==1) in [3 mo–15 yrs] ==="

* 3) Total sepsis admissions in that age range
count if outc_sepsis==1 & age_3mo_15==1

* 4) Unique persons with sepsis in that age range
bysort lopenr: gen byte tag_3mo15_sepsis = 0
by lopenr: replace tag_3mo15_sepsis = 1 if outc_sepsis==1 & age_3mo_15==1 & tag_3mo15_sepsis==0
display "Unique persons with sepsis at 3 mo–15 yrs:"
count if tag_3mo15_sepsis==1


save "Datafiler\pre_one_row_per.dta", replace


/* Creating a dataset with one row per person */
sort lopenr
by lopenr: gen n1 = _n
keep if n1 == 1
count
replace outc_sepsis = 0 if outc_sepsis==.
save "Analysis_file", replace


