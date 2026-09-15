	/*******************************************************************************
4. Descriptive Statistics and Main Analyses
*******************************************************************************/
clear all
/* Load the one-row-per-person dataset */
use "Datafiler\analysefil_final_august2026.dta", clear


/*******************************************************************************
    Generate Descriptive Statistics, by Gestational Age
*******************************************************************************/

/* Descriptive statistics stratified by gestational age categories, for each of the
three analysis populations (based on follow-up age) */


/*******************************************************************************
1. Create the new categorical variable for maternal age
*******************************************************************************/

gen maternal_age_cat = (mors_alder > 35) if !missing(mors_alder)

label define mage_label 0 "<35 years" 1 ">35 years"
label values maternal_age_cat mage_label
label var maternal_age_cat "Maternal Age"


/*******************************************************************************
2. Prepare the postfile to store the stratified results

The first output dataset is kept in long format. Additional variables are stored
only so that a second, more readable wide-format dataset can subsequently be
created.

mean_value and sd_value are used for continuous variables such as birthweight.
*******************************************************************************/

postfile desc_crosstab ///
        str20 age_group ///
        byte gact_code ///
        str40 gact_category ///
        str32 var_name ///
        str50 var_label ///
        double level_value ///
        str50 cat_label ///
        double count ///
        double percent ///
        double mean_value ///
        double sd_value ///
        using "Resultater\Descriptive_Crosstab_Output.dta", replace


/*******************************************************************************
3. Define the list of categorical row variables for the descriptive table
*******************************************************************************/

/*
    `gact_infs' is removed as it is now the stratification variable (columns).
    `maternal_age_cat' is added.

    Birthweight (`vekt') is NOT included here because it is continuous and is
    handled separately as mean (SD).
*/

local row_vars "kjonn maternal_age_cat paritet_g fstart_g country_of_birth gest_age_mnum"


/*******************************************************************************
4. Loop through each analysis age group
*******************************************************************************/

foreach agegroup in 3to11 1to5 6to15 {

    di as text "Processing descriptives for analysis group: `agegroup'"


    /***************************************************************************
    A. Define the population for this specific analysis
    ***************************************************************************/

    tempvar has_time
    gen `has_time' = ///
        (prsnyrs_`agegroup'_xlos > 0 & prsnyrs_`agegroup'_xlos != .)

    tempvar num_sibs_in_group
    bysort lopenr_mor_a: egen `num_sibs_in_group' = total(`has_time')

    tempvar pop_for_analysis
    gen `pop_for_analysis' = ///
        (`has_time' == 1 & `num_sibs_in_group' > 1)


    /***************************************************************************
    B. Get the different gestational-age levels for this population
    ***************************************************************************/

    qui levelsof gact_infs if `pop_for_analysis' == 1, local(gact_levels)


    /***************************************************************************
    C. Loop through each gestational-age category
    ***************************************************************************/

    foreach gact of local gact_levels {

        /*
            Denominator for this gestational-age column
        */

        qui count if ///
            gact_infs == `gact' & ///
            `pop_for_analysis' == 1

        local N_gact_denominator = r(N)


        if `N_gact_denominator' > 0 {

            local gact_label : label (gact_infs) `gact'


            /*******************************************************************
            Post the column total (N)
            *******************************************************************/

            post desc_crosstab ///
                ("`agegroup'") ///
                (`gact') ///
                ("`gact_label'") ///
                ("__TOTAL__") ///
                ("Total N") ///
                (-999) ///
                ("") ///
                (`N_gact_denominator') ///
                (100) ///
                (.) ///
                (.)


            /*******************************************************************
            D. Birthweight: calculate mean and standard deviation

            `vekt' is treated as a continuous variable.

            The mean and SD are calculated among children with nonmissing
            birthweight within this age-group × gestational-age group.
            *******************************************************************/

            quietly summarize vekt if ///
                gact_infs == `gact' & ///
                `pop_for_analysis' == 1

            local N_vekt = r(N)
            local mean_vekt = r(mean)
            local sd_vekt = r(sd)


            /*
                Post Birthweight (g), mean (SD), provided there is at least
                one nonmissing birthweight observation.
            */

            if `N_vekt' > 0 {

                post desc_crosstab ///
                    ("`agegroup'") ///
                    (`gact') ///
                    ("`gact_label'") ///
                    ("__VEKT_MEANSD__") ///
                    ("Birthweight (g), mean (SD)") ///
                    (-998) ///
                    ("") ///
                    (`N_vekt') ///
                    (.) ///
                    (`mean_vekt') ///
                    (`sd_vekt')
            }


            /*******************************************************************
            E. Birthweight missing

            Add a separate Missing row if birthweight is missing for any
            children in this age-group × gestational-age group.
            *******************************************************************/

            quietly count if ///
                missing(vekt) & ///
                gact_infs == `gact' & ///
                `pop_for_analysis' == 1

            local n_vekt_missing = r(N)


            if `n_vekt_missing' > 0 {

                local pct_vekt_missing = ///
                    (`n_vekt_missing' / `N_gact_denominator') * 100


                post desc_crosstab ///
                    ("`agegroup'") ///
                    (`gact') ///
                    ("`gact_label'") ///
                    ("vekt") ///
                    ("Birthweight") ///
                    (999999) ///
                    ("Missing") ///
                    (`n_vekt_missing') ///
                    (`pct_vekt_missing') ///
                    (.) ///
                    (.)
            }


            /*******************************************************************
            F. Loop through each categorical characteristic
            *******************************************************************/

            foreach var of local row_vars {

                local varname_label : var label `var'


                /***************************************************************
                G. Loop through the observed levels of the characteristic
                variable
                ***************************************************************/

                qui levelsof `var' if ///
                    gact_infs == `gact' & ///
                    `pop_for_analysis' == 1, ///
                    local(levels)


                foreach l of local levels {

                    qui count if ///
                        `var' == `l' & ///
                        gact_infs == `gact' & ///
                        `pop_for_analysis' == 1

                    local n_cell = r(N)

                    local pct_cell = ///
                        (`n_cell' / `N_gact_denominator') * 100


                    local catname_label : label (`var') `l'

                    if `"`catname_label'"' == "" {
                        local catname_label = "`l'"
                    }


                    /***********************************************************
                    H. Post count and percentage for this cell
                    ***********************************************************/

                    post desc_crosstab ///
                        ("`agegroup'") ///
                        (`gact') ///
                        ("`gact_label'") ///
                        ("`var'") ///
                        ("`varname_label'") ///
                        (`l') ///
                        ("`catname_label'") ///
                        (`n_cell') ///
                        (`pct_cell') ///
                        (.) ///
                        (.)
                }


                /***************************************************************
                I. Add Missing row when missing observations exist

                Missing is calculated using the same full gestational-age
                denominator as the other percentages.

                A Missing row is included only if at least one observation is
                missing for that characteristic.
                ***************************************************************/

                qui count if ///
                    missing(`var') & ///
                    gact_infs == `gact' & ///
                    `pop_for_analysis' == 1

                local n_missing = r(N)


                if `n_missing' > 0 {

                    local pct_missing = ///
                        (`n_missing' / `N_gact_denominator') * 100


                    post desc_crosstab ///
                        ("`agegroup'") ///
                        (`gact') ///
                        ("`gact_label'") ///
                        ("`var'") ///
                        ("`varname_label'") ///
                        (999999) ///
                        ("Missing") ///
                        (`n_missing') ///
                        (`pct_missing') ///
                        (.) ///
                        (.)
                }
            }
        }
    }
}


postclose desc_crosstab

di as text ///
    "Long-format descriptive data saved to Descriptive_Crosstab_Output.dta"



/*******************************************************************************
5. Create a wide, human-readable version of the descriptive table
*******************************************************************************/

use "Resultater\Descriptive_Crosstab_Output.dta", clear


/*******************************************************************************
5A. Define display order for age groups
*******************************************************************************/

gen byte age_order = .

replace age_order = 1 if age_group == "3to11"
replace age_order = 2 if age_group == "1to5"
replace age_order = 3 if age_group == "6to15"



/*******************************************************************************
5B. Define display sections and row order

This affects ONLY how the readable output is arranged.
It does not change any counts, percentages, means, or standard deviations.
*******************************************************************************/

gen byte var_order = .

replace var_order = 1  if var_name == "__TOTAL__"

/*
    Child characteristics:
        Birthweight
        Birthweight missing, if present
        Sex
        Onset of labor
*/

replace var_order = 10 if var_name == "__VEKT_MEANSD__"
replace var_order = 11 if var_name == "vekt"

replace var_order = 20 if var_name == "kjonn"
replace var_order = 30 if var_name == "fstart_g"

/*
    Pregnancy dating
*/

replace var_order = 40 if var_name == "gest_age_mnum"

/*
    Maternal birth country
*/

replace var_order = 50 if var_name == "country_of_birth"

/*
    Other maternal factors
*/

replace var_order = 60 if var_name == "paritet_g"
replace var_order = 70 if var_name == "maternal_age_cat"



/*******************************************************************************
5C. Create section headings similar to the HTML table
*******************************************************************************/

gen str40 section = ""

replace section = "Sample size" ///
    if var_name == "__TOTAL__"


replace section = "Child characteristics" ///
    if inlist(var_name, ///
        "__VEKT_MEANSD__", ///
        "vekt", ///
        "kjonn", ///
        "fstart_g")


replace section = "Pregnancy dating" ///
    if var_name == "gest_age_mnum"


replace section = "Maternal birth country" ///
    if var_name == "country_of_birth"


replace section = "Other maternal factors" ///
    if inlist(var_name, ///
        "paritet_g", ///
        "maternal_age_cat")



/*******************************************************************************
5D. Define within-characteristic category order
*******************************************************************************/

gen double cat_order = level_value


/*
    Total N first
*/

replace cat_order = -999 ///
    if var_name == "__TOTAL__"


/*
    Birthweight mean (SD) before any birthweight Missing row
*/

replace cat_order = -998 ///
    if var_name == "__VEKT_MEANSD__"


/*
    Show Norway before Other country in the readable output,
    matching the HTML-style table.
*/

replace cat_order = 0 ///
    if var_name == "country_of_birth" & ///
    cat_label == "Norway"


replace cat_order = 1 ///
    if var_name == "country_of_birth" & ///
    cat_label == "Other"


/*
    Always place Missing last within its characteristic.
*/

replace cat_order = 999999 ///
    if cat_label == "Missing"



/*******************************************************************************
5E. Create a single readable row label
*******************************************************************************/

gen str100 characteristic = ///
    var_label + ": " + cat_label


/*
    Total sample size
*/

replace characteristic = "Total N" ///
    if var_name == "__TOTAL__"


/*
    Continuous birthweight row
*/

replace characteristic = "Birthweight (g), mean (SD)" ///
    if var_name == "__VEKT_MEANSD__"



/*******************************************************************************
5F. Format table cells

Categorical variables:

        percentage (count)

Total-N row:

        N=count

Birthweight:

        mean (SD)

The long-format dataset retains full numeric precision.
Only this readable display dataset is formatted/rounded.
*******************************************************************************/

gen str20 n_display = ///
    subinstr( ///
        strtrim(string(count, "%12.0fc")), ///
        ",", ///
        " ", ///
        . ///
    )


/*
    Default formatting for categorical variables
*/

gen str40 table_cell = ///
    strtrim(string(percent, "%9.1f")) + ///
    " (" + n_display + ")"


/*
    Total-N formatting
*/

replace table_cell = ///
    "N=" + n_display ///
    if var_name == "__TOTAL__"


/*
    Birthweight mean (SD) formatting
*/

replace table_cell = ///
    strtrim(string(mean_value, "%9.1f")) + ///
    " (" + ///
    strtrim(string(sd_value, "%9.1f")) + ///
    ")" ///
    if var_name == "__VEKT_MEANSD__"



/*******************************************************************************
5G. Keep only the variables needed to construct the readable table
*******************************************************************************/

keep ///
    age_group ///
    age_order ///
    section ///
    var_order ///
    cat_order ///
    characteristic ///
    gact_code ///
    table_cell



/*******************************************************************************
5H. Reshape so gestational-age groups become columns
*******************************************************************************/

reshape wide table_cell, ///
    i(age_group age_order section var_order cat_order characteristic) ///
    j(gact_code)



/*******************************************************************************
5I. Ensure all seven gestational-age columns exist
*******************************************************************************/

capture confirm variable table_cell0
if _rc {
    gen str40 table_cell0 = ""
}


capture confirm variable table_cell1
if _rc {
    gen str40 table_cell1 = ""
}


capture confirm variable table_cell2
if _rc {
    gen str40 table_cell2 = ""
}


capture confirm variable table_cell3
if _rc {
    gen str40 table_cell3 = ""
}


capture confirm variable table_cell4
if _rc {
    gen str40 table_cell4 = ""
}


capture confirm variable table_cell5
if _rc {
    gen str40 table_cell5 = ""
}


capture confirm variable table_cell6
if _rc {
    gen str40 table_cell6 = ""
}



/*******************************************************************************
5J. Give the gestational-age columns readable names

gact_infs coding:
    0 = 23-27 weeks
    1 = 28-31 weeks
    2 = 32-33 weeks
    3 = 34-36 weeks
    4 = 37-38 weeks
    5 = 39-41 weeks
    6 = 42+ weeks
*******************************************************************************/

rename table_cell0 GA_23_27
rename table_cell1 GA_28_31
rename table_cell2 GA_32_33
rename table_cell3 GA_34_36
rename table_cell4 GA_37_38
rename table_cell5 GA_39_41
rename table_cell6 GA_42plus


label variable GA_23_27  "23-27 weeks"
label variable GA_28_31  "28-31 weeks"
label variable GA_32_33  "32-33 weeks"
label variable GA_34_36  "34-36 weeks"
label variable GA_37_38  "37-38 weeks"
label variable GA_39_41  "39-41 weeks"
label variable GA_42plus "42+ weeks"



/*******************************************************************************
5K. Sort rows to resemble the HTML table
*******************************************************************************/

sort age_order var_order cat_order



/*******************************************************************************
5L. Replace analysis-age codes with readable labels
*******************************************************************************/

replace age_group = "Age 3-11 months" ///
    if age_group == "3to11"


replace age_group = "Age 1-5 years" ///
    if age_group == "1to5"


replace age_group = "Age 6-15 years" ///
    if age_group == "6to15"



/*******************************************************************************
5M. Arrange the columns for easy viewing in Stata's Data Browser
*******************************************************************************/

order ///
    age_group ///
    section ///
    characteristic ///
    GA_23_27 ///
    GA_28_31 ///
    GA_32_33 ///
    GA_34_36 ///
    GA_37_38 ///
    GA_39_41 ///
    GA_42plus


drop age_order var_order cat_order


label variable age_group      "Age group"
label variable section        "Section"
label variable characteristic "Characteristic"



/*******************************************************************************
5N. Save the combined readable table
*******************************************************************************/

save ///
    "Resultater\Descriptive_Crosstab_Readable.dta", ///
    replace


di as text ///
    "Readable wide-format descriptive table saved to Descriptive_Crosstab_Readable.dta"



/*******************************************************************************
5O. Also save one compact file for each analysis age group

These are especially convenient when taking screenshots.
*******************************************************************************/

preserve

    keep if age_group == "Age 3-11 months"
    drop age_group

    save ///
        "Resultater\Descriptive_Crosstab_Readable_3to11.dta", ///
        replace

restore


preserve

    keep if age_group == "Age 1-5 years"
    drop age_group

    save ///
        "Resultater\Descriptive_Crosstab_Readable_1to5.dta", ///
        replace

restore


preserve

    keep if age_group == "Age 6-15 years"
    drop age_group

    save ///
        "Resultater\Descriptive_Crosstab_Readable_6to15.dta", ///
        replace

restore



/*******************************************************************************
Display the readable output
*******************************************************************************/

browse



/*******************************************************************************
4. Analysis
*******************************************************************************/

clear all


/* Step 1: build the mother-level education file, and validate it BEFORE using it */

use "N:\durable\infs\utdanning\utdanning_a_mor", clear

bysort lopenr_mor_a: egen check = sd(medu_highest_NUS2021)

tab check


* Look at any mothers where the value isn't constant across rows

list lopenr_mor_a medu_highest_NUS2021 ///
    if check > 0 & check != ., ///
    sepby(lopenr_mor_a)


* Only proceed once you've confirmed check is 0/missing everywhere
* (i.e. the list above is empty)

keep lopenr_mor_a medu_highest_NUS2021

duplicates drop lopenr_mor_a, force

save ///
    "N:\durable\infs\utdanning\utdanning_a_mor_unique.dta", ///
    replace



/* Step 2: load the main dataset and merge */

use ///
    "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
    clear

merge m:1 lopenr_mor_a using ///
    "N:\durable\infs\utdanning\utdanning_a_mor_unique.dta"

tab _merge


codebook paritet_g gest_age_mnum

tab paritet_g

tab gest_age_mnum



/*******************************************************************************
Main analyses
*******************************************************************************/

/* Open postfile to store the output for main analyses */

postfile Table_output_justert ///
    str40 YVAR ///
    str40 ESTTYPE ///
    EST ///
    LCI ///
    UCI ///
    using ///
    "Resultater\Table_output_justert.dta", ///
    replace



/* Main outcome variables */

foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    if strpos("`yvar'", "3to11") > 0 {

        gen prsnyrs = prsnyrs_3to11_xlos
    }

    else if strpos("`yvar'", "1to5") > 0 {

        gen prsnyrs = prsnyrs_1to5_xlos
    }

    else if strpos("`yvar'", "6to15") > 0 {

        gen prsnyrs = prsnyrs_6to15_xlos
    }


    replace prsnyrs = . if prsnyrs <= 0


    nbreg `yvar' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        gest_age_mnum, ///
        irr ///
        vce(robust) ///
        exposure(prsnyrs)


    foreach cat of numlist 0 1 2 3 4 6 {

        local irr = ///
            exp(_b[`cat'.gact_infs])

        local lci = ///
            exp(_b[`cat'.gact_infs] - ///
            invnormal(0.975)*_se[`cat'.gact_infs])

        local uci = ///
            exp(_b[`cat'.gact_infs] + ///
            invnormal(0.975)*_se[`cat'.gact_infs])


        post Table_output_justert ///
            ("`yvar'") ///
            ("IRR, GACT `cat'") ///
            (`irr') ///
            (`lci') ///
            (`uci')
    }


    margins i.gact_infs, ///
        predict(ir) ///
        atmeans


    matrix M = r(b)

    matrix V = r(V)


    local n_categories = colsof(M)


    forvalues i = 1/`n_categories' {

        local est = M[1,`i']

        local se = sqrt(V[`i',`i'])

        local lci = ///
            `est' - invnormal(0.975)*`se'

        local uci = ///
            `est' + invnormal(0.975)*`se'

        local cat = `i' - 1


        post Table_output_justert ///
            ("`yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop prsnyrs
}


postclose Table_output_justert

/*
/*******************************************************************************
Education sensitivity analysis
*******************************************************************************/

/* Open postfile to store the output for main analyses */

postfile Table_output_justert_edu ///
    str40 YVAR ///
    str40 ESTTYPE ///
    EST ///
    LCI ///
    UCI ///
    using ///
    "Resultater\Table_output_justert_edu.dta", ///
    replace



/* Main outcome variables */

foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    if strpos("`yvar'", "3to11") > 0 {

        gen prsnyrs = prsnyrs_3to11_xlos
    }

    else if strpos("`yvar'", "1to5") > 0 {

        gen prsnyrs = prsnyrs_1to5_xlos
    }

    else if strpos("`yvar'", "6to15") > 0 {

        gen prsnyrs = prsnyrs_6to15_xlos
    }


    replace prsnyrs = . if prsnyrs <= 0


    nbreg `yvar' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        i.medu_highest_NUS2021
        gest_age_mnum, ///
        irr ///
        vce(robust) ///
        exposure(prsnyrs)


    foreach cat of numlist 0 1 2 3 4 6 {

        local irr = ///
            exp(_b[`cat'.gact_infs])

        local lci = ///
            exp(_b[`cat'.gact_infs] - ///
            invnormal(0.975)*_se[`cat'.gact_infs])

        local uci = ///
            exp(_b[`cat'.gact_infs] + ///
            invnormal(0.975)*_se[`cat'.gact_infs])


        post Table_output_justert_edu ///
            ("`yvar'") ///
            ("IRR, GACT `cat'") ///
            (`irr') ///
            (`lci') ///
            (`uci')
    }


    margins i.gact_infs, ///
        predict(ir) ///
        atmeans


    matrix M = r(b)

    matrix V = r(V)


    local n_categories = colsof(M)


    forvalues i = 1/`n_categories' {

        local est = M[1,`i']

        local se = sqrt(V[`i',`i'])

        local lci = ///
            `est' - invnormal(0.975)*`se'

        local uci = ///
            `est' + invnormal(0.975)*`se'

        local cat = `i' - 1


        post Table_output_justert_edu ///
            ("`yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop prsnyrs
}


postclose Table_output_justert_edu
*/
/*******************************************************************************
4.2 Analyses using explicit sepsis codes
*******************************************************************************/

/* Reload the main analysis dataset */

use ///
    "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
    clear


/* Open postfile to store the results */

postfile Table_output_justert_expl ///
    str40 YVAR ///
    str40 ESTTYPE ///
    double EST ///
    double LCI ///
    double UCI ///
    using ///
    "Resultater\Table_output_justert_expl.dta", ///
    replace


/* Explicit-sepsis-code outcome variables */

foreach yvar of varlist ///
    n_3to11_outc_explisepsis ///
    n_1to5_outc_explisepsis ///
    n_6to15_outc_explisepsis {

    if strpos("`yvar'", "3to11") > 0 {

        gen prsnyrs = prsnyrs_3to11_xlos
    }

    else if strpos("`yvar'", "1to5") > 0 {

        gen prsnyrs = prsnyrs_1to5_xlos
    }

    else if strpos("`yvar'", "6to15") > 0 {

        gen prsnyrs = prsnyrs_6to15_xlos
    }


    replace prsnyrs = . if prsnyrs <= 0


    nbreg `yvar' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        gest_age_mnum, ///
        irr ///
        vce(robust) ///
        exposure(prsnyrs)


    /* Store adjusted incidence rate ratios */

    foreach cat of numlist 0 1 2 3 4 6 {

        local irr = ///
            exp(_b[`cat'.gact_infs])

        local lci = ///
            exp(_b[`cat'.gact_infs] - ///
            invnormal(0.975)*_se[`cat'.gact_infs])

        local uci = ///
            exp(_b[`cat'.gact_infs] + ///
            invnormal(0.975)*_se[`cat'.gact_infs])


        post Table_output_justert_expl ///
            ("`yvar'") ///
            ("IRR, GACT `cat'") ///
            (`irr') ///
            (`lci') ///
            (`uci')
    }


    /* Store adjusted incidence rates */

    margins i.gact_infs, ///
        predict(ir) ///
        atmeans


    matrix M = r(b)

    matrix V = r(V)


    local n_categories = colsof(M)


    forvalues i = 1/`n_categories' {

        local est = M[1,`i']

        local se = sqrt(V[`i',`i'])

        local lci = ///
            `est' - invnormal(0.975)*`se'

        local uci = ///
            `est' + invnormal(0.975)*`se'

        local cat = `i' - 1


        post Table_output_justert_expl ///
            ("`yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop prsnyrs
}


postclose Table_output_justert_expl



/*******************************************************************************
4.3 Sensitivity analysis

Respiratory failure does not qualify as organ dysfunction when the main
diagnosis is a respiratory tract infection and no nonrespiratory organ
dysfunction is present.
*******************************************************************************/

/* Reload the main analysis dataset */

use ///
    "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
    clear


/*******************************************************************************
4.3.1 Identify respiratory tract infection as the main diagnosis
*******************************************************************************/

gen byte main_rti = 0


replace main_rti = 1 if ///
    substr(tilstand_1_1, 1, 3) == "J00" | ///
    substr(tilstand_1_1, 1, 3) == "J01" | ///
    substr(tilstand_1_1, 1, 3) == "J02" | ///
    substr(tilstand_1_1, 1, 3) == "J03" | ///
    substr(tilstand_1_1, 1, 3) == "J04" | ///
    substr(tilstand_1_1, 1, 3) == "J05" | ///
    substr(tilstand_1_1, 1, 3) == "J06" | ///
    substr(tilstand_1_1, 1, 3) == "J09" | ///
    substr(tilstand_1_1, 1, 2) == "J1"  | ///
    substr(tilstand_1_1, 1, 2) == "J2"



/*******************************************************************************
4.3.2 Identify any nonrespiratory organ dysfunction
*******************************************************************************/

gen byte organdys_nonresp = 0


foreach var of varlist tilstand_* {

    replace organdys_nonresp = 1 if ///
        (substr(`var', 1, 3) == "D65"   | ///
         substr(`var', 1, 4) == "D695"  | ///
         substr(`var', 1, 4) == "E872"  | ///
         substr(`var', 1, 4) == "G934"  | ///
         substr(`var', 1, 3) == "I46"   | ///
         substr(`var', 1, 4) == "I959"  | ///
         substr(`var', 1, 3) == "J80"   | ///
         substr(`var', 1, 4) == "J952"  | ///
         substr(`var', 1, 4) == "J960"  | ///
         substr(`var', 1, 4) == "J962"  | ///
         substr(`var', 1, 4) == "K720"  | ///
         substr(`var', 1, 4) == "K729"  | ///
         substr(`var', 1, 3) == "N00"   | ///
         substr(`var', 1, 3) == "N17"   | ///
         substr(`var', 1, 4) == "R092"  | ///
         substr(`var', 1, 4) == "R400"  | ///
         substr(`var', 1, 4) == "R401"  | ///
         substr(`var', 1, 4) == "R402"  | ///
         substr(`var', 1, 5) == "R4020" | ///
         substr(`var', 1, 5) == "R4182" | ///
         substr(`var', 1, 3) == "R55"   | ///
         substr(`var', 1, 3) == "R57"   | ///
         substr(`var', 1, 4) == "M726"  | ///
         substr(`var', 1, 3) == "M00"   | ///
         substr(`var', 1, 4) == "M013"  | ///
         substr(`var', 1, 4) == "M860"  | ///
         substr(`var', 1, 4) == "M861"  | ///
         substr(`var', 1, 4) == "M862"  | ///
         substr(`var', 1, 4) == "M869"  | ///
         substr(`var', 1, 3) == "A40"   | ///
         substr(`var', 1, 3) == "A41"   | ///
         substr(`var', 1, 4) == "A483"  | ///
         substr(`var', 1, 4) == "R572"  | ///
         substr(`var', 1, 3) == "B95"   | ///
         substr(`var', 1, 3) == "B96"   | ///
         substr(`var', 1, 4) == "I330"  | ///
         substr(`var', 1, 4) == "I339"  | ///
         substr(`var', 1, 3) == "I38")  & ///
        !missing(`var')
}



/*******************************************************************************
4.3.3 Construct the sensitivity-analysis sepsis outcome
*******************************************************************************/

gen outc_sepsis_sens = outc_sepsis


replace outc_sepsis_sens = 0 if ///
    main_rti == 1 & ///
    outc_explisepsis == 0 & ///
    imsepsis == 1 & ///
    organdys == 1 & ///
    organdys_nonresp == 0



/*******************************************************************************
4.3.4 Run the sensitivity analyses
*******************************************************************************/

postfile Table_output_excl_resp ///
    str40 YVAR ///
    str40 ESTTYPE ///
    double EST ///
    double LCI ///
    double UCI ///
    using ///
    "Resultater\Table_output_excl_resp.dta", ///
    replace


foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    local sens_yvar = ///
        subinstr( ///
            "`yvar'", ///
            "outc_sepsis", ///
            "outc_sepsis_sens", ///
            . ///
        )


    gen `sens_yvar' = `yvar'


    replace `sens_yvar' = 0 if ///
        outc_sepsis_sens == 0 & ///
        `yvar' == 1


    if strpos("`yvar'", "3to11") > 0 {

        gen prsnyrs = prsnyrs_3to11_xlos
    }

    else if strpos("`yvar'", "1to5") > 0 {

        gen prsnyrs = prsnyrs_1to5_xlos
    }

    else if strpos("`yvar'", "6to15") > 0 {

        gen prsnyrs = prsnyrs_6to15_xlos
    }


    replace prsnyrs = . if prsnyrs <= 0


    nbreg `sens_yvar' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        gest_age_mnum, ///
        irr ///
        vce(robust) ///
        exposure(prsnyrs)


    /* Store adjusted incidence rate ratios */

    foreach cat of numlist 0 1 2 3 4 6 {

        local irr = ///
            exp(_b[`cat'.gact_infs])

        local lci = ///
            exp(_b[`cat'.gact_infs] - ///
            invnormal(0.975)*_se[`cat'.gact_infs])

        local uci = ///
            exp(_b[`cat'.gact_infs] + ///
            invnormal(0.975)*_se[`cat'.gact_infs])


        post Table_output_excl_resp ///
            ("`sens_yvar'") ///
            ("IRR, GACT `cat'") ///
            (`irr') ///
            (`lci') ///
            (`uci')
    }


    /* Store adjusted incidence rates */

    margins i.gact_infs, ///
        predict(ir) ///
        atmeans


    matrix M = r(b)

    matrix V = r(V)


    local n_categories = colsof(M)


    forvalues i = 1/`n_categories' {

        local est = M[1,`i']

        local se = sqrt(V[`i',`i'])

        local lci = ///
            `est' - invnormal(0.975)*`se'

        local uci = ///
            `est' + invnormal(0.975)*`se'

        local cat = `i' - 1


        post Table_output_excl_resp ///
            ("`sens_yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop `sens_yvar'

    drop prsnyrs
}


postclose Table_output_excl_resp



/*******************************************************************************
4.4 Analysis excluding indicated births

The analysis is restricted to births with spontaneous onset of labor
(fstart_g == 1).
*******************************************************************************/

/* Reload the main analysis dataset */

use ///
    "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
    clear


keep if fstart_g == 1


/* Open postfile to store the results */

postfile Table_output_excl_indicated ///
    str40 YVAR ///
    str40 ESTTYPE ///
    double EST ///
    double LCI ///
    double UCI ///
    using ///
    "Resultater\Table_output_excl_indicated.dta", ///
    replace


foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    if strpos("`yvar'", "3to11") > 0 {

        gen prsnyrs = prsnyrs_3to11_xlos
    }

    else if strpos("`yvar'", "1to5") > 0 {

        gen prsnyrs = prsnyrs_1to5_xlos
    }

    else if strpos("`yvar'", "6to15") > 0 {

        gen prsnyrs = prsnyrs_6to15_xlos
    }


    replace prsnyrs = . if prsnyrs <= 0


    nbreg `yvar' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        gest_age_mnum, ///
        irr ///
        vce(robust) ///
        exposure(prsnyrs)


    /* Store adjusted incidence rate ratios */

    foreach cat of numlist 0 1 2 3 4 6 {

        local irr = ///
            exp(_b[`cat'.gact_infs])

        local lci = ///
            exp(_b[`cat'.gact_infs] - ///
            invnormal(0.975)*_se[`cat'.gact_infs])

        local uci = ///
            exp(_b[`cat'.gact_infs] + ///
            invnormal(0.975)*_se[`cat'.gact_infs])


        post Table_output_excl_indicated ///
            ("`yvar'") ///
            ("IRR, GACT `cat'") ///
            (`irr') ///
            (`lci') ///
            (`uci')
    }


    /* Store adjusted incidence rates */

    margins i.gact_infs, ///
        predict(ir) ///
        atmeans


    matrix M = r(b)

    matrix V = r(V)


    local n_categories = colsof(M)


    forvalues i = 1/`n_categories' {

        local est = M[1,`i']

        local se = sqrt(V[`i',`i'])

        local lci = ///
            `est' - invnormal(0.975)*`se'

        local uci = ///
            `est' + invnormal(0.975)*`se'

        local cat = `i' - 1


        post Table_output_excl_indicated ///
            ("`yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop prsnyrs
}


postclose Table_output_excl_indicated



/*******************************************************************************
4.5 Sibling analyses
*******************************************************************************/

/* Reload the main analysis dataset */

use ///
    "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
    clear


/* Open postfile to store the sibling-analysis results */

postfile Table_output_siblings ///
    str40 YVAR ///
    str40 ESTTYPE ///
    double EST ///
    double LCI ///
    double UCI ///
    using ///
    "Resultater\Table_output_siblings.dta", ///
    replace


foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    /*
        Explicitly convert the count outcome to a binary indicator for the
        conditional logistic regression. This is equivalent when the original
        outcome is already coded 0/1.
    */

    tempvar any_sepsis

    gen byte `any_sepsis' = ///
        (`yvar' > 0) if !missing(`yvar')


    clogit `any_sepsis' ///
        ib(5).gact_infs ///
        i.kjonn ///
        mors_alder ///
        faar ///
        i.birth_month ///
        i.paritet_g ///
        gest_age_mnum, ///
        group(lopenr_mor_a) ///
        or ///
        vce(robust)


    /*
        Restrict the list of gestational-age categories to categories present
        in the estimation sample.
    */

    quietly levelsof gact_infs if e(sample), ///
        local(gact_levels)


    foreach level of local gact_levels {

        /*
            Gestational-age category 5 is the reference category and therefore
            has no separately estimated coefficient.
        */

        if `level' != 5 {

            local coefname = ///
                "`level'.gact_infs"


            capture scalar sibling_coef_test = ///
                _b[`coefname']


            if _rc == 0 {

                local coeff = ///
                    _b[`coefname']

                local se = ///
                    _se[`coefname']


                /*
                    Do not post a coefficient if Stata has omitted it and
                    assigned a standard error of zero.
                */

                if `se' > 0 & `se' < . {

                    local or = ///
                        exp(`coeff')

                    local lci = ///
                        exp(`coeff' - ///
                        invnormal(0.975)*`se')

                    local uci = ///
                        exp(`coeff' + ///
                        invnormal(0.975)*`se')


                    post Table_output_siblings ///
                        ("`yvar'") ///
                        ("OR, GACT `level'") ///
                        (`or') ///
                        (`lci') ///
                        (`uci')
                }
            }
        }
    }
}


postclose Table_output_siblings


/*******************************************************************************
4.6 Additional analyses

    Nonspontaneous births: fstart_g == 1
    Spontaneous births:    fstart_g == 0
    Birthweight sensitivity analysis: adjustment for c.Marsal_zs

Same model specification as the main analysis, without maternal education.
*******************************************************************************/

foreach analysis in nonspontaneous spontaneous zscore ex_malformations {

    /* Reload the main analysis dataset */

    use ///
        "N:\durable\infs\Eclin_innsending\Datafiler\analysefil_final_august2026.dta", ///
        clear


    /* Define the analysis population and additional adjustment */

    local extra_adjustment ""

    if "`analysis'" == "nonspontaneous" {

        keep if fstart_g == 1
    }

    else if "`analysis'" == "spontaneous" {

        keep if fstart_g == 0
    }

    else if "`analysis'" == "zscore" {

        local extra_adjustment "c.Marsal_zs"
    }
	
	else if "`analysis'" == "ex_malformations" {

		drop if misd==1
    }


    /* Open a separate postfile for each analysis */

    postfile Table_output_`analysis' ///
        str40 YVAR ///
        str40 ESTTYPE ///
        double EST ///
        double LCI ///
        double UCI ///
        using ///
        "Resultater\Table_output_`analysis'.dta", ///
        replace


    /* Main outcome variables */

    foreach yvar of varlist ///
        n_3to11_outc_sepsis ///
        n_1to5_outc_sepsis ///
        n_6to15_outc_sepsis {

        if strpos("`yvar'", "3to11") > 0 {

            gen prsnyrs = prsnyrs_3to11_xlos
        }

        else if strpos("`yvar'", "1to5") > 0 {

            gen prsnyrs = prsnyrs_1to5_xlos
        }

        else if strpos("`yvar'", "6to15") > 0 {

            gen prsnyrs = prsnyrs_6to15_xlos
        }


        replace prsnyrs = . if prsnyrs <= 0


        nbreg `yvar' ///
            ib(5).gact_infs ///
            i.kjonn ///
            mors_alder ///
            faar ///
            i.birth_month ///
            i.paritet_g ///
            gest_age_mnum ///
            `extra_adjustment', ///
            irr ///
            vce(robust) ///
            exposure(prsnyrs)


        /* Store adjusted incidence rate ratios */

        foreach cat of numlist 0 1 2 3 4 6 {

            local irr = ///
                exp(_b[`cat'.gact_infs])

            local lci = ///
                exp(_b[`cat'.gact_infs] - ///
                invnormal(0.975)*_se[`cat'.gact_infs])

            local uci = ///
                exp(_b[`cat'.gact_infs] + ///
                invnormal(0.975)*_se[`cat'.gact_infs])


            post Table_output_`analysis' ///
                ("`yvar'") ///
                ("IRR, GACT `cat'") ///
                (`irr') ///
                (`lci') ///
                (`uci')
        }


        /* Store adjusted incidence rates */

        margins i.gact_infs, ///
            predict(ir) ///
            atmeans


        matrix M = r(b)

        matrix V = r(V)


        local n_categories = colsof(M)


        forvalues i = 1/`n_categories' {

            local est = M[1,`i']

            local se = sqrt(V[`i',`i'])

            local lci = ///
                `est' - invnormal(0.975)*`se'

            local uci = ///
                `est' + invnormal(0.975)*`se'

            local cat = `i' - 1


            post Table_output_`analysis' ///
                ("`yvar'") ///
                ("rate, GACT `cat'") ///
                (`est') ///
                (`lci') ///
                (`uci')
        }


        drop prsnyrs
    }


    postclose Table_output_`analysis'
}
