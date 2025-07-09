pub mod interfaces{
    pub mod IZappQuiz;
}

pub mod systems {
    pub mod ZappQuiz;
}

pub mod models {
    pub mod game_model;
    pub mod player_model;
    pub mod quiz_model;
    pub mod system_model;
    pub mod analytics_model;
    pub mod question_model;
}

pub mod tests {
    mod test_world;
}