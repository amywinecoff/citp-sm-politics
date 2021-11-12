---create a table that only contains subreddits' first two intervention periods. So, if a subreddit had three different
---periods, only retain the first two

create table `citp-sm-reactions.reddit_clean_comments.reaction_interventions` as (
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

---join the updated interventions table to the interventions table to select only posts that are associated with subreddits
---that experienced an intervention.
create table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct_txt` as
    (
        SELECT distinct(sub.post_id), sub.link_id, sub.sub_id, sub.subreddit, sub.author, byte_length(sub.body) as body_length, sub.nest_level, sub.post_score,
            author_count.author_posts_per_subreddit,
            sub.who_instead_of_what, sub.we_vs_them, sub.fact_related_argument, sub.structured_argument,
            sub.counter_argument_structure, sub.emotional_language,sub.other, sub.you_in_the_epicenter, sub.empathy_reciprocity,
            sub.generalized_call, sub.situational_call_for_action,
            sub.collective_rhetoric, sub.ungrounded_argument,
            rxn.intervention, rxn.start_date_unix_epoc as int_start_unix_time, rxn.end_date_unix_epoc as int_end_unix_time, sub.unix_epoc_time
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as sub
        INNER JOIN `citp-sm-reactions.reddit_clean_comments.reaction_interventions` as rxn
            ON (sub.unix_epoc_time >= rxn.start_date_unix_epoc) AND (sub.unix_epoc_time <= rxn.end_date_unix_epoc)
            AND sub.subreddit = rxn.subreddit
        LEFT JOIN (select author, subreddit,COUNT(author) as author_posts_per_subreddit
                FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct`
                WHERE BYTE_LENGTH(author) > 0
                group by author, subreddit) as author_count on author_count.author = sub.author AND author_count.subreddit = sub.subreddit
    );

---need to make a separate table for the upvote to novote situation
create table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct_txt_upvote_novote` as
    (
        SELECT distinct(sub.post_id), sub.link_id, sub.sub_id, sub.subreddit, sub.author, byte_length(sub.body) as body_length, sub.nest_level, sub.post_score,
            author_count.author_posts_per_subreddit,
            sub.who_instead_of_what, sub.we_vs_them, sub.fact_related_argument, sub.structured_argument,
            sub.counter_argument_structure, sub.emotional_language,sub.other, sub.you_in_the_epicenter, sub.empathy_reciprocity,
            sub.generalized_call, sub.situational_call_for_action,
            sub.collective_rhetoric, sub.ungrounded_argument,
            rxn.intervention, rxn.start_date_unix_epoc as int_start_unix_time, rxn.end_date_unix_epoc as int_end_unix_time, sub.unix_epoc_time
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as sub
        INNER JOIN `citp-sm-reactions.reddit_clean_comments.reaction_interventions_upvote_novote` as rxn
            ON (sub.unix_epoc_time >= rxn.start_date_unix_epoc) AND (sub.unix_epoc_time <= rxn.end_date_unix_epoc)
            AND sub.subreddit = rxn.subreddit
        LEFT JOIN (select author, subreddit,COUNT(author) as author_posts_per_subreddit
                FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct`
                WHERE BYTE_LENGTH(author) > 0
                group by author, subreddit) as author_count on author_count.author = sub.author AND author_count.subreddit = sub.subreddit
        WHERE sub.subreddit in ('Conservative', 'GenderCritical', 'politics')
    );

