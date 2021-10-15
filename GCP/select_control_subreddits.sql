create table `citp-sm-reactions.reddit_clean_comments.temp_txt` as (
with cart as (
    SELECT  distinct(ctr.subreddit) as ctr_subreddit, txt.subreddit
    FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` as txt, `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as ctr
    WHERE txt.subreddit != ctr.subreddit AND ctr.subreddit not in (select distinct(subreddit) from `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt`)
    order by subreddit, ctr_subreddit
)
SELECT dt.*, cart.ctr_subreddit, ctr.post_id, ctr.unix_epoc_time, ctr.who_instead_of_what, ctr.we_vs_them, ctr.fact_related_argument, ctr.structured_argument,
            ctr.counter_argument_structure, ctr.emotional_language,ctr.other, ctr.you_in_the_epicenter, ctr.empathy_reciprocity,
            ctr.generalized_call, ctr.situational_call_for_action,
            ctr.collective_rhetoric, ctr.ungrounded_argument,
    CASE
        WHEN ctr.unix_epoc_time >= baseline_start AND ctr.unix_epoc_time <= baseline_end THEN 'baseline'
        WHEN ctr.unix_epoc_time >= upvote_start AND ctr.unix_epoc_time <= upvote_end THEN 'upvote'
        ELSE 'no_period'
    END as period
FROM (SELECT subreddit,
        min(CASE WHEN intervention = 'baseline' THEN start_date_unix_epoc END) AS baseline_start,
        min(CASE WHEN intervention = 'baseline' THEN end_date_unix_epoc END) AS baseline_end,
        min(CASE WHEN intervention = 'upvote_only' THEN start_date_unix_epoc END) AS upvote_start,
        min(CASE WHEN intervention = 'upvote_only' THEN end_date_unix_epoc END) AS upvote_end
        FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt`
        where subreddit not in ('vegan', 'unpopularopinion')
        group by subreddit) as dt
LEFT JOIN cart on cart.subreddit = dt.subreddit
LEFT JOIN `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as ctr
    ON ctr.subreddit = cart.ctr_subreddit
)
