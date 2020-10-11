#!/usr/local/bin/python

import os
import base64
import json
import requests
import pandas as pd
import datetime
from github import Github

dirName='java_projects'

try:
    os.mkdir(dirName)
    os.chdir(dirName)

except FileExistsError:
    print(dirName+"exists")


username = "vanessailana"
ACCESS_TOKEN = 'put your token here'
g=Github();

#we need a token for the usual api limit
rate_limit = g.get_rate_limit()
rate = rate_limit.search
if rate.remaining == 0:
    print(f'You have 0/{rate.limit} API calls remaining. Reset time: {rate.reset}')
   
else:
    print(f'You have {rate.remaining}/{rate.limit} API calls remaining')
 
user = g.get_user(username)

for repo in user.get_repos():
     #print_repo(repo)
     #print(repo.clone_url)
    #os.system("git clone {}".format(repo["git_url"]))
   #print(dir(repo))

    repo_name=[];
    stars=[];
    language=[];
    created_at=[];
#search java projects on github  pick 100 
#for i, repo in enumerate(g.search_repositories("topic:maven")): 
    for i,repo in  enumerate(g.search_repositories("topic:maven")):
        #amount of public repos 
        print("="*100)
        temp_data = {}
        temp_data["name"] = repo.name
        temp_data["stars"] = repo.stargazers_count
        temp_data['language']=repo.language
        temp_data['created_at']=repo.created_at


        #print(dir(repo)
        repo_name.append(temp_data['name']);
        #stars
        stars.append(temp_data['stars']);

        language.append(temp_data['language']);

        created_at.append(temp_data['created_at']);
      
        java_projects=pd.DataFrame()

        java_projects['name']=repo_name;

        java_projects['stars']=stars;

        java_projects['language']=language;

        java_projects.loc[java_projects['stars'] >=100]
        java_projects.loc[java_projects['language']=='java']

        print(java_projects.head(3))
       
        
        java_projects.to_csv('project_metadata.csv') 



    #metadata about projects in json 
    #f = open("java"+"/metadata.json", 'w')
    #f.write(json.dumps(metadata))
    #f.close()





















