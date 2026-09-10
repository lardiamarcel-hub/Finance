/// Clé de l'assistant IA (Google Gemini, offre gratuite), injectée au moment
/// de la compilation via --dart-define (voir .github/workflows/build-apk.yml)
/// pour ne jamais figurer en clair dans le code source ni l'historique Git.
/// En développement local sans --dart-define, cette valeur est vide et
/// l'assistant IA se désactive proprement (voir AppRepository.isAiAvailable).
const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

const String defaultAiModel = 'gemini-flash-latest';
