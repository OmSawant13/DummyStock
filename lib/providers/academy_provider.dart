import 'package:flutter/material.dart';
import '../models/academy_model.dart';
import '../services/storage_service.dart';

class AcademyProvider with ChangeNotifier {
  final StorageService _storageService;
  List<AcademyLesson> _lessons = [];
  List<GlossaryTerm> _glossary = [];
  String _glossarySearchQuery = '';
  String _selectedCategory = 'All';

  List<AcademyLesson> get lessons => _lessons;
  List<GlossaryTerm> get glossary => _glossary;
  String get glossarySearchQuery => _glossarySearchQuery;
  String get selectedCategory => _selectedCategory;

  AcademyProvider(this._storageService) {
    _initCurriculum();
    _loadCompletedLessons();
  }

  void _loadCompletedLessons() {
    final completedIds = _storageService.getCompletedLessons();
    for (var lesson in _lessons) {
      if (completedIds.contains(lesson.id)) {
        lesson.isCompleted = true;
      }
    }
  }

  void markLessonCompleted(String lessonId) {
    final lesson = _lessons.firstWhere((l) => l.id == lessonId);
    lesson.isCompleted = true;
    final completedIds = _lessons.where((l) => l.isCompleted).map((l) => l.id).toList();
    _storageService.saveCompletedLessons(completedIds);
    notifyListeners();
  }

  void setGlossarySearch(String query) {
    _glossarySearchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<GlossaryTerm> get filteredGlossary {
    return _glossary.where((item) {
      final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesQuery = _glossarySearchQuery.isEmpty ||
          item.term.toLowerCase().contains(_glossarySearchQuery.toLowerCase()) ||
          item.definition.toLowerCase().contains(_glossarySearchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  void _initCurriculum() {
    _lessons = [
      AcademyLesson(
        id: 'lesson-1',
        title: 'Mastering Market vs. Limit Orders',
        category: 'Stock Basics',
        summary:
            'Understand order book mechanics, slippage, bid-ask spreads, and when to execute instantaneously vs at a fixed price.',
        readTime: '4 min read',
        content: '''
### What is an Order in Financial Markets?
When you want to trade a stock, you submit an **order** to the exchange via your simulation broker.

#### 1. Market Orders
A **Market Order** is an instruction to buy or sell immediately at the best available current market price.
- **Advantage**: Guaranteed immediate execution.
- **Risk**: Price slippage in volatile markets or low liquidity stocks.

#### 2. Limit Orders
A **Limit Order** sets the maximum price you are willing to pay (Buy Limit) or the minimum price you are willing to receive (Sell Limit).
- **Advantage**: Exact price control; no unpleasant surprises.
- **Risk**: Your order may never execute if the market does not reach your target level.

#### 3. Stop-Loss & Take-Profit
- **Stop-Loss (SL)**: Triggers a market sell order once the stock drops to a specific defensive threshold to limit downside capital damage.
- **Take-Profit (TP)**: Locks in gains automatically when your upside price target is reached.
''',
        quiz: [
          QuizQuestion(
            question: 'Which order type guarantees execution speed over exact price?',
            options: ['Limit Order', 'Market Order', 'Stop-Loss Order', 'Trailing Stop'],
            correctOptionIndex: 1,
            explanation: 'Market orders execute immediately at the best current prevailing bid/ask price.',
          ),
          QuizQuestion(
            question: 'If you want to buy AAPL currently at \$228 only when it dips to \$220, what order should you use?',
            options: ['Market Buy', 'Buy Limit at \$220', 'Stop-Loss at \$220', 'Market Sell'],
            correctOptionIndex: 1,
            explanation: 'A Buy Limit order ensures you only buy when the price drops to or below \$220.',
          ),
        ],
      ),
      AcademyLesson(
        id: 'lesson-2',
        title: 'Candlestick Anatomy & Price Action',
        category: 'Technical Analysis',
        summary:
            'Learn how to read green & red candles, wicks, bodies, and spot bullish hammers and engulfing patterns.',
        readTime: '6 min read',
        content: '''
### Anatomy of a Candlestick
Every Japanese candlestick encapsulates 4 essential price milestones across a selected timeframe:
- **Open (O)**: The first trade price in the period.
- **High (H)**: The highest price achieved.
- **Low (L)**: The lowest price recorded.
- **Close (C)**: The final trade price when the candle closed.

#### Bullish vs. Bearish Candles
- **Bullish (Green)**: Close > Open (buyers were in control).
- **Bearish (Red)**: Close < Open (sellers pushed price down).

#### Wicks / Shadows
The upper and lower thin lines indicate price rejection. Long lower wicks often signal strong buying support at lower levels.
''',
        quiz: [
          QuizQuestion(
            question: 'What does a long lower wick on a candlestick typically signify?',
            options: [
              'Strong selling pressure at the close',
              'Strong buying support rejecting lower prices',
              'Market closed at the high of the day',
              'Zero trading volume',
            ],
            correctOptionIndex: 1,
            explanation: 'A long lower shadow shows that bears pushed price down, but aggressive bulls stepped in and bought it back up.',
          ),
        ],
      ),
      AcademyLesson(
        id: 'lesson-3',
        title: 'Risk Management: The 2% Rule & Portfolio Diversification',
        category: 'Risk & Money Management',
        summary:
            'Discover why capital preservation is the #1 rule of professional quant traders and how to prevent catastrophic drawdowns.',
        readTime: '5 min read',
        content: '''
### The Golden Rule of Capital Preservation
Amateur traders focus solely on how much money they can make. Professional institutional traders obsess over **how much money they can lose**.

#### The 2% Capital Risk Rule
Never risk more than 1% to 2% of your total account equity on any single trade. If your simulation wallet has \$100,000, your maximum stop-loss dollar risk should be \$1,000 – \$2,000.

#### Sector Diversification
Avoid placing 100% of your capital into one sector (e.g. only Tech). Spread risk across Healthcare, Energy, Financials, and Consumer Goods to cushion macroeconomic shocks.
''',
        quiz: [
          QuizQuestion(
            question: 'On a \$100,000 portfolio, what is the maximum dollar risk per trade under the 2% rule?',
            options: ['\$500', '\$2,000', '\$10,000', '\$20,000'],
            correctOptionIndex: 1,
            explanation: '2% of \$100,000 is \$2,000 maximum loss risk per trade.',
          ),
        ],
      ),
    ];

    _glossary = [
      GlossaryTerm(
        term: 'Bull Market',
        category: 'Market Trends',
        definition: 'A financial market condition where stock prices are consistently rising or expected to rise over an extended period.',
        example: 'During the 2023-2024 AI tech boom, the S&P 500 experienced a ferocious bull market.',
      ),
      GlossaryTerm(
        term: 'Bear Market',
        category: 'Market Trends',
        definition: 'A market condition characterized by prolonged price declines, conventionally defined as a drop of 20% or more from recent peaks.',
        example: 'In 2022, rising interest rates triggered a bear market across tech equities.',
      ),
      GlossaryTerm(
        term: 'P/E Ratio (Price-to-Earnings)',
        category: 'Valuation',
        definition: 'The ratio for valuing a company that measures its current share price relative to its per-share earnings (EPS).',
        example: 'A company trading at \$100 with \$5 EPS has a P/E ratio of 20x.',
      ),
      GlossaryTerm(
        term: 'Beta',
        category: 'Risk Metrics',
        definition: 'A measure of a stock\'s volatility and systematic risk in comparison to the overall market (benchmark Beta = 1.0).',
        example: 'Tesla has a Beta of 2.3, meaning it moves 2.3x more aggressively than the S&P 500.',
      ),
      GlossaryTerm(
        term: 'Sharpe Ratio',
        category: 'Risk Metrics',
        definition: 'The average return earned in excess of the risk-free rate per unit of volatility or total risk.',
        example: 'A Sharpe ratio above 1.5 indicates excellent risk-adjusted performance.',
      ),
      GlossaryTerm(
        term: 'Slippage',
        category: 'Execution',
        definition: 'The difference between the expected price of a trade and the actual price at which the order executes in fast markets.',
        example: 'Placing a market buy during high volatility caused \$0.40 slippage per share.',
      ),
    ];
  }
}
