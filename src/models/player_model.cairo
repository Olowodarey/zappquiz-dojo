use starknet::{ContractAddress, get_block_timestamp};

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
    Archived,                          
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

#[derive(Clone, Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,

    // User Profile
    pub nickname: ByteArray, 
    pub avatar_id: u8,
    pub created_at: u64,     
    pub last_active: u64, 

    // Game Statistics
    pub total_games_played: u32,
    pub total_wins: u32,
    pub total_podium_finishes: u32,
    pub best_win_streak: u32,
    pub current_win_streak: u32, 
    pub total_correct_answers: u32,
    pub total_losses: u32,
    pub total_questions_answered: u32,

    // Performance Metrics
    pub total_points_earned: u64,
    pub average_score_per_game: u32,
    pub fastest_correct_answer: u32,
    pub average_answer_time: u32,
    pub total_time_played: u64,
    pub total_score: u64,                   
    pub average_score: u32,                

    // Rewards & Economics    
    pub total_earnings: u256,
    pub current_balance: u256, 

    pub achievements_completed: u32,
    pub player_tier: PlayerTier,            
    pub tier_points: u32,                   
    pub favorite_category: felt252,         
    pub games_created: u32,                     
    pub is_active: bool,                    
   
    //Creator Stats
    pub quizzes_created: u32,
    pub total_quiz_plays: u32,
    pub creator_rating: u32,    

    // Achievement and Badges
    pub achievements_unlocked: Array<u16>,
    pub badges_earned: Array<u8>
}

#[derive(Copy, Drop, Serde, Debug, Introspect)]
pub enum CreatorTier {
    Unverified,
    Bronze,
    Silver, 
    Gold,
    Platinum,
    Diamond,
}

pub trait PlayerTrait {
    fn new(address: ContractAddress, nickname: ByteArray, avatar_id: u8) -> Player; 
    fn update_stats_after_game(ref self:Player, score:u32, position: u8, correct_answers: u32, total_questions: u32);
}

pub impl PlayerImpl of PlayerTrait {
    fn new(address: ContractAddress, nickname: ByteArray, avatar_id: u8) -> Player {
        Player{
            address,
            nickname,
            avatar_id,
            created_at: get_block_timestamp(),
            last_active: get_block_timestamp(),
            is_active: true,

            // initialize state 
            total_games_played: 0,
            total_wins: 0,
            total_podium_finishes: 0,
            total_questions_answered: 0,   
            best_win_streak: 0,
            current_win_streak: 0,
            total_correct_answers: 0,
            total_losses: 0,
            
            // performance
            total_points_earned: 0,
            average_score_per_game: 0,
            fastest_correct_answer: 0,
            average_answer_time: 0,
            total_time_played: 0,
            total_score: 0,
            average_score: 0,

            // Economics
            total_earnings: 0,
            current_balance: 0,
            achievements_completed: 0,
            player_tier: PlayerTier::Bronze,
            tier_points: 0,
            favorite_category: 0,
            games_created: 0,
            
            // Creator
            quizzes_created: 0,
            total_quiz_plays: 0,
            creator_rating: 0,

            // Achievement
            achievements_unlocked: ArrayTrait::new(),
            badges_earned: ArrayTrait::new()
        }
    }

    fn update_stats_after_game(ref self:Player, score:u32, position: u8, correct_answers: u32, total_questions: u32) {
        self.total_games_played += 1;
        self.total_correct_answers += correct_answers;
        self.total_questions_answered += total_questions;
        self.total_points_earned += score.into();

        if position == 1 {
            self.total_wins += 1;
            self.current_win_streak += 1;
            if self.current_win_streak > self.best_win_streak {
                self.best_win_streak = self.current_win_streak;
            }
        } else {
            self.current_win_streak = 0;
        }

        if position <= 3 {
            self.total_podium_finishes += 1;
        }

        self.average_score_per_game = (self.total_points_earned / self.total_games_played.into()).try_into().unwrap();

        self.last_active = get_block_timestamp();
    }
}