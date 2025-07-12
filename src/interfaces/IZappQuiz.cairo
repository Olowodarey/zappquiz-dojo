use zapp_quiz::models::quiz_model::RewardSettings;
use zapp_quiz::models::question_model::Question;
use zapp_quiz::models::quiz_model::Quiz;
use starknet::ContractAddress;

#[starknet::interface]
pub trait IZappQuiz<T> {
    fn create_quiz(
        ref self: T,
        title: ByteArray,
        description: ByteArray,
        category: ByteArray,
        questions: Array<Question>,
        public: bool,
        default_duration: u256,
        default_max_points: u16,
        custom_timing: bool,
        creator: ContractAddress,
        reward_settings: RewardSettings,
        amount: u256,
    ) -> Quiz;
    
    fn create_new_quiz_id(ref self: T,) -> u256;
}