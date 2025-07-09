#[derive(Copy, Drop, Introspect, Serde, Debug, PartialEq)]
pub enum QuestionType {
    multichoice,
    TrueFalse,
}

#[derive(Clone, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Question {
    #[key]
    pub id: u256,
    pub text: ByteArray,
    pub question_type: QuestionType,
    pub options: Array<ByteArray>,
    pub correct_option: ByteArray,
    pub duration_seconds: u8,
    pub point: u8,
    pub max_points: u16,
}


pub trait QuestionTrait {
    fn new(id: u256, text: ByteArray, question_type: QuestionType, options: Array<ByteArray>, correct_option: ByteArray, duration_seconds: u8, point: u8, max_points: u16) -> Question;
}

impl implQuestion of QuestionTrait {
    fn new(id: u256, text: ByteArray, question_type: QuestionType, options: Array<ByteArray>, correct_option: ByteArray, duration_seconds: u8, point: u8, max_points: u16) -> Question {
        Question {
            id,
            text,
            question_type,
            options,
            correct_option,
            duration_seconds,
            point,
            max_points,
        }
    }
}