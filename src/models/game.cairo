use starknet::{ContractAddress};


#[derive(Copy, Drop, Introspect, Serde, Debug)]
pub enum GameStatus {
    Waiting,
    Active,
    Completed,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct GameSession {
    #[key]
    pub game_id: felt252,
    pub quiz_title: felt252,
    pub host: ContractAddress,
    pub status: GameStatus,
    pub total_players: u32,
    pub current_question: u8,
    pub reward_distributed: bool,
    pub started_at: u64,
    pub ended_at: u64,
    pub total_reward_pool: u256,
    pub platform_fees_collected: u256,
    pub max_players: u32,
    pub entry_fee_collected: u256,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct LivePlayerState {
    #[key]
    pub game_code: felt252,
    #[key]
    pub player: ContractAddress,
    pub nickname: felt252, // Player's display name
    pub current_score: u32,
    pub current_streak: u8,
    pub is_connected: bool,
    pub last_answer_time: u64,
    pub answered_current_question: bool,
    pub current_rank: u32,
    pub points_this_question: u16,
}

// Game settings and configuration
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct GameConfig {
    #[key]
    pub id: u8,
    pub min_players: u32,
    pub max_players: u32,
    pub default_question_time: u8,
    pub max_question_time: u8,
    pub min_question_time: u8,
    pub streak_bonus_multiplier: u8,
    pub time_bonus_enabled: bool,
    pub difficulty_bonus_enabled: bool,
    pub updated_at: u64,
}

