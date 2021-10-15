SELECT count(post_id) as ctr_obvs_per_period, subreddit, period FROM (
    SELECT post_id, subreddit,
        CASE WHEN unix_epoc_time >= (SELECT txt.start_date_unix_epoc FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` txt
                    WHERE txt.intervention = 'baseline' and txt.subreddit = 'Conservative')
                AND unix_epoc_time < (SELECT txt.end_date_unix_epoc FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` txt
                    WHERE txt.intervention = 'baseline' and txt.subreddit = 'Conservative')
                THEN 'baseline_per'
                WHEN unix_epoc_time >= (SELECT txt.start_date_unix_epoc FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` txt
                    WHERE txt.intervention = 'upvote_only' and txt.subreddit = 'Conservative')
                AND unix_epoc_time < (SELECT txt.end_date_unix_epoc FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` txt
                    WHERE txt.intervention = 'upvote_only' and txt.subreddit = 'Conservative')
                THEN 'upvote_per'
            END AS period
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct`) ctr
    WHERE ctr.period is NOT NULL AND subreddit NOT in (SELECT distinct(subreddit) FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt`)
GROUP BY subreddit, period
ORDER BY subreddit, period;



-- with txt as (
--     SELECT subreddit as txt_subreddit,
--     min(CASE WHEN intervention = 'baseline' THEN start_date_unix_epoc END) AS baseline_start,
--     min(CASE WHEN intervention = 'baseline' THEN end_date_unix_epoc END) AS baseline_end,
--     min(CASE WHEN intervention = 'upvote_only' THEN start_date_unix_epoc END) AS upvote_start,
--     min(CASE WHEN intervention = 'upvote_only' THEN end_date_unix_epoc END) AS upvote_end
--     FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt`
--     where subreddit not in ('vegan', 'unpopularopinion')
--     group by subreddit)
-- SELECT ctr.subreddit,ctr.post_id
-- FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` ctr



-- select txt.subreddit,
--     (case
--         WHEN txt.intervention = 'baseline' THEN txt.start_date_unix_epoc
--     end) as baseline_start,
--     (case
--         WHEN txt.intervention = 'baseline' THEN txt.end_date_unix_epoc
--     end) as baseline_end,
--     (case
--         WHEN txt.intervention = 'upvote_only' THEN txt.start_date_unix_epoc
--     end) as txt_start,
--     (case
--         WHEN txt.intervention = 'upvote_only' THEN txt.start_date_unix_epoc
--     end) as txt_end
-- FROM `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` txt





--     txt.int_start_unix_time, txt.int_end_unix_time, txt.intervention,
--     count(txt.post_id) as obvs_per_intervention
--     FROM `citp-sm-reactions.reddit_clean_comments.labeled_comments_with_interventions_txt` txt
--     where txt.subreddit = "Conservative"
--     group by txt.subreddit, txt.int_start_unix_time, txt.int_end_unix_time, txt.intervention)
-- select ctr.subreddit, count(ctr.post_id) as ctr_obvs_count, sub_txt.intervention
-- FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` ctr
-- INNER JOIN sub_txt
--            ON (ctr.unix_epoc_time >= sub_txt.int_start_unix_time) AND (ctr.unix_epoc_time <= sub_txt.int_end_unix_time)







-- -- SELECT distinct(sub.post_id), sub.link_id, sub.sub_id, sub.subreddit, sub.author, byte_length(sub.body) as body_length, sub.nest_level, sub.post_score,
-- --             author_count.author_posts_per_subreddit,
-- --             sub.who_instead_of_what, sub.we_vs_them, sub.fact_related_argument, sub.structured_argument,
-- --             sub.counter_argument_structure, sub.emotional_language,sub.other, sub.you_in_the_epicenter, sub.empathy_reciprocity,
-- --             sub.generalized_call, sub.situational_call_for_action,
-- --             sub.collective_rhetoric, sub.ungrounded_argument,
-- --             rxn.intervention, rxn.start_date_unix_epoc as int_start_unix_time, rxn.end_date_unix_epoc as int_end_unix_time, sub.unix_epoc_time as post_unix_time
-- --         FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled` as sub
-- --         INNER JOIN `citp-sm-reactions.reddit_clean_comments.reaction_interventions_txt` as rxn
-- --             ON (sub.unix_epoc_time >= rxn.start_date_unix_epoc) AND (sub.unix_epoc_time <= rxn.end_date_unix_epoc)
-- --             AND sub.subreddit = rxn.subreddit
-- --         LEFT JOIN (select author, subreddit,COUNT(author) as author_posts_per_subreddit
-- --                 FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled`
-- --                 WHERE BYTE_LENGTH(author) > 0
-- --                 group by author, subreddit) as author_count on author_count.author = sub.author AND author_count.subreddit = sub.subreddit

