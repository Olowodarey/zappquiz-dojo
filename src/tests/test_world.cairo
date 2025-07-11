#[cfg(test)]
mod tests {
    // === Imports ===
    use dojo::model::{ModelStorage, ModelStorageTest};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDef, ContractDefTrait, WorldStorageTestTrait
    };
    use starknet::{contract_address_const, testing, get_block_timestamp};

    // Models 
    use zapp_quiz::models::analytics_model::{DailyStats, CreatorStats, m_CreatorStats, PlatformStats, m_PlatformStats, QuestionResults};
    
    use zapp_quiz::models::quiz_model::{Quiz, m_Quiz, QuizCounter, m_QuizCounter, RewardSettings, PrizeDistribution};
    
    use zapp_quiz::models::question_model::{Question, m_Question, QuestionType};
    
    use zapp_quiz::models::system_model::{PlatformConfig, m_PlatformConfig};

    use zapp_quiz::models::game_model::{GameSession, m_GameSession, LivePlayerState, m_LivePlayerState, GameConfig, m_GameConfig};

    use zapp_quiz::models::player_model::{Player, m_Player};

    use zapp_quiz::interfaces::IZappQuiz::{IZappQuiz, IZappQuizDispatcher, IZappQuizDispatcherTrait};
   
    use zapp_quiz::models::question_model::QuestionTrait;

    use zapp_quiz::systems::ZappQuiz::ZappQuiz;

    // === Define Resources ===
    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "zapp_quiz",
            resources: [
                // Quiz related models
                TestResource::Model(m_Quiz::TEST_CLASS_HASH),
                TestResource::Model(m_QuizCounter::TEST_CLASS_HASH),
                TestResource::Model(m_Question::TEST_CLASS_HASH),
                
                // Analytics models
                TestResource::Model(m_CreatorStats::TEST_CLASS_HASH),
                TestResource::Model(m_PlatformStats::TEST_CLASS_HASH),
                
                // System models
                TestResource::Model(m_PlatformConfig::TEST_CLASS_HASH),
                
                // Game models (add these if used by your contract)
                TestResource::Model(m_GameSession::TEST_CLASS_HASH),
                TestResource::Model(m_LivePlayerState::TEST_CLASS_HASH),
                TestResource::Model(m_GameConfig::TEST_CLASS_HASH),
                TestResource::Model(m_Player::TEST_CLASS_HASH),
                
                // Events
                TestResource::Event(ZappQuiz::e_QuizCreated::TEST_CLASS_HASH),
                
                // Contract
                TestResource::Contract(ZappQuiz::TEST_CLASS_HASH),
            ]
            .span(),
        };
        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"zapp_quiz", @"ZappQuiz")
                .with_writer_of([dojo::utils::bytearray_hash(@"zapp_quiz")].span())
        ]
            .span()
    }

    // === Test create_quiz ===
    // #[test]
    // fn test_create_quiz() {
    //     // Initialize test environment
    //     let caller_1 = contract_address_const::<'Akos'>();
    //     let ndef = namespace_def();

    //     // Register the resources.
    //     let mut world = spawn_test_world([ndef].span());

    //     // Ensures permissions and initializations are synced.
    //     world.sync_perms_and_inits(contract_defs());

    //     let (contract_address, _) = world.dns(@"ZappQuiz").unwrap();
    //     let actions_system = IZappQuizDispatcher { contract_address };

    //     testing::set_contract_address(caller_1);

    //     // Declare test data
    //     let title: ByteArray = "Zero sum game";
    //     let description: ByteArray = "When you finally get it your name would be written in the stars"; 
    //     let category: ByteArray = "Maths";

    //     let mut options = ArrayTrait::new();
    //     options.append("true");
    //     options.append("false");

    //     let question = QuestionTrait::new(
    //         25, 
    //         "What is 2 + 2 = 4?",
    //         QuestionType::TrueFalse,
    //         options,
    //         0,
    //         30_u8,
    //         10_u8,  
    //         10_u16,
    //     );

    //     let dummy_questions: Array<Question> = array![question];
        
    //     let reward_settings = RewardSettings {
    //         has_rewards: true,
    //         token_address: contract_address_const::<'Akos'>(),
    //         reward_amount: 1000000000000000000,
    //         distribution_type: PrizeDistribution::Custom,
    //         number_of_winners: 2,
    //         prize_percentage: array![50, 30, 20],
    //         min_players: 2,
    //     };

    //     // Create quiz
    //     let quiz = actions_system.create_quiz(
    //         title.clone(),
    //         description.clone(),
    //         category.clone(),
    //         dummy_questions.clone(),
    //         public: true,
    //         default_duration: 3000,
    //         default_max_points: 1000,
    //         custom_timing: true,
    //         creator: caller_1,
    //         reward_settings: reward_settings.clone(),
    //     );

    //     // Basic assertions to verify quiz creation
    //     assert(quiz.title == title, 'Quiz title mismatch');
    //     assert(quiz.creator == caller_1, 'Quiz creator mismatch');
    //     assert(quiz.id == 1, 'Quiz ID should be 1');
    //     assert!(quiz.is_active == false, "Quiz should be inactive initially");
        
    //     println!("Quiz created successfully with ID: {}", quiz.id);
    // }

    // Simple test to check if the contract is properly initialized
    #[test]
    fn test_contract_initialization() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());
        
        let (contract_address, _) = world.dns(@"ZappQuiz").unwrap();
        let actions_system = IZappQuizDispatcher { contract_address };
        
        // Test creating a new quiz ID
        let caller = contract_address_const::<'TestUser'>();
        testing::set_contract_address(caller);
        
        let quiz_id = actions_system.create_new_quiz_id();
        assert(quiz_id == 1, 'First quiz ID should be 1');
        
        let quiz_id_2 = actions_system.create_new_quiz_id();
        assert(quiz_id_2 == 2, 'Second quiz ID should be 2');
        
        println!("Contract initialization test passed");
    }
}