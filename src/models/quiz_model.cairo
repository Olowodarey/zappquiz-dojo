use starknet::ContractAddress;

#[derive(Copy, Drop, Introspect, Serde, Debug)]
pub enum QuestionType {
    multichoice,
    TrueFalse,
}

#[derive(Copy, Drop, Introspect, Serde, Debug, PartialEq)]
pub enum PrizeDistribution {
    WinnerTakesAll,
    SplitTopThree,
    Custom,
}

#[derive(Clone, Drop, Introspect, Serde, Debug)]
pub struct RewardSettings {
    pub has_rewards: bool,
    pub token_address: ContractAddress,
    pub reward_amount: u256,
    pub distribution_type: PrizeDistribution,
    pub number_of_winners: u8,
    pub prize_percentage: Array<u8>,
    pub min_players: u32,
}

#[derive(Clone, Drop, Serde, Debug)]
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
    pub game_sessions_created: u32,
    pub total_rewards_distributed: u256,
    pub platform_fees_generated: u256,
    pub is_active: bool,
}

#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct Question {
    #[key]
    pub id: u256,
    pub text: ByteArray,
    pub question_type: QuestionType,
    pub options: Array<felt252>,
    pub correct_option: u8,
    pub duration_seconds: u8,
    pub point: u8,
    pub max_points: u16,
}

#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct QuizRating {
    #[key]
    pub quiz_title: felt252,
    #[key]
    pub player: ContractAddress,
    pub rating: u8, // 1-5 stars
    pub comment: ByteArray,
    pub created_at: u64,
    pub helpful_votes: u32,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct QuizLeaderboard {
    #[key]
    pub quiz_title: felt252,
    #[key]
    pub player: ContractAddress,
    pub best_score: u32,
    pub total_player_participation: u32,
    pub win_count: u32, // Number of times ranked #1
    pub total_points_earned: u32,
}
