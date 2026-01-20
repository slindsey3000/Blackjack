# Blackjack Rails Application

A full-featured Blackjack game implemented as a Ruby on Rails web application. Play against the dealer with up to 6 players at the table, including AI-controlled computer players with varying skill levels.

## Features

### Core Game
- Standard Blackjack rules following [Bicycle Cards](https://bicyclecards.com/how-to-play/blackjack) guidelines
- 6-deck shoe with automatic reshuffling at 25% remaining
- Correct dealing order (clockwise, one card at a time)
- Ace handling (1 or 11, automatically optimized)
- Natural blackjack detection with proper payouts
- Dealer plays by house rules (hits on 16 or less, stands on 17+, hits soft 17)

### Additional Features (Beyond Core Requirements)
- **Up to 6 Players**: Add computer players to the table with one click
- **AI Skill Levels**: Choose from Low, Medium, or High skill computer opponents
  - Low: Makes random mistakes, hits until 14+
  - Medium: Follows basic strategy ~70% of the time
  - High: Near-optimal basic strategy play
- **Card Counting Dashboard**: Learn the Hi-Lo counting strategy
  - Running count display
  - True count calculation (running count / decks remaining)
  - Cards remaining indicator
  - Real-time strategy advice
  - Cards seen breakdown

## Tech Stack

- **Ruby** 3.3.6
- **Rails** 8.1.2
- **PostgreSQL** for database
- **Hotwire (Turbo + Stimulus)** for interactive UI
- **Tailwind CSS** for styling
- **RSpec** for testing
- **Docker** for containerized development

## Getting Started

### Option 1: Docker (Recommended for Quick Setup)

```bash
# Clone the repository
git clone https://github.com/slindsey3000/Blackjack.git
cd Blackjack

# Start with Docker Compose (builds, creates database, runs migrations automatically)
docker-compose up --build

# Visit http://localhost:3000
```

### Option 2: Local Development

**Prerequisites:**
- Ruby 3.3+ (check with `ruby -v`)
- PostgreSQL running locally (check with `pg_isready`)
- Node.js (for Tailwind CSS compilation)

```bash
# Clone the repository
git clone https://github.com/slindsey3000/Blackjack.git
cd Blackjack

# Install dependencies
bundle install

# Setup database (creates and migrates)
rails db:create db:migrate

# Start the server (runs Rails + Tailwind CSS watcher)
bin/dev

# Visit http://localhost:3000
```

**Note:** If you have a custom PostgreSQL setup, you can configure the connection using environment variables:
```bash
export DB_USERNAME=your_pg_user
export DB_PASSWORD=your_pg_password
export DB_HOST=localhost
```

### Running Tests

```bash
bundle exec rspec

# With coverage details
bundle exec rspec --format documentation
```

## How to Play

1. **Start a Game**: Enter your name and click "Start New Game"
2. **Add Players** (optional): Click "Add Computer Player" and select skill level
3. **Deal**: Click "Deal Cards" to start the round
4. **Play Your Hand**: 
   - Click **HIT** to take another card
   - Click **STAND** to keep your current hand
5. **Watch Results**: Computer players and dealer play automatically
6. **New Round**: Click "New Round" to play again

## Game Rules Implemented

- **Blackjack (Natural)**: Ace + 10-value card on first two cards
- **Bust**: Hand value exceeds 21
- **Push**: Tie between player and dealer
- **Dealer Rules**: Must hit on 16 or below, must stand on hard 17+, hits on soft 17

## Project Structure

```
app/
├── controllers/
│   ├── games_controller.rb     # Game flow and player actions
│   └── dashboard_controller.rb # Card counting dashboard
├── models/
│   ├── game.rb                 # Game state and associations
│   └── player.rb               # Player model with skill levels
├── services/
│   ├── blackjack_service.rb    # Core game logic
│   ├── computer_player_service.rb # AI decision making
│   ├── card_counting_service.rb   # Hi-Lo counting
│   └── basic_strategy_service.rb  # Strategy advice
├── lib/
│   ├── card.rb                 # Card PORO
│   ├── hand.rb                 # Hand value calculations
│   └── shoe.rb                 # Multi-deck shoe
└── views/
    ├── games/                  # Game UI views
    └── dashboard/              # Counting dashboard
```

## Deployment

### Heroku

```bash
# Create Heroku app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:essential-0

# Deploy
git push heroku main

# Run migrations (automatic via Procfile release phase)
```

## Architecture Decisions

1. **Service Objects**: Game logic is encapsulated in service classes for testability and separation of concerns
2. **PORO Domain Models**: Card, Hand, and Shoe are plain Ruby objects for clean, testable game mechanics
3. **Serialized State**: Game state (shoe, hands) is stored as JSON in PostgreSQL for simplicity
4. **Session-less Design**: All state is in the database, making the app stateless and Heroku-friendly

## Test Coverage

- 76 specs covering:
  - Card value calculations and counting values
  - Hand value calculations (including ace handling)
  - Game state management
  - Player actions (hit, stand)
  - Dealer play logic
  - Computer player AI decisions
  - Card counting calculations

## License

MIT
