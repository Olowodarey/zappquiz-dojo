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
    use zapp_quiz::models::analytics_model::{DailyStats, CreatorStats, m_CreatorStats, PlatformStats, m_PlatformStats};
    
    use zapp_quiz::models::quiz_model::{Quiz, m_Quiz, QuizCounter, m_QuizCounter, PrizeDistribution};
    
    use zapp_quiz::models::question_model::{Question, m_Question, QuestionType, QuestionCounter, m_QuestionCounter, QuestionTrait};
    
    use zapp_quiz::models::system_model::{PlatformConfig, m_PlatformConfig};

    use zapp_quiz::models::game_model::{GameSession, m_GameSession, LivePlayerState, m_LivePlayerState, GameConfig, m_GameConfig};

    use zapp_quiz::models::player_model::{Player, m_Player};

    use zapp_quiz::interfaces::IZappQuiz::{IZappQuizDispatcher, IZappQuizDispatcherTrait};
   

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
                TestResource::Model(m_QuestionCounter::TEST_CLASS_HASH),
                
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
    
    #[test]
    fn test_create_quiz() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());
        
        let (contract_address, _) = world.dns(@"ZappQuiz").unwrap();
        let actions_system = IZappQuizDispatcher { contract_address };
        
        // Test creating a new quiz ID
        let caller = contract_address_const::<'TestUser'>();
        testing::set_contract_address(caller);

        // let question_id = actions_system.create_new_question_id();

        // let quiz_id = actions_system.create_new_quiz_id();

        let mut options = ArrayTrait::new();
        options.append("Paris");
        options.append("London");
        options.append("Berlin");
        options.append("Madrid");

        let mut questions: Array<Question> = ArrayTrait::new();

        let question_1 = Question {
            id: 0,
            text: "What is the capital of France?",
            question_type: QuestionType::Multichoice,
            options: options,
            correct_option: 0,
            duration_seconds: 10000,
            point: 10,
            max_points: 10,
        };


        let mut option2: Array<ByteArray> = ArrayTrait::new();
        option2.append("True");
        option2.append("False");

        let question_2 = QuestionTrait::new(
            id: 1,
            text: "Is 2+2=5?",
            question_type: QuestionType::TrueFalse,
            options: option2,
            correct_option: 1,
            duration_seconds: 10000,
            point: 10,
            max_points: 10,
        );

        questions.append(question_1);
        // questions.append(question_2);

        let mut prize_percentage = ArrayTrait::new();

        actions_system.create_quiz(
            title: "Test Quiz",
            description: "This is a test quiz",
            category: "Test Category",
            public: true,
            default_duration: 10000,
            default_max_points: 10,
            custom_timing: false,
            creator: caller,
            questions: questions,
            amount: 10000,
            has_rewards: true,
            distribution_type: PrizeDistribution::WinnerTakesAll,
            number_of_winners: 1,
            prize_percentage: prize_percentage,
            min_players: 1,
            token_address: contract_address_const::<0x123456789>(),
        );

        // let quiz = actions_system.get_quiz(quiz_id);
        // assert!(quiz.id == quiz_id, "Quiz ID should match");
    }
}