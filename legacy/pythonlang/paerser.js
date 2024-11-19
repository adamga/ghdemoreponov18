class Parser {
    constructor(tokens) {
        this.tokens = tokens;
        this.current = 0;
    }

    parse() {
        const ast = {
            type: 'Program',
            body: []
        };

        while (this.current < this.tokens.length) {
            ast.body.push(this.parseStatement());
        }

        return ast;
    }

    parseStatement() {
        const token = this.tokens[this.current];

        if (token.type === 'IDENTIFIER') {
            if (token.value === 'spam') {
                return this.parseVariableDeclaration();
            } else if (token.value === 'eggs') {
                return this.parseFunctionDeclaration();
            } else if (token.value === 'ni') {
                return this.parseConditional();
            } else if (token.value === 'shrubbery') {
                return this.parseLoop();
            }
        }

        throw new Error(`Unexpected token: ${token.value}`);
    }

    parseVariableDeclaration() {
        this.current++; // skip 'spam'
        const name = this.tokens[this.current++].value;
        this.current++; // skip '='
        const value = this.tokens[this.current++].value;
        this.current++; // skip ';'
        return {
            type: 'VariableDeclaration',
            name,
            value
        };
    }

    parseFunctionDeclaration() {
        this.current++; // skip 'eggs'
        const name = this.tokens[this.current++].value;
        this.current++; // skip '('
        this.current++; // skip ')'
        this.current++; // skip '{'
        const body = [];
        while (this.tokens[this.current].value !== '}') {
            body.push(this.parseStatement());
        }
        this.current++; // skip '}'
        return {
            type: 'FunctionDeclaration',
            name,
            body
        };
    }

    parseConditional() {
        this.current++; // skip 'ni'
        this.current++; // skip '('
        const condition = this.tokens[this.current++].value;
        this.current++; // skip ')'
        this.current++; // skip '{'
        const body = [];
        while (this.tokens[this.current].value !== '}') {
            body.push(this.parseStatement());
        }
        this.current++; // skip '}'
        return {
            type: 'Conditional',
            condition,
            body
        };
    }

    parseLoop() {
        this.current++; // skip 'shrubbery'
        this.current++; // skip '{'
        const body = [];
        while (this.tokens[this.current].value !== '}') {
            body.push(this.parseStatement());
        }
        this.current++; // skip '}'
        return {
            type: 'Loop',
            body
        };
    }
}

// Example usage
const tokens = lexer.tokenize();
const parser = new Parser(tokens);
console.log(JSON.stringify(parser.parse(), null, 2));