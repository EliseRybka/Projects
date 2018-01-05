#include "functions.h"

int main ()
{
		string g;
		cin >> g;
        formula f = *(read_formula (g));
        double a, b;
        int n;
        cin >> a >> b >> n ;
        cout << f.integral (a, b, n, 1) << endl;
        getch();
        return 0;
}