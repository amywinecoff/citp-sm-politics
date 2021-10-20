---create a table that only contains subreddits' first two intervention periods. So, if a subreddit had three different
---periods, only retain the first two
create table `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` as (
with max_ints as (
    select subreddit
    FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_epoc`
    group by subreddit
    having max(int_order) > 1)
SELECT base.*
FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_epoc` as base
INNER JOIN max_ints on max_ints.subreddit = base.subreddit
WHERE int_order < 3
ORDER BY subreddit, intervention);