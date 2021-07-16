create table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_interventions_full` as 
    (
        SELECT distinct(sub.post_id), sub.link_id, sub.sub_id, sub.subreddit, byte_length(sub.body) as body_length,
            sub.who_instead_of_what, sub.we_vs_them, sub.fact_related_argument, sub.structured_argument,
            sub.counter_argument_structure, sub.emotional_language,sub.other, sub.you_in_the_epicenter, sub.empathy_reciprocity,
            sub.generalized_call, sub.situational_call_for_action,
            sub.collective_rhetoric, sub.ungrounded_argument,
            rxn.intervention, rxn.start_date_unix_epoc as int_start_unix_time, rxn.end_date_unix_epoc as int_end_unix_time, sub.unix_epoc_time as post_unix_time
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_march_epoc_csv` as sub
        INNER JOIN `citp-sm-reactions.reddit_clean_comments.reaction_interventions_epoc` as rxn
            ON (sub.unix_epoc_time >= rxn.start_date_unix_epoc) AND (sub.unix_epoc_time <= rxn.end_date_unix_epoc) 
            AND sub.subreddit = rxn.subreddit
    );
