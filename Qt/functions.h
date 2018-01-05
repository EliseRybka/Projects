#include<conio.h>
#include<stdio.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <cctype>


#define or ||
using namespace std;

enum lexeme_types
{
    NOTHING    = 0,
    NUMBER     = 123,
    OPERATOR   = 224,
    VARIABLE   = 357,
    BRACKET    = 490,
    FUNCTION   = 568,
    UNEXPECTED = 699,
};

enum functions
{
    SQRT   = 93,
    EXP    = 27,
    LN     = 10,
    SIN    = 30,
    COS    = 60,
    TG     = 45,
    CTG    = 55,
    ARCSIN = 31,
    ARCCOS = 61,
    ARCTG  = 46,
    ARCCTG = 56,
};

const double pi2 = 1.570796327;
const double pi = 3.141592654;

class function_code
{
public:
        int code;
        string name;
        function_code (int m_number, string m_name);//
};

const int NUMBER_OF_FUNCTIONS = 11;
const function_code FUNCTION_CODES [NUMBER_OF_FUNCTIONS] = {function_code(SQRT, "sqrt"), function_code(EXP, "exp"), 
                         function_code(LN, "ln"), function_code(SIN, "sin"), function_code(COS, "cos"), function_code(TG, "tg"), function_code(CTG, "ctg"),   
function_code(ARCSIN, "arcsin"), function_code(ARCCOS, "arccos"), function_code(ARCTG, "arctg"), function_code(ARCCTG, "arcctg")};

int seek_function_code (string m_name);//
string seek_function_name (int m_code);//
int seek_function_code (string m_name);//
string seek_function_name (int m_code);//

class lexeme
{
public:
        int type;
        double value;
        string name;
        lexeme () {};//
        lexeme (int m_type, double m_value, string m_name);//
        ~lexeme () {};//
};

class node
{
public:
        lexeme* lexema;
        node* left;
        node* right;
        node ();//
        node (lexeme* m_lexema, node* m_left, node* m_right);//
        node (int type, double value, string name, node* m_left, node* m_right);//
        ~node ();//
        void line_print ();//
        double calculate (double value);//
};

class formula
{
public:
        node* root;
        formula ();//
        formula (lexeme** definition);//
        ~formula ();//
        friend ostream & operator<< (ostream & os, const formula & m);//
        double operator() (double value);//
        double integral (double left, double right, int parts, int counters = 1);
};

double read_number (string formula, int *position);//
string read_function_name (string f, int *position);//
int isoperation (char symbol);//
formula* read_formula (string f);//

int current_lexeme = 0;

node* GetN (lexeme** lexemes);//
node* GetP (lexeme** lexemes);//
node* GetT (lexeme** lexemes);//
node* GetE (lexeme** lexemes);//
node* GetF (lexeme** lexemes);//
node* GetD (lexeme** lexemes);//



function_code::function_code (int m_code, string m_name)
{
        code = m_code;
        name = m_name;
}

int seek_function_code (string m_name)
{
        for (int i = 0; i < NUMBER_OF_FUNCTIONS; i ++)
        {
                if (FUNCTION_CODES[i].name == m_name)
                        return FUNCTION_CODES[i].code;
        }
        return 0;
}

string seek_function_name (int m_code)
{
        for (int i = 0; i < NUMBER_OF_FUNCTIONS; i ++)
        {
                if (FUNCTION_CODES[i].code == m_code)
                        return FUNCTION_CODES[i].name;
        }
        return 0;
}

lexeme::lexeme (int m_type, double m_value, string m_name)
{
        type = m_type;
        value = m_value;
        name = m_name;
}

node::node ()
{
        lexema = NULL;
        left = NULL;
        right = NULL;
}

node::node (lexeme* m_lexema, node* m_left, node* m_right)
{
        lexema = m_lexema;
        left = m_left;
        right = m_right;
}

node::node (int type, double value, string name, node* m_left, node* m_right)
{
        lexema = new lexeme (type, value, name);
        left = m_left;
        right = m_right;
}

node::~node ()
{
        if (left != NULL)
                left->~node ();
        if (right != NULL)
                right->~node ();
        delete lexema;
}

void node::line_print ()
{
        switch (lexema -> type)
        {
                case FUNCTION:
                {
                        if (lexema -> value == EXP)
                        {
                                cout <<"e^(";
                                right -> line_print ();
                        }
                        else
                        {
                                cout << lexema -> name << "(";
                                right -> line_print ();
                        }
                        cout << ")";
                        break;
                }
                case NUMBER:
                {
                        cout << lexema -> value;
                        break;
                }
                case VARIABLE:
                {
                        cout << 'x';
                        break;
                }
                case OPERATOR:
                {
                        switch ((int) lexema -> value)
                        {
                                case '+':
                                {
                                        left -> line_print ();
                                        cout << "+";
                                        right -> line_print ();
                                        break;
                                }
                                case '-':
                                {
                                        if (!(left -> lexema -> type == NUMBER &&
                                                        left -> lexema -> value == 0))

                                                left -> line_print ();

                                        cout << "-";

                                        if (right -> lexema -> type == OPERATOR &&
                                                (right -> lexema -> value == '+' ||
                                                right -> lexema -> value == '-'))

                                        {
                                                cout << "(";
                                                right -> line_print ();
                                                cout << ")";
                                        }
                                        else
                                                right -> line_print ();
                                        break;
                                }
                                case '*':
                                {
                                        if (left -> lexema -> type == OPERATOR &&
                                                (left -> lexema -> value == '+' ||
                                                left -> lexema -> value == '-'))

                                        {
                                                cout << "(";
                                                left -> line_print ();
                                                cout << ")";
                                        }
                                        else
                                                left -> line_print ();

                                        cout << "*";

                                        if (right -> lexema -> type == OPERATOR &&
                                                (right -> lexema -> value == '+' ||
                                                right -> lexema -> value == '-'))

                                        {
                                                cout << "(";
                                                right -> line_print ();
                                                cout << ")";
                                        }
                                        else
                                                right -> line_print ();
                                        break;
                                }
                                case '/':
                                {
                                        if (left -> lexema -> type == OPERATOR &&
                                                (left -> lexema -> value == '+' ||
                                                left -> lexema -> value == '-'))

                                        {
                                                cout << "(";
                                                left -> line_print ();
                                                cout << ")";
                                        }
                                        else
                                                left -> line_print ();

                                        cout << "/";
                                        
                                        if (right -> lexema -> type == OPERATOR &&
                                                (right -> lexema -> value == '+' ||
                                                right -> lexema -> value == '-' ||
                                                right -> lexema -> value == '*' ||
                                                right -> lexema -> value == '/'))

                                        {
                                                cout << "(";
                                                right -> line_print ();
                                                cout << ")";
                                        }
                                        else
                                                right -> line_print ();
                                        break;
                                }
                                case '^':
                                {
                                        if (left -> lexema -> type == NUMBER or left -> lexema -> type == VARIABLE)

                                                left -> line_print ();

                                        else
                                        {
                                                cout << "(";
                                                left -> line_print ();
                                                cout << ")";
                                        }
                                        cout << "^(";
                                        right -> line_print ();
                                        cout << ")";
                                        break;
                                }
                                default:
                                        break;
                        }
                break;
                }
        default:
                break;
    }
}

formula::formula ()
{
        root = NULL;
}

formula::formula (lexeme** definition)
{
        root = GetE (definition);
}

formula::~formula ()
{
        if (root == NULL)
                return;
        root -> ~node ();
}

ostream & operator<< (ostream & os, const formula & m)
{
        m.root -> line_print ();
        return os;
}

formula* read_formula (string f)
{
        f.push_back ('\n');
        int len = f.length ();
        lexeme** lexemes = new lexeme* [len];
        
        int counter  = 0;
        int position = 0;
        
        while (position < len)
        {
                lexemes [counter] = new lexeme ();
                if (isdigit (f [position]))
                {
                        lexemes [counter] -> type = NUMBER;
                        lexemes [counter] -> value = read_number (f, &position);
                }
                else
                if (isoperation (f [position]))
                {
                        if (f [position] == '-' && (counter == 0 ||
                                        (lexemes [counter - 1] -> type == BRACKET &&
                                        lexemes [counter - 1] -> name [0] == '(')))
                        {
                                lexemes [counter] -> type = NUMBER;
                                lexemes [counter] -> value = read_number (f, &position);
                        }
                        else
                        {
                                lexemes [counter] -> type = OPERATOR;
                                lexemes [counter] -> value = f [position];
                                lexemes [counter] -> name = string ();
                                (lexemes [counter] -> name).push_back (f [position]);
                                position ++;
                        }      
                }
                else
                if (f [position] == 'x')
                {
                        lexemes [counter] -> type = VARIABLE;
                        lexemes [counter] -> value = 0;
                        lexemes [counter] -> name = string ();
                        (lexemes [counter] -> name).push_back ('x');
                        position ++;
                }
                else
                if (f [position] == '(' or f [position] == ')')
                {
                        lexemes [counter] -> type = BRACKET;
                        lexemes [counter] -> value = f [position];
                        lexemes [counter] -> name = string ();
                        (lexemes [counter] -> name).push_back (f [position]);
                        position ++;
                }
                else
                if (isalpha (f [position]))
                {
                        lexemes [counter] -> type = FUNCTION;
                        lexemes [counter] -> name = read_function_name (f, &position);
                   lexemes [counter] -> value = seek_function_code (lexemes [counter] -> name);
                }
                else 
                if (f [position] == ' ')
                        position ++;
                else 
                if (f [position] == '\n')
                        break;
                counter ++;
        }
        formula* F = new formula (lexemes);
        
        return F;
}

double read_number (string formula, int *position)
{
        int signum = 1;
        bool afterpoint = 0;
        int num_AP = 0;
        int result_ignore_point = 0;

        if (formula [*position] == '-')
        {
                signum = -1;
                (*position) ++;
        }

        while (isdigit (formula [*position]) or
                formula [*position] == '.' or formula [*position] == ',')
        {
                if (formula [*position] == '.' or formula [*position] == ',')
                        afterpoint = 1;
                else
                {
                     result_ignore_point = result_ignore_point * 10 + formula [*position] - '0';
                        if (afterpoint)
                                num_AP ++;
                }
                (*position) ++;
        }

        double result = signum * result_ignore_point / pow (10.0, num_AP);
        return result;
}

string read_function_name (string f, int *position)
{
        string nm;
        while (isalpha (f [*position]))
        {
                nm.push_back (f [*position]);
                (*position) ++;
        }
        return nm;
}

int isoperation (char symbol)
{
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/' || symbol == '^')
                return 1;
        return 0;
}

double formula::operator() (double value)
{
        return root -> calculate (value);
}

double node::calculate (double value)
{
        switch (lexema -> type)
        {
                case NUMBER :
                {
                        return lexema -> value;
                }
                case VARIABLE :
                {
                        return value;
                }
                case FUNCTION :
                {
                        double x = right -> calculate (value);
                        switch ((int)(lexema -> value))
                        {
                                case SQRT :
                                {
                                        return sqrt (x);
                                }
                                case EXP :
                                {
                                        return exp (x);
                                }
                                case LN :
                                {
                                        return log (x);
                                }
                                case SIN :
                                {
                                        return sin (x);
                                }
                                case COS :
                                {
                                        return cos (x);
                                }
                                case TG :
                                {
                                        return tan (x);
                                }
                                case CTG :
                                {
                                        return 1 / tan (x);
                                }
                                case ARCSIN :
                                {
                                        if ((x > -1) && (x < 1))
                                                return atan (x / sqrt (1 - x * x));
                                        if (x == -1)
                                                return -pi2;
                                        if (x == 1)
                                                return pi2;
                                }
                                case ARCCOS :
                                {
                                        if ((x > -1) && (x < 1))
                                                return pi2 - atan (x / sqrt (1 - x * x));
                                        if (x == -1)
                                                return pi;
                                        if (x == 1)
                                                return 0;
                                }
                                case ARCTG :
                                {
                                        return atan (x);
                                }
                                case ARCCTG :
                                {
                                        return pi2 - atan (x);
                                }
                                
                        }
                }
                case OPERATOR :
                {
                        double x = left -> calculate (value);
                        double y = right -> calculate (value);
                        switch ((int)(lexema -> value))
                        {
                                case '+' :
                                {
                                        return x + y;
                                }
                                case '-' :
                                {
                                        return x - y;
                                }
                                case '*' :
                                {
                                        return x * y;
                                }
                                case '/' :
                                {
                                        return x / y;
                                }
                                case '^' :
                                {
                                        return pow (x, y);
                                }
                        }
                }
                default :
                        exit (1);
        }
}

double formula::integral (double left, double right, int parts, int counters)
{
        if (counters > 1)
        {
                double* partials = new double (counters);
                double onepart = (right - left) / counters;
                int* done = new int (counters);
                for (int i = 0; i < counters; i ++)
                        done [i] = 0;
                //omp_set_num_threads (counters);
                for (int i = 0; i < counters; i ++)
                {
                        partials [i] = integral (left + onepart * i,                    
                                              left + onepart * (i + 1), parts / counters + 1);
                        done [i] = 1;
                }
                int count = 0;
                double sum = 0;
                do {
                        for (int i = 0; i < counters; i ++)
                        {
                                if (done [i] == 1)
                                {
                                        sum += partials [i];
                                        done [i] = 0;
                                }
                        }
                } while (count > 0);
                return sum;
        }
        else
        {
                double delta = (right - left) / parts;
                double sum_l = 0, sum_r = 0;
                for (int i = 0; i < parts; i ++)
                {
                        sum_l += (*this)(left + delta * i) * delta;
                        sum_r += (*this)(left + delta * (i + 1)) * delta;
                }
                return (sum_l + sum_r) / 2;
        }
}




node* GetV (lexeme** lexemes)
{
        if (lexemes [current_lexeme] -> type == VARIABLE)
        {
                node* tree = new node (lexemes [current_lexeme], NULL, NULL);
                current_lexeme ++;
                return tree;
        }
        else
                exit (1);
}

node* GetN (lexeme** lexemes)
{
        if (lexemes [current_lexeme] -> type == NUMBER)
        {
                node* tree = new node (lexemes [current_lexeme], NULL, NULL);
                current_lexeme ++;
                return tree;
        }
        else
                exit (1);
}

node* GetP (lexeme** lexemes)
{
        if (lexemes [current_lexeme] -> type == BRACKET &&
                lexemes [current_lexeme] -> value == '(')
        {
                current_lexeme ++;
                node* tree = GetE (lexemes);
                current_lexeme ++;
                return tree;
        }
        else if (lexemes [current_lexeme] -> type == NUMBER)
        {
                node* tree = GetN (lexemes);
                return tree;
        }
        else if (lexemes [current_lexeme] -> type == VARIABLE)
        {
                node* tree = GetV (lexemes);
                return tree;
        }
        else if (lexemes [current_lexeme] -> type == FUNCTION)
        {
                node* tree = GetF (lexemes);
                return tree;
        }
        else
                exit (1);
}

node* GetF (lexeme** lexemes)
{
        node* tree = new node (lexemes [current_lexeme], NULL, NULL);
        current_lexeme ++;
        tree -> right = GetP (lexemes);

        return tree;
}

node* GetE (lexeme** lexemes)
{
        node* tree = GetT (lexemes);

        while (lexemes [current_lexeme] -> type == OPERATOR &&
                        (lexemes [current_lexeme] -> value == '+' ||
                        lexemes [current_lexeme] -> value == '-'))
        {
                tree = new node (lexemes [current_lexeme], tree, NULL);
                current_lexeme ++;
                tree -> right = GetT (lexemes);
        }
        return tree;
}

node* GetD (lexeme** lexemes)
{
        node* tree = GetP (lexemes);

        while (lexemes [current_lexeme] -> value == '^')
        {
                tree = new node (lexemes [current_lexeme], tree, NULL);
                current_lexeme ++;
                tree -> right = GetP (lexemes);
        }
        return tree;
}

node* GetT (lexeme** lexemes)
{
        node* tree = GetD (lexemes);

        while (lexemes [current_lexeme] -> type == OPERATOR &&
                (lexemes [current_lexeme] -> value == '*' ||
                lexemes [current_lexeme] -> value == '/'))
        {
                tree = new node (lexemes [current_lexeme], tree, NULL);
                current_lexeme ++;
                tree -> right = GetD (lexemes);
        }
        return tree;
}

