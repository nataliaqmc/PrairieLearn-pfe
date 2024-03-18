-- BLOCK select_assessment
SELECT
  to_jsonb(a) AS assessment
FROM
  assessments AS a
WHERE
  a.id = $assessment_id;

-- BLOCK select_total_students
SELECT
  COUNT(e.course_instance_id) AS students_total,
FROM
  assessments AS a
  LEFT JOIN enrollments AS e ON (a.course_instance_id = e.course_instance_id)
WHERE
  a.course_instance_id = $course_instance_id
GROUP BY
  a.id;

-- BLOCK barplot
SELECT
  t1.question,
  t1.submissions,
  t2.students_total
FROM
  (
    SELECT
      v.question_id as question,
      COUNT(DISTINCT v.user_id) as submissions,
      SUM(
        CASE
          WHEN s.correct = 't' THEN 1
          ELSE 0
        END
      ) AS correct
    FROM
      submissions as s
      LEFT JOIN variants as v ON (s.variant_id = v.id)
    WHERE
      v.course_instance_id = 2
    GROUP BY
      v.question_id
  ) AS t1
  JOIN (
    SELECT
      v.question_id as question,
      COUNT(DISTINCT e.user_id) AS students_total
    FROM
      assessments as a
      LEFT JOIN enrollments as e ON (a.course_instance_id = e.course_instance_id)
      LEFT JOIN variants as v ON (a.course_instance_id = v.course_instance_id)
    WHERE
      a.course_instance_id = 2
    GROUP BY
      v.question_id
  ) AS t2 ON t1.question = t2.question;

-- BLOCK assessment_stats_last_updated
SELECT
  CASE
    WHEN a.stats_last_updated IS NULL THEN 'never'
    ELSE format_date_full_compact (a.stats_last_updated, ci.display_timezone)
  END AS stats_last_updated
FROM
  assessments AS a
  JOIN course_instances AS ci ON (ci.id = a.course_instance_id)
WHERE
  a.id = $assessment_id
  -- BLOCK questions
SELECT
  c.short_name AS course_short_name,
  ci.short_name AS course_instance_short_name,
  (aset.abbreviation || a.number) as assessment_label,
  aq.*,
  q.qid,
  q.title AS question_title,
  row_to_json(top) AS topic,
  q.id AS question_id,
  admin_assessment_question_number (aq.id) as assessment_question_number,
  ag.number AS alternative_group_number,
  ag.number_choose AS alternative_group_number_choose,
  (
    count(*) OVER (
      PARTITION BY
        ag.number
    )
  ) AS alternative_group_size,
  z.title AS zone_title,
  z.number AS zone_number,
  (
    lag(z.id) OVER (
      PARTITION BY
        z.id
      ORDER BY
        aq.number
    ) IS NULL
  ) AS start_new_zone,
  (
    lag(ag.id) OVER (
      PARTITION BY
        ag.id
      ORDER BY
        aq.number
    ) IS NULL
  ) AS start_new_alternative_group
FROM
  assessment_questions AS aq
  JOIN questions AS q ON (q.id = aq.question_id)
  JOIN alternative_groups AS ag ON (ag.id = aq.alternative_group_id)
  JOIN zones AS z ON (z.id = ag.zone_id)
  JOIN topics AS top ON (top.id = q.topic_id)
  JOIN assessments AS a ON (a.id = aq.assessment_id)
  JOIN assessment_sets AS aset ON (aset.id = a.assessment_set_id)
  JOIN course_instances AS ci ON (ci.id = a.course_instance_id)
  JOIN pl_courses AS c ON (c.id = ci.course_id)
WHERE
  a.id = $assessment_id
  AND aq.deleted_at IS NULL
  AND q.deleted_at IS NULL
ORDER BY
  z.number,
  z.id,
  aq.number;
