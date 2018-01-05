#include <iostream>
#include <semaphore.h>
#include <stack> 
#include <math.h>
#include <omp.h>

#define max_local_stack_size 5
#define num_of_threads 1

struct segment
{
   double left_point;
   double right_point;
   double fL;
   double fR;
   double area_between;
};

struct global_stack_service
{
   int global_ntask;
   int proc_nactive;
   int max_tasks;
   double integral_result;
   sem_t sem_task_present;
   sem_t stack_access;
   sem_t sem_sum;
};

const double accuracy = 0.00001;
std::stack<struct segment> GLOBAL_STACK;
global_stack_service service = {};

double func(double point);
void integrate_local_stack(std::stack<struct segment>* stack_to_use);

int main()
{ 
   service.max_tasks = num_of_threads;
   sem_init(&(service.sem_task_present), 0, 1);
   sem_init(&(service.stack_access), 0, 1);
   sem_init(&(service.sem_sum), 0, 1);
   service.integral_result = 0;

   segment segment_to_push;
   segment_to_push.left_point = 0.0001;
   segment_to_push.right_point = 1;
   segment_to_push.fL = func(segment_to_push.left_point);
   segment_to_push.fR = func(segment_to_push.right_point);;
   segment_to_push.area_between = (segment_to_push.fL + segment_to_push.fR) * (segment_to_push.right_point - segment_to_push.left_point) / 2;
   GLOBAL_STACK.push(segment_to_push);
   
   double m_time_start = omp_get_wtime();

   #pragma omp parallel num_threads(num_of_threads)
   {
      std::stack<struct segment> stack_to_use;
      integrate_local_stack(&stack_to_use);
   }

   double m_time_end = omp_get_wtime();

   printf("result %lg, time: %f\n", service.integral_result, m_time_end - m_time_start);
}

double func(double point)
{
   return (sin(1/(point)) / (point) ) * (sin(1/(point)) / (point)) ; //point * point;//sin(point) / point;
}

void integrate_local_stack(std::stack<struct segment>* stack_to_use)
{
   double counted_integral = 0;
   double left_point = 0;
   double right_point = 0;
   double fL = 0;
   double fR = 0;

   double area = 0;
   segment segment_to_push = {};
   segment segment_pop_into = {};

   double central_point = 0;
   double fC = 0;
   double left_center_area = 0;
   double central_right_area = 0;
   double sum_area = 0;

   while(1)
   {  
      sem_wait(&service.sem_task_present);
      
      #pragma omp critical
      {
         sem_wait(&service.stack_access);

         segment_pop_into = GLOBAL_STACK.top();

         left_point = segment_pop_into.left_point;
         right_point = segment_pop_into.right_point;
         fL = segment_pop_into.fL;
         fR = segment_pop_into.fR;
         area = segment_pop_into.area_between;

         GLOBAL_STACK.pop();

         /*if(!GLOBAL_STACK.empty())
            sem_post(&service.sem_task_present);      TODO was uncommented
         */
         if(left_point <= right_point) 
            service.proc_nactive++;
         
         sem_post(&service.stack_access);
      }

      if(left_point > right_point)
         break;

      while(1)
      {
         central_point = (left_point + right_point) / 2;
         fC = func(central_point);
         left_center_area = (fL + fC) * (central_point - left_point) / 2;
         central_right_area = (fC + fR) * (right_point - central_point) / 2;     
         sum_area = central_right_area + left_center_area;

       //  printf("%d %d\n", omp_get_thread_num(), stack_to_use -> size());


         if(abs(area - sum_area) > accuracy * abs(sum_area))
         {
            segment_to_push.left_point = left_point;
            segment_to_push.right_point = central_point;
            segment_to_push.fL = fL;
            segment_to_push.fR = fC;
            segment_to_push.area_between = left_center_area;
            stack_to_use -> push(segment_to_push);
            
            left_point = central_point;
            fL = fC;
            area = central_right_area;
         }
         else
         {
            counted_integral += sum_area;

            if(stack_to_use -> empty())
               break;

            segment_pop_into = stack_to_use -> top();

            left_point = segment_pop_into.left_point;
            right_point = segment_pop_into.right_point;
            fL = segment_pop_into.fL;
            fR = segment_pop_into.fR;
            area = segment_pop_into.area_between;

            stack_to_use -> pop();
         }

         if((stack_to_use -> size() > max_local_stack_size) || service.global_ntask == 0)
         {
            #pragma omp critical
            {
               sem_wait(&service.stack_access);
               
               while(stack_to_use -> size() > max_local_stack_size)
               {
                  segment_pop_into = stack_to_use -> top();
                  stack_to_use -> pop();
                  GLOBAL_STACK.push(segment_pop_into);
                  service.global_ntask++;
                  sem_post(&service.sem_task_present); //TODO was in the commented if at the bottom
               }

               /*if(GLOBAL_STACK.size())    //TODO was !GLOBAS_STAXK
               {
                  sem_post(&service.sem_task_present);                    // установить семафор наличия
                                                                          // записей в глобальном стеке
               }
               */
               sem_post(&service.stack_access);
            }
         }
      }
      
      #pragma omp critical
      {
         sem_wait(&service.stack_access);
         service.proc_nactive--;

         if( (!service.proc_nactive) && (!GLOBAL_STACK.size()) )
         {
            // запись в глобальный стек списка терминальных отрезков
            
            int i = 0;  
            segment terminal = {};
            terminal.left_point = 2;
            terminal.right_point = 1;
            
            for(i=0; i < omp_get_num_threads() ; i++)
            {
               GLOBAL_STACK.push(terminal);
               service.global_ntask++;
               sem_post(&service.sem_task_present); //TODO was out of cycle 
            }

         }

         sem_post(&service.stack_access);
      }
       

   }    // конец цикла обработки стека интервалов

   // Начало критической секции сложения частичных сумм
   #pragma omp critical
   {
      sem_wait(&(service.sem_sum));
      service.integral_result += counted_integral;
      sem_post(&(service.sem_sum));
   }
}