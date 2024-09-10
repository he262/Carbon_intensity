from pathlib import Path
from behave import *
import pandas as pd
import requests
import numpy as np
from datetime import datetime
from urllib.parse import urlencode
from rtutility.dataop.fetch.database import ImportFromDatabase
from io import BytesIO
import logging
from pandas.testing import assert_series_equal

from logging import basicConfig,debug,DEBUG,info
basicConfig(level=DEBUG, format="%(levelname)s %(asctime)s : %(message)s")


@given('Read the base url for carbon_intensity at {Base_url}')
def base_url(context,Base_url:str):
    context.api_base_url = Base_url

@when('Append the following params')
def append_params(context):
    context.api_with_params = f"{context.api_base_url}?{urlencode(dict(context.table))}"

@when('Make api request for carbon_intensity data')
def api_request(context):
    context.response = requests.get(context.api_with_params,verify=False)
    if context.response.status_code == 200:
        context.carbon_intensity_api = context.response.content
        logging.info(context.response.status_code)
    else:
        raise ValueError("NO response")
    
@then('save the api_response at {Api_response}')
def save_response(context,Api_response:str):
    context.Api_Data_carbon_intensity=pd.read_csv(BytesIO(context.carbon_intensity_api),na_filter=False,sep='|')
    context.Api_Data_carbon_intensity.to_csv(Api_response,index=False)
    

@given('Fetch the Scope emission data from {ISS_query} at {cutoff_date}')
def fetch_scope_data(context,ISS_query:str,cutoff_date:str):
    k = "'),('".join(context.Api_Data_carbon_intensity['internalId'].to_list())
    with open(Path(ISS_query)) as fp:
        context.iss_data = fp.read().format(k,datetime.strptime(cutoff_date,'%Y-%m-%d').strftime('%Y%m%d'))
    context.Brutus_SIDEXT = ImportFromDatabase("brutus1.bat.ci.dom", "SIDExternal")
    context.Brutus_SIDEXT.query = context.iss_data
    context.Scope_Emission_DB = context.Brutus_SIDEXT.read()

@when('pivot the data of scope emission')
def pivot_data(context):
    context.Scope_Emission_Pivot = context.Scope_Emission_DB.pivot(index='stoxxId',columns='vendorItem',values='value').reset_index()

@given('Fetch the Evic data from {Evic_query} at {cutoff_date}')
def evic_data(context,Evic_query:str,cutoff_date:str):
    with open(Path(Evic_query),'r') as fp:
        context.evic = fp.read().format(datetime.strptime(cutoff_date,'%Y-%m-%d').strftime('%Y%m%d'))
    context.Brutus_Reporting = ImportFromDatabase("brutus1.bat.ci.dom", "Reporting")    
    context.Brutus_Reporting.query = context.evic
    context.Evic_data = context.Brutus_Reporting.read()
    # if context.Evic_data.empty:
    #     context.Evic_data['gfjr']=''
    # context.Evic_data.to_csv("Evic_data.csv",index=False)


@when("Pivot the evic data")
def evic_pivot(context):
    '''pivot the data evic data'''
    context.Evic_df = context.Evic_data.pivot(index=['dj_id','securityId'],values='value',columns='field').reset_index().rename(columns={'dj_id':'stoxxId'})

@then('Merge Evic data with scope emission')
def merge_evic(context):
    context.Final = context.Scope_Emission_Pivot.merge(context.Evic_df[['stoxxId','Evic']],on='stoxxId',how='left')

@when('calculate the Carbon_Intensity formula')
def calculate(context):

    context.Final['carbon_intensity_QA'] = pd.to_numeric(
        (
        pd.to_numeric(context.Final['ClimateScope1Emissions'],errors='coerce').fillna(0)+
        pd.to_numeric(context.Final['ClimateScope2Emissions'],errors='coerce').fillna(0)+
        pd.to_numeric(context.Final['ClimateScope3Emissions'],errors='coerce').fillna(0)
    )/pd.to_numeric(context.Final['Evic'],errors='coerce'),errors='coerce').fillna(0)


@then('Merge the carbon_intensity Db data with Api')
def merge_api(context):
    context.Final_Result=context.Api_Data_carbon_intensity.merge(context.Final[['stoxxId','carbon_intensity_QA']],how='left',left_on='internalId',right_on='stoxxId')
    context.Final_Result['carbon_intensity_QA'] = context.Final_Result['carbon_intensity_QA'].round(8)
    # context.Final['caroooon'] = context.Final['caroooon'].replace([float('inf'), float('-inf')], 0)
    # context.Final['w'] = context.Final['w'].replace([np.inf],0)
    context.Final_Result['carbon_intensity_QA'] = context.Final_Result['carbon_intensity_QA'].replace([np.inf, -np.inf], 0)
    context.Final_Result['carbon_intensity_QA'] = context.Final_Result['carbon_intensity_QA'].fillna(0)

@then('validate the carbon_intensity data')
def test(context):
    assert_series_equal(context.Final_Result['carbon_intensity'],context.Final_Result['carbon_intensity_QA'],check_dtype=False,check_names=False)