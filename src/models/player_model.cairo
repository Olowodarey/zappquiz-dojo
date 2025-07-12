use starknet::ContractAddress;

// Enhanced Achievement System
#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum AchievementType {
    FirstWin,                           
    SpeedDemon,                         
    PerfectScore,                       
    Consistent,                         
    TriviaMaster,                       
    BigWinner,                          
    CategoryExpert,                     
    QuickDraw,
    // New achievements
    Streak10,                           // 10 game win streak
    Streak25,                           // 25 game win streak
    TopPerformer,                       // Top 3 finish 50 times
    QuizCreator,                        // Created first quiz
    PopularCreator,                     // Quiz played by 100+ players
    CategoryMaster,                     // Master of 5 different categories
    WeeklyChampion,                     // Won most games in a week
    MonthlyLegend,                      // Won most games in a month
    LightningRound,                     // Answered 10 questions in under 30 seconds
    Comeback,                           // Won after being last place
}

#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum PlayerQuizCreationStatus {
    Active,
    Ended,
    Archived,                           // Soft delete for historical data
}

#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum PlayerTier {
    Bronze,
    Silver, 
    Gold,
    Platinum,
    Diamond,
    Master,
}

#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum QuizDifficulty {
    Easy,
    Medium,
    Hard,
    Expert,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
#[dojo::model]
pub struct PlayerCounter {
    #[key]
    pub id: felt252,
    pub current_val: u256,
}

// Enhanced Player model with better stats tracking
#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub nickname: felt252, 
    pub avatar_url: ByteArray,
    pub created_at: u64,                    // When player joined
    pub total_games_played: u32,
    pub total_wins: u32,
    pub total_losses: u32,
    pub current_win_streak: u32,            // Current consecutive wins
    pub best_win_streak: u32,               // Best ever win streak
    pub total_score: u64,                   // Increased from u32 for larger scores
    pub average_score: u32,                 // Calculated average score per game
    pub total_time_played: u64,
    pub average_answer_time: u32,           // Average time per answer in seconds
    pub last_active: u64,
    pub achievements_completed: u32,
    pub player_tier: PlayerTier,            // Ranking tier
    pub tier_points: u32,                   // Points toward next tier
    pub total_earnings: u256,               // Total crypto earned
    pub favorite_category: felt252,         // Most played category
    pub games_created: u32,                 // Number of quizzes created
    pub is_active: bool,                    // Account status
    pub referral_code: felt252,             // For referral system
    pub referred_by: ContractAddress,       // Who referred this player
}

// Enhanced PlayerAnswer with more granular data
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
    pub time_taken: u16,                    // Increased from u8 for more precision
    pub points_earned: u16,
    pub is_correct: bool,
    pub difficulty: QuizDifficulty,         // Question difficulty
    pub category: felt252,                  // Question category
    pub answered_at: u64,                   // Timestamp when answered
}

// Improved PlayerResult with better reward tracking
#[derive(Copy, Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct PlayerResult {
    #[key]
    pub game_id: felt252,
    #[key]
    pub player: ContractAddress,
    pub total_score: u32,
    pub correct_answers: u8,
    pub total_questions: u8,                // For accuracy calculation
    pub rank: u8,
    pub reward_amount: u256,
    pub reward_claimed: bool,
    pub bonus_points: u16,
    pub completion_time: u64,               // Total time to complete quiz
    pub perfect_score: bool,                // Whether player got 100%
    pub speed_bonus: u256,                  // Bonus for fast completion
    pub accuracy_bonus: u256,               // Bonus for high accuracy
    pub game_completed_at: u64,             // When game was finished
}

// Enhanced Achievement tracking with progress
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerAchievement {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub achievement_type: AchievementType,  // Use enum instead of felt252
    pub earned_at: u64,
    pub progress: u32,
    pub target: u32,                        // Target value for achievement
    pub completed: bool,
    pub reward_claimed: bool,               // Whether reward was claimed
    pub reward_amount: u256,                // Reward for this achievement
}

// Enhanced reward system
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerPendingReward {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game_id: felt252,
    pub reward_amount: u256,
    pub token_address: ContractAddress,
    pub created_at: u64,                    // When reward was earned
    pub expires_at: u64,                    // Expiration time for claiming
    pub reward_type: felt252,               // Type of reward (game_win, achievement, etc.)
}

// Enhanced quiz creation tracking
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerQuizCreation {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub quiz_id: felt252,                   // Unique quiz ID instead of title
    pub quiz_title: felt252,
    pub created_at: u64,
    pub updated_at: u64,                    // Last modification time
    pub num_of_questions: u32,
    pub times_played: u32,                  // Renamed for clarity
    pub total_players: u32,
    pub total_rewards_distributed: u256,
    pub status: PlayerQuizCreationStatus,
    pub difficulty: QuizDifficulty,         // Quiz difficulty level
    pub category: felt252,                  // Quiz category
    pub average_score: u32,                 // Average score of players
    pub average_completion_time: u64,       // Average time to complete
    pub creator_earnings: u256,             // How much creator earned
    pub is_featured: bool,                  // Whether quiz is featured
    pub rating: u8,                         // User rating out of 5
    pub total_ratings: u32,                 // Number of ratings received
}

// New model for tracking player statistics over time
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model] 
pub struct PlayerStatistics {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub period: felt252,                    // daily, weekly, monthly
    #[key]
    pub timestamp: u64,                     // Period start timestamp
    pub games_played: u32,
    pub games_won: u32,
    pub total_score: u64,
    pub total_time_played: u64,
    pub average_answer_time: u32,
    pub earnings: u256,
    pub achievements_earned: u32,
}

// New model for leaderboards
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerLeaderboard {
    #[key]
    pub leaderboard_type: felt252,          // weekly, monthly, all_time, category
    #[key]
    pub player: ContractAddress,
    pub rank: u32,
    pub score: u64,
    pub last_updated: u64,
    pub tier: PlayerTier,
}

// Enhanced reward history
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerRewardHistory {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub reward_id: felt252,
    pub quiz_title: ByteArray,
    pub game_id: felt252,
    pub reward_amount: u256,
    pub token_address: ContractAddress,
    pub earned_at: u64,
    pub claimed_at: u64,
    pub transaction_hash: felt252,          // Transaction hash instead of URL
    pub reward_type: felt252,               // game_win, achievement, referral, etc.
}

// New model for player sessions
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerSession {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub session_id: felt252,
    pub started_at: u64,
    pub ended_at: u64,
    pub games_played: u32,
    pub total_score: u64,
    pub total_earnings: u256,
}

