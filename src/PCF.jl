module PCF

using DataFrames
export cashFlows, irrs, boxPlots

function irrs(inDict)
    funds = inDict["portfolio"][1]["funds"]

    function fund_irrs(fund)
        portfolio = DataFrame(fund)[!,[:fund_name,:fund_id]]
        stats = fund["stats"]
        function scen_irrs(key)
            scenStats = stats[key]

            irrDf = DataFrame(scenStats["irr"])
            irrDf[!, :scenario] = [string(key)]
            irrDf = join(irrDf,portfolio,on=[], kind=:cross)
        end
        vcat(DataFrame.(scen_irrs.(keys(stats)))...)
    end
    vcat(DataFrame.(fund_irrs.(funds))...)
end


function boxPlots(inDict)
    funds = inDict["portfolio"][1]["funds"]

    function fund_boxes(fund)
        portfolio = DataFrame(fund)[!,[:fund_name,:fund_id]]
        stats = fund["stats"]
        function scen_boxes(key)
            scenStats = stats[key]

            irrDf = DataFrame(scenStats["box_plot"])
            irrDf[!, :scenario] = [string(key)]
            irrDf = join(irrDf,portfolio,on=[], kind=:cross)
        end
        vcat(DataFrame.(scen_boxes.(keys(stats)))...)
    end
    vcat(DataFrame.(fund_boxes.(funds))...)
end

function cashFlows(inDict)
    funds = inDict["portfolio"][1]["funds"]

    function fund_cfs(fund)
        portfolio = DataFrame(fund)[!,[:fund_name,:fund_id]]
        stats = fund["stats"]
        function scen_cfs(key)
            scenStats = stats[key]
            cashFlow = scenStats["cash_flow"]

            scenario = copy(portfolio)
            scenario[!,:scenario] = [string(key)]
            function collect_cfs(cf)
                date = cf["date"]

                function cfDf(col)
                    if col != "date"
                        _temp = DataFrame(cf[col])
                        _temp[!,:date] = [date]
                        _temp[!,:stat] = [col]
                        return(_temp)
                    end
                end

                cfs = vcat(DataFrame.([x for x in cfDf.(keys(cf)) if !isnothing(x)])...)
                return(cfs)
            end
            cashFlowDf = join(scenario, vcat(DataFrame.(collect_cfs.(cashFlow))...), on=[],kind=:cross)
        end

        allScenCashFlowDf = vcat(DataFrame.(scen_cfs.(keys(stats)))...)
    end
    allFundCashFlowCfs = vcat(DataFrame.(fund_cfs.(funds))...)
end







end # module
