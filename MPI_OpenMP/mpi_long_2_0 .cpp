#include <stdio.h>
#include <string.h>
#include <mpi.h>
#include <malloc.h>

#define max_size 11000000

#define min(A, B) (A < B ? A:B)

void from_ascii_to_int(char* array, int arr_size)
{
    for (int i = 0; i < arr_size; i++) 
    {
        if(array[i])
            array[i] -= '0';
    }
}

int sum_it(char* result, char* result1, char* num1, char* num2, int start_pos, int fin_pos) 
{
    printf("start %d end %d\n",start_pos, fin_pos);

    result1[start_pos] = 1;

    for (int i = start_pos; i >= fin_pos; i--) 
    {
        result[i - 1] = (num1[i] + num2[i] + result[i]) / 10;
        result[i] = (num1[i] + num2[i] + result[i]) % 10;

        result1[i - 1] = (num1[i] + num2[i] + result1[i]) / 10;
        result1[i] = (num1[i] + num2[i] + result1[i]) % 10;
    }

    if(result[fin_pos - 1] == 1 && result1[fin_pos - 1] == 1)
    {
        return 2;
    }
    else if (result1[fin_pos - 1] == 1)
    {
        return 1;
    }
    else 
        return 0; 
}

int main(int argc, char* argv[])
{
    FILE* file_with_numbers = NULL;
    file_with_numbers = fopen("numb1.txt","r");
    
    double startwtime = 0.0;
    double endwtime = 0.0;

    char* num1 = (char*)calloc(max_size, sizeof(char));
    char* num2 = (char*)calloc(max_size, sizeof(char));
    char* result = (char*)calloc(max_size, sizeof(char));
    char* result1 = (char*)calloc(max_size, sizeof(char));
    
    fscanf(file_with_numbers, "%s\n%s", num1, num2);

    fclose(file_with_numbers);

    int num1_length = strlen(num1);
    int num2_length = strlen(num2);
    bool my_overload1 = false;
    bool my_overload = false;
    bool prev_overload = false;

    if(num1_length > num2_length)
    {
        for(int i = 0; i < num1_length; i++)
        {
            num2[num1_length - 1 - i] = num2[num2_length - 1 - i];
            
            if(i > num2_length)
                num2[num1_length - 1 - i] = 0;
        }

        num2_length = num1_length;
    }
    else if(num1_length < num2_length)
    {
        for(int i = 0; i < num2_length; i++)
        {
            num1[num2_length - 1 - i] = num1[num1_length - 1 - i];

            if(i > num1_length)
                num1[num2_length - 1 - i] = 0;
        }

        num1_length = num2_length;
    }

    from_ascii_to_int(num1, num1_length);
    from_ascii_to_int(num2, num2_length);

    int rank;
    int proc_amount;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &proc_amount);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int fin_pos = num2_length / proc_amount * (proc_amount - rank - 1);             
    int start_pos = num2_length / proc_amount * (proc_amount - rank) - 1;            

    if(rank == proc_amount - 1)
        fin_pos = 0;                                                                 
    if(rank == 0)
        start_pos = num2_length - 1;
   
    if (rank == 0)
    {
        int current_length = 0;
        int current_start_pos = 0;
        startwtime = MPI_Wtime();

        my_overload = sum_it(result + 1, result1 + 1, num1, num2, start_pos, fin_pos);

        if(proc_amount > 1)
            MPI_Send(&my_overload, 1, MPI_CHAR, 1, rank, MPI_COMM_WORLD);

        for (int i = 1; i < proc_amount; i++)
        {
            MPI_Recv(&current_length, 1, MPI_INT, i, i, MPI_COMM_WORLD, NULL);
            MPI_Recv(&current_start_pos, 1, MPI_INT, i, i, MPI_COMM_WORLD, NULL);          
            MPI_Recv(&result[current_start_pos], current_length, MPI_CHAR, i, i, MPI_COMM_WORLD, NULL);
        }
    
        endwtime = MPI_Wtime();

        FILE* m_out = fopen("result.txt", "w");
    	
        for(int i = 0; i < num1_length + 1; i++)
            fprintf(m_out, "%d ",result[i]);
        
        fclose(m_out);
        delete(num1);
        delete(num2);
        delete(result);
        delete(result1);
        printf("%lg \n", endwtime - startwtime);
    }
    else
    {  
        int overload = sum_it(result + 1, result1 + 1, num1, num2, start_pos, fin_pos);

        if(overload == 2)
        {
            my_overload = true;
            my_overload1 = true;
        }
        else if (overload == 1)            
            my_overload1 = true;

        MPI_Recv(&prev_overload, 1, MPI_CHAR, rank - 1, MPI_ANY_TAG, MPI_COMM_WORLD, NULL);
        
        if(prev_overload && (rank < proc_amount - 1))
            MPI_Send(&my_overload1, 1, MPI_CHAR, rank + 1, rank, MPI_COMM_WORLD);
        else if(rank < proc_amount - 1)
            MPI_Send(&my_overload, 1, MPI_CHAR, rank + 1, rank, MPI_COMM_WORLD);

        int s_length = start_pos - fin_pos + 1;

        fin_pos++;
        start_pos++;

        if(rank == proc_amount - 1)
        {
            s_length++;
            fin_pos = 0;

            if(my_overload)
            {
                result1[fin_pos] = 1;
                result[fin_pos] = 1;
            }

            if(my_overload1)
            {
                result1[fin_pos] = 1;
            }
        }    
        
        MPI_Send(&s_length, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
        
        MPI_Send(&fin_pos, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
        
        if(prev_overload)
            MPI_Send(&result1[fin_pos], s_length, MPI_CHAR, 0, rank, MPI_COMM_WORLD);
        else
            MPI_Send(&result[fin_pos], s_length, MPI_CHAR, 0, rank, MPI_COMM_WORLD);
    }

    MPI_Finalize();
}
