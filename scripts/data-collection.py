#!/usr/local/bin/python

import os
import base64
import json
import requests
import datetime
from datetime import datetime, timedelta
import pandas as pd
import io 
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
<<<<<<< HEAD
#for i, repo in enumerate(g.search_repositories("topic:maven")): 
#print("test")


#epo_commits=requests.get('https://api.github.com/repos/octocat/Hello-World/commits')

=======
>>>>>>> aa535c9e9a4712e1f26fea0778f9ae38e2764a8f
for i,repo in  enumerate(g.search_repositories("topic:maven")):

        #amount of public repos
        
        print("="*100)
        if i == 10:
            break
        #print(dir(repo))
        
        temp_data = {}
        temp_data["name"] = repo.name
        temp_data["stars"] = repo.stargazers_count
        temp_data['language']=repo.language
        temp_data['git_url']=repo.git_url
<<<<<<< HEAD
        temp_data['commit_count']= repo.get_commits().totalCount;
        print(temp_data)
    
=======
      
        




>>>>>>> aa535c9e9a4712e1f26fea0778f9ae38e2764a8f
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

       
        dirName='cloned_projects'
<<<<<<< HEAD
        #os.mkdir(dirName)
        #os.chdir(dirName)
=======
        os.mkdir(dirName)
        os.chdir(dirName)
        #uncomment to download projects 
>>>>>>> aa535c9e9a4712e1f26fea0778f9ae38e2764a8f
       #os.system("git clone {}".format(java_projects["git_url"]))

  
        
        java_projects.drop(java_projects.columns[0], axis=1)
        print(java_projects.columns)
        #java_projects.to_csv('project_metadata.csv') 

<<<<<<< HEAD
=======
        
        java_projects.to_csv('project_metadata.csv') 
>>>>>>> aa535c9e9a4712e1f26fea0778f9ae38e2764a8f

 
 
    
    
    
    





















