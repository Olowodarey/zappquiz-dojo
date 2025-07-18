#[dojo::contract]
pub mod ZappQuiz {
    
    use zapp_quiz::models::quiz_model::{RewardSettings, PrizeDistribution, Quiz, QuizCounter, QuizDetails};
    use zapp_quiz::models::analytics_model::{CreatorStats, PlatformStats};
    use zapp_quiz::models::system_model::{PlatformConfig};
    use zapp_quiz::models::question_model::{QuestionCounter, Question};
    use zapp_quiz::models::game_model::{GameStatus, GameSession, GameSessionCounter, LivePlayerState, PlayerAnswer};
   
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

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct QuestionAddedToQuiz {
        #[key]
        pub quiz_id: u256,
        #[key]
        pub question_id: u256,
        pub text: ByteArray,
        pub creator: ContractAddress,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct QuestionRemovedFromQuiz {
        #[key]
        pub quiz_id: u256,
        #[key]
        pub question_index: u32,
        pub creator: ContractAddress,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct PlayerJoined {
        #[key]
        pub session_id: u256,
        pub player: ContractAddress,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct GameStarted {
        #[key]
        pub session_id: u256,
        pub question_start_time: u64,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct QuestionChanged {
        #[key]
        pub session_id: u256,
        pub question_num: u32,
        pub question_start_time: u64,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub struct AnswerSubmitted {
        #[key]
        pub session_id: u256,
        pub question_num: u32,
        pub answer: u8,
        pub points: u256,
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
            
        fn create_new_question_id(ref self: ContractState) -> u256{
            let mut world = self.world_default();
            let mut question_counter: QuestionCounter = world.read_model('v0');
            let new_val = question_counter.current_val + 1;
            question_counter.current_val = new_val;
            world.write_model(@question_counter);
            new_val
        }

        fn create_new_game_id(ref self: ContractState) -> u256{
            let mut world = self.world_default();
            let mut game_counter: GameSessionCounter = world.read_model('v0');
            let new_val = game_counter.current_val + 1;
            game_counter.current_val = new_val;
            world.write_model(@game_counter);
            new_val
        }

        fn create_quiz(
            ref self: ContractState,
            title: ByteArray,
            description: ByteArray,
            category: ByteArray,
            public: bool,
            default_duration: u256,
            default_max_points: u16,
            custom_timing: bool,
            creator: ContractAddress,
            // reward_settings: RewardSettings,
            questions: Array<Question>,
            amount: u256,
            has_rewards: bool,
            distribution_type: PrizeDistribution,
            number_of_winners: u8,
            prize_percentage: Array<u8>,
            min_players: u32,
            token_address: ContractAddress,
        ) -> u256 {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let timestamp = get_block_timestamp();

            // Ensure the creator is the caller
            assert!(creator == caller, "Only the creator can create a quiz");

            let quiz_details = QuizDetails {
                quiz_title: title.clone(),
                description: description,
                category: category,
                visibility: public,
            };

            let reward_settings = RewardSettings {
                has_rewards: has_rewards,
                token_address: token_address,
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

                match reward_settings.distribution_type {
                    PrizeDistribution::WinnerTakesAll => {
                        assert!(
                            reward_settings.number_of_winners == 1,
                            "Number of winners must be 1 for winner takes all"
                        );
                        assert!(
                            reward_settings.prize_percentage.len() == 0,
                            "Prize percentage should be empty for winner takes all"
                        );
                    },
                    PrizeDistribution::SplitTopThree => {
                        assert!(
                            reward_settings.number_of_winners == 3,
                            "Number of winners must be 3 for split top three"
                        );
                        assert!(
                            reward_settings.prize_percentage.len() == 3,
                            "Prize percentage must have exactly 3 values for split top three"
                        );
                
                        let mut expected = ArrayTrait::new();
                        expected.append(50_u8);
                        expected.append(30_u8);
                        expected.append(20_u8);

                        let mut i = 0;
                        while i < 3 {
                            assert!(
                                *reward_settings.prize_percentage.at(i) == expected[i].clone(),
                                "Split top three prize distribution must be [50, 30, 20]"
                            );
                            i += 1;
                        }
                    },
                    PrizeDistribution::Custom => {
                        let mut total: u8 = 0;
                        let mut i = 0;
                        while i < reward_settings.prize_percentage.len() {
                            total += *reward_settings.prize_percentage.at(i);
                            i += 1;
                        };
                        assert!(total == 100, "Custom prize percentages must sum to 100");
                    },
                }
            }

            let quiz_id = self.create_new_quiz_id();

            let mut quiz: Quiz = Quiz {
                id: quiz_id,
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
                is_active: false, 
            };

            // Store the quiz
            world.write_model(@quiz);

            // Update creator stats
            self._update_creator_stats(caller, 'quiz_created');

            // Emit event
            world.emit_event(@QuizCreated { title, creator, timestamp });

            quiz_id
        }

        fn get_quiz(self: @ContractState, quiz_id: u256) -> Quiz {
            let mut world = self.world_default();
            let quiz: Quiz = world.read_model(quiz_id);
            quiz
        }

        fn create_game_session(
            ref self: ContractState,
            quiz_id: u256,
            max_players: u32,
        ) -> u256 {
            let mut world = self.world_default();
            let host = get_caller_address();
            let timestamp = get_block_timestamp();

            let session_id = self.create_new_game_id();
            let mut game: GameSession = GameSession {
                id: session_id,
                quiz_id,
                host,
                status: GameStatus::Waiting,
                players: ArrayTrait::new(),
                total_players: 0,
                max_players,
                current_question: 0,
                reward_distributed: false,
                started_at: 0,
                ended_at: 0,
                question_start_time: 0,
                total_reward_pool: 0,
                platform_fees_collected: 0,
                created_at: timestamp,
            };
            world.write_model(@game);
            session_id
        }

        fn join_game_session(ref self: ContractState, session_id: u256, player: ContractAddress) {
            let mut world = self.world_default();
            let mut session: GameSession = world.read_model(session_id);

            // Validate Session
            assert!(session.status == GameStatus::Waiting, "Game has already started");
            assert!(session.total_players < session.max_players, "Game is full");

            // Add player
            session.players.append(player);
            world.write_model(@session);

            // Emit event
            world.emit_event(@PlayerJoined { session_id, player });

        }

        fn start_game_session(ref self: ContractState, session_id: u256) {
            let mut world = self.world_default();
            let mut session: GameSession = world.read_model(session_id);

            // Only host can start the game 
            assert!(session.host == get_caller_address(), "Only host can start the game");
            assert!(session.status == GameStatus::Waiting, "Game has already started");

            // Start the game
            session.status = GameStatus::Active;
            session.started_at = get_block_timestamp();
            session.current_question = 1;
            
            world.write_model(@session);
            
            // Emit event to notify all players
            world.emit_event(@GameStarted { session_id, question_start_time: session.question_start_time });
            
        }
     
        fn next_question(ref self: ContractState, session_id: u256) {   
             let mut world = self.world_default();
             let mut session: GameSession = world.read_model(session_id);

            //  assert!(session.host == get_caller_address(), "Only host can advance");

             let quiz: Quiz = world.read_model(session.quiz_id);

            if session.current_question >= quiz.questions.len() {
                session.status = GameStatus::Ended;
                // session.ended_at = get_block_timestamp();
            } else {
                session.current_question += 1;
                session.question_start_time = get_block_timestamp();
            }
             
            world.write_model(@session);
            
            // Emit event to notify all players
            world.emit_event(@QuestionChanged { session_id, question_num: session.current_question, question_start_time: session.question_start_time });
        }

        fn submit_answer(ref self: ContractState, session_id: u256, question_num:u32, answer: u8) {
            let mut world = self.world_default();
            let mut session: GameSession = world.read_model(session_id);
            let player = get_caller_address();
    
            // validate
            assert!(session.status == GameStatus::Active, "Game is not active");
            assert!(session.current_question == question_num, "Not the current question");
           
            // calculate points based on speed
            let  points = self.calculate_points(session_id, question_num, player);

            let player_answer = PlayerAnswer{
                session_id,
                player,
                question_num,
                answer,
                answered_at: get_block_timestamp(),
                points_earned: points,
            };

            world.write_model(@player_answer);
            world.emit_event(@AnswerSubmitted { session_id, question_num, answer, points });
        }
    }
   
        

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        // Helper function to get the default world storage
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zapp_quiz")
        }

        fn calculate_points(ref self: ContractState, session_id: u256, question_num: u32, player: ContractAddress) -> u256 {
            let mut world = self.world_default();
            let session: GameSession = world.read_model(session_id);
            let quiz: Quiz = world.read_model(session.quiz_id);
            let mut question: Question = quiz.questions[question_num].clone();
            let player_state: LivePlayerState = world.read_model(player);
            let time_taken = get_block_timestamp() - player_state.last_answer_time;
            let points = question.max_points / time_taken.into();
            points
        }

        fn _update_creator_stats(
            ref self: ContractState,    
            creator: ContractAddress,
            action_type: felt252 // 'quiz_created', 'game_hosted', etc.
        ) {
          
            let mut world = self.world_default();
            let mut creator_stats: CreatorStats = world.read_model(creator);

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

            if action_type == 'quiz_created' {
                creator_stats.total_quizzes_created += 1;
            } else if action_type == 'game_hosted' {
                creator_stats.total_games_hosted += 1;
            }

            let _updated_creator_stats = CreatorStats {
                last_activity: get_block_timestamp(),
                ..creator_stats
            };
            world.write_model(@creator_stats);
        }

        fn _initialize_platform_config(ref self: ContractState) {
            let mut world = self.world_default();
            let mut existing_config: PlatformConfig = world.read_model(1_u8);

            if existing_config.id == 0 {
                let default_config = PlatformConfig {
                    id: 1,
                    platform_fee_percentage: 5,
                    treasury_address: contract_address_const::<0>(), 
                    min_fee_threshold: 1000000000000000000,
                    max_fee_cap: 0,
                    fee_active: false,
                    updated_at: get_block_timestamp(),
                };

                world.write_model(@default_config);

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
