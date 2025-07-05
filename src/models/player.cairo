use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerAnswer {
    #[key]
    pub game_id: felt252,
    #[key]
    pub player: ContractAddress,
    #[key]
    pub question_index: u8,
    pub selected_option: u8,
    pub time_taken: u8,
    pub points_earned: u16,
    pub is_correct: bool,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerResult {
    #[key]
    pub game_id: felt252,
    #[key]
    pub player: ContractAddress,
    pub total_score: u32, // Sum of all question points
    pub correct_answers: u8, // Number of correct answers
    pub rank: u8, // Final ranking (1st, 2nd, 3rd, etc.)
    pub reward_amount: u256, // Crypto reward earned
    pub reward_claimed: bool,
    pub bonus_points: u16,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerAchievement {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub achievement_id: felt252,
    pub earned_at: u64,
    pub progress: u32,
    pub completed: bool,
}
