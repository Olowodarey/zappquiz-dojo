use starknet::ContractAddress;

// Analytics and reporting models
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct DailyStats {
    #[key]
    pub date: u64, // Unix timestamp for the day
    pub games_played: u32,
    pub unique_players: u32,
    pub total_rewards: u256,
    pub platform_fees: u256,
    pub new_users: u32,
    pub quiz_created: u32,
    pub average_game_size: u32,
}


// Creator statistics
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct CreatorStats {
    #[key]
    pub creator: ContractAddress,
    pub total_quizzes_created: u32,
    pub total_games_hosted: u32,
    pub total_rewards_distributed: u256,
    pub total_platform_fees_paid: u256,
    pub average_game_size: u32,
    pub last_activity: u64,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlatformStats {
    #[key]
    pub id: u8,
    pub total_games_created: u32,
    pub total_fees_collected: u256,
    pub total_rewards_distributed: u256,
    pub active_games: u32,
    pub total_players: u32,
    pub last_updated: u64,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct QuestionResults {
    #[key]
    pub game_code: felt252,
    #[key]
    pub question_index: u8,
    pub option_a_count: u32,
    pub option_b_count: u32,
    pub option_c_count: u32,
    pub option_d_count: u32,
    pub correct_answers: u32,
    pub fastest_player: ContractAddress,
    pub fastest_time: u8,
    pub average_time: u8,
}
