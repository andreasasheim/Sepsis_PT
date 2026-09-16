clear all
use "Analysis_file", clear





/*******************************************************************************
Main analyses
*******************************************************************************/

/* Open postfile to store the output for main analyses */

postfile Table_output_adjusted ///
    str40 YVAR ///
    str40 ESTTYPE ///
    EST ///
    LCI ///
    UCI ///
    using ///
    "Table_output_adjusted.dta", ///
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
        i.gest_age_mnum, ///
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


        post Table_output_adjusted ///
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


        post Table_output_adjusted ///
            ("`yvar'") ///
            ("rate, GACT `cat'") ///
            (`est') ///
            (`lci') ///
            (`uci')
    }


    drop prsnyrs
}


postclose Table_output_adjusted


/*******************************************************************************
4.5 Sibling analyses
*******************************************************************************/


/* Open postfile to store the sibling-analysis results */

postfile Table_output_siblings ///
    str40 YVAR ///
    str40 ESTTYPE ///
    double EST ///
    double LCI ///
    double UCI ///
    using ///
    "Table_output_siblings.dta", ///
    replace


foreach yvar of varlist ///
    n_3to11_outc_sepsis ///
    n_1to5_outc_sepsis ///
    n_6to15_outc_sepsis {

    /*
        Explicitly convert the count outcome to a binary indicator for the
        conditional logistic regression.
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
        i.gest_age_mnum, ///
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
