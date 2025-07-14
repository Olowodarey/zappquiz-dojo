use zapp_quiz::models::quiz_model::RewardSettings;
use zapp_quiz::models::question_model::Question;
use zapp_quiz::models::quiz_model::Quiz;
use zapp_quiz::models::quiz_model::PrizeDistribution;
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
        has_rewards: bool,
        distribution_type: PrizeDistribution,
        number_of_winners: u8,
        prize_percentage: Array<u8>,
        min_players: u32,
    ) -> Quiz;
    
    fn create_new_quiz_id(ref self: T,) -> u256;

    fn add_question(ref self: T, question: Question);

    fn delete_question(ref self: T, question_id: u256);
}