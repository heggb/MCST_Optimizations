static __attribute__((always_inline)) int add(int a, int b) 
{
    return a + b;
}

int main() 
{
    int x = add(10, 20);
    return x;
}