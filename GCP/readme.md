The notebook file `generate_subcategory_labeled.ipynb` is the code that will take the csv data from the GCP bucket `dialogue_labels` and add it into the table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled`\. 
\\
If you have your your data somewhere else (e.g., Google Drive), you will need to figure out how to get it into the GCP bucket. There is some code in this repo that will do a transfer of csvs from Google Drive to GCP, but that is a silly thing to do, so I'm not going to tell you which notebook does it or document that notebook. You can spend time attempting to decode my messy notebooks to do the Google Drive --> GCP transfer, or use that same energy just to figure out how to transfer data directly from its source to the GCP bucket. Your call, but I would highly recommend the latter since it is way faster and less silly. \
\
Note that this code does do filepath matching to make sure it does not copy any csvs with the EXACT same file path into the table. **However, note that if you add more files that have the same csv name (i.e., duplicate data) but store them in different folders (e.g., `\politics` and `_politics`), the resulting table will contain data duplicates. Also, if you add in other random stuff to this bucket, it will likely break this code and/or upload random stuff that you don't want into the table** 

Regardless of whether you add new duplicates, you will also need to then run the script `generate_subcategory_labeled_distinct.sql` because we do have duplicates in the SQL table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled` due to the previous issue with duplicated data in the `politics` and `ukpolitics` realted folders. 

If you want to verify whether there are duplicates using some aggregations and comparisons, run `test_for_duplicates.sql`

The script `generate_reaction_interventions_txt.sql` will clean up the stuff from the original intervention file you gave me, and create more organized table for the baseline --> upvote or notevote and a separate table for upvote --> novote

The scripts with the names `{VAR}_select_control_subreddits.sql` contain mutiple sequential queries to create the tables you need for the difference-in-difference analysis. **This is not end to end automated.** There is a section in the file that just has a select statement. From that select statement you need to download this data as a csv from BigQuery and run the correlations in Excel. You can see examples of how I did this in the csv files `{CONDITION}_correlations.csv`. Then use whatever control subreddits you select based on the correlation + sample size analysis you do in Excel to determine the subreddit contingencies in the final query. For documentation purposes, I have been putting the information about the selected control subreddit statistics in txt_ctr_table.xlsx with a different sheet for each intervention type. 

If you change the code and rerun the analysis, you will need to manually edit this file for any tables that you might want to put in the paper. **It is not generated automatically**. 

**Also note that if you run any of the previous code to create a smaller dataset using random or stratefied selection of data, the statistics in this table will not be correct for the data that is actually used in the analysis. It will only be accurate for the data you have sampled from. If you do that, be sure to make a note in the paper methods section**


