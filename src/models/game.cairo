use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Debug)]
pub enum QuestionType{
    mutichoice,
    TrueFalse,
}

#[derive(Copy, Drop, Serde, Debug)]
pub enum PrizeDistribution {
    WinnerTakesAll,
    SplitTopThree,
    Custom
}

#[derive(Copy, Drop, Serde, Debug)]
pub enum GameStatus{
    Waiting,
    Active,
    Completed,
}

#[derive(Copy, Drop, Serde, Debug)]
pub struct Question {
    pub text: ByteArray,
    pub question_type: QuestionType,
    pub options: Array<felt252>,
    pub correct_option: u8,
    pub duration_seconds: u8,
    pub point: u8,
    pub max_ponts: u16
}

#[derive(Copy, Drop, Debug)]
pub struct RewardSettings{
    pub has_rewards: bool,
    pub token_address: ContractAddress,
    pub reward_amount: u256,
    pub disttribution_type: PrizeDistribution,
    pub number_of_winners: u8,
    pub prize_percentage: Array<u8>,
    pub min_players: u32 
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Quiz {
    #[key]
    pub title: felt252,
    pub description: ByteArray,
    pub category: felt252,
    pub questions: Array<Question>,
    pub public: bool,
    pub default_duration: u8,
    pub default_max_points: u16,
    pub custom_timing: bool,
    pub creator: ContractAddress,
    pub reward_settings: RewardSettings,
    pub created_at: u64,
}

#derive[(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct  GameSession{
    #[key]
    pub game_id: felt252,
    pub quiz_title: felt252,
    pub host: ContractAddress,
    pub status: GameStatus,
    pub total_players: u32,
    pub current_question: u8,
    pub reward_distributed: bool,
    pub started_at: u64,
    pub ended_at:  u64
}

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
    pub total_score: u32,                // Sum of all question points
    pub correct_answers: u8,             // Number of correct answers
    pub rank: u8,                        // Final ranking (1st, 2nd, 3rd, etc.)
    pub reward_amount: u256,             // Crypto reward earned
    pub reward_claimed: bool,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct QuizLeaderboard {
    #[key]
    pub quiz_title: felt252,
    #[key]
    pub player: ContractAddress,
    pub best_score: u32,
    pub total_plays: u32,
    pub win_count: u32,                  // Number of times ranked #1
}
