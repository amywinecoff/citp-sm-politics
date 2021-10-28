 create table `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_ctr` as (
 with cart as (--create the Cartesian product between upvote treatment subreddits and all other subreddits
     SELECT  distinct(ctr.subreddit) as ctr_subreddit, txt.subreddit
     FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions` as txt, `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as ctr
     WHERE txt.subreddit != ctr.subreddit AND ctr.subreddit not in (select distinct(subreddit) from `citp-sm-reactions.reddit_clean_comments.reaction_interventions`)
     order by subreddit, ctr_subreddit
 )
 SELECT dt.*, cart.ctr_subreddit, ctr.post_id, ctr.link_id, ctr.sub_id, ctr.author, ctr.unix_epoc_time, ctr.who_instead_of_what, ctr.we_vs_them, ctr.fact_related_argument, ctr.structured_argument,
             ctr.counter_argument_structure, ctr.emotional_language,ctr.other, ctr.you_in_the_epicenter, ctr.empathy_reciprocity,
             ctr.generalized_call, ctr.situational_call_for_action,
             ctr.collective_rhetoric, ctr.ungrounded_argument, ctr.nest_level, byte_length(ctr.body) as body_length, author_count.author_posts_per_subreddit,
     CASE
         WHEN ctr.unix_epoc_time >= baseline_start AND ctr.unix_epoc_time <= baseline_end THEN 'baseline'
         WHEN ctr.unix_epoc_time >= upvote_start AND ctr.unix_epoc_time <= upvote_end THEN 'upvote_only'
         ELSE 'no_period'
     END as period
 FROM (SELECT subreddit as txt_subreddit,
         min(CASE WHEN intervention = 'baseline' THEN start_date_unix_epoc END) AS baseline_start,
         min(CASE WHEN intervention = 'baseline' THEN end_date_unix_epoc END) AS baseline_end,
         min(CASE WHEN intervention = 'upvote_only' THEN start_date_unix_epoc END) AS upvote_start,
         min(CASE WHEN intervention = 'upvote_only' THEN end_date_unix_epoc END) AS upvote_end
         FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions`
         where subreddit not in ('vegan', 'unpopularopinion', 'EnoughTrumpSpam')--vegan and unpopularopinion subreddits did not have the upvote intervention. EnoughTrumpSpam only has 13 observations in the baseline period
         group by subreddit) as dt
 LEFT JOIN cart on cart.subreddit = dt.txt_subreddit
 LEFT JOIN `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as ctr
     ON ctr.subreddit = cart.ctr_subreddit
 LEFT JOIN (select author, subreddit,COUNT(author) as author_posts_per_subreddit
                FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct`
                WHERE BYTE_LENGTH(author) > 0
                group by author, subreddit) as author_count on author_count.author = ctr.author AND author_count.subreddit = ctr.subreddit
 );

--create a table that contains the average values of the language subcomponents and the total number of observations per period to enable
--matching to the treatment subreddits. Note that the aggregates are also computed for the upvote period so that subreddits can also
--be matched on number of observations during the intervention, but the average language subcomponent values SHOULD NOT be used for
--selection of the appropriate controls
 create table `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_ctr` as (
 SELECT txt_subreddit, ctr_subreddit, period,
     avg(counter_argument_structure) as ctr_avg_counter_argument_structure,
     avg(emotional_language) as ctr_avg_emotional_language,
     avg(other) as ctr_avg_other,
     avg(you_in_the_epicenter) as ctr_avg_you_in_the_epicenter,
     avg(empathy_reciprocity) as ctr_avg_empathy_reciprocity,
     avg(generalized_call) as ctr_avg_generalized_call,
     avg(situational_call_for_action) as ctr_avg_situational_call_for_action,
     avg(collective_rhetoric) as ctr_avg_collective_rhetoric,
     avg(ungrounded_argument) as ctr_avg_ungrounded_argument,
     count(post_id) as ctr_obs_per_period,
 from `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_ctr`
 group by ctr_subreddit, period, txt_subreddit
 HAVING period != 'no_period'
 order by txt_subreddit, ctr_subreddit, period);

--create a table that contains the same info for the upvote treatment subreddits for subsequent matching to the control subreddits
create table `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_txt` as (
SELECT subreddit as txt_subreddit, intervention as period,
    avg(counter_argument_structure) as txt_avg_counter_argument_structure,
    avg(emotional_language) as txt_avg_emotional_language,
    avg(other) as txt_avg_other,
    avg(you_in_the_epicenter) as txt_avg_you_in_the_epicenter,
    avg(empathy_reciprocity) as txt_avg_empathy_reciprocity,
    avg(generalized_call) as txt_avg_generalized_call,
    avg(situational_call_for_action) as txt_avg_situational_call_for_action,
    avg(collective_rhetoric) as txt_avg_collective_rhetoric,
    avg(ungrounded_argument) as txt_avg_ungrounded_argument,
    count(post_id) as txt_obs_per_period,
from `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct_txt`
WHERE subreddit != 'EnoughTrumpSpam'
group by intervention, subreddit
HAVING intervention != 'no_votes'
order by subreddit, intervention);;

-- create a table joining the treatment average language values and control average language values to allow correlations to be calculated elsewhere
-- too hard to figure out how to do rowise correlations within SQL
create table `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_txt_and_ctr_avg` as (
SELECT txt.txt_subreddit,
      ctr.ctr_subreddit,
      txt.txt_obs_per_period as txt_obs_per_baseline,
      ctr.ctr_obs_per_period as ctr_obs_per_baseline,
      txt_obs.txt_obs_per_upvote,
      ctr_obs.ctr_obs_per_upvote,
      txt.txt_avg_counter_argument_structure,
      txt.txt_avg_emotional_language,
      txt.txt_avg_you_in_the_epicenter,
      txt.txt_avg_empathy_reciprocity,
      txt.txt_avg_generalized_call,
      txt.txt_avg_situational_call_for_action,
      txt.txt_avg_collective_rhetoric,
      txt.txt_avg_ungrounded_argument,
      ctr.ctr_avg_counter_argument_structure,
      ctr.ctr_avg_emotional_language,
      ctr.ctr_avg_you_in_the_epicenter,
      ctr.ctr_avg_empathy_reciprocity,
      ctr.ctr_avg_generalized_call,
      ctr.ctr_avg_situational_call_for_action,
      ctr.ctr_avg_collective_rhetoric,
      ctr.ctr_avg_ungrounded_argument,
FROM `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_txt` txt
JOIN `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_ctr` ctr
   ON ctr.txt_subreddit = txt.txt_subreddit and ctr.period = txt.period
JOIN (SELECT txt_subreddit, txt_obs_per_period as txt_obs_per_upvote
       from `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_txt`
       WHERE period = 'upvote_only') txt_obs on txt_obs.txt_subreddit = txt.txt_subreddit
JOIN (SELECT ctr_subreddit, txt_subreddit, ctr_obs_per_period as ctr_obs_per_upvote
       from `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_avg_ctr`
       WHERE period = 'upvote_only') ctr_obs on ctr_obs.ctr_subreddit = ctr.ctr_subreddit
           and ctr_obs.txt_subreddit = ctr.txt_subreddit
WHERE txt.period = 'baseline'
);


create table `citp-sm-reactions.reddit_clean_comments.subreddits_union_upvote_ctr_txt` as (
SELECT post_id, link_id, sub_id, subreddit, author, intervention as period, 'treatment' as group_type, who_instead_of_what, we_vs_them, fact_related_argument, structured_argument,
             counter_argument_structure, emotional_language,other, you_in_the_epicenter, empathy_reciprocity,
             generalized_call, situational_call_for_action,
             collective_rhetoric, ungrounded_argument, nest_level, body_length, author_posts_per_subreddit
FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct_txt`
WHERE subreddit in ('atheism', 'Conservative', 'exmuslim', 'politics', 'ukpolitics')
AND intervention in ('baseline', 'upvote_only')
UNION DISTINCT
SELECT post_id, link_id, sub_id, ctr_subreddit as subreddit, author, period, 'control' as group_type, who_instead_of_what, we_vs_them, fact_related_argument, structured_argument,
             counter_argument_structure, emotional_language,other, you_in_the_epicenter, empathy_reciprocity,
             generalized_call, situational_call_for_action,
             collective_rhetoric, ungrounded_argument, nest_level, body_length, author_posts_per_subreddit
FROM `citp-sm-reactions.reddit_clean_comments.subreddits_for_upvote_ctr`
WHERE (txt_subreddit = "atheism" AND ctr_subreddit = "PoliticalHumor" AND period != "no_period") OR
       (txt_subreddit = "Conservative" AND ctr_subreddit = "Republican" AND period != "no_period") OR
        (txt_subreddit = "exmuslim" AND ctr_subreddit = "Anarchism" AND period != "no_period") OR
        (txt_subreddit = "politics" AND ctr_subreddit = "progressive" AND period != "no_period") OR
       (txt_subreddit = "ukpolitics" AND ctr_subreddit = "Anarcho_Capitalism" AND period != "no_period")
);



-- select distinct(intervention) from `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct_txt`
-- SELECT m.post_id, m.subreddit, j.txt_subreddit , j.ctr_subreddit
-- FROM `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions` m
-- INNER JOIN (SELECT txt_subreddit, ctr_subreddit, post_id from `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt`
--                     WHERE (txt_subreddit = "atheism" AND ctr_subreddit = "conspiracy")) j
--     ON m.subreddit = j.ctr_subreddit and m.post_id = j.post_id
-- ORDER BY j.txt_subreddit DESC;


-- SELECT post_id, subreddit
-- FROM `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions`
-- where post_id in (SELECT post_id from `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt`
--                     WHERE (txt_subreddit = 'atheism' AND ctr_subreddit = "conspiracy") OR
--                     (txt_subreddit = 'Conservative' AND ctr_subreddit = "Republican"))

---- with ts as (
--    SELECT txt.txt_subreddit,
--       ctr.ctr_subreddit,
--       txt.txt_obs_per_period as txt_obs_per_baseline,
--       ctr.ctr_obs_per_period as ctr_obs_per_baseline,
--       txt_obs.txt_obs_per_upvote,
--       txt.txt_avg_counter_argument_structure,
--       txt.txt_avg_emotional_language,
--       txt.txt_avg_you_in_the_epicenter,
--       txt.txt_avg_empathy_reciprocity,
--       txt.txt_avg_generalized_call,
--       txt.txt_avg_situational_call_for_action,
--       txt.txt_avg_collective_rhetoric,
--       txt.txt_avg_ungrounded_argument,
--       ctr.ctr_avg_counter_argument_structure,
--       ctr.ctr_avg_emotional_language,
--       ctr.ctr_avg_you_in_the_epicenter,
--       ctr.ctr_avg_empathy_reciprocity,
--       ctr.ctr_avg_generalized_call,
--       ctr.ctr_avg_situational_call_for_action,
--       ctr.ctr_avg_collective_rhetoric,
--       ctr.ctr_avg_ungrounded_argument,
--FROM `citp-sm-reactions.reddit_clean_comments.txt_subreddits_for_upvote_txt_avg` txt
--JOIN `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt_avg` ctr
--    ON ctr.txt_subreddit = txt.txt_subreddit and ctr.period = txt.period
--JOIN (SELECT txt_subreddit, txt_obs_per_period as txt_obs_per_upvote
--        from `citp-sm-reactions.reddit_clean_comments.txt_subreddits_for_upvote_txt_avg`
--        WHERE period = 'upvote') txt_obs on txt_obs.txt_subreddit = txt.txt_subreddit
--JOIN (SELECT ctr_subreddit, txt_subreddit, ctr_obs_per_period as ctr_obs_per_upvote
--        from `citp-sm-reactions.reddit_clean_comments.ctr_subreddits_for_upvote_txt_avg`
--        WHERE period = 'upvote') ctr_obs on ctr_obs.ctr_subreddit = ctr.ctr_subreddit
--            and ctr_obs.txt_subreddit = ctr.txt_subreddit
--WHERE txt.period = 'baseline'
