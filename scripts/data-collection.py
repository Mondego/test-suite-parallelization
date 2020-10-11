#!/usr/local/bin/python

import os
import base64
import json
import requests
import pandas as pd
import datetime
from github import Github
#user your username 
username = "vanessailana"
#generate a token 
ACCESS_TOKEN = ''
g=Github();

#we need a token for the usual api limit
rate_limit = g.get_rate_limit()
rate = rate_limit.search
if rate.remaining == 0:
    print(f'You have 0/{rate.limit} API calls remaining. Reset time: {rate.reset}')
   
else:
    print(f'You have {rate.remaining}/{rate.limit} API calls remaining')
 
    repo_name=[];
    stars=[];
    language=[];
    created_at=[];
    git_url=[];
    commit_count=[];
#search java projects on github  pick 100 
#for i, repo in enumerate(g.search_repositories("topic:maven")): 
print("test")
for i,repo in  enumerate(g.search_repositories("topic:maven")):
        #amount of public repos 
        print("="*1000)
        if i==100:
            break
        temp_data = {}
        temp_data["name"] = repo.name
        temp_data["stars"] = repo.stargazers_count
        temp_data['language']=repo.language
        temp_data['commit_count']=repo.get_commits().totalCount
        temp_data['git_url']=repo.git_url
        #os.system("git clone {}".format(repo.git_url))
        



        #print(dir(repo)
        repo_name.append(temp_data['name']);
        #stars
        stars.append(temp_data['stars']);

        language.append(temp_data['language']);

        git_url.append(temp_data['git_url']);

        commit_count.append(temp_data['commit_count']);

        java_projects=pd.DataFrame()

        java_projects['name']=repo_name;

        java_projects['stars']=stars;

        java_projects['language']=language;

        java_projects['git_url']=git_url

        java_projects['commits']=commit_count

        java_projects.loc[java_projects['stars'] >=50]

        java_projects.loc[java_projects['commits'] >=100]

        java_projects.loc[java_projects['language']=='java']

        #uncomment this line when you aread to download projects
        dirName='cloned_projects'
        os.mkdir(dirName)
        os.chdir(dirName)
       #os.system("git clone {}".format(java_projects["git_url"]))

  
        

        print(java_projects.head(3))
        java_projects.to_csv('project_metadata.csv') 

 
 
    
    
    
    





















