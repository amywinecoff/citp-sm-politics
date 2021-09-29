create table `citp-sm-reactions.reddit_clean_comments.subcategory_labeled_distinct` as (
    SELECT *
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY post_id ORDER BY post_score) post_id_rn
        FROM `citp-sm-reactions.reddit_clean_comments.subcategory_labeled`
) x
WHERE post_id_rn = 1)
