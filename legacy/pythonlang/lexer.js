class Lexer {
    constructor(input) {
        this.input = input;
        this.tokens = [];
        this.current = 0;
    }

    tokenize() {
        while (this.current < this.input.length) {
            let char = this.input[this.current];

            if (/\s/.test(char)) {
                this.current++;
                continue;
            }

            if (char === '(' || char === ')' || char === '{' || char === '}' || char === ';') {
                this.tokens.push({ type: 'PUNCTUATION', value: char });
                this.current++;
                continue;
            }

            if (/[a-zA-Z]/.test(char)) {
                let value = '';
                while (/[a-zA-Z]/.test(char)) {
                    value += char;
                    char = this.input[++this.current];
                }
                this.tokens.push({ type: 'IDENTIFIER', value });
                continue;
            }

            throw new Error(`Unexpected character: ${char}`);
        }

        return this.tokens;
    }
}

// Example usage
const lexer = new Lexer("spam x = 42; eggs foo() { ni (x > 10) { shrubbery { x = x - 1; } } }");
console.log(lexer.tokenize());