use zappquiz::models::quiz::{RewardSettings, Question};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IZappQuiz<T> {
    fn create_quiz(
        ref self: T,
        title: felt252,
        description: ByteArray,
        category: felt252,
        questions: Array<Question>,
        public: bool,
        default_duration: u8,
        default_max_points: u16,
        custom_timing: bool,
        creator: ContractAddress,
        reward_settings: RewardSettings,
    );
}