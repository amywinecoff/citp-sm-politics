create table `citp-sm-reactions.reddit_clean_comments.labled_comments_with_interventions_sample` as (
with stratified_sampled_subreddits as (

    select
        post_id,
        subreddit,
        intervention,
        row_number() over(partition by subreddit, intervention
                            order by rand()) as random_sort_rownum,
        count(post_id) over (partition by subreddit, intervention) as sr_int_count
    from
        `citp-sm-reactions.reddit_clean_comments.labled_comments_with_interventions`

)
select
    int.*,
    sss.random_sort_rownum,
    sss.sr_int_count,
    sss.random_sort_rownum / sss.sr_int_count as random_sort_proportion
from
    stratified_sampled_subreddits as sss
inner join `citp-sm-reactions.reddit_clean_comments.labled_comments_with_interventions` int
     on int.post_id = sss.post_id
        and int.subreddit = sss.subreddit
        and int.intervention = sss.intervention
);

