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

---create a table that will hopefully only contain the subreddits that had multiple interventions, where the
---second intervention was switching from upvote to novote
create table `citp-sm-reactions.reddit_clean_comments.reaction_interventions_upvote_novote` as (
with max_ints as (
    select subreddit
    FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_epoc`
    group by subreddit
    having max(int_order) > 2) --this means they should have had three interventions
SELECT base.*
FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_epoc` as base
INNER JOIN max_ints on max_ints.subreddit = base.subreddit
WHERE int_order > 1
ORDER BY subreddit, intervention);