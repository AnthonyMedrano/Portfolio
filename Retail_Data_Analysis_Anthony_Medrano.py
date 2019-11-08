# import libraries
import numpy as np
import matplotlib.pyplot as plt
import json
import pandas as pd

# load store file
with open('/Users/anthony/Downloads/stores.json') as j_stores:
    store_data = json.load(j_stores)

# load price and auditor files
price_data = pd.read_csv('/Users/anthony/Downloads/prices.csv')
auditor_data = pd.read_csv('/Users/anthony/Downloads/auditors.csv')

# view variables
print(store_data[0])         # type: dictionary
print(price_data.head(0))    # type: dataframe
print(auditor_data.head(0))  # type: dataframe

# merge price and auditor dataframes by Auditor ID
merged_data = pd.merge(price_data, auditor_data, on="Auditor ID")

# insert and initialize column for Banner variable
merged_data.head(0)
merged_data.insert(8, 'Banner', '')

# loop through merged dataframe and store dictionary to acquire Banner value according to Store ID
for i in range(merged_data.shape[0]):
    for j in range(len(store_data)):
        if store_data[j]['Store ID'] == merged_data.loc[i,'Store ID'] and store_data[j]['Region'] == merged_data.loc[i,'Region']:
            merged_data.loc[i,'Banner'] = store_data[j]['Banner'].encode('ascii','ignore')
            break

# select entries with a valid Banner
merged_data = merged_data[merged_data['Banner'] != '']

# drop unused columns
merged_data.drop(['Date','First','Last','Auditor ID','Store ID'], axis=1, inplace=True)

# create new formatted dataframe, determine median Price for each combination of Banner-UPC-Subregion
formatted_data = pd.pivot_table(merged_data, values='Price', index=['Banner', 'UPC'], columns=['Region'], aggfunc=np.median).reset_index()

# output formatted dataframe to excel
formatted_data.to_excel('Engage3_Data_Challenge_Anthony_Medrano.xlsx', sheet_name='Price Summary', index=False)

# list of region and store names
region_names = ['Kansas','New York','Northern California','Texas']
store_names = ['Safeway','Trader Joes','Walmart','Wegmans','Whole Foods']



""" Box Plot: Region Summary """

region_data = []
for i in range(len(region_names)):
    region_data.append(formatted_data[region_names[i]].dropna())
    
fig, ax = plt.subplots()
ax.boxplot(region_data)
plt.xticks([i+1 for i in range(len(region_names))],region_names)
plt.ylabel('Price [$]')
plt.title('All Products by Region')
plt.show()
fig.savefig('All_Products_by_Region.eps', format ='eps')



""" Box Plot: Store Summary """

store_data = [[] for k in range(len(store_names))]
for i in range(len(store_names)):
    for j in region_names:
        store_data[i].extend(formatted_data[j][formatted_data['Banner']==store_names[i]].dropna())
        
fig, ax = plt.subplots()
ax.boxplot(store_data)
plt.xticks([i+1 for i in range(len(store_names))],store_names)
plt.ylabel('Price [$]')
plt.title('All Products by Store')
plt.show()
fig.savefig('All_Products_by_Store.eps', format ='eps')



""" Box Plots: Store Products by Region Box Plots """

for i in range(len(store_names)):
    region_data = [[] for k in range(len(region_names))]
    for j in range(len(region_names)):
        region_data[j].extend(formatted_data[region_names[j]][formatted_data['Banner']==store_names[i]].dropna())
        
    fig, ax = plt.subplots()
    ax.boxplot(region_data)
    plt.xticks([i+1 for i in range(len(region_names))],region_names)
    plt.ylabel('Price [$]')
    plt.title(store_names[i]+' Products by Region')
    plt.show()
    fig.savefig(store_names[i]+'_Products_by_Region.eps', format ='eps')
    
    
    
""" Box Plots: Region Products by Store """

for i in range(len(region_names)):
    store_data = [[] for k in range(len(store_names))]
    for j in range(len(store_names)):
        store_data[j].extend(formatted_data[region_names[i]][formatted_data['Banner']==store_names[j]].dropna())
        
    fig, ax = plt.subplots()
    ax.boxplot(store_data)
    plt.xticks([i+1 for i in range(len(store_names))],store_names)
    plt.ylabel('Price [$]')
    plt.title(region_names[i]+' Products by Store')
    plt.show()
    fig.savefig(region_names[i]+'_Products_by_Store.eps', format ='eps')