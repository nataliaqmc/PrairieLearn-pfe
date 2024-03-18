-- Adding median_question_score to assessment_questions table
ALTER TABLE assessment_questions
ADD COLUMN median_question_score NUMERIC;

-- Adding number_of_submissions to assessment_questions table
ALTER TABLE assessment_questions
ADD COLUMN number_submissions NUMERIC;

-- Adding total_students_enrolled to assessment_questions table
ALTER TABLE assessment_questions
ADD COLUMN total_students_enrolled NUMERIC;
