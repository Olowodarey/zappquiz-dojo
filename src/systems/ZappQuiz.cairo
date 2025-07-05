#[dojo::contract]
pub mod GameActions {
    
    use zappquiz::models::quiz_model::{RewardSettings, PrizeDistribution, Question, Quiz};
    use zappquiz::models::analytics_model::{CreatorStats, PlatformStats};
    use zappquiz::models::system_model::{PlatformConfig};

    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, contract_address_const};

    use zappquiz::interfaces::IZappQuiz::{IZappQuiz, };

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;


    // Game Events
    #[derive(Copy, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct QuizCreated {
        #[key]
        pub title: felt252,
        pub creator: ContractAddress,
        pub timestamp: u64,
    }

    #[abi(embed_v0)]
    impl ZappQuizImpl of IZappQuiz<ContractState> {
        fn create_quiz(
            ref self: ContractState,
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
        ) {
            let mut world = self.world_default();

            let caller = get_caller_address();
            let timestamp = get_block_timestamp();

            // Ensure the creator is the caller
            assert!(creator == caller, "Only the creator can create a quiz");

            // Validate quiz data
            assert!(questions.len() > 0, "Quiz must have at least one question");
            assert!(questions.len() <= 50, "Quiz cannot have more than 50 questions");

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
            
            let mut quiz: Quiz = world.read_model(1);
            quiz =
                Quiz {
                    title,
                    description,
                    category,
                    questions,
                    public,
                    default_duration,
                    default_max_points,
                    custom_timing,
                    creator: caller,
                    reward_settings,
                    created_at: timestamp,
                    game_sessions_created: 0,
                    total_rewards_distributed: 0,
                    platform_fees_generated: 0,
                    is_active: false,
                };

            // Store the quiz
            world.write_model(@quiz);

            // Update creator stats
            self._update_creator_stats(caller, 'quiz_created');

            // Emit event
            world.emit_event(@QuizCreated { title, creator, timestamp });
        }
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        // Helper function to get the default world storage
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"dojo_starter")
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
                creator_stats.creator = creator;
                creator_stats.total_quizzes_created = 0;
                creator_stats.total_games_hosted = 0;
                creator_stats.total_rewards_distributed = 0;
                creator_stats.total_platform_fees_paid = 0;
                creator_stats.average_game_size = 0;
                creator_stats.last_activity = get_block_timestamp();
            }

            // Update based on action type
            if action_type == 'quiz_created' {
                creator_stats.total_quizzes_created += 1;
            } else if action_type == 'game_hosted' {
                creator_stats.total_games_hosted += 1;
            }

            creator_stats.last_activity = get_block_timestamp();
            world.write_model(@creator_stats);
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
