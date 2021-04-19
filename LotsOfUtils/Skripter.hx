
using StringTools;

// Seems to work

class Skripter {

}

class LexerUtils {
    public static function stringStartsWith(string: String, with: String, fromPos: Int = 0) {
        for (i in 0...with.length)
            if (string.charAt(i + fromPos) != with.charAt(i)) return false;
        return true;
    }
    public static function isAnySubstringAt(subs: Array<String>, str, start) {
        for (i in 0...subs.length) {
            var sub = subs[i];
            var result = stringStartsWith(str, sub, start);
            if (result == true) return i;
        }
        return -1;
    }
    public static function isSpace(char) return char == ' ' || char == '\t' || char == '\n';
    public static function isOperator(text, position, operators: Array<String>) {
        var result = isAnySubstringAt(operators, text, position);
        if (result != -1)
            return operators[result];
        return null;
    }
    public static function startsString(text: String, position: Int): String {
        if (text.charAt(position) == '"' || text.charAt(position) == "'") return text.charAt(position);
        return null;
    }
    public static function endsString(text, position, closeSeparator: String): Bool {
        if (text.charAt(position) == closeSeparator) return true;
        return false;
    }
}

enum LexerState { ReadingBlank; ReadingWord; ReadingString; }

class Lexer {

    var code: String;
    var operators: Array<String>;
    
    var start = 0;
    var currentCharIndex = 0;
    var state = ReadingBlank;

    var tokens : Array<String>;

    var _theOperator = '';
    var _stringStartChar = '';
    

    public function new(code, operators) {
        this.code = code;
        this.operators = operators;
    }

    function pushWord(start, end) tokens.push(code.substring(start, end));
    function isAtAnOperator() : Bool {
        _theOperator = LexerUtils.isOperator(code, currentCharIndex, this.operators);
        return _theOperator != null;
    }
    function isAtStringStart() : Bool {
        _stringStartChar = LexerUtils.startsString(code, currentCharIndex);
        return _stringStartChar != null;
    }
    function isAtStringEnd() return LexerUtils.endsString(code, currentCharIndex, _stringStartChar);
    function isAtSpace() return LexerUtils.isSpace(code.charAt(currentCharIndex));
    function getCurrentChar() return code.charAt(currentCharIndex);

    function splitCode() {
        tokens = [];
        while (currentCharIndex < code.length) {
            switch (state) {
                case ReadingBlank:  stepBlank();
                case ReadingWord:   stepWord();
                case ReadingString: stepString();
                default: throw 'No state $state exists';
            }
            currentCharIndex += 1;
        }
        if (state == ReadingWord)   pushWord(start, code.length);
        if (state == ReadingString) pushWord(start, code.length);
        return tokens;
    }

    function stepBlank() {
        if (isAtSpace()) {
            // Pass
        } else if (isAtAnOperator()) {
            var endPos = currentCharIndex + _theOperator.length;
            pushWord(currentCharIndex, endPos);
            currentCharIndex = endPos - 1;
        } else if (isAtStringStart()) {
            start = currentCharIndex;
            state = ReadingString;
        } else {
            start = currentCharIndex;
            state = ReadingWord;
        }
    }
    function stepWord() {
        if (isAtSpace()) {
            pushWord(start, currentCharIndex);
            state = ReadingBlank;
        } else if (isAtAnOperator()) {
            pushWord(start, currentCharIndex);
            var endPos = currentCharIndex + _theOperator.length;
            pushWord(currentCharIndex, endPos);
            state = ReadingBlank;
            currentCharIndex = endPos - 1;
        } else if (isAtStringStart()) {
            start = currentCharIndex;
            state = ReadingString;
        } else {
            // Pass
        }
    }
    var skipNextStringChar = false;
    function stepString() {
        if (skipNextStringChar) {
            skipNextStringChar = false;
        } else if (getCurrentChar() == '\\') {
            skipNextStringChar == true;
        } else if (isAtStringEnd()) {
            pushWord(start, currentCharIndex + 1);
        }
    }
}

class Expression {
    public var token: String = null;
    public var tokens: Array<String> = null;
    public var parentExpression: Expression = null;
}
class Expressizer {


    public static function parseTokens(tokens : Array<String>) {
        var expressions: Array<Expression> = [];
        var currentExpression

        for (string in tokens) {

        }
    }

}