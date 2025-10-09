!pip install kaggle

#download api key file .json
#Upload kaggle.json

from google.colab import files
files.upload()  # choose your kaggle.json

#Move kaggle.json to the correct folder
!mkdir -p ~/.kaggle
!cp kaggle.json ~/.kaggle/
!chmod 600 ~/.kaggle/kaggle.json


#Download & unzip the dataset in Colab
!kaggle datasets download -d asaniczka/1-3m-linkedin-jobs-and-skills-2024
!unzip -q 1-3m-linkedin-jobs-and-skills-2024.zip -d ./linkedin_dataset

#read the loaded datasets 

import pandas as pd

# Load first 100k rows to avoid memory issues
job_postings = pd.read_csv('./linkedin_dataset/linkedin_job_postings.csv', nrows=100000)
job_summary = pd.read_csv('./linkedin_dataset/job_summary.csv', nrows=100000)
job_skills = pd.read_csv('./linkedin_dataset/job_skills.csv', nrows=100000)

# Quick look
#print(job_postings.head())
#print(job_summary.head())
print(job_skills.head())

#merge all there tables 
job_data = job_postings.merge(job_skills.groupby('job_link')['job_skills'].apply(list).reset_index(), on='job_link', how='left')
job_data['skill'] = job_data['job_skills'].apply(lambda x: x if isinstance(x, list) else [])


#company has 1 missing value
job_data['company'] = job_data['company'].fillna('Unknown')

job_data['job_skills'] = job_data['job_skills'].apply(lambda x: x if isinstance(x, list) else [])




