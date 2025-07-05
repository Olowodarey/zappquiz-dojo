use starknet::ContractAddress;

// Notification system
#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct Notification {
    #[key]
    pub id: felt252,
    #[key]
    pub recipient: ContractAddress,
    pub message: ByteArray,
    pub notification_type: felt252,
    pub read: bool,
    pub created_at: u64,
    pub expires_at: u64,
    pub action_url: ByteArray,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlatformConfig {
    #[key]
    pub id: u8,
    pub platform_fee_percentage: u8, // 0-100
    pub treasury_address: ContractAddress,
    pub min_fee_threshold: u256, // Minimum fee to be charged
    pub max_fee_cap: u256, // Maximum fee cap, 0 means no cap
    pub fee_active: bool, // Whether fees are currently active
    pub updated_at: u64,
}

// Achievement system
#[derive(Clone, Drop, Serde, Debug)]
#[dojo::model]
pub struct Achievement {
    #[key]
    pub id: felt252,
    pub name: felt252,
    pub description: ByteArray,
    pub requirement: felt252,
    pub reward_points: u16,
    pub rarity: u8, // 1-5 scale
    pub icon: felt252,
    pub created_at: u64,
}
