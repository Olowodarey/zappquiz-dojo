use starknet::ContractAddress;

// Player's Achievements/Badges
#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum AchievementType {
    FirstWin,                           // Won first game
    SpeedDemon,                         // Answered all questions under 5 seconds
    PerfectScore,                       // 100% accuracy in a game
    Consistent,                         // Won 5 games in a row
    TriviaMaster,                       // Won 100 games
    BigWinner,                          // Earned over 1000 USDC in rewards
    CategoryExpert,                     // Won 10 games in same category
    QuickDraw,                          // Fastest answer in a game
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
#[dojo::model]
pub struct PlayerCounter {
    #[key]
    pub id: felt252,
    pub current_val: u256,
}


#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub nickname: felt252, 
    pub avatar_url: ByteArray,
    pub total_games_played: u32,
    pub total_wins: u32,
    pub total_losses: u32,
    pub total_score: u32, 
    pub total_time_played: u64,
    pub last_active: u64, 
    pub achievements_completed: u32,

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

#[derive(Copy, Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct PlayerResult {
    #[key]
    pub game_id: felt252,
    #[key]
    pub achievement_type: AchievementType,
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

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerPendingReward {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game_id: felt252,
    pub reward_amount: u256,
    pub token_address: ContractAddress,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerQuizCreation {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub quiz_title: felt252,
    pub created_at: u64,
    pub total_plays: u32,               // How many times this quiz was played
    pub total_players: u32,             // How many unique players played it
    pub total_rewards_distributed: u256, // Total rewards given out
}