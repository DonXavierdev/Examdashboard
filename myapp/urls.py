
from django.contrib import admin
from django.urls import path
from . import views


urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('attendance/', views.attendance_view, name='attendance'),
    path('dutychange/', views.dutychange, name='dutychange'),
    path('exchange_accept/', views.exchange_accept, name='exchange_accept'),
]
