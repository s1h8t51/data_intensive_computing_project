# data_intensive_computing_project_phase_2
- install dependencies and spark session
- extracting datasets
- The script performs three distinct loading operations:

Job Postings:

Loads linkedin_job_postings.csv.

Result: Stored in a DataFrame named df_postings.

Job Skills:

Loads job_skills.csv.

Result: Stored in a DataFrame named df_skills.

Job Summary:

Loads job_summary.csv.

Result: Stored in a DataFrame named df_summary.

-  Deduplication Step: Cleaned and deduplicated only df_postings to create the new DataFrame df_postings_clean.
-  missing data handling
-  Preprocessing Step: Selected, cleaned, and filtered columns from only df_postings_clean to create the final working table df_work.
- joining all 3 datasets
  
-  Order,Task Type,Corresponding Objective / ML Task,Rationale
-  1.,Exploratory Analysis,Objective 1: Identify Most In-Demand Skills.,Must be done first to understand the raw material (skills) and general market demand.
-  
2.,Exploratory Analysis,Objective 2: Analyze Skill Count Correlation.,Simple statistical analysis before complex modeling.
3.,Skill Similarity Modeling,Objective 3: Measure Skill Overlap.,Calculates the necessary quantitative metrics (similarity scores) needed for the clustering tasks.
4.,Unsupervised Learning,Objective 5 / ML Task 3: Evaluate Emerging Job Clusters.,Applying clustering techniques to segment the market based on the metrics derived in Step 3.
5.,Regional Analysis,Objective 4: Explore Regional Specialization.,Utilizes the identified skill clusters and frequencies to analyze geographic differences.
6.,Supervised Learning,ML Task 1: Classification (Predict Job Demand).,Uses the cleaned features and skill metrics to build the predictive model.
7.,Supervised Learning,ML Task 2: Regression (Estimate Compensation Tiers).,Uses the cleaned features and skill metrics to build the value prediction model.
8.,Reporting / Visualization,Objective 6: Visualize Skill Evolution.,Final step to communicate all the findings from the preceding analyses and models.
