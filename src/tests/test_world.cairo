#[cfg(test)]
mod tests {
    // === Imports ===
    use dojo::model::{ModelStorage, ModelStorageTest};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDef, ContractDefTrait, WorldStorageTestTrait
    };
    use starknet::{contract_address_const, testing, get_block_timestamp};

    use zapp_quiz::interfaces::IZappQuiz::{IZappQuizDispatcher, IZappQuizDispatcherTrait};

    use zapp_quiz::models::quiz_model::{
        Quiz, m_Quiz, m_QuizCounter, RewardSettings, PrizeDistribution
    };

    use zapp_quiz::models::question_model::{Question, m_Question, QuestionType};

    use zapp_quiz::models::question_model::QuestionTrait;

    use zapp_quiz::systems::ZappQuiz::ZappQuiz;

    // === Define Resources ===
    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "zappquiz",
            resources: [
                TestResource::Model(m_Quiz::TEST_CLASS_HASH),
                TestResource::Model(m_QuizCounter::TEST_CLASS_HASH),
                TestResource::Event(ZappQuiz::e_QuizCreated::TEST_CLASS_HASH),
                TestResource::Contract(ZappQuiz::TEST_CLASS_HASH),
            ]
            .span(),
        };
        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"zappquiz", @"ZappQuiz")
                .with_writer_of([dojo::utils::bytearray_hash(@"zappquiz")].span())
        ]
            .span()
    }

    // === Test create_quiz ===
    #[test]
    fn test_create_quiz(){
        let caller_1 = contract_address_const::<'Akos'>();

        let ndef = namespace_def();

        // Register the resources.
        let mut world = spawn_test_world([ndef].span());

        // Ensures permissions and initializations are synced.
        world.sync_perms_and_inits(contract_defs());

        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"zappquiz").unwrap();
        let actions_system = IZappQuizDispatcher { contract_address };

        testing::set_contract_address(caller_1);

        //declare title 
        let title = "Zero sum game";

        let description = "When you finally get it your name would be written in the stars"; 

        let mut options = ArrayTrait::new();
        options.append("true");
        options.append("false");

        let category = "Maths";

        let question = QuestionTrait::new(
            25, 
            "What is 2 + 2 = 4?",
            QuestionType::TrueFalse,
            options,
            "false",
            30_u8,
            10_u8,  
            10_u16,
        );

        let dummy_questions: Array<Question> = array![question];
        
        let reward_settings = RewardSettings {
            has_rewards: true,
                token_address: contract_address_const::<'Akos'>(),
                reward_amount: 1000000000000000000,
                distribution_type: PrizeDistribution::Custom,
                number_of_winners: 2,
                prize_percentage: array![10, 20, 30, 40, 50],
                min_players: 2,
        };

        let Quiz = actions_system.create_quiz(
            title.clone(),
            description.clone(),
            category.clone(),
            dummy_questions.clone(),
            public: true,
            default_duration: 3000,
            default_max_points: 1000,
            custom_timing: true,
            creator: caller_1,
            reward_settings: reward_settings.clone(),
        );

        // let Quiz = world.read_model(quiz_id);
        // Quiz

        // assert!(Quiz.id == quiz_id, "Quiz ID does not match");
        assert!(Quiz.title == title, "Quiz title does not match");
        assert!(Quiz.description == description, "Quiz description does not match");
        assert!(Quiz.category == category, "Quiz category does not match");
        assert!(Quiz.questions == dummy_questions, "Quiz questions do not match");
        assert!(Quiz.public == true, "Quiz public does not match");
        assert!(Quiz.default_duration == 3000, "Quiz default duration does not match");
        assert!(Quiz.default_max_points == 1000, "Quiz default max points does not match");
        assert!(Quiz.custom_timing == true, "Quiz custom timing does not match");
        assert!(Quiz.creator == caller_1, "Quiz creator does not match");
        assert!(Quiz.reward_settings == reward_settings, "Quiz reward settings do not match");
        assert!(Quiz.created_at == get_block_timestamp(), "Quiz created at does not match");
        assert!(Quiz.game_sessions_created == 0, "Quiz game sessions created does not match");
        assert!(Quiz.total_rewards_distributed == 0, "Quiz total rewards distributed does not match");
        assert!(Quiz.platform_fees_generated == 0, "Quiz platform fees generated does not match");
        assert!(Quiz.is_active == false, "Quiz is active does not match");
   
    }
}
