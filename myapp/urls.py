
from django.contrib import admin
from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('attendance/', views.attendance_update, name='attendance'),
    path('dutychange/', views.dutychange, name='dutychange'),
    path('exchange_accept/', views.exchange_accept, name='exchange_accept'),
    path('exchange_reject/', views.exchange_reject, name='exchange_reject'),
    path('attendance/status/', views.get_attendance_status, name='get_attendance_status'),
    path('grab_teacher_names/', views.grab_teacher_names, name='grab_teacher_names'),
]
