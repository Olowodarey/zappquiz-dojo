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
    public: bool,
    default_duration: u256,
    default_max_points: u16,
    custom_timing: bool,
    creator: ContractAddress,
    // reward_settings: RewardSettings,
    questions: Array<Question>,
    amount: u256,
    has_rewards: bool,
    distribution_type: PrizeDistribution,
    number_of_winners: u8,
    prize_percentage: Array<u8>,
    min_players: u32,
    token_address: ContractAddress
    ) -> u256;

    fn create_game_session(ref self: T, quiz_id: u256, max_players: u32) -> u256;
    fn join_game_session(ref self: T, session_id: u256, player: ContractAddress);
    fn start_game_session(ref self: T, session_id: u256);
    fn next_question(ref self: T, session_id: u256);
    fn submit_answer(ref self: T, session_id: u256, question_num: u32, answer: u8);
    fn get_quiz(self: @T, quiz_id: u256) -> Quiz;
    fn create_new_quiz_id(ref self: T,) -> u256;
    fn create_new_question_id(ref self: T,) -> u256;
    fn create_new_game_id(ref self: T,) -> u256;
}