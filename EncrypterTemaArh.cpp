#include <iostream>
#include <iomanip>
#include <string>

#define hexout          cout << hex << uppercase << setw(2) << setfill('0')
#define cout_alligned   cout << setw(2)

using namespace std;

int main()
{
    

    int a = 233;
    int b = 96;
    string text;
    
    cout << "text: ";
    cin >> text;

    int n = text.length();

    int* x = new int[n];
    cout << "a: " << endl;
    cin >> a;
    cout << "b: " << endl;
    cin >> b;
    cout << "x0: " << endl;
    cin >> x[0];


    // Print plain-text
    cout << "plain-text: \n\t";
    for (int i = 0; i < n; i++) {
        cout_alligned << text[i] << " ";
    }
    cout << endl << '\t';
    
    // Print plain-text ( hex )
    for (int i = 0; i < n; i++) {
        hexout << (int)(text[i]) << " ";
    }
    cout << endl;

    // Print x ( hex )
    cout << "x: \n\t";
    hexout << x[0] << " ";
    for (int i = 1; i < n; i++) {
        x[i] = (a * x[i - 1] + b) % 255;
        hexout << x[i] << " ";
    }

    // Debug only
    hexout << (a * x[n - 1] + b) % 255 << " ";
    cout << endl;

    // Print encrypted text ( hex )
    cout << "encrypted: " << endl;
    cout << "\t";
    for (int i = 0; i < n; i++) {
        hexout << (int)(x[i] ^ (int)text[i]) << " ";
    }
    cout << endl;

    delete[] x;

    return 0;
}
