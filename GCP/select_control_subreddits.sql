--create a table that contains observations for each potential control subreddit for each upvote treatment subreddit by aligning
--observations within the same period as the treatment was applied for each subreddit that had the baseline-->upvote only treatment
create table `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt` as (
with cart as (--create the Cartesian product between upvote treatment subreddits and all other subreddits
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
FROM (SELECT subreddit as txt_subreddit,
        min(CASE WHEN intervention = 'baseline' THEN start_date_unix_epoc END) AS baseline_start,
        min(CASE WHEN intervention = 'baseline' THEN end_date_unix_epoc END) AS baseline_end,
        min(CASE WHEN intervention = 'upvote_only' THEN start_date_unix_epoc END) AS upvote_start,
        min(CASE WHEN intervention = 'upvote_only' THEN end_date_unix_epoc END) AS upvote_end
        FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt`
        where subreddit not in ('vegan', 'unpopularopinion')--these subreddits did not have the upvote intervention
        group by subreddit) as dt
LEFT JOIN cart on cart.subreddit = dt.txt_subreddit
LEFT JOIN `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as ctr
    ON ctr.subreddit = cart.ctr_subreddit
);

---create a table that contains the average values of the language subcomponents and the total number of observations per period to enable
---matching to the treatment subreddits. Note that the aggregates are also computed for the upvote period so that subreddits can also
---be matched on number of observations during the intervention, but the average language subcomponent values SHOULD NOT be used for
---selection of the appropriate controls
create table `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt_avg` as (
SELECT txt_subreddit, ctr_subreddit, period,
    avg(counter_argument_structure) as avg_counter_argument_structure,
    avg(emotional_language) as avg_emotional_language,
    avg(other) as avg_other,
    avg(you_in_the_epicenter) as avg_you_in_the_epicenter,
    avg(empathy_reciprocity) as avg_empathy_reciprocity,
    avg(generalized_call) as avg_generalized_call,
    avg(situational_call_for_action) as avg_situational_call_for_action,
    avg(collective_rhetoric) as avg_collective_rhetoric,
    avg(ungrounded_argument) as avg_ungrounded_argument,
    count(post_id) as obs_per_period,
from `citp-sm-reactions.reddit_clean_comments.controls_for_upvote_txt`
group by ctr_subreddit, period, txt_subreddit
HAVING period != 'no_period'
order by txt_subreddit, ctr_subreddit, period);

--create a table that contains the same info for the upvote treatment subreddits for subsequent matching to the control subreddits
create table `citp-sm-reactions.reddit_clean_comments.txt_subreddits_for_upvote_txt_avg` as (
SELECT txt_subreddit, ctr_subreddit, period,
    avg(counter_argument_structure) as avg_counter_argument_structure,
    avg(emotional_language) as avg_emotional_language,
    avg(other) as avg_other,
    avg(you_in_the_epicenter) as avg_you_in_the_epicenter,
    avg(empathy_reciprocity) as avg_empathy_reciprocity,
    avg(generalized_call) as avg_generalized_call,
    avg(situational_call_for_action) as avg_situational_call_for_action,
    avg(collective_rhetoric) as avg_collective_rhetoric,
    avg(ungrounded_argument) as avg_ungrounded_argument,
    count(post_id) as obs_per_period,
from `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions_txt`
group by ctr_subreddit, period, txt_subreddit
HAVING period != 'no_votes'
order by txt_subreddit, ctr_subreddit, period);
