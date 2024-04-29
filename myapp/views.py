from django.shortcuts import render
from django.db import connection
from django.core.serializers import serialize
from datetime import datetime
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login
import json

def get_all_data(query, db_alias='default'):
    with connection.cursor() as cursor:
        cursor.execute(query)
        rows = cursor.fetchall()
    return rows

def execute_sql(sql, db_alias='default', args=None):
    with connection.cursor() as cursor:
        if args:
            cursor.execute(sql, args)
        else:
            cursor.execute(sql)
        # If you need to fetch any result after executing the query, you can do it here
        # result = cursor.fetchall()  # Example: fetching results
    # Committing the changes to the database
    connection.commit()

@csrf_exempt
def exchange_accept(request):
    if request.method == 'POST':
        print('hello')
        exchange_for = request.POST.get('exchange_for')
        exchange_by = request.POST.get('exchange_by')
        exchange_date = request.POST.get('exchange_date')
        print(exchange_date)
        sql = "INSERT INTO teacher_allocations (teacher_id,exam_id,exam_date,slot,room_id) VALUES (%s, %s, %s, %s,%s)"
        
       
        execute_sql(sql, args=(exchange_for, 73 , exchange_date,'Afternoon',1))
        sql = "DELETE FROM pending_exchanges WHERE exchange_for = '%s'" % (exchange_for)
        execute_sql(sql)


        
       
        execute_sql(sql, args=(exchange_for, 73 , exchange_date,'Afternoon',1))

        return HttpResponse("Change accepted.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)
@csrf_exempt

def dutychange(request):
    if request.method == 'POST':
        print('hello')
        exchange_for = request.POST.get('exchange_for')
        exchange_by = request.POST.get('exchange_by')
        friday_duty = request.POST.get('friday_duty')
        request_date = request.POST.get('request_date')
        print(exchange_by,exchange_for,friday_duty,request_date)
        query = f"SELECT teacher_id FROM teachers WHERE name = '{exchange_for}'"
        exchange_for = get_all_data(query)[0][0]
        friday_duty = int(friday_duty)
        sql = "INSERT INTO pending_exchanges (exchange_for, exchange_by, friday_duty, request_date) VALUES (%s, %s, %s, %s)"
        
       
        execute_sql(sql, args=(exchange_for, exchange_by, friday_duty, request_date))

        return HttpResponse("Change requested.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)



@csrf_exempt


def attendance_view(request):
    if request.method == 'POST':
        status = request.POST.get('status')
        prn = request.POST.get('prn')
        print(prn,status)

        return HttpResponse("Attendance marked successfully.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        user_id = request.POST.get('username')
        password = request.POST.get('password')    
        query = f"SELECT * FROM users WHERE user_id = '{user_id}'"    
        rows = get_all_data(query)
        if rows[0][1] == password:
            user_type = rows[0][2]  
            if user_type == 'Teacher':
                query = f"SELECT * FROM teachers WHERE teacher_id = '{user_id}'"
                teacher = get_all_data(query)
                teach_name = teacher[0][1]
                teach_dep = teacher[0][2]
                query = f"SELECT content FROM teacher_notifications WHERE teacher_id = '{user_id}'"
                teacher_notifies = get_all_data(query)            
                query = f"SELECT * FROM teacher_allocations WHERE teacher_id = '{user_id}'"
                teacher_allocations = get_all_data(query)
                
                # student_data = StudentAllocation.objects.all()
                teacher_allocations_data = []
                
                
                for allocation in teacher_allocations:
                    query = f"SELECT * FROM rooms WHERE room_id = '{allocation[4]}'"
                    room_data = get_all_data(query)   
                    query = f"SELECT prn FROM student_allocations WHERE exam_date = '{allocation[2]}' AND room_id = '{allocation[4]}' ORDER BY prn ASC"

                    student_prns = get_all_data(query) 
                    student_prns = [student[0] for student in student_prns]     
                    allocation_data = {
                        'room_name': room_data[0][1],
                        'date': datetime.strptime(allocation[2], "%d/%m/%Y").strftime("%Y-%m-%d"),
                        'student_prns': student_prns
                    }
                    teacher_allocations_data.append(allocation_data)
                teacher_notify_msgs = [notify[0] for notify in teacher_notifies]
                query = f"SELECT name FROM teachers"
                teacher_names = get_all_data(query)
                teacher_names = [name[0] for name in teacher_names]
                query = f"SELECT request_date FROM pending_exchanges WHERE exchange_for = '{user_id}'"
                exchangeRequest = get_all_data(query)
                if exchangeRequest:
                    exchangeRequest =exchangeRequest[0][0]
                    exchangeRequest = datetime.strptime(exchangeRequest, "%Y-%m-%d")
                    exchangeRequest = exchangeRequest.strftime("%d/%m/%Y")
                else:
                    exchangeRequest = ''
                
                data = {
                    'name': teach_name,
                    'prn': user_id,
                    'department': teach_dep,
                    'user_type': user_type,
                    'notification': teacher_notify_msgs,
                    'teacher_allocations': teacher_allocations_data,
                    'teacher_names':teacher_names,
                    'exchangeRequest':exchangeRequest
                }
                
                return JsonResponse(data)

            elif user_type == 'Student':
    
                query = f"SELECT * FROM students WHERE prn = '{user_id}'"
                student = get_all_data(query)
                stud_name = student[0][1]
                stud_dep = student[0][3]
                query = f"SELECT content FROM student_notifications WHERE prn = '{user_id}'"
                student_notifies = get_all_data(query)
                query = f"SELECT * FROM student_allocations WHERE prn = '{user_id}'"
                student_allocations = get_all_data(query)
                student_allocations_data = []

                for allocation in student_allocations:
                    query = f"SELECT * FROM rooms WHERE room_id = '{allocation[6]}'"
                    room_data = get_all_data(query)
                    query = f"SELECT * FROM room_classes WHERE room_class_id = '{room_data[0][2]}'"
                    class_data = get_all_data(query)
                    
                    allocation_data = {
                        'course_code': allocation[3],
                        'subject_name': allocation[4],
                        'room_name': room_data[0][1],
                        'date': datetime.strptime(allocation[2], "%d/%m/%Y").strftime("%Y-%m-%d"),
                        'student_row': allocation[7],
                        'student_col': allocation[8],
                        'room_columns': class_data[0][3],
                        'room_seats': class_data[0][2],
                        'room_rows': class_data[0][4],
                    }
                    student_allocations_data.append(allocation_data)
                student_notify_msgs = [notify[0] for notify in student_notifies]
                data = {
                    'name': stud_name,
                    'prn': user_id,
                    'department': stud_dep,
                    'user_type': user_type,
                    'notification': student_notify_msgs,
                    'student_allocations':student_allocations_data
                }
                return JsonResponse(data)

        else:
            return JsonResponse({'error': 'Invalid username or password'}, status=400)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)


