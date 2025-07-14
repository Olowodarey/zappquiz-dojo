#[dojo::contract]
pub mod ZappQuiz {
    
    use zapp_quiz::models::quiz_model::{RewardSettings, PrizeDistribution, Quiz, QuizCounter, QuizDetails};
    use zapp_quiz::models::analytics_model::{CreatorStats, PlatformStats};
    use zapp_quiz::models::system_model::{PlatformConfig};
    use zapp_quiz::models::question_model::{Question,};

    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};

    use zapp_quiz::interfaces::IZappQuiz::{IZappQuiz};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    // Game Events
    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct QuizCreated {
        #[key]
        pub title: ByteArray,
        pub creator: ContractAddress,
        pub timestamp: u64,
    }

    #[abi(embed_v0)]
    pub impl ZappQuizImpl of IZappQuiz<ContractState> {

        fn create_new_quiz_id(ref self: ContractState) -> u256{
            let mut world = self.world_default();
            let mut quiz_counter: QuizCounter = world.read_model('v0');
            let new_val = quiz_counter.current_val + 1;
            quiz_counter.current_val = new_val;
            world.write_model(@quiz_counter);
            new_val


        }

        fn add_question(ref self: ContractState, question: Question) {
        }

        fn delete_question(ref self: ContractState, question_id: u256) {
        }

        
       fn create_quiz(
            ref self: ContractState,
            title: ByteArray,
            description: ByteArray,
            category: ByteArray,
            questions: Array<Question>,
            public: bool,
            default_duration: u256,
            default_max_points: u16,
            custom_timing: bool,
            creator: ContractAddress,
            reward_settings: RewardSettings,
            amount:  u256,
            has_rewards: bool,
            distribution_type: PrizeDistribution,
            number_of_winners: u8,
            prize_percentage: Array<u8>,
            min_players: u32,

        ) -> Quiz {
            let mut world = self.world_default();

            let caller = get_caller_address();
            let timestamp = get_block_timestamp();

            // Ensure the creator is the caller
            assert!(creator == caller, "Only the creator can create a quiz");

            // Validate quiz data
            assert!(questions.len() > 0, "Quiz must have at least one question");
            assert!(questions.len() <= 50, "Quiz cannot have more than 50 questions");

            let quiz_details = QuizDetails{
                quiz_title: title,
                description: description,
                category: category,
                visibility: public,
            };

            let reward_settings = RewardSettings{
                has_rewards: true,
                token_address: contract_address_const::<'Akos'>(),
                reward_amount: amount,
                distribution_type: distribution_type,
                number_of_winners: number_of_winners,
                prize_percentage: prize_percentage,
                min_players: min_players,
            };

            // Validate reward settings
            if reward_settings.has_rewards {
                assert!(reward_settings.reward_amount > 0, "Reward amount must be greater than 0");
                assert!(reward_settings.min_players > 0, "Minimum players must be greater than 0");

                // Validate prize distribution percentages
                if reward_settings.distribution_type == PrizeDistribution::Custom {
                    let mut total_percentage: u8 = 0;
                    let mut i = 0;
                    while i < reward_settings.prize_percentage.len() {
                        total_percentage += *reward_settings.prize_percentage.at(i);
                        i += 1;
                    };
                    assert!(total_percentage == 100, "Prize percentages must sum to 100");
                }
            }
            
            let id = self.create_new_quiz_id();

            let mut quiz: Quiz = Quiz {
                    id,
                    quiz_details,
                    questions,
                    default_duration,
                    default_max_points,
                    custom_timing,
                    creator,
                    reward_settings,
                    created_at: timestamp,
                    game_sessions_created: 0,
                    total_rewards_distributed: 0,
                    platform_fees_generated: 0,
                    is_active: true,
                };

            // Store the quiz
            world.write_model(@quiz);

            // Update creator stats
            self._update_creator_stats(caller, 'quiz_created');

            // Emit event
            world.emit_event(@QuizCreated { title, creator, timestamp });

            quiz
        }

    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        // Helper function to get the default world storage
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zapp_quiz")
        }

        fn _update_creator_stats(
            ref self: ContractState,    
            creator: ContractAddress,
            action_type: felt252 // 'quiz_created', 'game_hosted', etc.
        ) {
            // Read existing creator stats or create new ones
            let mut world = self.world_default();
            let mut creator_stats: CreatorStats = world.read_model(creator);

            // Initialize if first time (check if creator address is zero)
            if creator_stats.creator == contract_address_const::<0>() {
                creator_stats = CreatorStats {
                    creator: creator,
                    total_quizzes_created: 0,
                    total_games_hosted: 0,
                    total_rewards_distributed: 0,
                    total_platform_fees_paid: 0,
                    average_game_size: 0,
                    last_activity: get_block_timestamp(),
                };
            }

            // Update based on action type
            if action_type == 'quiz_created' {
                creator_stats.total_quizzes_created += 1;
            } else if action_type == 'game_hosted' {
                creator_stats.total_games_hosted += 1;
            }

            let updated_creator_stats = CreatorStats {
                last_activity: get_block_timestamp(),
                ..creator_stats
            };
            world.write_model(@updated_creator_stats);
        }

        fn _initialize_platform_config(ref self: ContractState) {
            // Initialize default platform configuration if it doesn't exist
            let mut world = self.world_default();
            let mut existing_config: PlatformConfig = world.read_model(1_u8);

            if existing_config.id == 0 {
                let default_config = PlatformConfig {
                    id: 1,
                    platform_fee_percentage: 5,
                    treasury_address: contract_address_const::<0>(), // Must be set by admin
                    min_fee_threshold: 1000000000000000000, // 1 token minimum
                    max_fee_cap: 0, // No cap by default
                    fee_active: false, // Start with fees disabled
                    updated_at: get_block_timestamp(),
                };

                world.write_model(@default_config);

                // Initialize platform stats
                let platform_stats = PlatformStats {
                    id: 1,
                    total_games_created: 0,
                    total_fees_collected: 0,
                    total_rewards_distributed: 0,
                    active_games: 0,
                    total_players: 0,
                    last_updated: get_block_timestamp(),
                };

                world.write_model(@platform_stats);
            }
        }
    }
}


// fn update_quiz_reward_settings(
//     ref self: ContractState,
//     quiz_id: u256,
//     new_token_address: ContractAddress,
//     new_reward_amount: u256,
//     new_distribution_type: PrizeDistribution,
//     new_number_of_winners: u8,
//     new_prize_percentage: Array<u8>,
//     new_min_players: u32,
// ) {
//     let mut world = self.world_default();

//     // Read existing quiz
//     let mut quiz: Quiz = world.read_model(quiz_id);

//     // Validate new reward settings
//     if new_distribution_type == PrizeDistribution::Custom {
//         let mut total_percentage: u8 = 0;
//         let mut i = 0;
//         while i < new_prize_percentage.len() {
//             total_percentage += *new_prize_percentage.at(i);
//             i += 1;
//         };

//         assert!(total_percentage == 100, "Custom distribution must sum to 100%");
//     }

//     // Construct new RewardSettings
//     let new_reward_settings = RewardSettings {
//         has_rewards: true,
//         token_address: new_token_address,
//         reward_amount: new_reward_amount,
//         distribution_type: new_distribution_type,
//         number_of_winners: new_number_of_winners,
//         prize_percentage: new_prize_percentage,
//         min_players: new_min_players,
//     };

//     // Apply changes
//     quiz.reward_settings = new_reward_settings;

//     // Write updated quiz back to the world
//     world.write_model(@quiz);
// }