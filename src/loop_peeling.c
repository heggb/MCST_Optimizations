void process(int *arr, int n) 
{
    for (int i = 0; i < n; i++) 
    {
        if (i == 0) 
        {
            arr[i] *= 2; 
        } 
        else 
        {
            arr[i] += arr[i-1]; 
        }
    }
}