# from django.db import models


# class Users(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     prn =  models.CharField(max_length=25,default='210021027643')
#     password =  models.CharField(max_length=15)
#     type =  models.CharField(max_length=10,default='student')
#     class Meta:
#         ordering = ['prn', 'password', 'type']
# class User_date(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     prn =  models.CharField(max_length=25)
    
# class Student(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     name = models.CharField(max_length=100)
#     prn = models.CharField(max_length=100)
#     department =  models.CharField(max_length=100)
#     cgpa = models.DecimalField(max_digits=5 ,decimal_places=2)

# class StudentAllocation(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     prn = models.CharField(max_length=100)
#     course_code = models.CharField(max_length=100)
#     room_name = models.CharField(max_length=100)
#     student_row = models.IntegerField(default=2)
#     student_col = models.IntegerField(default=1)
#     date = models.DateField()

# class TeacherAllocation(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     prn = models.CharField(max_length=100)
#     room_name = models.CharField(max_length=100)
#     date = models.DateField()

# class Teacher(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     name = models.CharField(max_length=100)
#     prn = models.CharField(max_length=100)
#     department =  models.CharField(max_length=100)

# class Notification(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     prn =  models.CharField(max_length=25,default='210021027643')
#     message = models.TextField(max_length=100)

# class test(models.Model):
#     id = models.BigAutoField(primary_key=True)
#     msg = models.TextField(max_length=100)
    
# class RoomData(models.Model):
#     room_name = models.CharField(max_length=255)
#     seats = models.IntegerField()
#     columns = models.IntegerField()
#     rows = models.IntegerField()

#     class Meta:
#         db_table = 'room_data'
