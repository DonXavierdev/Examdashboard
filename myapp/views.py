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


def exchange_accept(request):
    if request.method == 'POST':
        user_prn = request.POST.get('user_prn')
        exchange_for = request.POST.get('exchange_for')
        exam_id = request.POST.get('exam_id')
        friday_duty = request.POST.get('friday_duty')
        if friday_duty=='1':
            friday_duty=1
        else:
            friday_duty=0
        sql =" UPDATE exchange_requests SET approval_status = %s WHERE exam_id = %s AND exchange_for = %s AND exchange_by=%s"
        execute_sql(sql, args=(1,exam_id,exchange_for,user_prn))
        sql =" UPDATE teacher_allocations SET teacher_id = %s WHERE exam_id = %s AND teacher_id = %s"
        execute_sql(sql, args=(user_prn,exam_id,exchange_for))
        if friday_duty:
            sql =" UPDATE teachers SET friday_duties = friday_duties-1 WHERE teacher_id = %s"
            execute_sql(sql, args=(exchange_for))
        else:
            sql =" UPDATE teachers SET duties = duties-1 WHERE teacher_id = %s"
            execute_sql(sql, args=(exchange_for))
        sql =" UPDATE teacher_allocations SET teacher_id = %s WHERE exam_id = %s AND teacher_id = %s"
        execute_sql(sql, args=(user_prn,exam_id,user_prn))
        if friday_duty:
            sql =" UPDATE teachers SET friday_duties = friday_duties+1 WHERE teacher_id = %s"
            execute_sql(sql, args=(user_prn))
        else:
            sql =" UPDATE teachers SET duties = duties+1 WHERE teacher_id = %s"
            execute_sql(sql, args=(user_prn))
        sql = "INSERT INTO pending_exchanges (exchange_for, exchange_by,friday_duty) VALUES (%s, %s, %s)"
        execute_sql(sql, args=(exchange_for,user_prn,friday_duty))
        sql = f"select date from exam_data where exam_id = {exam_id}"
        expiry_date = get_all_data(sql)[0][0]
        day, month, year = expiry_date.strip('()').split('/')
        expiry_date = f'{year}-{month}-{day}'
        sql = "INSERT INTO teacher_notifications (teacher_id, content, expiry) VALUES (%s, %s, %s)"
        content = f"Exchange Request has been accepted by {user_prn}"
        execute_sql(sql, args=(exchange_for, content, expiry_date))

        return HttpResponse("Change accepted.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)
    
def exchange_reject(request):
    if request.method == 'POST':
        user_prn = request.POST.get('user_prn')
        exchange_for = request.POST.get('exchange_for')
        exam_id = request.POST.get('exam_id')
        sql =" UPDATE exchange_requests SET approval_status = %s WHERE exam_id = %s AND exchange_for = %s AND exchange_by=%s"
        execute_sql(sql, args=(0,exam_id,exchange_for,user_prn))
        sql = f"select date from exam_data where exam_id = {exam_id}"
        expiry_date = get_all_data(sql)[0][0]
        day, month, year = expiry_date.strip('()').split('/')
        expiry_date = f'{year}-{month}-{day}'
        sql = "INSERT INTO teacher_notifications (teacher_id, content, expiry) VALUES (%s, %s, %s)"
        content = 'Exchange Request has been rejected by {}'.format(user_prn)
        execute_sql(sql, args=(exchange_for, content, expiry_date))
        return HttpResponse("Change Not accepted.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)

def dutychange(request):
    if request.method == 'POST':
        exchange_for = request.POST.get('exchange_for')
        exchange_by = request.POST.get('exchange_by')
        exam_id = request.POST.get('exam_id')
        # request_date = request.POST.get('request_date')
        
        query = f"SELECT teacher_id FROM teachers WHERE name = '{exchange_by}'"
        exchange_by = get_all_data(query)[0][0]
        sql = "INSERT INTO exchange_requests (exchange_for, exchange_by,exam_id) VALUES (%s, %s, %s)"

        execute_sql(sql, args=(exchange_for, exchange_by,exam_id))

        return HttpResponse("Change requested.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)

def grab_teacher_names(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('user_id')
        exam_id = data.get('exam_id')
        exam_date = data.get('exam_date')
       
        query = f"""
            SELECT name 
            FROM teachers 
            WHERE teacher_id NOT IN ('{user_id}', 'COE') 
                AND available = 1 
                AND teacher_id NOT IN (
                SELECT exchange_by 
                FROM exchange_requests 
                WHERE exchange_for = '{user_id}' 
                    AND     exam_id = {exam_id}
                    AND approval_status = 1 OR approval_status IS NULL
                ) 
                AND teacher_id NOT IN (
                SELECT teacher_id 
                FROM teacher_allocations 
                WHERE exam_date = '{exam_date}'
                );
        """
        results = get_all_data(query)
        teacher_names = [row[0] for row in results]

        return JsonResponse({'teacher_names': teacher_names})
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)

def attendance_update(request):
    if request.method == 'POST':
        status = request.POST.get('status')
        prn = request.POST.get('prn')
        exam_id = request.POST.get('exam_id')
        query = f"UPDATE student_allocations SET attendance = {status} WHERE prn = '{prn}' AND exam_id = '{exam_id}'"
        with connection.cursor() as cursor:
            cursor.execute(query)
        return HttpResponse("Attendance marked successfully.", status=200)
    else:
        return HttpResponse("Method not allowed", status=405)

def get_attendance_status(request):
    data = json.loads(request.body)
    prn = data.get('prn', [])
    exam_id = data.get('exam_id')
    print(exam_id)
    status_list = []
    try:
        for i in prn:
            query = f"SELECT attendance FROM student_allocations WHERE prn = '{i}' AND exam_id = {exam_id}" 
            each_status = get_all_data(query)[0][0]
            status_list.append(each_status)
        return JsonResponse({'status': status_list}) 
    except:
        return JsonResponse({'status': None}, status=404)
 

def login_view(request):
    if request.method == 'POST':
        user_id = request.POST.get('username').upper()
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
                query = f" SELECT content FROM general_notifications UNION ALL SELECT content FROM teacher_notifications WHERE teacher_id = '{user_id}' "
                teacher_notifies = get_all_data(query)            
                print(teacher_notifies)
                query = f"SELECT * FROM teacher_allocations WHERE teacher_id = '{user_id}' AND exam_id IN (SELECT exam_id FROM exam_data WHERE authorization = 1) ORDER BY STR_TO_DATE(exam_date, '%d/%m/%Y')"

                teacher_allocations = get_all_data(query)
                
                # student_data = StudentAllocation.objects.all()
                teacher_allocations_data = []
                
                
                for allocation in teacher_allocations:
                    query = f"SELECT * FROM rooms WHERE room_id = '{allocation[4]}'"
                    room_data = get_all_data(query)                       
                    query = f"SELECT student_list FROM teacher_allocations WHERE teacher_id = '{allocation[0]}' AND exam_id = '{allocation[1]}'"
                    student_prns = get_all_data(query)
                    student_prns=student_prns[0][0]
                    student_prns=json.loads(student_prns)
                    query = f"SELECT day FROM exam_data WHERE exam_id = '{allocation[1]}'"
                    day = get_all_data(query) [0][0]
                    allocation_data = {
                        'room_name': room_data[0][1],
                        'date': datetime.strptime(allocation[2], "%d/%m/%Y").strftime("%Y-%m-%d"),
                        'exam_id':allocation[1],
                        'student_prns': student_prns,
                        'slot':allocation[3],
                        'day':day,
                    }
                    teacher_allocations_data.append(allocation_data)
                teacher_notify_msgs = [notify[0] for notify in teacher_notifies]
                query = f"SELECT exam_id,exchange_for FROM exchange_requests WHERE exchange_by = '{user_id}' AND approval_status IS NULL"
                exchangeRequest = get_all_data(query)
                NewexchangeRequest = []        
                if len(exchangeRequest) > 0:
                    for i in exchangeRequest:
                        query = f"SELECT day FROM exam_data where exam_id = '{i[0]}'"
                        selectDay = get_all_data(query)[0][0]
                        if selectDay == 'Friday':
                            selectDay = ('1',)
                        else:
                            selectDay = ('0',)
                        i+=selectDay
                        query = f"SELECT date,slot FROM exam_data where exam_id = '{i[0]}'"
                        selectDay = get_all_data(query)[0]
                        i+=selectDay
                        query = f"SELECT name FROM teachers where teacher_id = '{i[1]}'"
                        selectDay = get_all_data(query)[0]
                        i+=selectDay
                        NewexchangeRequest.append(i)
                    

                        
                print(NewexchangeRequest)
                data = {
                    'name': teach_name,
                    'prn': rows[0][0],
                    'department': teach_dep,
                    'user_type': user_type,
                    'notification': teacher_notify_msgs,
                    'teacher_allocations': teacher_allocations_data,
                    'exchangeRequest':tuple(NewexchangeRequest)
                }
                
                return JsonResponse(data)

            elif user_type == 'Student':
    
                query = f"SELECT * FROM students WHERE prn = '{user_id}'"
                student = get_all_data(query)
                stud_name = student[0][1]
                stud_dep = student[0][3]
                stud_level = student[0][2]
                stud_batch = student[0][4]
                query = f"""
                    SELECT content
                    FROM exam_cell_data.student_notifications 
                    WHERE 
                        (prn = '{user_id}' 
                        OR (level = '{stud_level }' AND batch = '{stud_batch}') 
                        OR (program = '{stud_dep}' AND batch = '{stud_batch}') )
                        AND str_to_date(expiry, '%Y-%m-%d') > CURDATE()

                    UNION ALL

                    SELECT content
                    FROM exam_cell_data.general_notifications 
                    WHERE str_to_date(expiry, '%Y-%m-%d') > CURDATE();
                    """
                student_notifies = get_all_data(query)
                query = f"SELECT * FROM student_allocations WHERE prn = '{user_id}' AND exam_id IN (SELECT exam_id FROM exam_data WHERE authorization = 1) ORDER BY STR_TO_DATE(exam_date, '%d/%m/%Y')"
                student_allocations = get_all_data(query)
                student_allocations_data = []

                for allocation in student_allocations:
                    query = f"SELECT room_name FROM rooms WHERE room_id = '{allocation[6]}'"
                    room_name = get_all_data(query)[0][0]
                    # query = f"SELECT * FROM room_classes WHERE room_class_id = '{room_data[0][2]}'"
                    # class_data = get_all_data(query)
                    query = f"SELECT allocation_data FROM room_allocations WHERE room_id = {allocation[6]} AND exam_id ={allocation[1]}"
                    room_alloc_data = json.loads(get_all_data(query)[0][0])                    
                    total_rows = len(room_alloc_data)
                    total_columns = len(room_alloc_data[0])
                    query = f"SELECT day FROM exam_data WHERE exam_id = '{allocation[1]}'"
                    day = get_all_data(query) [0][0]
                    allocation_data = {
                        'course_code': allocation[3],
                        'subject_name': allocation[4],
                        'room_name': room_name,
                        'date': datetime.strptime(allocation[2], "%d/%m/%Y").strftime("%Y-%m-%d"),
                        'student_row': allocation[7],
                        'student_col': allocation[8],
                        'student_seat': allocation[9],
                        'room_columns': total_columns,
                        'room_rows': total_rows,
                        'day':day,

                    }
                    student_allocations_data.append(allocation_data)
                student_notify_msgs = [notify[0] for notify in student_notifies]
                data = {
                    'name': stud_name,
                    'prn': user_id,
                    'department': stud_dep,
                    'level': stud_level,
                    'batch': stud_batch,
                    'user_type': user_type,
                    'notification': student_notify_msgs,
                    'student_allocations':student_allocations_data
                }
                return JsonResponse(data)

        else:
            return JsonResponse({'error': 'Invalid username or password'}, status=400)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)


