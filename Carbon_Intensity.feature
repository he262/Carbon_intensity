Feature: Test the data for carbon Intensity

    Scenario Outline: Test the data for api data for carbon Intensity and validate with the database
    Given Read the base url for carbon_intensity at <Base_url>
    When Append the following params
        | Param_name   | Param_value           |
        | indexSymbol  | <indexSymbol>         |
        | compDate     | <Eff_date>            |
        | secAttrDate  | <cutoff_date>         |
        | calendarName | STOXXCAL              |
        | targetCcys   |                       |
        | fields       | evic,carbon_intensity |
        | vendorItems  |                       |
        | output       | csv                   |

    When Make api request for carbon_intensity data
    Then save the api_response at <Api_response>
    Given Fetch the Scope emission data from <ISS_query> at <cutoff_date>
    When pivot the data of scope emission
    Given Fetch the Evic data from <Evic_query> at <cutoff_date>
    When Pivot the evic data
    Then Merge Evic data with scope emission
    When calculate the Carbon_Intensity formula
    Then Merge the carbon_intensity Db data with Api
    Then validate the carbon_intensity data

    Examples:
        | ISS_query                     | Evic_query               | indexSymbol | cutoff_date | Eff_date   | Base_url                                                  | Api_response                                      |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2024-03-28  | 2024-04-22 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2024-02-29  | 2024-03-18 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2024-01-31  | 2024-02-19 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-12-29  | 2024-01-22 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-11-30  | 2023-12-18 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-10-31  | 2023-11-20 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-09-29  | 2023-10-23 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-08-31  | 2023-09-18 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-07-31  | 2023-08-21 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-06-30  | 2023-07-24 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-05-31  | 2023-06-19 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-04-28  | 2023-05-22 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-03-31  | 2023-04-24 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-02-28  | 2023-03-20 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        # # | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | SXW1E       | 2023-01-31  | 2023-02-20 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |
        # | Features\\Data\\Iss_query.sql | Features\\Data\\Evic.sql | TW1P       | 2022-12-30  | 2023-01-23 | http://brutus2.bat.ci.dom/sidwebapi/api/Index/GetUniverse | Features\\Data\\Api_response_carbon_intensity.csv |