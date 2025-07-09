// use starknet::{contract_address};
// use zappquiz::models::game::{RewardSettings};

// fn _distribute_winner_takes_all(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     game_id: felt252,
//     reward_settings: RewardSettings,
// ) {
//     // Get the winner (player with rank 1)
//     let winner_address = self._get_winner(world, game_id);

//     if winner_address != ContractAddress::zero() {
//         let mut player_result: PlayerResult = world.read_model((game_id, winner_address));
//         player_result.gross_reward_amount = reward_settings.reward_amount;
//         world.write_model(@player_result);
//     }
// }

// fn _distribute_split_top_three(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     game_id: felt252,
//     reward_settings: RewardSettings,
// ) {
//     // Split rewards: 50% to 1st, 30% to 2nd, 20% to 3rd
//     let first_place_reward = (reward_settings.reward_amount * 50) / 100;
//     let second_place_reward = (reward_settings.reward_amount * 30) / 100;
//     let third_place_reward = (reward_settings.reward_amount * 20) / 100;

//     // Get top 3 players and assign rewards
//     let top_players = self._get_top_players(world, game_id, 3);

//     if top_players.len() >= 1 {
//         let mut player_result: PlayerResult = world.read_model((game_id, *top_players.at(0)));
//         player_result.gross_reward_amount = first_place_reward;
//         world.write_model(@player_result);
//     }

//     if top_players.len() >= 2 {
//         let mut player_result: PlayerResult = world.read_model((game_id, *top_players.at(1)));
//         player_result.gross_reward_amount = second_place_reward;
//         world.write_model(@player_result);
//     }

//     if top_players.len() >= 3 {
//         let mut player_result: PlayerResult = world.read_model((game_id, *top_players.at(2)));
//         player_result.gross_reward_amount = third_place_reward;
//         world.write_model(@player_result);
//     }
// }

// fn _distribute_custom(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     game_id: felt252,
//     reward_settings: RewardSettings,
// ) {
//     // Distribute according to custom percentages
//     let num_winners = reward_settings.number_of_winners;
//     let top_players = self._get_top_players(world, game_id, num_winners.into());

//     let mut i = 0;
//     while i < top_players.len() && i < reward_settings.prize_percentage.len() {
//         let player_address = *top_players.at(i);
//         let percentage = *reward_settings.prize_percentage.at(i);
//         let reward_amount = (reward_settings.reward_amount * percentage.into()) / 100;

//         let mut player_result: PlayerResult = world.read_model((game_id, player_address));
//         player_result.gross_reward_amount = reward_amount;
//         world.write_model(@player_result);

//         i += 1;
//     }
// }

// fn _calculate_platform_fee(
//     ref self: ContractState,
//     gross_reward: u256,
//     platform_config: PlatformConfig,
// ) -> (u256, u256) {
//     // Return (platform_fee, net_reward)

//     if !platform_config.fee_active || gross_reward < platform_config.min_fee_threshold {
//         return (0, gross_reward);
//     }

//     let mut platform_fee = (gross_reward * platform_config.platform_fee_percentage.into()) / 100;

//     // Apply fee cap if set
//     if platform_config.max_fee_cap > 0 && platform_fee > platform_config.max_fee_cap {
//         platform_fee = platform_config.max_fee_cap;
//     }

//     let net_reward = gross_reward - platform_fee;

//     (platform_fee, net_reward)
// }

// fn _get_top_players(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     game_id: felt252,
//     count: u32,
// ) -> Array<ContractAddress> {
//     // This is a placeholder implementation
//     // In a real implementation, you'd need to:
//     // 1. Query all PlayerResult entities for this game_id
//     // 2. Sort them by total_score in descending order
//     // 3. Return the top 'count' players
//     // 4. This might require off-chain indexing or a more complex on-chain sorting mechanism

//     let mut top_players = ArrayTrait::new();

//     // Placeholder: return empty array
//     // You would implement proper player ranking logic here
//     // This could involve:
//     // - Iterating through all players in the game
//     // - Sorting by score (requires custom sorting implementation)
//     // - Or using an off-chain indexer to maintain rankings

//     top_players
// }

// pub fn _initialize_platform_config(
//     ref self: ContractState,
//     world: IWorldDispatcher,
// ) {
//     // Initialize default platform configuration if it doesn't exist
//     let existing_config: PlatformConfig = world.read_model(1_u8);

//     if existing_config.id == 0 {
//         let default_config = PlatformConfig {
//             id: 1,
//             platform_fee_percentage: 5,  // 5% default fee
//             treasury_address: ContractAddress::zero(), // Must be set by admin
//             min_fee_threshold: 1000000000000000000,  // 1 token minimum
//             max_fee_cap: 0,  // No cap by default
//             fee_active: false,  // Start with fees disabled
//             updated_at: get_block_timestamp(),
//         };

//         world.write_model(@default_config);

//         // Initialize platform stats
//         let platform_stats = PlatformStats {
//             id: 1,
//             total_games_created: 0,
//             total_fees_collected: 0,
//             total_rewards_distributed: 0,
//             active_games: 0,
//             total_players: 0,
//             last_updated: get_block_timestamp(),
//         };

//         world.write_model(@platform_stats);
//     }
// }

// fn _update_creator_stats(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     creator: ContractAddress,
//     action_type: felt252,  // 'quiz_created', 'game_hosted', etc.
// ) {
//     let mut creator_stats: CreatorStats = world.read_model(creator);

//     // Initialize if first time
//     if creator_stats.creator.is_zero() {
//         creator_stats.creator = creator;
//         creator_stats.total_quizzes_created = 0;
//         creator_stats.total_games_hosted = 0;
//         creator_stats.total_rewards_distributed = 0;
//         creator_stats.total_platform_fees_paid = 0;
//         creator_stats.average_game_size = 0;
//         creator_stats.last_activity = get_block_timestamp();
//     }

//     // Update based on action type
//     if action_type == 'quiz_created' {
//         creator_stats.total_quizzes_created += 1;
//     } else if action_type == 'game_hosted' {
//         creator_stats.total_games_hosted += 1;
//     }

//     creator_stats.last_activity = get_block_timestamp();
//     world.write_model(@creator_stats);
// }

// fn _update_platform_stats(
//     ref self: ContractState,
//     world: IWorldDispatcher,
//     action_type: felt252,
//     value: u256,
// ) {
//     let mut platform_stats: PlatformStats = world.read_model(1_u8);

//     if action_type == 'game_created' {
//         platform_stats.total_games_created += 1;
//         platform_stats.active_games += 1;
//     } else if action_type == 'game_completed' {
//         platform_stats.active_games -= 1;
//     } else if action_type == 'player_joined' {
//         platform_stats.total_players += 1;
//     }

//     platform_stats.last_updated = get_block_timestamp();
//     world.write_model(@platform_stats);
// }
