select
  (select count(1) from (select distinct *
  from `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions`)) as distinct_rows,
  (select count(1) from `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions`) as total_rows
