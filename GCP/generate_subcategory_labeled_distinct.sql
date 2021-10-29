---because the language model script was run multiple times and new folders were introduced that had the same unique identifiers
---(e.g., _poltics* contains many of the same posts as politics), we need to get rid of near duplicates. Note that this CANNOT
---be accomplished with a group by on all columns because the predicted values for the same unique identifier will differ slightly
---from one model run to another, particularly if predictions are very near zero in both files that contain the same unique record
create table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as (
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY post_id ORDER BY post_score) post_id_rn
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled`
) x
WHERE post_id_rn = 1)
